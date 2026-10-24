// Run only against sync/shows/dc-pwm-smoke.toml: no physical transport.
import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'

const base = new URL(process.argv[2] ?? 'http://127.0.0.1:18081')
const logFile = process.argv[3] ?? '/tmp/fx-dc-pwm-smoke.log'
const read = async path => {
  const response = await fetch(new URL(path, base))
  assert.ok(response.ok, await response.clone().text())
  return response.json()
}
const post = body => fetch(new URL('/api/control', base), {
  method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body),
})
assert.equal((await read('/api/control')).show, 'dc-pwm-smoke', 'never run on production')
assert.ok((await read('/api/boards')).boards.every(board => board.transport === 'simulated'))
const manifest = await read('/api/control')
const expected = []
for (const motor of ['a', 'b']) {
  for (const [direction, protocol] of [['forward', 'fwd'], ['reverse', 'rev']]) {
    const control = `dc_${motor}_${direction}`
    assert.equal(manifest.controls.find(item => item.id === control).pwm, 255)
    for (const pwm of [1, 64, 128, 191, 255]) {
      const response = await post({ control, phase: 'press', pwm })
      assert.ok(response.ok, await response.clone().text())
      expected.push(`delivered cue 'dc:jog:${protocol}:${pwm}' to '00000000000${motor.toUpperCase()}'`.replaceAll("'", '`'))
    }
    assert.ok((await post({ control, phase: 'release' })).ok)
  }
}
for (const pwm of [0, -1, 256, 1.5, '128']) {
  assert.ok(!(await post({ control: 'dc_a_forward', phase: 'press', pwm })).ok)
}
for (const body of [
  { control: 'dc_a_forward', phase: 'release', pwm: 128 },
  { control: 'timed', phase: 'press', pwm: 128 },
  { control: 'stop_all', phase: 'press', pwm: 128 },
  { control: 'display/test-eye/wake', phase: 'press', pwm: 128 },
  { control: 'dc_a_forward', phase: 'press', pwm: 128, cue: 'dc:fwd:255:99999' },
]) assert.ok(!(await post(body)).ok)
assert.ok((await post({ control: 'dc_a_forward', phase: 'press' })).ok, 'legacy payload still works')
assert.ok((await post({ control: 'dc_a_forward', phase: 'release' })).ok)
assert.ok((await post({ control: 'timed', phase: 'press' })).ok)
assert.ok((await post({
  control: 'dc_a', phase: 'press', dcProfile: {
    direction: 'forward', peakPwmPercent: 85, minimumPwmPercent: 20,
    rampMs: 300, holdMs: 700, fadeMs: 2200,
  },
})).ok)
for (const dcProfile of [
  { direction: 'forward', peakPwmPercent: 0, minimumPwmPercent: 0, rampMs: 300, holdMs: 700, fadeMs: 2200 },
  { direction: 'reverse', peakPwmPercent: 80, minimumPwmPercent: 81, rampMs: 300, holdMs: 700, fadeMs: 2200 },
  { direction: 'forward', peakPwmPercent: 80, minimumPwmPercent: 20, rampMs: 10, holdMs: 700, fadeMs: 2200 },
]) assert.ok(!(await post({ control: 'dc_a', phase: 'press', dcProfile })).ok)
assert.ok(!(await post({
  control: 'dc_a_forward', phase: 'press', dcProfile: {
    direction: 'forward', peakPwmPercent: 85, minimumPwmPercent: 20,
    rampMs: 300, holdMs: 700, fadeMs: 2200,
  },
})).ok, 'only configured DC sink identifiers are profile targets')

for (let attempt = 0; ; attempt++) {
  const log = await readFile(logFile, 'utf8')
  const all = [...expected,
    "delivered cue `dc:stop` to `00000000000A`",
    "delivered cue `dc:stop` to `00000000000B`",
    "delivered cue `dc:fwd:70:500` to `00000000000A`",
    "delivered cue `dc:c:f:217:51:300:700:2200` to `00000000000A`",
  ]
  if (all.every(line => log.includes(line))) break
  assert.ok(attempt < 30, 'expected simulated deliveries missing from runtime log')
  await new Promise(resolve => setTimeout(resolve, 100))
}
console.log('PASS: A/B directions, PWM range, smoothed profile, defaults, stops, fixed cues, and unsafe or unrelated overrides rejected; simulated transport only')
