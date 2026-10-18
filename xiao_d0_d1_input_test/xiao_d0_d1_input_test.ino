/*
  Minimal Seeed XIAO ESP32-S3 Expansion Base input test.

  This intentionally uses the ESP32-S3 GPIO numbers rather than Arduino pin
  aliases so the test does not depend on D0/D1/A0 board-name resolution:

    Expansion Base A0/D0 Grove SIG -> XIAO GPIO1
    Expansion Base Button(D1)      -> XIAO GPIO2 (active-low)

  Nothing else is initialized. Open USB Serial Monitor at 115200 baud.
*/

#include <Arduino.h>

constexpr uint8_t POT_GPIO = 1;
constexpr uint8_t BUTTON_GPIO = 2;
constexpr uint8_t ADC_SAMPLE_COUNT = 32;
constexpr uint16_t REPORT_INTERVAL_MS = 200;

uint16_t minimumPotSeen = 4095;
uint16_t maximumPotSeen = 0;

uint16_t readAveragedPot() {
  uint32_t total = 0;

  for (uint8_t sample = 0; sample < ADC_SAMPLE_COUNT; ++sample) {
    total += analogRead(POT_GPIO);
  }

  return total / ADC_SAMPLE_COUNT;
}

void setup() {
  pinMode(BUTTON_GPIO, INPUT_PULLUP);
  pinMode(POT_GPIO, INPUT);

  analogReadResolution(12);
  analogSetPinAttenuation(POT_GPIO, ADC_11db);

  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("XIAO Expansion Base D0/D1 input test");
  Serial.println("D0/A0 = raw GPIO1; Button D1 = raw GPIO2");
  Serial.println("Expected button: released=HIGH, held=LOW");
}

void loop() {
  const int buttonLevel = digitalRead(BUTTON_GPIO);
  const uint16_t pot = readAveragedPot();

  minimumPotSeen = min(minimumPotSeen, pot);
  maximumPotSeen = max(maximumPotSeen, pot);

  Serial.printf(
      "GPIO1 pot=%4u  seen=%4u..%4u  |  GPIO2 button=%s (%s)\n",
      pot, minimumPotSeen, maximumPotSeen,
      buttonLevel == LOW ? "LOW " : "HIGH",
      buttonLevel == LOW ? "HELD" : "RELEASED");

  delay(REPORT_INTERVAL_MS);
}
