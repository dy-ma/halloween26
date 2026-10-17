const int LIMIT_PIN = 3;

void setup() {
  Serial.begin(115200);
  pinMode(LIMIT_PIN, INPUT_PULLUP);
}

void loop() {
  int limit = digitalRead(LIMIT_PIN);

  Serial.print("Limit:");
  Serial.print(limit);

  // Dummy signals to keep the Y axis fixed
  Serial.print(" Min:");
  Serial.print(-0.2);

  Serial.print(" Max:");
  Serial.println(1.2);

  delay(10);  // 100 samples/sec
}