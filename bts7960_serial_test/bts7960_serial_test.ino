/*
  BTS7960 / IBT-2 serial motor test for an ESP32-S3

  Wiring:
    ESP32 GPIO 4  -> BTS7960 RPWM
    ESP32 GPIO 5  -> BTS7960 LPWM
    ESP32 5V      -> BTS7960 VCC, R_EN, and L_EN
    ESP32 GND     -> BTS7960 GND

    18 V supply + -> BTS7960 B+
    18 V supply - -> BTS7960 B-
    Motor leads   -> BTS7960 M+ and M-

  Serial commands (115200 baud, Newline ending):
    f 80   Drive forward at duty 80 (range 0-255)
    r 80   Drive reverse at duty 80 (range 0-255)
    s      Stop

  This sketch targets Arduino-ESP32 core 3.x.
*/

#include <Arduino.h>

constexpr uint8_t RPWM_PIN = 4;
constexpr uint8_t LPWM_PIN = 5;

constexpr uint32_t PWM_FREQUENCY_HZ = 20000;
constexpr uint8_t PWM_RESOLUTION_BITS = 8;
constexpr uint16_t REVERSAL_PAUSE_MS = 500;

enum class Direction : uint8_t {
  Stopped,
  Forward,
  Reverse,
};

Direction currentDirection = Direction::Stopped;

void stopMotor() {
  // Always switch both inputs off together for a definite stop.
  ledcWrite(RPWM_PIN, 0);
  ledcWrite(LPWM_PIN, 0);
  currentDirection = Direction::Stopped;
}

void driveMotor(Direction requestedDirection, uint8_t duty) {
  if (duty == 0 || requestedDirection == Direction::Stopped) {
    stopMotor();
    return;
  }

  // Never reverse while power is still applied in the old direction.
  if (currentDirection != Direction::Stopped &&
      currentDirection != requestedDirection) {
    stopMotor();
    delay(REVERSAL_PAUSE_MS);
  }

  if (requestedDirection == Direction::Forward) {
    ledcWrite(LPWM_PIN, 0);
    ledcWrite(RPWM_PIN, duty);
  } else {
    ledcWrite(RPWM_PIN, 0);
    ledcWrite(LPWM_PIN, duty);
  }

  currentDirection = requestedDirection;
}

void printHelp() {
  Serial.println();
  Serial.println("BTS7960 motor test ready.");
  Serial.println("Commands:");
  Serial.println("  f 80   forward, speed 0-255");
  Serial.println("  r 80   reverse, speed 0-255");
  Serial.println("  s      stop");
  Serial.println("Start with a low value such as 50-80.");
}

void handleCommand(String command) {
  command.trim();
  command.toLowerCase();

  if (command == "s") {
    stopMotor();
    Serial.println("Stopped");
    return;
  }

  if (command.length() < 3 || command.charAt(1) != ' ') {
    Serial.println("Invalid command. Use f 80, r 80, or s.");
    return;
  }

  const char action = command.charAt(0);
  const int requestedDuty = command.substring(2).toInt();

  if ((action != 'f' && action != 'r') ||
      requestedDuty < 0 || requestedDuty > 255) {
    Serial.println("Invalid command. Speed must be from 0 to 255.");
    return;
  }

  const Direction direction =
      action == 'f' ? Direction::Forward : Direction::Reverse;
  driveMotor(direction, static_cast<uint8_t>(requestedDuty));

  Serial.print(direction == Direction::Forward ? "Forward at " : "Reverse at ");
  Serial.println(requestedDuty);
}

void setup() {
  // Establish LOW outputs before enabling PWM hardware.
  pinMode(RPWM_PIN, OUTPUT);
  pinMode(LPWM_PIN, OUTPUT);
  digitalWrite(RPWM_PIN, LOW);
  digitalWrite(LPWM_PIN, LOW);

  Serial.begin(115200);
  delay(500);

  const bool rightAttached =
      ledcAttach(RPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);
  const bool leftAttached =
      ledcAttach(LPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);

  if (!rightAttached || !leftAttached) {
    stopMotor();
    Serial.println("ERROR: Could not configure PWM outputs.");
    while (true) {
      delay(1000);
    }
  }

  stopMotor();
  printHelp();
}

void loop() {
  if (Serial.available() > 0) {
    handleCommand(Serial.readStringUntil('\n'));
  }
}
