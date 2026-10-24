import type { RuntimeStatus } from './dashboard-types'

const phaseLabel = (phase: string) => phase.charAt(0).toUpperCase() + phase.slice(1)

export function RunTimeline({ runs }: { runs: RuntimeStatus['runs'] }) {
  const active = runs.find(run => run.nodes.some(node => ['pending', 'scheduled', 'running'].includes(node.phase))) ?? runs[0]
  return <section aria-labelledby="run-timeline-heading">
    <div className="section-heading-row">
      <div><p className="eyebrow">Execution</p><h2 id="run-timeline-heading">Current run</h2></div>
      {active ? <span>{active.role} · {new Date(active.startedAtMs).toLocaleTimeString()}</span> : null}
    </div>
    {active ? <div className="run-timeline">
      {active.nodes.map(node => <article className={`run-node run-node--${node.phase}`} key={node.id}>
        <div><strong>{node.id.split('/').at(-1)}</strong><span>{phaseLabel(node.phase)}</span></div>
        <p>{node.detail}</p>
        <small>{node.executeAtMs ? `Execute ${new Date(node.executeAtMs).toLocaleTimeString()}` : `Offset ${node.offsetMs}ms`}{node.transition ? ` · ${node.transition}` : ''}</small>
      </article>)}
    </div> : <p className="empty-card">No workflow has run since FX started.</p>}
  </section>
}
