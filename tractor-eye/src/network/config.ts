import { isRecord } from './protocol.ts'

export type WebSocketConfig = {
  screenId: string
  websocket: { enabled: false } | { enabled: true; url: string }
}

export function decodeRuntimeConfig(value: unknown, pageUrl: string): WebSocketConfig {
  if (!isRecord(value) || typeof value.screenId !== 'string'
    || !value.screenId.trim() || value.screenId.length > 128 || !isRecord(value.websocket)) {
    throw new Error('Invalid eye runtime configuration')
  }
  if (value.websocket.enabled === false) {
    return { screenId: value.screenId, websocket: { enabled: false } }
  }
  if (value.websocket.enabled !== true || typeof value.websocket.url !== 'string'
    || !value.websocket.url.trim() || value.websocket.url.length > 2048) {
    throw new Error('Invalid WebSocket configuration')
  }
  const page = new URL(pageUrl)
  const rawUrl = value.websocket.url
  // The only relative form is an origin-relative path; no protocol-relative hosts.
  if (!rawUrl.startsWith('ws://') && !rawUrl.startsWith('wss://')
    && (!rawUrl.startsWith('/') || rawUrl.startsWith('//'))) throw new Error('Invalid WebSocket URL')
  const url = new URL(rawUrl, page.origin)
  if (rawUrl.startsWith('/')) url.protocol = page.protocol === 'https:' ? 'wss:' : 'ws:'
  if (!['ws:', 'wss:'].includes(url.protocol) || (page.protocol === 'https:' && url.protocol !== 'wss:')
    || url.username || url.password || url.hash) throw new Error('Unsafe WebSocket URL')
  return { screenId: value.screenId, websocket: { enabled: true, url: url.href } }
}
