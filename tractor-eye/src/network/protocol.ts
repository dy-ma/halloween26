import { decodeAnimationCommand, type EyeSnapshot, type WireAnimationCommand } from '../commands/animation-command.ts'

export const MAX_FRAME_BYTES = 8 * 1024
const encoder = new TextEncoder()

export type ServerMessage =
  | { v: 1; type: 'snapshot'; sessionId: string; seq: number; state: EyeSnapshot }
  | { v: 1; type: 'command'; sessionId: string; seq: number; expiresAtMs: number; command: WireAnimationCommand }
  | { v: 1; type: 'pong'; id: string }

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

function validId(value: unknown): value is string {
  return typeof value === 'string' && value.length > 0 && value.length <= 128
}

function safeCounter(value: unknown): value is number {
  return typeof value === 'number' && Number.isSafeInteger(value) && value >= 0
}

function gazeValue(value: unknown): value is number {
  return typeof value === 'number' && Number.isFinite(value) && value >= -1 && value <= 1
}

function snapshot(value: unknown): EyeSnapshot | undefined {
  if (!isRecord(value) || !isRecord(value.gaze)) return
  const { mode, gaze } = value
  if (mode !== 'sleeping' && mode !== 'idle' && mode !== 'alert' && mode !== 'tipping') return
  if (!gazeValue(gaze.x) || !gazeValue(gaze.y)) return
  return { mode, gaze: { x: gaze.x, y: gaze.y } }
}

export function decodeServerMessage(raw: unknown): ServerMessage | undefined {
  // Reject binary frames and bound bytes, not just UTF-16 string length.
  if (typeof raw !== 'string' || raw.length > MAX_FRAME_BYTES || encoder.encode(raw).byteLength > MAX_FRAME_BYTES) return
  let value: unknown
  try { value = JSON.parse(raw) } catch { return }
  if (!isRecord(value) || value.v !== 1) return
  if (value.type === 'pong') {
    return validId(value.id) ? { v: 1, type: 'pong', id: value.id } : undefined
  }
  if (!validId(value.sessionId) || !safeCounter(value.seq)) return
  if (value.type === 'snapshot') {
    const state = snapshot(value.state)
    return state ? { v: 1, type: 'snapshot', sessionId: value.sessionId, seq: value.seq, state } : undefined
  }
  if (value.type !== 'command' || !safeCounter(value.expiresAtMs)) return
  const command = decodeAnimationCommand(value.command)
  if (!command) return
  if ('durationMs' in command && command.durationMs !== undefined
    && (!Number.isFinite(command.durationMs) || command.durationMs < 0 || command.durationMs > 10_000)) return
  if ('x' in command && (!gazeValue(command.x) || !gazeValue(command.y))) return
  return { v: 1, type: 'command', sessionId: value.sessionId, seq: value.seq, expiresAtMs: value.expiresAtMs, command }
}
