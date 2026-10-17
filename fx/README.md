# FX audio

`fx-audio` provides one primitive: **play an audio file on an audio device**.
It also exposes device enumeration and the Bluetooth controls needed to make
Bluetooth audio devices available. The accompanying `fx` CLI is a thin testing
surface over those bindings.

Sequences, serial triggers, screen commands, and show configuration live above
this library. `fx sequence` demonstrates composition without putting an
orchestration model into the audio layer.

## Library API

```rust
use fx_audio::{AudioSystem, DeviceSelector, PipeWire, PlaybackRequest};

let audio = PipeWire::default();

for device in audio.devices()? {
    println!("{}", device.id);
}

audio.play(&PlaybackRequest::new(
    "/home/dyma/audio/tractor_tipping_0015-0026.wav",
    DeviceSelector::Default,
))?;
```

`AudioSystem` is the backend boundary:

```rust
pub trait AudioSystem {
    fn devices(&self) -> Result<Vec<AudioDevice>>;
    fn play(&self, request: &PlaybackRequest) -> Result<()>;
}
```

The current implementation delegates to `wpctl` and `pw-play`, which are
already working on the Pi. A native PipeWire implementation can replace it
later without changing callers.

## Build and test

```sh
cargo test --manifest-path fx/Cargo.toml
cargo build --release --manifest-path fx/Cargo.toml
```

The CLI expects Linux with `bluetoothctl`, `wpctl`, and `pw-play` installed.
The library's parsing tests work on other platforms.

## CLI testing loop

```sh
fx outputs list
fx play /home/dyma/audio/tractor_tipping_0015-0026.wav
fx play sound.wav --device bluez_output.74_68_59_F0_F2_F4.1
fx sequence first.wav second.wav --device bluez_output.74_68_59_F0_F2_F4.1
```

Read or change the PipeWire sink volume without remembering `wpctl` syntax:

```sh
fx volume get
fx volume set 80
fx volume up 5
fx volume down 5
fx volume mute
fx volume unmute
fx volume toggle
fx volume set 70 --device jbl
```

Percentages are limited to 0–100. Omitting `--device` controls the current
default output; aliases and stable IDs use the same resolution as `fx play`.

The device identifier is the stable PipeWire node name printed by
`fx outputs list`. Omitting `--device` uses the current default.

Assign a short, persistent alias to a stable PipeWire device ID:

```sh
fx outputs alias jbl bluez_output.74_68_59_F0_F2_F4.1
fx outputs aliases
fx play ~/audio/tractor_tipping_0015-0026.wav --device jbl
```

Aliases are CLI configuration stored in `~/.config/fx/device-aliases`; they are
resolved before the library receives a playback request. This keeps the core
primitive independent of naming and show configuration.

## Shell completion

The file arguments are annotated as paths. Generate and load the Bash
completion definition to enable subcommand, option, and path completion:

```sh
mkdir -p ~/.local/share/bash-completion/completions
fx completions bash > ~/.local/share/bash-completion/completions/fx
source ~/.local/share/bash-completion/completions/fx
```

## Bluetooth

```sh
fx bluetooth devices --filter paired
fx bluetooth scan --seconds 10
fx bluetooth pair 74:68:59:F0:F2:F4
fx bluetooth trust 74:68:59:F0:F2:F4
fx bluetooth connect 74:68:59:F0:F2:F4
fx bluetooth info 74:68:59:F0:F2:F4
```

The speaker must be put into pairing mode before scanning or pairing. The Pi
does not need to be discoverable when it is acting as the controller.

## Serial input

List or monitor a USB serial device:

```sh
fx serial list
fx serial monitor
```

When exactly one device exists under `/dev/serial/by-id`, it is selected
automatically. To wait for one JSON event, play once, and exit:

```sh
fx serial play-once tractor_tipped \
  ~/audio/tractor_tipping_0015-0026.wav \
  --device jbl
```

The expected input is one JSON object per line with an `event` string and an
optional numeric `sequence`.

For continuous overlapping playback, map one or more events to files:

```sh
fx serial mux --device jbl \
  --map 'horn:pushed=/home/dyma/audio/horn.wav' \
  --map 'tractor:tipped=/home/dyma/audio/tractor.wav' \
  --map 'tractor:moo=/home/dyma/audio/moo.wav' \
  --map 'tractor:fart=/home/dyma/audio/fart.wav'
```

Each unique `(source, event, sequence)` starts a separate `pw-play` stream. PipeWire
mixes those streams on the selected output. Exact retransmissions are discarded;
the same event with a new sequence may overlap its own earlier playback. Use
`--max-active` to cap simultaneous streams and `--max-events` for finite tests.

## Show configurations

For repeatable testing, register links, sources, assets, and sinks in one TOML
show manifest. Flows map an incoming Cue to independently scheduled nodes:

```toml
version = 2
name = "tractor-test"

[links.radio]
type = "serial-cue"
baud = 115200

[sources.radio]
type = "cue-link"
link = "radio"

[playback]
max_active = 16
dedupe_capacity = 4096

[assets.tractor]
type = "audio"
file = "/home/dyma/audio/tractor.wav"

[assets.impact]
type = "audio"
file = "/home/dyma/audio/impact.wav"

[assets.moo]
type = "audio"
file = "/home/dyma/audio/moo.wav"

[sinks.front]
type = "audio"
device = "jbl-usb"
volume = 0.70

[sinks.rear]
type = "audio"
device = "rear-speaker"
volume = 0.55

[sinks.eye]
type = "screen"
screen_id = "tractor-eye"
initial_state = { mode = "sleeping", gaze = { x = 0.0, y = 0.0 } }

[sinks.tip_motor]
type = "cue"
link = "radio"
namespace = "tractor:stepper"

[flows.tip]
trigger = { source = "radio", cue = "tractor:tipped" }

[[flows.tip.nodes]]
id = "tractor-sound"
action = { type = "audio.play", sink = "front", asset = "tractor" }

[[flows.tip.nodes]]
id = "impact"
action = { type = "audio.play", sink = "front", asset = "impact", volume = 0.85 }

[[flows.tip.nodes]]
id = "moo"
at_ms = 250
action = { type = "audio.play", sink = "rear", asset = "moo" }

[[flows.tip.nodes]]
id = "wake-eye"
at_ms = 3000
action = { type = "screen.command", sink = "eye", command = { type = "eye/wake" }, final_state = { mode = "tipping", gaze = { x = -0.25, y = -0.65 } } }

[[flows.tip.nodes]]
id = "motor-stroke"
at_ms = 8500
action = { type = "cue.emit", sink = "tip_motor", cue = "stroke", expires_after_ms = 500 }

[flows.reset]
trigger = { source = "radio", cue = "show:reset" }

[[flows.reset.nodes]]
id = "reset-eye"
action = { type = "screen.command", sink = "eye", command = { type = "system/reset" }, final_state = { mode = "sleeping", gaze = { x = 0.0, y = 0.0 } } }

[server]
bind = "127.0.0.1:8080"
static_dir = "/home/dyma/tractor-eye/dist"
screen_id = "tractor-eye"

[kiosk]
enabled = true
url = "http://127.0.0.1:8080/"
# browser = "chromium"
# log_file = "/tmp/fx-kiosk.log"
# pid_file = "/tmp/fx-kiosk.pid"

```

Every node in a matching flow starts independently at `at_ms` relative to its
trigger. The example mixes two sounds on `front`, sends a delayed sound to
`rear`, wakes the eye, and finally broadcasts `tractor:stepper:stroke`. Cue
emission is bounded and expires rather than replaying stale motion after a link
reconnect. Repeating the trigger with a new Cue ID starts another flow instance;
exact retransmissions remain deduplicated. Eye state returns only in response to
the separate `show:reset` flow.

When `[server]` is present, `fx run` also serves the built eye app, runtime
configuration, health endpoint, and WebSocket from one loopback origin:

```text
http://127.0.0.1:8080/
http://127.0.0.1:8080/config.json
http://127.0.0.1:8080/healthz
ws://127.0.0.1:8080/ws
```

`fx run` is the sole serial-port owner. Each registered `serial-cue` link is
bidirectional: received Cue JSON enters matching flows, while `cue.emit` nodes
send bounded newline JSON commands back to the gateway. Audio starts
independently of browser connection state, so a missing or reconnecting eye
display does not block sound. Conversely, the WebSocket and eye state can be
tested with an eye-only manifest containing no audio actions. Each serial link
reconnects to the same stable port after an unplug/replug.

Check a show, select it as the default, and run it:

```sh
fx show check ~/shows/tractor-test.toml
fx show enable ~/shows/tractor-test.toml
fx show current
fx run
```

When `kiosk.enabled = true`, `fx run` waits for the eye server and launches
Chromium automatically. `fx` stays in the foreground with the serial, cue, and
playback logs while also appending them to `/tmp/fx-run.log`. Chromium
stdout/stderr is appended separately to `/tmp/fx-kiosk.log`. Stopping `fx run`
also stops the Chromium instance it launched. Use `--log-file PATH` to put the
runtime log elsewhere, or follow it from another shell with:

```sh
tail -f /tmp/fx-run.log
```

`show enable` stores the selected configuration path in
`~/.config/fx/active-show`; it does not start a process. Pass a file directly
for a one-off run without changing the enabled show. The long option is
recommended, while the positional form remains compatible:

```sh
fx run --config ~/shows/another-test.toml
fx run ~/shows/another-test.toml
```

Override kiosk startup when debugging:

```sh
fx run --config ~/shows/tractor-test.toml --no-kiosk
fx run --config ~/shows/tractor-test.toml --kiosk
```

The kiosk can also be managed independently, using the enabled show by default:

```sh
fx kiosk status
fx kiosk start
fx kiosk restart
fx kiosk stop
fx kiosk start --config ~/shows/tractor-test.toml
```

These standalone controls intentionally refuse to stop or restart a kiosk owned
by a running unified `fx run`. Use `fx run --no-kiosk` when you want to operate
the kiosk as a separate process.

The repository includes Bluetooth and USB variants in `shows/`. Both include
the tractor-eye Wake route and expect its production build at
`/home/dyma/tractor-eye/dist`. A future boot service can call `fx run` and use
the same enabled configuration.

### Cue button nodes

The active board firmware now lives in [`../firmware`](../firmware/README.md).
The button node sends three ESP-NOW copies with the same Cue ID; the Pi gateway
deduplicates them and writes one event to serial. There is no broadcast ACK or
delivery wait. The older `transceiver/transceiver.ino` is retained only as the
bring-up prototype.

Received serial events still include packet RSSI so range and antenna
placement can be measured rather than guessed:

```json
{"event":"tractor:tipped","sequence":123,"source":"AABBCCDDEEFF","rssi":-67}
```

With the gateway attached to the Pi, prove the radio path before adding audio:

```sh
fx serial monitor
```

Press BOOT on the other board. Its LED should pulse and the Pi should print one
JSON event. Then start the audio mapping:

```sh
fx serial mux --device jbl-usb \
  --map 'tractor:tipped=/home/dyma/audio/tractor_tipping_0015-0026.wav'
```

## Composition

[`examples/play_sequence.rs`](examples/play_sequence.rs) implements an ordered
sequence by calling `play` twice. Show manifests provide the higher-level Cue
orchestration: named flows currently schedule independent nodes relative to a
trigger. Node IDs leave room for explicit dependencies and completion edges
later without changing the audio, serial, or WebSocket contracts.
