// Shared by the actual wake sequence and the dashboard's read-only milestones.
// Moving the wake marker shifts the sequence; it does not retime its sections.
export const wakeTiming = {
  openDelayMs: 180,
  openDurationMs: 320,
  alertDelayMs: 500,
  tipDelayMs: 4_000,
  tipDurationMs: 2_400,
} as const

export const wakeMilestones = (wakeDelayMs: number) => [
  { label: 'Wake', timeMs: wakeDelayMs, kind: 'wake' },
  { label: 'Opens', timeMs: wakeDelayMs + wakeTiming.openDelayMs, kind: 'open' },
  { label: 'Tip look', timeMs: wakeDelayMs + wakeTiming.tipDelayMs, kind: 'tip' },
  { label: 'Look settled', timeMs: wakeDelayMs + wakeTiming.tipDelayMs + wakeTiming.tipDurationMs, kind: 'settled' },
]
