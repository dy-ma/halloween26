import type { ConnectionStatus } from '../sources/websocket-command-source'

export function createConnectionReporter(): (status: Readonly<ConnectionStatus>) => void {
  let lastLogAt = -Infinity
  let lastPhase: ConnectionStatus['phase'] | undefined
  return (status) => {
    // Observable without React state, UI overlays, or animation-bus traffic.
    document.body.dataset.eyeConnection = JSON.stringify(status)
    if (status.phase === lastPhase) return
    lastPhase = status.phase
    const now = Date.now()
    if (now - lastLogAt < 10_000 && status.phase !== 'config-error') return
    lastLogAt = now
    console.info('[tractor-eye websocket]', status.phase, status.reason ?? '')
  }
}
