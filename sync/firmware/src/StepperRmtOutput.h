#pragma once

#include <driver/gpio.h>
#include <driver/rmt_tx.h>
#include <esp_attr.h>
#include <esp_timer.h>
#include <freertos/FreeRTOS.h>
#include <freertos/portmacro.h>

#define STEPPER_ISR_ATTR IRAM_ATTR
#include "StepperMotion.h"
#undef STEPPER_ISR_ATTR

// One continuous DMA/RMT transaction per move, including jog acceleration.
// The network/main loop never emits edges or restarts a jog heartbeat.
class StepperRmtOutput {
 public:
  bool begin(int gpio) {
    rmt_tx_channel_config_t channel_config = {};
    channel_config.gpio_num = static_cast<gpio_num_t>(gpio);
    channel_config.clk_src = RMT_CLK_SRC_DEFAULT;
    channel_config.resolution_hz = 1000000;
    channel_config.mem_block_symbols = 256;
    channel_config.trans_queue_depth = 1;
    channel_config.intr_priority = 3;
    channel_config.flags.with_dma = true;
    if (rmt_new_tx_channel(&channel_config, &channel_) != ESP_OK) return false;

    rmt_simple_encoder_config_t encoder_config = {};
    encoder_config.callback = encode;
    encoder_config.arg = &waveform_;
    encoder_config.min_chunk_size = 1;
    if (rmt_new_simple_encoder(&encoder_config, &encoder_) != ESP_OK) return false;
    rmt_tx_event_callbacks_t callbacks = {};
    callbacks.on_trans_done = finished;
    if (rmt_tx_register_event_callbacks(channel_, &callbacks, this) != ESP_OK) return false;
    ready_ = true;
    return true;
  }

  bool start(const stepper_motion::Profile &profile) {
    if (!ready_ || !stop()) return false;
    waveform_.reset(profile);
    portENTER_CRITICAL(&completion_mux_);
    done_ = false;
    symbol_count_ = 0;
    portEXIT_CRITICAL(&completion_mux_);
    if (rmt_encoder_reset(encoder_) != ESP_OK) return false;
    if (rmt_enable(channel_) != ESP_OK) return false;
    enabled_ = true;
    rmt_transmit_config_t config = {};
    config.flags.eot_level = 0;  // stop, cancellation and EOF all leave PUL LOW
    config.flags.queue_nonblocking = 1;
    portENTER_CRITICAL(&completion_mux_);
    started_at_us_ = static_cast<uint32_t>(esp_timer_get_time());
    elapsed_us_ = 0;
    portEXIT_CRITICAL(&completion_mux_);
    if (rmt_transmit(channel_, encoder_, &waveform_, sizeof(waveform_), &config) != ESP_OK) {
      stop();
      return false;
    }
    return true;
  }

  bool stop() {
    // rmt_disable cancels the live transaction, not just future submissions.
    // Never change the payload/cursor until the peripheral has been stopped.
    if (enabled_) {
      if (rmt_disable(channel_) != ESP_OK) {
        ready_ = false;
        return false;
      }
      enabled_ = false;
    }
    portENTER_CRITICAL(&completion_mux_);
    done_ = false;
    portEXIT_CRITICAL(&completion_mux_);
    return true;
  }

  bool done() {
    portENTER_CRITICAL(&completion_mux_);
    const bool value = done_;
    portEXIT_CRITICAL(&completion_mux_);
    return value;
  }
  uint32_t symbolsSent() {
    portENTER_CRITICAL(&completion_mux_);
    const uint32_t value = symbol_count_;
    portEXIT_CRITICAL(&completion_mux_);
    return value;
  }
  uint32_t elapsedMicros() {
    portENTER_CRITICAL(&completion_mux_);
    const uint32_t value = elapsed_us_;
    portEXIT_CRITICAL(&completion_mux_);
    return value;
  }

 private:
  static size_t IRAM_ATTR encode(const void *, size_t, size_t, size_t available,
                                  rmt_symbol_word_t *out, bool *done, void *arg) {
    auto &waveform = *static_cast<stepper_motion::Waveform *>(arg);
    size_t count = 0;
    *done = false;
    while (count < available) {
      stepper_motion::Symbol symbol;
      if (!waveform.next(symbol)) { *done = true; break; }
      out[count].val = 0;
      out[count].duration0 = symbol.duration0;
      out[count].level0 = symbol.level0;
      out[count].duration1 = symbol.duration1;
      out[count].level1 = symbol.level1;
      ++count;
    }
    return count;
  }

  static bool IRAM_ATTR finished(rmt_channel_handle_t, const rmt_tx_done_event_data_t *event, void *arg) {
    auto &self = *static_cast<StepperRmtOutput *>(arg);
    portENTER_CRITICAL_ISR(&self.completion_mux_);
    self.elapsed_us_ = static_cast<uint32_t>(esp_timer_get_time()) - self.started_at_us_;
    self.symbol_count_ = event->num_symbols;
    self.done_ = true;
    portEXIT_CRITICAL_ISR(&self.completion_mux_);
    return false;
  }

  rmt_channel_handle_t channel_ = nullptr;
  rmt_encoder_handle_t encoder_ = nullptr;
  stepper_motion::Waveform waveform_;
  // Use IDF's ISR-safe SMP critical section; this toolchain's C++ atomics
  // are not guaranteed lock-free. Hold it only for the two completion fields.
  portMUX_TYPE completion_mux_ = portMUX_INITIALIZER_UNLOCKED;
  bool done_ = false;
  uint32_t symbol_count_ = 0;
  uint32_t started_at_us_ = 0;
  uint32_t elapsed_us_ = 0;
  bool enabled_ = false;
  bool ready_ = false;
};
