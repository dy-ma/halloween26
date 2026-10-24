#define CUE_USE_MQTT 1
#define TMC_STEP_PIN D9
#define TMC_DIR_PIN D10
// MQTT uses DMA/RMT with these TB6600 timings and an S-curve profile.
#define TMC_PULSE_HIGH_US 10
#define TMC_DIR_SETUP_US 20
#include "../../src/stepper.cpp"
