#pragma once

#ifndef CUE_USE_MQTT
#define CUE_USE_MQTT 0
#endif

#if CUE_USE_MQTT
#include <MqttTransport.h>

#if __has_include("../include/wifi_secrets.h")
#include "../include/wifi_secrets.h"
#endif

#ifndef CUE_WIFI_SSID
#define CUE_WIFI_SSID ""
#endif
#ifndef CUE_WIFI_PASSWORD
#define CUE_WIFI_PASSWORD ""
#endif
#ifndef CUE_MQTT_HOST
#define CUE_MQTT_HOST ""
#endif
#ifndef CUE_MQTT_PORT
#define CUE_MQTT_PORT 1883
#endif
#ifndef CUE_MQTT_TOPIC_PREFIX
#define CUE_MQTT_TOPIC_PREFIX "halloween"
#endif
#ifndef CUE_MQTT_USERNAME
#define CUE_MQTT_USERNAME ""
#endif
#ifndef CUE_MQTT_PASSWORD
#define CUE_MQTT_PASSWORD ""
#endif

namespace sync_transport {

using Transport = cue::MqttTransport;

inline Transport::Config config(const char *service) {
  return Transport::Config(
    CUE_WIFI_SSID,
    CUE_WIFI_PASSWORD,
    CUE_MQTT_HOST,
    CUE_MQTT_PORT,
    CUE_MQTT_TOPIC_PREFIX,
    service,
    CUE_MQTT_USERNAME,
    CUE_MQTT_PASSWORD
  );
}

constexpr const char *name = "mqtt";

}  // namespace sync_transport

#else

#include <EspNowTransport.h>

namespace sync_transport {

using Transport = cue::EspNowTransport;

inline Transport::Config config(const char *service) {
  return Transport::Config(1, 5, 70, 240, 1000, true, service);
}

constexpr const char *name = "esp-now";

}  // namespace sync_transport

#endif
