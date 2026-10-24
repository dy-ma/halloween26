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

For now trim/export new WAV clips offline, keeping the master unchanged.
Later the catalog can gain non-destructive source/clip boundaries without
coupling clips to a speaker. There is no waveform editor, upload interface,
looping engine, or time-range playback API in this change.

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
