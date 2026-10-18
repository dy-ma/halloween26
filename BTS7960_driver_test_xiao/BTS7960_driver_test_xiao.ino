/*
  BTS7960 / IBT-2 manual motor controller for a Seeed XIAO ESP32-S3
  on the Seeed Studio Expansion Base for XIAO.

  Controls:
    - Hold the Expansion Base Button (D1) to run.
    - Potentiometer below center: reverse/counterclockwise.
    - Potentiometer above center: forward/clockwise.
    - A dead band around center stops and disables the bridge.
    - Releasing the button immediately stops and disables the bridge.

  The sketch defaults to SERIAL_TEST_ONLY mode. In that mode it prints the
  requested command and speed while keeping R_EN, L_EN, RPWM, and LPWM low.
  Change SERIAL_TEST_ONLY to false only after the serial test looks correct.

  Signal wiring (the six-pin logic header on the BTS7960 module):
    Expansion Base GND   -> BTS7960 GND
    XIAO VBUS (USB 5V)   -> BTS7960 VCC
    XIAO D7              -> BTS7960 R_EN
    XIAO D8              -> BTS7960 L_EN
    XIAO D9              -> BTS7960 RPWM
    XIAO D10             -> BTS7960 LPWM
    BTS7960 R_IS and L_IS are unused and may be left disconnected.

  VCC is logic power only; never connect 24 V to it. These six connections are
  all available together on the exposed upper female socket row beside the
  XIAO: VBUS, GND, D10, D9, D8, and D7. Leave the 3V3 socket unused.

  Power wiring:
    24 V supply + -> BTS7960 B+
    24 V supply - -> BTS7960 B-
    Motor leads   -> BTS7960 M+ and M-

  The Expansion Base potentiometer remains connected to A0/D0. The onboard
  user button is already connected to D1 and is active-low.

  D7-D10 are shared with the Expansion Base UART and microSD connections.
  Leave the UART Grove connector unused and do not insert a microSD card while
  using this mapping.

  Clockwise direction depends on the motor-lead order. Swap M+ and M- if the
  physical direction is opposite to the labels used here.

  This sketch targets Arduino-ESP32 core 3.x.
*/

#include <Arduino.h>
#include <U8x8lib.h>
#include <Wire.h>

constexpr uint8_t POT_PIN = A0;
constexpr uint8_t BUTTON_PIN = D1;

constexpr uint8_t R_EN_PIN = D7;
constexpr uint8_t L_EN_PIN = D8;
constexpr uint8_t RPWM_PIN = D9;
constexpr uint8_t LPWM_PIN = D10;

constexpr bool SERIAL_TEST_ONLY = false;

constexpr uint16_t ADC_MAX = 4095;
constexpr uint16_t ADC_CENTER = ADC_MAX / 2;
constexpr uint16_t CENTER_DEAD_BAND = 180;

constexpr uint32_t PWM_FREQUENCY_HZ = 20000;
constexpr uint8_t PWM_RESOLUTION_BITS = 8;
constexpr uint8_t PWM_MAX = (1U << PWM_RESOLUTION_BITS) - 1;

constexpr uint16_t REVERSAL_PAUSE_MS = 300;
constexpr uint8_t RAMP_STEP = 4;
constexpr uint16_t LOOP_DELAY_MS = 10;
constexpr uint16_t SERIAL_REPORT_INTERVAL_MS = 100;
constexpr uint16_t DISPLAY_REPORT_INTERVAL_MS = 25;

// The Expansion Base OLED is internally wired to D4/SDA and D5/SCL.
U8X8_SSD1306_128X64_NONAME_HW_I2C oled(U8X8_PIN_NONE, SCL, SDA);

enum class Direction : uint8_t {
  Stopped,
  Clockwise,
  Reverse,
};

struct MotorRequest {
  Direction direction;
  uint8_t duty;
};

Direction activeDirection = Direction::Stopped;
uint8_t activeDuty = 0;
bool buttonArmed = false;
uint32_t lastSerialReportMs = 0;
uint32_t lastDisplayReportMs = 0;

void disableBridge() {
  // Remove PWM first, then put both half-bridges into high impedance.
  ledcWrite(RPWM_PIN, 0);
  ledcWrite(LPWM_PIN, 0);
  digitalWrite(R_EN_PIN, LOW);
  digitalWrite(L_EN_PIN, LOW);

  activeDirection = Direction::Stopped;
  activeDuty = 0;
}

uint16_t readPot() {
  // A small average makes the center transition less sensitive to ADC noise.
  uint32_t total = 0;
  constexpr uint8_t SAMPLE_COUNT = 8;

  for (uint8_t sample = 0; sample < SAMPLE_COUNT; ++sample) {
    total += analogRead(POT_PIN);
  }

  return total / SAMPLE_COUNT;
}

MotorRequest requestFromPot(uint16_t pot) {
  const uint16_t lowerEdge = ADC_CENTER - CENTER_DEAD_BAND;
  const uint16_t upperEdge = ADC_CENTER + CENTER_DEAD_BAND;

  if (pot < lowerEdge) {
    const long mapped = map(pot, lowerEdge, 0, 0, PWM_MAX);
    return {Direction::Reverse,
            static_cast<uint8_t>(constrain(mapped, 0L, long(PWM_MAX)))};
  }

  if (pot > upperEdge) {
    const long mapped = map(pot, upperEdge, ADC_MAX, 0, PWM_MAX);
    return {Direction::Clockwise,
            static_cast<uint8_t>(constrain(mapped, 0L, long(PWM_MAX)))};
  }

  return {Direction::Stopped, 0};
}

const char *directionName(Direction direction) {
  switch (direction) {
    case Direction::Clockwise:
      return "FWD";
    case Direction::Reverse:
      return "REV";
    default:
      return "STOP";
  }
}

void printSerialTest(bool runButtonHeld, uint16_t pot,
                     const MotorRequest &request) {
  // USB logging must never stall the motor/UI loop when no monitor is reading.
  if (!Serial) {
    return;
  }

  const uint32_t now = millis();
  if (now - lastSerialReportMs < SERIAL_REPORT_INTERVAL_MS) {
    return;
  }
  lastSerialReportMs = now;

  const char *motorCommand;
  uint8_t commandedDuty = 0;
  if (!buttonArmed) {
    motorCommand = "WAIT";
  } else if (!runButtonHeld) {
    motorCommand = "STOP";
  } else {
    motorCommand = directionName(request.direction);
    commandedDuty = request.duty;
  }

  const uint8_t targetSpeedPercent =
      static_cast<uint8_t>((uint16_t(request.duty) * 100U + 127U) / PWM_MAX);
  const uint8_t commandedSpeedPercent =
      static_cast<uint8_t>((uint16_t(commandedDuty) * 100U + 127U) / PWM_MAX);

  Serial.printf(
      "pot=%4u -> %-4s %3u%% | button=%s | motor=%-4s %3u%%\n", pot,
      directionName(request.direction), targetSpeedPercent,
      runButtonHeld ? "DOWN" : "UP", motorCommand, commandedSpeedPercent);
}

void updateDisplay(bool runButtonHeld, uint16_t pot,
                   const MotorRequest &request) {
  const uint32_t now = millis();
  if (now - lastDisplayReportMs < DISPLAY_REPORT_INTERVAL_MS) {
    return;
  }
  lastDisplayReportMs = now;

  const char *motorCommand;
  uint8_t commandedDuty = 0;
  if (!buttonArmed) {
    motorCommand = "WAIT";
  } else if (!runButtonHeld) {
    motorCommand = "STOP";
  } else {
    motorCommand = directionName(request.direction);
    commandedDuty = request.duty;
  }

  const uint8_t targetSpeedPercent =
      static_cast<uint8_t>((uint16_t(request.duty) * 100U + 127U) / PWM_MAX);
  const uint8_t commandedSpeedPercent =
      static_cast<uint8_t>((uint16_t(commandedDuty) * 100U + 127U) / PWM_MAX);

  char line[17];

  snprintf(line, sizeof(line), "POT %4u        ", pot);
  oled.drawString(0, 2, line);

  if (request.direction == Direction::Reverse) {
    snprintf(line, sizeof(line), "<< REV      %3u%%", targetSpeedPercent);
  } else if (request.direction == Direction::Clockwise) {
    snprintf(line, sizeof(line), "FWD >>      %3u%%", targetSpeedPercent);
  } else {
    snprintf(line, sizeof(line), "--- STOP ---    ");
  }
  oled.drawString(0, 3, line);

  snprintf(line, sizeof(line), "BUTTON %-4s     ", runButtonHeld ? "DOWN" : "UP");
  oled.drawString(0, 5, line);

  snprintf(line, sizeof(line), "MOTOR %-4s %3u%% ", motorCommand,
           commandedSpeedPercent);
  oled.drawString(0, 6, line);
}

uint8_t rampToward(uint8_t current, uint8_t target) {
  if (current < target) {
    const uint16_t next = current + RAMP_STEP;
    return static_cast<uint8_t>(next < target ? next : target);
  }

  if (current > target) {
    const int16_t next = current - RAMP_STEP;
    return static_cast<uint8_t>(next > target ? next : target);
  }

  return current;
}

void applyMotorRequest(const MotorRequest &request) {
  if (request.direction == Direction::Stopped || request.duty == 0) {
    disableBridge();
    return;
  }

  // Never reverse a moving motor. Disable it, pause, and let the next loop
  // re-read both the button and potentiometer before starting the other way.
  if (activeDirection != Direction::Stopped &&
      activeDirection != request.direction) {
    disableBridge();
    delay(REVERSAL_PAUSE_MS);
    return;
  }

  if (activeDirection == Direction::Stopped) {
    activeDirection = request.direction;
    activeDuty = 0;

    // Establish known PWM states before enabling either half-bridge.
    ledcWrite(RPWM_PIN, 0);
    ledcWrite(LPWM_PIN, 0);
    digitalWrite(R_EN_PIN, HIGH);
    digitalWrite(L_EN_PIN, HIGH);
  }

  activeDuty = rampToward(activeDuty, request.duty);

  // Exactly one PWM input is active at a time.
  if (activeDirection == Direction::Clockwise) {
    ledcWrite(LPWM_PIN, 0);
    ledcWrite(RPWM_PIN, activeDuty);
  } else {
    ledcWrite(RPWM_PIN, 0);
    ledcWrite(LPWM_PIN, activeDuty);
  }
}

void setup() {
  // Put all bridge controls low as early as possible during startup.
  pinMode(R_EN_PIN, OUTPUT);
  pinMode(L_EN_PIN, OUTPUT);
  pinMode(RPWM_PIN, OUTPUT);
  pinMode(LPWM_PIN, OUTPUT);

  digitalWrite(R_EN_PIN, LOW);
  digitalWrite(L_EN_PIN, LOW);
  digitalWrite(RPWM_PIN, LOW);
  digitalWrite(LPWM_PIN, LOW);

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(POT_PIN, INPUT);
  analogReadResolution(12);
  analogSetPinAttenuation(POT_PIN, ADC_11db);

  Serial.begin(115200);
  Serial.setTxTimeoutMs(0);

  oled.setBusClock(400000);
  oled.begin();
  oled.setFlipMode(0);
  oled.setFont(u8x8_font_chroma48medium8_r);
  oled.clear();
  oled.drawString(0, 0, "BTS7960 TEST");

  const bool rightPwmReady =
      ledcAttach(RPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);
  const bool leftPwmReady =
      ledcAttach(LPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);

  if (!rightPwmReady || !leftPwmReady) {
    disableBridge();
    while (true) {
      delay(1000);
    }
  }

  disableBridge();

  if (SERIAL_TEST_ONLY) {
    Serial.println();
    Serial.println("BTS7960 TEST - motor outputs disabled");
    Serial.println("pot target | button | gated motor command");
    Serial.println("pot calibration: 0=REV 100%, 2047=STOP, 4095=FWD 100%");
  }
}

void loop() {
  const bool runButtonHeld = digitalRead(BUTTON_PIN) == LOW;
  const uint16_t pot = readPot();
  const MotorRequest request = requestFromPot(pot);

  if (SERIAL_TEST_ONLY) {
    // Keep every driver input low even if a BTS7960 is already connected.
    disableBridge();

    if (!runButtonHeld) {
      buttonArmed = true;
    }

    printSerialTest(runButtonHeld, pot, request);
    updateDisplay(runButtonHeld, pot, request);
    delay(LOOP_DELAY_MS);
    return;
  }

  if (!runButtonHeld) {
    // Require one observed release after every reset before motion is allowed.
    buttonArmed = true;
    disableBridge();
    updateDisplay(runButtonHeld, pot, request);
    delay(LOOP_DELAY_MS);
    return;
  }

  if (!buttonArmed) {
    disableBridge();
    updateDisplay(runButtonHeld, pot, request);
    delay(LOOP_DELAY_MS);
    return;
  }

  applyMotorRequest(request);
  updateDisplay(runButtonHeld, pot, request);
  delay(LOOP_DELAY_MS);
}
