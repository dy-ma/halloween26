import { Option, Schema } from 'effect'

const EyeOpenCommand = Schema.Struct({
  type: Schema.Literal('eye/open'),
  durationMs: Schema.optionalKey(Schema.Number),
})

const EyeCloseCommand = Schema.Struct({
  type: Schema.Literal('eye/close'),
  durationMs: Schema.optionalKey(Schema.Number),
})

const EyeBlinkCommand = Schema.Struct({
  type: Schema.Literal('eye/blink'),
  durationMs: Schema.optionalKey(Schema.Number),
})

const EyeWakeCommand = Schema.Struct({ type: Schema.Literal('eye/wake') })

const EyeLookCommand = Schema.Struct({
  type: Schema.Literal('eye/look'),
  x: Schema.Number,
  y: Schema.Number,
  durationMs: Schema.optionalKey(Schema.Number),
})

const EyeNudgeCommand = Schema.Struct({
  type: Schema.Literal('eye/nudge'),
  x: Schema.Number,
  y: Schema.Number,
})

const EyeModeCommand = Schema.Struct({
  type: Schema.Literal('eye/mode'),
  mode: Schema.Literals(['idle', 'alert', 'tipping', 'sleeping']),
})

const SystemResetCommand = Schema.Struct({
  type: Schema.Literal('system/reset'),
})

export const AnimationCommandSchema = Schema.Union([
  EyeOpenCommand,
  EyeCloseCommand,
  EyeBlinkCommand,
  EyeWakeCommand,
  EyeLookCommand,
  EyeNudgeCommand,
  EyeModeCommand,
  SystemResetCommand,
])

export type AnimationCommand = Schema.Schema.Type<
  typeof AnimationCommandSchema
>

const decodeCommand = Schema.decodeUnknownOption(AnimationCommandSchema)

export function decodeAnimationCommand(input: unknown): AnimationCommand | undefined {
  return Option.getOrUndefined(decodeCommand(input))
}
