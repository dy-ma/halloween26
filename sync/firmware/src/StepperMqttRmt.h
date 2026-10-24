#pragma once

#include "StepperRmtOutput.h"
#include <esp_rom_gpio.h>
#include <soc/gpio_sig_map.h>

namespace {

sync_transport::Transport::Config transport_config = sync_transport::config("stepper");
sync_transport::Transport transport(transport_config);
cue::Node node;
StepperRmtOutput pulse_output;
bool pulse_ready = false;
bool running = false;
bool jogging = false;
bool direction_forward = true;
uint16_t active_rpm = 0;
uint32_t jog_stop_at_ms = 0;
uint64_t report_destination = 0;
uint64_t report_command_id = 0;

void reportTo(uint64_t destination, const char *name, uint64_t command_id) {
  if (destination == 0) return;
  cue::Message message;
  if (makeAssemblyStatus(node, destination, name, command_id, message)) transport.trySend(message);
}

void report(const char *name) { reportTo(report_destination, name, report_command_id); }

bool haltPulses() {
  const bool stopped = pulse_output.stop();
  running = false;
  jogging = false;
  jog_stop_at_ms = 0;
  if (!stopped) {
    // Fault fallback disconnects RMT from PUL and forces the pad LOW.
    gpio_reset_pin(static_cast<gpio_num_t>(TMC_STEP_PIN));
    esp_rom_gpio_connect_out_signal(TMC_STEP_PIN, SIG_GPIO_OUT_IDX, false, false);
    gpio_set_direction(static_cast<gpio_num_t>(TMC_STEP_PIN), GPIO_MODE_OUTPUT);
    gpio_set_level(static_cast<gpio_num_t>(TMC_STEP_PIN), 0);
    pulse_ready = false;
  }
  return stopped;
}

void updateMotion(uint32_t now_ms) {
  if (!running) return;
  if (jogging && stepper_motion::leaseExpired(now_ms, jog_stop_at_ms)) {
    report(haltPulses() ? "step:stopped" : "step:fault");
  } else if (pulse_output.done()) {
    const bool was_jog = jogging;
    const bool stopped = haltPulses();
    report(stopped && !was_jog ? "step:complete" : "step:fault");
  }
}

void handleCue(const cue::Message &message, uint32_t now_ms) {
  // Observe a completion/expired lease before associating a newer command.
  updateMotion(now_ms);
  if (strcmp(message.name, "step:stop") == 0) {
    const bool was_running = running;
    const bool stopped = haltPulses();
    if (was_running && report_command_id != 0 && report_command_id != message.id) report(stopped ? "step:stopped" : "step:fault");
    report_destination = message.source;
    report_command_id = message.id;
    report(stopped ? "step:stopped" : "step:fault");
    return;
  }

  char direction[4] = {};
  unsigned steps = 0, rpm = 0;
  int consumed = 0;
  const bool is_jog = sscanf(message.name, "step:jog:%3[^:]:%u%n", direction, &rpm, &consumed) == 2
    && message.name[consumed] == '\0';
  bool valid = is_jog;
  if (!is_jog) {
    consumed = 0;
    memset(direction, 0, sizeof(direction));
    valid = sscanf(message.name, "step:%3[^:]:%u:%u%n", direction, &steps, &rpm, &consumed) == 3
      && message.name[consumed] == '\0' && steps > 0;
  }
  valid = valid && (strcmp(direction, "fwd") == 0 || strcmp(direction, "rev") == 0)
    && rpm > 0 && rpm <= 9000;
  if (!valid) { reportTo(message.source, "step:invalid", message.id); return; }
  const bool forward = strcmp(direction, "fwd") == 0;
  if (running && jogging && is_jog && direction_forward == forward && active_rpm == rpm) {
    // A heartbeat only extends the lease. Do not restart RMT or its ramp.
    jog_stop_at_ms = now_ms + stepper_motion::kJogLeaseMs;
    return;
  }

  stepper_motion::Profile prepared;
  if (!prepared.prepare(steps, static_cast<uint16_t>(rpm), is_jog)) {
    reportTo(message.source, "step:invalid", message.id);
    return;
  }
  if (running) report("step:replaced");
  const bool stopped = haltPulses();
  report_destination = message.source;
  report_command_id = message.id;
  if (!pulse_ready || !stopped) { report("step:fault"); return; }
  gpio_set_level(static_cast<gpio_num_t>(TMC_DIR_PIN), forward ? 1 : 0);
  direction_forward = forward;
  active_rpm = static_cast<uint16_t>(rpm);
  jogging = is_jog;
  jog_stop_at_ms = millis() + stepper_motion::kJogLeaseMs;
  running = true;
  if (!pulse_output.start(prepared)) {
    haltPulses();
    report("step:fault");
    return;
  }
  report("step:running");
}

}  // namespace

void setup() {
  pinMode(TMC_STEP_PIN, OUTPUT);
  pinMode(TMC_DIR_PIN, OUTPUT);
  digitalWrite(TMC_STEP_PIN, LOW);
  digitalWrite(TMC_DIR_PIN, LOW);
  Serial.begin(115200);
  pulse_ready = pulse_output.begin(TMC_STEP_PIN);
  const bool ready = transport.begin();
  if (ready) node.begin(transport.localNode(), esp_random());
  if (Serial) Serial.printf("sync stepper %012llX transport=mqtt status=%s pulse_engine=rmt-dma pulse=%uus dir_setup=%uus\n",
    static_cast<unsigned long long>(node.source()), pulse_ready && ready ? "ready" : "unavailable",
    stepper_motion::kPulseHighUs, stepper_motion::kDirSetupUs);
}

void loop() {
  updateMotion(millis());
  transport.poll(millis());
  cue::ReceivedCue received;
  while (transport.tryReceive(received)) {
    if (node.accept(received.message)) handleCue(received.message, millis());
  }
  updateMotion(millis());
  delay(1);  // RMT owns every edge; yielding no longer stretches pulses.
}
