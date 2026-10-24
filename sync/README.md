# Integrated show control

This directory combines the proven ESP-NOW Cue transport, BTS7960 output logic,
TMC step generation, Pi show runner, and eye UI into one integration-testable
system. The original sketches remain unchanged for isolated hardware testing.

Future work and field observations are tracked in [BACKLOG.md](BACKLOG.md).

## Roles

- `sync-gateway`: XIAO ESP32-S3 connected to the Raspberry Pi by USB. It routes
  newline-delimited JSON to explicit ESP-NOW destinations and returns delivery
  results plus incoming board events.
- `sync-remote`: battery/remote XIAO. Its start button sends `show:start` and an
  optional second button sends `show:stop` to the configured gateway node.
- `sync-horn-mqtt`: single-switch XIAO for the physical horn. A debounced press
  on D6 sends `horn:pushed` to the Pi. Wire a normally-open switch between D6
  and GND; the firmware uses `INPUT_PULLUP` and triggers on the falling edge.
- `sync-dc`: flash the same image onto both BTS7960 controller boards. Their MAC
  addresses distinguish `dc_a` from `dc_b` in the show file.
- `sync-dc-expansion`: wireless-only DC firmware for the six-wire BTS7960
  harness. It uses D10 (blue/R_EN), D9 (yellow/L_EN), D8 (white/RPWM), and D7
  (green/LPWM). Black connects GND and red connects the XIAO `3V3` pin, matching
  the verified module wiring. Expansion Base peripherals, when present, are
  ignored.
- `sync-stepper`: TMC controller with non-blocking trapezoidal step generation.
- `fx`: Raspberry Pi coordinator. It owns the serial gateway, schedules show
  nodes, serves the eye, and serves `/control/`.

The wireless XIAO stepper wiring uses four adjacent header pins: `GND` to TMC
ground, `3V3` to TMC logic `VIO`, `D10` to `DIR`, and `D9` to `STEP`. Motor
power remains on the TMC module's separate `VM`/`VMOT` barrel-jack supply.

All ESP32 roles use ESP-NOW channel 1 with long-range mode and acknowledged,
deduplicated unicast from `firmware/lib`.

## Optional MQTT/Wi-Fi profile

The same dashboard, show scheduler, cue grammar, motor logic, audio, and eye
server can now use an `mqtt-cue` link over ordinary Wi-Fi. The existing
ESP-NOW images and `integration-hardware.toml` remain unchanged. The alternate
profile is `integration-mqtt.toml`, with matching `*-mqtt` board images.

In this profile, `fx` talks directly to an MQTT broker and the USB
`sync-gateway` board is not used. The checked-in deployment points `fx` at a
broker on the same Pi through `mqtt.dylfi`, but the broker hostname is ordinary
show configuration and can point to another machine later. `fx` remains the
audio, dashboard, WebSocket, eye, and show-coordination process either way; it
does not own or supervise the broker.

See [`mqtt/README.md`](mqtt/README.md) for the topology, credential file,
Mosquitto bring-up, MQTT firmware builds, and tomorrow's hardware checklist.

## Automatic board discovery

For independently addressable browser displays, correlated assembly status,
and dependency-based workflows, see [ORCHESTRATION.md](ORCHESTRATION.md).

Every board broadcasts a HELLO packet about once per second containing its
service role and hardware-derived 12-digit node ID. The USB gateway forwards a
fresh peer snapshot to the Pi once per second, including its own `gateway`
entry. The control page polls `/api/boards` and shows the service, node ID,
connection, RSSI, and whether the board has been heard in the last 3.5 seconds.
A disconnected board stays in the table as `Offline`, so a power or radio loss
is visible instead of silently removing the row.

Discovery identifies what is powered and reachable. Show commands still use
the explicit node IDs in the hardware show file, so two identical DC boards
cannot accidentally swap roles when they boot in a different order.

## Motion behavior

There is no firmware arming flag, test-only build, or motor-enable guard. Once
flashed, the DC and stepper outputs accept serial, dashboard, and show cues
immediately. DC duty accepts the driver's full 1–255 command range, and timed
moves accept the duration encoded in the cue.

DC jog cues are leases, not latched motor commands. The browser repeats a jog
cue every 100 ms and each accepted cue grants only 400 ms of motion. Releasing
the button sends `dc:stop`; loss of the browser, Pi, USB gateway, or radio lets
the lease expire locally. Direction changes stop for 500 ms before applying
reverse power.

Stepper commands contain a direction, step count, and RPM. Step pulses are
generated without blocking the ESP-NOW polling loop. `step:stop` stops
immediately.

These controls complement rather than replace limit switches, fuses, guards,
and a physical motor-power disconnect.

## Simulation without boards

Build the browser bundle, then run the simulator show:

```sh
npm --prefix tractor-eye run build
cargo run --manifest-path fx/Cargo.toml -- run \
  --config sync/shows/integration-sim.toml --no-kiosk
```

Open `http://127.0.0.1:8080/control/`. Every button runs through the same show
scheduler used on the Pi. Simulated radio deliveries appear in the terminal and
`/tmp/fx-run.log`. Open `http://127.0.0.1:8080/` in another window to watch the
eye respond to the integration and stop flows. The Boards table contains the
three simulated motor services, using their configured destination IDs.

The DC forward and reverse bench controls are hold-to-run. Each controller
ramps from zero to the selected PWM over 350 ms, keeps the ramp running across the
100 ms command heartbeats, and stops immediately on release or lease expiry.
Timed show cues retain their explicitly configured PWM value and start without
the bench ramp. The dashboard binds DC A forward/reverse to `W`/`S` and DC B
forward/reverse to `ArrowUp`/`ArrowDown`, so one key from each pair can be held
to run both motors simultaneously. Opposing directions for one motor are
mutually exclusive, and focus loss releases every active hold. `Space` sends
one 1,600-microstep piston stroke. The unbound clockwise and counter-clockwise
stepper buttons are hold-to-position controls at 30 RPM. The MQTT stepper
uses hardware-timed DMA/RMT pulses and an S-curve for finite strokes; its
60 RPM piston stroke nominally takes 1.375 seconds including both ramps.
The original ESP-NOW motion implementation remains unchanged.

DC panels expose the existing firmware's 1–255 PWM drive range through a slider
and 25/50/75/100% presets, shared by forward and reverse for that motor.
Changing the setting alone never starts motion; active jog heartbeats use the
latest setting and the board ramps to the new target over 350 ms. Settings are
local to the open dashboard page and reset to the show file's configured duty
on reload. Timed show cues are unchanged. PWM is an open-loop drive level, not
a measured speed or torque setting. Low drive may not overcome the load.

`GET /api/control` advertises a nullable `pwm` default only for adjustable DC
jogs. `POST /api/control` optionally accepts `pwm: 1..255` on their `press`
phase; `release` remains parameter-free and sends the original stop cue.
The server rejects PWM on timed moves, displays, steppers and other controls;
clients cannot provide arbitrary cue text or change a configured control's
target.

The dashboard's **Motion timing tuner** is a separate, bounded programmed
mode. It ramps from zero to a peak, holds, then follows a quintic smooth fade
to a final PWM before stopping. Peak/final PWM, ramp, hold, fade, direction,
audio track/output, and the motor's offset from audio start can be adjusted;
the draft is saved in that browser. Field changes never move the motor. A run
is submitted as structured parameters, and `fx` will only route it to a DC sink
already represented by an adjustable jog control. It does not accept arbitrary
cue text from the browser. The controller evaluates the curve locally at motor
loop speed, so network jitter cannot turn the profile into discrete PWM jumps.

Use **Play** with the **Audio**, **DC motor**, **Stepper**, and **Eye** checkboxes to apply any
combination, and **Stop all** at any point. Unchecking a component does not
change its saved settings or the other components' offsets. Motor and wake
delays are relative to Play even when Audio is unchecked. Unchecked graph
components are faded for reference. The graph's playhead is a UI preview; the
board is authoritative. Both limit inputs are checked before motion and every
loop during motion. A limit immediately turns outputs off and reports
`dc:limit:fwd` or `dc:limit:rev`. Final PWM is open-loop and must be calibrated
under the real load: a value below the motion threshold can stall and heat a
motor. Once tuned, the compact cue printed below the graph can be placed in a
show node's `cue.emit`.

The Stepper controls select an existing finite stroke, peak speed (10–120 RPM),
and delay (0–10,000 ms from Play). The runtime reuses the configured stroke's
direction, pulse count, board, link, and delivery lifetime; the dashboard cannot
substitute arbitrary cue text or a different destination. The Stepper checkbox
starts unchecked and is saved with the other browser preferences. Stepper-only
trials do not dispatch DC, eye, or audio actions. All four components are planned
in one runtime workflow, and Stop all cancels delayed strokes before dispatch.

The separate amber RPM lane previews the MQTT firmware's existing quintic
S-curve. It uses 1,600 pulses/revolution, integer pulse periods, a maximum of 300
ramp pulses per end, and 20 µs DIR setup, matching `StepperMotion.h`. A 1,600-pulse
stroke at 60 RPM takes approximately 1.375 s including both ramps. Changing RPM
changes the estimated finish time; delay shifts the whole stroke. This is a
timing estimate, not position or completion feedback. Ramp shape/duration remain
firmware-managed and cannot be edited here. Legacy transports show a constant-
speed estimate labelled as potentially different instead of claiming MQTT ramp
timings. Existing ESP-NOW firmware and stroke controls are unchanged.

The tuner also has an optional **Eye display** selector and **Eye wake delay**
(0–10,000 ms from audio start). Choose a currently connected saved display and
check **Eye** to include it in the same runtime run.
The graph overlays Wake, Tip look, and Look settled markers; the legend also
shows when opening begins. Wake is one command: opening starts at +180 ms,
the tipping look starts at +4,000 ms and settles at +6,400 ms. These are planned
animation milestones, not device completion feedback. The marker timings share
constants with the actual animation. Only the overall wake offset is editable;
the animation's internal sections remain unchanged. The eye stays awake after
settling, with its normal idle movements.

Eye selection is optional and saved alongside the existing browser draft
without changing its motor settings. It uses the persistent browser device ID,
so reconnecting does not require choosing a new connection. All current tabs of
that saved device receive a private Wake; unrelated displays do not. An offline
selection rejects a run that includes Eye before anything is scheduled; uncheck
Eye to test other components independently. **Stop all** cancels any pending wake along
with pending motor/audio actions; the existing show stop/reset controls handle
the eye's already-running animation. Each Wake restarts the sequence from a
closed pose, so a manual Reset is not required between timing trials.

For isolated verification without motors, run `fx run --config
sync/shows/dc-pwm-smoke.toml --no-kiosk --log-file /tmp/fx-dc-pwm-smoke.log`
and open `http://127.0.0.1:18081/control/`. This fixture has only a simulated
link: it cannot send MQTT/serial traffic or play audio.

Bench controls are grouped by device. Panel status reports motor-board
discovery, eye-browser connection and current eye mode, speaker availability
and volume, and locally active hold controls. A control response means the Pi
accepted and scheduled the action; motor boards do not currently return
physical position or load feedback to the dashboard. ESP-NOW delivery results
remain available in the `fx` log.

Displays and Audio devices now have dedicated sections. Discovered audio
outputs and paired Bluetooth speakers each get a track picker, readiness,
volume, and per-voice Stop controls. The show's `speaker` sink still selects
the `jbl` alias from `~/.config/fx/device-aliases`; configured sinks and source
track IDs remain independent. See [AUDIO.md](AUDIO.md) for the track catalog,
concurrent routing/layering, Bluetooth connection controls, and DAG examples.

In addition to the motor bindings, `E` wakes the eye and `A` plays the full
audio file.

The HTTP API is also scriptable:

```sh
curl -X POST http://127.0.0.1:8080/api/control \
  -H 'content-type: application/json' \
  -d '{"control":"run_integration","phase":"press"}'
```

`127.0.0.1` always means the machine where the browser is running. Use it only
when `fx` is also running on that same machine, such as the laptop simulator.
Both integration show files listen on `0.0.0.0:8080`, so when `fx` runs on the
Pi the dashboard is available to other devices on the same LAN. On the Pi, run:

```sh
hostname -I
```

Then open `http://PI_ADDRESS:8080/control/` on the laptop, replacing
`PI_ADDRESS` with the Pi's LAN address. `http://raspberrypi.local:8080/control/`
also works when the Pi hostname and mDNS service use the default name.

## Board bring-up order

1. Install PlatformIO and build all four environments before connecting motors:

   ```sh
   pio run -d sync/firmware -e sync-gateway
   pio run -d sync/firmware -e sync-remote
   pio run -d sync/firmware -e sync-dc
   pio run -d sync/firmware -e sync-dc-expansion
   pio run -d sync/firmware -e sync-stepper
   ```

   The parallel MQTT images are `sync-remote-mqtt`, `sync-horn-mqtt`,
   `sync-dc-mqtt`, `sync-dc-expansion-mqtt`, and `sync-stepper-mqtt`. They are
   additions, not replacements for the ESP-NOW environments.

   Arduino CLI wrappers are also included and are what the repository build was
   verified with. For example, flash the Pi gateway with:

   ```sh
   arduino-cli compile --upload -p /dev/cu.usbmodemBOARD \
     --fqbn esp32:esp32:XIAO_ESP32S3 \
     --libraries firmware/lib \
     sync/firmware/arduino/sync-gateway
   ```

2. Replace the older Pi SuperMini with a blank XIAO ESP32-S3. Flash
   `sync-gateway`, open its 115200-baud serial monitor, and record the 12-digit
   node ID printed after `sync gateway`.
3. Flash both DC boards and the stepper board. Record each printed node ID and
   place them in `integration-hardware.toml` as `dc_a`, `dc_b`, and `stepper`.
4. The remote build is configured for gateway node `9070690BD848`. If the Pi
   gateway board is ever replaced, update `CUE_GATEWAY_NODE` in both build
   wrappers before flashing the remote.
5. With motor power still disconnected, run the hardware show and verify that
   each control produces a `delivered` report to the intended destination.
6. Apply motor power to one controller at a time. Verify stop, lease expiry,
   direction reversal, and bounded moves before running the integration flow.

Run the hardware coordinator on the Pi with:

```sh
cargo run --manifest-path fx/Cargo.toml -- run \
  --config sync/shows/integration-hardware.toml
```

Hardware mode launches the eye page full-screen on the Pi display and serves
the control dashboard at the same time. Pass `--no-kiosk` only when deliberately
running the hardware coordinator without the attached eye display.

## Future dashboard lifecycle controls

Add a persistent Pi supervisor so the web app can show `starting`, `running`,
`stopping`, `stopped`, and `failed` runtime states and provide Start, Stop, and
Restart actions. Keep host-level Reboot and Shutdown separate from runtime
controls, require an explicit confirmation, and show connection loss as the
expected result. The supervisor must own both `fx` and its managed eye kiosk so
stopping the runtime cannot leave Chromium orphaned.

The serial gateway accepts commands shaped as:

```json
{"type":"emit","request":42,"destination":"AABBCCDDEEFF","event":"dc:stop"}
```

All four firmware roles check whether USB CDC has a connected host before
printing. They never wait for Serial, and disconnected debug output is skipped,
so powering a controller from USB-C without an open serial monitor cannot add a
multi-second pause to its radio or motion loop.

It accepts `{"type":"status"}` for a node/peer summary and emits incoming
radio cues, queue results, ACK latency, attempt count, and RSSI as JSON lines.
Its periodic discovery output looks like:

```json
{"type":"peer","node":"AABBCCDDEEFF","service":"dc-motor","transport":"esp-now","rssi":-61}
```

## Cue grammar

`fwd` and `rev` are electrical DIR levels, not universal physical rotation
names. The installed mechanism has been calibrated as `fwd` = clockwise and
`rev` = counter-clockwise; changing motor phases or viewing the shaft from the
opposite side reverses that physical interpretation. Always verify with a
short, unloaded positioning jog before enabling a full stroke.

| Controller | Cue | Behavior |
| --- | --- | --- |
| DC | `dc:jog:fwd:70` | Forward duty 70 while the 400 ms lease is refreshed |
| DC | `dc:jog:rev:70` | Reverse duty 70 while the lease is refreshed |
| DC | `dc:fwd:70:500` | Forward duty 70 for 500 ms |
| DC | `dc:c:f:217:51:300:700:2200` | Smooth forward curve: peak/final duty, ramp, hold, fade |
| DC | `dc:rev:70:500` | Reverse duty 70 for 500 ms |
| DC | `dc:stop` | Immediate local stop |
| Stepper | `step:fwd:1600:60` | 1,600 microsteps forward at up to 60 RPM |
| Stepper | `step:rev:1600:60` | 1,600 microsteps reverse at up to 60 RPM |
| Stepper | `step:jog:fwd:30` | Forward at 30 RPM while the 400 ms lease is refreshed |
| Stepper | `step:jog:rev:30` | Reverse at 30 RPM while the lease is refreshed |
| Stepper | `step:stop` | Immediate local stop |

