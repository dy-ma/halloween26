#include <Arduino.h>
#include <Cue.h>
#include <EspNowTransport.h>

namespace {

constexpr uint8_t kEspNowChannel = 1;
constexpr size_t kMaxReceivedPerLoop = 8;
constexpr uint32_t kExpectedIntervalMs = 100;
constexpr uint32_t kLossDetectionGraceMs = 50;

cue::EspNowTransport::Config transport_config = {
  kEspNowChannel,
  1,
  100,
  100,
  1000,
  true,
};
cue::EspNowTransport transport(transport_config);
cue::Node node;

enum class OutputMode { PLOTTER, LOG };
OutputMode output_mode = OutputMode::PLOTTER;

bool have_stream = false;
uint64_t active_source = 0;
uint32_t active_session = 0;
uint32_t last_sequence = 0;
uint32_t received_total = 0;
uint32_t lost_total = 0;
uint32_t last_received_at = 0;
uint32_t next_plot_at = 0;
uint32_t latest_missed = 0;
uint32_t latest_sequence_step = 0;
int latest_rssi = -100;

void resetStream(const cue::Message &message) {
  active_source = message.source;
  active_session = static_cast<uint32_t>(message.id >> 32);
  last_sequence = 0;
  received_total = 0;
  lost_total = 0;
  have_stream = true;
}

void updateOutputMode() {
  while (Serial.available() > 0) {
    const char command = static_cast<char>(Serial.read());
    if (command == 'p' || command == 'P') {
      output_mode = OutputMode::PLOTTER;
      next_plot_at = millis();
    } else if (command == 'l' || command == 'L') {
      output_mode = OutputMode::LOG;
    }
  }
}

uint32_t pendingMissing(uint32_t now_ms) {
  if (!have_stream) {
    return 0;
  }

  const uint32_t silence_ms = now_ms - last_received_at;
  if (silence_ms <= kExpectedIntervalMs + kLossDetectionGraceMs) {
    return 0;
  }
  return (silence_ms - kLossDetectionGraceMs) / kExpectedIntervalMs;
}

float lossPercent(uint32_t pending_missing = 0) {
  const uint32_t expected_total =
    received_total + lost_total + pending_missing;
  return expected_total == 0
    ? 0.0f
    : 100.0f * static_cast<float>(lost_total + pending_missing) /
      static_cast<float>(expected_total);
}

void emitPlotter(uint32_t now_ms) {
  if (static_cast<int32_t>(now_ms - next_plot_at) < 0) {
    return;
  }
  next_plot_at += kExpectedIntervalMs;
  if (static_cast<int32_t>(now_ms - next_plot_at) >= 0) {
    next_plot_at = now_ms + kExpectedIntervalMs;
  }

  const uint32_t pending_missing = pendingMissing(now_ms);
  const bool link_alive = have_stream &&
    now_ms - last_received_at <= kExpectedIntervalMs + kLossDetectionGraceMs;
  Serial.printf(
    "rssi_dbm:%d loss_percent:%.3f link_alive:%u missed:%lu "
    "sequence_step:%lu\n",
    latest_rssi,
    static_cast<double>(lossPercent(pending_missing)),
    link_alive ? 100U : 0U,
    static_cast<unsigned long>(latest_missed),
    static_cast<unsigned long>(latest_sequence_step)
  );
  latest_missed = 0;
  latest_sequence_step = 0;
}

void handleProbe(const cue::ReceivedCue &received) {
  if (strcmp(received.message.name, "range:test") != 0) {
    return;
  }

  const uint32_t session = static_cast<uint32_t>(received.message.id >> 32);
  const uint32_t sequence = static_cast<uint32_t>(received.message.id);
  if (!have_stream || received.message.source != active_source ||
      session != active_session) {
    resetStream(received.message);
  }

  // ESP-NOW normally preserves order for a sender. Ignore an old or duplicate
  // packet instead of letting it corrupt the cumulative loss calculation.
  const uint32_t sequence_step = last_sequence == 0 ? 1 : sequence - last_sequence;
  if (last_sequence != 0 && static_cast<int32_t>(sequence_step) <= 0) {
    return;
  }

  const uint32_t missed = sequence_step > 1 ? sequence_step - 1 : 0;
  lost_total += missed;
  ++received_total;
  last_sequence = sequence;
  const int rssi = received.metadata.has_rssi ? received.metadata.rssi : 0;
  last_received_at = millis();
  latest_rssi = rssi;
  latest_missed = missed;
  latest_sequence_step = sequence_step;

  if (output_mode == OutputMode::LOG) {
    Serial.printf(
      "ms=%lu source=%012llX session=%08lX sequence=%lu rssi=%d "
      "received=%lu lost=%lu loss_percent=%.3f\n",
      static_cast<unsigned long>(last_received_at),
      static_cast<unsigned long long>(active_source & 0xffffffffffffULL),
      static_cast<unsigned long>(active_session),
      static_cast<unsigned long>(sequence),
      rssi,
      static_cast<unsigned long>(received_total),
      static_cast<unsigned long>(lost_total),
      static_cast<double>(lossPercent())
    );
  }
}

}  // namespace

void setup() {
  Serial.begin(115200);
  next_plot_at = millis();
  if (!transport.begin()) {
    Serial.println("receiver_error:1");
  } else {
    node.begin(transport.localNode(), esp_random());
  }
}

void loop() {
  transport.poll(millis());
  updateOutputMode();

  cue::ReceivedCue received;
  size_t handled = 0;
  while (handled < kMaxReceivedPerLoop && transport.tryReceive(received)) {
    ++handled;
    if (node.accept(received.message)) {
      handleProbe(received);
    }
  }

  if (output_mode == OutputMode::PLOTTER) {
    // Keep advancing the plot during a complete outage. loss_percent includes
    // a clock-based estimate until the next sequence number makes it exact.
    emitPlotter(millis());
  }

  delay(1);
}
