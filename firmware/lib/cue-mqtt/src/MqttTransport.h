#pragma once

#include <Arduino.h>
#include <ArduinoMqttClient.h>
#include <CueTransport.h>
#include <WiFi.h>

namespace cue {

class MqttTransport final : public Transport {
 public:
  struct Config {
    Config(
      const char *wifi_ssid_value,
      const char *wifi_password_value,
      const char *broker_host_value,
      uint16_t broker_port_value = 1883,
      const char *topic_prefix_value = "halloween",
      const char *service_name_value = "",
      const char *username_value = "",
      const char *password_value = "",
      uint8_t max_attempts_value = 5,
      uint16_t ack_timeout_ms_value = 70,
      uint16_t max_retry_ms_value = 240
    )
      : wifi_ssid(wifi_ssid_value),
        wifi_password(wifi_password_value),
        broker_host(broker_host_value),
        broker_port(broker_port_value),
        topic_prefix(topic_prefix_value),
        service_name(service_name_value),
        username(username_value),
        password(password_value),
        max_attempts(max_attempts_value),
        ack_timeout_ms(ack_timeout_ms_value),
        max_retry_ms(max_retry_ms_value) {}

    const char *wifi_ssid;
    const char *wifi_password;
    const char *broker_host;
    uint16_t broker_port;
    const char *topic_prefix;
    const char *service_name;
    const char *username;
    const char *password;
    uint8_t max_attempts;
    uint16_t ack_timeout_ms;
    uint16_t max_retry_ms;
  };

  explicit MqttTransport(const Config &config);

  bool begin() override;
  SendResult trySend(const Message &message) override;
  void poll(uint32_t now_ms) override;
  bool tryReceive(ReceivedCue &received) override;
  bool tryDelivery(DeliveryReport &report) override;

  uint64_t localNode() const { return local_node_; }
  bool addPeer(uint64_t node) const;

 private:
  static constexpr size_t kOutgoingQueueCapacity = 12;
  static constexpr size_t kRawQueueCapacity = 24;
  static constexpr size_t kCueQueueCapacity = 16;
  static constexpr size_t kDeliveryQueueCapacity = 16;
  static constexpr size_t kSendCapacity = 8;
  static constexpr size_t kAckCapacity = 8;

  struct Outgoing {
    Message message;
    uint32_t queued_at = 0;
  };

  struct RawPacket {
    uint8_t bytes[kWireSize] = {};
    size_t length = 0;
  };

  struct SendSlot {
    bool active = false;
    Message message;
    uint8_t bytes[kWireSize] = {};
    uint8_t attempts = 0;
    uint32_t started_at = 0;
    uint32_t next_attempt_at = 0;
  };

  struct AckSlot {
    bool active = false;
    uint64_t destination = 0;
    uint8_t bytes[kWireSize] = {};
  };

  static MqttTransport *active_instance_;
  static void taskEntry(void *context);
  static void onMessage(int message_size);

  void run();
  void receiveMessage(int message_size);
  bool ensureConnected(uint32_t now_ms);
  void configureClient();
  bool publish(uint64_t destination, const uint8_t *bytes, size_t length);
  bool publishPresence();
  void acceptOutgoing();
  void processIncoming(uint32_t now_ms);
  void sendOneAck();
  void sendDueCues(uint32_t now_ms);
  void complete(
    SendSlot &slot,
    DeliveryStatus status,
    uint32_t now_ms
  );
  bool queueAck(const Packet &packet);
  uint32_t retryDelay(uint8_t attempts) const;
  void makeTopic(char *output, size_t output_size, uint64_t node) const;

  Config config_;
  WiFiClient wifi_client_;
  MqttClient mqtt_client_;
  QueueHandle_t outgoing_queue_ = nullptr;
  QueueHandle_t raw_queue_ = nullptr;
  QueueHandle_t cue_queue_ = nullptr;
  QueueHandle_t delivery_queue_ = nullptr;
  SendSlot send_slots_[kSendCapacity] = {};
  AckSlot ack_slots_[kAckCapacity] = {};
  DuplicateCache<64> received_ids_;
  uint64_t local_node_ = 0;
  uint32_t next_wifi_attempt_at_ = 0;
  uint32_t next_mqtt_attempt_at_ = 0;
  uint32_t next_presence_at_ = 0;
  bool configured_ = false;
  bool ready_ = false;
};

}  // namespace cue
