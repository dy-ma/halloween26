import assert from 'node:assert/strict'
import { test } from 'node:test'
import { AnimationCommandBus } from '../src/commands/command-bus.ts'
import { createInitialEyeState, reduceEyeCommand } from '../src/features/eye/eye-state.ts'
import { wakeSequenceSource } from '../src/sources/wake-sequence-source.ts'

function setup() {
  const bus = new AnimationCommandBus()
  let state = createInitialEyeState()
  bus.subscribe((command) => { state = reduceEyeCommand(state, command) })
  const stop = wakeSequenceSource.start(bus)
  return { bus, stop, state: () => state }
}

test('moves the gaze during each blink, then settles looking upward', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  assert.equal(eye.state().isOpen, false)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(180)
  assert.equal(eye.state().isOpen, true)
  t.mock.timers.tick(370)
  assert.equal(eye.state().blinkSequence, 1)
  assert.equal(eye.state().transitionDurationMs, 220)
  assert.equal(eye.state().mode, 'alert')
  assert.deepEqual(eye.state().gaze, { x: 0, y: 0 })
  // Each gaze starts 50ms into the blink, before its 220ms duration ends.
  t.mock.timers.tick(50)
  assert.deepEqual(eye.state().gaze, { x: -0.65, y: -0.12 })
  assert.equal(eye.state().blinkSequence, 1)
  t.mock.timers.tick(250)
  assert.equal(eye.state().blinkSequence, 2)
  t.mock.timers.tick(50)
  assert.deepEqual(eye.state().gaze, { x: 0.15, y: -0.2 })
  assert.equal(eye.state().blinkSequence, 2)
  t.mock.timers.tick(250)
  assert.equal(eye.state().blinkSequence, 3)
  t.mock.timers.tick(50)
  assert.deepEqual(eye.state().gaze, { x: -0.25, y: -0.12 })
  assert.equal(eye.state().blinkSequence, 3)
  t.mock.timers.tick(199)
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
    t.mock.timers.tick(3000)
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
  t.mock.timers.tick(1400)
  assert.equal(eye.state().blinkSequence, 3)
  assert.equal(eye.state().gaze.y, -0.65)
})

test('disposing the source clears timers and subscription', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  eye.bus.publish({ type: 'eye/wake' })
  eye.stop()
  t.mock.timers.tick(3000)
  assert.equal(eye.state().isOpen, false)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(3000)
  assert.equal(eye.state().isOpen, false)
})

test('manual gaze cancels the remaining startled glances', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(900)
  eye.bus.publish({ type: 'eye/look', x: -0.4, y: 0.2 })
  t.mock.timers.tick(3000)
  assert.deepEqual(eye.state().gaze, { x: -0.4, y: 0.2 })
})

test('manual nudge after the drift restores responsive gaze timing', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] })
  const eye = setup()
  t.after(eye.stop)
  eye.bus.publish({ type: 'eye/wake' })
  t.mock.timers.tick(1400)
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
  t.mock.timers.tick(5000)
  assert.deepEqual(looks, [
    { x: -0.65, y: -0.12 },
    { x: 0.15, y: -0.2 },
    { x: -0.25, y: -0.12 },
    { x: -0.25, y: -0.65 },
  ])
})
