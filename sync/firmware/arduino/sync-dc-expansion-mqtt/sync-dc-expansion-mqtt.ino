#define CUE_USE_MQTT 1
#define DC_REN_PIN D9
#define DC_LEN_PIN D9
#define DC_RPWM_PIN D7
#define DC_LPWM_PIN D8
#define DC_LIMIT_FWD_PIN D6
#define DC_LIMIT_REV_PIN D5
// External 3V3 pull-ups and NC contacts to GND: open/pressed = HIGH.
#define DC_LIMIT_ACTIVE_LEVEL HIGH
#define DC_LIMIT_INPUT_MODE INPUT
#include "../../src/dc_motor.cpp"
