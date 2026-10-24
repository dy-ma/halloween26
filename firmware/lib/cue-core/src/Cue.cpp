#include "Cue.h"

#include <string.h>

namespace cue {
namespace {

constexpr uint8_t kMagic[] = {'C', 'U', 'E', '2'};
constexpr uint8_t kVersion = 2;
constexpr uint8_t kHasReportedRssi = 1 << 0;
constexpr size_t kNameOffset = 32;

void writeU64(uint8_t *output, uint64_t value) {
  for (size_t index = 0; index < 8; ++index) {
    output[index] = static_cast<uint8_t>(value >> (index * 8));
  }
}

uint64_t readU64(const uint8_t *input) {
  uint64_t value = 0;
  for (size_t index = 0; index < 8; ++index) {
    value |= static_cast<uint64_t>(input[index]) << (index * 8);
  }
  return value;
}

size_t boundedLength(const char *value, size_t capacity) {
  size_t length = 0;
  while (length < capacity && value[length] != '\0') {
    ++length;
  }
  return length;
}

bool isValidPacket(const Packet &packet) {
  if (!isValidNode(packet.message.source) ||
      packet.message.source == kBroadcastNode) {
    return false;
  }

  switch (packet.kind) {
    case PacketKind::CUE:
      return isValid(packet.message);
    case PacketKind::ACK:
      return isValidNode(packet.message.destination) &&
        packet.message.destination != kBroadcastNode &&
        packet.message.source != packet.message.destination &&
        packet.message.id != 0;
    case PacketKind::HELLO:
      return packet.message.destination == kBroadcastNode &&
        packet.message.id == 0 &&
        boundedLength(packet.message.name, kNameCapacity) < kNameCapacity;
  }
  return false;
}

}  // namespace

bool setName(Message &message, const char *name) {
  if (name == nullptr) {
    return false;
  }

  const size_t length = boundedLength(name, kNameCapacity);
  if (length == 0 || length >= kNameCapacity) {
    return false;
  }

  memset(message.name, 0, sizeof(message.name));
  memcpy(message.name, name, length);
  return true;
}

bool isValidNode(uint64_t node) {
  return node != 0 && (node & 0xffff000000000000ULL) == 0;
}

bool isValid(const Message &message) {
  if (!isValidNode(message.source) || !isValidNode(message.destination) ||
      message.destination == kBroadcastNode ||
      message.source == message.destination || message.id == 0) {
    return false;
  }
  const size_t length = boundedLength(message.name, kNameCapacity);
  return length > 0 && length < kNameCapacity;
}

Packet makeCuePacket(const Message &message) {
  Packet packet = {};
  packet.kind = PacketKind::CUE;
  packet.message = message;
  return packet;
}

Packet makeAckPacket(
  uint64_t source,
  uint64_t destination,
  uint64_t acknowledged_id,
  int8_t reported_rssi,
  bool has_reported_rssi
) {
  Packet packet = {};
  packet.kind = PacketKind::ACK;
  packet.message.source = source;
  packet.message.destination = destination;
  packet.message.id = acknowledged_id;
  packet.has_reported_rssi = has_reported_rssi;
  packet.reported_rssi = reported_rssi;
  return packet;
}

Packet makeHelloPacket(uint64_t source, const char *service) {
  Packet packet = {};
  packet.kind = PacketKind::HELLO;
  packet.message.source = source;
  packet.message.destination = kBroadcastNode;
  if (service != nullptr && service[0] != '\0') {
    setName(packet.message, service);
  }
  return packet;
}

bool encode(const Packet &packet, uint8_t *output, size_t output_size) {
  if (output == nullptr || output_size < kWireSize || !isValidPacket(packet)) {
    return false;
  }

  memset(output, 0, kWireSize);
  memcpy(output, kMagic, sizeof(kMagic));
  output[4] = kVersion;
  output[5] = static_cast<uint8_t>(packet.kind);
  output[6] = packet.has_reported_rssi ? kHasReportedRssi : 0;
  output[7] = static_cast<uint8_t>(packet.reported_rssi);
  writeU64(output + 8, packet.message.source);
  writeU64(output + 16, packet.message.destination);
  writeU64(output + 24, packet.message.id);
  if (packet.kind == PacketKind::CUE || packet.kind == PacketKind::HELLO) {
    memcpy(output + kNameOffset, packet.message.name, sizeof(packet.message.name));
  }
  return true;
}

bool decode(const uint8_t *input, size_t input_size, Packet &packet) {
  if (input == nullptr || input_size != kWireSize ||
      memcmp(input, kMagic, sizeof(kMagic)) != 0 || input[4] != kVersion) {
    return false;
  }

  Packet decoded = {};
  decoded.kind = static_cast<PacketKind>(input[5]);
  decoded.has_reported_rssi = (input[6] & kHasReportedRssi) != 0;
  decoded.reported_rssi = static_cast<int8_t>(input[7]);
  decoded.message.source = readU64(input + 8);
  decoded.message.destination = readU64(input + 16);
  decoded.message.id = readU64(input + 24);
  if (decoded.kind == PacketKind::CUE || decoded.kind == PacketKind::HELLO) {
    memcpy(decoded.message.name, input + kNameOffset, sizeof(decoded.message.name));
  }
  if (!isValidPacket(decoded)) {
    return false;
  }

  packet = decoded;
  return true;
}

void Node::begin(uint64_t source, uint32_t session) {
  source_ = isValidNode(source) && source != kBroadcastNode ? source : 1;
  session_ = session == 0 ? 1 : session;
  counter_ = 0;
  received_.clear();
}

bool Node::makeCue(
  uint64_t destination,
  const char *name,
  Message &message
) {
  Message created = {};
  created.source = source_;
  created.destination = destination;
  ++counter_;
  if (counter_ == 0) {
    ++counter_;
  }
  created.id = (static_cast<uint64_t>(session_) << 32) | counter_;
  if (!setName(created, name) || !isValid(created)) {
    return false;
  }
  message = created;
  return true;
}

bool Node::accept(const Message &message) {
  return isValid(message) && message.destination == source_ &&
    received_.remember(message.source, message.id);
}

}  // namespace cue
