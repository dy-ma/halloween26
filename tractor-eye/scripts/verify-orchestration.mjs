// Requires the isolated sync/shows/orchestration-smoke.toml coordinator and
// mosquitto CLI tools. It never uses the production `halloween` MQTT prefix.
import assert from 'node:assert/strict'
import { spawn } from 'node:child_process'
import { createInterface } from 'node:readline'
import { randomBytes } from 'node:crypto'
import WebSocket from 'ws'

const base = new URL(process.argv[2] ?? 'http://127.0.0.1:18080')
const broker = process.argv[3] ?? '127.0.0.1'
const port = process.argv[4] ?? '1883'
const node = 0x001122334455n
const coordinator = 0x0200000000FEn
const prefix = 'halloween-smoke'
const sockets = []
let subscription

async function bounded(promise, ms = 5000) {
  let timer
  try { return await Promise.race([promise, new Promise((_, reject) => { timer = setTimeout(() => reject(new Error('Smoke-test deadline exceeded')), ms) })]) }
  finally { clearTimeout(timer) }
}

async function read(path) {
  const response = await fetch(new URL(path, base))
  if (!response.ok) throw new Error(`${path}: ${await response.text()}`)
  return response.json()
}

function packet(kind, id, name = '') {
  assert.ok(Buffer.byteLength(name) <= 31)
  const bytes = Buffer.alloc(64)
  bytes.write('CUE2'); bytes[4] = 2; bytes[5] = kind
  bytes.writeBigUInt64LE(node, 8); bytes.writeBigUInt64LE(coordinator, 16)
  bytes.writeBigUInt64LE(id, 24); bytes.write(name, 32)
  return bytes
}

async function publish(bytes) {
  await new Promise((resolve, reject) => {
    const child = spawn('mosquitto_pub', ['-h', broker, '-p', port, '-q', '1', '-t', `${prefix}/cue/0200000000FE`, '-s'])
    let error = ''
    child.stderr.on('data', chunk => { error += chunk })
    child.on('error', reject)
    child.on('close', code => code === 0 ? resolve() : reject(new Error(error || `mosquitto_pub exited ${code}`)))
    child.stdin.end(bytes)
  })
}

async function display(role) {
  const url = new URL('/ws', base); url.protocol = base.protocol === 'https:' ? 'wss:' : 'ws:'
  const socket = new WebSocket(url, { origin: base.origin })
  const commands = []
  sockets.push(socket)
  await bounded(new Promise((resolve, reject) => {
    socket.once('error', reject)
    socket.on('open', () => socket.send(JSON.stringify({ v: 1, type: 'hello', screenId: role, clientId: `smoke-${role}`, clientName: `Smoke ${role}` })))
    socket.on('message', raw => {
      const message = JSON.parse(String(raw))
      if (message.type === 'snapshot') resolve()
      if (message.type === 'command') {
        commands.push(message.command.type)
        socket.send(JSON.stringify({ v: 1, type: 'applied', sessionId: message.sessionId, seq: message.seq }))
      }
    })
  }))
  return commands
}

try {
  const [left, right] = await Promise.all([display('left'), display('right')])
  subscription = spawn('mosquitto_sub', ['-h', broker, '-p', port, '-t', `${prefix}/cue/001122334455`, '-F', '%x'])
  const lines = createInterface({ input: subscription.stdout })
  const command = bounded(new Promise((resolve, reject) => {
    subscription.once('error', reject)
    subscription.stderr.on('data', raw => reject(new Error(String(raw))))
    lines.on('line', hex => {
      const bytes = Buffer.from(hex.trim(), 'hex')
      if (bytes.length === 64 && bytes[5] === 1) resolve(bytes)
    })
  }))
  const response = await fetch(new URL('/api/control', base), {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ control: 'run_smoke', phase: 'press' }),
  })
  assert.equal(response.ok, true)
  const outgoing = await command
  assert.equal(outgoing.readBigUInt64LE(8), coordinator)
  assert.equal(outgoing.readBigUInt64LE(16), node)
  const id = outgoing.readBigUInt64LE(24)
  await publish(packet(2, id)) // Transport ACK alone must not release the graph.
  const name = value => `dc:limit:fwd:${value.toString(16).padStart(16, '0').toUpperCase()}`
  const stale = id ^ 1n
  const statusId = () => randomBytes(8).readBigUInt64LE()
  await publish(packet(1, statusId(), name(stale))) // Nor may an unrelated/old completion.
  await bounded((async () => {
    for (;;) {
      const waiting = await read('/api/status')
      if (waiting.devices.some(device => device.commandId === stale.toString(16).padStart(16, '0').toUpperCase())) {
        assert.equal(waiting.runs[0].nodes[0].phase, 'running')
        assert.deepEqual(left, []); assert.deepEqual(right, [])
        return
      }
      await new Promise(resolve => setTimeout(resolve, 25))
    }
  })())
  await publish(packet(1, statusId(), name(id)))
  await bounded((async () => {
    for (;;) {
      const state = await read('/api/status')
      if (state.runs[0].nodes.every(entry => entry.phase === 'complete')) return
      if (state.runs[0].nodes.some(entry => entry.phase === 'failed')) throw new Error(JSON.stringify(state.runs[0]))
      await new Promise(resolve => setTimeout(resolve, 25))
    }
  })())
  assert.deepEqual(left, ['eye/wake', 'system/reset'])
  assert.deepEqual(right, ['eye/wake', 'system/reset'])
  const screens = await read('/api/screens')
  const connections = (await read('/api/displays')).flatMap(device => device.connections)
  // Group and per-connection counters intentionally diverge after private
  // commands or reconnects; compare an ACK with its own connection sequence.
  assert.ok(screens.every(screen => screen.sequence >= 2 && connections.some(client =>
    client.screenId === screen.id && client.connected && client.sequence >= 2 && client.lastAppliedSequence === client.sequence)))
  console.log(JSON.stringify({ passed: true, checks: ['MQTT transport ACK does not complete motion', 'stale command status rejected', 'matching limit status releases parallel display branches', 'two independent WebSocket clients acknowledge commands', 'DAG join resets both displays'], screens: screens.map(screen => screen.id) }, null, 2))
} finally {
  for (const socket of sockets) socket.terminate()
  subscription?.kill('SIGTERM')
}
