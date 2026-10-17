#pragma once

#include <stdint.h>

#include <Cue.h>

namespace cue {

enum class SendResult : uint8_t {
  QUEUED,
  NOT_READY,
  QUEUE_FULL,
  INVALID_MESSAGE,
  PEER_UNAVAILABLE,
};

enum class DeliveryStatus : uint8_t {
  DELIVERED,
  TIMED_OUT,
};

struct ReceiveMetadata {
  bool has_rssi = false;
  int8_t rssi = 0;
};

struct ReceivedCue {
  Message message;
  ReceiveMetadata metadata;
};

struct DeliveryReport {
  uint64_t message_id = 0;
  uint64_t destination = 0;
  DeliveryStatus status = DeliveryStatus::TIMED_OUT;
  uint8_t attempts = 0;
  uint32_t latency_ms = 0;

  // remote_rssi is how strongly the recipient heard our cue. ack_rssi is how
  // strongly this board heard the recipient's ACK.
  bool has_remote_rssi = false;
  int8_t remote_rssi = 0;
  bool has_ack_rssi = false;
  int8_t ack_rssi = 0;
};

// Transport contract:
// - trySend(), poll(), tryReceive(), and tryDelivery() never wait;
// - poll() performs a bounded amount of work;
// - callbacks owned by an adapter may enqueue bytes but never call user code.
class Transport {
 public:
  virtual ~Transport() = default;
  virtual bool begin() = 0;
  virtual SendResult trySend(const Message &message) = 0;
  virtual void poll(uint32_t now_ms) = 0;
  virtual bool tryReceive(ReceivedCue &received) = 0;
  virtual bool tryDelivery(DeliveryReport &report) = 0;
};

}  // namespace cue
