#include <Arduino.h>
#include <Cue.h>
#include "SyncTransport.h"

#ifndef CUE_COORDINATOR_NODE
#define CUE_COORDINATOR_NODE 0ULL
#endif
#ifndef HORN_SWITCH_PIN
#define HORN_SWITCH_PIN D6
#endif
#ifndef HORN_SWITCH_ACTIVE_LEVEL
#define HORN_SWITCH_ACTIVE_LEVEL LOW
#endif
#ifndef HORN_SWITCH_INPUT_MODE
#define HORN_SWITCH_INPUT_MODE INPUT_PULLUP
#endif

namespace {

constexpr uint32_t kDebounceMs = 30;
constexpr uint64_t kCoordinatorNode = CUE_COORDINATOR_NODE;
constexpr char kHornEvent[] = "horn:pushed";

sync_transport::Transport::Config transport_config = sync_transport::config("horn");
sync_transport::Transport transport(transport_config);
cue::Node node;
bool reading = HORN_SWITCH_ACTIVE_LEVEL != HIGH;
bool stable = HORN_SWITCH_ACTIVE_LEVEL != HIGH;
uint32_t changed_at = 0;

void sendHorn() {
  if (kCoordinatorNode == 0) {
    if (Serial) Serial.println("horn not configured: set CUE_COORDINATOR_NODE");
    return;
  }
  cue::Message message;
  if (!node.makeCue(kCoordinatorNode, kHornEvent, message) ||
      transport.trySend(message) != cue::SendResult::QUEUED) {
    if (Serial) Serial.println("horn failed to queue horn:pushed");
    return;
  }
  if (Serial) {
    Serial.printf(
      "horn queued horn:pushed id=%llu\n",
      static_cast<unsigned long long>(message.id)
    );
  }
}

void updateSwitch(uint32_t now) {
  const bool next = digitalRead(HORN_SWITCH_PIN);
  if (next != reading) {
    reading = next;
    changed_at = now;
  }
  if (reading != stable && now - changed_at >= kDebounceMs) {
    stable = reading;
    if (stable == HORN_SWITCH_ACTIVE_LEVEL) sendHorn();
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
