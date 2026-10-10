import { useCallback, useEffect, useMemo, useReducer } from 'react'
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
import './App.css'

function App() {
  const commandBus = useMemo(() => new AnimationCommandBus(), [])
  const [eyeState, dispatch] = useReducer(
    reduceEyeCommand,
    undefined,
    createInitialEyeState,
  )

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

  const handleSceneReady = useCallback(() => {
    document.body.dataset.sceneReady = 'true'
  }, [])

  return (
    <main className="tractor-eye-stage" aria-label="Animated tractor eye">
      <TractorEye state={eyeState} onReady={handleSceneReady} />
    </main>
  )
}

export default App
