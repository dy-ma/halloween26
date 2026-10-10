import type { AnimationCommand } from '../../commands/animation-command'

export type EyeMode = 'idle' | 'alert' | 'tipping' | 'sleeping'

export interface EyeState {
  readonly isOpen: boolean
  readonly mode: EyeMode
  readonly gaze: Readonly<{ x: number; y: number }>
  readonly gazeDurationMs: number
  readonly blinkSequence: number
  readonly transitionDurationMs: number
}

export function createInitialEyeState(): EyeState {
  return {
    isOpen: false,
    mode: 'sleeping',
    gaze: { x: 0, y: 0 },
    gazeDurationMs: 240,
    blinkSequence: 0,
    transitionDurationMs: 1_200,
  }
}

function clampGaze(value: number): number {
  return Math.max(-1, Math.min(1, value))
}

export function reduceEyeCommand(
  state: EyeState,
  command: AnimationCommand,
): EyeState {
  switch (command.type) {
    case 'eye/wake':
      return { ...createInitialEyeState(), transitionDurationMs: 120 }

    case 'eye/open':
      return {
        ...state,
        isOpen: true,
        mode: state.mode === 'sleeping' ? 'idle' : state.mode,
        transitionDurationMs: command.durationMs ?? 1_200,
      }

    case 'eye/close':
      return {
        ...state,
        isOpen: false,
        mode: 'sleeping',
        transitionDurationMs: command.durationMs ?? 900,
      }

    case 'eye/blink':
      return state.isOpen
        ? { ...state, blinkSequence: state.blinkSequence + 1, transitionDurationMs: command.durationMs ?? 380 }
        : state

    case 'eye/look':
      return {
        ...state,
        gazeDurationMs: command.durationMs ?? (state.mode === 'alert' ? 140 : 240),
        gaze: {
          x: clampGaze(command.x),
          y: clampGaze(command.y),
        },
      }

    case 'eye/nudge':
      return {
        ...state,
        gazeDurationMs: 240,
        gaze: {
          x: clampGaze(state.gaze.x + command.x),
          y: clampGaze(state.gaze.y + command.y),
        },
      }

    case 'eye/mode':
      return {
        ...state,
        isOpen: command.mode !== 'sleeping',
        mode: command.mode,
      }

    case 'system/reset':
      return createInitialEyeState()
  }
}
