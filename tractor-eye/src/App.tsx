import { useCallback, useEffect, useMemo, useReducer, useState } from 'react'
import { AnimationCommandBus } from './commands/command-bus'
import {
  createInitialEyeState,
  reduceEyeCommand,
} from './features/eye/eye-state'
import { TractorEye } from './features/eye/TractorEye'
import { keyboardCommandSource } from './sources/keyboard-command-source'
import { wakeSequenceSource } from './sources/wake-sequence-source'
import { createRuntimeWebSocketSource } from './sources/runtime-websocket-source'
import { createConnectionReporter } from './network/diagnostics'
import { EyeDiagnostics } from './display/EyeDiagnostics'
import {
  loadDisplayCalibration,
  loadDiagnosticsPreference,
  loadMirroredPreference,
  saveDisplayCalibration,
  saveMirroredPreference,
} from './display/display-preferences'
import { reduceCalibration, type CalibrationAction } from './display/calibration'
import './App.css'

function App() {
  const commandBus = useMemo(() => new AnimationCommandBus(), [])
  const [eyeState, dispatch] = useReducer(
    reduceEyeCommand,
    undefined,
    createInitialEyeState,
  )
  const [mirrored, setMirrored] = useState(loadMirroredPreference)
  const [showDiagnostics, setShowDiagnostics] = useState(loadDiagnosticsPreference)
  const [calibration, setCalibration] = useState(loadDisplayCalibration)

  useEffect(() => commandBus.subscribe(dispatch), [commandBus])
  useEffect(() => wakeSequenceSource.start(commandBus), [commandBus])

  useEffect(
    () => keyboardCommandSource.start(commandBus),
    [commandBus],
  )

  useEffect(() => createRuntimeWebSocketSource({
    pageUrl: window.location.href,
    onStatus: createConnectionReporter(),
  }).start(commandBus), [commandBus])

  useEffect(() => {
    const handleDisplayKey = (event: KeyboardEvent) => {
      if (event.target instanceof HTMLElement
        && (event.target.isContentEditable || event.target.closest('input, textarea, select'))) return

      if (event.code === 'KeyM') {
        if (event.repeat) return
        event.preventDefault()
        setMirrored(current => {
          const next = !current
          saveMirroredPreference(next)
          return next
        })
      } else if (event.code === 'KeyD') {
        if (event.repeat) return
        event.preventDefault()
        setShowDiagnostics(current => !current)
      } else {
        let action: CalibrationAction | undefined
        const move = event.altKey ? 40 : 8
        const resize = event.altKey ? 0.05 : 0.01
        if (event.ctrlKey && event.code === 'ArrowLeft') action = { type: 'scale-width', amount: -resize }
        else if (event.ctrlKey && event.code === 'ArrowRight') action = { type: 'scale-width', amount: resize }
        else if (event.ctrlKey && event.code === 'ArrowUp') action = { type: 'scale-height', amount: resize }
        else if (event.ctrlKey && event.code === 'ArrowDown') action = { type: 'scale-height', amount: -resize }
        else if (event.shiftKey && event.code === 'ArrowLeft') action = { type: 'translate', dx: -move, dy: 0 }
        else if (event.shiftKey && event.code === 'ArrowRight') action = { type: 'translate', dx: move, dy: 0 }
        else if (event.shiftKey && event.code === 'ArrowUp') action = { type: 'translate', dx: 0, dy: -move }
        else if (event.shiftKey && event.code === 'ArrowDown') action = { type: 'translate', dx: 0, dy: move }
        else if (event.code === 'BracketLeft') action = { type: 'rotate', degrees: event.shiftKey ? -5 : -1 }
        else if (event.code === 'BracketRight') action = { type: 'rotate', degrees: event.shiftKey ? 5 : 1 }
        else if (event.code === 'Minus') action = { type: 'scale', amount: event.altKey ? -0.05 : -0.01 }
        else if (event.code === 'Equal') action = { type: 'scale', amount: event.altKey ? 0.05 : 0.01 }
        else if (event.shiftKey && event.code === 'KeyR') action = { type: 'reset' }

        if (action) {
          event.preventDefault()
          setCalibration(current => {
            const next = reduceCalibration(current, action)
            saveDisplayCalibration(next)
            return next
          })
        }
      }
    }

    window.addEventListener('keydown', handleDisplayKey)
    return () => window.removeEventListener('keydown', handleDisplayKey)
  }, [])

  const handleSceneReady = useCallback(() => {
    document.body.dataset.sceneReady = 'true'
  }, [])

  return (
    <main className="tractor-eye-stage" aria-label="Animated tractor eye">
      <TractorEye
        state={eyeState}
        mirrored={mirrored}
        showGuide={showDiagnostics}
        calibration={calibration}
        onReady={handleSceneReady}
      />
      <EyeDiagnostics
        state={eyeState}
        mirrored={mirrored}
        visible={showDiagnostics}
        calibration={calibration}
      />
    </main>
  )
}

export default App
