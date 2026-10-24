#include "EspNowTransport.h"

#include <WiFi.h>
#include <esp_arduino_version.h>
#include <esp_wifi.h>

namespace cue {
namespace {

constexpr uint8_t kBroadcastAddress[] = {
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff
};

bool isDue(uint32_t now_ms, uint32_t deadline_ms) {
  return static_cast<int32_t>(now_ms - deadline_ms) >= 0;
}

}  // namespace

EspNowTransport *EspNowTransport::active_instance_ = nullptr;

EspNowTransport::EspNowTransport() = default;

EspNowTransport::EspNowTransport(const Config &config) : config_(config) {}

uint64_t EspNowTransport::nodeFromMac(const uint8_t *mac) {
  uint64_t node = 0;
  for (size_t index = 0; index < 6; ++index) {
    node = (node << 8) | mac[index];
  }
  return node;
}

void EspNowTransport::macFromNode(uint64_t node, uint8_t *mac) {
  for (int index = 5; index >= 0; --index) {
    mac[index] = static_cast<uint8_t>(node);
    node >>= 8;
  }
}

bool EspNowTransport::addEspNowPeer(const uint8_t *mac) {
  if (!esp_now_is_peer_exist(mac)) {
    esp_now_peer_info_t peer = {};
    memcpy(peer.peer_addr, mac, sizeof(peer.peer_addr));
    peer.channel = config_.channel;
    peer.ifidx = WIFI_IF_STA;
    peer.encrypt = false;
    const esp_err_t result = esp_now_add_peer(&peer);
    if (result != ESP_OK && result != ESP_ERR_ESPNOW_EXIST) {
      return false;
    }
  }

  if (!config_.long_range) {
    return true;
  }
#if ESP_ARDUINO_VERSION_MAJOR >= 3
  esp_now_rate_config_t rate = {};
  rate.phymode = WIFI_PHY_MODE_LR;
  rate.rate = WIFI_PHY_RATE_LORA_250K;
  rate.ersu = false;
  rate.dcm = false;
  return esp_now_set_peer_rate_config(mac, &rate) == ESP_OK;
#else
  return esp_wifi_config_espnow_rate(
    WIFI_IF_STA,
    WIFI_PHY_RATE_LORA_250K
  ) == ESP_OK;
#endif
}

bool EspNowTransport::begin() {
  if (ready_ || active_instance_ != nullptr) {
    return ready_;
  }

  raw_receive_queue_ = xQueueCreate(
    kRawReceiveQueueCapacity,
    sizeof(RawReceive)
  );
  cue_queue_ = xQueueCreate(kCueQueueCapacity, sizeof(ReceivedCue));
  delivery_queue_ = xQueueCreate(
    kDeliveryQueueCapacity,
    sizeof(DeliveryReport)
  );
  if (raw_receive_queue_ == nullptr || cue_queue_ == nullptr ||
      delivery_queue_ == nullptr) {
    return false;
  }

  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  if (config_.long_range) {
    if (esp_wifi_set_protocol(WIFI_IF_STA, WIFI_PROTOCOL_LR) != ESP_OK) {
      return false;
    }
  }
  uint8_t local_mac[6] = {};
  if (esp_wifi_set_channel(config_.channel, WIFI_SECOND_CHAN_NONE) != ESP_OK ||
      esp_wifi_get_mac(WIFI_IF_STA, local_mac) != ESP_OK ||
      esp_now_init() != ESP_OK) {
    return false;
  }
  local_node_ = nodeFromMac(local_mac);

  active_instance_ = this;
  if (esp_now_register_recv_cb(onReceive) != ESP_OK) {
    active_instance_ = nullptr;
    return false;
  }
  if (!addEspNowPeer(kBroadcastAddress)) {
    active_instance_ = nullptr;
    return false;
  }

  received_ids_.clear();
  next_hello_at_ = millis() + esp_random() % 250;
  ready_ = true;
  return true;
}

size_t EspNowTransport::peerCount() const {
  size_t count = 0;
  for (const PeerSlot &peer : peers_) {
    if (peer.active) {
      ++count;
    }
  }
  return count;
}

bool EspNowTransport::peerAt(size_t index, PeerInfo &peer) const {
  size_t active_index = 0;
  for (const PeerSlot &slot : peers_) {
    if (!slot.active) continue;
    if (active_index++ != index) continue;
    peer.node = slot.node;
    peer.last_seen_ms = slot.last_seen_at;
    peer.has_rssi = slot.has_rssi;
    peer.rssi = slot.rssi;
    memcpy(peer.service, slot.service, sizeof(peer.service));
    return true;
  }
  return false;
}

bool EspNowTransport::firstPeer(uint64_t &node) const {
  const PeerSlot *newest = nullptr;
  for (const PeerSlot &peer : peers_) {
    if (peer.active &&
        (newest == nullptr ||
         static_cast<int32_t>(peer.last_seen_at - newest->last_seen_at) > 0)) {
      newest = &peer;
    }
  }
  if (newest == nullptr) {
    return false;
  }
  node = newest->node;
  return true;
}

EspNowTransport::PeerSlot *EspNowTransport::findPeer(uint64_t node) {
  for (PeerSlot &peer : peers_) {
    if (peer.active && peer.node == node) {
      return &peer;
    }
  }
  return nullptr;
}

const EspNowTransport::PeerSlot *EspNowTransport::findPeer(
  uint64_t node
) const {
  for (const PeerSlot &peer : peers_) {
    if (peer.active && peer.node == node) {
      return &peer;
    }
  }
  return nullptr;
}

bool EspNowTransport::rememberPeer(
  uint64_t node,
  const uint8_t *mac,
  uint32_t now_ms,
  bool has_rssi,
  int8_t rssi,
  const char *service
) {
  if (!isValidNode(node) || node == local_node_ || node == kBroadcastNode ||
      nodeFromMac(mac) != node || !addEspNowPeer(mac)) {
    return false;
  }

  PeerSlot *slot = findPeer(node);
  if (slot == nullptr) {
    for (PeerSlot &candidate : peers_) {
      if (!candidate.active) {
        slot = &candidate;
        break;
      }
    }
  }
  if (slot == nullptr) {
    return false;
  }

  slot->active = true;
  slot->node = node;
  memcpy(slot->mac, mac, sizeof(slot->mac));
  slot->last_seen_at = now_ms;
  slot->has_rssi = has_rssi;
  slot->rssi = rssi;
  if (service != nullptr && service[0] != '\0') {
    memset(slot->service, 0, sizeof(slot->service));
    strncpy(slot->service, service, sizeof(slot->service) - 1);
  }
  return true;
}

bool EspNowTransport::addPeer(uint64_t node) {
  if (!ready_ || !isValidNode(node) || node == local_node_ ||
      node == kBroadcastNode) {
    return false;
  }
  uint8_t mac[6] = {};
  macFromNode(node, mac);
  return rememberPeer(node, mac, millis(), false, 0, nullptr);
}

SendResult EspNowTransport::trySend(const Message &message) {
  if (!ready_) {
    return SendResult::NOT_READY;
  }
  if (!isValid(message) || message.source != local_node_) {
    return SendResult::INVALID_MESSAGE;
  }

  PeerSlot *peer = findPeer(message.destination);
  if (peer == nullptr && !addPeer(message.destination)) {
    return SendResult::PEER_UNAVAILABLE;
  }
  peer = findPeer(message.destination);
  if (peer == nullptr) {
    return SendResult::PEER_UNAVAILABLE;
  }

  for (SendSlot &slot : send_slots_) {
    if (slot.active) {
      continue;
    }
    if (!encode(makeCuePacket(message), slot.bytes, sizeof(slot.bytes))) {
      return SendResult::INVALID_MESSAGE;
    }
    slot.active = true;
    slot.destination = message.destination;
    slot.message_id = message.id;
    memcpy(slot.destination_mac, peer->mac, sizeof(slot.destination_mac));
    slot.attempts = 0;
    slot.started_at = millis();
    slot.next_attempt_at = slot.started_at;
    return SendResult::QUEUED;
  }

  ++full_send_count_;
  return SendResult::QUEUE_FULL;
}

void EspNowTransport::enqueueRaw(
  const uint8_t *source_mac,
  const uint8_t *data,
  int length,
  int8_t rssi,
  bool has_rssi
) {
  if (source_mac == nullptr || data == nullptr || length != kWireSize) {
    return;
  }
  RawReceive raw = {};
  memcpy(raw.source_mac, source_mac, sizeof(raw.source_mac));
  memcpy(raw.bytes, data, sizeof(raw.bytes));
  raw.length = static_cast<uint8_t>(length);
  raw.rssi = rssi;
  raw.has_rssi = has_rssi;
  if (xQueueSend(raw_receive_queue_, &raw, 0) != pdTRUE) {
    ++dropped_receive_count_;
  }
}

bool EspNowTransport::queueAck(
  const Packet &cue_packet,
  const RawReceive &raw
) {
  for (AckSlot &slot : ack_slots_) {
    if (slot.active) {
      continue;
    }
    const Packet ack = makeAckPacket(
      local_node_,
      cue_packet.message.source,
      cue_packet.message.id,
      raw.rssi,
      raw.has_rssi
    );
    if (!encode(ack, slot.bytes, sizeof(slot.bytes))) {
      return false;
    }
    memcpy(slot.destination_mac, raw.source_mac, sizeof(slot.destination_mac));
    slot.active = true;
    return true;
  }
  ++dropped_ack_count_;
  return false;
}

void EspNowTransport::completeDelivery(
  SendSlot &slot,
  DeliveryStatus status,
  uint32_t now_ms,
  const Packet *ack,
  const RawReceive *raw
) {
  DeliveryReport report = {};
  report.message_id = slot.message_id;
  report.destination = slot.destination;
  report.status = status;
  report.attempts = slot.attempts;
  report.latency_ms = now_ms - slot.started_at;
  if (ack != nullptr && ack->has_reported_rssi) {
    report.has_remote_rssi = true;
    report.remote_rssi = ack->reported_rssi;
  }
  if (raw != nullptr && raw->has_rssi) {
    report.has_ack_rssi = true;
    report.ack_rssi = raw->rssi;
  }
  if (xQueueSend(delivery_queue_, &report, 0) != pdTRUE) {
    ++dropped_delivery_count_;
  }
  slot.active = false;
}

bool EspNowTransport::processOneIncoming(uint32_t now_ms) {
  RawReceive raw = {};
  if (xQueueReceive(raw_receive_queue_, &raw, 0) != pdTRUE) {
    return false;
  }

  Packet packet = {};
  if (!decode(raw.bytes, raw.length, packet) ||
      packet.message.source != nodeFromMac(raw.source_mac)) {
    return true;
  }
  if (!rememberPeer(
        packet.message.source,
        raw.source_mac,
        now_ms,
        raw.has_rssi,
      raw.rssi,
      packet.kind == PacketKind::HELLO ? packet.message.name : nullptr
      )) {
    return true;
  }

  if (packet.kind == PacketKind::HELLO) {
    return true;
  }
  if (packet.message.destination != local_node_) {
    return true;
  }

  if (packet.kind == PacketKind::ACK) {
    for (SendSlot &slot : send_slots_) {
      if (slot.active && slot.destination == packet.message.source &&
          slot.message_id == packet.message.id) {
        completeDelivery(
          slot,
          DeliveryStatus::DELIVERED,
          now_ms,
          &packet,
          &raw
        );
        break;
      }
    }
    return true;
  }

  if (packet.kind == PacketKind::CUE) {
    if (received_ids_.contains(packet.message.source, packet.message.id)) {
      // The sender may not have heard the previous ACK. ACK duplicates again,
      // but never enqueue or execute the application cue twice.
      queueAck(packet, raw);
      return true;
    }
    ReceivedCue received = {};
    received.message = packet.message;
    received.metadata.has_rssi = raw.has_rssi;
    received.metadata.rssi = raw.rssi;
    if (xQueueSend(cue_queue_, &received, 0) != pdTRUE) {
      ++dropped_cue_count_;
      // Do not ACK a cue we could not accept. The sender will retry, giving
      // the application queue time to drain instead of reporting false success.
      return true;
    }
    received_ids_.remember(packet.message.source, packet.message.id);
    queueAck(packet, raw);
  }
  return true;
}

bool EspNowTransport::sendOneAck() {
  for (AckSlot &slot : ack_slots_) {
    if (!slot.active) {
      continue;
    }
    const esp_err_t result = esp_now_send(
      slot.destination_mac,
      slot.bytes,
      sizeof(slot.bytes)
    );
    if (result == ESP_ERR_ESPNOW_NO_MEM) {
      return true;
    }
    if (result != ESP_OK) {
      ++radio_send_error_count_;
    }
    slot.active = false;
    return true;
  }
  return false;
}

bool EspNowTransport::sendOneDueCue(uint32_t now_ms) {
  for (SendSlot &slot : send_slots_) {
    if (!slot.active || !isDue(now_ms, slot.next_attempt_at)) {
      continue;
    }
    if (slot.attempts >= config_.max_attempts) {
      completeDelivery(slot, DeliveryStatus::TIMED_OUT, now_ms);
      return true;
    }

    const esp_err_t result = esp_now_send(
      slot.destination_mac,
      slot.bytes,
      sizeof(slot.bytes)
    );
    if (result == ESP_ERR_ESPNOW_NO_MEM) {
      slot.next_attempt_at = now_ms + 5;
      return true;
    }
    if (result != ESP_OK) {
      ++radio_send_error_count_;
    }
    ++slot.attempts;

    uint32_t wait_ms = config_.ack_timeout_ms;
    for (uint8_t step = 1; step < slot.attempts; ++step) {
      wait_ms *= 2;
      if (wait_ms >= config_.max_retry_ms) {
        wait_ms = config_.max_retry_ms;
        break;
      }
    }
    const uint32_t jitter = esp_random() % 16;
    slot.next_attempt_at = now_ms + wait_ms + jitter;
    return true;
  }
  return false;
}

bool EspNowTransport::sendHello(uint32_t now_ms) {
  if (config_.discovery_interval_ms == 0 || !isDue(now_ms, next_hello_at_)) {
    return false;
  }
  uint8_t bytes[kWireSize] = {};
  if (!encode(
        makeHelloPacket(local_node_, config_.service_name),
        bytes,
        sizeof(bytes)
      )) {
    return false;
  }
  if (esp_now_send(kBroadcastAddress, bytes, sizeof(bytes)) != ESP_OK) {
    ++radio_send_error_count_;
  }
  next_hello_at_ = now_ms + config_.discovery_interval_ms +
    esp_random() % 250;
  return true;
}

void EspNowTransport::poll(uint32_t now_ms) {
  if (!ready_) {
    return;
  }

  // Process one received frame, then perform at most one radio send. ACKs have
  // priority so a healthy link normally completes in a few milliseconds.
  processOneIncoming(now_ms);
  if (sendOneAck()) {
    return;
  }
  if (sendOneDueCue(now_ms)) {
    return;
  }
  sendHello(now_ms);
}

bool EspNowTransport::tryReceive(ReceivedCue &received) {
  return cue_queue_ != nullptr &&
    xQueueReceive(cue_queue_, &received, 0) == pdTRUE;
}

bool EspNowTransport::tryDelivery(DeliveryReport &report) {
  return delivery_queue_ != nullptr &&
    xQueueReceive(delivery_queue_, &report, 0) == pdTRUE;
}

#if ESP_ARDUINO_VERSION_MAJOR >= 3
void EspNowTransport::onReceive(
  const esp_now_recv_info_t *info,
  const uint8_t *data,
  int length
) {
  if (active_instance_ == nullptr || info == nullptr) {
    return;
  }
  const bool has_rssi = info->rx_ctrl != nullptr;
  active_instance_->enqueueRaw(
    info->src_addr,
    data,
    length,
    has_rssi ? info->rx_ctrl->rssi : 0,
    has_rssi
  );
}
#else
void EspNowTransport::onReceive(
  const uint8_t *mac,
  const uint8_t *data,
  int length
) {
  if (active_instance_ != nullptr) {
    active_instance_->enqueueRaw(mac, data, length, 0, false);
  }
}
#endif

}  // namespace cue
