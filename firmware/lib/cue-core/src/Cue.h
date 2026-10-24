#pragma once

#include <stddef.h>
#include <stdint.h>

namespace cue {

constexpr size_t kNameCapacity = 32;
constexpr size_t kWireSize = 64;
constexpr uint64_t kBroadcastNode = 0xffffffffffffULL;

enum class PacketKind : uint8_t {
  CUE = 1,
  ACK = 2,
  HELLO = 3,
};

struct Message {
  uint64_t source = 0;
  uint64_t destination = 0;
  uint64_t id = 0;
  char name[kNameCapacity] = {};
};

// Packet is the protocol's explicit wire-level representation. Applications
// normally deal only in Message; ACK and HELLO packets are transport details.
struct Packet {
  PacketKind kind = PacketKind::CUE;
  Message message;
  bool has_reported_rssi = false;
  int8_t reported_rssi = 0;
};

// The wire format is explicit rather than a packed C struct so transports do
// not depend on compiler padding or CPU endianness.
bool encode(const Packet &packet, uint8_t *output, size_t output_size);
bool decode(const uint8_t *input, size_t input_size, Packet &packet);
bool setName(Message &message, const char *name);
bool isValidNode(uint64_t node);
bool isValid(const Message &message);

Packet makeCuePacket(const Message &message);
Packet makeAckPacket(
  uint64_t source,
  uint64_t destination,
  uint64_t acknowledged_id,
  int8_t reported_rssi,
  bool has_reported_rssi
);
Packet makeHelloPacket(uint64_t source, const char *service = nullptr);

template <size_t Capacity>
class DuplicateCache {
 public:
  static_assert(Capacity > 0, "duplicate cache must have at least one entry");

  // Returns true the first time an ID is seen and false for a duplicate.
  bool remember(uint64_t source, uint64_t id) {
    if (contains(source, id)) {
      return false;
    }

    entries_[next_].source = source;
    entries_[next_].id = id;
    next_ = (next_ + 1) % Capacity;
    if (count_ < Capacity) {
      ++count_;
    }
    return true;
  }

  bool contains(uint64_t source, uint64_t id) const {
    for (size_t index = 0; index < count_; ++index) {
      if (entries_[index].source == source && entries_[index].id == id) {
        return true;
      }
    }
    return false;
  }

  void clear() {
    count_ = 0;
    next_ = 0;
  }

 private:
  struct Entry {
    uint64_t source = 0;
    uint64_t id = 0;
  };

  Entry entries_[Capacity] = {};
  size_t count_ = 0;
  size_t next_ = 0;
};

class Node {
 public:
  void begin(uint64_t source, uint32_t session);
  bool makeCue(uint64_t destination, const char *name, Message &message);

  // Validates addressing and deduplicates a received cue. It performs no I/O
  // and never invokes application code.
  bool accept(const Message &message);

  uint64_t source() const { return source_; }

 private:
  uint64_t source_ = 0;
  uint32_t session_ = 0;
  uint32_t counter_ = 0;
  DuplicateCache<64> received_;
};

}  // namespace cue
