// Requires sync/shows/audio-smoke.toml and two silent virtual PipeWire sinks.
// Guarded against production, and never selects a physical output.
import assert from 'node:assert/strict'
const base = new URL(process.argv[2] ?? 'http://127.0.0.1:18080')
const read = async path => {
  const response = await fetch(new URL(path, base))
  assert.ok(response.ok, await response.clone().text())
  return response.json()
}
const post = async (path, body) => fetch(new URL(path, base), { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body) })
async function until(check, timeout = 15000) {
  const deadline = Date.now() + timeout
  while (Date.now() < deadline) {
    const result = await check()
    if (result) return result
    await new Promise(resolve => setTimeout(resolve, 100))
  }
  throw new Error('Audio test deadline exceeded')
}
const a = 'pipewire:fx_audio_test_a', b = 'pipewire:fx_audio_test_b'
const play = async (track, output, loop = false) => {
  assert.ok([a, b].includes(output))
  const response = await post('/api/audio', { type: 'play', track, output, volume: 0, loop })
  assert.equal(response.status, 202, await response.clone().text())
  return (await response.json()).playback
}
const stop = async playback => assert.ok((await post('/api/audio', { type: 'stop', playback })).ok)
const phase = async (id, expected) => until(async () => (await read('/api/audio')).playbacks.find(job => job.id === id)?.phase === expected)
const control = async id => assert.ok((await post('/api/control', { control: id, phase: 'press' })).ok)

assert.equal((await read('/api/control')).show, 'audio-smoke', 'never run on production')
const initial = await read('/api/audio')
for (const id of [a, b]) assert.ok(initial.outputs.some(output => output.id === id && output.ready), `${id} must be a ready virtual sink`)
assert.ok(initial.tracks.every(track => track.format === 'WAV' && track.available && track.durationMs > 0))
try {
  const one = await play('tractor_tip', a)
  const two = await play('tractor_source', a)
  const three = await play('tractor_tip', b)
  await control('audio_dag')
  const full = await until(async () => { const state = await read('/api/audio'); return state.playbacks.filter(job => job.phase === 'playing').length === 4 && state })
  assert.equal(full.playbacks.filter(job => job.output === a && job.phase === 'playing').length, 3)
  assert.equal((await post('/api/audio', { type: 'play', track: 'tractor_tip', output: b, volume: 0 })).status, 400)
  assert.equal((await post('/api/audio', { type: 'play', track: '../../arbitrary-file', output: a })).status, 400)
  assert.equal((await post('/api/audio', { type: 'play', track: 'tractor_tip', output: 'unknown-output' })).status, 400)
  await stop(one); await phase(one, 'stopped')
  assert.ok((await read('/api/audio')).playbacks.some(job => job.id === two && job.phase === 'playing'))
  const parent = full.playbacks.find(job => ![one, two, three].includes(job.id) && job.phase === 'playing')
  await stop(parent.id)
  await until(async () => {
    const run = (await read('/api/status')).runs.find(run => run.reason === 'control `audio_dag`')
    return run.nodes.some(node => node.id.endsWith('/parent') && node.phase === 'failed') && run.nodes.some(node => node.id.endsWith('/child') && node.phase === 'skipped')
  })
  assert.ok((await post('/api/audio', { type: 'volume', output: a, percent: 25 })).ok)
  assert.equal((await read('/api/audio')).outputs.find(output => output.id === a).percent, 25)
  await control('stop_all')
  await until(async () => !(await read('/api/audio')).playbacks.some(job => job.phase === 'playing'))
  const natural = await play('tractor_tip', a)
  await phase(natural, 'finished')
  const ambient = await play('tractor_tip', a, true)
  const trackDuration = initial.tracks.find(track => track.id === 'tractor_tip').durationMs
  await new Promise(resolve => setTimeout(resolve, trackDuration + 750))
  assert.equal((await read('/api/audio')).playbacks.find(job => job.id === ambient)?.phase, 'playing', 'ambient loop must survive the first end-of-file')
  await stop(ambient); await phase(ambient, 'stopped')
  await control('audio_dag')
  await until(async () => {
    const run = (await read('/api/status')).runs.find(run => run.reason === 'control `audio_dag`')
    assert.ok(!run.nodes.some(node => node.phase === 'failed'), JSON.stringify(run))
    return run.nodes.some(node => node.id.endsWith('/parent') && node.phase === 'complete') && run.nodes.some(node => node.id.endsWith('/child') && node.phase === 'running')
  })
  const child = (await read('/api/audio')).playbacks.find(job => job.phase === 'playing')
  assert.equal(child.output, b)
  assert.equal(child.track, 'tractor_source')
  await stop(child.id); await phase(child.id, 'stopped')
  console.log(JSON.stringify({ passed: true, checks: ['track catalog with WAV durations', 'different files layered on one output', 'independent second output', 'shared dashboard/DAG playback limit', 'unknown tracks and outputs rejected', 'individual Stop leaves other voices running', 'stopped DAG audio skips dependents', 'per-output volume', 'STOP ALL stops managed audio', 'natural end-of-file completion', 'ambient loop survives end-of-file until Stop', 'DAG child starts after parent audio finishes'] }, null, 2))
} finally {
  await control('stop_all')
}
