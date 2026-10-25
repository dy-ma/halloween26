import { useState } from 'react'
import { ActivityLog } from './ActivityLog'
import type { RuntimeStatus, ScreenStatus, SystemStatus } from './dashboard-types'

export function DashboardDock({ runtime, system, screens, boardsOnline, boardsTotal,
  restartFxAvailable, restartingFx, restartingBroker, status, onRestartFx, onRestartBroker }: {
  runtime: RuntimeStatus
  system: SystemStatus | null
  screens: ScreenStatus[]
  boardsOnline: number
  boardsTotal: number
  restartFxAvailable: boolean
  restartingFx: boolean
  restartingBroker: boolean
  status: string
  onRestartFx: () => void
  onRestartBroker: () => void
}) {
  const [logOpen, setLogOpen] = useState(false)
  const broker = system?.links.find(link => link.transport.toLowerCase().includes('mqtt'))
  const eye = screens.find(screen => screen.id === 'tractor-eye') ?? screens[0]
  return <aside className="dashboard-dock" aria-label="System status and activity">
    {logOpen && <div className="dashboard-dock-log"><ActivityLog entries={runtime.log ?? []} /></div>}
    <div className="dashboard-dock-bar">
      <strong className={`mode-badge mode-badge--${runtime.state.mode}`}>{runtime.state.mode.replace('-', ' ')}</strong>
      <span><i className={system?.wifiSsid ? 'online' : ''} />Wi-Fi <strong>{system?.wifiSsid ?? 'offline'}</strong></span>
      <span><i className={broker?.connected ? 'online' : ''} />MQTT <strong>{broker?.connected ? 'up' : 'down'}</strong></span>
      <span><i className={boardsOnline > 0 ? 'online' : ''} />Boards <strong>{boardsOnline}/{boardsTotal}</strong></span>
      <span><i className={eye?.connected ? 'online' : ''} />Eye <strong>{eye?.connected ? eye.state.mode : 'offline'}</strong></span>
      <output>{status}</output>
      <div className="dock-actions">
        <button type="button" onClick={() => setLogOpen(open => !open)}>{logOpen ? 'Hide log' : 'Show log'}</button>
        <button type="button" disabled={!system?.brokerRestartAvailable || restartingBroker || restartingFx} onClick={onRestartBroker}>{restartingBroker ? 'Restarting…' : 'Restart broker'}</button>
        <button type="button" className="restart-fx" disabled={!restartFxAvailable || restartingFx || restartingBroker} onClick={onRestartFx}>{restartingFx ? 'Restarting…' : 'Restart FX'}</button>
      </div>
    </div>
  </aside>
}
