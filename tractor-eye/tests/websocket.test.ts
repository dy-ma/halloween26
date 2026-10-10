import assert from 'node:assert/strict'
import { test, type TestContext } from 'node:test'
import { AnimationCommandBus } from '../src/commands/command-bus.ts'
import type { AnimationCommand } from '../src/commands/animation-command.ts'
import { decodeRuntimeConfig } from '../src/network/config.ts'
import { decodeServerMessage, MAX_FRAME_BYTES } from '../src/network/protocol.ts'
import { createInitialEyeState, reduceEyeCommand } from '../src/features/eye/eye-state.ts'
import { wakeSequenceSource } from '../src/sources/wake-sequence-source.ts'
import { createRuntimeWebSocketSource } from '../src/sources/runtime-websocket-source.ts'
import { createWebSocketCommandSource, type ConnectionStatus } from '../src/sources/websocket-command-source.ts'

class FakeSocket extends EventTarget {
  sent: Record<string, unknown>[] = []
  closed = false
  send(text: string) { this.sent.push(JSON.parse(text)) }
  close() { this.closed = true }
  open() { this.dispatchEvent(new Event('open')) }
  receive(value: unknown) { this.raw(JSON.stringify(value)) }
  raw(data: unknown) { this.dispatchEvent(new MessageEvent('message', { data })) }
}

const config = decodeRuntimeConfig({ screenId: 'tractor-eye', websocket: { enabled: true, url: '/ws' } }, 'http://localhost:8080/')
const snapshot = (seq = 0, mode = 'sleeping') => ({
  v: 1, type: 'snapshot', sessionId: 'boot-1', seq,
  state: { mode, gaze: { x: 0, y: 0 } },
})
const command = (seq = 1, extras = {}) => ({
  v: 1, type: 'command', sessionId: 'boot-1', seq, expiresAtMs: 100_000,
  command: { type: 'eye/wake' }, ...extras,
})

function setup(t: TestContext) {
  t.mock.timers.enable({ apis: ['setTimeout', 'Date'], now: 10_000 })
  const bus = new AnimationCommandBus()
  const received: AnimationCommand[] = []
  const statuses: Readonly<ConnectionStatus>[] = []
  const sockets: FakeSocket[] = []
  bus.subscribe(c => received.push(c))
  const source = createWebSocketCommandSource(config, {
    random: () => 1,
    now: () => Date.now(),
    createSocket: () => { const s = new FakeSocket(); sockets.push(s); return s },
    onStatus: s => statuses.push(s),
  })
  const stop = source.start(bus)
  t.after(stop)
  return { bus, source, stop, received, statuses, sockets, socket: sockets[0]! }
}

test('configuration resolves same-origin WS/WSS and explicit disabled mode', () => {
  assert.deepEqual(config, { screenId: 'tractor-eye', websocket: { enabled: true, url: 'ws://localhost:8080/ws' } })
  const enabled = { screenId: 'eye', websocket: { enabled: true, url: '/ws' } }
  assert.equal(decodeRuntimeConfig(enabled, 'https://host/').websocket.enabled, true)
  assert.deepEqual(decodeRuntimeConfig(enabled, 'https://host/').websocket, { enabled: true, url: 'wss://host/ws' })
  assert.deepEqual(decodeRuntimeConfig({ screenId: 'eye', websocket: { enabled: false } }, 'http://host/').websocket, { enabled: false })
  for (const url of ['ws://host/ws', '//host/ws', 'https://host/ws', 'javascript:alert(1)', 'wss://u:p@host/ws', '/ws#fragment']) {
    assert.throws(() => decodeRuntimeConfig({ ...enabled, websocket: { enabled: true, url } }, 'https://host/'))
  }
  assert.throws(() => decodeRuntimeConfig({}, 'http://host/'))
})

test('wire validation rejects malformed, binary, oversized, unbounded, and local-only messages', () => {
  const invalid: unknown[] = [
    '{', new Uint8Array(1), ' '.repeat(MAX_FRAME_BYTES + 1),
    JSON.stringify({ ...command(), padding: '🦉'.repeat(2200) }),
    ...[
      { ...command(), v: 2 }, { ...command(), seq: -1 }, { ...command(), seq: 1.5 },
      { ...command(), seq: Number.MAX_SAFE_INTEGER + 1 }, { ...command(), expiresAtMs: -1 },
      { ...command(), sessionId: '' }, { ...command(), command: { type: 'eye/snapshot', state: snapshot().state } },
      { ...command(), command: { type: 'eye/look', x: 1.01, y: 0 } },
      { ...command(), command: { type: 'eye/nudge', x: 0, y: -2 } },
      { ...command(), command: { type: 'eye/open', durationMs: 10001 } },
      { ...command(), command: { type: 'eye/blink', durationMs: -1 } },
      { ...snapshot(), state: { mode: 'unknown', gaze: { x: 0, y: 0 } } },
      { ...snapshot(), state: { mode: 'idle', gaze: { x: null, y: 0 } } },
    ].map(v => JSON.stringify(v)),
    '{"v":1,"type":"command","sessionId":"b","seq":1,"expiresAtMs":100,"command":{"type":"eye/look","x":1e999,"y":0}}',
  ]
  for (const raw of invalid) assert.equal(decodeServerMessage(raw), undefined)
  assert.equal(decodeServerMessage(JSON.stringify(command()))?.type, 'command')
  assert.equal(decodeServerMessage(JSON.stringify(snapshot()))?.type, 'snapshot')
})

test('hello, atomic snapshot, ordered commands and duplicate suppression', t => {
  const h = setup(t)
  h.socket.open()
  assert.deepEqual(h.socket.sent, [{ v: 1, type: 'hello', screenId: 'tractor-eye' }])
  h.socket.receive(snapshot(10))
  h.socket.receive(command(11))
  h.socket.receive(command(11))
  h.socket.receive(command(9))
  assert.deepEqual(h.received.map(c => c.type), ['eye/snapshot', 'eye/wake'])
  assert.equal(h.statuses.at(-1)?.lastAcceptedSeq, 11)
})

for (const [name, message] of [
  ['sequence gap', command(2)],
  ['expired cue', command(1, { expiresAtMs: 10000 })],
  ['session mismatch', command(1, { sessionId: 'different' })],
  ['repeated snapshot', snapshot()],
  ['unsolicited pong', { v: 1, type: 'pong', id: 'bad' }],
  ['invalid envelope', { v: 9, type: 'command' }],
] as const) {
  test(`${name} retires connection without publishing a cue`, t => {
    const h = setup(t)
    h.socket.open()
    h.socket.receive(snapshot())
    h.socket.receive(message)
    assert.equal(h.socket.closed, true)
    assert.equal(h.statuses.at(-1)?.phase, 'retrying')
    assert.equal(h.received.length, 1)
    h.socket.receive(command()) // A retired socket cannot publish late events.
    t.mock.timers.tick(500)
    assert.equal(h.sockets.length, 2)
    h.sockets[1]!.open()
    h.sockets[1]!.receive({ ...snapshot(50, 'tipping'), sessionId: 'boot-2' })
    assert.equal(h.received.length, 2)
    assert.equal(h.received.at(-1)?.type, 'eye/snapshot')
  })
}

test('commands before snapshot fail closed; keyboard remains usable', t => {
  const h = setup(t)
  h.socket.open()
  h.socket.receive(command())
  assert.equal(h.received.length, 0)
  h.bus.publish({ type: 'eye/wake' })
  assert.equal(h.received.length, 1)
  assert.equal(h.socket.closed, true)
})

test('connect/snapshot deadline retires a stalled connection', t => {
  const h = setup(t)
  h.socket.open()
  t.mock.timers.tick(5000)
  assert.equal(h.socket.closed, true)
  assert.equal(h.statuses.at(-1)?.reason, 'connect-or-snapshot-timeout')
})

test('one outstanding heartbeat; pongs never enter the animation bus', t => {
  const h = setup(t)
  h.socket.open()
  h.socket.receive(snapshot())
  t.mock.timers.tick(5000)
  assert.deepEqual(h.socket.sent.at(-1), { v: 1, type: 'ping', id: '1' })
  t.mock.timers.tick(5000)
  assert.equal(h.socket.sent.length, 2)
  h.socket.receive({ v: 1, type: 'pong', id: '1' })
  assert.equal(h.received.length, 1)
  assert.equal(h.statuses.at(-1)?.lastHeartbeatAtMs, Date.now())
  t.mock.timers.tick(5000)
  assert.deepEqual(h.socket.sent.at(-1), { v: 1, type: 'ping', id: '2' })
  t.mock.timers.tick(10000)
  assert.equal(h.socket.closed, true)
  assert.equal(h.statuses.at(-1)?.reason, 'heartbeat-timeout')
})

test('cleanup cancels every timer and permits clean Strict Mode remount', t => {
  const h = setup(t)
  h.socket.open()
  h.socket.receive(snapshot())
  h.stop()
  h.socket.receive(command())
  t.mock.timers.tick(60000)
  assert.equal(h.sockets.length, 1)
  assert.equal(h.received.length, 1)
  const stopAgain = h.source.start(h.bus)
  t.after(stopAgain)
  assert.equal(h.sockets.length, 2)
  stopAgain()
  t.mock.timers.tick(60000)
  assert.equal(h.sockets.length, 2)
})

test('backoff grows on flapping connections and resets only after 30 healthy seconds', t => {
  const h = setup(t)
  h.socket.dispatchEvent(new Event('error'))
  h.socket.dispatchEvent(new Event('close'))
  t.mock.timers.tick(499)
  assert.equal(h.sockets.length, 1)
  t.mock.timers.tick(1)
  const s = h.sockets[1]!
  s.open()
  s.receive(snapshot())
  s.dispatchEvent(new Event('close'))
  t.mock.timers.tick(999)
  assert.equal(h.sockets.length, 2)
  t.mock.timers.tick(1)
  const healthy = h.sockets[2]!
  healthy.open()
  healthy.receive(snapshot())
  for (let i = 1; i <= 6; i++) {
    t.mock.timers.tick(5000)
    healthy.receive({ v: 1, type: 'pong', id: String(i) })
  }
  healthy.dispatchEvent(new Event('close'))
  t.mock.timers.tick(500)
  assert.equal(h.sockets.length, 4)
})

test('socket construction failure retries and cleanup cancels the retry', t => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  let attempts = 0
  const stop = createWebSocketCommandSource(config, {
    random: () => 1, createSocket: () => { attempts++; throw new Error('network') },
  }).start(new AnimationCommandBus())
  t.mock.timers.tick(500)
  assert.equal(attempts, 2)
  stop()
  t.mock.timers.tick(60000)
  assert.equal(attempts, 2)
})

test('retry delay caps at ten seconds even after repeated immediate failures', t => {
  const h = setup(t)
  for (const delay of [500, 1000, 2000, 4000, 8000, 10000, 10000]) {
    const count = h.sockets.length
    h.sockets.at(-1)!.dispatchEvent(new Event('error'))
    t.mock.timers.tick(delay - 1)
    assert.equal(h.sockets.length, count)
    t.mock.timers.tick(1)
    assert.equal(h.sockets.length, count + 1)
  }
})

test('snapshot cancels Wake and applies a stable instantaneous pose', t => {
  const h = setup(t)
  let state = createInitialEyeState()
  h.bus.subscribe(c => { state = reduceEyeCommand(state, c) })
  const stopWake = wakeSequenceSource.start(h.bus)
  t.after(stopWake)
  h.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(600)
  h.socket.open()
  h.socket.receive({ ...snapshot(30, 'tipping'), state: { mode: 'tipping', gaze: { x: -.25, y: -.65 } } })
  assert.equal(state.instantPose, true)
  assert.equal(state.blinkSequence, 0)
  assert.equal(state.transitionDurationMs, 0)
  assert.equal(state.gazeDurationMs, 0)
  assert.equal(state.snapshotRevision, 1)
  t.mock.timers.tick(4000)
  assert.deepEqual(state.gaze, { x: -.25, y: -.65 })
  assert.equal(state.mode, 'tipping')
  h.bus.publish({ type: 'eye/close' })
  assert.equal(state.instantPose, false)
  assert.equal(state.transitionDurationMs, 900)
  h.bus.publish({ type: 'eye/snapshot', state: { mode: 'tipping', gaze: { x: -.25, y: -.65 } } })
  assert.equal(state.snapshotRevision, 2)
  h.bus.publish({ type: 'eye/wake' })
  assert.equal(state.snapshotRevision, 2)
  h.bus.publish({ type: 'system/reset' })
  assert.equal(state.snapshotRevision, 2)
})

test('disconnect and heartbeat do not cancel an in-flight Wake', t => {
  const h = setup(t)
  let state = createInitialEyeState()
  h.bus.subscribe(c => { state = reduceEyeCommand(state, c) })
  t.after(wakeSequenceSource.start(h.bus))
  h.socket.open()
  h.socket.receive(snapshot())
  h.socket.receive(command())
  t.mock.timers.tick(600)
  h.socket.dispatchEvent(new Event('close'))
  t.mock.timers.tick(1000)
  assert.equal(state.mode, 'tipping')
  assert.deepEqual(state.gaze, { x: -.25, y: -.65 })
})

test('config fetch is uncached, disabled config never opens a socket', async () => {
  let calls = 0
  const phases: string[] = []
  const stop = createRuntimeWebSocketSource({
    pageUrl: 'http://host:8080/',
    fetchConfig: async (url, init) => {
      assert.equal(String(url), 'http://host:8080/config.json')
      assert.equal(init?.cache, 'no-store')
      return new Response(JSON.stringify({ screenId: 'eye', websocket: { enabled: false } }))
    },
    createSocket: () => { calls++; return new FakeSocket() },
    onStatus: s => phases.push(s.phase),
  }).start(new AnimationCommandBus())
  await new Promise(resolve => setImmediate(resolve))
  stop()
  assert.equal(calls, 0)
  assert.deepEqual(phases, ['disabled'])
})

test('invalid or missing config reports an error without opening a socket', async () => {
  for (const response of [new Response('not JSON'), new Response('{}', { status: 404 }), new Response('{}')]) {
    const phases: string[] = []
    const stop = createRuntimeWebSocketSource({
      pageUrl: 'http://host/', fetchConfig: async () => response,
      createSocket: () => { throw new Error('must not connect') }, onStatus: s => phases.push(s.phase),
    }).start(new AnimationCommandBus())
    await new Promise(resolve => setImmediate(resolve))
    stop()
    assert.deepEqual(phases, ['config-error'])
  }
})

test('unmount while loading config cannot open a late socket', async () => {
  let finish!: (response: Response) => void
  let sockets = 0
  const stop = createRuntimeWebSocketSource({
    pageUrl: 'http://host/', fetchConfig: () => new Promise(resolve => { finish = resolve }),
    createSocket: () => { sockets++; return new FakeSocket() },
  }).start(new AnimationCommandBus())
  stop()
  finish(new Response(JSON.stringify({ screenId: 'eye', websocket: { enabled: true, url: '/ws' } })))
  await new Promise(resolve => setImmediate(resolve))
  assert.equal(sockets, 0)
})

test('config deadline aborts a hanging fetch and reports a configuration error', async t => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const phases: string[] = []
  let aborted = false
  const stop = createRuntimeWebSocketSource({
    pageUrl: 'http://host/',
    fetchConfig: (_url, init) => new Promise((_resolve, reject) => {
      init!.signal!.addEventListener('abort', () => { aborted = true; reject(new Error('aborted')) })
    }),
    onStatus: s => phases.push(s.phase),
  }).start(new AnimationCommandBus())
  t.after(stop)
  t.mock.timers.tick(5000)
  await new Promise(resolve => setImmediate(resolve))
  assert.equal(aborted, true)
  assert.deepEqual(phases, ['config-error'])
})
