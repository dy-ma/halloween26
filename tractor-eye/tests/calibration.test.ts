import assert from 'node:assert/strict'
import test from 'node:test'
import {
  DEFAULT_DISPLAY_CALIBRATION,
  reduceCalibration,
} from '../src/display/calibration.ts'

test('display calibration composes independent edge adjustments', () => {
  const moved = reduceCalibration(DEFAULT_DISPLAY_CALIBRATION, {
    type: 'translate',
    dx: 40,
    dy: -24,
  })
  const rotated = reduceCalibration(moved, { type: 'rotate', degrees: 30 })
  const scaled = reduceCalibration(rotated, { type: 'scale', amount: 0.15 })

  assert.deepEqual(scaled, {
    xPx: 40,
    yPx: -24,
    rotationDeg: 30,
    scaleX: 1.15,
    scaleY: 1.15,
  })
  assert.deepEqual(reduceCalibration(scaled, { type: 'reset' }), DEFAULT_DISPLAY_CALIBRATION)
})

test('display calibration clamps unsafe values', () => {
  const translated = reduceCalibration(DEFAULT_DISPLAY_CALIBRATION, {
    type: 'translate',
    dx: 10_000,
    dy: -10_000,
  })
  const rotated = reduceCalibration(translated, { type: 'rotate', degrees: 999 })
  const scaled = reduceCalibration(rotated, { type: 'scale', amount: -10 })

  assert.deepEqual(scaled, {
    xPx: 600,
    yPx: -960,
    rotationDeg: 180,
    scaleX: 0.5,
    scaleY: 0.5,
  })
})

test('width and height can be calibrated independently', () => {
  const wider = reduceCalibration(DEFAULT_DISPLAY_CALIBRATION, {
    type: 'scale-width',
    amount: 0.12,
  })
  const shorter = reduceCalibration(wider, {
    type: 'scale-height',
    amount: -0.08,
  })

  assert.deepEqual(shorter, {
    xPx: 0,
    yPx: 0,
    rotationDeg: 0,
    scaleX: 1.12,
    scaleY: 0.92,
  })
})
