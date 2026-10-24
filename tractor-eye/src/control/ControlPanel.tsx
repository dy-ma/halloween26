import { useCallback, useEffect, useRef, useState } from 'react'
import { ActivityLog, type ActivityEntry } from './ActivityLog'
import { DisplayDevices, type DisplayDevice } from './DisplayDevices'
import { AudioDevices } from './AudioDevices'
import { DcDriveControl } from './DcDriveControl'
import { DcCurveTuner } from './DcCurveTuner'
import './control-panel.css'

type ControlDefinition = {
  id: string
  label: string
  kind: 'flow' | 'cue' | 'hold'
  repeatMs: number | null
  pwm: number | null
  rpm: number | null
  strokeSteps: number | null
  strokeProfile: 'quintic' | null
  key: string | null
  group: string | null
  panel: string
  target: string | null
  section: 'show' | 'bench'
}

type AudioOutputDefinition = {
  id: string
}

type ControlManifest = {
  show: string
  runtimeInstance: number
  reloadAvailable: boolean
  controls: ControlDefinition[]
  audioOutputs: AudioOutputDefinition[]
}

type BoardStatus = {
  node: string
  service: string
  link: string
  transport: string
  rssi: number | null
  online: boolean
}

type RuntimeStatus = {
  log: ActivityEntry[]
  devices: { link: string; node: string; event: string; commandId: string | null; receivedAtMs: number }[]
  runs: { id: string; reason: string; startedAtMs: number; nodes: {
    id: string; phase: 'pending' | 'running' | 'complete' | 'failed' | 'skipped'; detail: string
  }[] }[]
}

type ActiveHold = {
  control: ControlDefinition
  timer: number
}

const keyLabel = (key: string) => {
  if (key === 'Space') return 'Space'
  if (key === 'ArrowUp') return '↑'
  if (key === 'ArrowDown') return '↓'
  if (key === 'ArrowLeft') return '←'
  if (key === 'ArrowRight') return '→'
  return key.length === 1 ? key.toUpperCase() : key
}

const normalizedKey = (key: string) => {
  if (key === ' ' || key === 'Spacebar' || key === 'Space') return 'Space'
  return key.length === 1 ? key.toLowerCase() : key
}

const panelTitle = (panel: string) => panel
  .split(/[-_]/)
  .map(part => part.toLowerCase() === 'dc'
    ? 'DC'
    : `${part.charAt(0).toUpperCase()}${part.slice(1)}`)
  .join(' ')

const preferredPanels = ['dc_a', 'dc_b', 'stepper', 'tractor-eye', 'speaker']

export function ControlPanel() {
  const [manifest, setManifest] = useState<ControlManifest | null>(null)
  const [boards, setBoards] = useState<BoardStatus[]>([])
  const [displays, setDisplays] = useState<DisplayDevice[]>([])
  const [displayUnavailable, setDisplayUnavailable] = useState(false)
  const [runtime, setRuntime] = useState<RuntimeStatus>({ devices: [], runs: [], log: [] })
  const [status, setStatus] = useState('Connecting…')
  const [busy, setBusy] = useState<Set<string>>(() => new Set())
  const [reloading, setReloading] = useState(false)
  const [driveLevels, setDriveLevels] = useState<Record<string, number>>({})
  const [stepperSpeeds, setStepperSpeeds] = useState<Record<string, number>>({})
  // Heartbeats read the latest setting without recreating keyboard listeners
  // (whose cleanup releases active holds). Settings never send commands alone.
  const driveLevelsRef = useRef<Record<string, number>>({})
  const stepperSpeedsRef = useRef<Record<string, number>>({})
  const activeHolds = useRef<Map<string, ActiveHold>>(new Map())
  const startingHolds = useRef<Map<string, ControlDefinition>>(new Map())
  const cancelledStarts = useRef<Set<string>>(new Set())

  useEffect(() => {
    const previousTitle = document.title
    document.body.dataset.mode = 'control'
    document.title = 'FX Control'
    return () => {
      delete document.body.dataset.mode
      document.title = previousTitle
    }
  }, [])

  useEffect(() => {
    let active = true
    const loadScreens = async () => {
      try {
        const [screenResponse, runtimeResponse] = await Promise.all([
          fetch('/api/displays', { cache: 'no-store' }),
          fetch('/api/status', { cache: 'no-store' }),
        ])
        if (!screenResponse.ok || !runtimeResponse.ok) throw new Error('Status unavailable')
        const [value, status] = await Promise.all([
          screenResponse.json() as Promise<DisplayDevice[]>,
          runtimeResponse.json() as Promise<RuntimeStatus>,
        ])
        if (active) { setDisplays(value); setRuntime(status); setDisplayUnavailable(false) }
      } catch {
        if (active) setDisplayUnavailable(true)
      }
    }
    void loadScreens()
    const timer = window.setInterval(() => { void loadScreens() }, 1_000)
    return () => {
      active = false
      window.clearInterval(timer)
    }
  }, [])

  useEffect(() => {
    const controller = new AbortController()
    void fetch('/api/control', { cache: 'no-store', signal: controller.signal })
      .then(async response => {
        if (!response.ok) throw new Error(await response.text())
        return response.json() as Promise<ControlManifest>
      })
      .then(value => {
        setManifest(value)
        setStatus('Runtime connected')
      })
      .catch(error => {
        if (!controller.signal.aborted) setStatus(`Runtime unavailable: ${String(error)}`)
      })
    return () => controller.abort()
  }, [])

  useEffect(() => {
    let active = true
    const loadBoards = async () => {
      try {
        const response = await fetch('/api/boards', { cache: 'no-store' })
        if (!response.ok) throw new Error(await response.text())
        const value = await response.json() as { boards: BoardStatus[] }
        if (active) setBoards(value.boards)
      } catch {
        if (active) setBoards([])
      }
    }
    void loadBoards()
    const timer = window.setInterval(() => { void loadBoards() }, 1_000)
    return () => {
      active = false
      window.clearInterval(timer)
    }
  }, [])

  const send = useCallback(async (control: string, phase: 'press' | 'release', parameters?: {
    pwm?: number
    rpm?: number
  }) => {
    const response = await fetch('/api/control', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ control, phase, ...parameters }),
    })
    if (!response.ok) throw new Error(await response.text())
  }, [])

  const reloadShow = async () => {
    if (!manifest || !window.confirm('Stop all activity and restart FX to reload the show configuration?')) return
    setReloading(true)
    setStatus('Stopping activity and reloading show configuration…')
    try {
      const response = await fetch('/api/runtime/reload', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: '{}',
      })
      if (!response.ok) throw new Error(await response.text())
      for (let attempt = 0; attempt < 60; attempt += 1) {
        await new Promise(resolve => window.setTimeout(resolve, 250))
        try {
          const refreshed = await fetch('/api/control', { cache: 'no-store' })
          if (!refreshed.ok) continue
          const next = await refreshed.json() as ControlManifest
          if (next.runtimeInstance !== manifest.runtimeInstance) {
            window.location.reload()
            return
          }
        } catch {
          // The short connection gap is expected while systemd restarts FX.
        }
      }
      throw new Error('FX did not return within 15 seconds')
    } catch (error) {
      setStatus(`Show reload failed: ${String(error)}`)
      setReloading(false)
    }
  }

  const sendHold = useCallback((control: ControlDefinition) => send(control.id, 'press', {
    pwm:
    typeof control.pwm === 'number'
      ? driveLevelsRef.current[control.group ?? control.id] ?? control.pwm
      : undefined,
  }), [send])

  const changeDrive = (group: string, value: number) => {
    driveLevelsRef.current = { ...driveLevelsRef.current, [group]: value }
    setDriveLevels(current => ({ ...current, [group]: value }))
  }

  const changeStepperSpeed = (controlId: string, value: number) => {
    stepperSpeedsRef.current = { ...stepperSpeedsRef.current, [controlId]: value }
    setStepperSpeeds(current => ({ ...current, [controlId]: value }))
  }

  const invoke = useCallback(async (control: ControlDefinition) => {
    if (control.kind === 'hold') return
    setBusy(current => new Set(current).add(control.id))
    try {
      await send(control.id, 'press', typeof control.rpm === 'number' ? {
        rpm: stepperSpeedsRef.current[control.id] ?? control.rpm,
      } : undefined)
      setStatus(`${control.label}: accepted`)
    } catch (error) {
      setStatus(`${control.label}: ${String(error)}`)
    } finally {
      setBusy(current => {
        const next = new Set(current)
        next.delete(control.id)
        return next
      })
    }
  }, [send])

  const releaseHold = useCallback(async (controlId: string) => {
    if (startingHolds.current.has(controlId)) {
      cancelledStarts.current.add(controlId)
      return
    }
    const active = activeHolds.current.get(controlId)
    if (!active) return
    activeHolds.current.delete(controlId)
    window.clearInterval(active.timer)
    setBusy(current => {
      const next = new Set(current)
      next.delete(controlId)
      return next
    })
    try {
      await send(controlId, 'release')
      setStatus(`${active.control.label}: stopped`)
    } catch (error) {
      setStatus(`Stop command failed: ${String(error)}`)
    }
  }, [send])

  const releaseAll = useCallback(() => {
    const controlIds = new Set([
      ...activeHolds.current.keys(),
      ...startingHolds.current.keys(),
    ])
    for (const controlId of controlIds) void releaseHold(controlId)
  }, [releaseHold])

  const startHold = useCallback(async (control: ControlDefinition) => {
    if (control.kind !== 'hold' || activeHolds.current.has(control.id)
      || startingHolds.current.has(control.id)) return
    if (control.group) {
      const activeConflicts = [...activeHolds.current.entries()]
        .filter(([, active]) => active.control.group === control.group)
        .map(([controlId]) => controlId)
      const startingConflicts = [...startingHolds.current.entries()]
        .filter(([, starting]) => starting.group === control.group)
        .map(([controlId]) => controlId)
      await Promise.all([...activeConflicts, ...startingConflicts].map(releaseHold))
    }
    const repeatMs = control.repeatMs ?? 100
    startingHolds.current.set(control.id, control)
    try {
      await sendHold(control)
      if (cancelledStarts.current.delete(control.id)) {
        await send(control.id, 'release')
        return
      }
      const timer = window.setInterval(() => {
        void sendHold(control).catch(() => {
          setStatus('Jog heartbeat failed')
          void releaseHold(control.id)
        })
      }, repeatMs)
      activeHolds.current.set(control.id, { control, timer })
      setBusy(current => new Set(current).add(control.id))
      setStatus(`${control.label}: running`)
    } catch (error) {
      setStatus(`${control.label}: ${String(error)}`)
    } finally {
      startingHolds.current.delete(control.id)
      cancelledStarts.current.delete(control.id)
    }
  }, [releaseHold, send, sendHold])

  useEffect(() => {
    const controlsByKey = new Map(
      (manifest?.controls ?? [])
        .filter(control => control.key)
        .map(control => [normalizedKey(control.key!), control]),
    )
    const isEditable = (target: EventTarget | null) => target instanceof HTMLElement
      && (target.isContentEditable || ['INPUT', 'SELECT', 'TEXTAREA'].includes(target.tagName))
    const keyDown = (event: KeyboardEvent) => {
      if (event.defaultPrevented || event.repeat || isEditable(event.target)) return
      const control = controlsByKey.get(normalizedKey(event.key))
      if (!control) return
      event.preventDefault()
      if (control.kind === 'hold') void startHold(control)
      else void invoke(control)
    }
    const keyUp = (event: KeyboardEvent) => {
      const control = controlsByKey.get(normalizedKey(event.key))
      if (!control || control.kind !== 'hold') return
      event.preventDefault()
      void releaseHold(control.id)
    }
    const visibilityChange = () => {
      if (document.hidden) releaseAll()
    }
    window.addEventListener('keydown', keyDown)
    window.addEventListener('keyup', keyUp)
    window.addEventListener('blur', releaseAll)
    document.addEventListener('visibilitychange', visibilityChange)
    return () => {
      window.removeEventListener('keydown', keyDown)
      window.removeEventListener('keyup', keyUp)
      window.removeEventListener('blur', releaseAll)
      document.removeEventListener('visibilitychange', visibilityChange)
      releaseAll()
    }
  }, [invoke, manifest, releaseAll, releaseHold, startHold])

  const flows = manifest?.controls.filter(control => control.section === 'show') ?? []
  const bench = manifest?.controls.filter(control => control.section === 'bench' && !control.id.startsWith('display/')
    && !manifest.audioOutputs.some(output => output.id === control.panel)) ?? []
  const benchPanels = [...new Set([
    ...bench.map(control => control.panel),
  ])].sort((left, right) => {
    const leftIndex = preferredPanels.indexOf(left)
    const rightIndex = preferredPanels.indexOf(right)
    if (leftIndex === -1 && rightIndex === -1) return left.localeCompare(right)
    if (leftIndex === -1) return 1
    if (rightIndex === -1) return -1
    return leftIndex - rightIndex
  })
  const curveMotors = [...new Map(bench
    .filter(control => typeof control.pwm === 'number' && control.group)
    .map(control => [control.group!, {
      id: control.group!,
      label: panelTitle(control.panel),
    }])).values()]
  const stopControl = manifest?.controls.find(control => control.id === 'stop_all')?.id ?? null
  const curveSteppers = bench.filter(control => typeof control.rpm === 'number' && typeof control.strokeSteps === 'number')
    .map(control => ({ id: control.id, label: control.label, rpm: control.rpm!, steps: control.strokeSteps!, profile: control.strokeProfile ?? null }))

  const panelStatus = (controls: ControlDefinition[]) => {
    if (controls.some(control => busy.has(control.id))) {
      return { label: 'Running', tone: 'active' }
    }
    const targets = new Set(controls.flatMap(control => control.target ? [control.target] : []))
    if (targets.size) {
      const matching = boards.filter(board => targets.has(board.node))
      if (!matching.length) return { label: 'Not discovered', tone: 'offline' }
      if (matching.some(board => board.online)) {
        const rssi = matching.find(board => board.online && board.rssi !== null)?.rssi
        return { label: rssi === undefined ? 'Online' : `Online · ${rssi} dBm`, tone: 'online' }
      }
      return { label: 'Offline', tone: 'offline' }
    }
    return { label: 'Ready', tone: 'neutral' }
  }

  const controlButton = (control: ControlDefinition) => (
    <button
      className={control.kind === 'hold' ? 'hold-button' : undefined}
      data-active={busy.has(control.id)}
      disabled={control.kind !== 'hold' && busy.has(control.id)}
      key={control.id}
      onClick={() => void invoke(control)}
      onKeyDown={event => {
        if (control.kind === 'hold' && !event.repeat
          && (event.key === ' ' || event.key === 'Enter')) {
          event.preventDefault()
          void startHold(control)
        }
      }}
      onKeyUp={event => {
        if (control.kind === 'hold' && (event.key === ' ' || event.key === 'Enter')) {
          event.preventDefault()
          void releaseHold(control.id)
        }
      }}
      onPointerDown={event => {
        if (control.kind === 'hold') {
          event.preventDefault()
          event.currentTarget.setPointerCapture(event.pointerId)
          void startHold(control)
        }
      }}
      onPointerUp={event => {
        if (control.kind === 'hold') {
          event.preventDefault()
          void releaseHold(control.id)
        }
      }}
      onPointerCancel={() => {
        if (control.kind === 'hold') void releaseHold(control.id)
      }}
      type="button"
    >
      {control.label}
      {(control.kind === 'hold' || control.key) && (
        <small>
          {control.kind === 'hold' ? 'Hold to run' : 'Press'}
          {control.key ? ` · ${keyLabel(control.key)}` : ''}
        </small>
      )}
    </button>
  )

  return (
    <main className="control-shell">
      <header>
        <div>
          <h1>FX Control</h1>
          <p>{manifest?.show ?? 'Loading show…'}</p>
        </div>
        <div className="runtime-actions">
          <p className="runtime-status" role="status">{status}</p>
          {manifest?.reloadAvailable && <button type="button" disabled={reloading}
            onClick={() => void reloadShow()}>{reloading ? 'Reloading…' : 'Reload show'}</button>}
        </div>
      </header>

      <section aria-labelledby="boards-heading">
        <h2 id="boards-heading">Boards</h2>
        <div className="board-table-wrap">
          <table>
            <thead>
              <tr><th>Status</th><th>Service</th><th>Node ID</th><th>Connection</th><th>RSSI</th><th>Assembly report</th></tr>
            </thead>
            <tbody>
              {boards.map(board => (
                <tr key={`${board.link}:${board.node}`}>
                  <td><span className={`board-dot ${board.online ? 'online' : ''}`} />{board.online ? 'Online' : 'Offline'}</td>
                  <td>{board.service}</td>
                  <td><code>{board.node}</code></td>
                  <td>{board.transport} / {board.link}</td>
                  <td>{board.rssi === null ? '—' : `${board.rssi} dBm`}</td>
                  <td>{runtime.devices.find(device => device.link === board.link && device.node === board.node)?.event ?? '—'}</td>
                </tr>
              ))}
              {!boards.length && <tr><td colSpan={6}>No boards discovered.</td></tr>}
            </tbody>
          </table>
        </div>
        <p className="status-note">Online is live discovery. Assembly reports describe what the firmware observed; a delivery acknowledgment alone does not confirm motion or position.</p>
      </section>

      <DisplayDevices devices={displays} unavailable={displayUnavailable}
        onForgot={id => setDisplays(current => current.filter(device => device.id !== id))} />

      <AudioDevices />

      <DcCurveTuner motors={curveMotors} steppers={curveSteppers} stopControl={stopControl} displays={displays} displayUnavailable={displayUnavailable} />

      <ActivityLog entries={runtime.log ?? []} />

      <section aria-labelledby="show-controls">
        <h2 id="show-controls">Show</h2>
        <div className="control-grid">
          {flows.map(controlButton)}
          {!flows.length && <p>No show controls configured.</p>}
        </div>
      </section>

      <section aria-labelledby="bench-controls">
        <h2 id="bench-controls">Bench</h2>
        <div className="bench-grid">
          {benchPanels.map(panel => {
            const controls = bench.filter(control => control.panel === panel)
            const panelState = panelStatus(controls)
            const driveControls = [...new Map(controls
              .filter(control => typeof control.pwm === 'number')
              .map(control => [control.group ?? control.id, control])).entries()]
            return (
              <article className="bench-panel" key={panel}>
                <div className="panel-heading">
                  <h3>{panelTitle(panel)}</h3>
                  <span className={`panel-status ${panelState.tone}`}>
                    <span className="board-dot" />{panelState.label}
                  </span>
                </div>
                {driveControls.map(([group, control]) => (
                  <DcDriveControl key={group} value={driveLevels[group] ?? control.pwm!}
                    onChange={value => changeDrive(group, value)} />
                ))}
                {controls.filter(control => typeof control.rpm === 'number').map(control => {
                  const rpm = stepperSpeeds[control.id] ?? control.rpm!
                  return <div className="stepper-speed" key={`${control.id}/speed`}>
                    <div className="dc-drive-heading">
                      <label htmlFor={`${control.id}-rpm`}>Stroke speed</label>
                      <output htmlFor={`${control.id}-rpm`}>{rpm} RPM</output>
                    </div>
                    <input id={`${control.id}-rpm`} type="range" min="10" max="120" step="5"
                      value={rpm} aria-valuetext={`${rpm} revolutions per minute`}
                      onChange={event => changeStepperSpeed(control.id, Number(event.currentTarget.value))} />
                    <div className="dc-presets" aria-label="Stepper speed presets">
                      {[30, 60, 90, 120].map(preset => <button key={preset} type="button"
                        aria-pressed={rpm === preset}
                        onClick={() => changeStepperSpeed(control.id, preset)}>{preset}</button>)}
                    </div>
                  </div>
                })}
                <div className="control-grid panel-controls">
                  {controls.map(controlButton)}
                </div>
              </article>
            )
          })}
          {!benchPanels.length && <p>No bench controls configured.</p>}
        </div>
      </section>

    </main>
  )
}
