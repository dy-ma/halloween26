#include <assert.h>
#include <stdint.h>
#include <stdio.h>

#include "../../sync/firmware/src/DcMotion.h"

int main() {
  dc_motion::Profile invalid;
  assert(!invalid.prepare(0, 0, 300, 700, 2200));
  assert(!invalid.prepare(256, 0, 300, 700, 2200));
  assert(!invalid.prepare(200, 201, 300, 700, 2200));
  assert(!invalid.prepare(200, 50, 0, 700, 2200));
  assert(!invalid.prepare(200, 50, 300, 700, 0));
  assert(!invalid.prepare(200, 50, 9000, 9000, 9000));

  dc_motion::Profile profile;
  assert(profile.prepare(220, 50, 300, 700, 2200));
  assert(profile.duration_ms == 3200);
  assert(profile.dutyAt(0) == 0);
  assert(profile.dutyAt(300) == 220);
  assert(profile.dutyAt(999) == 220);
  assert(profile.dutyAt(2100) == 135);
  assert(profile.dutyAt(3199) == 50);
  assert(profile.dutyAt(3200) == 0);

  uint8_t previous = profile.dutyAt(0);
  for (uint32_t elapsed = 1; elapsed <= profile.ramp_ms; ++elapsed) {
    const uint8_t duty = profile.dutyAt(elapsed);
    assert(duty >= previous);
    assert(duty <= profile.peak_duty);
    previous = duty;
  }
  previous = profile.dutyAt(profile.ramp_ms + profile.hold_ms);
  for (uint32_t elapsed = profile.ramp_ms + profile.hold_ms + 1;
       elapsed < profile.duration_ms; ++elapsed) {
    const uint8_t duty = profile.dutyAt(elapsed);
    assert(duty <= previous);
    assert(duty >= profile.minimum_duty);
    previous = duty;
  }

  dc_motion::Profile full_fade;
  assert(full_fade.prepare(255, 0, 100, 0, 100));
  assert(full_fade.dutyAt(100) == 255);
  assert(full_fade.dutyAt(150) == 128);
  assert(full_fade.dutyAt(199) == 0);

  printf("DC motion: validation, quintic ramp/hold/fade, bounds and monotonicity passed\n");
}
