#include "MqttTransport.h"

#include <esp_mac.h>
#include <stdio.h>
#include <string.h>

namespace cue {
namespace {

bool due(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

uint64_t nodeFromMac(const uint8_t *mac) {
  uint64_t node = 0;
  for (size_t index = 0; index < 6; ++index) {
    node = (node << 8) | mac[index];
  }
  return node;
}

}  // namespace

MqttTransport *MqttTransport::active_instance_ = nullptr;

MqttTransport::MqttTransport(const Config &config)
  : config_(config), mqtt_client_(wifi_client_) {}

bool MqttTransport::begin() {
  if (ready_ || active_instance_ != nullptr || config_.wifi_ssid == nullptr ||
      config_.wifi_ssid[0] == '\0' || config_.broker_host == nullptr ||
      config_.broker_host[0] == '\0' || config_.topic_prefix == nullptr ||
      config_.topic_prefix[0] == '\0') {
    return ready_;
  }

  outgoing_queue_ = xQueueCreate(kOutgoingQueueCapacity, sizeof(Outgoing));
  raw_queue_ = xQueueCreate(kRawQueueCapacity, sizeof(RawPacket));
  cue_queue_ = xQueueCreate(kCueQueueCapacity, sizeof(ReceivedCue));
  delivery_queue_ = xQueueCreate(kDeliveryQueueCapacity, sizeof(DeliveryReport));
  if (outgoing_queue_ == nullptr || raw_queue_ == nullptr || cue_queue_ == nullptr ||
      delivery_queue_ == nullptr) {
    return false;
  }

  uint8_t mac[6] = {};
  if (esp_read_mac(mac, ESP_MAC_WIFI_STA) != ESP_OK) return false;
  local_node_ = nodeFromMac(mac);
  if (!isValidNode(local_node_) || local_node_ == kBroadcastNode) return false;

  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  active_instance_ = this;
  received_ids_.clear();
  ready_ = xTaskCreate(
    taskEntry,
    "cue-mqtt",
    8192,
    this,
    1,
    nullptr
  ) == pdPASS;
  if (!ready_) active_instance_ = nullptr;
  return ready_;
}

bool MqttTransport::addPeer(uint64_t node) const {
  return isValidNode(node) && node != local_node_ && node != kBroadcastNode;
}

SendResult MqttTransport::trySend(const Message &message) {
  if (!ready_) return SendResult::NOT_READY;
  if (!isValid(message) || message.source != local_node_) {
    return SendResult::INVALID_MESSAGE;
  }
  Outgoing outgoing = {};
  outgoing.message = message;
  outgoing.queued_at = millis();
  return xQueueSend(outgoing_queue_, &outgoing, 0) == pdTRUE
    ? SendResult::QUEUED
    : SendResult::QUEUE_FULL;
}

void MqttTransport::poll(uint32_t) {
  // Network work runs on its own task so broker stalls cannot block motion.
}

bool MqttTransport::tryReceive(ReceivedCue &received) {
  return ready_ && xQueueReceive(cue_queue_, &received, 0) == pdTRUE;
}

bool MqttTransport::tryDelivery(DeliveryReport &report) {
  return ready_ && xQueueReceive(delivery_queue_, &report, 0) == pdTRUE;
}

void MqttTransport::taskEntry(void *context) {
  static_cast<MqttTransport *>(context)->run();
}

void MqttTransport::onMessage(int message_size) {
  if (active_instance_ != nullptr) {
    active_instance_->receiveMessage(message_size);
  }
}

void MqttTransport::receiveMessage(int message_size) {
  RawPacket raw = {};
  while (mqtt_client_.available() && raw.length < sizeof(raw.bytes)) {
    const int byte = mqtt_client_.read();
    if (byte < 0) break;
    raw.bytes[raw.length++] = static_cast<uint8_t>(byte);
  }
  while (mqtt_client_.available()) mqtt_client_.read();
  if (message_size == static_cast<int>(kWireSize) && raw.length == kWireSize) {
    xQueueSend(raw_queue_, &raw, 0);
  }
}

void MqttTransport::configureClient() {
  if (configured_) return;
  char client_id[32] = {};
  snprintf(
    client_id,
    sizeof(client_id),
    "cue-%012llX",
    static_cast<unsigned long long>(local_node_)
  );
  mqtt_client_.setId(client_id);
  mqtt_client_.setCleanSession(true);
  mqtt_client_.setKeepAliveInterval(5000);
  mqtt_client_.setConnectionTimeout(1000);
  mqtt_client_.onMessage(onMessage);
  if (config_.username != nullptr && config_.username[0] != '\0') {
    mqtt_client_.setUsernamePassword(config_.username, config_.password);
  }
  configured_ = true;
}

bool MqttTransport::ensureConnected(uint32_t now_ms) {
  if (WiFi.status() != WL_CONNECTED) {
    if (mqtt_client_.connected()) mqtt_client_.stop();
    if (due(now_ms, next_wifi_attempt_at_)) {
      next_wifi_attempt_at_ = now_ms + 10000;
      WiFi.begin(config_.wifi_ssid, config_.wifi_password);
    }
    return false;
  }
  if (mqtt_client_.connected()) return true;
  if (!due(now_ms, next_mqtt_attempt_at_)) return false;
  next_mqtt_attempt_at_ = now_ms + 1000;
  configureClient();
  if (!mqtt_client_.connect(config_.broker_host, config_.broker_port)) {
    return false;
  }
  char inbox[128] = {};
  makeTopic(inbox, sizeof(inbox), local_node_);
  if (!mqtt_client_.subscribe(inbox, 0)) {
    mqtt_client_.stop();
    return false;
  }
  next_presence_at_ = now_ms;
  return true;
}

void MqttTransport::makeTopic(
  char *output,
  size_t output_size,
  uint64_t node
) const {
  snprintf(
    output,
    output_size,
    "%s/cue/%012llX",
    config_.topic_prefix,
    static_cast<unsigned long long>(node)
  );
}

bool MqttTransport::publish(
  uint64_t destination,
  const uint8_t *bytes,
  size_t length
) {
  if (!mqtt_client_.connected()) return false;
  char topic[128] = {};
  makeTopic(topic, sizeof(topic), destination);
  if (!mqtt_client_.beginMessage(topic, length, false, 0, false)) return false;
  if (mqtt_client_.write(bytes, length) != length) return false;
  return mqtt_client_.endMessage() == 1;
}

bool MqttTransport::publishPresence() {
  Packet hello = makeHelloPacket(local_node_, config_.service_name);
  uint8_t bytes[kWireSize] = {};
  if (!encode(hello, bytes, sizeof(bytes))) return false;
  char topic[128] = {};
  snprintf(
    topic,
    sizeof(topic),
    "%s/presence/%012llX",
    config_.topic_prefix,
    static_cast<unsigned long long>(local_node_)
  );
  if (!mqtt_client_.beginMessage(topic, sizeof(bytes), false, 0, false)) {
    return false;
  }
  return mqtt_client_.write(bytes, sizeof(bytes)) == sizeof(bytes) &&
    mqtt_client_.endMessage() == 1;
}

void MqttTransport::acceptOutgoing() {
  Outgoing outgoing = {};
  while (xQueueReceive(outgoing_queue_, &outgoing, 0) == pdTRUE) {
    SendSlot *available = nullptr;
    for (SendSlot &slot : send_slots_) {
      if (!slot.active) {
        available = &slot;
        break;
      }
    }
    if (available == nullptr) {
      DeliveryReport report = {};
      report.message_id = outgoing.message.id;
      report.destination = outgoing.message.destination;
      report.status = DeliveryStatus::TIMED_OUT;
      xQueueSend(delivery_queue_, &report, 0);
      continue;
    }
    Packet packet = makeCuePacket(outgoing.message);
    if (!encode(packet, available->bytes, sizeof(available->bytes))) continue;
    available->active = true;
    available->message = outgoing.message;
    available->attempts = 0;
    available->started_at = outgoing.queued_at;
    available->next_attempt_at = outgoing.queued_at;
  }
}

bool MqttTransport::queueAck(const Packet &packet) {
  for (AckSlot &slot : ack_slots_) {
    if (slot.active) continue;
    Packet ack = makeAckPacket(
      local_node_,
      packet.message.source,
      packet.message.id,
      0,
      false
    );
    if (!encode(ack, slot.bytes, sizeof(slot.bytes))) return false;
    slot.destination = packet.message.source;
    slot.active = true;
    return true;
  }
  return false;
}

void MqttTransport::processIncoming(uint32_t now_ms) {
  RawPacket raw = {};
  size_t handled = 0;
  while (handled++ < 8 && xQueueReceive(raw_queue_, &raw, 0) == pdTRUE) {
    Packet packet = {};
    if (!decode(raw.bytes, raw.length, packet) ||
        packet.message.destination != local_node_) {
      continue;
    }
    if (packet.kind == PacketKind::ACK) {
      for (SendSlot &slot : send_slots_) {
        if (slot.active && slot.message.destination == packet.message.source &&
            slot.message.id == packet.message.id) {
          complete(slot, DeliveryStatus::DELIVERED, now_ms);
          break;
        }
      }
      continue;
    }
    if (packet.kind != PacketKind::CUE) continue;
    if (received_ids_.contains(packet.message.source, packet.message.id)) {
      queueAck(packet);
      continue;
    }
    ReceivedCue received = {};
    received.message = packet.message;
    if (xQueueSend(cue_queue_, &received, 0) == pdTRUE) {
      received_ids_.remember(packet.message.source, packet.message.id);
      queueAck(packet);
    }
  }
}

void MqttTransport::sendOneAck() {
  for (AckSlot &slot : ack_slots_) {
    if (!slot.active) continue;
    if (publish(slot.destination, slot.bytes, sizeof(slot.bytes))) {
      slot.active = false;
    }
    return;
  }
}

uint32_t MqttTransport::retryDelay(uint8_t attempts) const {
  uint32_t delay = config_.ack_timeout_ms;
  for (uint8_t index = 1; index < attempts; ++index) {
    delay = min<uint32_t>(delay * 2, config_.max_retry_ms);
  }
  return delay;
}

void MqttTransport::sendDueCues(uint32_t now_ms) {
  for (SendSlot &slot : send_slots_) {
    if (!slot.active || !due(now_ms, slot.next_attempt_at)) continue;
    if (slot.attempts >= config_.max_attempts) {
      complete(slot, DeliveryStatus::TIMED_OUT, now_ms);
      continue;
    }
    if (!mqtt_client_.connected()) {
      if (now_ms - slot.started_at > 1200) {
        complete(slot, DeliveryStatus::TIMED_OUT, now_ms);
      }
      continue;
    }
    ++slot.attempts;
    publish(slot.message.destination, slot.bytes, sizeof(slot.bytes));
    slot.next_attempt_at = now_ms + retryDelay(slot.attempts);
  }
}

void MqttTransport::complete(
  SendSlot &slot,
  DeliveryStatus status,
  uint32_t now_ms
) {
  DeliveryReport report = {};
  report.message_id = slot.message.id;
  report.destination = slot.message.destination;
  report.status = status;
  report.attempts = slot.attempts;
  report.latency_ms = now_ms - slot.started_at;
  xQueueSend(delivery_queue_, &report, 0);
  slot.active = false;
}

void MqttTransport::run() {
  while (true) {
    const uint32_t now = millis();
    const bool connected = ensureConnected(now);
    if (connected) mqtt_client_.poll();
    acceptOutgoing();
    processIncoming(now);
    sendOneAck();
    sendDueCues(now);
    if (connected && due(now, next_presence_at_)) {
      publishPresence();
      next_presence_at_ = now + 1000;
    }
    vTaskDelay(pdMS_TO_TICKS(2));
  }
}

}  // namespace cue
