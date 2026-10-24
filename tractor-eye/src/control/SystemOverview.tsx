import type { RuntimeStatus, ScreenStatus, SystemStatus } from './dashboard-types'

const modeLabel = (mode: RuntimeStatus['state']['mode']) => mode.replace('-', ' ')

const duration = (milliseconds: number) => {
  const totalMinutes = Math.floor(milliseconds / 60_000)
  const days = Math.floor(totalMinutes / 1_440)
  const hours = Math.floor((totalMinutes % 1_440) / 60)
  const minutes = totalMinutes % 60
  return days ? `${days}d ${hours}h` : hours ? `${hours}h ${minutes}m` : `${minutes}m`
}

export function SystemOverview({ runtime, system, screens, boardsOnline, boardsTotal }: {
  runtime: RuntimeStatus
  system: SystemStatus | null
  screens: ScreenStatus[]
  boardsOnline: number
  boardsTotal: number
}) {
  const mode = runtime.state.mode
  const eye = screens.find(screen => screen.id === 'tractor-eye') ?? screens[0]
  return <section className="system-overview" aria-labelledby="system-overview-heading">
    <div className="section-heading-row">
      <div><p className="eyebrow">Master controller</p><h2 id="system-overview-heading">System status</h2></div>
      <span className={`mode-badge mode-badge--${mode}`}>{modeLabel(mode)}</span>
    </div>
    <div className="status-card-grid">
      <article className="status-card">
        <span className="status-card-label">FX runtime</span>
        <strong><span className="status-light status-light--online" />Online</strong>
        <small>{system ? `${system.hostname} · up ${duration(system.uptimeMs)}` : 'Reading host details…'}</small>
      </article>
      <article className="status-card">
        <span className="status-card-label">Network</span>
        <strong>{system?.wifiSsid ?? 'SSID unavailable'}</strong>
        <small>{system?.links.map(link => `${link.id} · ${link.transport} ${link.endpoint}: ${link.connected ? 'connected' : 'offline'}`).join(' · ') || 'No cue links configured'}</small>
      </article>
      <article className="status-card">
        <span className="status-card-label">Boards</span>
        <strong><span className={`status-light ${boardsOnline === boardsTotal && boardsTotal ? 'status-light--online' : 'status-light--offline'}`} />{boardsOnline} / {boardsTotal} online</strong>
        <small>Live presence, not command delivery</small>
      </article>
      <article className="status-card">
        <span className="status-card-label">Eye</span>
        <strong><span className={`status-light ${eye?.connected ? 'status-light--online' : 'status-light--offline'}`} />{eye?.state.mode ?? 'unavailable'}</strong>
        <small>{eye ? `${eye.connected ? 'display connected' : 'desired state retained'} · sequence ${eye.sequence}` : 'No eye configured'}</small>
      </article>
      <article className="status-card">
        <span className="status-card-label">Battery telemetry</span>
        <strong>{system?.batteryPercent == null ? 'Not available' : `${system.batteryPercent}%`}</strong>
        <small>No fuel-gauge telemetry configured</small>
      </article>
    </div>
  </section>
}
