#include <Arduino.h>
#include <Cue.h>
#include <EspNowTransport.h>

#include <stdlib.h>
#include <string.h>

namespace {

constexpr size_t kSerialLineCapacity = 256;
constexpr size_t kMaxSerialBytesPerLoop = 192;
constexpr size_t kMaxReceivedPerLoop = 8;
constexpr uint32_t kPeerReportIntervalMs = 1000;
constexpr uint32_t kPeerOnlineTimeoutMs = 3000;

cue::EspNowTransport::Config transport_config(1, 5, 70, 240, 1000, true, "gateway");
cue::EspNowTransport transport(transport_config);
cue::Node node;
char serial_line[kSerialLineCapacity] = {};
size_t serial_line_length = 0;
uint32_t next_peer_report_at = 0;

bool due(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

bool parseUnsignedField(const char *line, const char *field, uint64_t &value) {
  const char *start = strstr(line, field);
  if (start == nullptr) return false;
  start += strlen(field);
  char *end = nullptr;
  value = strtoull(start, &end, 10);
  return end != start;
}

bool parseStringField(
  const char *line,
  const char *field,
  char *value,
  size_t capacity
) {
  const char *start = strstr(line, field);
  if (start == nullptr) return false;
  start += strlen(field);
  const char *end = strchr(start, '"');
  const char *escape = strchr(start, '\\');
  if (end == nullptr || (escape != nullptr && escape < end)) return false;
  const size_t length = static_cast<size_t>(end - start);
  if (length == 0 || length >= capacity) return false;
  memcpy(value, start, length);
  value[length] = '\0';
  return true;
}

bool parseNode(const char *value, uint64_t &node_id) {
  if (strlen(value) != 12) return false;
  char *end = nullptr;
  node_id = strtoull(value, &end, 16);
  return end != value && *end == '\0' && cue::isValidNode(node_id) &&
    node_id != cue::kBroadcastNode;
}

void emitResult(
  uint64_t request,
  const char *status,
  uint64_t destination = 0,
  uint64_t sequence = 0
) {
  if (!Serial) return;
  Serial.printf(
    "{\"type\":\"emit_result\",\"request\":%llu,\"status\":\"%s\"",
    static_cast<unsigned long long>(request),
    status
  );
  if (destination != 0) {
    Serial.printf(
      ",\"destination\":\"%012llX\"",
      static_cast<unsigned long long>(destination)
    );
  }
  if (sequence != 0) {
    Serial.printf(
      ",\"sequence\":%llu",
      static_cast<unsigned long long>(sequence)
    );
  }
  Serial.println("}");
}

void emitStatus() {
  if (!Serial) return;
  Serial.printf(
    "{\"type\":\"status\",\"node\":\"%012llX\",\"peers\":%u}\n",
    static_cast<unsigned long long>(node.source()),
    static_cast<unsigned>(transport.peerCount())
  );
}

void emitPeer(
  uint64_t peer_node,
  const char *service,
  const char *transport_name,
  bool has_rssi,
  int8_t rssi
) {
  if (!Serial) return;
  Serial.printf(
    "{\"type\":\"peer\",\"node\":\"%012llX\",\"service\":\"%s\","
    "\"transport\":\"%s\"",
    static_cast<unsigned long long>(peer_node),
    service != nullptr && service[0] != '\0' ? service : "unknown",
    transport_name
  );
  if (has_rssi) Serial.printf(",\"rssi\":%d", rssi);
  Serial.println("}");
}

void emitPeers(uint32_t now) {
  next_peer_report_at = now + kPeerReportIntervalMs;
  if (!Serial) return;
  emitPeer(node.source(), "gateway", "usb", false, 0);
  cue::EspNowTransport::PeerInfo peer;
  for (size_t index = 0; transport.peerAt(index, peer); ++index) {
    if (static_cast<uint32_t>(now - peer.last_seen_ms) > kPeerOnlineTimeoutMs) {
      continue;
    }
    emitPeer(peer.node, peer.service, "esp-now", peer.has_rssi, peer.rssi);
  }
}

void handleSerialCommand(const char *line) {
  if (strstr(line, "\"type\":\"status\"") != nullptr) {
    emitStatus();
    emitPeers(millis());
    return;
  }

  uint64_t request = 0;
  char event[cue::kNameCapacity] = {};
  char destination_text[16] = {};
  uint64_t destination = 0;
  if (strstr(line, "\"type\":\"emit\"") == nullptr ||
      !parseUnsignedField(line, "\"request\":", request) ||
      !parseStringField(
        line,
        "\"destination\":\"",
        destination_text,
        sizeof(destination_text)
      ) ||
      !parseNode(destination_text, destination) ||
      !parseStringField(line, "\"event\":\"", event, sizeof(event))) {
    emitResult(request, "invalid");
    return;
  }

  cue::Message message;
  if (!node.makeCue(destination, event, message)) {
    emitResult(request, "invalid", destination);
    return;
  }
  uint64_t tracked_id = 0;
  if (parseUnsignedField(line, "\"message_id\":", tracked_id) && tracked_id != 0) {
    message.id = tracked_id;
  }
  const cue::SendResult result = transport.trySend(message);
  switch (result) {
    case cue::SendResult::QUEUED:
      emitResult(request, "queued", destination, message.id);
      break;
    case cue::SendResult::QUEUE_FULL:
      emitResult(request, "queue_full", destination);
      break;
    case cue::SendResult::PEER_UNAVAILABLE:
      emitResult(request, "peer_unavailable", destination);
      break;
    case cue::SendResult::NOT_READY:
      emitResult(request, "not_ready", destination);
      break;
    default:
      emitResult(request, "invalid", destination);
      break;
  }
}

void receiveSerialCommands() {
  if (!Serial) return;
  size_t handled = 0;
  while (handled < kMaxSerialBytesPerLoop && Serial.available() > 0) {
    ++handled;
    const int byte = Serial.read();
    if (byte < 0) return;
    if (byte == '\n') {
      serial_line[serial_line_length] = '\0';
      handleSerialCommand(serial_line);
      serial_line_length = 0;
    } else if (byte != '\r') {
      if (serial_line_length + 1 < sizeof(serial_line)) {
        serial_line[serial_line_length++] = static_cast<char>(byte);
      } else {
        serial_line_length = 0;
        emitResult(0, "line_too_long");
      }
    }
  }
}

void emitIncoming(
  const cue::Message &message,
  const cue::ReceiveMetadata &metadata
) {
  if (!Serial) return;
  Serial.printf(
    "{\"event\":\"%s\",\"sequence\":%llu,\"source\":\"%012llX\"",
    message.name,
    static_cast<unsigned long long>(message.id),
    static_cast<unsigned long long>(message.source)
  );
  if (metadata.has_rssi) Serial.printf(",\"rssi\":%d", metadata.rssi);
  Serial.println("}");
}

}  // namespace

void setup() {
  Serial.begin(115200);
  const bool ready = transport.begin();
  if (ready) node.begin(transport.localNode(), esp_random());
  if (Serial) {
    Serial.printf(
      "sync gateway %012llX radio=%s\n",
      static_cast<unsigned long long>(node.source()),
      ready ? "ready" : "unavailable"
    );
  }
  emitPeers(millis());
}

void loop() {
  const uint32_t now = millis();
  receiveSerialCommands();
  transport.poll(now);

  cue::ReceivedCue received;
  size_t handled = 0;
  while (handled++ < kMaxReceivedPerLoop && transport.tryReceive(received)) {
    if (node.accept(received.message)) emitIncoming(received.message, received.metadata);
  }

  cue::DeliveryReport report;
  while (transport.tryDelivery(report)) {
    if (Serial) {
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
  }
  if (due(now, next_peer_report_at)) emitPeers(now);
  delay(1);
}

