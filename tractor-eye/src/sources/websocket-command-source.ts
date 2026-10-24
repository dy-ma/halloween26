import type { AnimationCommandSource } from '../commands/command-bus.ts'
import type { WebSocketConfig } from '../network/config.ts'
import { decodeServerMessage } from '../network/protocol.ts'

export interface ConnectionStatus {
  phase: 'disabled' | 'connecting' | 'syncing' | 'connected' | 'retrying' | 'config-error'
  sessionId: string | null
  lastAcceptedSeq: number | null
  lastHeartbeatAtMs: number | null
  reason?: string
}

export type EyeSocket = Pick<WebSocket, 'addEventListener' | 'removeEventListener' | 'send' | 'close'>
export interface WebSocketSourceOptions {
  clientId?: string
  clientName?: string
  createSocket?: (url: string) => EyeSocket
  now?: () => number
  random?: () => number
  onStatus?: (status: Readonly<ConnectionStatus>) => void
}

export function createWebSocketCommandSource(
  config: WebSocketConfig,
  options: WebSocketSourceOptions = {},
): AnimationCommandSource {
  return {
    start(commandBus) {
      const createSocket = options.createSocket ?? ((url: string) => new WebSocket(url))
      const now = options.now ?? Date.now
      const random = options.random ?? Math.random
      let status: ConnectionStatus = {
        phase: 'disabled', sessionId: null, lastAcceptedSeq: null, lastHeartbeatAtMs: null,
      }
      const report = (update: Partial<ConnectionStatus>) => {
        status = { ...status, ...update }
        options.onStatus?.({ ...status })
      }
      if (!config.websocket.enabled) {
        report({ phase: 'disabled' })
        return () => {}
      }
      const url = config.websocket.url
      let stopped = false
      let failures = 0
      let retryTimer: ReturnType<typeof setTimeout> | undefined
      let disposeConnection = () => {}

      const retry = (reason: string) => {
        disposeConnection()
        if (stopped || retryTimer !== undefined) return
        report({ phase: 'retrying', reason })
        // 50–100% jitter keeps the maximum delay bounded at ten seconds.
        const ceiling = Math.min(10_000, 500 * 2 ** Math.min(failures++, 5))
        retryTimer = setTimeout(() => {
          retryTimer = undefined
          connect()
        }, ceiling * (0.5 + random() * 0.5))
      }

      const connect = () => {
        if (stopped) return
        report({ phase: 'connecting', sessionId: null, lastAcceptedSeq: null, lastHeartbeatAtMs: null, reason: undefined })
        let socket: EyeSocket
        try { socket = createSocket(url) } catch { retry('socket-create-failed'); return }
        let active = true
        let sessionId: string | null = null
        let sequence = 0
        let pingId = 0
        let pendingPing: string | null = null
        let pingTimer: ReturnType<typeof setTimeout> | undefined
        let pongTimer: ReturnType<typeof setTimeout> | undefined
        let healthyTimer: ReturnType<typeof setTimeout> | undefined
        const deadline = setTimeout(() => fail('connect-or-snapshot-timeout'), 5_000)
        const fail = (reason: string) => { if (active && !stopped) retry(reason) }
        const send = (message: object) => {
          try { socket.send(JSON.stringify(message)); return true }
          catch { fail('send-failed'); return false }
        }
        const schedulePing = () => {
          pingTimer = setTimeout(() => {
            if (!active || stopped || pendingPing !== null) return
            pendingPing = String(++pingId)
            pongTimer = setTimeout(() => fail('heartbeat-timeout'), 10_000)
            send({ v: 1, type: 'ping', id: pendingPing })
          }, 5_000)
        }
        const onOpen = () => {
          if (!active || stopped) return
          report({ phase: 'syncing' })
          send({ v: 1, type: 'hello', screenId: config.screenId,
            ...(options.clientId ? { clientId: options.clientId, clientName: options.clientName } : {}),
          })
        }
        const onMessage: EventListener = (event) => {
          if (!active || stopped) return
          const message = decodeServerMessage((event as MessageEvent<unknown>).data)
          if (!message) { fail('invalid-frame'); return }
          if (message.type === 'snapshot') {
            if (sessionId !== null) { fail('unexpected-snapshot'); return }
            sessionId = message.sessionId
            sequence = message.seq
            clearTimeout(deadline)
            // One action cancels pending wake cues and replaces the entire pose.
            commandBus.publish({ type: 'eye/snapshot', state: message.state })
            report({ phase: 'connected', sessionId, lastAcceptedSeq: sequence, reason: undefined })
            healthyTimer = setTimeout(() => { failures = 0 }, 30_000)
            schedulePing()
            return
          }
          if (sessionId === null) { fail('snapshot-required'); return }
          if (message.type === 'pong') {
            if (message.id !== pendingPing) { fail('unexpected-pong'); return }
            clearTimeout(pongTimer)
            pendingPing = null
            report({ lastHeartbeatAtMs: now() })
            schedulePing()
            return
          }
          if (message.sessionId !== sessionId) { fail('session-mismatch'); return }
          if (message.seq <= sequence) return
          if (message.seq !== sequence + 1) { fail('sequence-gap'); return }
          if (message.expiresAtMs <= now()) { fail('expired-command'); return }
          sequence = message.seq
          commandBus.publish(message.command)
          // Reports receipt and dispatch to the client command bus, not animation completion.
          send({ v: 1, type: 'applied', sessionId, seq: sequence })
          report({ lastAcceptedSeq: sequence })
        }
        const onClose = () => fail('socket-closed')
        const onError = () => fail('socket-error')
        disposeConnection = () => {
          if (!active) return
          active = false
          clearTimeout(deadline)
          clearTimeout(pingTimer)
          clearTimeout(pongTimer)
          clearTimeout(healthyTimer)
          socket.removeEventListener('open', onOpen)
          socket.removeEventListener('message', onMessage)
          socket.removeEventListener('close', onClose)
          socket.removeEventListener('error', onError)
          try { socket.close() } catch { /* Already retired. */ }
        }
        socket.addEventListener('open', onOpen)
        socket.addEventListener('message', onMessage)
        socket.addEventListener('close', onClose)
        socket.addEventListener('error', onError)
      }
      connect()
      return () => {
        stopped = true
        clearTimeout(retryTimer)
        disposeConnection()
      }
    },
  }
}
