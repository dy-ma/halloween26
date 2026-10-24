#include <Arduino.h>
#include <Cue.h>
#include "SyncTransport.h"
#include "AssemblyStatus.h"
#include "DcMotion.h"

#include <stdio.h>
#include <string.h>

#ifndef DC_RPWM_PIN
#define DC_RPWM_PIN 4
#endif
#ifndef DC_LPWM_PIN
#define DC_LPWM_PIN 5
#endif
#ifndef DC_REN_PIN
#define DC_REN_PIN -1
#endif
#ifndef DC_LEN_PIN
#define DC_LEN_PIN -1
#endif
#ifndef DC_LIMIT_FWD_PIN
#define DC_LIMIT_FWD_PIN -1
#endif
#ifndef DC_LIMIT_REV_PIN
#define DC_LIMIT_REV_PIN -1
#endif
#ifndef DC_LIMIT_ACTIVE_LEVEL
#define DC_LIMIT_ACTIVE_LEVEL LOW
#endif
#ifndef DC_LIMIT_INPUT_MODE
#define DC_LIMIT_INPUT_MODE INPUT_PULLUP
#endif
#ifndef CUE_STATUS_TARGET_NODE
#if CUE_USE_MQTT
#define CUE_STATUS_TARGET_NODE 0x020000000001ULL
#else
#define CUE_STATUS_TARGET_NODE 0ULL
#endif
#endif
namespace {

constexpr bool validLimitPin(int pin) {
  return pin < 0 || (pin != DC_RPWM_PIN && pin != DC_LPWM_PIN && pin != DC_REN_PIN && pin != DC_LEN_PIN);
}
static_assert(validLimitPin(DC_LIMIT_FWD_PIN) && validLimitPin(DC_LIMIT_REV_PIN), "Limit pins overlap motor outputs");
static_assert(DC_LIMIT_FWD_PIN < 0 || DC_LIMIT_REV_PIN < 0 || DC_LIMIT_FWD_PIN != DC_LIMIT_REV_PIN, "Limit pins must be distinct");

constexpr uint32_t kPwmFrequencyHz = 20000;
constexpr uint8_t kPwmResolutionBits = 8;
constexpr uint32_t kJogLeaseMs = 400;
constexpr uint32_t kJogRampMs = 350;
constexpr uint32_t kReversePauseMs = 500;
constexpr uint32_t kCurveRestartPauseMs = 100;

enum class Direction : uint8_t { STOPPED, FORWARD, REVERSE };

sync_transport::Transport::Config transport_config = sync_transport::config("dc-motor");
sync_transport::Transport transport(transport_config);
cue::Node node;
Direction direction = Direction::STOPPED;
Direction pending_direction = Direction::STOPPED;
uint8_t pending_duty = 0;
uint32_t pending_ramp_ms = 0;
uint32_t pending_at = 0;
uint32_t stop_at = 0;
uint64_t report_destination = CUE_STATUS_TARGET_NODE;
uint64_t report_command_id = 0;
bool finite_motion = false;
uint32_t next_inputs_report = 0;
bool pending = false;
uint8_t current_duty = 0;
uint8_t target_duty = 0;
uint8_t ramp_start_duty = 0;
uint32_t ramp_started_at = 0;
uint32_t ramp_duration_ms = 0;
bool pending_curve = false;
bool curve_motion = false;
uint32_t curve_started_at = 0;
dc_motion::Profile pending_curve_profile;
dc_motion::Profile active_curve_profile;

bool due(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

void outputsOff() {
  ledcWrite(DC_RPWM_PIN, 0);
  ledcWrite(DC_LPWM_PIN, 0);
  if (DC_REN_PIN >= 0) digitalWrite(DC_REN_PIN, LOW);
  if (DC_LEN_PIN >= 0) digitalWrite(DC_LEN_PIN, LOW);
  direction = Direction::STOPPED;
  current_duty = 0;
  target_duty = 0;
  ramp_start_duty = 0;
  ramp_started_at = 0;
  ramp_duration_ms = 0;
  curve_motion = false;
  curve_started_at = 0;
}

void report(uint64_t destination, const char *name) {
  if (destination == 0) return;
  cue::Message message;
  if (makeAssemblyStatus(node, destination, name, report_command_id, message)) transport.trySend(message);
}

bool limitActive(int pin) { return pin >= 0 && digitalRead(pin) == DC_LIMIT_ACTIVE_LEVEL; }
bool blocked(Direction requested) {
  return requested == Direction::FORWARD ? limitActive(DC_LIMIT_FWD_PIN) : limitActive(DC_LIMIT_REV_PIN);
}

void beginCommand(const cue::Message &message) {
  if (pending || direction != Direction::STOPPED) report(report_destination, "dc:superseded");
  report_destination = message.source;
  report_command_id = message.id;
}

void reportInputs(uint64_t destination = 0) {
  if (DC_LIMIT_FWD_PIN < 0 && DC_LIMIT_REV_PIN < 0) return;
  char name[cue::kNameCapacity] = {};
  snprintf(name, sizeof(name), "dc:limits:%c%c",
    DC_LIMIT_FWD_PIN < 0 ? '-' : (limitActive(DC_LIMIT_FWD_PIN) ? '1' : '0'),
    DC_LIMIT_REV_PIN < 0 ? '-' : (limitActive(DC_LIMIT_REV_PIN) ? '1' : '0'));
  cue::Message status;
  if (makeAssemblyStatus(node, destination == 0 ? report_destination : destination, name, 0, status)) transport.trySend(status);
}

void stop(uint64_t destination, const char *status) {
  outputsOff();
  pending = false;
  pending_curve = false;
  stop_at = 0;
  report(destination, status);
}

void writeDuty(Direction requested, uint8_t duty) {
  ledcWrite(DC_RPWM_PIN, 0);
  ledcWrite(DC_LPWM_PIN, 0);
  if (DC_REN_PIN >= 0) digitalWrite(DC_REN_PIN, HIGH);
  if (DC_LEN_PIN >= 0) digitalWrite(DC_LEN_PIN, HIGH);
  if (requested == Direction::FORWARD) {
    ledcWrite(DC_RPWM_PIN, duty);
  } else {
    ledcWrite(DC_LPWM_PIN, duty);
  }
  direction = requested;
  current_duty = duty;
}

void beginMotion(
  uint32_t now,
  Direction requested,
  uint8_t duty,
  uint32_t ramp_ms
) {
  curve_motion = false;
  target_duty = duty;
  ramp_start_duty = 0;
  ramp_started_at = now;
  ramp_duration_ms = ramp_ms;
  writeDuty(requested, ramp_ms == 0 ? duty : 0);
}

void retargetMotion(uint32_t now, uint8_t duty, uint32_t ramp_ms) {
  curve_motion = false;
  if (duty == target_duty) return;
  target_duty = duty;
  ramp_start_duty = current_duty;
  ramp_started_at = now;
  ramp_duration_ms = ramp_ms;
  if (ramp_ms == 0) writeDuty(direction, duty);
}

void requestMotion(
  uint32_t now,
  Direction requested,
  uint8_t duty,
  uint32_t run_ms,
  uint32_t ramp_ms,
  uint64_t source
) {
  report_destination = source;
  pending_curve = false;
  if (blocked(requested)) {
    stop(source, requested == Direction::FORWARD ? "dc:limit:fwd" : "dc:limit:rev");
    return;
  }
  if (direction != Direction::STOPPED && direction != requested) {
    outputsOff();
    pending = true;
    pending_direction = requested;
    pending_duty = duty;
    pending_ramp_ms = ramp_ms;
    pending_at = now + kReversePauseMs;
    stop_at = pending_at + run_ms;
  } else if (pending) {
    pending_direction = requested;
    pending_duty = duty;
    pending_ramp_ms = ramp_ms;
    stop_at = max(stop_at, pending_at + run_ms);
  } else if (direction == Direction::STOPPED) {
    beginMotion(now, requested, duty, ramp_ms);
    stop_at = now + run_ms;
  } else {
    retargetMotion(now, duty, ramp_ms);
    stop_at = now + run_ms;
  }
  report(source, pending ? "dc:pending" : "dc:running");
}

void beginCurveMotion(
  uint32_t now,
  Direction requested,
  const dc_motion::Profile &profile
) {
  active_curve_profile = profile;
  curve_motion = true;
  curve_started_at = now;
  ramp_duration_ms = 0;
  target_duty = profile.peak_duty;
  writeDuty(requested, profile.dutyAt(0));
  stop_at = now + profile.duration_ms;
}

void requestCurve(
  uint32_t now,
  Direction requested,
  const dc_motion::Profile &profile,
  uint64_t source
) {
  report_destination = source;
  finite_motion = true;
  if (blocked(requested)) {
    stop(source, requested == Direction::FORWARD ? "dc:limit:fwd" : "dc:limit:rev");
    return;
  }
  if (pending || direction != Direction::STOPPED) {
    const bool reversing = direction != Direction::STOPPED && direction != requested;
    outputsOff();
    pending = true;
    pending_curve = true;
    pending_direction = requested;
    pending_curve_profile = profile;
    pending_at = now + (reversing ? kReversePauseMs : kCurveRestartPauseMs);
    stop_at = pending_at + profile.duration_ms;
  } else {
    pending_curve = false;
    beginCurveMotion(now, requested, profile);
  }
  report(source, pending ? "dc:pending" : "dc:running");
}

bool parseDirection(const char *value, Direction &parsed) {
  if (strcmp(value, "fwd") == 0) parsed = Direction::FORWARD;
  else if (strcmp(value, "rev") == 0) parsed = Direction::REVERSE;
  else return false;
  return true;
}

bool parseCompactDirection(const char *value, Direction &parsed) {
  if (strcmp(value, "f") == 0) parsed = Direction::FORWARD;
  else if (strcmp(value, "r") == 0) parsed = Direction::REVERSE;
  else return false;
  return true;
}

void handleCue(const cue::Message &message, uint32_t now) {
  if (strcmp(message.name, "dc:status") == 0) {
    reportInputs(message.source);
    return;
  }
  if (strcmp(message.name, "dc:stop") == 0) {
    beginCommand(message);
    stop(message.source, "dc:stopped");
    return;
  }

  char direction_text[4] = {};
  unsigned duty = 0;
  unsigned duration = 0;
  int consumed = 0;
  Direction requested;
  unsigned minimum_duty = 0;
  unsigned ramp_ms = 0;
  unsigned hold_ms = 0;
  unsigned fade_ms = 0;
  if (sscanf(
        message.name,
        "dc:c:%1[^:]:%u:%u:%u:%u:%u%n",
        direction_text,
        &duty,
        &minimum_duty,
        &ramp_ms,
        &hold_ms,
        &fade_ms,
        &consumed
      ) == 6 && message.name[consumed] == '\0' &&
      parseCompactDirection(direction_text, requested)) {
    dc_motion::Profile profile;
    if (profile.prepare(duty, minimum_duty, ramp_ms, hold_ms, fade_ms)) {
      beginCommand(message);
      requestCurve(now, requested, profile, message.source);
      return;
    }
  }

  consumed = 0;
  memset(direction_text, 0, sizeof(direction_text));
  if (sscanf(message.name, "dc:jog:%3[^:]:%u%n", direction_text, &duty, &consumed) == 2 &&
      message.name[consumed] == '\0' && parseDirection(direction_text, requested) &&
      duty > 0 && duty <= 255) {
    beginCommand(message);
    finite_motion = false;
    requestMotion(
      now,
      requested,
      static_cast<uint8_t>(duty),
      kJogLeaseMs,
      kJogRampMs,
      message.source
    );
    return;
  }

  consumed = 0;
  memset(direction_text, 0, sizeof(direction_text));
  if (sscanf(
        message.name,
        "dc:%3[^:]:%u:%u%n",
        direction_text,
        &duty,
        &duration,
        &consumed
      ) == 3 && message.name[consumed] == '\0' &&
      parseDirection(direction_text, requested) && duty > 0 && duty <= 255 &&
      duration > 0 && duration <= 0x7fffffffUL) {
    beginCommand(message);
    finite_motion = true;
    requestMotion(
      now,
      requested,
      static_cast<uint8_t>(duty),
      duration,
      0,
      message.source
    );
    return;
  }

  cue::Message invalid;
  if (makeAssemblyStatus(node, message.source, "dc:invalid", message.id, invalid)) transport.trySend(invalid);
}

void updateMotion(uint32_t now) {
  const Direction requested = pending ? pending_direction : direction;
  if ((pending || direction != Direction::STOPPED) && blocked(requested)) {
    stop(report_destination, requested == Direction::FORWARD ? "dc:limit:fwd" : "dc:limit:rev");
    return;
  }
  if (pending && due(now, pending_at)) {
    pending = false;
    if (pending_curve) {
      pending_curve = false;
      beginCurveMotion(now, pending_direction, pending_curve_profile);
    } else {
      beginMotion(now, pending_direction, pending_duty, pending_ramp_ms);
    }
  }
  if (direction != Direction::STOPPED && curve_motion) {
    const uint8_t duty = active_curve_profile.dutyAt(now - curve_started_at);
    if (duty != current_duty) writeDuty(direction, duty);
  } else if (direction != Direction::STOPPED && ramp_duration_ms != 0) {
    const uint32_t elapsed = now - ramp_started_at;
    if (elapsed >= ramp_duration_ms) {
      ramp_duration_ms = 0;
      writeDuty(direction, target_duty);
    } else {
      const int32_t range = static_cast<int32_t>(target_duty) - ramp_start_duty;
      const uint8_t duty = static_cast<uint8_t>(
        static_cast<int32_t>(ramp_start_duty) +
        range * static_cast<int32_t>(elapsed) / static_cast<int32_t>(ramp_duration_ms)
      );
      if (duty != current_duty) writeDuty(direction, duty);
    }
  }
  if ((pending || direction != Direction::STOPPED) && stop_at != 0 && due(now, stop_at)) {
    stop(report_destination, finite_motion ? "dc:complete" : "dc:expired");
  }
}

}  // namespace

void setup() {
  if (DC_LIMIT_FWD_PIN >= 0) pinMode(DC_LIMIT_FWD_PIN, DC_LIMIT_INPUT_MODE);
  if (DC_LIMIT_REV_PIN >= 0) pinMode(DC_LIMIT_REV_PIN, DC_LIMIT_INPUT_MODE);
  pinMode(DC_RPWM_PIN, OUTPUT);
  pinMode(DC_LPWM_PIN, OUTPUT);
  if (DC_REN_PIN >= 0) pinMode(DC_REN_PIN, OUTPUT);
  if (DC_LEN_PIN >= 0) pinMode(DC_LEN_PIN, OUTPUT);
  digitalWrite(DC_RPWM_PIN, LOW);
  digitalWrite(DC_LPWM_PIN, LOW);
  if (DC_REN_PIN >= 0) digitalWrite(DC_REN_PIN, LOW);
  if (DC_LEN_PIN >= 0) digitalWrite(DC_LEN_PIN, LOW);
  Serial.begin(115200);

  const bool pwm_ready = ledcAttach(DC_RPWM_PIN, kPwmFrequencyHz, kPwmResolutionBits) &&
    ledcAttach(DC_LPWM_PIN, kPwmFrequencyHz, kPwmResolutionBits);
  outputsOff();
  const bool radio_ready = transport.begin();
  if (radio_ready) node.begin(transport.localNode(), esp_random());
  if (Serial) {
    Serial.printf(
      "sync dc %012llX pwm=%s transport=%s status=%s\n",
      static_cast<unsigned long long>(node.source()),
      pwm_ready ? "ready" : "unavailable",
      sync_transport::name,
      radio_ready ? "ready" : "unavailable"
    );
  }
  if (!pwm_ready) while (true) delay(1000);
}

void loop() {
  const uint32_t now = millis();
  transport.poll(now);
  cue::ReceivedCue received;
  while (transport.tryReceive(received)) {
    if (node.accept(received.message)) handleCue(received.message, now);
  }
  updateMotion(now);
  if (due(now, next_inputs_report)) {
    next_inputs_report = now + 1000;
    reportInputs();
  }
  delay(1);
}

