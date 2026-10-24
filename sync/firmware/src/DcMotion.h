#pragma once

#include <stdint.h>

namespace dc_motion {

constexpr uint32_t kMaxPhaseMs = 9999;
constexpr uint32_t kMaxProfileMs = 20000;

struct Profile {
  uint8_t peak_duty = 0;
  uint8_t minimum_duty = 0;
  uint32_t ramp_ms = 0;
  uint32_t hold_ms = 0;
  uint32_t fade_ms = 0;
  uint32_t duration_ms = 0;

  bool prepare(
    unsigned requested_peak,
    unsigned requested_minimum,
    unsigned requested_ramp_ms,
    unsigned requested_hold_ms,
    unsigned requested_fade_ms
  ) {
    const uint64_t total = static_cast<uint64_t>(requested_ramp_ms) +
      requested_hold_ms + requested_fade_ms;
    if (requested_peak == 0 || requested_peak > 255 ||
        requested_minimum > requested_peak || requested_ramp_ms == 0 ||
        requested_ramp_ms > kMaxPhaseMs || requested_hold_ms > kMaxPhaseMs ||
        requested_fade_ms == 0 || requested_fade_ms > kMaxPhaseMs ||
        total > kMaxProfileMs) {
      return false;
    }
    peak_duty = static_cast<uint8_t>(requested_peak);
    minimum_duty = static_cast<uint8_t>(requested_minimum);
    ramp_ms = requested_ramp_ms;
    hold_ms = requested_hold_ms;
    fade_ms = requested_fade_ms;
    duration_ms = static_cast<uint32_t>(total);
    return true;
  }

  uint8_t dutyAt(uint32_t elapsed_ms) const {
    if (duration_ms == 0 || elapsed_ms >= duration_ms) return 0;
    if (elapsed_ms < ramp_ms) {
      return rounded(peak_duty * smoothstep(elapsed_ms, ramp_ms));
    }
    const uint32_t fade_start = ramp_ms + hold_ms;
    if (elapsed_ms < fade_start) return peak_duty;
    const double progress = smoothstep(elapsed_ms - fade_start, fade_ms);
    const double duty = peak_duty +
      (static_cast<int>(minimum_duty) - peak_duty) * progress;
    return rounded(duty);
  }

 private:
  static double smoothstep(uint32_t elapsed, uint32_t duration) {
    double u = static_cast<double>(elapsed) / duration;
    if (u < 0.0) u = 0.0;
    if (u > 1.0) u = 1.0;
    const double u2 = u * u;
    const double u3 = u2 * u;
    return u3 * (u * (u * 6.0 - 15.0) + 10.0);
  }

  static uint8_t rounded(double duty) {
    if (duty <= 0.0) return 0;
    if (duty >= 255.0) return 255;
    return static_cast<uint8_t>(duty + 0.5);
  }
};

}  // namespace dc_motion
