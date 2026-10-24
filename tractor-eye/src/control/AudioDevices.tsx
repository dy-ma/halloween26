import { useCallback, useEffect, useRef, useState } from 'react'

type Track = { id: string; label: string; format: string; fileName: string; available: boolean; durationMs: number | null }
type Output = { id: string; label: string; kind: string; aliases: string[]; paired: boolean; connected: boolean; ready: boolean; percent: number | null; muted: boolean }
type Playback = { id: string; track: string; output: string; phase: string; startedAtMs: number; detail: string }
type AudioStatus = { host: string; tracks: Track[]; outputs: Output[]; playbacks: Playback[]; errors: string[]; maxActive: number }
type Action = { type: 'play'; output: string; track: string } | { type: 'stop'; playback: string }
  | { type: 'volume'; output: string; percent: number } | { type: 'connect' | 'disconnect'; output: string }

function AudioOutputCard({ output, tracks, playbacks, unavailable, busy, action }: {
  output: Output; tracks: Track[]; playbacks: Playback[]; unavailable: boolean; busy: Set<string>
  action: (body: Action, key: string) => Promise<boolean>
}) {
  const [choice, setChoice] = useState('')
  const [draftVolume, setDraftVolume] = useState<number | null>(null)
  const volumeTimer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const volumeVersion = useRef(0)
  const selected = tracks.find(track => track.id === choice && track.available)?.id ?? tracks.find(track => track.available)?.id ?? ''
  const active = playbacks.filter(playback => playback.output === output.id && playback.phase === 'playing')
  const latest = playbacks.find(playback => playback.output === output.id)
  useEffect(() => () => { if (volumeTimer.current) clearTimeout(volumeTimer.current) }, [])

  const volume = (percent: number) => {
    const version = ++volumeVersion.current
    setDraftVolume(percent)
    if (volumeTimer.current) clearTimeout(volumeTimer.current)
    volumeTimer.current = setTimeout(() => {
      void action({ type: 'volume', output: output.id, percent }, `volume:${output.id}`).then(ok => { if (ok && volumeVersion.current === version) setDraftVolume(null) })
    }, 200)
  }

  return <article className="audio-output" aria-label={output.label}>
    <div className="panel-heading">
      <div><h3 title={output.id}>{output.label}</h3>{output.aliases.length > 0 && <small>{output.aliases.join(', ')}</small>}
        {output.kind === 'bluetooth' && <small className="audio-device-id">{output.id.replace('bluetooth:', '')}</small>}</div>
      <span className={`panel-status ${output.ready ? 'online' : 'offline'}`}>
        <span className="board-dot" />{output.ready ? 'Ready' : output.connected ? 'Connected · audio not ready' : output.paired ? 'Paired · disconnected' : 'Unavailable'}
      </span>
    </div>
    {output.paired && <div className="audio-connection-actions"><button type="button" disabled={unavailable || busy.has(output.id)}
      onClick={() => void action({ type: output.connected ? 'disconnect' : 'connect', output: output.id }, output.id)}>
      {busy.has(output.id) ? 'Working…' : output.connected ? 'Disconnect' : 'Connect'}
    </button></div>}
    <div className="audio-track-picker">
      <label>Track<select aria-label={`Track for ${output.label}`} value={selected} onChange={event => setChoice(event.target.value)} disabled={!tracks.some(track => track.available)}>
        {!selected && <option value="">No tracks available</option>}
        {tracks.map(track => <option value={track.id} key={track.id} disabled={!track.available}>{track.label} · {track.format}{track.durationMs != null ? ` · ${(track.durationMs / 1000).toFixed(2)}s` : ''}{!track.available ? ' · missing file' : ''}</option>)}
      </select></label>
      <button type="button" className="audio-play" disabled={unavailable || !output.ready || !selected || busy.has(output.id)}
        onClick={() => void action({ type: 'play', output: output.id, track: selected }, output.id)}>Play</button>
    </div>
    <label className="volume-control"><span>Volume{output.muted ? ' (muted)' : ''}</span>
      <input type="range" aria-label={`${output.label} volume`} min={0} max={100} value={draftVolume ?? output.percent ?? 0}
        disabled={unavailable || !output.ready || output.percent === null} onChange={event => volume(Number(event.target.value))} />
      <output>{output.percent === null ? '—' : `${draftVolume ?? output.percent}%`}</output>
    </label>
    <ul className="audio-playing">
      {active.map(playback => <li key={playback.id}><span>{tracks.find(track => track.id === playback.track)?.label ?? playback.track} · playing</span>
        <button type="button" disabled={unavailable || busy.has(playback.id)} onClick={() => void action({ type: 'stop', playback: playback.id }, playback.id)}>Stop</button></li>)}
    </ul>
    {!active.length && latest && <p className="status-note">{latest.phase}: {latest.detail}</p>}
    {!active.length && !latest && <p className="status-note">Not playing</p>}
  </article>
}

export function AudioDevices() {
  const [audio, setAudio] = useState<AudioStatus | null>(null)
  const [error, setError] = useState('')
  const [pollError, setPollError] = useState('')
  const [unavailable, setUnavailable] = useState(true)
  const [busy, setBusy] = useState<Set<string>>(() => new Set())
  const refresh = useCallback(async (signal?: AbortSignal) => {
    const response = await fetch('/api/audio', { cache: 'no-store', signal })
    if (!response.ok) throw new Error(await response.text())
    const value = await response.json() as AudioStatus
    if (!signal?.aborted) { setAudio(value); setUnavailable(false); setPollError('') }
  }, [])

  useEffect(() => {
    const controller = new AbortController()
    let timer: ReturnType<typeof setTimeout> | undefined
    const poll = async () => {
      try { await refresh(controller.signal) }
      catch (error) { if (!controller.signal.aborted) { setUnavailable(true); setPollError(String(error)) } }
      finally { if (!controller.signal.aborted) timer = setTimeout(() => { void poll() }, 2000) }
    }
    void poll()
    return () => { controller.abort(); clearTimeout(timer) }
  }, [refresh])

  const action = async (body: Action, key: string) => {
    setBusy(current => new Set(current).add(key))
    try {
      const response = await fetch('/api/audio', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body) })
      if (!response.ok) throw new Error(await response.text())
      setError('')
      await refresh()
      return true
    } catch (error) { setError(String(error)); return false }
    finally { setBusy(current => { const next = new Set(current); next.delete(key); return next }) }
  }

  return <section aria-labelledby="audio-heading">
    <h2 id="audio-heading">Audio devices</h2>
    {error && <p role="status">{error}</p>}
    {pollError && <p role="status">{pollError}</p>}
    {audio?.errors.map(message => <p className="status-note" key={message}>{message}</p>)}
    <div className="audio-output-list">{audio?.outputs.map(output => <AudioOutputCard key={output.id} output={output} tracks={audio.tracks} playbacks={audio.playbacks}
      unavailable={unavailable} busy={busy} action={action} />)}</div>
    {!audio && <p>Checking the FX host’s audio devices…</p>}
    {audio && !audio.outputs.length && <p>No audio outputs found on the FX host.</p>}
    {audio && <p className="status-note">{audio.tracks.length} {audio.tracks.length === 1 ? 'track' : 'tracks'} on {audio.host} · Each Play adds an independent layer · Up to {audio.maxActive} active tracks</p>}
  </section>
}
