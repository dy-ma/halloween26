import assert from 'node:assert/strict'
import { test } from 'node:test'
import { buildDcPlayback, dcPlaybackDuration, type DcPlaybackSettings } from '../src/control/dc-playback.ts'

const settings: DcPlaybackSettings = {
  direction: 'forward', peakPwmPercent: 60, minimumPwmPercent: 20,
  rampMs: 300, holdMs: 700, fadeMs: 3500, motorDelayMs: 4000,
  track: 'tractor_tip', output: 'speaker', eyeDevice: 'pi-eye', wakeDelayMs: 750,
  playAudio: true, playMotor: true, playEye: true,
  playStepper: false, stepperControl: 'stroke', stepperRpm: 60, stepperDelayMs: 2000,
}

test('each checkbox independently includes only its component without changing the curve or delays', () => {
  for (let selection = 0; selection < 16; selection++) {
    const draft = { ...settings,
      playAudio: Boolean(selection & 1), playMotor: Boolean(selection & 2), playEye: Boolean(selection & 4),
      playStepper: Boolean(selection & 8),
    }
    const profile = buildDcPlayback(draft)
    assert.equal('audio' in profile, draft.playAudio)
    assert.equal('eye' in profile, draft.playEye)
    assert.equal(profile.motorEnabled, draft.playMotor)
    assert.equal('stepper' in profile, draft.playStepper)
    if (profile.stepper) assert.deepEqual(profile.stepper, {control:'stroke', rpm:60, delayMs:2000})
    assert.equal(profile.motorDelayMs, 4000)
    assert.equal(profile.peakPwmPercent, 60)
    assert.equal(profile.minimumPwmPercent, 20)
    assert.equal(profile.fadeMs, 3500)
    if (profile.eye) assert.equal(profile.eye.wakeDelayMs, 750)
    assert.equal(dcPlaybackDuration(draft, 9540, 6400, 1375.02), Math.max(
      draft.playAudio ? 9540 : 0, draft.playMotor ? 8500 : 0, draft.playEye ? 7150 : 0,
      draft.playStepper ? 3375.02 : 0,
    ))
  }
})
