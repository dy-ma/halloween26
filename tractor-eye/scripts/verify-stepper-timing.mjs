// Only the isolated dc-pwm-smoke show; no physical motor outputs.
import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'

const base = process.argv[2] ?? 'http://127.0.0.1:18081'
const logFile = process.argv[3] ?? '/tmp/fx-run.log'
const read = async path => (await fetch(new URL(path, base))).json()
const manifest = await read('/api/control')
assert.equal(manifest.show, 'dc-pwm-smoke', 'never run on production')
assert.ok((await read('/api/boards')).boards.every(board => board.transport === 'simulated'))
const stroke = manifest.controls.find(control => control.id === 'stepper_stroke')
assert.equal(stroke.strokeSteps, 1600)
assert.equal(stroke.strokeProfile, 'quintic')
const post = body => fetch(new URL('/api/control', base), {
  method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(body),
})
const wait = ms => new Promise(resolve => setTimeout(resolve, ms))
const run = stepper => post({control:'dc_b',phase:'press',dcProfile:{
  motorEnabled:false, direction:'forward', peakPwmPercent:60, minimumPwmPercent:20,
  rampMs:300, holdMs:700, fadeMs:3500, stepper,
}})
for (const rpm of [10,30,60,90,120]) {
  assert.ok((await run({control:'stepper_stroke',rpm,delayMs:100})).ok)
  let latest
  for (let i = 0; i < 100; i++) {
    latest = (await read('/api/status')).runs[0]
    if (latest.nodes[0].phase === 'complete') break
    await wait(20)
  }
  assert.equal(latest.nodes.length, 1, 'no DC, audio or eye nodes when unchecked')
  assert.equal(latest.nodes[0].phase, 'complete')
  assert.ok(latest.nodes[0].id.endsWith('/stepper'))
  assert.ok((await readFile(logFile,'utf8')).includes(`delivered cue \`step:rev:1600:${rpm}\` to \`00000000000C\``))
}
const before = (await read('/api/status')).runs.length
for (const stepper of [
  {control:'stepper_stroke',rpm:9,delayMs:100},
  {control:'stepper_stroke',rpm:121,delayMs:100},
  {control:'stepper_stroke',rpm:60,delayMs:10001},
  {control:'dc_a_forward',rpm:60,delayMs:100},
  {control:'missing',rpm:60,delayMs:100},
  {control:'stepper_stroke',rpm:60,delayMs:100,cue:'step:fwd:99999:120'},
]) assert.ok(!(await run(stepper)).ok)
assert.equal((await read('/api/status')).runs.length,before)
assert.ok((await run({control:'stepper_stroke',rpm:77,delayMs:700})).ok)
assert.ok((await post({control:'stop_all',phase:'press'})).ok)
await wait(850)
const stopped = (await read('/api/status')).runs.find(run => run.reason === 'DC profile `dc_b`')
assert.equal(stopped.nodes.length,1)
assert.equal(stopped.nodes[0].phase,'skipped')
assert.ok(!(await readFile(logFile,'utf8')).includes('delivered cue `step:rev:1600:77`'))
console.log('PASS: stepper-only dispatch, 10–120 RPM, exact configured direction/pulse count/target, delayed start, Stop cancellation and rejected invalid overrides; simulated transport only')
