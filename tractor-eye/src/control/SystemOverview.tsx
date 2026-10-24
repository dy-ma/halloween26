import type { RuntimeStatus, ScreenStatus, SystemStatus } from './dashboard-types'

const modeLabel = (mode: RuntimeStatus['state']['mode']) => mode.replace('-', ' ')

const duration = (milliseconds: number) => {
  const totalMinutes = Math.floor(milliseconds / 60_000)
  const days = Math.floor(totalMinutes / 1_440)
  const hours = Math.floor((totalMinutes % 1_440) / 60)
  const minutes = totalMinutes % 60
  return days ? `${days}d ${hours}h` : hours ? `${hours}h ${minutes}m` : `${minutes}m`
}

function HealthMetric({ label, value, online, detail }: {
  label: string
  value: string
  online?: boolean
  detail?: string
}) {
  return <div className="health-metric">
    <dt>{label}</dt>
    <dd>
      {online !== undefined && <span className={`status-light ${online ? 'status-light--online' : 'status-light--offline'}`} />}
      <strong>{value}</strong>
      {detail && <small>{detail}</small>}
    </dd>
  </div>
}

export function SystemOverview({ runtime, system, screens, boardsOnline, boardsTotal,
  restartFxAvailable, restartingFx, restartingBroker, actionStatus, onRestartFx, onRestartBroker }: {
  runtime: RuntimeStatus
  system: SystemStatus | null
  screens: ScreenStatus[]
  boardsOnline: number
  boardsTotal: number
  restartFxAvailable: boolean
  restartingFx: boolean
  restartingBroker: boolean
  actionStatus: string
  onRestartFx: () => void
  onRestartBroker: () => void
}) {
  const mode = runtime.state.mode
  const eye = screens.find(screen => screen.id === 'tractor-eye') ?? screens[0]
  const broker = system?.links.find(link => link.transport.toLowerCase().includes('mqtt')) ?? system?.links[0]
  return <section className="system-overview" aria-labelledby="system-overview-heading">
    <div className="system-console-heading">
      <div className="system-title">
        <div><p className="eyebrow">Master controller</p><h2 id="system-overview-heading">System</h2></div>
        <span className={`mode-badge mode-badge--${mode}`}>{modeLabel(mode)}</span>
      </div>
      <div className="lifecycle-actions" aria-label="Lifecycle controls">
        <button type="button" disabled={!system?.brokerRestartAvailable || restartingBroker || restartingFx}
          title={!system?.brokerRestartAvailable ? 'Install the dashboard broker authorization on the Pi to enable this control.' : undefined}
          onClick={onRestartBroker}>{restartingBroker ? 'Restarting broker…' : 'Restart broker'}</button>
        <button type="button" className="restart-fx" disabled={!restartFxAvailable || restartingFx || restartingBroker}
          onClick={onRestartFx}>{restartingFx ? 'Restarting FX…' : 'Restart FX'}</button>
      </div>
    </div>

    <dl className="health-strip">
      <HealthMetric label="Runtime" value={system ? system.hostname : 'unavailable'} online={Boolean(system)}
        detail={system ? `up ${duration(system.uptimeMs)}` : undefined} />
      <HealthMetric label="Wi-Fi" value={system?.wifiSsid ?? 'unavailable'} />
      <HealthMetric label="Broker" value={broker?.connected ? 'connected' : 'offline'} online={broker?.connected ?? false}
        detail={broker?.endpoint} />
      <HealthMetric label="Boards" value={`${boardsOnline}/${boardsTotal}`} online={boardsTotal > 0 && boardsOnline === boardsTotal} />
      <HealthMetric label="Eye" value={eye?.connected ? eye.state.mode : 'offline'} online={eye?.connected ?? false}
        detail={eye && !eye.connected ? `desired ${eye.state.mode}` : undefined} />
      {system?.batteryPercent != null && <HealthMetric label="Battery" value={`${system.batteryPercent}%`} />}
    </dl>
    {actionStatus && actionStatus !== 'Runtime connected' && <output className="system-action-status" aria-live="polite">{actionStatus}</output>}
  </section>
}
