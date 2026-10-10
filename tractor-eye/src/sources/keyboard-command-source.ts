import type { AnimationCommand } from '../commands/animation-command'
import type { AnimationCommandSource } from '../commands/command-bus'

const LOOK_STEP = 0.28

const commandByCode: Readonly<Record<string, AnimationCommand>> = {
  KeyW: { type: 'eye/wake' },
  KeyO: { type: 'eye/open' },
  KeyC: { type: 'eye/close' },
  KeyB: { type: 'eye/blink' },
  Space: { type: 'eye/blink' },
  KeyI: { type: 'eye/mode', mode: 'idle' },
  KeyA: { type: 'eye/mode', mode: 'alert' },
  KeyS: { type: 'eye/mode', mode: 'sleeping' },
  KeyR: { type: 'system/reset' },
  Home: { type: 'eye/look', x: 0, y: 0 },
  ArrowLeft: { type: 'eye/nudge', x: -LOOK_STEP, y: 0 },
  ArrowRight: { type: 'eye/nudge', x: LOOK_STEP, y: 0 },
  ArrowUp: { type: 'eye/nudge', x: 0, y: -LOOK_STEP },
  ArrowDown: { type: 'eye/nudge', x: 0, y: LOOK_STEP },
}

export const keyboardCommandSource: AnimationCommandSource = {
  start(commandBus) {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.repeat) return
      if (event.target instanceof HTMLElement) {
        if (event.target.isContentEditable || event.target.closest('input, textarea, select')) return
        // Do not intercept native keyboard activation if controls are added.
        if (event.code === 'Space' && event.target.closest('button')) return
      }

      const command = commandByCode[event.code]
      if (!command) return

      event.preventDefault()
      commandBus.publish(command)
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  },
}
