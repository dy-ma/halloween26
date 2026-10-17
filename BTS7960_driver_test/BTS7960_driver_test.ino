const int FORWARD_BUTTON = 9;
const int REVERSE_BUTTON = 11;
const int POT_PIN = 4;

const int RPWM_PIN = 5;
const int LPWM_PIN = 6;

int previousDirection = 0;

void stopMotor() {
  ledcWrite(RPWM_PIN, 0);
  ledcWrite(LPWM_PIN, 0);
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(FORWARD_BUTTON, INPUT_PULLUP);
  pinMode(REVERSE_BUTTON, INPUT_PULLUP);

  analogReadResolution(12);

  ledcAttach(RPWM_PIN, 20000, 8);
  ledcAttach(LPWM_PIN, 20000, 8);

  stopMotor();

  Serial.println("Motor controller ready");
}

void loop() {
  bool forwardPressed =
      digitalRead(FORWARD_BUTTON) == LOW;

  bool reversePressed =
      digitalRead(REVERSE_BUTTON) == LOW;

  int potValue = analogRead(POT_PIN);
  int motorSpeed = map(potValue, 0, 4095, 0, 255);
  int speedPercent = map(motorSpeed, 0, 255, 0, 100);

  if (motorSpeed < 8) {
    motorSpeed = 0;
  }

  int requestedDirection = 0;

  if (forwardPressed && !reversePressed) {
    requestedDirection = 1;
  } else if (reversePressed && !forwardPressed) {
    requestedDirection = -1;
  }

  // Stop briefly before directly reversing.
  if (requestedDirection != 0 &&
      previousDirection != 0 &&
      requestedDirection != previousDirection) {
    stopMotor();
    delay(250);
  }

  if (requestedDirection == 1) {
    ledcWrite(LPWM_PIN, 0);
    ledcWrite(RPWM_PIN, motorSpeed);

    Serial.printf(
      "FORWARD | pot=%d | speed=%d%% | PWM=%d\n",
      potValue, speedPercent, motorSpeed
    );
  } else if (requestedDirection == -1) {
    ledcWrite(RPWM_PIN, 0);
    ledcWrite(LPWM_PIN, motorSpeed);

    Serial.printf(
      "REVERSE | pot=%d | speed=%d%% | PWM=%d\n",
      potValue, speedPercent, motorSpeed
    );
  } else {
    stopMotor();

    if (forwardPressed && reversePressed) {
      Serial.println("BOTH PRESSED — STOP");
    }
  }

  previousDirection = requestedDirection;
  delay(50);
}