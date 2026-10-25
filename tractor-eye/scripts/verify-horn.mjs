// End-to-end horn semantics against sync/shows/horn-smoke.toml. The profile
// uses an isolated MQTT prefix, a simulated motor and a muted non-JBL output.
import assert from 'node:assert/strict'
import { spawn } from 'node:child_process'
import WebSocket from 'ws'

const base = new URL(process.argv[2] ?? 'http://127.0.0.1:18083')
const broker = process.argv[3] ?? '127.0.0.1'
const port = process.argv[4] ?? '1883'
const coordinator = 0x0200000000FDn
const horn = 0x00112233AA55n
const topic = 'halloween-horn-smoke/cue/0200000000FD'
const sockets = []

const wait = ms => new Promise(resolve => setTimeout(resolve, ms))
async function until(check, timeout = 5000) {
  const deadline = Date.now() + timeout
  while (Date.now() < deadline) {
    const result = await check()
    if (result) return result
    await wait(25)
  }
  throw new Error('Horn smoke-test deadline exceeded')
}
async function read(path) {
  const response = await fetch(new URL(path, base))
  assert.ok(response.ok, await response.clone().text())
  return response.json()
}
async function control(id) {
  const response = await fetch(new URL('/api/control', base), {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ control: id, phase: 'press' }),
  })
  assert.ok(response.ok, await response.text())
}
function cue(id, event = 'horn:pushed') {
  const bytes = Buffer.alloc(80)
  bytes.write('CUE3'); bytes[4] = 3; bytes[5] = 1
  bytes.writeBigUInt64LE(horn, 8); bytes.writeBigUInt64LE(coordinator, 16)
  bytes.writeBigUInt64LE(id, 24); bytes.write(event, 48)
  return bytes
}
async function publish(bytes) {
  await new Promise((resolve, reject) => {
    const [program, args] = broker.startsWith('ssh:')
      ? ['ssh', [broker.slice(4), 'mosquitto_pub', '-h', '127.0.0.1', '-p', port, '-q', '1', '-t', topic, '-s']]
      : ['mosquitto_pub', ['-h', broker, '-p', port, '-q', '1', '-t', topic, '-s']]
    const child = spawn(program, args)
    let error = ''
    child.stderr.on('data', chunk => { error += chunk })
    child.on('error', reject)
    child.on('close', code => code === 0 ? resolve() : reject(new Error(error || `mosquitto_pub exited ${code}`)))
    child.stdin.end(bytes)
  })
}
async function display() {
  const url = new URL('/ws', base); url.protocol = 'ws:'
  const socket = new WebSocket(url, { headers: { origin: base.origin } })
  const commands = []
  sockets.push(socket)
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Display snapshot deadline')), 3000)
    socket.once('error', reject)
    socket.on('open', () => socket.send(JSON.stringify({
      v: 1, type: 'hello', screenId: 'horn-smoke-eye',
      clientId: 'horn-smoke-eye', clientName: 'Horn smoke eye',
    })))
    socket.on('message', raw => {
      const message = JSON.parse(String(raw))
      if (message.type === 'snapshot') { clearTimeout(timer); resolve() }
      if (message.type === 'command') {
        commands.push(message.command.type)
        socket.send(JSON.stringify({ v: 1, type: 'applied', sessionId: message.sessionId, seq: message.seq }))
      }
    })
  })
  return commands
}

assert.equal((await read('/api/control')).show, 'horn-smoke', 'never run against production')
const commands = await display()
try {
  assert.notEqual((await read('/api/status')).state.mode, 'ready')
  await publish(cue(1n))
  const first = await until(async () => (await read('/api/audio')).playbacks.find(playback =>
    playback.track === 'horn' && playback.phase === 'playing' && playback.detail.includes('(held)')))
  let state = await read('/api/status')
  assert.ok(state.runs.some(run => run.reason === 'cue `horn:pushed`' && run.role === 'utility'))
  assert.ok(!state.runs.some(run => run.role === 'show'), 'show must be rejected before reset')
  assert.deepEqual(commands, [])
  await publish(cue(2n, 'horn:held'))
  await wait(100)
  let audio = await read('/api/audio')
  assert.equal(audio.playbacks.filter(playback => playback.phase === 'playing').length, 1, 'heartbeat must not layer another horn')
  assert.equal(audio.playbacks.find(playback => playback.phase === 'playing').id, first.id, 'heartbeat must renew the existing horn')
  await publish(cue(3n, 'horn:show'))
  await wait(100)
  state = await read('/api/status')
  assert.ok(!state.runs.some(run => run.role === 'show'), 'held show request must still be rejected before reset')
  assert.deepEqual(commands, [])
  await publish(cue(4n, 'horn:released'))
  await until(async () => {
    const playback = (await read('/api/audio')).playbacks.find(item => item.id === first.id)
    return playback?.phase === 'stopped' && playback.detail === 'audio stopped by operator'
  })

  await control('reset')
  await until(async () => (await read('/api/status')).state.mode === 'ready')
  const runsBefore = (await read('/api/status')).runs.length
  await publish(cue(5n))
  await publish(cue(6n, 'horn:held'))
  await publish(cue(7n, 'horn:show'))
  await until(async () => {
    const current = await read('/api/status')
    return current.state.mode === 'needs-reset' && current.runs.some(run => run.role === 'show')
  })
  assert.deepEqual(commands, ['eye/wake'])
  state = await read('/api/status')
  assert.ok(state.runs.length >= runsBefore + 3, 'press, held renewal, and show request must remain separate runs')
  const afterAccepted = state.runs.length
  await publish(cue(7n, 'horn:show'))
  await wait(200)
  assert.equal((await read('/api/status')).runs.length, afterAccepted, 'duplicate show delivery must not replay the show')
  await publish(cue(8n, 'horn:held'))
  const acceptedHorn = (await read('/api/audio')).playbacks.find(playback => playback.phase === 'playing')
  assert.ok(acceptedHorn, 'accepted held show must leave the independent horn playing until release')
  await publish(cue(9n, 'horn:released'))
  await until(async () => {
    const playback = (await read('/api/audio')).playbacks.find(item => item.id === acceptedHorn.id)
    return playback?.phase === 'stopped' && playback.detail === 'audio stopped by operator'
  })

  await publish(cue(10n))
  const leased = await until(async () => (await read('/api/audio')).playbacks.find(playback => playback.phase === 'playing'))
  await until(async () => (await read('/api/audio')).playbacks.find(playback => playback.id === leased.id)?.detail === 'audio hold lease expired', 3000)
  console.log('PASS: press starts unconditional resident horn; held renews without layering; a separate held-threshold event requests the state-gated show; release stops; lost release expires; duplicate MQTT delivery does not replay the show')
} finally {
  await control('stop').catch(() => {})
  for (const socket of sockets) socket.terminate()
}
