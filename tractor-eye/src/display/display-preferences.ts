import {
  DEFAULT_DISPLAY_CALIBRATION,
  type DisplayCalibration,
} from './calibration'

const MIRROR_STORAGE_KEY = 'tractor-eye.mirrored'
const CALIBRATION_STORAGE_KEY = 'tractor-eye.calibration'

function queryBoolean(name: string): boolean | undefined {
  const value = new URLSearchParams(window.location.search).get(name)
  if (value === '1' || value === 'true') return true
  if (value === '0' || value === 'false') return false
  return undefined
}

export function loadMirroredPreference(): boolean {
  const fromQuery = queryBoolean('mirror')
  if (fromQuery !== undefined) return fromQuery

  try {
    return window.localStorage.getItem(MIRROR_STORAGE_KEY) === 'true'
  } catch {
    return false
  }
}

export function saveMirroredPreference(mirrored: boolean): void {
  try {
    window.localStorage.setItem(MIRROR_STORAGE_KEY, String(mirrored))
  } catch {
    // Kiosk operation must continue if storage is unavailable.
  }
}

export function loadDiagnosticsPreference(): boolean {
  return queryBoolean('debug') ?? true
}

export function loadDisplayCalibration(): DisplayCalibration {
  try {
    const value: unknown = JSON.parse(window.localStorage.getItem(CALIBRATION_STORAGE_KEY) ?? 'null')
    if (!value || typeof value !== 'object') return DEFAULT_DISPLAY_CALIBRATION
    const candidate = value as Partial<DisplayCalibration>
    const legacyScale = (candidate as Partial<DisplayCalibration> & { scale?: number }).scale
    const scaleX = candidate.scaleX ?? legacyScale
    const scaleY = candidate.scaleY ?? legacyScale
    if (![candidate.xPx, candidate.yPx, candidate.rotationDeg, scaleX, scaleY]
      .every(item => typeof item === 'number' && Number.isFinite(item))) {
      return DEFAULT_DISPLAY_CALIBRATION
    }
    if (scaleX! < 0.5 || scaleX! > 1.75 || scaleY! < 0.5 || scaleY! > 1.75) {
      return DEFAULT_DISPLAY_CALIBRATION
    }
    return {
      xPx: candidate.xPx!,
      yPx: candidate.yPx!,
      rotationDeg: candidate.rotationDeg!,
      scaleX: scaleX!,
      scaleY: scaleY!,
    }
  } catch {
    return DEFAULT_DISPLAY_CALIBRATION
  }
}

export function saveDisplayCalibration(calibration: DisplayCalibration): void {
  try {
    window.localStorage.setItem(CALIBRATION_STORAGE_KEY, JSON.stringify(calibration))
  } catch {
    // Kiosk operation must continue if storage is unavailable.
  }
}
