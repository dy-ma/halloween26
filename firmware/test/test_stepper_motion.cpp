#include <cassert>
#include <cstdint>
#include <cstdio>
#include <initializer_list>
#include "../../sync/firmware/src/StepperMotion.h"

using namespace stepper_motion;

static uint64_t checkWaveform(uint32_t steps, uint16_t rpm) {
  Profile profile;
  assert(profile.prepare(steps, rpm, false));
  Waveform wave;
  wave.reset(profile);
  Symbol symbol;
  uint64_t elapsed = 0;
  uint32_t rising_edges = 0;
  bool previous_high = false;
  uint64_t high_time = 0;
  while (wave.next(symbol)) {
    const uint16_t durations[] = {symbol.duration0, symbol.duration1};
    const bool levels[] = {symbol.level0, symbol.level1};
    for (int phase = 0; phase < 2; ++phase) {
      if (durations[phase] == 0) {
        assert(phase == 1);
        continue;
      }
      assert(durations[phase] <= kMaxPhaseUs);
      if (levels[phase]) {
        assert(!previous_high);
        assert(elapsed >= kDirSetupUs);
        assert(durations[phase] == kPulseHighUs);
        high_time += durations[phase];
        ++rising_edges;
      }
      previous_high = levels[phase];
      elapsed += durations[phase];
    }
  }
  assert(rising_edges == steps);
  assert(high_time == static_cast<uint64_t>(steps) * kPulseHighUs);
  assert(!wave.next(symbol));  // terminal cursor never emits another pulse
  uint64_t expected_us = kDirSetupUs;
  for (uint32_t i = 0; i < steps; ++i) {
    const uint32_t period = profile.periodAt(i);
    assert(period >= kPulseHighUs + kMinLowUs);
    assert(period == profile.periodAt(steps - 1 - i));
    expected_us += period;
  }
  assert(elapsed == expected_us);
  return elapsed;
}

int main() {
  Profile profile;
  assert(!profile.prepare(0, 60, false));
  assert(!profile.prepare(1600, 0, false));
  assert(!profile.prepare(1600, 9000, false));
  assert(!profile.prepare(1600, 1876, false));
  assert(profile.prepare(1600, 1875, false));
  assert(profile.prepare(1600, 60, false));
  assert(profile.cruise_us == 625);
  assert(profile.ramp_steps == 300);
  uint64_t ramp_time = 0;
  for (uint32_t i = 0; i < profile.ramp_steps; ++i) {
    ramp_time += profile.ramp_us[i];
    if (i != 0) assert(profile.ramp_us[i] <= profile.ramp_us[i - 1] + 1);
  }
  assert(ramp_time == 375000);
  assert(profile.ramp_us[0] > 10000); // accelerates from rest, not an immediate 20 RPM jump
  assert(profile.ramp_us[299] >= 624 && profile.ramp_us[299] <= 626);

  for (uint32_t steps : {1U, 2U, 3U, 10U, 59U, 60U, 299U, 300U, 599U, 600U, 601U, 1600U}) {
    for (uint16_t rpm : {1, 15, 30, 60, 1875}) checkWaveform(steps, rpm);
  }
  const uint64_t stroke_us = checkWaveform(1600, 60);
  assert(stroke_us == 1375020);

  assert(profile.prepare(0, 30, true));
  assert(profile.ramp_steps == 60 && profile.cruise_us == 1250);
  Waveform jog;
  jog.reset(profile);
  Symbol symbol;
  uint32_t pulses = 0;
  for (uint32_t i = 0; i < 50000; ++i) {
    assert(jog.next(symbol));
    pulses += symbol.level0 + symbol.level1;
  }
  assert(pulses > 40000);
  assert(jog.pulses == profile.ramp_steps); // no unbounded jog counter overflow
  assert(jog.profile.periodAt(jog.pulses) == 1250);
  // Replacement clears every partial long-LOW state and reintroduces DIR setup.
  assert(profile.prepare(1, 15, false));
  jog.reset(profile);
  assert(jog.next(symbol) && symbol.level0 == false && symbol.duration0 == kDirSetupUs);

  assert(!leaseExpired(100, 500));
  assert(leaseExpired(500, 500));
  const uint32_t renewal = 0xfffffff0U + kJogLeaseMs;
  assert(!leaseExpired(0x20, renewal));
  assert(leaseExpired(renewal, renewal));
  std::printf("Stepper profile: 60 waveform cases, exact counts/widths/setup, S-curve symmetry, low-speed splitting, jog saturation, reset and lease wrap passed; stroke %.3f s\n", stroke_us / 1000000.0);
}
