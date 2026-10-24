#include <Arduino.h>
#include <Cue.h>
#include "SyncTransport.h"
#include "AssemblyStatus.h"

#include <stdio.h>
#include <string.h>

#ifndef TMC_STEP_PIN
#define TMC_STEP_PIN 9
#endif
#ifndef TMC_DIR_PIN
#define TMC_DIR_PIN 10
#endif
#ifndef TMC_PULSE_HIGH_US
#define TMC_PULSE_HIGH_US 4
#endif
#ifndef TMC_DIR_SETUP_US
#define TMC_DIR_SETUP_US 10
#endif

#ifndef TMC_USE_RMT
#define TMC_USE_RMT CUE_USE_MQTT
#endif

#if TMC_USE_RMT
#include "StepperMqttRmt.h"
#else

namespace {

constexpr uint16_t kStepsPerRevolution = 1600;
constexpr uint16_t kStartRpm = 20;
constexpr uint32_t kPulseHighUs = TMC_PULSE_HIGH_US;
constexpr uint32_t kDirSetupUs = TMC_DIR_SETUP_US;
static_assert(kPulseHighUs > 0 && kDirSetupUs > 0, "Stepper signal timings must be positive");
constexpr uint32_t kJogLeaseMs = 400;

sync_transport::Transport::Config transport_config = sync_transport::config("stepper");
sync_transport::Transport transport(transport_config);
cue::Node node;
bool running = false;
bool jogging = false;
bool direction_forward = true;
bool pulse_high = false;
uint32_t total_steps = 0;
uint32_t completed_steps = 0;
uint32_t ramp_steps = 0;
uint32_t start_period_us = 0;
uint32_t target_period_us = 0;
uint32_t next_transition_us = 0;
uint32_t jog_stop_at_ms = 0;
uint64_t report_destination = 0;
uint64_t report_command_id = 0;

bool due(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

void report(uint64_t destination, const char *name) {
  if (destination == 0) return;
  cue::Message message;
  if (makeAssemblyStatus(node, destination, name, report_command_id, message)) transport.trySend(message);
}

void beginCommand(const cue::Message &message) {
  if (running) report(report_destination, "step:replaced");
  report_command_id = message.id;
}

void stop(uint64_t destination, const char *status) {
  running = false;
  jogging = false;
  pulse_high = false;
  jog_stop_at_ms = 0;
  digitalWrite(TMC_STEP_PIN, LOW);
  report(destination, status);
}

uint32_t stepPeriod() {
  if (ramp_steps == 0) return target_period_us;
  uint32_t position = completed_steps;
  if (!jogging && completed_steps >= total_steps - ramp_steps) {
    position = total_steps - completed_steps;
  }
  if (position >= ramp_steps) return target_period_us;
  const uint32_t range = start_period_us - target_period_us;
  return start_period_us - (range * position) / ramp_steps;
}

void configureMotion(bool forward, uint16_t rpm, uint64_t source) {
  stop(0, "step:stopped");
  digitalWrite(TMC_DIR_PIN, forward ? HIGH : LOW);
  direction_forward = forward;
  completed_steps = 0;
  const uint16_t start_rpm = min<uint16_t>(kStartRpm, rpm);
  start_period_us = 60000000UL / (kStepsPerRevolution * start_rpm);
  target_period_us = 60000000UL / (kStepsPerRevolution * rpm);
  report_destination = source;
  running = true;
  next_transition_us = micros() + kDirSetupUs;
}

void startFinite(bool forward, uint32_t steps, uint16_t rpm, uint64_t source) {
  configureMotion(forward, rpm, source);
  jogging = false;
  total_steps = steps;
  ramp_steps = min<uint32_t>(300, steps / 2);
}

void requestJog(
  uint32_t now_ms,
  bool forward,
  uint16_t rpm,
  uint64_t source
) {
  if (!running || !jogging || direction_forward != forward) {
    configureMotion(forward, rpm, source);
    jogging = true;
    total_steps = 0;
    ramp_steps = 300;
  }
  report_destination = source;
  jog_stop_at_ms = now_ms + kJogLeaseMs;
}

void handleCue(const cue::Message &message, uint32_t now_ms) {
  if (strcmp(message.name, "step:stop") == 0) {
    beginCommand(message);
    stop(message.source, "step:stopped");
    return;
  }

  char direction[4] = {};
  unsigned steps = 0;
  unsigned rpm = 0;
  int consumed = 0;
  if (sscanf(
        message.name,
        "step:jog:%3[^:]:%u%n",
        direction,
        &rpm,
        &consumed
      ) == 2 && message.name[consumed] == '\0' &&
      (strcmp(direction, "fwd") == 0 || strcmp(direction, "rev") == 0) &&
      rpm > 0 && rpm <= 9000) {
    beginCommand(message);
    requestJog(
      now_ms,
      strcmp(direction, "fwd") == 0,
      static_cast<uint16_t>(rpm),
      message.source
    );
    return;
  }

  consumed = 0;
  memset(direction, 0, sizeof(direction));
  if (sscanf(
        message.name,
        "step:%3[^:]:%u:%u%n",
        direction,
        &steps,
        &rpm,
        &consumed
      ) == 3 && message.name[consumed] == '\0' &&
      (strcmp(direction, "fwd") == 0 || strcmp(direction, "rev") == 0) &&
      steps > 0 && rpm > 0 && rpm <= 9000) {
    beginCommand(message);
    startFinite(
      strcmp(direction, "fwd") == 0,
      steps,
      static_cast<uint16_t>(rpm),
      message.source
    );
    return;
  }
  cue::Message invalid;
  if (makeAssemblyStatus(node, message.source, "step:invalid", message.id, invalid)) transport.trySend(invalid);
}

void updateMotion(uint32_t now_us, uint32_t now_ms) {
  if (running && jogging && due(now_ms, jog_stop_at_ms)) {
    stop(report_destination, "step:stopped");
    return;
  }
  if (!running || !due(now_us, next_transition_us)) return;
  if (!pulse_high) {
    digitalWrite(TMC_STEP_PIN, HIGH);
    pulse_high = true;
    next_transition_us = now_us + kPulseHighUs;
    return;
  }

  digitalWrite(TMC_STEP_PIN, LOW);
  pulse_high = false;
  ++completed_steps;
  if (!jogging && completed_steps >= total_steps) {
    stop(report_destination, "step:complete");
    return;
  }
  next_transition_us = now_us + stepPeriod() - kPulseHighUs;
}

}  // namespace

void setup() {
  pinMode(TMC_STEP_PIN, OUTPUT);
  pinMode(TMC_DIR_PIN, OUTPUT);
  digitalWrite(TMC_STEP_PIN, LOW);
  digitalWrite(TMC_DIR_PIN, LOW);
  Serial.begin(115200);

  const bool ready = transport.begin();
  if (ready) node.begin(transport.localNode(), esp_random());
  if (Serial) {
    Serial.printf(
      "sync stepper %012llX transport=%s status=%s steps_per_rev=%u\n",
      static_cast<unsigned long long>(node.source()),
      sync_transport::name,
      ready ? "ready" : "unavailable",
      kStepsPerRevolution
    );
  }
}

void loop() {
  const uint32_t now_ms = millis();
  transport.poll(now_ms);
  cue::ReceivedCue received;
  while (transport.tryReceive(received)) {
    if (node.accept(received.message)) handleCue(received.message, now_ms);
  }
  updateMotion(micros(), now_ms);
}

#endif  // TMC_USE_RMT: preserve the original software-timed implementation

