import { useEffect, useRef } from 'react'
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

// Long holds between quick, small glances: apprehensive, rather than shaking.
const idleGlance = {
  x: ['0%', '0%', '-6%', '-6%', '4%', '4%', '0%', '0%'],
  y: ['0%', '0%', '1%', '1%', '-1%', '-1%', '0%', '0%'],
}
const idleTiming = [0, 0.28, 0.31, 0.49, 0.53, 0.71, 0.75, 1]
const alertGlance = {
  x: ['0%', '0%', '-2%', '-2%', '1.5%', '1.5%', '0%', '0%'],
  y: ['0%', '0%', '-0.7%', '-0.7%', '0.5%', '0.5%', '0%', '0%'],
}
const tippingGlance = {
  x: ['0%', '0%', '-0.5%', '-0.5%', '0.35%', '0.35%', '0%', '0%'],
  y: ['0%', '0%', '-0.18%', '-0.18%', '0.12%', '0.12%', '0%', '0%'],
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
  // Curved lids overlap when closed so no white leaks through at the corners.
  const upperY = useTransform(aperture, [0, 1], ['-44%', '-94%'])
  const lowerY = useTransform(aperture, [0, 1], ['50%', '98%'])
  const upperCurve = useTransform(aperture, [0, 1], ['0% 0%', '42% 8%'])
  const lowerCurve = useTransform(aperture, [0, 1], ['0% 0%', '40% 7%'])
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
          animate={{ x: `${state.gaze.x * 10}%`, y: `${state.gaze.y * 22}%` }}
          transition={{ duration: reducedMotion ? 0 : state.gazeDurationMs / 1000, ease: tipping ? 'easeInOut' : 'easeOut' }}
        >
          <motion.div
            className="eye-idle-gaze"
            animate={idle ? (tipping ? tippingGlance : startled ? alertGlance : idleGlance) : { x: '0%', y: '0%' }}
            transition={idle
              ? { duration: tipping ? 5.5 : startled ? 3.8 : 10.4, times: idleTiming, repeat: Infinity, ease: 'easeInOut' }
              : { duration: reducedMotion ? 0 : 0.2 }}
          >
            <motion.div
              className="eye-iris"
              animate={{ transform: `perspective(450px) rotateY(${irisAngle}deg) scale(${startled ? 0.88 : 1})` }}
              transition={{ duration: reducedMotion ? 0 : 0.16, ease: 'easeOut' }}
            >
              <motion.div
                className="eye-pupil"
                animate={{ scale: startled ? 0.66 : 1 }}
                transition={{ duration: reducedMotion ? 0 : 0.16 }}
              />
              <div className="eye-catchlight" />
              <div className="eye-catchlight eye-catchlight--small" />
            </motion.div>
          </motion.div>
        </motion.div>
      </div>
      <motion.div className="eye-lid eye-lid--upper" style={{ y: upperY, borderBottomLeftRadius: upperCurve }} />
      <motion.div className="eye-lid eye-lid--lower" style={{ y: lowerY, borderTopLeftRadius: lowerCurve }} />
      <div className="eye-seal" />
    </div>
  )
}

export function TractorEye({ state, onReady }: TractorEyeProps) {
  const aperture = useMotionValue(0)
  const reducedMotion = Boolean(useReducedMotion())
  const lastBlink = useRef(state.blinkSequence)

  useEffect(() => { onReady?.() }, [onReady])

  useEffect(() => {
    const newBlink = state.blinkSequence !== lastBlink.current
    lastBlink.current = state.blinkSequence
    const opening = state.isOpen ? (state.mode === 'alert' || state.mode === 'tipping' ? 1 : 0.86) : 0
    const blink = newBlink && state.isOpen && !reducedMotion
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
  }, [aperture, reducedMotion, state.isOpen, state.mode, state.blinkSequence, state.transitionDurationMs])

  return (
    <div className={`eye-scene eye-scene--${state.mode}`}>
      <div className="tractor-windshield" role="img" aria-label={`Right-facing tractor eye, ${state.mode}`}>
        <div className="tractor-brow" />
        <WindshieldEye state={state} aperture={aperture} reducedMotion={reducedMotion} />
      </div>
    </div>
  )
}
