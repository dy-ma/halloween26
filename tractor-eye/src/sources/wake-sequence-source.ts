import type { AnimationCommand } from '../commands/animation-command'
import type { AnimationCommandSource } from '../commands/command-bus'
import { wakeTiming } from './wake-timing.ts'

// Spread four 220ms blinks evenly across the opening movement phase. Gaze keeps
// its faster cadence underneath, then continues without blinking.
const wakeCues: ReadonlyArray<readonly [number, AnimationCommand]> = [
  [wakeTiming.openDelayMs, { type: 'eye/open', durationMs: wakeTiming.openDurationMs }],
  [wakeTiming.alertDelayMs, { type: 'eye/mode', mode: 'alert' }],
  [550, { type: 'eye/blink', durationMs: 220 }],
  [600, { type: 'eye/look', x: -0.65, y: -0.12 }],
  [900, { type: 'eye/look', x: 0.15, y: -0.2 }],
  [950, { type: 'eye/blink', durationMs: 220 }],
  [1200, { type: 'eye/look', x: -0.25, y: -0.12 }],
  [1350, { type: 'eye/blink', durationMs: 220 }],
  [1500, { type: 'eye/look', x: 0.45, y: -0.18 }],
  [1750, { type: 'eye/blink', durationMs: 220 }],
  [1800, { type: 'eye/look', x: -0.5, y: -0.08 }],
  [2100, { type: 'eye/look', x: 0.25, y: -0.22 }],
  [2400, { type: 'eye/look', x: -0.6, y: -0.14 }],
  [2700, { type: 'eye/look', x: 0.1, y: -0.18 }],
  [3000, { type: 'eye/look', x: -0.25, y: -0.12 }],
  [3300, { type: 'eye/look', x: 0.5, y: -0.1 }],
  [3600, { type: 'eye/look', x: -0.45, y: -0.2 }],
  [3900, { type: 'eye/look', x: -0.25, y: -0.12 }],
  // At a 750ms wake offset, this begins 4.75s into the audio at the moo.
  // Continue from the final unaccompanied glance after the blink phase ends.
  // Keep x unchanged: recentering also turns the iris and causes a visible snap.
  [wakeTiming.tipDelayMs, { type: 'eye/mode', mode: 'tipping' }],
  [wakeTiming.tipDelayMs, { type: 'eye/look', x: -0.25, y: -0.65, durationMs: wakeTiming.tipDurationMs }],
]

export const wakeSequenceSource: AnimationCommandSource = {
  start(commandBus) {
    let timers: ReturnType<typeof setTimeout>[] = []
    let publishingCue = false

    const cancel = () => {
      timers.forEach(clearTimeout)
      timers = []
    }

    const unsubscribe = commandBus.subscribe((command) => {
      if (publishingCue) return
      // Any new external command takes ownership, including another Wake.
      cancel()
      if (command.type !== 'eye/wake') return

      timers = wakeCues.map(([delay, cue]) => setTimeout(() => {
        publishingCue = true
        try {
          commandBus.publish(cue)
        } finally {
          publishingCue = false
        }
      }, delay))
    })

    return () => {
      cancel()
      unsubscribe()
    }
  },
}
