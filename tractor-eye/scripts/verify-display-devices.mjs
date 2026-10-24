// Exercise only display controls on the isolated orchestration-smoke server.
// --retain leaves the two offline records for a restart/persistence check.
import assert from 'node:assert/strict'
import WebSocket from 'ws'

const base = new URL(process.argv[2] ?? 'http://127.0.0.1:18080')
const retain = process.argv.includes('--retain')
const ids = ['dynamic-test-a', 'dynamic-test-b']
const sockets = []
const read = async path => (await fetch(new URL(path, base))).json()
async function until(check) {
  const deadline = Date.now() + 5000
  while (Date.now() < deadline) {
    const result = await check()
    if (result) return result
    await new Promise(resolve => setTimeout(resolve, 25))
  }
  throw new Error('Display-test deadline exceeded')
}

async function connect(id, role) {
  const url = new URL('/ws', base); url.protocol = 'ws:'
  const socket = new WebSocket(url, { origin: base.origin, headers: { 'user-agent': 'Chrome/123 Dynamic-display-test' } })
  const commands = []
  sockets.push(socket)
  await new Promise((resolve, reject) => {
    const deadline = setTimeout(() => reject(new Error('No snapshot')), 5000)
    socket.once('error', reject)
    socket.on('open', () => socket.send(JSON.stringify({ v: 1, type: 'hello', screenId: role, clientId: id })))
    socket.on('message', raw => {
      const event = JSON.parse(String(raw))
      if (event.type === 'snapshot') { clearTimeout(deadline); resolve() }
      if (event.type === 'command') {
        assert.equal(event.seq, commands.length + 1, 'connection sequence must stay contiguous')
        commands.push(event)
        socket.send(JSON.stringify({ v: 1, type: 'applied', sessionId: event.sessionId, seq: event.seq }))
      }
    })
  })
  return { socket, commands }
}

async function control(id) {
  const response = await fetch(new URL('/api/control', base), {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ control: id, phase: 'press' }),
  })
  assert.equal(response.ok, true, await response.text())
  await until(async () => {
    const state = await read('/api/status')
    const run = state.runs.find(run => run.reason === `control \`${id}\``)
    if (!run) return false
    assert.ok(!run.nodes.some(node => node.phase === 'failed'), JSON.stringify(run))
    return run.nodes.every(node => node.phase === 'complete')
  })
}

assert.equal((await read('/api/control')).show, 'orchestration-smoke', 'never run this driver on production')
try {
  const { screenId: role } = await read('/config.json')
  const a = await connect(ids[0], role)
  const mirror = await connect(ids[0], role)
  const b = await connect(ids[1], role)
  const devices = await read('/api/displays')
  const first = devices.find(device => device.id === ids[0])
  const second = devices.find(device => device.id === ids[1])
  assert.equal(first.connections.length, 2)
  assert.equal(second.connections.length, 1)
  assert.equal(first.userAgent, second.userAgent, 'identical UA must not merge device identities')
  const firstToken = first.connections[0].connectionId
  const secondToken = second.connections[0].connectionId
  assert.equal((await fetch(new URL(`/api/displays/${ids[0]}`, base), { method: 'DELETE' })).status, 400)
  await control(`client/${firstToken}/wake`)
  const [target, untouched] = a.commands.length ? [a, mirror] : [mirror, a]
  assert.equal(target.commands.length, 1)
  assert.equal(untouched.commands.length, 0)
  assert.equal(b.commands.length, 0)
  await control(`client/${secondToken}/wake`)
  assert.equal(b.commands.length, 1)
  assert.equal(untouched.commands.length, 0)
  await control(`display/${role}/reset`)
  await until(() => target.commands.length === 2 && untouched.commands.length === 1 && b.commands.length === 2)
  assert.deepEqual(target.commands.map(event => event.command.type), ['eye/wake', 'system/reset'])
  assert.deepEqual(untouched.commands.map(event => event.command.type), ['system/reset'])
  assert.deepEqual(b.commands.map(event => event.command.type), ['eye/wake', 'system/reset'])
} finally {
  for (const socket of sockets) socket.terminate()
  await until(async () => (await read('/api/displays')).filter(device => ids.includes(device.id)).every(device => device.connections.length === 0))
  if (!retain) {
    for (const id of ids) {
      const response = await fetch(new URL(`/api/displays/${id}`, base), { method: 'DELETE' })
      assert.ok(response.ok)
    }
  }
}
console.log(JSON.stringify({ passed: true, checks: ['automatic device discovery', 'saved ID rather than user-agent identity', 'two tabs controlled independently', 'group reset after divergent private sequences', 'offline records retained', retain ? 'records left for restart check' : 'test records forgotten'], ids }, null, 2))
