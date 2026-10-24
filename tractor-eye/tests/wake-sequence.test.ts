import assert from 'node:assert/strict'
import { test } from 'node:test'
import { AnimationCommandBus } from '../src/commands/command-bus.ts'
import { createInitialEyeState, reduceEyeCommand } from '../src/features/eye/eye-state.ts'
import { wakeSequenceSource } from '../src/sources/wake-sequence-source.ts'
import { wakeMilestones, wakeTiming } from '../src/sources/wake-timing.ts'

test('dashboard milestones use the actual sequence timing and shift with wake', () => {
  assert.deepEqual(wakeMilestones(750).map(marker => [marker.label, marker.timeMs]), [
    ['Wake', 750], ['Opens', 930], ['Tip look', 4750], ['Look settled', 7150],
  ])
  assert.equal(wakeTiming.openDelayMs + wakeTiming.openDurationMs, wakeTiming.alertDelayMs)
  assert.equal(wakeMilestones(2000)[2].timeMs, 6000)
})

function setup() {
  const bus = new AnimationCommandBus()
  let state = createInitialEyeState()
  bus.subscribe((command) => { state = reduceEyeCommand(state, command) })
  const stop = wakeSequenceSource.start(bus)
  return { bus, stop, state: () => state }
}

test('blinks during the first glances, moves without blinking, then drifts upward', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  assert.equal(eye.state().isOpen, false)
  eye.bus.publish({ type: 'eye/wake' })
  assert.equal(eye.state().instantPose, true)
  assert.equal(eye.state().transitionDurationMs, 0)
  t.mock.timers.tick(180)
  assert.equal(eye.state().isOpen, true)
  t.mock.timers.tick(370)
  assert.equal(eye.state().blinkSequence, 1)
  assert.equal(eye.state().transitionDurationMs, 220)
  assert.equal(eye.state().mode, 'alert')
  assert.deepEqual(eye.state().gaze, { x: 0, y: 0 })
  // Gaze keeps moving rapidly while four blinks are spread across the phase.
  t.mock.timers.tick(50)
  assert.deepEqual(eye.state().gaze, { x: -0.65, y: -0.12 })
  assert.equal(eye.state().blinkSequence, 1)
  t.mock.timers.tick(250)
  assert.equal(eye.state().blinkSequence, 1)
  t.mock.timers.tick(50)
  assert.deepEqual(eye.state().gaze, { x: 0.15, y: -0.2 })
  assert.equal(eye.state().blinkSequence, 1)
  t.mock.timers.tick(50)
  assert.equal(eye.state().blinkSequence, 2)
  t.mock.timers.tick(250)
  assert.deepEqual(eye.state().gaze, { x: -0.25, y: -0.12 })
  assert.equal(eye.state().blinkSequence, 2)
  t.mock.timers.tick(150)
  assert.equal(eye.state().blinkSequence, 3)
  t.mock.timers.tick(400)
  assert.equal(eye.state().blinkSequence, 4)
  t.mock.timers.tick(50)
  assert.deepEqual(eye.state().gaze, { x: -0.5, y: -0.08 })
  // The remaining rapid glances do not add more blinks.
  t.mock.timers.tick(2100)
  assert.equal(eye.state().blinkSequence, 4)
  assert.deepEqual(eye.state().gaze, { x: -0.25, y: -0.12 })
  assert.equal(eye.state().mode, 'alert')
  t.mock.timers.tick(99)
  assert.deepEqual(eye.state().gaze, { x: -0.25, y: -0.12 })
  assert.equal(eye.state().mode, 'alert')
  t.mock.timers.tick(1)
  assert.equal(eye.state().mode, 'tipping')
  assert.deepEqual(eye.state().gaze, { x: -0.25, y: -0.65 })
  assert.equal(eye.state().gazeDurationMs, 2400)
  // Changing gaze timing must not change blink timing.
  assert.equal(eye.state().transitionDurationMs, 220)
  assert.equal(eye.state().isOpen, true)
})

test('close and reset cancel pending wake cues', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  for (const type of ['eye/close', 'system/reset'] as const) {
    const eye = setup()
    eye.bus.publish({ type: 'eye/wake' })
    t.mock.timers.tick(600)
    eye.bus.publish({ type })
    const resting = eye.state()
    t.mock.timers.tick(6000)
    assert.deepEqual(eye.state(), resting)
    assert.equal(eye.state().isOpen, false)
    eye.stop()
  }
})

test('repeated Wake replaces the previous sequence', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(600)
  eye.bus.publish({ type: 'eye/wake' })
  assert.equal(eye.state().isOpen, false)
  t.mock.timers.tick(4000)
  assert.equal(eye.state().blinkSequence, 4)
  assert.equal(eye.state().gaze.y, -0.65)
})

test('disposing the source clears timers and subscription', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  eye.bus.publish({ type: 'eye/wake' })
  eye.stop()
  t.mock.timers.tick(6000)
  assert.equal(eye.state().isOpen, false)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(6000)
  assert.equal(eye.state().isOpen, false)
})

test('manual gaze cancels the remaining startled glances', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(900)
  eye.bus.publish({ type: 'eye/look', x: -0.4, y: 0.2 })
  t.mock.timers.tick(6000)
  assert.deepEqual(eye.state().gaze, { x: -0.4, y: 0.2 })
})

test('manual nudge after the drift restores responsive gaze timing', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(4000)
  assert.equal(eye.state().gazeDurationMs, 2400)
  eye.bus.publish({ type: 'eye/nudge', x: -0.2, y: 0 })
  assert.equal(eye.state().gazeDurationMs, 240)
  assert.equal(eye.state().gaze.x, -0.45)
})

test('rapid movement flows directly into drift without shake or recenter cues', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  const looks: Array<{ x: number; y: number }> = []
  eye.bus.subscribe((command) => {
    if (command.type === 'eye/look') looks.push({ x: command.x, y: command.y })
  })
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(6000)
  assert.deepEqual(looks, [
    { x: -0.65, y: -0.12 },
    { x: 0.15, y: -0.2 },
    { x: -0.25, y: -0.12 },
    { x: 0.45, y: -0.18 },
    { x: -0.5, y: -0.08 },
    { x: 0.25, y: -0.22 },
    { x: -0.6, y: -0.14 },
    { x: 0.1, y: -0.18 },
    { x: -0.25, y: -0.12 },
    { x: 0.5, y: -0.1 },
    { x: -0.45, y: -0.2 },
    { x: -0.25, y: -0.12 },
    { x: -0.25, y: -0.65 },
  ])
})
