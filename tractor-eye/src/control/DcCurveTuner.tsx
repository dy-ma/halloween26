import { useCallback, useEffect, useRef, useState } from 'react'
import type { DisplayDevice } from './DisplayDevices'
import { wakeMilestones, wakeTiming } from '../sources/wake-timing'
import { stepperTiming, stepperSpeedAt, type StepperStroke } from './stepper-timing'
import type { RuntimeStatus, ScreenStatus } from './dashboard-types'

export type DcCurveMotor = {
  id: string
  label: string
}

type Track = {
  id: string
  label: string
  available: boolean
  durationMs: number | null
}

type Output = {
  id: string
  label: string
  ready: boolean
}

type AudioStatus = {
  tracks: Track[]
  outputs: Output[]
}

type Draft = {
  motor: string
  direction: 'forward' | 'reverse'
  peakPwmPercent: number
  minimumPwmPercent: number
  rampMs: number
  holdMs: number
  fadeMs: number
  motorDelayMs: number
  track: string
  output: string
  eyeDevice: string
  wakeDelayMs: number
  playAudio: boolean
  playMotor: boolean
  playEye: boolean
  playStepper: boolean
  stepperControl: string
  stepperRpm: number
  stepperDelayMs: number
}

type ShowPresetNode = { nodeId: string; atMs: number; cue: string | null }
type ShowPreset = { version: 1; name: string; nodes: ShowPresetNode[] }
type ShowPresetLibrary = { active: string; presets: ShowPreset[] }

const storageKey = 'fx.dc-curve-tuner.v1'
const defaultDraft: Draft = {
  motor: '',
  direction: 'forward',
  peakPwmPercent: 85,
  minimumPwmPercent: 20,
  rampMs: 300,
  holdMs: 700,
  fadeMs: 2_200,
  motorDelayMs: 0,
  track: '',
  output: '',
  eyeDevice: '',
  wakeDelayMs: 750,
  playAudio: true,
  playMotor: true,
  playEye: false,
  playStepper: false,
  stepperControl: '',
  stepperRpm: 60,
  stepperDelayMs: 0,
}

const loadDraft = (): Draft => {
  try {
    const stored = localStorage.getItem(storageKey)
    const saved = stored ? JSON.parse(stored) as Partial<Draft> | null : null
    return saved ? {
      ...defaultDraft, ...saved,
      playAudio: typeof saved.playAudio === 'boolean' ? saved.playAudio : true,
      playMotor: typeof saved.playMotor === 'boolean' ? saved.playMotor : true,
      playEye: typeof saved.playEye === 'boolean' ? saved.playEye : Boolean(saved.eyeDevice),
      playStepper: typeof saved.playStepper === 'boolean' ? saved.playStepper : false,
    } : defaultDraft
  } catch {
    return defaultDraft
  }
}

const clamp = (value: number, low: number, high: number) => Math.min(high, Math.max(low, value))
const smoothstep = (value: number) => {
  const x = clamp(value, 0, 1)
  return x * x * x * (x * (x * 6 - 15) + 10)
}
const percentToDuty = (percent: number) => Math.round(clamp(percent, 0, 100) * 255 / 100)

const curvePercentAt = (draft: Draft, elapsedMs: number) => {
  if (elapsedMs < 0) return 0
  if (elapsedMs < draft.rampMs) return draft.peakPwmPercent * smoothstep(elapsedMs / draft.rampMs)
  const fadeStart = draft.rampMs + draft.holdMs
  if (elapsedMs < fadeStart) return draft.peakPwmPercent
  if (elapsedMs < fadeStart + draft.fadeMs) {
    const progress = smoothstep((elapsedMs - fadeStart) / draft.fadeMs)
    return draft.peakPwmPercent + (draft.minimumPwmPercent - draft.peakPwmPercent) * progress
  }
  return 0
}

function CurveGraph({ draft, trackDurationMs, playheadMs, stepper }: {
  draft: Draft
  trackDurationMs: number
  playheadMs: number | null
  stepper: StepperStroke | undefined
}) {
  const motorDuration = draft.rampMs + draft.holdMs + draft.fadeMs
  const milestones = draft.eyeDevice ? wakeMilestones(draft.wakeDelayMs) : []
  const stroke = stepper ? stepperTiming(stepper.steps, draft.stepperRpm, stepper.profile) : null
  const timelineDuration = Math.max(1, draft.motorDelayMs + motorDuration, trackDurationMs,
    stroke ? draft.stepperDelayMs + stroke.durationMs : 0,
    ...milestones.map(marker => marker.timeMs))
  const plotLeft = 48
  const plotTop = 16
  const plotWidth = 724
  const plotHeight = 174
  const point = (time: number, percent: number) => `${plotLeft + time / timelineDuration * plotWidth},${plotTop + (100 - percent) / 100 * plotHeight}`
  const curvePoints = Array.from({ length: 81 }, (_, index) => {
    const elapsed = motorDuration * index / 80
    const percent = index === 80 ? draft.minimumPwmPercent : curvePercentAt(draft, elapsed)
    return point(draft.motorDelayMs + elapsed, percent)
  }).join(' ')
  const playheadX = playheadMs === null ? null : plotLeft + clamp(playheadMs / timelineDuration, 0, 1) * plotWidth
  const strokePoints = stroke ? Array.from({ length: 101 }, (_, i) => {
    const elapsed = stroke.durationMs * i / 100
    return `${plotLeft + (draft.stepperDelayMs + elapsed) / timelineDuration * plotWidth},${320 - stepperSpeedAt(elapsed, draft.stepperRpm, stroke) / 120 * 58}`
  }).join(' ') : ''

  return <figure className="dc-curve-figure">
    <svg viewBox={`0 0 800 ${stroke ? 356 : 276}`} role="img" aria-label="DC PWM, stepper RPM, audio, and eye wake timing">
      <line className="curve-axis" x1={plotLeft} y1={plotTop} x2={plotLeft} y2={plotTop + plotHeight} />
      <line className="curve-axis" x1={plotLeft} y1={plotTop + plotHeight} x2={plotLeft + plotWidth} y2={plotTop + plotHeight} />
      {[0, 50, 100].map(percent => <g key={percent}>
        <line className="curve-grid" x1={plotLeft} y1={plotTop + (100 - percent) / 100 * plotHeight}
          x2={plotLeft + plotWidth} y2={plotTop + (100 - percent) / 100 * plotHeight} />
        <text x={plotLeft - 8} y={plotTop + (100 - percent) / 100 * plotHeight + 4} textAnchor="end">{percent}%</text>
      </g>)}
      <g className={draft.playMotor ? undefined : 'curve-muted'}>
      <polyline className="curve-line" points={curvePoints} />
      <line className="curve-stop" x1={plotLeft + (draft.motorDelayMs + motorDuration) / timelineDuration * plotWidth}
        y1={plotTop + (100 - draft.minimumPwmPercent) / 100 * plotHeight}
        x2={plotLeft + (draft.motorDelayMs + motorDuration) / timelineDuration * plotWidth}
        y2={plotTop + plotHeight} />
      </g>
      {trackDurationMs > 0 && <rect className={`audio-timeline${draft.playAudio ? '' : ' curve-muted'}`} x={plotLeft} y={210}
        width={Math.min(1, trackDurationMs / timelineDuration) * plotWidth} height={10} rx={5} />}
      <g className={draft.playEye ? undefined : 'curve-muted'}>
      {draft.eyeDevice && <rect className="eye-timeline"
        x={plotLeft + draft.wakeDelayMs / timelineDuration * plotWidth} y={232}
        width={(wakeTiming.tipDelayMs + wakeTiming.tipDurationMs) / timelineDuration * plotWidth} height={8} rx={4} />}
      {milestones.filter(marker => marker.kind !== 'open').map(marker => {
        const x = plotLeft + marker.timeMs / timelineDuration * plotWidth
        return <g key={marker.kind} className={`eye-marker eye-marker--${marker.kind}`}>
          <title>{marker.label}: {(marker.timeMs / 1000).toFixed(2)}s</title>
          <line x1={x} y1={plotTop} x2={x} y2={242} />
          <text x={x > plotLeft + plotWidth - 100 ? x - 5 : x + 5} y={marker.kind === 'wake' ? 32 : 52}
            textAnchor={x > plotLeft + plotWidth - 100 ? 'end' : 'start'}>{marker.label}</text>
        </g>
      })}
      </g>
      {stroke && <g className={draft.playStepper ? undefined : 'curve-muted'}>
        <line className="curve-grid" x1={plotLeft} x2={plotLeft + plotWidth} y1={320} y2={320} />
        <text x={plotLeft} y={258}>stepper · {draft.stepperRpm} RPM peak{draft.playStepper ? '' : ' (off)'}</text>
        <polyline className="stepper-curve" points={strokePoints} />
      </g>}
      {playheadX !== null && <line className="curve-playhead" x1={playheadX} y1={plotTop} x2={playheadX} y2={stroke ? 324 : 242} />}
      <text x={plotLeft} y={stroke ? 348 : 268}>0s</text>
      <text x={plotLeft + plotWidth} y={stroke ? 348 : 268} textAnchor="end">{(timelineDuration / 1000).toFixed(2)}s</text>
      {trackDurationMs > 0 && <text x={plotLeft} y={207}>audio{draft.playAudio ? '' : ' (off)'}</text>}
      {draft.eyeDevice && <text x={plotLeft} y={239}>eye{draft.playEye ? '' : ' (off)'}</text>}
    </svg>
    {milestones.length > 0 && <figcaption className="eye-timing-legend">
      {milestones.map(marker => <span key={marker.kind}>{marker.label} <strong>{(marker.timeMs / 1000).toFixed(2)}s</strong></span>)}
    </figcaption>}
    {stroke && <figcaption>Stepper: {(draft.stepperDelayMs / 1000).toFixed(2)}s → {((draft.stepperDelayMs + stroke.durationMs) / 1000).toFixed(2)}s · estimated {(stroke.durationMs / 1000).toFixed(3)}s {stepper?.profile === 'quintic' ? 'including S-curve ramps' : '(legacy profile may differ)'}</figcaption>}
  </figure>
}

export function DcCurveTuner({ motors, steppers, stopControl, showControl, resetControl, displays, runtime, screens }: {
  motors: DcCurveMotor[]
  steppers: StepperStroke[]
  stopControl: string | null
  showControl: string | null
  resetControl: string | null
  displays: DisplayDevice[]
  runtime: RuntimeStatus
  screens: ScreenStatus[]
}) {
  const [draft, setDraft] = useState<Draft>(loadDraft)
  const [audio, setAudio] = useState<AudioStatus | null>(null)
  const [status, setStatus] = useState('')
  const [busy, setBusy] = useState(false)
  const [library, setLibrary] = useState<ShowPresetLibrary | null>(null)
  const [presetName, setPresetName] = useState('default')
  const [playheadMs, setPlayheadMs] = useState<number | null>(null)
  const firstDisplayId = displays[0]?.id
  const isPreviewing = playheadMs !== null
  const runStartedAt = useRef<number | null>(null)
  const runDurationMs = useRef(0)

  const motor = motors.some(item => item.id === draft.motor) ? draft.motor : motors[0]?.id ?? ''
  const tracks = audio?.tracks.filter(track => track.available) ?? []
  const outputs = audio?.outputs.filter(output => output.ready) ?? []
  const track = tracks.some(item => item.id === draft.track) ? draft.track : tracks[0]?.id ?? ''
  const output = outputs.some(item => item.id === draft.output) ? draft.output : outputs[0]?.id ?? ''
  const selectedTrack = tracks.find(item => item.id === track)
  const stepperControl = steppers.some(item => item.id === draft.stepperControl) ? draft.stepperControl : steppers[0]?.id ?? ''
  const selectedStepper = steppers.find(item => item.id === stepperControl)
  const strokeTiming = selectedStepper ? stepperTiming(selectedStepper.steps, draft.stepperRpm, selectedStepper.profile) : null
  const motorDuration = draft.rampMs + draft.holdMs + draft.fadeMs
  const error = draft.peakPwmPercent < 1 || draft.peakPwmPercent > 100
    ? 'Peak PWM must be 1–100%.'
    : draft.minimumPwmPercent < 0 || draft.minimumPwmPercent > draft.peakPwmPercent
      ? 'Final PWM must be between 0% and the peak.'
      : draft.rampMs < 50 || draft.rampMs > 9_999 || draft.fadeMs < 50 || draft.fadeMs > 9_999
        ? 'Ramp and fade must each be 50–9,999 ms.'
        : draft.holdMs < 0 || draft.holdMs > 9_999 || motorDuration > 20_000
          ? 'Hold must be 0–9,999 ms and total motor time at most 20 s.'
          : draft.motorDelayMs < 0 || draft.motorDelayMs > 10_000
            ? 'Motor delay must be 0–10,000 ms.'
            : ''
  const cue = `dc:c:${draft.direction === 'forward' ? 'f' : 'r'}:${percentToDuty(draft.peakPwmPercent)}:${percentToDuty(draft.minimumPwmPercent)}:${draft.rampMs}:${draft.holdMs}:${draft.fadeMs}`
  const stepperError = !selectedStepper ? 'Choose a configured stepper stroke.'
    : !strokeTiming ? 'Stepper speed must be 10–120 RPM.'
      : !Number.isInteger(draft.stepperDelayMs) || draft.stepperDelayMs < 0 || draft.stepperDelayMs > 10_000
        ? 'Stepper delay must be 0–10,000 ms.' : ''
  const playbackError = error || (steppers.length ? stepperError : '')

  const applyPreset = useCallback((preset: ShowPreset) => {
    const motorNode = preset.nodes.find(node => node.cue?.startsWith('dc:c:'))
    const stepperNode = preset.nodes.find(node => node.cue?.startsWith('step:'))
    const eyeNode = preset.nodes.find(node => node.nodeId.endsWith('/wake-eye'))
    const motorParts = motorNode?.cue?.split(':') ?? []
    const stepperParts = stepperNode?.cue?.split(':') ?? []
    setDraft(current => ({
      ...current,
      eyeDevice: current.eyeDevice || firstDisplayId || 'tractor-eye',
      playAudio: preset.nodes.some(node => node.nodeId.endsWith('/tractor-audio')),
      playMotor: Boolean(motorNode),
      playEye: Boolean(eyeNode),
      playStepper: Boolean(stepperNode),
      motorDelayMs: motorNode?.atMs ?? current.motorDelayMs,
      wakeDelayMs: eyeNode?.atMs ?? current.wakeDelayMs,
      stepperDelayMs: stepperNode?.atMs ?? current.stepperDelayMs,
      direction: motorParts[2] === 'r' ? 'reverse' : 'forward',
      peakPwmPercent: motorParts[3] ? Math.round(Number(motorParts[3]) * 100 / 255) : current.peakPwmPercent,
      minimumPwmPercent: motorParts[4] ? Math.round(Number(motorParts[4]) * 100 / 255) : current.minimumPwmPercent,
      rampMs: motorParts[5] ? Number(motorParts[5]) : current.rampMs,
      holdMs: motorParts[6] ? Number(motorParts[6]) : current.holdMs,
      fadeMs: motorParts[7] ? Number(motorParts[7]) : current.fadeMs,
      stepperRpm: stepperParts[3] ? Number(stepperParts[3]) : current.stepperRpm,
    }))
    setPresetName(preset.name)
  }, [firstDisplayId])

  const loadLibrary = useCallback(async () => {
    const response = await fetch('/api/show-presets', { cache: 'no-store' })
    if (!response.ok) throw new Error(await response.text())
    const value = await response.json() as ShowPresetLibrary
    setLibrary(value)
    const active = value.presets.find(preset => preset.name === value.active)
    if (active) applyPreset(active)
  }, [applyPreset])

  useEffect(() => {
    try {
      localStorage.setItem(storageKey, JSON.stringify({ ...draft, motor, track, output, stepperControl }))
    } catch {
      // Private browsing or a locked-down kiosk may deny storage; tuning still works.
    }
  }, [draft, motor, output, track, stepperControl])

  useEffect(() => {
    // Preset state arrives asynchronously from the controller.
    // eslint-disable-next-line react/set-state-in-effect
    void loadLibrary().catch(loadError => setStatus(`Show library unavailable: ${String(loadError)}`))
  }, [loadLibrary])

  useEffect(() => {
    const controller = new AbortController()
    let timer: ReturnType<typeof setTimeout> | undefined
    const poll = async () => {
      try {
        const response = await fetch('/api/audio', { cache: 'no-store', signal: controller.signal })
        if (!response.ok) throw new Error(await response.text())
        setAudio(await response.json() as AudioStatus)
      } catch (fetchError) {
        if (!controller.signal.aborted) setStatus(`Audio unavailable: ${String(fetchError)}`)
      } finally {
        if (!controller.signal.aborted) timer = setTimeout(() => { void poll() }, 2_000)
      }
    }
    void poll()
    return () => { controller.abort(); clearTimeout(timer) }
  }, [])

  useEffect(() => {
    if (!isPreviewing) return
    const timer = window.setInterval(() => {
      const elapsed = Date.now() - (runStartedAt.current ?? Date.now())
      if (elapsed >= runDurationMs.current) {
        setPlayheadMs(null)
        runStartedAt.current = null
      } else {
        setPlayheadMs(elapsed)
      }
    }, 50)
    return () => window.clearInterval(timer)
  }, [isPreviewing])

  const numberChange = (field: keyof Draft, value: string) => {
    setDraft(current => ({ ...current, [field]: Number(value) }))
  }

  const currentPreset = (): ShowPreset => {
    const basis = library?.presets.find(preset => preset.name === library.active)
      ?? library?.presets[0]
    const nodes = (basis?.nodes ?? []).map(node => {
      if (node.cue?.startsWith('dc:c:')) return { ...node, atMs: draft.motorDelayMs, cue }
      if (node.cue?.startsWith('step:')) {
        const parts = node.cue.split(':')
        return { ...node, atMs: draft.stepperDelayMs, cue: `${parts.slice(0, 3).join(':')}:${draft.stepperRpm}` }
      }
      if (node.nodeId.endsWith('/wake-eye')) return { ...node, atMs: draft.wakeDelayMs }
      return node
    })
    return { version: 1, name: presetName.trim(), nodes }
  }

  const save = async () => {
    if (playbackError) throw new Error(playbackError)
    const response = await fetch('/api/show-presets', {
      method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(currentPreset()),
    })
    if (!response.ok) throw new Error(await response.text())
    const value = await response.json() as ShowPresetLibrary
    setLibrary(value)
    setStatus(`Saved and activated ${presetName}.`)
  }

  const run = async (startedAt: number) => {
    if (!showControl || playbackError) return
    setBusy(true)
    try {
      await save()
      const response = await fetch('/api/control', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ control: showControl, phase: 'press' }),
      })
      if (!response.ok) throw new Error(await response.text())
      runStartedAt.current = startedAt
      runDurationMs.current = Math.max(draft.motorDelayMs + motorDuration,
        draft.wakeDelayMs + wakeTiming.tipDelayMs + wakeTiming.tipDurationMs,
        draft.stepperDelayMs + (strokeTiming?.durationMs ?? 0), selectedTrack?.durationMs ?? 0)
      setPlayheadMs(0)
      setStatus(`Running ${presetName} through the show state machine.`)
    } catch (runError) {
      setStatus(`Show failed: ${String(runError)}`)
    } finally {
      setBusy(false)
    }
  }

  const invoke = async (control: string | null, success: string) => {
    if (!control) return
    setBusy(true)
    try {
      const response = await fetch('/api/control', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ control, phase: 'press' }) })
      if (!response.ok) throw new Error(await response.text())
      setStatus(success)
    } catch (actionError) {
      setStatus(String(actionError))
    } finally { setBusy(false) }
  }

  const stop = async () => {
    if (!stopControl) return
    setBusy(true)
    try {
      const response = await fetch('/api/control', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ control: stopControl, phase: 'press' }),
      })
      if (!response.ok) throw new Error(await response.text())
      setPlayheadMs(null)
      runStartedAt.current = null
      setStatus('All motion and audio stopped.')
    } catch (stopError) {
      setStatus(`Stop failed: ${String(stopError)}`)
    } finally {
      setBusy(false)
    }
  }

  if (!motors.length) return null

  const eye = screens.find(screen => screen.id === 'tractor-eye') ?? screens[0]

  return <section aria-labelledby="dc-curve-heading" className="show-studio">
    <div className="dc-curve-heading">
      <div><p className="eyebrow">Authoritative choreography</p><h2 id="dc-curve-heading">Studio</h2></div>
      {status && <output className="runtime-status" aria-live="polite">{status}</output>}
    </div>
    <div className="studio-layout">
      <aside className="show-library" aria-label="Saved shows">
        <h3>Shows</h3>
        <div className="show-library-list">{library?.presets.map(preset => <button type="button" key={preset.name}
          className={library.active === preset.name ? 'active' : ''}
          onClick={() => {
            void fetch(`/api/show-presets/${encodeURIComponent(preset.name)}/activate`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: '{}' })
              .then(async response => { if (!response.ok) throw new Error(await response.text()); return response.json() as Promise<ShowPresetLibrary> })
              .then(value => { setLibrary(value); applyPreset(preset); setStatus(`Activated ${preset.name}.`) })
              .catch(activateError => setStatus(String(activateError)))
          }}>{preset.name}<small>{library.active === preset.name ? 'active' : 'saved'}</small></button>)}</div>
        <label>Name<input value={presetName} maxLength={64} onChange={event => setPresetName(event.target.value.replace(/[^A-Za-z0-9_-]/g, ''))} /></label>
        <button type="button" className="save-show" disabled={busy || Boolean(playbackError) || !presetName} onClick={() => void save().catch(saveError => setStatus(String(saveError)))}>Save</button>
      </aside>
      <div className="studio-editor">
      <div className="dc-curve-controls">
        <label>DC motor<select value={motor} onChange={event => setDraft(current => ({ ...current, motor: event.target.value }))}>
          {motors.map(item => <option key={item.id} value={item.id}>{item.label}</option>)}
        </select></label>
        <label>Direction<select value={draft.direction} onChange={event => setDraft(current => ({ ...current, direction: event.target.value as Draft['direction'] }))}>
          <option value="forward">Forward</option><option value="reverse">Reverse</option>
        </select></label>
        <label>Peak PWM<input type="number" min={1} max={100} value={draft.peakPwmPercent}
          onChange={event => numberChange('peakPwmPercent', event.target.value)} /><span>%</span></label>
        <label>Final PWM<input type="number" min={0} max={100} value={draft.minimumPwmPercent}
          onChange={event => numberChange('minimumPwmPercent', event.target.value)} /><span>%</span></label>
        <label>Ramp<input type="number" min={50} max={9999} step={50} value={draft.rampMs}
          onChange={event => numberChange('rampMs', event.target.value)} /><span>ms</span></label>
        <label>Hold<input type="number" min={0} max={9999} step={50} value={draft.holdMs}
          onChange={event => numberChange('holdMs', event.target.value)} /><span>ms</span></label>
        <label>Fade<input type="number" min={50} max={9999} step={50} value={draft.fadeMs}
          onChange={event => numberChange('fadeMs', event.target.value)} /><span>ms</span></label>
        <label>Motor delay<input type="number" min={0} max={10000} step={50} value={draft.motorDelayMs}
          onChange={event => numberChange('motorDelayMs', event.target.value)} /><span>ms</span></label>
        {steppers.length > 0 && <>
          <label className="dc-curve-wide">Stepper stroke<select value={stepperControl}
            onChange={event => setDraft(current => ({ ...current, stepperControl: event.target.value }))}>
            {steppers.map(item => <option key={item.id} value={item.id}>{item.label}</option>)}
          </select></label>
          <label>Stroke speed<input type="number" min={10} max={120} step={1} value={draft.stepperRpm}
            onChange={event => numberChange('stepperRpm', event.target.value)} /><span>RPM</span></label>
          <label>Stepper delay<input type="number" min={0} max={10000} step={50} value={draft.stepperDelayMs}
            onChange={event => numberChange('stepperDelayMs', event.target.value)} /><span>ms from Play</span></label>
          <input className="dc-curve-wide" type="range" aria-label="Stroke speed" min={10} max={120} step={1}
            value={draft.stepperRpm} onChange={event => numberChange('stepperRpm', event.target.value)} />
          <p className="dc-curve-wide eye-timing-note">{selectedStepper?.steps.toLocaleString()} microsteps · configured direction and distance. Speed changes keep the firmware’s existing ramps.</p>
        </>}
        <label className="dc-curve-wide">Eye wake delay<input type="number" min={0} max={10000} step={50}
            value={draft.wakeDelayMs} onChange={event => numberChange('wakeDelayMs', event.target.value)} /><span>ms from Play</span></label>
          <input className="dc-curve-wide" type="range" aria-label="Eye wake delay" min={0} max={10000} step={50}
            value={draft.wakeDelayMs} onChange={event => numberChange('wakeDelayMs', event.target.value)} />
      </div>
      <div>
        <CurveGraph draft={{ ...draft, motor, track, output, stepperControl }} stepper={selectedStepper} trackDurationMs={selectedTrack?.durationMs ?? 0} playheadMs={playheadMs} />
        <div className="dc-curve-summary">
          <span>DC motor {(motorDuration / 1000).toFixed(2)}s</span>
          <code>{cue}</code>
        </div>
        {playbackError && <p className="dc-curve-error" role="alert">{playbackError}</p>}
        <div className="dc-curve-actions">
          <button type="button" disabled={busy || Boolean(playbackError) || runtime.state.mode !== 'ready'} onClick={() => void run(Date.now())}>Play show</button>
          <button type="button" disabled={busy || !resetControl || ['running', 'resetting'].includes(runtime.state.mode)} onClick={() => void invoke(resetControl, 'Reset started.')}>Reset</button>
          <button type="button" className="stop-button" disabled={!stopControl} onClick={() => void stop()}>Stop all</button>
        </div>
      </div>
      </div>
      <aside className="studio-live" aria-label="Live state">
        <div><span>Controller</span><strong className={`mode-badge mode-badge--${runtime.state.mode}`}>{runtime.state.mode.replace('-', ' ')}</strong></div>
        {runtime.state.props.map(prop => <div key={prop.id}><span>{prop.label}</span><strong>{prop.state}</strong></div>)}
        <div><span>Eye</span><strong>{eye?.connected ? eye.state.mode : 'offline'}</strong></div>
        <div><span>Active preset</span><strong>{library?.active ?? 'loading'}</strong></div>
      </aside>
    </div>
  </section>
}
