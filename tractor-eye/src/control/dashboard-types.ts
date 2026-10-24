export type FlowRole = 'utility' | 'show' | 'reset' | 'stop'
export type RunPhase = 'pending' | 'scheduled' | 'running' | 'complete' | 'failed' | 'skipped'

export type PropTransition = {
  name: string
  from: string[]
  active: string
  to: string
  failure: string
}

export type PropStatus = {
  id: string
  label: string
  state: string
  readyState: string
  states: string[]
  transitions: PropTransition[]
  pending: null | {
    name: string
    phase: 'scheduled' | 'active'
    executeAtMs: number | null
    runId: string
    nodeId: string
  }
}

export type TimingStatus = {
  nodeId: string
  flow: string
  node: string
  role: FlowRole
  defaultAtMs: number
  atMs: number
  after: string[]
  transition: string | null
}

export type RuntimeStatus = {
  state: { mode: 'unmanaged' | 'needs-reset' | 'ready' | 'running' | 'resetting' | 'halted' | 'fault'; props: PropStatus[] }
  log: import('./ActivityLog').ActivityEntry[]
  devices: { link: string; node: string; event: string; commandId: string | null; receivedAtMs: number }[]
  timings: TimingStatus[]
  runs: {
    id: string
    reason: string
    startedAtMs: number
    role: FlowRole
    nodes: {
      id: string
      phase: RunPhase
      detail: string
      offsetMs: number
      after: string[]
      transition: string | null
      executeAtMs: number | null
      startedAtMs: number | null
      finishedAtMs: number | null
    }[]
  }[]
}

export type SystemStatus = {
  startedAtMs: number
  uptimeMs: number
  hostname: string
  wifiSsid: string | null
  brokerRestartAvailable: boolean
  batteryPercent: number | null
  links: { id: string; transport: string; endpoint: string; connected: boolean }[]
}

export type ScreenStatus = {
  id: string
  connected: boolean
  sequence: number
  state: { mode: 'sleeping' | 'idle' | 'alert' | 'tipping'; gaze: { x: number; y: number } }
  clients: { connectionId: string; name: string; connected: boolean; lastAppliedSequence: number | null }[]
}
