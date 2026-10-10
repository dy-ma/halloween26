import type { AnimationCommandSource } from '../commands/command-bus.ts'
import { decodeRuntimeConfig } from '../network/config.ts'
import { MAX_FRAME_BYTES } from '../network/protocol.ts'
import { createWebSocketCommandSource, type WebSocketSourceOptions } from './websocket-command-source.ts'

interface RuntimeSourceOptions extends WebSocketSourceOptions {
  pageUrl: string
  fetchConfig?: typeof fetch
}

export function createRuntimeWebSocketSource(options: RuntimeSourceOptions): AnimationCommandSource {
  return {
    start(bus) {
      const controller = new AbortController()
      let disposed = false
      let stopSocket = () => {}
      const timeout = setTimeout(() => controller.abort(), 5_000)
      const load = async () => {
        try {
          const response = await (options.fetchConfig ?? fetch)(new URL('/config.json', options.pageUrl), {
            cache: 'no-store', signal: controller.signal,
          })
          if (!response.ok) throw new Error('Config unavailable')
          const text = await response.text()
          if (text.length > MAX_FRAME_BYTES) throw new Error('Config too large')
          const config = decodeRuntimeConfig(JSON.parse(text), options.pageUrl)
          if (disposed || controller.signal.aborted) return
          stopSocket = createWebSocketCommandSource(config, options).start(bus)
        } catch {
          if (!disposed) options.onStatus?.({
            phase: 'config-error', sessionId: null, lastAcceptedSeq: null,
            lastHeartbeatAtMs: null, reason: 'Could not load a valid /config.json; reload after fixing it',
          })
        } finally {
          clearTimeout(timeout)
        }
      }
      void load()
      return () => {
        disposed = true
        controller.abort()
        clearTimeout(timeout)
        stopSocket()
      }
    },
  }
}
