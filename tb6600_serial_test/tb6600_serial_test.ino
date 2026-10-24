/*
  TB6600 serial bench test for a Seeed XIAO ESP32-S3.

  Common-cathode signal wiring:
    XIAO GND -> TB6600 PUL- and DIR-
    XIAO D9  -> TB6600 PUL+
    XIAO D10 -> TB6600 DIR+
    TB6600 ENA+ and ENA- are left disconnected

  Motor power is separate:
    Supply + -> TB6600 VCC/DC+
    Supply - -> TB6600 GND/DC-

  Open Serial Monitor at 115200 baud with a newline line ending. The driver is
  idle after boot and remains responsive to "stop" while the motor is moving.

  Commands:
    help              Show this command list
    status            Show the current state
    speed 400         Set pulse rate in steps/second (1..5000)
    fwd               Run forward continuously
    rev               Run reverse continuously
    fwd 1600          Move forward 1600 pulses, then stop
    rev 1600          Move reverse 1600 pulses, then stop
    stop              Stop pulse output immediately

  "steps" means pulses sent to the driver. Mechanical travel depends on the
  motor's full-step angle and the microstep DIP-switch setting.
*/

#include <Arduino.h>

constexpr uint8_t STEP_PIN = D9;
constexpr uint8_t DIR_PIN = D10;

// Conservative timing for the opto-isolated inputs on common TB6600 modules.
constexpr uint32_t STEP_PULSE_HIGH_US = 10;
constexpr uint32_t DIR_SETUP_US = 20;
constexpr uint32_t MIN_STEPS_PER_SECOND = 1;
constexpr uint32_t MAX_STEPS_PER_SECOND = 5000;
constexpr uint32_t DEFAULT_STEPS_PER_SECOND = 400;

constexpr size_t COMMAND_BUFFER_SIZE = 64;

char commandBuffer[COMMAND_BUFFER_SIZE] = {};
size_t commandLength = 0;

bool running = false;
bool continuousMove = false;
bool forwardDirection = true;
bool stepPulseHigh = false;
uint32_t stepsPerSecond = DEFAULT_STEPS_PER_SECOND;
uint32_t stepPeriodUs = 1000000UL / DEFAULT_STEPS_PER_SECOND;
uint32_t stepsRemaining = 0;
uint32_t nextEdgeUs = 0;

bool isDue(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

void printHelp() {
  Serial.println();
  Serial.println("TB6600 serial bench test");
  Serial.println("  help              show commands");
  Serial.println("  status            show current state");
  Serial.println("  speed <1..5000>   set pulse rate in steps/second");
  Serial.println("  fwd               run forward continuously");
  Serial.println("  rev               run reverse continuously");
  Serial.println("  fwd <steps>       move forward a finite pulse count");
  Serial.println("  rev <steps>       move reverse a finite pulse count");
  Serial.println("  stop              stop immediately");
  Serial.println();
}

void printStatus() {
  Serial.printf(
      "state=%s direction=%s speed=%lu_steps/s mode=%s remaining=%lu\n",
      running ? "RUNNING" : "STOPPED",
      forwardDirection ? "FWD" : "REV",
      static_cast<unsigned long>(stepsPerSecond),
      running && continuousMove ? "continuous" : "finite",
      static_cast<unsigned long>(stepsRemaining));
}

void stopMotion(bool report = true) {
  running = false;
  continuousMove = false;
  stepPulseHigh = false;
  stepsRemaining = 0;
  digitalWrite(STEP_PIN, LOW);

  if (report) {
    Serial.println("STOPPED");
  }
}

void startMotion(bool forward, bool continuous, uint32_t steps) {
  // Always end any in-progress pulse before changing direction.
  stopMotion(false);
  forwardDirection = forward;
  continuousMove = continuous;
  stepsRemaining = steps;

  digitalWrite(DIR_PIN, forwardDirection ? HIGH : LOW);
  nextEdgeUs = micros() + DIR_SETUP_US;
  running = true;

  Serial.printf("START %s ", forwardDirection ? "FWD" : "REV");
  if (continuousMove) {
    Serial.printf("continuous at %lu steps/s\n",
                  static_cast<unsigned long>(stepsPerSecond));
  } else {
    Serial.printf("%lu steps at %lu steps/s\n",
                  static_cast<unsigned long>(stepsRemaining),
                  static_cast<unsigned long>(stepsPerSecond));
  }
}

void setSpeed(uint32_t requestedStepsPerSecond) {
  if (requestedStepsPerSecond < MIN_STEPS_PER_SECOND ||
      requestedStepsPerSecond > MAX_STEPS_PER_SECOND) {
    Serial.printf("ERROR speed must be %lu..%lu steps/s\n",
                  static_cast<unsigned long>(MIN_STEPS_PER_SECOND),
                  static_cast<unsigned long>(MAX_STEPS_PER_SECOND));
    return;
  }

  stepsPerSecond = requestedStepsPerSecond;
  stepPeriodUs = 1000000UL / stepsPerSecond;
  Serial.printf("OK speed=%lu steps/s\n",
                static_cast<unsigned long>(stepsPerSecond));
}

void handleCommand(char *line) {
  char command[16] = {};
  unsigned long value = 0;
  char extra = '\0';
  const int fields = sscanf(line, "%15s %lu %c", command, &value, &extra);

  for (char *character = command; *character != '\0'; ++character) {
    *character = static_cast<char>(tolower(static_cast<unsigned char>(*character)));
  }

  if (fields == 1 && strcmp(command, "help") == 0) {
    printHelp();
    return;
  }
  if (fields == 1 && strcmp(command, "status") == 0) {
    printStatus();
    return;
  }
  if (fields == 1 && strcmp(command, "stop") == 0) {
    stopMotion();
    return;
  }
  if (fields == 2 && strcmp(command, "speed") == 0) {
    setSpeed(static_cast<uint32_t>(value));
    return;
  }

  const bool isForward = strcmp(command, "fwd") == 0;
  const bool isReverse = strcmp(command, "rev") == 0;
  if ((isForward || isReverse) && fields == 1) {
    startMotion(isForward, true, 0);
    return;
  }
  if ((isForward || isReverse) && fields == 2 && value > 0 &&
      value <= UINT32_MAX) {
    startMotion(isForward, false, static_cast<uint32_t>(value));
    return;
  }

  Serial.println("ERROR unknown or malformed command; type help");
}

void readSerialCommands() {
  while (Serial.available() > 0) {
    const char incoming = static_cast<char>(Serial.read());

    if (incoming == '\r' || incoming == '\n') {
      if (commandLength > 0) {
        commandBuffer[commandLength] = '\0';
        handleCommand(commandBuffer);
        commandLength = 0;
      }
      continue;
    }

    if (commandLength < COMMAND_BUFFER_SIZE - 1) {
      commandBuffer[commandLength++] = incoming;
    } else {
      commandLength = 0;
      Serial.println("ERROR command too long");
    }
  }
}

void updateMotion() {
  if (!running) {
    return;
  }

  const uint32_t now = micros();
  if (!isDue(now, nextEdgeUs)) {
    return;
  }

  if (!stepPulseHigh) {
    digitalWrite(STEP_PIN, HIGH);
    stepPulseHigh = true;
    nextEdgeUs = now + STEP_PULSE_HIGH_US;
    return;
  }

  digitalWrite(STEP_PIN, LOW);
  stepPulseHigh = false;

  if (!continuousMove) {
    --stepsRemaining;
    if (stepsRemaining == 0) {
      stopMotion(false);
      Serial.println("COMPLETE");
      return;
    }
  }

  nextEdgeUs = now + stepPeriodUs - STEP_PULSE_HIGH_US;
}

void setup() {
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  digitalWrite(STEP_PIN, LOW);
  digitalWrite(DIR_PIN, LOW);

  Serial.begin(115200);
  delay(500);
  printHelp();
  Serial.println("Driver output is idle. Type a command to move.");
}

void loop() {
  readSerialCommands();
  updateMotion();
}
