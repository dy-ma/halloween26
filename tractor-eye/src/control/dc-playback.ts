export type DcPlaybackSettings = {
  direction: 'forward' | 'reverse'
  peakPwmPercent: number
  minimumPwmPercent: number
  rampMs: number
  holdMs: number
  fadeMs: number
  motorDelayMs: number
  track: string
  output: string
  eyeDevice: string
  wakeDelayMs: number
  playAudio: boolean
  playMotor: boolean
  playEye: boolean
  playStepper: boolean
  stepperControl: string
  stepperRpm: number
  stepperDelayMs: number
}

export const buildDcPlayback = (settings: DcPlaybackSettings) => ({
  direction: settings.direction,
  peakPwmPercent: settings.peakPwmPercent,
  minimumPwmPercent: settings.minimumPwmPercent,
  rampMs: settings.rampMs,
  holdMs: settings.holdMs,
  fadeMs: settings.fadeMs,
  motorEnabled: settings.playMotor,
  motorDelayMs: settings.motorDelayMs,
  ...(settings.playAudio ? { audio: {
    track: settings.track, output: settings.output, motorDelayMs: settings.motorDelayMs,
  } } : {}),
  ...(settings.playEye ? { eye: {
    deviceId: settings.eyeDevice, wakeDelayMs: settings.wakeDelayMs,
  } } : {}),
  ...(settings.playStepper ? { stepper: {
    control: settings.stepperControl, rpm: settings.stepperRpm, delayMs: settings.stepperDelayMs,
  } } : {}),
})

export const dcPlaybackDuration = (settings: DcPlaybackSettings, trackDurationMs: number, eyeDurationMs: number, stepperDurationMs = 0) =>
  Math.max(0,
    settings.playAudio ? trackDurationMs : 0,
    settings.playMotor ? settings.motorDelayMs + settings.rampMs + settings.holdMs + settings.fadeMs : 0,
    settings.playEye ? settings.wakeDelayMs + eyeDurationMs : 0,
    settings.playStepper ? settings.stepperDelayMs + stepperDurationMs : 0,
  )
