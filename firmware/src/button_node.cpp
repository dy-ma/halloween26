#include <Arduino.h>
#include <Cue.h>
#include <CueTransport.h>
#include <EspNowTransport.h>

namespace {

constexpr uint8_t kEspNowChannel = 1;
constexpr uint32_t kDebounceMs = 30;
constexpr uint32_t kLedPulseMs = 180;
constexpr size_t kMaxReceivedPerLoop = 4;

#ifndef CUE_LED_PIN
#define CUE_LED_PIN 21
#endif

enum class LedColor { OFF, AMBER, GREEN, RED };

struct ButtonBinding {
  uint8_t pin;
  const char *cue_name;
  bool last_reading = HIGH;
  bool stable_state = HIGH;
  uint32_t changed_at = 0;
};

// Add button-to-cue mappings here. Each button is active-low and uses the
// internal pull-up resistor.
ButtonBinding buttons[] = {
  {0, "tractor:tipped"},
};

cue::EspNowTransport::Config transport_config(
  kEspNowChannel,
  5,    // maximum application-level delivery attempts
  70,   // first ACK timeout
  240,  // maximum retry interval
  1000,
  true
);
cue::EspNowTransport transport(transport_config);
cue::Node node;

bool led_on = false;
uint32_t led_off_at = 0;
uint32_t last_reported_rx_drops = 0;

bool isDue(uint32_t now_ms, uint32_t deadline_ms) {
  return static_cast<int32_t>(now_ms - deadline_ms) >= 0;
}

void setLed(LedColor color) {
  // The XIAO ESP32-S3 has a single active-low yellow user LED. Color still
  // describes the logical status for callers, but any non-OFF state lights it.
  digitalWrite(CUE_LED_PIN, color == LedColor::OFF ? HIGH : LOW);
}

void pulseLed(LedColor color) {
  setLed(color);
  led_on = color != LedColor::OFF;
  led_off_at = millis() + kLedPulseMs;
}

void emitSerial(
  const cue::Message &message,
  const cue::ReceiveMetadata *metadata = nullptr
) {
  if (metadata != nullptr && metadata->has_rssi) {
    Serial.printf(
      "{\"event\":\"%s\",\"sequence\":%llu,\"source\":\"%012llX\",\"rssi\":%d}\n",
      message.name,
      static_cast<unsigned long long>(message.id),
      static_cast<unsigned long long>(message.source & 0xffffffffffffULL),
      metadata->rssi
    );
  } else {
    Serial.printf(
      "{\"event\":\"%s\",\"sequence\":%llu,\"source\":\"%012llX\"}\n",
      message.name,
      static_cast<unsigned long long>(message.id),
      static_cast<unsigned long long>(message.source & 0xffffffffffffULL)
    );
  }
}

void sendCue(const char *name) {
  uint64_t peer = 0;
  if (!transport.firstPeer(peer)) {
    pulseLed(LedColor::RED);
    Serial.println("cue send rejected: no peer discovered");
    return;
  }
  cue::Message message;
  if (!node.makeCue(peer, name, message)) {
    pulseLed(LedColor::RED);
    return;
  }

  // A USB-connected button node can also act as the Pi's serial gateway.
  emitSerial(message);
  if (transport.trySend(message) == cue::SendResult::QUEUED) {
    pulseLed(LedColor::AMBER);
  } else {
    pulseLed(LedColor::RED);
    Serial.println("cue send rejected");
  }
}

void receiveDeliveryReports() {
  cue::DeliveryReport report;
  while (transport.tryDelivery(report)) {
    Serial.printf(
      "cue delivery id=%llu destination=%012llX status=%s attempts=%u "
      "latency_ms=%lu remote_rssi=%d ack_rssi=%d\n",
      static_cast<unsigned long long>(report.message_id),
      static_cast<unsigned long long>(report.destination),
      report.status == cue::DeliveryStatus::DELIVERED ? "delivered" : "timeout",
      report.attempts,
      static_cast<unsigned long>(report.latency_ms),
      report.has_remote_rssi ? report.remote_rssi : 0,
      report.has_ack_rssi ? report.ack_rssi : 0
    );
    pulseLed(
      report.status == cue::DeliveryStatus::DELIVERED
        ? LedColor::GREEN
        : LedColor::RED
    );
  }
}

void updateButtons(uint32_t now_ms) {
  for (ButtonBinding &button : buttons) {
    const bool reading = digitalRead(button.pin);
    if (reading != button.last_reading) {
      button.last_reading = reading;
      button.changed_at = now_ms;
    }

    if (reading != button.stable_state &&
        now_ms - button.changed_at >= kDebounceMs) {
      button.stable_state = reading;
      if (button.stable_state == LOW) {
        sendCue(button.cue_name);
      }
    }
  }
}

void receiveCues() {
  cue::ReceivedCue received;
  size_t handled = 0;
  while (handled < kMaxReceivedPerLoop && transport.tryReceive(received)) {
    ++handled;
    if (!node.accept(received.message)) {
      continue;
    }
    pulseLed(LedColor::GREEN);
    emitSerial(received.message, &received.metadata);
  }
}

void updateStatus(uint32_t now_ms) {
  if (led_on && isDue(now_ms, led_off_at)) {
    setLed(LedColor::OFF);
    led_on = false;
  }

  const uint32_t rx_drops = transport.droppedReceiveCount();
  if (rx_drops != last_reported_rx_drops) {
    Serial.printf("cue receive queue dropped %lu packet(s)\n", rx_drops);
    last_reported_rx_drops = rx_drops;
  }
}

}  // namespace

void setup() {
  for (const ButtonBinding &button : buttons) {
    pinMode(button.pin, INPUT_PULLUP);
  }
  pinMode(CUE_LED_PIN, OUTPUT);
  setLed(LedColor::OFF);

  Serial.begin(115200);
  const bool radio_ready = transport.begin();
  if (radio_ready) {
    node.begin(transport.localNode(), esp_random());
  }
  Serial.printf(
    "cue button node %012llX ready; ESP-NOW channel %u; radio %s\n",
    static_cast<unsigned long long>(node.source() & 0xffffffffffffULL),
    kEspNowChannel,
    radio_ready ? "ready" : "unavailable"
  );
  if (!radio_ready) {
    pulseLed(LedColor::RED);
  }
}

void loop() {
  const uint32_t now_ms = millis();
  transport.poll(now_ms);
  receiveCues();
  receiveDeliveryReports();
  updateButtons(now_ms);
  updateStatus(now_ms);

  // Give the FreeRTOS idle task time to run instead of keeping this core in a
  // full-speed polling loop. One millisecond is negligible for a human button
  // and does not change the transport's non-blocking contract.
  delay(1);
}
