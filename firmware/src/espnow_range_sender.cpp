#include <Arduino.h>
#include <Cue.h>
#include <CueTransport.h>
#include <EspNowTransport.h>

namespace {

constexpr uint8_t kEspNowChannel = 1;
constexpr uint32_t kSendIntervalMs = 100;

// Range tests must send each sequence number exactly once. The normal Cue
// applications repeat packets for reliability, which would hide packet loss.
cue::EspNowTransport::Config transport_config = {
  kEspNowChannel,
  1,    // one over-the-air packet per sequence number
  100,  // wait this long for its ACK before recording failure
  100,
  1000,
  true,
};
cue::EspNowTransport transport(transport_config);
cue::Node node;
uint32_t next_send_at = 0;

bool isDue(uint32_t now_ms, uint32_t deadline_ms) {
  return static_cast<int32_t>(now_ms - deadline_ms) >= 0;
}

void sendProbe() {
  uint64_t peer = 0;
  if (!transport.firstPeer(peer)) {
    return;
  }
  cue::Message message;
  if (!node.makeCue(peer, "range:test", message)) {
    Serial.println("sender_error:1");
    return;
  }

  const cue::SendResult result = transport.trySend(message);
  const uint32_t sequence = static_cast<uint32_t>(message.id);
  Serial.printf(
    "sequence:%lu tx_rejected:%u radio_errors:%lu\n",
    static_cast<unsigned long>(sequence),
    result == cue::SendResult::QUEUED ? 0U : 1U,
    static_cast<unsigned long>(transport.radioSendErrorCount())
  );
}

}  // namespace

void setup() {
  Serial.begin(115200);
  // Hardware CDC can otherwise wait about two seconds when the USB host is
  // present but no Serial Monitor is draining its transmit buffer. Diagnostic
  // output must never change the radio test cadence.
  Serial.setTxTimeoutMs(0);
  if (!transport.begin()) {
    // Keep this numeric so both Serial Monitor and Serial Plotter can show it.
    Serial.println("sender_error:1");
    return;
  }
  node.begin(transport.localNode(), esp_random());

  next_send_at = millis();
}

void loop() {
  const uint32_t now_ms = millis();
  transport.poll(now_ms);

  if (isDue(now_ms, next_send_at)) {
    sendProbe();
    next_send_at += kSendIntervalMs;

    // Do not send a burst after a long pause (for example, while USB serial is
    // reconnecting). Resume the 10 Hz schedule from the current time instead.
    if (isDue(now_ms, next_send_at + kSendIntervalMs)) {
      next_send_at = now_ms + kSendIntervalMs;
    }
  }

  delay(1);
}
