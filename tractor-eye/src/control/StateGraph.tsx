import { useId } from 'react'
import type { PropStatus, PropTransition, ScreenStatus } from './dashboard-types'

const graphWidth = 640
const stableY = 44
const transitionY = 142

const stateLabel = (state: string) => state.replaceAll('-', ' ')

type Point = { x: number; y: number }

const statePositions = (states: string[]) => new Map(states.map((state, index) => [
  state,
  { x: graphWidth * (index + 1) / (states.length + 1), y: stableY },
] as const))

const curve = (from: Point, to: Point) => {
  const bend = Math.max(28, Math.abs(to.y - from.y) * 0.48)
  const direction = to.y > from.y ? 1 : -1
  return `M ${from.x} ${from.y} C ${from.x} ${from.y + bend * direction}, ${to.x} ${to.y - bend * direction}, ${to.x} ${to.y}`
}

function StateMachine({ prop }: { prop: PropStatus }) {
  const markerId = `arrow-${useId().replaceAll(':', '')}`
  const failureMarkerId = `${markerId}-failure`
  const activeStates = new Set(prop.transitions.map(transition => transition.active))
  const stableStates = prop.states.filter(state => !activeStates.has(state))
  const positions = statePositions(stableStates)
  const transitionPositions = new Map(prop.transitions.map((transition, index) => [
    transition.name,
    { x: graphWidth * (index + 1) / (prop.transitions.length + 1), y: transitionY },
  ] as const))

  const activeTransition = prop.pending?.name
    ?? prop.transitions.find(transition => transition.active === prop.state)?.name

  const stateBottom = (state: string) => {
    const position = positions.get(state)!
    return { x: position.x, y: position.y + 23 }
  }
  const transitionTop = (transition: PropTransition) => {
    const position = transitionPositions.get(transition.name)!
    return { x: position.x, y: position.y - 24 }
  }

  return <svg className="state-machine" viewBox={`0 0 ${graphWidth} 190`} role="img"
    aria-label={`${prop.label}: current state ${stateLabel(prop.state)}`}>
    <defs>
      <marker id={markerId} viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
        <path d="M 0 0 L 10 5 L 0 10 z" />
      </marker>
      <marker id={failureMarkerId} className="machine-failure-marker" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
        <path d="M 0 0 L 10 5 L 0 10 z" />
      </marker>
    </defs>

    <g className="machine-edges">
      {prop.transitions.flatMap(transition => {
        const transitionPosition = transitionPositions.get(transition.name)!
        const entering = transition.from
          .filter(state => positions.has(state))
          .map(state => <path key={`${transition.name}:${state}:in`}
            className={activeTransition === transition.name ? 'active' : undefined}
            d={curve(stateBottom(state), transitionTop(transition))} markerEnd={`url(#${markerId})`} />)
        const target = positions.get(transition.to)
        const outgoing = target ? <path key={`${transition.name}:out`}
          className={activeTransition === transition.name ? 'active' : undefined}
          d={curve({ x: transitionPosition.x, y: transitionPosition.y - 24 }, { x: target.x, y: target.y + 23 })}
          markerEnd={`url(#${markerId})`} /> : null
        const failure = transition.failure !== transition.to ? positions.get(transition.failure) : undefined
        const failed = failure ? <path key={`${transition.name}:failure`} className="failure"
          d={curve({ x: transitionPosition.x + 18, y: transitionPosition.y - 22 }, { x: failure.x, y: failure.y + 23 })}
          markerEnd={`url(#${failureMarkerId})`} /> : null
        return [...entering, outgoing, failed]
      })}
    </g>

    {stableStates.map(state => {
      const position = positions.get(state)!
      const current = state === prop.state
      const ready = state === prop.readyState
      return <g className={`machine-state${current ? ' current' : ''}${ready ? ' ready' : ''}`}
        transform={`translate(${position.x}, ${position.y})`} key={state}>
        <rect x="-53" y="-22" width="106" height="44" rx="11" />
        <text y={ready ? -2 : 5}>{stateLabel(state)}</text>
        {ready && <text className="machine-state-tag" y="13">READY</text>}
      </g>
    })}

    {prop.transitions.map(transition => {
      const position = transitionPositions.get(transition.name)!
      const active = activeTransition === transition.name
      return <g className={`machine-transition${active ? ' active' : ''}`}
        transform={`translate(${position.x}, ${position.y})`} key={transition.name}>
        <rect x="-57" y="-24" width="114" height="48" rx="24" />
        <text y="-2">{stateLabel(transition.name)}</text>
        <text className="machine-transition-phase" y="13">{stateLabel(transition.active)}</text>
      </g>
    })}
  </svg>
}

function PropGraph({ prop }: { prop: PropStatus }) {
  const active = prop.pending
    ?? prop.transitions.find(transition => transition.active === prop.state)
  return <article className="prop-graph">
    <div className="prop-graph-heading">
      <div><h3>{prop.label}</h3><span>{prop.id}</span></div>
      <strong className={active ? 'state-active' : undefined}>
        {prop.pending ? `${stateLabel(prop.pending.name)} · ${prop.pending.phase}` : stateLabel(prop.state)}
      </strong>
    </div>
    <StateMachine prop={prop} />
  </article>
}

function EyeGraph({ screen }: { screen: ScreenStatus }) {
  const markerId = `eye-arrow-${useId().replaceAll(':', '')}`
  const modes = ['sleeping', 'idle', 'alert', 'tipping'] as const
  const positions = statePositions([...modes])
  return <article className="prop-graph eye-state-card">
    <div className="prop-graph-heading">
      <div><h3>Eye</h3><span>{screen.id}</span></div>
      <strong>{stateLabel(screen.state.mode)}</strong>
    </div>
    <svg className="state-machine eye-machine" viewBox={`0 0 ${graphWidth} 112`} role="img"
      aria-label={`Eye: current state ${screen.state.mode}`}>
      <defs>
        <marker id={markerId} viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
          <path d="M 0 0 L 10 5 L 0 10 z" />
        </marker>
      </defs>
      {modes.slice(0, -1).map((mode, index) => {
        const from = positions.get(mode)!
        const to = positions.get(modes[index + 1])!
        return <line className="eye-mode-edge" key={mode} x1={from.x + 53} y1={stableY} x2={to.x - 53} y2={stableY}
          markerEnd={`url(#${markerId})`} />
      })}
      {modes.map(mode => {
        const position = positions.get(mode)!
        return <g className={`machine-state${mode === screen.state.mode ? ' current' : ''}`}
          transform={`translate(${position.x}, ${position.y})`} key={mode}>
          <rect x="-53" y="-22" width="106" height="44" rx="11" />
          <text y="5">{mode}</text>
        </g>
      })}
      <text className="eye-machine-detail" x={graphWidth / 2} y="96" textAnchor="middle">
        gaze {screen.state.gaze.x.toFixed(2)}, {screen.state.gaze.y.toFixed(2)} · {screen.connected ? 'connected' : 'offline'}
      </text>
    </svg>
  </article>
}

export function StateGraph({ props, screens }: { props: PropStatus[]; screens: ScreenStatus[] }) {
  return <section aria-labelledby="state-graph-heading">
    <div className="section-heading-row">
      <div><p className="eyebrow">Live model</p><h2 id="state-graph-heading">Prop states</h2></div>
    </div>
    <div className="prop-graph-grid">
      {props.map(prop => <PropGraph prop={prop} key={prop.id} />)}
      {screens.map(screen => <EyeGraph screen={screen} key={screen.id} />)}
      {!props.length && !screens.length ? <p>No managed props or displays configured.</p> : null}
    </div>
  </section>
}
