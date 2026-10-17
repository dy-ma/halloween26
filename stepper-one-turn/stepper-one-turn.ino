// Spin a 1.8-degree stepper exactly one revolution whenever BOOT is pressed.
// Wiring:
//   ESP32-S3 GPIO9  -> TMC2208 STEP
//   ESP32-S3 GPIO10 -> TMC2208 DIR
//   ESP32-S3 GPIO0  -> onboard BOOT button (active low)
//
// Assumes TMC2208 MS1 and MS2 are grounded for 1/8 microstepping.

constexpr uint8_t STEP_PIN = 9;
constexpr uint8_t DIR_PIN = 10;
constexpr uint8_t BOOT_BUTTON_PIN = 0;

constexpr uint16_t MOTOR_FULL_STEPS = 200;
constexpr uint8_t MICROSTEPS = 8;
constexpr uint16_t STEPS_PER_REVOLUTION = MOTOR_FULL_STEPS * MICROSTEPS;

constexpr uint16_t START_RPM = 20;
constexpr uint16_t TARGET_RPM = 120;
constexpr uint16_t RAMP_STEPS = 300;
constexpr bool DIRECTION = HIGH;

constexpr uint32_t START_STEP_PERIOD_US =
    60000000UL / (STEPS_PER_REVOLUTION * START_RPM);
constexpr uint32_t TARGET_STEP_PERIOD_US =
    60000000UL / (STEPS_PER_REVOLUTION * TARGET_RPM);
constexpr uint32_t STEP_PERIOD_RANGE_US =
    START_STEP_PERIOD_US - TARGET_STEP_PERIOD_US;
constexpr uint32_t STEP_PULSE_HIGH_US = 4;

bool buttonWasPressed = false;

void spinOneRevolution() {
  digitalWrite(DIR_PIN, DIRECTION);
  delayMicroseconds(10);

  for (uint16_t step = 0; step < STEPS_PER_REVOLUTION; ++step) {
    uint32_t stepPeriodUs = TARGET_STEP_PERIOD_US;

    if (step < RAMP_STEPS) {
      // Accelerate by shortening the interval between STEP pulses.
      stepPeriodUs = START_STEP_PERIOD_US -
                     (STEP_PERIOD_RANGE_US * step) / RAMP_STEPS;
    } else if (step >= STEPS_PER_REVOLUTION - RAMP_STEPS) {
      // Decelerate for a gentler stop.
      const uint16_t rampPosition =
          step - (STEPS_PER_REVOLUTION - RAMP_STEPS);
      stepPeriodUs = TARGET_STEP_PERIOD_US +
                     (STEP_PERIOD_RANGE_US * rampPosition) / RAMP_STEPS;
    }

    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(STEP_PULSE_HIGH_US);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(stepPeriodUs - STEP_PULSE_HIGH_US);
  }
}

void setup() {
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(BOOT_BUTTON_PIN, INPUT_PULLUP);

  digitalWrite(STEP_PIN, LOW);
  digitalWrite(DIR_PIN, DIRECTION);
}

void loop() {
  const bool buttonPressed = digitalRead(BOOT_BUTTON_PIN) == LOW;

  if (buttonPressed && !buttonWasPressed) {
    delay(20);  // Debounce the button contact.
    if (digitalRead(BOOT_BUTTON_PIN) == LOW) {
      spinOneRevolution();
    }
  }

  buttonWasPressed = buttonPressed;
  delay(5);
}
