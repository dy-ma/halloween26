#include <Arduino.h>
#include <Cue.h>
#include "SyncTransport.h"

#ifndef CUE_COORDINATOR_NODE
#define CUE_COORDINATOR_NODE 0ULL
#endif
#ifndef HORN_SWITCH_PIN
#define HORN_SWITCH_PIN D10
#endif
#ifndef HORN_SWITCH_ACTIVE_LEVEL
#define HORN_SWITCH_ACTIVE_LEVEL LOW
#endif
#ifndef HORN_SWITCH_INPUT_MODE
#define HORN_SWITCH_INPUT_MODE INPUT_PULLUP
#endif

namespace {

constexpr uint32_t kDebounceMs = 30;
// A tap is still a real horn press, but the larger show is requested only
// after the operator has held the button deliberately for this long.
constexpr uint32_t kShowHoldMs = 600;
// A held switch periodically renews the Pi-side horn lease. If this board,
// Wi-Fi, MQTT, or FX disappears, the lease expires instead of leaving a horn
// droning forever.
constexpr uint32_t kHeldIntervalMs = 400;
constexpr uint64_t kCoordinatorNode = CUE_COORDINATOR_NODE;
constexpr char kHornPushedEvent[] = "horn:pushed";
constexpr char kHornHeldEvent[] = "horn:held";
constexpr char kHornReleasedEvent[] = "horn:released";
constexpr char kHornShowEvent[] = "horn:show";

sync_transport::Transport::Config transport_config = sync_transport::config("horn");
sync_transport::Transport transport(transport_config);
cue::Node node;
bool reading = HORN_SWITCH_ACTIVE_LEVEL != HIGH;
bool stable = HORN_SWITCH_ACTIVE_LEVEL != HIGH;
uint32_t changed_at = 0;
uint32_t next_held_at = 0;
uint32_t pressed_at = 0;
bool show_requested = false;

bool sendHorn(const char* event) {
  if (kCoordinatorNode == 0) {
    if (Serial) Serial.println("horn not configured: set CUE_COORDINATOR_NODE");
    return false;
  }
  cue::Message message;
  if (!node.makeCue(kCoordinatorNode, event, message) ||
      transport.trySend(message) != cue::SendResult::QUEUED) {
    if (Serial) Serial.printf("horn failed to queue %s\n", event);
    return false;
  }
  if (Serial) {
    Serial.printf(
      "horn queued %s id=%llu\n",
      event,
      static_cast<unsigned long long>(message.id)
    );
  }
  return true;
}

void updateSwitch(uint32_t now) {
  const bool next = digitalRead(HORN_SWITCH_PIN);
  if (next != reading) {
    reading = next;
    changed_at = now;
  }
  if (reading != stable && now - changed_at >= kDebounceMs) {
    stable = reading;
    if (stable == HORN_SWITCH_ACTIVE_LEVEL) {
      sendHorn(kHornPushedEvent);
      pressed_at = now;
      show_requested = false;
      next_held_at = now + kHeldIntervalMs;
    } else {
      sendHorn(kHornReleasedEvent);
    }
  }
  if (stable == HORN_SWITCH_ACTIVE_LEVEL &&
      static_cast<int32_t>(now - next_held_at) >= 0) {
    sendHorn(kHornHeldEvent);
    next_held_at = now + kHeldIntervalMs;
  }
  if (stable == HORN_SWITCH_ACTIVE_LEVEL && !show_requested &&
      now - pressed_at >= kShowHoldMs) {
    show_requested = sendHorn(kHornShowEvent);
  }
}

}  // namespace

void setup() {
  pinMode(HORN_SWITCH_PIN, HORN_SWITCH_INPUT_MODE);
  reading = stable = digitalRead(HORN_SWITCH_PIN);
  Serial.begin(115200);
  const bool ready = transport.begin();
  if (ready) {
    node.begin(transport.localNode(), esp_random());
    if (kCoordinatorNode != 0) transport.addPeer(kCoordinatorNode);
  }
  if (ready && stable == HORN_SWITCH_ACTIVE_LEVEL) {
    sendHorn(kHornPushedEvent);
    pressed_at = millis();
    show_requested = false;
    next_held_at = pressed_at + kHeldIntervalMs;
  }
  if (Serial) {
    Serial.printf(
      "sync horn %012llX coordinator=%012llX pin=%u transport=%s status=%s\n",
      static_cast<unsigned long long>(node.source()),
      static_cast<unsigned long long>(kCoordinatorNode),
      static_cast<unsigned>(HORN_SWITCH_PIN),
      sync_transport::name,
      ready ? "ready" : "unavailable"
    );
  }
}

void loop() {
  const uint32_t now = millis();
  transport.poll(now);
  updateSwitch(now);

  cue::DeliveryReport report;
  while (transport.tryDelivery(report)) {
    if (Serial) {
      Serial.printf(
        "horn delivery status=%s attempts=%u latency_ms=%lu\n",
        report.status == cue::DeliveryStatus::DELIVERED ? "delivered" : "timeout",
        report.attempts,
        static_cast<unsigned long>(report.latency_ms)
      );
    }
  }
  delay(1);
}
