import assert from 'node:assert/strict'
import { test } from 'node:test'
import { stepperTiming, stepperSpeedAt } from '../src/control/stepper-timing.ts'

test('stroke duration mirrors firmware integer periods, ramp caps and DIR setup', () => {
  for (const [rpm, durationMs] of [[10, 6375.02], [30, 2375.02], [60, 1375.02], [90, 915.22], [120, 686.42]]) {
    const timing = stepperTiming(1600, rpm, 'quintic')!
    assert.ok(Math.abs(timing.durationMs - durationMs) < 0.000001)
    assert.equal(stepperSpeedAt(0, rpm, timing), 0)
    assert.equal(stepperSpeedAt(timing.durationMs, rpm, timing), 0)
    assert.equal(stepperSpeedAt(timing.setupMs + timing.rampMs, rpm, timing), rpm)
    assert.ok(stepperSpeedAt(timing.setupMs + timing.rampMs / 2, rpm, timing) > 0)
    assert.ok(Math.abs(stepperSpeedAt(timing.setupMs + timing.rampMs / 2, rpm, timing) - rpm / 2) < 0.000001)
  }
  assert.equal(stepperTiming(1600, 60, 'quintic')!.rampMs, 375)
  assert.equal(stepperTiming(1, 60, 'quintic')!.rampMs, 0)
  assert.equal(stepperTiming(1600, 60, null)!.durationMs, 1000.02)
  for (const [steps, rpm] of [[0,60],[1600,9],[1600,121],[1600,30.5]]) {
    assert.equal(stepperTiming(steps, rpm, 'quintic'), null)
  }
})
