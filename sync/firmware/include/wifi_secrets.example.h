#pragma once

// Copy this file to wifi_secrets.h. The real file is ignored by Git.
#define CUE_WIFI_SSID "travel-router-network"
#define CUE_WIFI_PASSWORD "replace-me"

// This address is from the boards' point of view. If Mosquitto runs on the Pi,
// use the Pi's travel-router address, not 127.0.0.1.
#define CUE_MQTT_HOST "192.168.8.2"
#define CUE_MQTT_PORT 1883
#define CUE_MQTT_TOPIC_PREFIX "halloween"

// Leave both empty for an isolated bring-up network, or configure both here
// and configure matching credentials in Mosquitto.
#define CUE_MQTT_USERNAME ""
#define CUE_MQTT_PASSWORD ""
