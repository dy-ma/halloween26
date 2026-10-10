import { useEffect, useLayoutEffect, useRef } from 'react'
import {
  animate,
  motion,
  useMotionValue,
  useReducedMotion,
  useTransform,
  type MotionValue,
} from 'motion/react'
import type { EyeState } from './eye-state'
import './tractor-eye.css'

interface TractorEyeProps {
  readonly state: EyeState
  readonly onReady?: () => void
}

// Travel stays relative to the eye-white container, not the small iris layers.
// Long holds between quick, small glances: apprehensive, rather than shaking.
const idleGlance = {
  x: ['0cqw', '0cqw', '-6cqw', '-6cqw', '4cqw', '4cqw', '0cqw', '0cqw'],
  y: ['0cqh', '0cqh', '1cqh', '1cqh', '-1cqh', '-1cqh', '0cqh', '0cqh'],
}
const idleTiming = [0, 0.28, 0.31, 0.49, 0.53, 0.71, 0.75, 1]
const alertGlance = {
  x: ['0cqw', '0cqw', '-2cqw', '-2cqw', '1.5cqw', '1.5cqw', '0cqw', '0cqw'],
  y: ['0cqh', '0cqh', '-0.7cqh', '-0.7cqh', '0.5cqh', '0.5cqh', '0cqh', '0cqh'],
}
const tippingGlance = {
  x: ['0cqw', '0cqw', '-0.5cqw', '-0.5cqw', '0.35cqw', '0.35cqw', '0cqw', '0cqw'],
  y: ['0cqh', '0cqh', '-0.18cqh', '-0.18cqh', '0.12cqh', '0.12cqh', '0cqh', '0cqh'],
}

function WindshieldEye({
  state,
  aperture,
  reducedMotion,
}: {
  state: EyeState
  aperture: MotionValue<number>
  reducedMotion: boolean
}) {
  // Keep the textured lid shapes fixed so blinking only moves cached layers.
  // 18% closed overlap covers both fixed corner curves (8% + 7%) with margin.
  const upperY = useTransform(aperture, [0, 1], ['-38%', '-94%'])
  const lowerY = useTransform(aperture, [0, 1], ['44%', '98%'])
  const tipping = state.mode === 'tipping'
  const startled = state.mode === 'alert' || tipping
  const idle = state.isOpen && !reducedMotion
    && (startled || (state.gaze.x === 0 && state.gaze.y === 0))
  // A backward glance reveals more iris; looking forward turns it side-on again.
  const irisAngle = 68 + state.gaze.x * 20

  return (
    <div className="windshield-eye">
      <div className="eye-white">
        <motion.div
          className="eye-gaze"
          initial={false}
          animate={{ x: `${state.gaze.x * 10}cqw`, y: `${state.gaze.y * 22}cqh` }}
          transition={{ duration: reducedMotion ? 0 : state.gazeDurationMs / 1000, ease: tipping ? 'easeInOut' : 'easeOut' }}
        >
          <motion.div
            className="eye-idle-gaze"
            initial={false}
            animate={idle ? (tipping ? tippingGlance : startled ? alertGlance : idleGlance) : { x: '0cqw', y: '0cqh' }}
            transition={idle
              ? { duration: tipping ? 5.5 : startled ? 3.8 : 10.4, times: idleTiming, repeat: Infinity, ease: 'easeInOut' }
              : { duration: reducedMotion || state.instantPose ? 0 : 0.2 }}
          >
            <motion.div
              className="eye-iris"
              initial={false}
              animate={{ transform: `perspective(450px) rotateY(${irisAngle}deg) scale(${startled ? 0.88 : 1})` }}
              transition={{ duration: reducedMotion || state.instantPose ? 0 : 0.16, ease: 'easeOut' }}
            >
              <motion.div
                className="eye-pupil"
                initial={false}
                animate={{ scale: startled ? 0.66 : 1 }}
                transition={{ duration: reducedMotion || state.instantPose ? 0 : 0.16 }}
              />
              <div className="eye-catchlight" />
              <div className="eye-catchlight eye-catchlight--small" />
            </motion.div>
          </motion.div>
        </motion.div>
      </div>
      <motion.div className="eye-lid eye-lid--upper" style={{ y: upperY }} />
      <motion.div className="eye-lid eye-lid--lower" style={{ y: lowerY }} />
      <div className="eye-seal" />
    </div>
  )
}

export function TractorEye({ state, onReady }: TractorEyeProps) {
  const aperture = useMotionValue(0)
  const reducedMotion = Boolean(useReducedMotion())
  const lastBlink = useRef(state.blinkSequence)

  useEffect(() => { onReady?.() }, [onReady])

  useLayoutEffect(() => {
    const newBlink = state.blinkSequence !== lastBlink.current
    lastBlink.current = state.blinkSequence
    const opening = state.isOpen ? (state.mode === 'alert' || state.mode === 'tipping' ? 1 : 0.86) : 0
    const blink = newBlink && state.isOpen && !reducedMotion && !state.instantPose
    if (state.instantPose) aperture.set(opening)
    let playback = animate(aperture, blink ? [aperture.get(), 0, opening] : opening, {
      duration: reducedMotion ? 0 : state.transitionDurationMs / 1000,
      ...(blink ? { times: [0, 0.38, 1] } : {}),
      ease: 'easeInOut',
    })

    let timer: ReturnType<typeof setTimeout> | undefined
    let cancelled = false
    let blinkCount = 0
    const scheduleBlink = () => {
      timer = setTimeout(() => {
        if (cancelled) return
        blinkCount += 1
        // An occasional double blink gives the old tractor a hesitant character.
        const doubleBlink = blinkCount % 3 === 0
        playback = animate(aperture,
          doubleBlink ? [opening, 0, opening, opening, 0, opening] : [opening, 0, opening],
          {
            duration: doubleBlink ? 0.82 : 0.38,
            times: doubleBlink ? [0, 0.15, 0.38, 0.55, 0.7, 1] : [0, 0.38, 1],
            ease: 'easeInOut',
          },
        )
        scheduleBlink()
      }, 4200 + Math.random() * 3800)
    }
    if (state.isOpen && !reducedMotion) scheduleBlink()

    // Closing/resetting cancels both an in-flight blink and its idle timer.
    return () => {
      cancelled = true
      clearTimeout(timer)
      playback.stop()
    }
  }, [aperture, reducedMotion, state.isOpen, state.mode, state.blinkSequence, state.transitionDurationMs, state.instantPose, state.snapshotRevision])

  return (
    <div className={`eye-scene eye-scene--${state.mode}`}>
      <div className="tractor-windshield" role="img" aria-label={`Right-facing tractor eye, ${state.mode}`}>
        <div className="tractor-brow" />
        {/* Recovery remounts motion tracks even if a snapshot matches an in-flight target. */}
        <WindshieldEye key={state.snapshotRevision} state={state} aperture={aperture} reducedMotion={reducedMotion} />
      </div>
    </div>
  )
}
