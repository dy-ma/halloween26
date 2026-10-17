#include <Arduino.h>
#include <Cue.h>
#include <EspNowTransport.h>

#include <stdlib.h>
#include <string.h>

namespace {

constexpr uint8_t kEspNowChannel = 1;
constexpr size_t kMaxReceivedPerLoop = 8;
constexpr size_t kMaxSerialBytesPerLoop = 128;
constexpr size_t kSerialLineCapacity = 192;

cue::EspNowTransport transport;
cue::Node node;
uint32_t last_reported_rx_drops = 0;
char serial_line[kSerialLineCapacity] = {};
size_t serial_line_length = 0;

void emitResult(uint64_t request, const char *status, uint64_t sequence = 0) {
  if (sequence == 0) {
    Serial.printf(
      "{\"type\":\"emit_result\",\"request\":%llu,\"status\":\"%s\"}\n",
      static_cast<unsigned long long>(request),
      status
    );
  } else {
    Serial.printf(
      "{\"type\":\"emit_result\",\"request\":%llu,\"status\":\"%s\",\"sequence\":%llu}\n",
      static_cast<unsigned long long>(request),
      status,
      static_cast<unsigned long long>(sequence)
    );
  }
}

bool parseUnsignedField(const char *line, const char *field, uint64_t &value) {
  const char *start = strstr(line, field);
  if (start == nullptr) {
    return false;
  }
  start += strlen(field);
  char *end = nullptr;
  value = strtoull(start, &end, 10);
  return end != start;
}

bool parseEventField(const char *line, char *event, size_t capacity) {
  const char *start = strstr(line, "\"event\":\"");
  if (start == nullptr) {
    return false;
  }
  start += strlen("\"event\":\"");
  const char *end = strchr(start, '"');
  const char *escape = strchr(start, '\\');
  if (end == nullptr || (escape != nullptr && escape < end)) {
    return false;
  }
  const size_t length = static_cast<size_t>(end - start);
  if (length == 0 || length >= capacity) {
    return false;
  }
  memcpy(event, start, length);
  event[length] = '\0';
  return true;
}

void handleSerialCommand(const char *line) {
  uint64_t request = 0;
  char event[cue::kNameCapacity] = {};
  if (strstr(line, "\"type\":\"emit\"") == nullptr ||
      !parseUnsignedField(line, "\"request\":", request) ||
      !parseEventField(line, event, sizeof(event))) {
    emitResult(request, "invalid");
    return;
  }

  uint64_t peer = 0;
  if (!transport.firstPeer(peer)) {
    emitResult(request, "peer_unavailable");
    return;
  }

  cue::Message message;
  if (!node.makeCue(peer, event, message)) {
    emitResult(request, "invalid");
    return;
  }
  const cue::SendResult result = transport.trySend(message);
  if (result == cue::SendResult::QUEUED) {
    emitResult(request, "queued", message.id);
  } else if (result == cue::SendResult::QUEUE_FULL) {
    emitResult(request, "queue_full");
  } else if (result == cue::SendResult::NOT_READY) {
    emitResult(request, "not_ready");
  } else {
    emitResult(request, "invalid");
  }
}

void receiveSerialCommands() {
  size_t handled = 0;
  while (handled < kMaxSerialBytesPerLoop && Serial.available() > 0) {
    ++handled;
    const int byte = Serial.read();
    if (byte < 0) {
      return;
    }
    if (byte == '\n') {
      serial_line[serial_line_length] = '\0';
      handleSerialCommand(serial_line);
      serial_line_length = 0;
      continue;
    }
    if (byte == '\r') {
      continue;
    }
    if (serial_line_length + 1 < sizeof(serial_line)) {
      serial_line[serial_line_length++] = static_cast<char>(byte);
    } else {
      serial_line_length = 0;
      emitResult(0, "line_too_long");
    }
  }
}

void emitSerial(
  const cue::Message &message,
  const cue::ReceiveMetadata &metadata
) {
  if (metadata.has_rssi) {
    Serial.printf(
      "{\"event\":\"%s\",\"sequence\":%llu,\"source\":\"%012llX\",\"rssi\":%d}\n",
      message.name,
      static_cast<unsigned long long>(message.id),
      static_cast<unsigned long long>(message.source & 0xffffffffffffULL),
      metadata.rssi
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

}  // namespace

void setup() {
  Serial.begin(115200);
  const bool radio_ready = transport.begin();
  if (radio_ready) {
    node.begin(transport.localNode(), esp_random());
  }
  Serial.printf(
    "cue Pi gateway %012llX ready; ESP-NOW channel %u; radio %s\n",
    static_cast<unsigned long long>(node.source() & 0xffffffffffffULL),
    kEspNowChannel,
    radio_ready ? "ready" : "unavailable"
  );
}

void loop() {
  receiveSerialCommands();
  transport.poll(millis());

  cue::ReceivedCue received;
  size_t handled = 0;
  while (handled < kMaxReceivedPerLoop && transport.tryReceive(received)) {
    ++handled;
    if (node.accept(received.message)) {
      emitSerial(received.message, received.metadata);
    }
  }

  cue::DeliveryReport report;
  while (transport.tryDelivery(report)) {
    Serial.printf(
      "{\"type\":\"delivery\",\"sequence\":%llu,\"destination\":\"%012llX\","
      "\"status\":\"%s\",\"attempts\":%u,\"latency_ms\":%lu,"
      "\"remote_rssi\":%d,\"ack_rssi\":%d}\n",
      static_cast<unsigned long long>(report.message_id),
      static_cast<unsigned long long>(report.destination),
      report.status == cue::DeliveryStatus::DELIVERED ? "delivered" : "timeout",
      report.attempts,
      static_cast<unsigned long>(report.latency_ms),
      report.has_remote_rssi ? report.remote_rssi : 0,
      report.has_ack_rssi ? report.ack_rssi : 0
    );
  }

  const uint32_t rx_drops = transport.droppedReceiveCount();
  if (rx_drops != last_reported_rx_drops) {
    Serial.printf("cue receive queue dropped %lu packet(s)\n", rx_drops);
    last_reported_rx_drops = rx_drops;
  }

  // Yield to FreeRTOS rather than keeping this core busy while the gateway is
  // waiting for its next radio packet.
  delay(1);
}
