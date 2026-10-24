export type StepperStroke = {
  id: string
  label: string
  rpm: number
  steps: number
  profile: 'quintic' | null
}

// Mirrors StepperMotion.h's finite MQTT/RMT planner. This is a preview, not
// position feedback. The driver must still be set to 1600 pulses/revolution.
export function stepperTiming(steps: number, rpm: number, profile: StepperStroke['profile']) {
  if (!Number.isInteger(steps) || steps < 1 || !Number.isInteger(rpm) || rpm < 10 || rpm > 120) return null
  const periodUs = Math.floor(60_000_000 / (1600 * rpm))
  const rampSteps = profile === 'quintic'
    ? Math.min(300, Math.floor(steps / 2), Math.max(1, Math.floor(1_000_000 / periodUs * 0.375 / 2)))
    : 0
  const setupMs = 0.020
  const rampMs = 2 * rampSteps * periodUs / 1000
  const cruiseMs = (steps - 2 * rampSteps) * periodUs / 1000
  return { durationMs: setupMs + 2 * rampMs + cruiseMs, rampMs, cruiseMs, setupMs }
}

export function stepperSpeedAt(elapsedMs: number, rpm: number, timing: NonNullable<ReturnType<typeof stepperTiming>>) {
  const t = elapsedMs - timing.setupMs
  if (t < 0 || elapsedMs >= timing.durationMs) return 0
  const smooth = (u: number) => u * u * u * (u * (u * 6 - 15) + 10)
  if (timing.rampMs > 0 && t < timing.rampMs) return rpm * smooth(t / timing.rampMs)
  if (timing.rampMs > 0 && t > timing.rampMs + timing.cruiseMs) {
    return rpm * smooth((timing.durationMs - elapsedMs) / timing.rampMs)
  }
  return rpm
}
