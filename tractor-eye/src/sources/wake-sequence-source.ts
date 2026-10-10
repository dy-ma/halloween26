import type { AnimationCommand } from '../commands/animation-command'
import type { AnimationCommandSource } from '../commands/command-bus'

// Start each glance 50ms into a 220ms blink: it moves behind the closing lids
// and finishes as they reopen. Gaze commands do not restart the lid animation.
const wakeCues: ReadonlyArray<readonly [number, AnimationCommand]> = [
  [180, { type: 'eye/open', durationMs: 320 }],
  [500, { type: 'eye/mode', mode: 'alert' }],
  [550, { type: 'eye/blink', durationMs: 220 }],
  [600, { type: 'eye/look', x: -0.65, y: -0.12 }],
  [850, { type: 'eye/blink', durationMs: 220 }],
  [900, { type: 'eye/look', x: 0.15, y: -0.2 }],
  [1150, { type: 'eye/blink', durationMs: 220 }],
  [1200, { type: 'eye/look', x: -0.25, y: -0.12 }],
  // Continue from the last glance once the final blink reopens (1370ms).
  // Keep x unchanged: recentering also turns the iris and causes a visible snap.
  [1400, { type: 'eye/mode', mode: 'tipping' }],
  [1400, { type: 'eye/look', x: -0.25, y: -0.65, durationMs: 2400 }],
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
