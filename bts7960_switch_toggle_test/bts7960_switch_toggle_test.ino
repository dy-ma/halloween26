/*
  Standalone XIAO ESP32-S3 + BTS7960 switch-toggle bench test

  Wiring:
    D9 -> joined R_EN + L_EN
    D8 -> LPWM
    D7 -> RPWM
    D6 -> filtered NC limit-switch input

  Limit switch:
    COM -> GND
    NC  -> signal cable
    NO  -> unused

  External input network:
    10k pull-up to 3V3, 100 nF to GND, and 1k series to D6.

  Behavior:
    - Boots with the motor stopped.
    - Requires the NC circuit to be closed/LOW before it is armed.
    - First press/opening starts the motor slowly.
    - Release, then press/open again to stop it.
    - Holding the switch does not cause repeated toggles.
    - A 10-second timeout stops the motor as a bench-test backstop.

  CAUTION: An NC switch opening and a broken/disconnected wire both read HIGH.
  While stopped, either event after arming can start the motor in this special
  toggle test. Do not use this behavior as production limit-switch logic.
*/

#include <Arduino.h>

constexpr uint8_t ENABLE_PIN = D9;
constexpr uint8_t LPWM_PIN = D8;
constexpr uint8_t RPWM_PIN = D7;
constexpr uint8_t SWITCH_PIN = D6;

constexpr uint32_t PWM_FREQUENCY_HZ = 20000;
constexpr uint8_t PWM_RESOLUTION_BITS = 8;
constexpr uint8_t MOTOR_DUTY = 80;  // 0-255; about 31% command
constexpr uint32_t DEBOUNCE_MS = 35;
constexpr uint32_t MAX_RUN_MS = 10000;

bool motorRunning = false;
bool stableSwitchOpen = false;
bool lastRawSwitchOpen = false;
bool switchArmed = false;
uint32_t rawChangedAtMs = 0;
uint32_t motorStartedAtMs = 0;

void stopMotor() {
  // Remove drive before disabling the bridge.
  ledcWrite(RPWM_PIN, 0);
  ledcWrite(LPWM_PIN, 0);
  digitalWrite(ENABLE_PIN, LOW);
  motorRunning = false;
  motorStartedAtMs = 0;
}

void startMotor() {
  // This test drives RPWM only. Swap RPWM/LPWM here to reverse direction.
  ledcWrite(LPWM_PIN, 0);
  ledcWrite(RPWM_PIN, 0);
  digitalWrite(ENABLE_PIN, HIGH);
  ledcWrite(RPWM_PIN, MOTOR_DUTY);
  motorRunning = true;
  motorStartedAtMs = millis();
}

void toggleMotor() {
  if (motorRunning) {
    stopMotor();
  } else {
    startMotor();
  }
}

void updateSwitch() {
  const uint32_t now = millis();
  const bool rawSwitchOpen = digitalRead(SWITCH_PIN) == HIGH;

  if (rawSwitchOpen != lastRawSwitchOpen) {
    lastRawSwitchOpen = rawSwitchOpen;
    rawChangedAtMs = now;
  }

  if (rawSwitchOpen != stableSwitchOpen &&
      now - rawChangedAtMs >= DEBOUNCE_MS) {
    stableSwitchOpen = rawSwitchOpen;

    if (!stableSwitchOpen) {
      // Arm only after a stable release/closed NC circuit.
      switchArmed = true;
    } else if (switchArmed) {
      // Consume one press. It must return LOW before another can register.
      switchArmed = false;
      toggleMotor();
    }
  }
}

void setup() {
  pinMode(ENABLE_PIN, OUTPUT);
  pinMode(RPWM_PIN, OUTPUT);
  pinMode(LPWM_PIN, OUTPUT);
  digitalWrite(ENABLE_PIN, LOW);
  digitalWrite(RPWM_PIN, LOW);
  digitalWrite(LPWM_PIN, LOW);

  // The board already has the external 10k pull-up.
  pinMode(SWITCH_PIN, INPUT);

  const bool rightAttached =
      ledcAttach(RPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);
  const bool leftAttached =
      ledcAttach(LPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);

  if (!rightAttached || !leftAttached) {
    stopMotor();
    while (true) {
      delay(1000);
    }
  }

  stopMotor();
  delay(150);  // Let the external RC input settle before sampling it.

  stableSwitchOpen = digitalRead(SWITCH_PIN) == HIGH;
  lastRawSwitchOpen = stableSwitchOpen;
  rawChangedAtMs = millis();
  switchArmed = !stableSwitchOpen;
}

void loop() {
  updateSwitch();

  if (motorRunning && millis() - motorStartedAtMs >= MAX_RUN_MS) {
    stopMotor();
  }

  delay(1);
}
