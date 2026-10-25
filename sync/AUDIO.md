# Audio devices and source tracks

FX on the Pi is the audio host. The dashboard's Audio devices section lists
actual PipeWire outputs, paired Bluetooth speakers (including disconnected
ones), and configured show-output aliases. Display clients stay independent.
The Pi's existing `tractor_tip` asset is PCM WAV, 48 kHz, stereo, 16-bit, 9.54 s.

Each ready output has a track picker, Play, output volume, and a list of active
voices with individual Stop controls. Each Play adds a new voice; it does not
replace another track. Different files can play on different speakers, and
multiple files can mix on the same speaker. `playback.max_active` caps all
dashboard and show voices together. Finished/stopped/failed history is bounded
to 128 voices (active voices are never evicted).

Paired Bluetooth audio speakers have Connect/Disconnect controls. Pairing a
new speaker still uses the Pi's Bluetooth tools; scanning/pairing UI is not part
of this change. Paired, connected, and ready-for-audio are separate states.
Ready means the host exposes an audio sink, not microphone-confirmed sound.
Bluetooth identities use the address, not a transient PipeWire numeric index.
Configured aliases and discovery merge into one physical-output card.

Playback always selects a concrete sink. It never intentionally uses the
system default as a fallback when the selected speaker is missing. Streams set
`node.dont-fallback`, `node.dont-reconnect`, and disable lingering; see the
[WirePlumber linking policy](https://pipewire.pages.freedesktop.org/wireplumber/policies/linking.html).
Host commands and discovery run asynchronously with deadlines so a Bluetooth
operation cannot block the coordinator's control loop.
Loss or replacement of a selected output fails its active voices rather than
leaving a dependency waiting indefinitely. STOP ALL also invalidates starts
still waiting on discovery, so an old request cannot start sound afterward.

## Immediate interaction sounds

Use `audio.trigger` for a short sound that must react to a physical input. FX
decodes those WAV assets at startup and maintains one 48 kHz stereo PipeWire
stream for every referenced output. The stream continuously supplies silence,
which keeps the Bluetooth audio path active; a trigger mixes the predecoded
samples into that stream without starting a process or opening a file. The
default requested PipeWire latency is 20 ms and can be changed with
`playback.resident_latency_ms` in the bounded 5–100 ms range. A Bluetooth sink
may impose a larger codec/radio buffer than PipeWire requests.

Resident clips must be 16-bit PCM WAV, mono or stereo. They are converted to
48 kHz stereo at startup. Normal `audio.play` voices—including dashboard
ambient loops—remain separate PipeWire streams and mix with the resident
channel. The always-open silent stream keeps the transport awake; actual
background audio may additionally prevent a speaker's own silence gate or
amplifier sleep from engaging.

The production horn uses a named resident hold. Press starts it, held packets
renew a 1.2-second safety lease, and release stops it. If the switch board or
network disappears, the lease stops the sound instead of leaving it on:

```toml
[flows.horn_audio]
trigger = { source = "remote", cue = "horn:pushed" }

[[flows.horn_audio.nodes]]
id = "horn"
action = { type = "audio.hold.start", key = "horn", sink = "speaker", asset = "horn", lease_ms = 1200 }

[flows.horn_held]
trigger = { source = "remote", cue = "horn:held" }

[[flows.horn_held.nodes]]
id = "horn"
action = { type = "audio.hold.start", key = "horn", sink = "speaker", asset = "horn", lease_ms = 1200 }

[flows.horn_released]
trigger = { source = "remote", cue = "horn:released" }

[[flows.horn_released.nodes]]
id = "horn"
action = { type = "audio.hold.stop", key = "horn" }

[flows.show]
trigger = { source = "remote", cue = "horn:pushed", aliases = ["show:start"] }
role = "show"
```

Utility flows are dispatched before stateful flows. Consequently the horn is
direct feedback and sounds even when the controller rejects the show request;
the eye and physical assemblies still run only when the controller is Ready.
Only `horn:pushed` requests the show; renew/release packets are audio-only. A
hold start is idempotent by key, and Cue IDs are deduplicated, so heartbeats and
MQTT retries cannot layer copies or restart the show.

By default the entire resident clip loops. For a more natural extendable horn,
keep an attack at the front of the WAV and choose a steady, zero-crossing loop
region with `loop_start_ms` and `loop_end_ms` on both hold-start actions. The
attack plays once; only that region repeats. Release currently stops
immediately, which is appropriate for a push-button horn and can later be
extended with a separate release tail if the source recording needs one.

## Library and future clips

The show asset map is the track catalog, with stable IDs separate from outputs:

```toml
[assets.horn]
type = "audio"
file = "/home/dyma/audio/horn.wav"

[assets.wind]
type = "audio"
file = "/home/dyma/audio/wind.wav"
```

Keep source masters on the Pi (and backed up elsewhere), preferably uncompressed
PCM WAV. The current 48 kHz/16-bit/stereo format is a practical common format;
retain higher-resolution originals rather than destructively converting them.
Add independently named assets for horn, tip, fart, idle, wind, Frank, etc.
The API takes a catalog ID, never an arbitrary browser-supplied path. The
dashboard shows availability, file format, and PCM/float WAV duration without
reading the complete audio into memory. Other formats supported by `pw-play`
may work, but are not automatically transcoded or duration-probed here.

For now trim/export new WAV clips offline, keeping the master unchanged. The
dashboard's Loop checkbox repeats a selected ambient track until its playback
Stop button is pressed. That general-purpose loop may have a small restart gap;
the resident horn loop is sample-continuous. There is no waveform editor or
upload interface.

## DAG mixing

Existing `audio.play` actions use the same managed player as the dashboard.
An audio node completes only after the player process successfully reaches
end of file. Operator Stop makes that node fail; dependents are skipped. It
does not pretend that stopped audio completed normally. STOP ALL now cancels
pending actions **and** stops active FX-managed audio, not unrelated desktop
applications.

Within a flow whose assets and sinks are configured:

```toml
[[flows.scene.nodes]]
id = "wind"
action = { type = "audio.play", sink = "porch", asset = "wind", volume = 0.25 }

[[flows.scene.nodes]]
id = "horn"
action = { type = "audio.play", sink = "tractor", asset = "horn" }

[[flows.scene.nodes]]
id = "tip"
after = ["horn"]
action = { type = "audio.play", sink = "tractor", asset = "tractor_tip" }
```

The wind and horn start independently; tip waits for horn to finish. Use the
same sink on independent nodes to layer tracks. Per-action volume is stream
gain, while the dashboard slider changes the physical sink's volume. Layering
can clip, so leave headroom. Process completion is not acoustic feedback, and
separate processes/Bluetooth speakers do not provide sample-accurate sync.

## API and verification

`GET /api/audio` returns tracks, outputs, playback instances, host, readiness
errors, and the shared concurrency limit. `POST /api/audio` accepts:

- `{ "type": "play", "track": "tractor_tip", "output": "speaker" }`
- `{ "type": "play", "track": "wind", "output": "speaker", "loop": true }`
- `{ "type": "stop", "playback": "PLAYBACK_UUID" }`
- `{ "type": "volume", "output": "OUTPUT_ID", "percent": 50 }`
- `{ "type": "connect", "output": "bluetooth:AA:BB:CC:DD:EE:FF" }`
- `{ "type": "disconnect", "output": "bluetooth:AA:BB:CC:DD:EE:FF" }`

Play also accepts optional stream `volume` from 0 to 1. Discovery refreshes
about every two seconds. The dashboard reports each action's failure, while
the activity log records playback starts and terminal status.

`sync/shows/audio-smoke.toml` and
`tractor-eye/scripts/verify-audio.mjs` target only two explicitly named silent
virtual sinks, `fx_audio_test_a` and `fx_audio_test_b`, on port 18080. The driver
refuses production show names and physical outputs. It verifies simultaneous
tracks/output routing, shared capacity, Stop, natural completion, volume,
unknown-target rejection, and audio-dependent DAG behavior without sending
sound to a real speaker. Use a separate `FX_DISPLAY_REGISTRY` for this test
instance as with the orchestration smoke profile.

`sync/shows/horn-smoke.toml` plus `tractor-eye/scripts/verify-horn.mjs`
exercise the complete physical-event semantics through an isolated MQTT topic:
resident audio fires while the state machine rejects an unready show, a reset
permits the next show, timing is honored, and a duplicate event starts neither
branch twice. The fixture uses a simulated motor and a muted Pi output, never
the JBL alias.
