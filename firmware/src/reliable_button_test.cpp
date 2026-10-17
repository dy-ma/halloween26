#include <Arduino.h>
#include <Cue.h>
#include <CueTransport.h>
#include <EspNowTransport.h>

namespace {

constexpr uint8_t kEspNowChannel = 1;
constexpr uint8_t kButtonPin = 0;
constexpr uint8_t kLedPin = 21;
constexpr uint32_t kDebounceMs = 30;
constexpr uint32_t kReceivedLedMs = 1000;
constexpr uint32_t kDeliveredLedMs = 100;
constexpr size_t kMaxEventsPerLoop = 8;

cue::EspNowTransport::Config transport_config(
  kEspNowChannel,
  5,     // total attempts before declaring a delivery failure
  70,    // first ACK timeout
  240,   // maximum exponential retry interval
  1000,  // peer discovery broadcast interval
  true   // ESP32-S3 long-range radio mode
);
cue::EspNowTransport transport(transport_config);
cue::Node node;

bool last_button_reading = HIGH;
bool stable_button_state = HIGH;
uint32_t button_changed_at = 0;
uint32_t led_off_at = 0;
uint8_t failure_toggles_remaining = 0;
uint32_t next_failure_toggle_at = 0;
size_t last_peer_count = 0;

bool isDue(uint32_t now_ms, uint32_t deadline_ms) {
  return static_cast<int32_t>(now_ms - deadline_ms) >= 0;
}

void setLed(bool on) {
  // The XIAO ESP32-S3 user LED is active-low.
  digitalWrite(kLedPin, on ? LOW : HIGH);
}

void pulseLed(uint32_t duration_ms) {
  failure_toggles_remaining = 0;
  setLed(true);
  led_off_at = millis() + duration_ms;
}

void startFailurePattern() {
  // Three visible flashes without ever blocking radio processing.
  failure_toggles_remaining = 6;
  next_failure_toggle_at = millis();
  led_off_at = 0;
}

void updateLed(uint32_t now_ms) {
  if (failure_toggles_remaining > 0 && isDue(now_ms, next_failure_toggle_at)) {
    const bool turn_on = (failure_toggles_remaining % 2) == 0;
    setLed(turn_on);
    --failure_toggles_remaining;
    next_failure_toggle_at = now_ms + 120;
    if (failure_toggles_remaining == 0) {
      setLed(false);
    }
    return;
  }
  if (led_off_at != 0 && isDue(now_ms, led_off_at)) {
    setLed(false);
    led_off_at = 0;
  }
}

void sendButtonCue() {
  uint64_t peer = 0;
  if (!transport.firstPeer(peer)) {
    Serial.println("send failed: no peer discovered yet");
    startFailurePattern();
    return;
  }

  cue::Message message;
  if (!node.makeCue(peer, "test:button", message)) {
    Serial.println("send failed: could not create cue");
    startFailurePattern();
    return;
  }

  const cue::SendResult result = transport.trySend(message);
  if (result != cue::SendResult::QUEUED) {
    Serial.printf("send failed: transport result=%u\n", static_cast<unsigned>(result));
    startFailurePattern();
    return;
  }

  Serial.printf(
    "SEND id=%08lX:%lu destination=%012llX\n",
    static_cast<unsigned long>(message.id >> 32),
    static_cast<unsigned long>(message.id),
    static_cast<unsigned long long>(peer)
  );
}

void updateButton(uint32_t now_ms) {
  const bool reading = digitalRead(kButtonPin);
  if (reading != last_button_reading) {
    last_button_reading = reading;
    button_changed_at = now_ms;
  }

  if (reading != stable_button_state &&
      now_ms - button_changed_at >= kDebounceMs) {
    stable_button_state = reading;
    if (stable_button_state == LOW) {
      sendButtonCue();
    }
  }
}

void receiveCues() {
  cue::ReceivedCue received;
  size_t handled = 0;
  while (handled < kMaxEventsPerLoop && transport.tryReceive(received)) {
    ++handled;
    if (!node.accept(received.message)) {
      continue;
    }
    pulseLed(kReceivedLedMs);
    if (received.metadata.has_rssi) {
      Serial.printf(
        "RECEIVED id=%08lX:%lu source=%012llX rssi=%d\n",
        static_cast<unsigned long>(received.message.id >> 32),
        static_cast<unsigned long>(received.message.id),
        static_cast<unsigned long long>(received.message.source),
        received.metadata.rssi
      );
    } else {
      Serial.printf(
        "RECEIVED id=%08lX:%lu source=%012llX rssi=unavailable\n",
        static_cast<unsigned long>(received.message.id >> 32),
        static_cast<unsigned long>(received.message.id),
        static_cast<unsigned long long>(received.message.source)
      );
    }
  }
}

void receiveDeliveryReports() {
  cue::DeliveryReport report;
  size_t handled = 0;
  while (handled < kMaxEventsPerLoop && transport.tryDelivery(report)) {
    ++handled;
    if (report.status == cue::DeliveryStatus::DELIVERED) {
      pulseLed(kDeliveredLedMs);
      Serial.printf(
        "DELIVERED id=%08lX:%lu destination=%012llX attempts=%u "
        "latency_ms=%lu remote_rssi=%d ack_rssi=%d\n",
        static_cast<unsigned long>(report.message_id >> 32),
        static_cast<unsigned long>(report.message_id),
        static_cast<unsigned long long>(report.destination),
        report.attempts,
        static_cast<unsigned long>(report.latency_ms),
        report.has_remote_rssi ? report.remote_rssi : 0,
        report.has_ack_rssi ? report.ack_rssi : 0
      );
    } else {
      startFailurePattern();
      Serial.printf(
        "TIMEOUT id=%08lX:%lu destination=%012llX attempts=%u "
        "elapsed_ms=%lu\n",
        static_cast<unsigned long>(report.message_id >> 32),
        static_cast<unsigned long>(report.message_id),
        static_cast<unsigned long long>(report.destination),
        report.attempts,
        static_cast<unsigned long>(report.latency_ms)
      );
    }
  }
}

void reportPeerChanges() {
  const size_t peer_count = transport.peerCount();
  if (peer_count == last_peer_count) {
    return;
  }
  last_peer_count = peer_count;
  uint64_t peer = 0;
  if (transport.firstPeer(peer)) {
    Serial.printf(
      "PEER discovered=%012llX total=%u; ready for button presses\n",
      static_cast<unsigned long long>(peer),
      static_cast<unsigned>(peer_count)
    );
  }
}

}  // namespace

void setup() {
  pinMode(kButtonPin, INPUT_PULLUP);
  pinMode(kLedPin, OUTPUT);
  setLed(false);

  Serial.begin(115200);
  Serial.setTxTimeoutMs(0);
  const bool radio_ready = transport.begin();
  if (radio_ready) {
    node.begin(transport.localNode(), esp_random());
  }
  Serial.printf(
    "reliable button test node=%012llX channel=%u long_range=on radio=%s\n",
    static_cast<unsigned long long>(transport.localNode()),
    kEspNowChannel,
    radio_ready ? "ready" : "FAILED"
  );
  if (!radio_ready) {
    startFailurePattern();
  }
}

void loop() {
  const uint32_t now_ms = millis();
  transport.poll(now_ms);
  receiveCues();
  receiveDeliveryReports();
  updateButton(now_ms);
  updateLed(now_ms);
  reportPeerChanges();
  delay(1);
}
