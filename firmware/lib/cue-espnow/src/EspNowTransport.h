#pragma once

#include <Arduino.h>
#include <CueTransport.h>
#include <esp_arduino_version.h>
#include <esp_now.h>

namespace cue {

class EspNowTransport final : public Transport {
 public:
  struct Config {
    Config(
      uint8_t channel_value = 1,
      uint8_t max_attempts_value = 5,
      uint16_t ack_timeout_ms_value = 70,
      uint16_t max_retry_ms_value = 240,
      uint16_t discovery_interval_ms_value = 1000,
      bool long_range_value = true,
      const char *service_name_value = ""
    )
      : channel(channel_value),
        max_attempts(max_attempts_value),
        ack_timeout_ms(ack_timeout_ms_value),
        max_retry_ms(max_retry_ms_value),
        discovery_interval_ms(discovery_interval_ms_value),
        long_range(long_range_value),
        service_name(service_name_value) {}

    uint8_t channel = 1;
    uint8_t max_attempts = 5;
    uint16_t ack_timeout_ms = 70;
    uint16_t max_retry_ms = 240;
    uint16_t discovery_interval_ms = 1000;
    bool long_range = true;
    const char *service_name = "";
  };

  struct PeerInfo {
    uint64_t node = 0;
    uint32_t last_seen_ms = 0;
    bool has_rssi = false;
    int8_t rssi = 0;
    char service[kNameCapacity] = {};
  };

  EspNowTransport();
  explicit EspNowTransport(const Config &config);

  bool begin() override;
  SendResult trySend(const Message &message) override;
  void poll(uint32_t now_ms) override;
  bool tryReceive(ReceivedCue &received) override;
  bool tryDelivery(DeliveryReport &report) override;

  uint64_t localNode() const { return local_node_; }
  size_t peerCount() const;
  bool peerAt(size_t index, PeerInfo &peer) const;
  bool firstPeer(uint64_t &node) const;
  bool addPeer(uint64_t node);

  uint32_t droppedReceiveCount() const { return dropped_receive_count_; }
  uint32_t droppedCueCount() const { return dropped_cue_count_; }
  uint32_t droppedAckCount() const { return dropped_ack_count_; }
  uint32_t droppedDeliveryCount() const { return dropped_delivery_count_; }
  uint32_t fullSendCount() const { return full_send_count_; }
  uint32_t radioSendErrorCount() const { return radio_send_error_count_; }

 private:
  static constexpr size_t kRawReceiveQueueCapacity = 24;
  static constexpr size_t kCueQueueCapacity = 16;
  static constexpr size_t kDeliveryQueueCapacity = 16;
  static constexpr size_t kSendQueueCapacity = 8;
  static constexpr size_t kAckQueueCapacity = 8;
  static constexpr size_t kPeerCapacity = 12;

  struct RawReceive {
    uint8_t source_mac[6] = {};
    uint8_t bytes[kWireSize] = {};
    uint8_t length = 0;
    bool has_rssi = false;
    int8_t rssi = 0;
    char service[kNameCapacity] = {};
  };

  struct SendSlot {
    bool active = false;
    uint64_t destination = 0;
    uint64_t message_id = 0;
    uint8_t destination_mac[6] = {};
    uint8_t bytes[kWireSize] = {};
    uint8_t attempts = 0;
    uint32_t started_at = 0;
    uint32_t next_attempt_at = 0;
  };

  struct AckSlot {
    bool active = false;
    uint8_t destination_mac[6] = {};
    uint8_t bytes[kWireSize] = {};
  };

  struct PeerSlot {
    bool active = false;
    uint64_t node = 0;
    uint8_t mac[6] = {};
    uint32_t last_seen_at = 0;
    bool has_rssi = false;
    int8_t rssi = 0;
    char service[kNameCapacity] = {};
  };

  static EspNowTransport *active_instance_;

#if ESP_ARDUINO_VERSION_MAJOR >= 3
  static void onReceive(
    const esp_now_recv_info_t *info,
    const uint8_t *data,
    int length
  );
#else
  static void onReceive(const uint8_t *mac, const uint8_t *data, int length);
#endif

  static uint64_t nodeFromMac(const uint8_t *mac);
  static void macFromNode(uint64_t node, uint8_t *mac);

  void enqueueRaw(
    const uint8_t *source_mac,
    const uint8_t *data,
    int length,
    int8_t rssi,
    bool has_rssi
  );
  bool processOneIncoming(uint32_t now_ms);
  bool queueAck(
    const Packet &cue_packet,
    const RawReceive &raw
  );
  bool sendOneAck();
  bool sendOneDueCue(uint32_t now_ms);
  bool sendHello(uint32_t now_ms);
  void completeDelivery(
    SendSlot &slot,
    DeliveryStatus status,
    uint32_t now_ms,
    const Packet *ack = nullptr,
    const RawReceive *raw = nullptr
  );
  PeerSlot *findPeer(uint64_t node);
  const PeerSlot *findPeer(uint64_t node) const;
  bool rememberPeer(
    uint64_t node,
    const uint8_t *mac,
    uint32_t now_ms,
    bool has_rssi,
    int8_t rssi,
    const char *service = nullptr
  );
  bool addEspNowPeer(const uint8_t *mac);

  Config config_;
  QueueHandle_t raw_receive_queue_ = nullptr;
  QueueHandle_t cue_queue_ = nullptr;
  QueueHandle_t delivery_queue_ = nullptr;
  SendSlot send_slots_[kSendQueueCapacity] = {};
  AckSlot ack_slots_[kAckQueueCapacity] = {};
  PeerSlot peers_[kPeerCapacity] = {};
  DuplicateCache<64> received_ids_;
  uint64_t local_node_ = 0;
  uint32_t next_hello_at_ = 0;
  bool ready_ = false;
  volatile uint32_t dropped_receive_count_ = 0;
  uint32_t dropped_cue_count_ = 0;
  uint32_t dropped_ack_count_ = 0;
  uint32_t dropped_delivery_count_ = 0;
  uint32_t full_send_count_ = 0;
  uint32_t radio_send_error_count_ = 0;
};

}  // namespace cue
