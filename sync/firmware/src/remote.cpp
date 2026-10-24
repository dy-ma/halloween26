#include <Arduino.h>
#include <Cue.h>
#include "SyncTransport.h"

#ifndef CUE_COORDINATOR_NODE
#ifdef CUE_GATEWAY_NODE
#define CUE_COORDINATOR_NODE CUE_GATEWAY_NODE
#else
#define CUE_COORDINATOR_NODE 0ULL
#endif
#endif
#ifndef REMOTE_START_PIN
#define REMOTE_START_PIN 0
#endif
#ifndef REMOTE_STOP_PIN
#define REMOTE_STOP_PIN 1
#endif

namespace {

constexpr uint32_t kDebounceMs = 30;
constexpr uint64_t kGatewayNode = CUE_COORDINATOR_NODE;

struct Button {
  uint8_t pin;
  const char *cue;
  bool reading = HIGH;
  bool stable = HIGH;
  uint32_t changed_at = 0;
};

Button buttons[] = {
  {REMOTE_START_PIN, "show:start"},
  {REMOTE_STOP_PIN, "show:stop"},
};
sync_transport::Transport::Config transport_config = sync_transport::config("remote");
sync_transport::Transport transport(transport_config);
cue::Node node;

void send(const char *name) {
  if (kGatewayNode == 0) {
    if (Serial) {
      Serial.println("remote not configured: set CUE_COORDINATOR_NODE");
    }
    return;
  }
  cue::Message message;
  if (!node.makeCue(kGatewayNode, name, message) ||
      transport.trySend(message) != cue::SendResult::QUEUED) {
    if (Serial) Serial.printf("remote failed to queue %s\n", name);
    return;
  }
  if (Serial) {
    Serial.printf(
      "remote queued %s id=%llu\n",
      name,
      static_cast<unsigned long long>(message.id)
    );
  }
}

void updateButtons(uint32_t now) {
  for (Button &button : buttons) {
    const bool reading = digitalRead(button.pin);
    if (reading != button.reading) {
      button.reading = reading;
      button.changed_at = now;
    }
    if (reading != button.stable && now - button.changed_at >= kDebounceMs) {
      button.stable = reading;
      if (reading == LOW) send(button.cue);
    }
  }
}

}  // namespace

void setup() {
  for (const Button &button : buttons) pinMode(button.pin, INPUT_PULLUP);
  Serial.begin(115200);
  const bool ready = transport.begin();
  if (ready) {
    node.begin(transport.localNode(), esp_random());
    if (kGatewayNode != 0) transport.addPeer(kGatewayNode);
  }
  if (Serial) {
    Serial.printf(
      "sync remote %012llX coordinator=%012llX transport=%s status=%s\n",
      static_cast<unsigned long long>(node.source()),
      static_cast<unsigned long long>(kGatewayNode),
      sync_transport::name,
      ready ? "ready" : "unavailable"
    );
  }
}

void loop() {
  const uint32_t now = millis();
  transport.poll(now);
  updateButtons(now);

  cue::DeliveryReport report;
  while (transport.tryDelivery(report)) {
    if (Serial) {
      Serial.printf(
        "remote delivery status=%s attempts=%u latency_ms=%lu\n",
        report.status == cue::DeliveryStatus::DELIVERED ? "delivered" : "timeout",
        report.attempts,
        static_cast<unsigned long>(report.latency_ms)
      );
    }
  }
  delay(1);
}

