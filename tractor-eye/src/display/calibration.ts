export interface DisplayCalibration {
  readonly xPx: number
  readonly yPx: number
  readonly rotationDeg: number
  readonly scaleX: number
  readonly scaleY: number
}

export type CalibrationAction =
  | { readonly type: 'translate'; readonly dx: number; readonly dy: number }
  | { readonly type: 'rotate'; readonly degrees: number }
  | { readonly type: 'scale'; readonly amount: number }
  | { readonly type: 'scale-width'; readonly amount: number }
  | { readonly type: 'scale-height'; readonly amount: number }
  | { readonly type: 'reset' }

export const DEFAULT_DISPLAY_CALIBRATION: DisplayCalibration = {
  xPx: 0,
  yPx: 0,
  rotationDeg: 0,
  scaleX: 1,
  scaleY: 1,
}

function clamp(value: number, minimum: number, maximum: number): number {
  return Math.max(minimum, Math.min(maximum, value))
}

export function reduceCalibration(
  calibration: DisplayCalibration,
  action: CalibrationAction,
): DisplayCalibration {
  switch (action.type) {
    case 'translate':
      return {
        ...calibration,
        xPx: Math.round(clamp(calibration.xPx + action.dx, -600, 600)),
        yPx: Math.round(clamp(calibration.yPx + action.dy, -960, 960)),
      }
    case 'rotate':
      return {
        ...calibration,
        rotationDeg: Math.round(clamp(calibration.rotationDeg + action.degrees, -180, 180) * 10) / 10,
      }
    case 'scale':
      return {
        ...calibration,
        scaleX: Math.round(clamp(calibration.scaleX + action.amount, 0.5, 1.75) * 100) / 100,
        scaleY: Math.round(clamp(calibration.scaleY + action.amount, 0.5, 1.75) * 100) / 100,
      }
    case 'scale-width':
      return {
        ...calibration,
        scaleX: Math.round(clamp(calibration.scaleX + action.amount, 0.5, 1.75) * 100) / 100,
      }
    case 'scale-height':
      return {
        ...calibration,
        scaleY: Math.round(clamp(calibration.scaleY + action.amount, 0.5, 1.75) * 100) / 100,
      }
    case 'reset':
      return DEFAULT_DISPLAY_CALIBRATION
  }
}
