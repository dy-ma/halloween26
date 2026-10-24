#pragma once

#include <cmath>
#include <cstdint>

#ifndef STEPPER_ISR_ATTR
#define STEPPER_ISR_ATTR
#endif

// Pure motion planning and symbol generation, shared by host tests and RMT.
// No allocation, floating point, networking, or blocking calls in the ISR path.
namespace stepper_motion {

constexpr uint32_t kStepsPerRevolution = 1600;
#ifdef TMC_PULSE_HIGH_US
constexpr uint32_t kPulseHighUs = TMC_PULSE_HIGH_US;
#else
constexpr uint32_t kPulseHighUs = 10;
#endif
#ifdef TMC_DIR_SETUP_US
constexpr uint32_t kDirSetupUs = TMC_DIR_SETUP_US;
#else
constexpr uint32_t kDirSetupUs = 20;
#endif
constexpr uint32_t kMinLowUs = 10;
constexpr uint32_t kMaxPhaseUs = 32767;
constexpr uint32_t kMaxRampSteps = 300;
constexpr uint32_t kJogLeaseMs = 400;
static_assert(kPulseHighUs > 0 && kPulseHighUs <= kMaxPhaseUs && kDirSetupUs > 0,
              "RMT pulse width and direction setup must be representable");

inline bool leaseExpired(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

struct Profile {
  uint32_t steps = 0;
  uint32_t cruise_us = 0;
  uint32_t ramp_steps = 0;
  bool jogging = false;
  uint32_t ramp_us[kMaxRampSteps] = {};

  bool prepare(uint32_t requested_steps, uint16_t rpm, bool jog) {
    if (rpm == 0 || (!jog && requested_steps == 0)) return false;
    const uint32_t period = 60000000UL / (kStepsPerRevolution * rpm);
    if (period < kPulseHighUs + kMinLowUs) return false;
    steps = requested_steps;
    cruise_us = period;
    jogging = jog;

    // A quintic velocity curve v(t)=v_peak*(6u^5-15u^4+10u^3),
    // u=t/T. Velocity, acceleration and jerk join smoothly at both ends.
    // Its integral is T*v_peak*(u^6-3u^5+2.5u^4).
    // Plan pulse timestamps by inverting this integral outside the ISR.
    const double peak_hz = 1000000.0 / period;
    const double ramp_seconds = jog ? 0.150 : 0.375;
    uint32_t count = static_cast<uint32_t>(peak_hz * ramp_seconds / 2.0);
    if (count == 0) count = 1;
    if (count > kMaxRampSteps) count = kMaxRampSteps;
    if (!jog && count > steps / 2) count = steps / 2;
    ramp_steps = count;
    if (count == 0) return true;

    const double duration_us = 2.0 * count * period;
    uint32_t previous_us = 0;
    for (uint32_t i = 0; i < count; ++i) {
      const double fraction = static_cast<double>(i + 1) / (2.0 * count);
      double lo = 0.0, hi = 1.0;
      for (int iteration = 0; iteration < 32; ++iteration) {
        const double u = (lo + hi) * 0.5;
        const double u2 = u * u;
        const double integral = u2 * u2 * (u2 - 3.0 * u + 2.5);
        if (integral < fraction) lo = u;
        else hi = u;
      }
      const uint32_t timestamp_us = static_cast<uint32_t>(std::llround(duration_us * (lo + hi) * 0.5));
      ramp_us[i] = timestamp_us - previous_us;
      previous_us = timestamp_us;
    }
    return true;
  }

  STEPPER_ISR_ATTR uint32_t periodAt(uint32_t index) const {
    if (index < ramp_steps) return ramp_us[index];
    if (!jogging && index >= steps - ramp_steps) return ramp_us[steps - 1 - index];
    return cruise_us;
  }
};

struct Symbol {
  uint16_t duration0 = 0;
  bool level0 = false;
  uint16_t duration1 = 0;
  bool level1 = false;
};

struct Waveform {
  Profile profile;
  uint32_t pulses = 0;
  uint32_t remaining_low_us = 0;
  bool high_due = false;

  void reset(const Profile &prepared) {
    profile = prepared;
    pulses = 0;
    // Setup LOW precedes the first interval; every HIGH is exactly 10 us.
    remaining_low_us = kDirSetupUs;
    high_due = false;
  }

  STEPPER_ISR_ATTR bool nextPhase(uint16_t &duration, bool &level) {
    if (remaining_low_us == 0 && !high_due) {
      if (!profile.jogging && pulses == profile.steps) return false;
      remaining_low_us = profile.periodAt(pulses) - kPulseHighUs;
      high_due = true;
    }
    if (remaining_low_us != 0) {
      const uint32_t part = remaining_low_us > kMaxPhaseUs ? kMaxPhaseUs : remaining_low_us;
      duration = static_cast<uint16_t>(part);
      level = false;
      remaining_low_us -= part;
      return true;
    }
    duration = kPulseHighUs;
    level = true;
    high_due = false;
    // An infinite jog saturates its cursor after the acceleration ramp.
    if (!profile.jogging || pulses < profile.ramp_steps) ++pulses;
    return true;
  }

  STEPPER_ISR_ATTR bool next(Symbol &symbol) {
    symbol.duration0 = 0;
    symbol.duration1 = 0;
    symbol.level0 = false;
    symbol.level1 = false;
    if (!nextPhase(symbol.duration0, symbol.level0)) return false;
    nextPhase(symbol.duration1, symbol.level1);
    return true;
  }
};

}  // namespace stepper_motion
