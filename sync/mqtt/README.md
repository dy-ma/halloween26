# MQTT deployment profile

MQTT is an alternate Cue transport for the integrated show. It does not replace
or modify the ESP-NOW profile.

```text
ESP-NOW profile                         MQTT profile

fx -> USB gateway -> ESP-NOW boards    fx -> MQTT broker <- Wi-Fi boards
```

`fx` still owns show scheduling, audio, the HTTP dashboard, the eye WebSocket,
and the optional Chromium kiosk. The broker is an independently managed
service. It may run on the same Raspberry Pi or on another host.

The test show and board secrets use `mqtt.dylfi`, a router DNS record for the
broker. If it moves later, update that DNS record and reserve the new host's
address. The dashboard, flows, cue grammar, audio, and eye configuration do
not depend on broker placement. Loopback (`127.0.0.1`) is also valid for `fx`
when it shares the broker host, but never for a remote board.

## Components

- `fx` uses `mqtt-cue` as a bidirectional link and has the virtual Cue node ID
  `020000000001` in the checked-in profile.
- Each board subscribes only to `halloween/cue/<its-node-id>` and publishes its
  one-second presence heartbeat to `halloween/presence/<its-node-id>`.
- Cue v2 binary packets, application ACKs, duplicate suppression, bounded
  retries, and expiring dashboard actions are preserved over MQTT.
- MQTT socket work runs on a separate ESP32 task. Broker or Wi-Fi delays cannot
  block the motor loop, lease expiry, step pulse generation, or local stop.
- The MQTT profile does not use `sync-gateway`; that spare XIAO is still needed
  whenever the ESP-NOW profile is selected.

## Pi test deployment

The Beryl test LAN currently uses `192.168.8.133` for `dylpi`. Reserve this
address in the router's DHCP settings. The router DNS names `mqtt.dylfi`,
`fx.dylfi`, and `dylpi.dylfi` currently resolve to that address. The local,
ignored firmware secrets header points the boards at `mqtt.dylfi`.
On the show LAN, use `http://fx.dylfi:8080/control/`; over Tailscale, use
`http://100.110.38.16:8080/control/`. The Pi's eye display uses
`http://127.0.0.1:8080/?screen=tractor-eye&name=Pi-eye&client=pi-eye`.
See [orchestration](../ORCHESTRATION.md) for additional
display clients and completion-driven workflows.

The deployment root on the Pi is `/home/dyma/halloween/2026`. It contains
`fx/bin/fx`, `sync/shows/integration-mqtt.toml`, `sync/pi/`, and
`tractor-eye/dist/`. The existing audio asset and audio-device aliases stay in
the Pi user's home directory.

After copying the deployment files, configure the system broker on the Pi:

```sh
sudo sh /home/dyma/halloween/2026/sync/pi/setup-broker.sh
```

This installs Mosquitto and its CLI tools if needed, then enables its system
service with listeners on loopback and `192.168.8.133`, TCP port 1883. This is
an anonymous test broker for the show LAN. Its configuration is saved at
`/etc/mosquitto/conf.d/halloween-test.conf`.

The `fx-mqtt` user service owns the coordinator and eye kiosk. Install it as
the normal Pi desktop user:

```sh
install -Dm644 /home/dyma/halloween/2026/sync/pi/fx-mqtt.service \
  /home/dyma/.config/systemd/user/fx-mqtt.service
systemctl --user daemon-reload
systemctl --user enable --now fx-mqtt.service
```

It starts when that user's session starts (the Pi currently logs in to its
desktop automatically), survives SSH disconnects, and restarts on failure.
Inspect or restart it without sudo:

```sh
systemctl --user status fx-mqtt.service
journalctl --user -u fx-mqtt.service -n 50 --no-pager
tail -n 50 /tmp/fx-run.log
systemctl --user restart fx-mqtt.service
```

Chromium may ask to unlock the login keyring on the physical Pi display after
desktop auto-login. Enter the Pi account password there. Until the prompt is
unlocked, the broker and dashboard can be running while the eye has not
registered a live connection. Confirm `Pi-eye` has a connection in
`/api/displays`. Other browser displays register automatically; saved offline
devices can be forgotten from the dashboard.

The broker and `fx` remain separate services. To switch back to ESP-NOW, stop
`fx-mqtt` before running the ESP-NOW show so only one coordinator owns port
8080 and the eye kiosk.

## Tomorrow's bring-up

The MQTT stepper uses D9 to PUL+ and D10 to DIR+. DMA/RMT emits one continuous
hardware-timed stream, with 10 microsecond pulse HIGH, at least 10 microsecond
LOW, 20 microsecond direction setup, and LOW at EOF or cancellation. The
profile retains the 1600 pulses/revolution setting (8x microstepping with a
200-full-step motor). The piston stroke requests 60 RPM peak. A quintic
velocity-versus-time S-curve accelerates from rest for 300 pulses and
decelerates to rest for 300 pulses; 1000 pulses run at cruise. Nominal duration
is 1.375 seconds, including 0.375 seconds for each ramp. Short moves scale
the ramps to fit. Pulse timestamps are precomputed outside the ISR; the RMT
encoder only performs integer lookups and symbol packing.

Positioning requests 30 RPM, with a 0.15-second S-curve acceleration. Each
heartbeat extends the 400 ms lease without restarting the waveform or ramp.
Release/Stop and lease expiry cancel the live RMT transaction immediately;
they do not wait for a deceleration ramp. Lease checks remain in the main loop,
as before; RMT is not an independent emergency-stop watchdog. Natural EOF
reports `step:complete`; hardware errors report `step:fault`, never success.
Impossible pulse-width/rate combinations report `step:invalid` rather than
underflowing the LOW interval. Holding current and ENA wiring are unchanged.
The original ESP-NOW motion code, show speeds and timing defaults remain intact.

Host waveform tests (counts, widths, timing, symmetry, low-speed splitting,
jog cursor and lease rollover):

```sh
c++ -std=c++17 -Wall -Wextra -Werror -fsanitize=address,undefined \
  firmware/test/test_stepper_motion.cpp -o /tmp/test-stepper-motion
/tmp/test-stepper-motion
```

`sync/firmware/arduino/sync-stepper-rmt-selftest` is an isolated hardware test:
before any transmission, its STEP output is disconnected from RMT in the
GPIO matrix and held LOW, Wi-Fi is active, and there is no MQTT subscription.
It verifies natural EOF/duration,
cancel/restart and repeated jog cancellation without sending motor pulses.
Flash the production `sync-stepper-mqtt` image afterward. No self-test or
automatic motion runs when production firmware boots. Physical motor
smoothness and pin-level timing still require a real-world test/measurement;
software tests alone cannot establish the source of audible motor noise.
For rollback, build the same MQTT sketch with
`--build-property compiler.cpp.extra_flags=-DTMC_USE_RMT=0`; this selects the
previous software-timed motion path while retaining MQTT, pins and status.

Both DC controllers use the same MQTT image pinout: D9 drives R_EN and L_EN
together, D7 drives RPWM, and D8 drives LPWM. D6 is the forward limit and D5
the reverse limit. Both inputs are enabled from the first flash, plain `INPUT`
and active HIGH, using the external 10k pull-ups to 3V3 and filtered NC
contacts to GND. An open switch circuit reads asserted, including an unwired
switch with its external pull-up fitted. See
[DC limit inputs](../ORCHESTRATION.md#dc-limit-inputs).
`sync-dc-mqtt` and `sync-dc-expansion-mqtt` now share this wiring; the original
ESP-NOW images keep their old pinouts.

The same two MQTT DC images also accept bounded programmed profiles using
`dc:c:<f|r>:<peak-duty>:<final-duty>:<ramp-ms>:<hold-ms>:<fade-ms>`. Ramp and
fade use quintic smoothing and are evaluated on the controller, with a maximum
20-second motor profile. The D6/D5 limits preempt pending and active profiles
exactly as they preempt jogs and timed moves. This requires reflashing the DC
controller firmware; the dashboard and show coordinator alone cannot add the
local curve evaluator.

1. Give the Pi a stable address on the travel router (a DHCP reservation is
   fine) and note its subnet address.
2. Install Mosquitto on the broker host. For a short, isolated bench test,
   `mosquitto-bringup.conf` exposes port 1883 without credentials. Do not expose
   that configuration to an untrusted LAN or the internet.
3. Start the broker independently of `fx`:

   ```sh
   mosquitto -c sync/mqtt/mosquitto-bringup.conf -v
   ```

4. Copy `sync/firmware/include/wifi_secrets.example.h` to
   `sync/firmware/include/wifi_secrets.h`, then set the router SSID/password and
   `mqtt.dylfi` (or the broker's reserved address) as `CUE_MQTT_HOST`. The real
   file is ignored by Git.
5. Build and flash the matching `*-mqtt` images. Do not flash `sync-gateway`:

   ```sh
   arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 \
     --libraries firmware/lib sync/firmware/arduino/sync-dc-mqtt

   arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 \
     --libraries firmware/lib sync/firmware/arduino/sync-stepper-mqtt

   arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 \
     --libraries firmware/lib sync/firmware/arduino/sync-remote-mqtt
   ```

   Install the official `ArduinoMqttClient` library first when using Arduino
   CLI. PlatformIO resolves it from `platformio.ini`.
6. Run the MQTT show profile on the Pi:

   ```sh
   cargo run --manifest-path fx/Cargo.toml -- run \
     --config sync/shows/integration-mqtt.toml
   ```

7. Before motor power is connected, confirm the three boards appear online in
   `/control/`, then issue stop and motion commands and watch for MQTT delivery
   reports in the `fx` log. Apply motor power to one controller at a time.

The virtual `fx` node ID must match in three places: the MQTT show's
`links.radio.node`, the MQTT remote's `CUE_COORDINATOR_NODE`, and any future
board that sends unsolicited events to `fx`.

## Broker separation and security

Mosquitto should eventually run under its own service manager with persistence,
authentication, and firewall rules. `fx` intentionally does not start or stop
it. The show format supports `username` plus `password_env` on an `mqtt-cue`
link so the password stays out of TOML. Board credentials live only in the
ignored `wifi_secrets.h` file.

If the broker moves to another machine, its firewall must allow TCP 1883 from
both the Pi and the board subnet. Keep the control dashboard and eye WebSocket
deployment decisions separate from that broker placement.
