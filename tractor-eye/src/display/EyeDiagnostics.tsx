import type { EyeState } from '../features/eye/eye-state'
import type { DisplayCalibration } from './calibration'

interface EyeDiagnosticsProps {
  readonly state: EyeState
  readonly mirrored: boolean
  readonly visible: boolean
  readonly calibration: DisplayCalibration
}

export function EyeDiagnostics({ state, mirrored, visible, calibration }: EyeDiagnosticsProps) {
  if (!visible) return null

  return (
    <aside className="eye-diagnostics" aria-label="Eye diagnostics">
      <strong>TRACTOR EYE</strong>
      <span>{mirrored ? '← LEFT-FACING' : 'RIGHT-FACING →'}</span>
      <span>{state.mode.toUpperCase()} / {state.isOpen ? 'OPEN' : 'CLOSED'}</span>
      <span>GAZE {state.gaze.x.toFixed(2)}, {state.gaze.y.toFixed(2)}</span>
      <span>VIEW {window.innerWidth}×{window.innerHeight}</span>
      <span>BASE 55.6vw × 90.1vh</span>
      <span>FRAME {calibration.xPx >= 0 ? '+' : ''}{calibration.xPx}, {calibration.yPx >= 0 ? '+' : ''}{calibration.yPx} px</span>
      <span>ROTATE {calibration.rotationDeg.toFixed(1)}°</span>
      <span>WIDTH {Math.round(calibration.scaleX * 100)}%</span>
      <span>HEIGHT {Math.round(calibration.scaleY * 100)}%</span>
      <small>M mirror · D guide</small>
      <small>⇧ arrows move · +Alt coarse</small>
      <small>Ctrl ←/→ width · ↑/↓ height</small>
      <small>[ ] rotate · ⇧[ ] by 5°</small>
      <small>−/+ scale both · +Alt by 5%</small>
      <small>⇧R reset frame</small>
    </aside>
  )
}
