// Isolated motor transport + real WebSocket protocol. Never target production.
import assert from 'node:assert/strict'
import WebSocket from 'ws'

const base = new URL(process.argv[2] ?? 'http://127.0.0.1:18081')
const read = async path => {
  const response = await fetch(new URL(path, base))
  assert.ok(response.ok, await response.clone().text())
  return response.json()
}
const post = body => fetch(new URL('/api/control', base), {
  method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body),
})
const wait = ms => new Promise(resolve => setTimeout(resolve, ms))
async function until(predicate) {
  for (let attempt = 0; attempt < 100; attempt++) {
    if (await predicate()) return
    await wait(25)
  }
  throw new Error('Verification deadline exceeded')
}

assert.equal((await read('/api/control')).show, 'dc-pwm-smoke', 'never run on production')
assert.ok((await read('/api/boards')).boards.every(board => board.transport === 'simulated'))
const sockets = []
async function display(clientId) {
  const url = new URL('/ws', base); url.protocol = 'ws:'
  const socket = new WebSocket(url, { origin: base.origin })
  sockets.push(socket)
  const commands = []
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('WebSocket snapshot deadline')), 3000)
    socket.once('close', (code, reason) => {
      clearTimeout(timer)
      reject(new Error(`WebSocket closed: ${code} ${reason}`))
    })
    socket.once('error', reject)
    socket.on('open', () => socket.send(JSON.stringify({
      v: 1, type: 'hello', screenId: 'test-eye', clientId, clientName: clientId,
    })))
    socket.on('message', raw => {
      const message = JSON.parse(String(raw))
      if (message.type === 'snapshot') { clearTimeout(timer); resolve() }
      if (message.type === 'command') {
        commands.push({ type: message.command.type, receivedAt: Date.now() })
        socket.send(JSON.stringify({ v: 1, type: 'applied', sessionId: message.sessionId, seq: message.seq }))
      }
    })
  })
  return { socket, commands }
}
const profile = {
  direction: 'forward', peakPwmPercent: 60, minimumPwmPercent: 20,
  rampMs: 300, holdMs: 700, fadeMs: 3500,
  eye: { deviceId: 'smoke-selected-eye', wakeDelayMs: 250 },
}
const run = dcProfile => post({ control: 'dc_b', phase: 'press', dcProfile })

try {
  const first = await display('smoke-selected-eye')
  const second = await display('smoke-selected-eye')
  const other = await display('smoke-other-eye')
  const startedAt = Date.now()
  assert.ok((await run(profile)).ok)
  await until(() => first.commands.length === 1 && second.commands.length === 1)
  assert.equal(first.commands[0].type, 'eye/wake')
  assert.ok(first.commands[0].receivedAt - startedAt >= 220, 'wake must honor the configured delay')
  assert.deepEqual(other.commands, [], 'private wake must not reach other displays')
  await until(async () => (await read('/api/status')).runs[0].nodes.every(node => node.phase === 'complete'))

  // Cancellation must prevent a delayed Wake, not merely update the UI.
  assert.ok((await run({ ...profile, eye: { ...profile.eye, wakeDelayMs: 700 } })).ok)
  assert.ok((await post({ control: 'stop_all', phase: 'press' })).ok)
  await wait(850)
  assert.equal(first.commands.length, 1)
  assert.equal(second.commands.length, 1)
  const cancelled = (await read('/api/status')).runs.find(run => run.reason === 'DC profile `dc_b`')
  assert.ok(cancelled.nodes.filter(node => node.id.includes('/eye/')).every(node => node.phase === 'skipped'))

  first.socket.close(); second.socket.close()
  await until(async () => !(await read('/api/displays')).find(device => device.id === 'smoke-selected-eye')?.connections.length)
  const count = (await read('/api/status')).runs.length
  assert.ok(!(await run(profile)).ok, 'offline device must reject the whole run')
  assert.equal((await read('/api/status')).runs.length, count, 'no motor run may be added on rejected eye selection')
  const reconnected = await display('smoke-selected-eye')
  assert.ok((await run(profile)).ok)
  await until(() => reconnected.commands.length === 1)
  assert.equal(reconnected.commands[0].type, 'eye/wake')
  assert.deepEqual(other.commands, [])
  // Motor unchecked must omit Cue nodes entirely, not send a zero-speed motor cue.
  assert.ok((await run({ ...profile, motorEnabled: false, motorDelayMs: 4000 })).ok)
  await until(() => reconnected.commands.length === 2)
  const eyeOnly = (await read('/api/status')).runs[0]
  assert.equal(eyeOnly.nodes.length, 1)
  assert.ok(eyeOnly.nodes[0].id.includes('/eye/'))
  console.log('PASS: delayed private Wake, saved identity across reconnects, independent displays, ACKs, Stop cancellation, offline atomic rejection, Eye-only with no motor action; simulated motors only')
} finally {
  for (const socket of sockets) socket.terminate()
}
