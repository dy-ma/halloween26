# Tractor Eye

Fullscreen browser animation for the Halloween tractor prop. The app is a static Vite build intended to run in Chromium kiosk mode on a Raspberry Pi. Keyboard controls and the WebSocket client publish through the same typed command bus. Serial and audio remain the responsibility of `fx`.

The installed panel reports a 1920 x 1200 resolution and 340 x 210 mm active area. Mounted in portrait, the default rendered eye is approximately one inch wider and 1.5 inches taller than the first 88 x 265 mm template-derived layout. Its 55.6vw x 90.1vh calibration frame is about 667 x 1730 px at the Pi's 1200 x 1920 desktop. The animated eye stays inside that frame with a black safety area around it. The iris looks off to one side, foreshortened by the viewing angle, with rusty brown sliding lids. While open, it makes small hesitant glances and occasional double blinks. Arrow-key gaze overrides neutral-mode idle glances; alert/tipping retain their small tremor. `Home` centers the gaze. Reduced-motion preferences disable idle animation. For Pi rendering performance, the textured lids use fixed shapes with transform-only movement, and the gaze layers are iris-sized.

## Run locally

```sh
npm install
npm run dev
```

## Keyboard controls

| Key | Command |
|---|---|
| `W` | Flutter awake, then flow directly into an upward drift |
| `O` | Open |
| `C` | Close |
| `B` or `Space` | Blink |
| `I` | Idle mode |
| `A` | Alert mode |
| `S` | Sleeping mode |
| Arrow keys | Move the gaze |
| `Home` | Center the gaze |
| `R` | Reset |
| `M` | Mirror the display for the opposite-facing tractor (persisted locally) |
| `D` | Toggle the mounting guide and diagnostics |
| `Shift` + Arrow keys | Move the eye frame by 8 px (`Alt` adds a 40 px coarse step) |
| `Ctrl` + Left/Right | Narrow or widen by 1% (`Alt` changes by 5%) |
| `Ctrl` + Up/Down | Make taller or shorter by 1% (`Alt` changes by 5%) |
| `[` / `]` | Rotate by 1° (`Shift` rotates by 5°) |
| `-` / `+` | Scale width and height together by 1% (`Alt` scales by 5%) |
| `Shift` + `R` | Reset translation, rotation, and scale |

Diagnostics are shown by default in the screen area outside the cutout. Translation, rotation, and scale move the animated eye and dashed cutout guide together so the guide can be aligned directly with the wood opening. Display calibration and mirror state persist in local storage on each Pi. Use `?debug=0` to start with diagnostics hidden. `?mirror=1` or `?mirror=0` can override the saved orientation for a kiosk URL.

The eye rests closed on startup, with no on-screen controls. `W` publishes `eye/wake` through the same command bus as the WebSocket source. Wake snaps to a visibly closed launch pose and opens into a startled expression with an enlarged iris and pupil. The first phase spreads four quick blinks 400ms apart while rapid glances continue underneath. The second phase continues the rapid glances without blinking. At 4.0 seconds, the eye starts a smooth 2.4-second upward drift from the last glance's position, with no extra shakes or horizontal recentering. With the show's eye node scheduled at 750ms, that drift begins 4.75 seconds into the audio. Tipping mode keeps the wide-eyed expression and enlarged iris but reduces tremor amplitude to roughly a quarter of alert mode and slows it down. The frame does not rotate. Another Wake restarts the sequence; other animation commands cancel pending cues. `C`, `S`, or `R` returns the eye to rest. Transport heartbeats never enter this bus.

`eye/look` accepts an optional `durationMs`, independent of eyelid timing, for slow gaze movements. `eye/mode` also accepts `tipping` for the calmer tremor. Keyboard gaze input restores a quick transition after a slow drift.

## Build

```sh
npm run build
```

The static output is written to `dist/`. It can be served by the Rust `fx` service or any small local HTTP server.

## Connect to fx

The [v1 WebSocket contract and Pi deployment checklist](docs/websocket-and-pi.md) is implemented on the browser side. The real `fx` server and durable service installation are separate work; this repo includes a local mock for integration testing.

`public/config.json` defaults to explicit keyboard-only mode (`websocket.enabled: false`). For a connected installation, have `fx` serve `/config.json` with:

```json
{
  "screenId": "tractor-eye",
  "websocket": { "enabled": true, "url": "/ws" }
}
```

The browser fetches this file with `cache: no-store` at page startup. It is runtime configuration, so the production server can supply it without rebuilding JS. Reload the page after changing it. `/ws` resolves to the page's origin using WS/WSS; an explicit `ws://host:8081/ws` URL supports separate hosting. Missing/invalid config fails closed with a diagnostic error; keyboard controls remain available. The client never reads serial or plays audio.

The server must send `hello` → `snapshot` → ordered command envelopes as described in the contract; bare `{"type":"eye/wake"}` frames are not accepted. A reconnect restores the final desired pose without replaying a missed cue. Audio/eye coordination is cue-level, not sample-accurate synchronization.

Inspect transport state without an overlay in browser DevTools:

```js
JSON.parse(document.body.dataset.eyeConnection)
```

This contains connection phase, server session, last accepted sequence, last heartbeat time, and a failure reason when applicable. Connection logs are rate limited.

## Local integration test (no Pi, serial, or audio needed)

```sh
npm ci
npm run build
npm run mock:fx
```

Open `http://127.0.0.1:4174/`. In the mock server terminal, type `wake`, `close`, `reset`, or `disconnect`, then Enter. It serves enabled config, sends snapshots, responds to heartbeats, and sends expiring commands. `disconnect` exercises reconnect/snapshot recovery; it must not replay Wake. Ctrl+C stops the mock. Set `MOCK_FX_PORT` to use another port. It binds loopback only and is a developer fixture, not a production server.

Run `npm test`, `npm run lint`, and `npm run build` before handing off changes. Tests cover transport validation, ordering, expiry, reconnect/backoff, heartbeat, teardown/remount, config loading, and the animation sequence.

## Command boundary

Commands and their Effect schema live in `src/commands/animation-command.ts`. Sources publish them through `AnimationCommandBus`; the React reducer and Motion renderer do not know whether a command came from a keyboard, WebSocket, serial bridge, or demo sequence.

`src/network/protocol.ts` adds stricter network bounds around the local command schema. `createWebSocketCommandSource` handles transport; `createRuntimeWebSocketSource` loads config. A local-only `eye/snapshot` action atomically cancels scripted cues and resets pose/motion tracks. It cannot be sent inside a wire command envelope.
