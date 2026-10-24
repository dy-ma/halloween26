import { useEffect, useRef, useState } from 'react'

export type ActivityEntry = {
  id: number
  timestampMs: number
  level: 'info' | 'warning' | 'error'
  message: string
  runId: string | null
}

const clock = new Intl.DateTimeFormat(undefined, { hour: '2-digit', minute: '2-digit', second: '2-digit' })

export function ActivityLog({ entries }: { entries: ActivityEntry[] }) {
  const viewport = useRef<HTMLDivElement>(null)
  const [following, setFollowing] = useState(true)
  const latestId = entries.at(-1)?.id
  const latestTime = entries.at(-1)?.timestampMs

  useEffect(() => {
    if (following && viewport.current) viewport.current.scrollTop = viewport.current.scrollHeight
  }, [following, latestId, latestTime])

  return (
    <section aria-labelledby="activity-heading">
      <div className="activity-heading">
        <h2 id="activity-heading">Activity log</h2>
        <label><input type="checkbox" checked={following} onChange={event => setFollowing(event.target.checked)} /> Follow latest</label>
      </div>
      <div className="activity-log" ref={viewport} role="log" aria-label="Workflow and assembly activity" aria-live="off" tabIndex={0}
        onScroll={event => {
          const element = event.currentTarget
          setFollowing(element.scrollHeight - element.scrollTop - element.clientHeight < 24)
        }}>
        {entries.map(entry => (
          <div className={`log-entry log-${entry.level}`} key={`${entry.timestampMs}:${entry.id}`} title={entry.runId ? `Run ${entry.runId}` : undefined}>
            <time dateTime={new Date(entry.timestampMs).toISOString()}>{clock.format(entry.timestampMs)}</time>
            <span className="log-level">{entry.level}</span>
            <span>{entry.message}</span>
          </div>
        ))}
        {!entries.length && <p className="log-empty">No activity yet.</p>}
      </div>
      <p className="status-note">Last 500 events · Scroll back to pause following · Cleared when the server restarts</p>
    </section>
  )
}
