// Isolated RMT peripheral test. Before transmitting ANY waveform, explicitly
// disconnect RMT from STEP in the GPIO matrix and hold the real pad LOW.
// No MQTT subscription or motion cue is created.
#include <Arduino.h>
#include <WiFi.h>
#include <esp_rom_gpio.h>
#include <soc/gpio_sig_map.h>
#include "../../include/wifi_secrets.h"
#include "../../src/StepperRmtOutput.h"

StepperRmtOutput output;
bool passed = true;

void check(bool result, const char *label) {
  Serial.printf("%s %s\n", result ? "PASS" : "FAIL", label);
  passed = passed && result;
}

void natural(uint32_t steps, uint16_t rpm) {
  stepper_motion::Profile profile;
  check(profile.prepare(steps, rpm, false), "prepare finite");
  uint64_t expected_us = stepper_motion::kDirSetupUs;
  for (uint32_t i = 0; i < steps; ++i) expected_us += profile.periodAt(i);
  const uint32_t before = micros();
  check(output.start(profile), "start virtual finite");
  if (steps >= 1600) delay(250); // edges continue while the application loop sleeps
  while (!output.done() && static_cast<uint32_t>(micros() - before) < expected_us + 250000) delay(1);
  // Timestamp in the completion ISR, not the polling loop: USB logging can
  // block a task when no monitor is attached, without affecting RMT timing.
  const uint32_t elapsed_us = output.elapsedMicros();
  check(output.done(), "RMT EOF completion");
  check(elapsed_us >= expected_us - 2000 && elapsed_us < expected_us + 30000, "hardware duration within 30ms");
  check(output.symbolsSent() >= steps, "transmitted symbol count");
  Serial.printf("steps=%lu rpm=%u expected_us=%llu elapsed_us=%lu symbols=%lu\n",
    static_cast<unsigned long>(steps), rpm, static_cast<unsigned long long>(expected_us),
    static_cast<unsigned long>(elapsed_us), static_cast<unsigned long>(output.symbolsSent()));
  check(output.stop(), "idle after finite");
}

void setup() {
  pinMode(D9, OUTPUT); digitalWrite(D9, LOW);
  pinMode(D10, OUTPUT); digitalWrite(D10, LOW);
  Serial.begin(115200);
  const uint32_t attach_until = millis() + 8000;
  while (!Serial && static_cast<int32_t>(millis() - attach_until) < 0) delay(10);
  delay(1500);
  Serial.println("RMT_SELFTEST STEP/DIR held LOW; RMT disconnected before transmission");
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.begin(CUE_WIFI_SSID, CUE_WIFI_PASSWORD);
  const uint32_t wifi_until = millis() + 8000;
  while (WiFi.status() != WL_CONNECTED && static_cast<int32_t>(millis() - wifi_until) < 0) delay(10);
  Serial.printf("WiFi status before test=%d\n", static_cast<int>(WiFi.status()));
  const bool ready = output.begin(D9); // no transaction is enabled or started
  gpio_set_level(static_cast<gpio_num_t>(D9), 0);
  esp_rom_gpio_connect_out_signal(D9, SIG_GPIO_OUT_IDX, false, false);
  gpio_set_direction(static_cast<gpio_num_t>(D9), GPIO_MODE_OUTPUT);
  check(ready, "create DMA/RMT and disconnect its pad route before transmit");
  if (!ready) return;
  natural(1600, 60);
  natural(1, 1); // long-LOW phase splitting, odd final symbol
  natural(599, 30);

  stepper_motion::Profile jog;
  check(jog.prepare(0, 30, true), "prepare jog");
  check(output.start(jog), "start virtual jog");
  delay(100);
  check(!output.done(), "jog has no premature EOF");
  const uint32_t before_stop = micros();
  const bool stopped = output.stop();
  const uint32_t stop_us = micros() - before_stop;
  check(stopped, "cancel in-flight DMA jog");
  check(stop_us < 10000, "cancel within 10ms");
  delay(500);
  check(!output.done(), "no stale completion after cancel");
  natural(1600, 60); // reset/restart after cancel; no stale queued transaction
  for (int i = 0; i < 10; ++i) {
    check(output.start(jog), "repeat jog start");
    delay(5);
    check(output.stop(), "repeat jog cancel");
  }
  natural(2, 60);
  Serial.printf("WiFi status=%d\n", static_cast<int>(WiFi.status()));
  Serial.println(passed ? "RMT_SELFTEST_PASS" : "RMT_SELFTEST_FAIL");
}

void loop() {
  delay(2000);
  Serial.println(passed ? "RMT_SELFTEST_PASS" : "RMT_SELFTEST_FAIL");
}
