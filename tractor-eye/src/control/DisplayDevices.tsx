import { useState } from 'react'

export type DisplayDevice = {
  id: string
  name: string
  userAgent: string
  firstSeenAtMs: number
  lastSeenAtMs: number
  connections: {
    connectionId: string
    lastAppliedSequence: number | null
    state: { mode: string }
  }[]
}

export function DisplayDevices({ devices, unavailable, onForgot }: {
  devices: DisplayDevice[]
  unavailable: boolean
  onForgot: (id: string) => void
}) {
  const [busy, setBusy] = useState<Set<string>>(() => new Set())
  const [message, setMessage] = useState('')

  const request = async (key: string, url: string, options: RequestInit, done?: () => void) => {
    setBusy(current => new Set(current).add(key))
    try {
      const response = await fetch(url, options)
      if (!response.ok) throw new Error(await response.text())
      done?.()
      setMessage('')
    } catch (error) { setMessage(String(error)) }
    finally { setBusy(current => { const next = new Set(current); next.delete(key); return next }) }
  }

  return <section aria-labelledby="displays-heading">
    <div className="activity-heading"><h2 id="displays-heading">Display devices</h2><a href="/" target="_blank" rel="noreferrer">Open display page</a></div>
    {unavailable && <p role="status">Device status unavailable. Controls paused until reconnected.</p>}
    {message && <p role="status">{message}</p>}
    <div className="display-device-list">
      {devices.map(device => <article className="display-device" key={device.id} aria-label={device.name}>
        <header>
          <div><h3 title={device.userAgent || undefined}>{device.name}</h3><code title={`Saved browser ID: ${device.id}`}>{device.id}</code></div>
          <button type="button" className="forget-display" disabled={unavailable || !!device.connections.length || busy.has(device.id)}
            title={device.connections.length ? 'Close this display’s tabs before forgetting it' : 'Remove this saved device; reopening its display page adds it again'}
            onClick={() => void request(device.id, `/api/displays/${encodeURIComponent(device.id)}`, { method: 'DELETE' }, () => onForgot(device.id))}>Forget</button>
        </header>
        {!device.connections.length && <p className="status-note">Offline · Last seen {new Date(device.lastSeenAtMs).toLocaleString()}</p>}
        {device.connections.map(connection => <div className="display-connection" key={connection.connectionId}>
          <span>{device.connections.length > 1 ? `Tab ${connection.connectionId.slice(0, 6)} · ` : ''}{connection.state.mode} · connected</span>
          <div className="control-grid display-actions">
            {(['wake', 'reset'] as const).map(operation => <button key={operation} type="button"
              disabled={unavailable || busy.has(connection.connectionId)}
              onClick={() => void request(connection.connectionId, '/api/control', {
                method: 'POST', headers: { 'content-type': 'application/json' },
                body: JSON.stringify({ control: `client/${connection.connectionId}/${operation}`, phase: 'press' }),
              })}>{operation === 'wake' ? 'Wake' : 'Reset'}</button>)}
          </div>
        </div>)}
      </article>)}
    </div>
    {!devices.length && !unavailable && <p>No saved displays yet. Open the display page on any browser to add it automatically.</p>}
  </section>
}
