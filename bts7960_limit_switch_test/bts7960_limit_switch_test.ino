/*
  XIAO ESP32-S3 + BTS7960/IBT-2 motor and NC limit-switch bench test

  Logic wiring:
    XIAO D9  -> joined R_EN + L_EN
    XIAO D8  -> LPWM
    XIAO D7  -> RPWM
    XIAO D6  -> filtered limit-switch input
    XIAO 3V3 -> BTS7960 VCC
    XIAO GND -> BTS7960 GND

  Limit-switch wiring:
    COM -> GND
    NC  -> signal cable
    NO  -> unused

  The external 10k pull-up means the limit input uses INPUT, not INPUT_PULLUP.
  Normal/unpressed and connected = LOW.
  Pressed, disconnected, or broken cable = HIGH and stops the motor.

  Serial monitor: 115200 baud, Newline ending
    f 80        Forward at duty 80 for at most 4 seconds
    r 80        Reverse at duty 80 for at most 4 seconds
    f 80 2000   Forward at duty 80 for at most 2000 ms
    s           Stop immediately
    status      Print motor and switch state
    help        Print commands

  Start with the motor mechanically unloaded and a low duty such as 50-80.
  This sketch targets Arduino-ESP32 core 3.x.
*/

#include <Arduino.h>

constexpr uint8_t ENABLE_PIN = D9;
constexpr uint8_t LPWM_PIN = D8;
constexpr uint8_t RPWM_PIN = D7;
constexpr uint8_t LIMIT_PIN = D6;

constexpr uint32_t PWM_FREQUENCY_HZ = 20000;
constexpr uint8_t PWM_RESOLUTION_BITS = 8;
constexpr uint16_t REVERSAL_PAUSE_MS = 300;
constexpr uint16_t LIMIT_DEBOUNCE_MS = 20;
constexpr uint32_t DEFAULT_RUN_TIMEOUT_MS = 4000;
constexpr uint32_t MAX_RUN_TIMEOUT_MS = 10000;

enum class Direction : uint8_t {
  Stopped,
  Forward,
  Reverse,
};

Direction currentDirection = Direction::Stopped;
uint8_t currentDuty = 0;
uint32_t stopDeadlineMs = 0;

bool stableLimitTriggered = false;
bool lastRawLimitTriggered = false;
uint32_t rawLimitChangedMs = 0;

char commandBuffer[48];
size_t commandLength = 0;

const char *directionName(Direction direction) {
  switch (direction) {
    case Direction::Forward:
      return "FORWARD";
    case Direction::Reverse:
      return "REVERSE";
    default:
      return "STOPPED";
  }
}

bool motorRunning() {
  return currentDirection != Direction::Stopped;
}

void stopMotor(const char *reason, bool printMessage = true) {
  // Remove PWM first, then disable both bridge channels through the joined ENs.
  ledcWrite(RPWM_PIN, 0);
  ledcWrite(LPWM_PIN, 0);
  digitalWrite(ENABLE_PIN, LOW);

  const bool wasRunning = motorRunning();
  currentDirection = Direction::Stopped;
  currentDuty = 0;
  stopDeadlineMs = 0;

  if (printMessage && (wasRunning || reason != nullptr)) {
    Serial.print("MOTOR: STOP");
    if (reason != nullptr) {
      Serial.print(" — ");
      Serial.print(reason);
    }
    Serial.println();
  }
}

void printLimitState(const char *prefix) {
  Serial.print(prefix);
  Serial.print(stableLimitTriggered ? "TRIGGERED/HIGH" : "CLEAR/LOW");
  Serial.println(stableLimitTriggered
                     ? " (pressed, disconnected, or broken wire)"
                     : " (NC circuit closed)");
}

void printStatus() {
  Serial.print("STATUS: motor=");
  Serial.print(directionName(currentDirection));
  Serial.print(" duty=");
  Serial.print(currentDuty);
  Serial.print(" EN=");
  Serial.print(digitalRead(ENABLE_PIN) == HIGH ? "HIGH" : "LOW");
  Serial.print(" limit_raw=");
  Serial.print(digitalRead(LIMIT_PIN) == HIGH ? "HIGH" : "LOW");
  Serial.print(" limit_debounced=");
  Serial.println(stableLimitTriggered ? "TRIGGERED" : "CLEAR");
}

void printHelp() {
  Serial.println();
  Serial.println("BTS7960 + limit-switch test ready.");
  Serial.println("Commands (Newline ending):");
  Serial.println("  f 80        forward, duty 0-255, 4 s timeout");
  Serial.println("  r 80        reverse, duty 0-255, 4 s timeout");
  Serial.println("  f 80 2000   forward, duty 80, 2000 ms timeout");
  Serial.println("  s           stop");
  Serial.println("  status      show motor and limit state");
  Serial.println("  help        show this help");
  Serial.println("Start at 50-80 with the motor mechanically unloaded.");
  Serial.println("Any raw HIGH on D6 stops and disables the bridge immediately.");
}

void updateLimitSwitch() {
  const bool rawTriggered = digitalRead(LIMIT_PIN) == HIGH;
  const uint32_t now = millis();

  // A raw HIGH is fail-safe: stop immediately instead of waiting for debounce.
  if (rawTriggered && motorRunning()) {
    stopMotor("LIMIT D6 went HIGH");
  }

  if (rawTriggered != lastRawLimitTriggered) {
    lastRawLimitTriggered = rawTriggered;
    rawLimitChangedMs = now;
  }

  if (rawTriggered != stableLimitTriggered &&
      now - rawLimitChangedMs >= LIMIT_DEBOUNCE_MS) {
    stableLimitTriggered = rawTriggered;
    printLimitState("LIMIT: ");
  }
}

void driveMotor(Direction requestedDirection, uint8_t duty,
                uint32_t timeoutMs) {
  if (duty == 0 || requestedDirection == Direction::Stopped) {
    stopMotor("zero-duty command");
    return;
  }

  // Both raw and debounced states must be clear before a run may begin.
  if (digitalRead(LIMIT_PIN) == HIGH || stableLimitTriggered) {
    stopMotor(nullptr, false);
    Serial.println("REJECTED: limit is HIGH; release/check the switch and cable.");
    return;
  }

  if (motorRunning() && currentDirection != requestedDirection) {
    stopMotor("direction change");
    delay(REVERSAL_PAUSE_MS);

    // Re-check the switch after the reversal pause.
    updateLimitSwitch();
    if (digitalRead(LIMIT_PIN) == HIGH || stableLimitTriggered) {
      Serial.println("REJECTED: limit became HIGH during direction pause.");
      return;
    }
  }

  ledcWrite(RPWM_PIN, 0);
  ledcWrite(LPWM_PIN, 0);
  digitalWrite(ENABLE_PIN, HIGH);

  if (requestedDirection == Direction::Forward) {
    ledcWrite(RPWM_PIN, duty);
  } else {
    ledcWrite(LPWM_PIN, duty);
  }

  currentDirection = requestedDirection;
  currentDuty = duty;
  stopDeadlineMs = millis() + timeoutMs;

  Serial.print("MOTOR: ");
  Serial.print(directionName(requestedDirection));
  Serial.print(" duty=");
  Serial.print(duty);
  Serial.print(" timeout_ms=");
  Serial.println(timeoutMs);
}

void handleCommand(char *line) {
  while (*line == ' ' || *line == '\t') {
    ++line;
  }

  for (char *cursor = line; *cursor != '\0'; ++cursor) {
    if (*cursor >= 'A' && *cursor <= 'Z') {
      *cursor = static_cast<char>(*cursor - 'A' + 'a');
    }
  }

  if (strcmp(line, "s") == 0 || strcmp(line, "stop") == 0) {
    stopMotor("serial command");
    return;
  }

  if (strcmp(line, "status") == 0) {
    printStatus();
    return;
  }

  if (strcmp(line, "help") == 0 || strcmp(line, "?") == 0) {
    printHelp();
    return;
  }

  char action = '\0';
  int requestedDuty = -1;
  unsigned long requestedTimeoutMs = DEFAULT_RUN_TIMEOUT_MS;
  const int fields =
      sscanf(line, " %c %d %lu", &action, &requestedDuty, &requestedTimeoutMs);

  if (fields < 2 || (action != 'f' && action != 'r') || requestedDuty < 0 ||
      requestedDuty > 255 || requestedTimeoutMs == 0 ||
      requestedTimeoutMs > MAX_RUN_TIMEOUT_MS) {
    Serial.println(
        "Invalid command. Use f 80, r 80, f 80 2000, s, status, or help.");
    Serial.println("Duty: 0-255. Timeout: 1-10000 ms.");
    return;
  }

  const Direction direction =
      action == 'f' ? Direction::Forward : Direction::Reverse;
  driveMotor(direction, static_cast<uint8_t>(requestedDuty),
             static_cast<uint32_t>(requestedTimeoutMs));
}

void readSerialCommands() {
  while (Serial.available() > 0) {
    const char incoming = static_cast<char>(Serial.read());

    if (incoming == '\r') {
      continue;
    }

    if (incoming == '\n') {
      commandBuffer[commandLength] = '\0';
      if (commandLength > 0) {
        handleCommand(commandBuffer);
      }
      commandLength = 0;
      continue;
    }

    if (commandLength < sizeof(commandBuffer) - 1) {
      commandBuffer[commandLength++] = incoming;
    } else {
      commandLength = 0;
      Serial.println("Command too long; buffer cleared.");
    }
  }
}

void setup() {
  // Establish safe LOW outputs before configuring PWM or accepting commands.
  pinMode(ENABLE_PIN, OUTPUT);
  pinMode(RPWM_PIN, OUTPUT);
  pinMode(LPWM_PIN, OUTPUT);
  digitalWrite(ENABLE_PIN, LOW);
  digitalWrite(RPWM_PIN, LOW);
  digitalWrite(LPWM_PIN, LOW);

  // The board has an external 10k pull-up on this input.
  pinMode(LIMIT_PIN, INPUT);

  Serial.begin(115200);
  delay(500);

  const bool rightAttached =
      ledcAttach(RPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);
  const bool leftAttached =
      ledcAttach(LPWM_PIN, PWM_FREQUENCY_HZ, PWM_RESOLUTION_BITS);

  if (!rightAttached || !leftAttached) {
    stopMotor(nullptr, false);
    Serial.println("ERROR: could not configure PWM outputs; bridge disabled.");
    while (true) {
      delay(1000);
    }
  }

  stopMotor(nullptr, false);

  stableLimitTriggered = digitalRead(LIMIT_PIN) == HIGH;
  lastRawLimitTriggered = stableLimitTriggered;
  rawLimitChangedMs = millis();

  printHelp();
  printLimitState("BOOT LIMIT: ");
  printStatus();
}

void loop() {
  updateLimitSwitch();
  readSerialCommands();

  if (motorRunning() &&
      static_cast<int32_t>(millis() - stopDeadlineMs) >= 0) {
    stopMotor("run timeout");
  }

  // Keep the loop responsive to the fail-safe limit input.
  delay(1);
}
