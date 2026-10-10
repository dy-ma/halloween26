# Tractor Eye

Fullscreen browser animation for the Halloween tractor prop. The app is a static Vite build intended to run in Chromium kiosk mode on a Raspberry Pi. Keyboard controls and the WebSocket client publish through the same typed command bus. Serial and audio remain the responsibility of `fx`.

The reference-inspired prop uses one tall, narrow white eye set into a rusty brown body panel, sized to 90% of viewport height. Its level frame extends beyond the right edge of the display so the white appears to wrap around the tractor's front corner. The iris looks forward to the right, foreshortened by the viewing angle, with rusty brown sliding lids. While open, it makes small hesitant glances and occasional double blinks. Arrow-key gaze overrides neutral-mode idle glances; alert/tipping retain their small tremor. `Home` centers the gaze. Reduced-motion preferences disable idle animation. For Pi rendering performance, the textured lids use fixed shapes with transform-only movement, and the gaze layers are iris-sized.

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

The eye rests closed on startup, with no on-screen controls. `W` publishes `eye/wake` through the same command bus as the WebSocket source. Wake takes about 3.8 seconds: settle closed, open into a startled expression, then three quick blinks with glances moving underneath the eyelids. Each glance begins 50ms into its 220ms blink so it finishes as the lids reopen. At 1.4 seconds, directly after the final blink, the eye starts a smooth 2.4-second upward drift from the last glance's position, with no extra shakes or horizontal recentering. Tipping mode keeps the wide-eyed expression but reduces tremor amplitude to roughly a quarter of alert mode and slows it down. The frame does not rotate. Another Wake restarts the sequence; other animation commands cancel pending cues. `C`, `S`, or `R` returns the eye to rest. Transport heartbeats never enter this bus.

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
