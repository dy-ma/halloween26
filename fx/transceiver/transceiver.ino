// Legacy bring-up prototype. Active Cue firmware is in ../../firmware/.
// This file intentionally remains available to reproduce earlier tests.
#include <WiFi.h>
#include <esp_arduino_version.h>
#include <esp_now.h>
#include <esp_wifi.h>

// Flash this same sketch onto both ESP32-S3 boards. On most generic boards,
// BOOT connects GPIO0 to ground and the other button is RESET/EN.
constexpr uint8_t BUTTON_PIN = 0;
constexpr char EVENT_NAME[] = "tractor:tipped";

// Every ESP-NOW node must use the same channel. No Wi-Fi network is required.
constexpr uint8_t ESPNOW_CHANNEL = 1;
constexpr unsigned long DEBOUNCE_MS = 30;
constexpr unsigned long ACK_TIMEOUT_MS = 100;
constexpr unsigned long LED_SUCCESS_MS = 220;
constexpr unsigned long LED_FAILURE_MS = 700;
constexpr uint8_t MAX_SEND_ATTEMPTS = 4;
constexpr uint32_t MESSAGE_MAGIC = 0x46583102;  // "FX1", protocol version 2
constexpr size_t EVENT_NAME_CAPACITY = 32;
constexpr size_t RECEIVE_QUEUE_CAPACITY = 16;
constexpr size_t PENDING_CAPACITY = 8;
constexpr size_t RECENT_CAPACITY = 32;

constexpr uint8_t BROADCAST_ADDRESS[] = {
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff
};

enum class MessageKind : uint8_t {
  EVENT = 1,
  ACK = 2,
};

struct __attribute__((packed)) RadioMessage {
  uint32_t magic;
  MessageKind kind;
  uint8_t reserved[3];
  uint64_t sender;
  uint64_t recipient;
  uint64_t sequence;
  char event[EVENT_NAME_CAPACITY];
};

struct ReceivedMessage {
  RadioMessage message;
  int8_t rssi;
  bool has_rssi;
};

struct PendingMessage {
  bool active;
  RadioMessage message;
  uint8_t attempts;
  unsigned long next_attempt_at;
};

struct RecentMessage {
  uint64_t sender;
  uint64_t sequence;
};

enum class LedColor {
  OFF,
  AMBER,
  GREEN,
  RED,
};

QueueHandle_t received_messages;
PendingMessage pending[PENDING_CAPACITY] = {};
RecentMessage recent[RECENT_CAPACITY] = {};
size_t recent_count = 0;
size_t recent_next = 0;

uint64_t node_id;
uint32_t boot_nonce;
uint32_t local_counter = 0;
bool radio_ready = false;

bool last_button_reading = HIGH;
bool stable_button_state = HIGH;
unsigned long button_changed_at = 0;

bool led_is_on = false;
unsigned long led_off_at = 0;

void setLed(LedColor color) {
#if defined(RGB_BUILTIN)
  uint8_t red = 0;
  uint8_t green = 0;
  if (color == LedColor::AMBER) {
    red = 28;
    green = 12;
  } else if (color == LedColor::GREEN) {
    green = 32;
  } else if (color == LedColor::RED) {
    red = 32;
  }
  rgbLedWrite(RGB_BUILTIN, red, green, 0);
#elif defined(LED_BUILTIN)
  digitalWrite(LED_BUILTIN, color == LedColor::OFF ? LOW : HIGH);
#else
  (void)color;
#endif
}

void showLed(LedColor color, unsigned long duration_ms) {
  setLed(color);
  led_is_on = color != LedColor::OFF;
  led_off_at = millis() + duration_ms;
}

void updateLed() {
  if (led_is_on && static_cast<int32_t>(millis() - led_off_at) >= 0) {
    setLed(LedColor::OFF);
    led_is_on = false;
  }
}

void emitSerial(const RadioMessage &message, int8_t rssi = 0, bool has_rssi = false) {
  if (has_rssi) {
    Serial.printf(
      "{\"event\":\"%s\",\"sequence\":%llu,\"source\":\"%012llX\",\"rssi\":%d}\n",
      message.event,
      static_cast<unsigned long long>(message.sequence),
      static_cast<unsigned long long>(message.sender & 0xffffffffffffULL),
      rssi
    );
  } else {
    Serial.printf(
      "{\"event\":\"%s\",\"sequence\":%llu,\"source\":\"%012llX\"}\n",
      message.event,
      static_cast<unsigned long long>(message.sequence),
      static_cast<unsigned long long>(message.sender & 0xffffffffffffULL)
    );
  }
}

void enqueueReceived(
  const uint8_t *data,
  int length,
  int8_t rssi,
  bool has_rssi
) {
  if (length != sizeof(RadioMessage)) {
    return;
  }

  ReceivedMessage received = {};
  memcpy(&received.message, data, sizeof(received.message));
  received.rssi = rssi;
  received.has_rssi = has_rssi;

  const RadioMessage &message = received.message;
  if (message.magic != MESSAGE_MAGIC || message.sender == node_id) {
    return;
  }
  if (message.kind == MessageKind::EVENT &&
      memchr(message.event, '\0', sizeof(message.event)) == nullptr) {
    return;
  }
  if (message.kind != MessageKind::EVENT && message.kind != MessageKind::ACK) {
    return;
  }

  // Never block the high-priority Wi-Fi task.
  xQueueSend(received_messages, &received, 0);
}

#if ESP_ARDUINO_VERSION_MAJOR >= 3
void onReceive(
  const esp_now_recv_info_t *info,
  const uint8_t *data,
  int length
) {
  const bool has_rssi = info != nullptr && info->rx_ctrl != nullptr;
  const int8_t rssi = has_rssi ? info->rx_ctrl->rssi : 0;
  enqueueReceived(data, length, rssi, has_rssi);
}
#else
void onReceive(const uint8_t *mac, const uint8_t *data, int length) {
  (void)mac;
  enqueueReceived(data, length, 0, false);
}
#endif

bool setupRadio() {
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  if (esp_wifi_set_channel(ESPNOW_CHANNEL, WIFI_SECOND_CHAN_NONE) != ESP_OK) {
    Serial.println("radio error: could not set ESP-NOW channel");
    return false;
  }
  if (esp_now_init() != ESP_OK) {
    Serial.println("radio error: esp_now_init failed");
    return false;
  }
  if (esp_now_register_recv_cb(onReceive) != ESP_OK) {
    Serial.println("radio error: could not register receive callback");
    return false;
  }

  esp_now_peer_info_t peer = {};
  memcpy(peer.peer_addr, BROADCAST_ADDRESS, sizeof(BROADCAST_ADDRESS));
  peer.channel = ESPNOW_CHANNEL;
  peer.ifidx = WIFI_IF_STA;
  peer.encrypt = false;
  const esp_err_t result = esp_now_add_peer(&peer);
  if (result != ESP_OK && result != ESP_ERR_ESPNOW_EXIST) {
    Serial.printf("radio error: could not add broadcast peer (%d)\n", result);
    return false;
  }
  return true;
}

esp_err_t sendRadioMessage(const RadioMessage &message) {
  return esp_now_send(
    BROADCAST_ADDRESS,
    reinterpret_cast<const uint8_t *>(&message),
    sizeof(message)
  );
}

RadioMessage makeLocalEvent() {
  RadioMessage message = {};
  message.magic = MESSAGE_MAGIC;
  message.kind = MessageKind::EVENT;
  message.sender = node_id;
  // A random boot nonce plus a local counter prevents a board reboot from
  // reusing recent sequence numbers remembered by fx.
  message.sequence =
    (static_cast<uint64_t>(boot_nonce) << 32) | ++local_counter;
  strlcpy(message.event, EVENT_NAME, sizeof(message.event));
  return message;
}

void sendAck(const RadioMessage &event) {
  RadioMessage ack = {};
  ack.magic = MESSAGE_MAGIC;
  ack.kind = MessageKind::ACK;
  ack.sender = node_id;
  ack.recipient = event.sender;
  ack.sequence = event.sequence;
  const esp_err_t result = sendRadioMessage(ack);
  if (result != ESP_OK) {
    Serial.printf("radio ACK send error: %d\n", result);
  }
}

bool wasRecentlyReceived(const RadioMessage &message) {
  for (size_t index = 0; index < recent_count; ++index) {
    if (recent[index].sender == message.sender &&
        recent[index].sequence == message.sequence) {
      return true;
    }
  }

  recent[recent_next] = {message.sender, message.sequence};
  recent_next = (recent_next + 1) % RECENT_CAPACITY;
  if (recent_count < RECENT_CAPACITY) {
    ++recent_count;
  }
  return false;
}

void acknowledgePending(uint64_t sequence) {
  for (PendingMessage &entry : pending) {
    if (entry.active && entry.message.sequence == sequence) {
      entry.active = false;
      showLed(LedColor::GREEN, LED_SUCCESS_MS);
      Serial.printf(
        "radio delivered sequence %llu after %u attempt(s)\n",
        static_cast<unsigned long long>(sequence),
        entry.attempts
      );
      return;
    }
  }
}

void transmitPending(PendingMessage &entry) {
  const esp_err_t result = sendRadioMessage(entry.message);
  ++entry.attempts;
  // Small random jitter prevents two simultaneously pressed nodes from
  // repeatedly colliding on every retry.
  entry.next_attempt_at = millis() + ACK_TIMEOUT_MS + (esp_random() % 31);
  if (result != ESP_OK) {
    Serial.printf("radio send error: %d\n", result);
  }
}

void beginReliableSend(const RadioMessage &message) {
  for (PendingMessage &entry : pending) {
    if (!entry.active) {
      entry.active = true;
      entry.message = message;
      entry.attempts = 0;
      showLed(LedColor::AMBER, ACK_TIMEOUT_MS * MAX_SEND_ATTEMPTS + 200);
      transmitPending(entry);
      return;
    }
  }

  showLed(LedColor::RED, LED_FAILURE_MS);
  Serial.println("radio send error: pending queue is full");
}

void updatePendingMessages() {
  const unsigned long now = millis();
  for (PendingMessage &entry : pending) {
    if (!entry.active ||
        static_cast<int32_t>(now - entry.next_attempt_at) < 0) {
      continue;
    }
    if (entry.attempts >= MAX_SEND_ATTEMPTS) {
      Serial.printf(
        "radio delivery failed for sequence %llu after %u attempts\n",
        static_cast<unsigned long long>(entry.message.sequence),
        entry.attempts
      );
      entry.active = false;
      showLed(LedColor::RED, LED_FAILURE_MS);
    } else {
      transmitPending(entry);
    }
  }
}

void handleLocalButtonPress() {
  const RadioMessage message = makeLocalEvent();
  // A Pi-connected board can also originate events. On a remote board this
  // serial output harmlessly goes nowhere.
  emitSerial(message);

  if (radio_ready) {
    beginReliableSend(message);
  } else {
    showLed(LedColor::RED, LED_FAILURE_MS);
  }
}

void handleReceivedMessages() {
  ReceivedMessage received;
  while (xQueueReceive(received_messages, &received, 0) == pdTRUE) {
    const RadioMessage &message = received.message;
    if (message.kind == MessageKind::ACK) {
      if (message.recipient == node_id) {
        acknowledgePending(message.sequence);
      }
      continue;
    }

    // ACK every valid event, including retries whose first ACK was lost.
    sendAck(message);
    if (wasRecentlyReceived(message)) {
      continue;
    }

    showLed(LedColor::GREEN, LED_SUCCESS_MS);
    emitSerial(message, received.rssi, received.has_rssi);
  }
}

void updateButton() {
  const bool reading = digitalRead(BUTTON_PIN);
  const unsigned long now = millis();

  if (reading != last_button_reading) {
    last_button_reading = reading;
    button_changed_at = now;
  }

  if (reading != stable_button_state &&
      now - button_changed_at >= DEBOUNCE_MS) {
    stable_button_state = reading;
    if (stable_button_state == LOW) {
      handleLocalButtonPress();
    }
  }
}

void setup() {
  pinMode(BUTTON_PIN, INPUT_PULLUP);
#if defined(LED_BUILTIN) && !defined(RGB_BUILTIN)
  pinMode(LED_BUILTIN, OUTPUT);
#endif
  setLed(LedColor::OFF);

  Serial.begin(115200);
  received_messages =
    xQueueCreate(RECEIVE_QUEUE_CAPACITY, sizeof(ReceivedMessage));
  if (received_messages == nullptr) {
    Serial.println("fatal: could not create receive queue");
    return;
  }

  node_id = ESP.getEfuseMac();
  boot_nonce = esp_random();
  radio_ready = setupRadio();
  Serial.printf(
    "fx node %012llX ready; ESP-NOW channel %u; reliable radio %s\n",
    static_cast<unsigned long long>(node_id & 0xffffffffffffULL),
    ESPNOW_CHANNEL,
    radio_ready ? "ready" : "unavailable"
  );
}

void loop() {
  if (received_messages != nullptr) {
    handleReceivedMessages();
  }
  updatePendingMessages();
  updateButton();
  updateLed();
  delay(1);
}
