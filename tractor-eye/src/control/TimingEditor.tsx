import { useState } from 'react'
import type { TimingStatus } from './dashboard-types'

export function TimingEditor({ timings, onUpdated }: { timings: TimingStatus[]; onUpdated: (nodeId: string, atMs: number) => void }) {
  const [drafts, setDrafts] = useState<Record<string, number>>({})
  const [message, setMessage] = useState('')

  const save = async (timing: TimingStatus) => {
    const atMs = drafts[timing.nodeId] ?? timing.atMs
    const response = await fetch('/api/timing', {
      method: 'POST', headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ nodeId: timing.nodeId, atMs }),
    })
    if (!response.ok) throw new Error(await response.text())
    onUpdated(timing.nodeId, atMs)
    setDrafts(current => {
      const next = { ...current }
      delete next[timing.nodeId]
      return next
    })
    setMessage(`${timing.nodeId} will use ${atMs}ms on the next run.`)
  }

  const grouped = timings.reduce<Map<string, TimingStatus[]>>((groups, timing) => {
    const nodes = groups.get(timing.flow)
    if (nodes) nodes.push(timing)
    else groups.set(timing.flow, [timing])
    return groups
  }, new Map())
  return <section aria-labelledby="timing-heading">
    <div className="section-heading-row"><div><p className="eyebrow">Choreography</p><h2 id="timing-heading">Execution timing</h2></div>{message && <output aria-live="polite">{message}</output>}</div>
    <div className="timing-groups">
      {[...grouped].map(([flow, nodes]) => <article className="timing-group" key={flow}>
        <h3>{flow.replaceAll('_', ' ')}</h3>
        {nodes.map(timing => {
          const inputId = `timing-${timing.nodeId.replaceAll('/', '-')}`
          return <div className="timing-row" key={timing.nodeId}>
            <label htmlFor={inputId}><strong>{timing.node}</strong><small>{timing.after.length ? `after ${timing.after.map(id => id.split('/').at(-1)).join(', ')}` : 'from trigger'}{timing.transition ? ` · ${timing.transition}` : ''}</small></label>
            <input id={inputId} type="number" min="0" max="60000" step="10" value={drafts[timing.nodeId] ?? timing.atMs}
              onChange={event => setDrafts(current => ({ ...current, [timing.nodeId]: Number(event.currentTarget.value) }))} />
            <span>ms</span>
            <button type="button" disabled={(drafts[timing.nodeId] ?? timing.atMs) === timing.atMs}
              onClick={() => void save(timing).catch(error => setMessage(String(error)))}>Apply</button>
          </div>
        })}
      </article>)}
    </div>
  </section>
}
