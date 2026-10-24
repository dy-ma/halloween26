import type { PropStatus, ScreenStatus } from './dashboard-types'

const stateLabel = (state: string) => state.replaceAll('-', ' ')

function PropGraph({ prop }: { prop: PropStatus }) {
  return <article className="prop-graph">
    <div className="prop-graph-heading">
      <div><h3>{prop.label}</h3><span>{prop.id}</span></div>
      <strong>{stateLabel(prop.state)}</strong>
    </div>
    <div className="state-nodes" aria-label={`${prop.label} states`}>
      {prop.states.map(state => <span key={state}
        className={`state-node${state === prop.state ? ' current' : ''}${state === prop.readyState ? ' ready' : ''}`}>
        {stateLabel(state)}
      </span>)}
    </div>
    <div className="transition-list">
      {prop.transitions.map(transition => <div className={`transition-row${prop.pending?.name === transition.name ? ' active' : ''}`} key={transition.name}>
        <span className="transition-name">{transition.name}</span>
        <span>{transition.from.map(stateLabel).join(' / ')}</span>
        <span aria-hidden="true">→</span>
        <span>{stateLabel(transition.active)}</span>
        <span aria-hidden="true">→</span>
        <span>{stateLabel(transition.to)}</span>
      </div>)}
    </div>
    {prop.pending ? <p className="pending-transition">
      {prop.pending.phase} <strong>{prop.pending.name}</strong>
      {prop.pending.executeAtMs ? ` · ${new Date(prop.pending.executeAtMs).toLocaleTimeString()}` : ''}
    </p> : <p className="pending-transition muted">No transition pending</p>}
  </article>
}

export function StateGraph({ props, screens }: { props: PropStatus[]; screens: ScreenStatus[] }) {
  return <section aria-labelledby="state-graph-heading">
    <div className="section-heading-row">
      <div><p className="eyebrow">Live model</p><h2 id="state-graph-heading">Prop state graph</h2></div>
      <p>Outlined state = ready position</p>
    </div>
    <div className="prop-graph-grid">
      {props.map(prop => <PropGraph prop={prop} key={prop.id} />)}
      {screens.map(screen => <article className="prop-graph eye-state-card" key={screen.id}>
        <div className="prop-graph-heading"><div><h3>Eye</h3><span>{screen.id}</span></div><strong>{screen.state.mode}</strong></div>
        <div className="state-nodes">
          {['sleeping', 'idle', 'alert', 'tipping'].map(mode => <span className={`state-node${mode === screen.state.mode ? ' current' : ''}`} key={mode}>{mode}</span>)}
        </div>
        <p className="pending-transition">Desired gaze {screen.state.gaze.x.toFixed(2)}, {screen.state.gaze.y.toFixed(2)} · {screen.connected ? 'display connected' : 'waiting for display'}</p>
      </article>)}
      {!props.length && !screens.length ? <p>No managed props or displays configured.</p> : null}
    </div>
  </section>
}
