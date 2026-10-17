# Tractor eye WebSocket client and Pi deployment

V1 contract for the browser client and the `fx` server. **The browser transport, runtime configuration loader, bounded decoder, atomic snapshot handler, and real `fx` endpoints are implemented.** Durable Pi startup/service units and full on-device recovery testing remain deployment work. The source-tree development config still explicitly disables networking; the config served by `fx` enables it.

The approved wake sequence is unchanged by networking. The current renderer fills 90% of viewport height and uses fixed-shape sliding lids and iris-sized gaze layers for Pi performance. Do not reintroduce per-frame lid-radius changes or windshield-sized gaze surfaces during integration.

## Implemented fx integration

1. `fx run` owns USB serial and audio; the eye never reads serial or plays sound.
2. A single deduplicated show cue starts all matching audio routes and publishes one enveloped screen command. Wake's blink and gaze sub-cues stay local to the browser. V1 starts on receipt; it does not promise exact audio/visual timing or multi-Pi synchronization.
3. `fx` tracks each screen's boot-unique session, contiguous sequence, and stable desired state. For Wake, the route stores the final `tipping` pose immediately for reconnect recovery. Snapshot plus subscription is atomic.
4. `fx` serves `/`, enabled `/config.json`, `/healthz`, and `/ws` from one loopback origin. The origin allowlist is limited to loopback hosts on the configured port.
5. A real socket-level Rust test covers hello, initial snapshot, and live command delivery. `npm run build && npm run mock:fx` remains the browser-side reference fixture on loopback port 4174; its terminal accepts `wake`, `close`, `reset`, and `disconnect`.

Screen behavior is configured as flow nodes beside audio actions in the show TOML. Returning to sleeping/idle is always another explicit Cue flow (for example `show:reset`); `fx` does not invent a preset return timer.

As of the manual Pi setup on 2026-10-10, `fx` owns `127.0.0.1:8080` and launches Chromium when the show enables `[kiosk]`. Vite is not part of the deployed runtime. This is running from tmux, not a boot-installed service, so unattended cold-boot startup remains deployment work.

Use a persistent WebSocket that receives pushed commands, not a polling loop. Keep the animation entirely local: one `eye/wake` command runs the approved sequence without further network traffic. `fx` remains the sole serial reader and audio owner.

## Runtime layout

Recommended Pi layout:

```text
ESP32 USB serial
      |
      v
fx process ──> PipeWire audio
      |
      +── HTTP 127.0.0.1:8080/     built tractor-eye/dist files
      +── HTTP 127.0.0.1:8080/healthz
      +── WS   127.0.0.1:8080/ws  pushed screen commands
                                |
                                v
                       Chromium kiosk
```

With `kiosk.enabled = true`, one foreground `fx run --config ...` command starts the server, waits for it to listen, launches Chromium, records the kiosk PID, and stops Chromium when the show exits. `fx run --no-kiosk` plus `fx kiosk start|stop|restart|status` keeps separate-process debugging available. There is no Vite/Node process on the Pi. Serving the assets and WebSocket on the same origin also avoids a second browser endpoint to configure. Bind loopback only for the first deployment.

If static hosting must stay separate, use a small production HTTP server on 8080 and the `fx` WebSocket on 8081, or reverse-proxy `/ws` through the static server. Keep the endpoint configurable. Do not run `vite dev` or `vite preview` as the production server; [Vite explicitly describes preview as local testing only](https://vite.dev/guide/static-deploy.html).

## Ports and Portless

Allocate 8080 in the Pi configuration and check that it is free during installation; this is a convention, not an OS reservation. Fail clearly if another process owns it, instead of silently choosing another port.

[Portless](https://github.com/vercel-labs/portless) supplies named local URLs through a proxy and can install that proxy as a startup service. It is useful on a development laptop with many apps. For this fixed appliance, it adds routing and proxy configuration without removing the need to supervise `fx` and Chromium. Keep it optional for laptop development, not a Pi dependency.

## Client interface

`createWebSocketCommandSource(config): AnimationCommandSource` implements the existing `start(commandBus)` / cleanup interface. `App` mounts `createRuntimeWebSocketSource` once beside the keyboard source; it loads config and starts the transport. The source owns the socket, handshake, reconnection, heartbeat, and inbound validation. It does not own animation timing or serial access.

Runtime configuration comes from `/config.json`, fetched without caching with a 5-second deadline:

```json
{
  "screenId": "tractor-eye",
  "websocket": {
    "enabled": true,
    "url": "/ws"
  }
}
```

The client resolves origin-relative paths such as `/ws` against the page origin, with `ws:` for HTTP and `wss:` for HTTPS. An explicit absolute WebSocket URL supports laptop-to-Pi testing or separate hosting. It rejects insecure `ws:` endpoints on an HTTPS page, embedded credentials, fragments, and protocol-relative hosts. Screen IDs must be nonempty strings up to 128 characters. Do not bake the Pi's IP into the JS bundle. `public/config.json` supplies an explicit disabled config for keyboard-only development; missing or invalid config keeps the initial scene closed and logs a configuration error, not an invented endpoint. Keyboard controls remain available. Config is read once per page load; reload after changing it.

## Wire protocol

JSON text frames, protocol version `v: 1`, at most 8 KiB of UTF-8 per frame. Binary frames are rejected. All messages below are handled by the client. Screen IDs are routing labels, not authentication credentials. Session IDs and heartbeat IDs must be nonempty strings up to 128 characters.

### Connect and synchronize

Client sends immediately on socket open:

```json
{"v":1,"type":"hello","screenId":"tractor-eye"}
```

Server sends a snapshot before any commands on every connection:

```json
{
  "v": 1,
  "type": "snapshot",
  "sessionId": "fx-boot-unique-id",
  "seq": 12,
  "state": {
    "mode": "sleeping",
    "gaze": {"x": 0, "y": 0}
  }
}
```

`sessionId` is unique each time the server loses/reinitializes its sequencing state. `seq` is a nonnegative safe integer, monotonic per screen within that session. The snapshot's sequence is the last command included in that state; commands after it must be sent in order. Capture the snapshot and register the live subscription atomically so no event falls between them.

Snapshot modes are `sleeping`, `idle`, `alert`, and `tipping`. Sleeping means closed; other modes mean open. Gaze values are finite numbers from -1 to 1. The server supplies a stable desired pose, not internal React counters, pending timers, or an instruction to replay Wake.

The client applies a local-only atomic snapshot action: cancel the wake sequence, set mode/gaze/aperture without a blink or transition, and clear transient animation state. Motion tracks remount on each snapshot, including when the desired pose matches an in-flight animation's target. A freshly loaded browser starts closed until this snapshot arrives (unless locally overridden by keyboard). On reconnect, the snapshot replaces the current pose, even if it differs; this deliberate recovery correction is separate from the uninterrupted animation's smooth phase transitions. Send exactly one snapshot per connection; a second snapshot causes resynchronization.

For a reconnect in the middle of a show cue, v1 restores that cue's desired final pose, not its exact elapsed frame. For the current Wake sequence, that pose is `tipping` with gaze `{"x":-0.25,"y":-0.65}`. Exact mid-animation resumption or synchronized multi-Pi animation needs a later timeline/start-time extension.

### Live commands

After the snapshot, the server sends:

```json
{
  "v": 1,
  "type": "command",
  "sessionId": "fx-boot-unique-id",
  "seq": 13,
  "expiresAtMs": 1791660002000,
  "command": {"type":"eye/wake"}
}
```

`expiresAtMs` is an illustrative Unix timestamp in milliseconds; the server generates a current deadline for each command. Start with a 2-second delivery lifetime for live cues. The browser must not run delayed Wake events after a stalled connection recovers. Same-Pi deployment shares the host clock; distributed Pis need clock synchronization and a tested expiry budget.

The inner `command` uses the existing `AnimationCommandSchema`. Useful commands include:

```json
{"type":"eye/wake"}
{"type":"eye/close","durationMs":900}
{"type":"system/reset"}
{"type":"eye/look","x":-0.25,"y":-0.65,"durationMs":2400}
```

Rules:

- Accept commands only after a valid snapshot, from its `sessionId`.
- Drop duplicate/older sequence numbers without republishing them.
- Require the next sequence to be exactly the previous one plus one. On a gap, session mismatch, or expired command, reconnect for a fresh snapshot instead of guessing or replaying.
- Validate before publishing. The network decoder rejects unknown versions/types, nonfinite or out-of-range gaze/nudge values, invalid sequence/timestamps, and durations outside 0–10000ms. Sequence numbers and expiry timestamps must be nonnegative safe integers. The local command schema alone does not enforce all of these bounds. A local-only `eye/snapshot` is never accepted as a wire command.
- Malformed or oversized frames must not reach the animation bus. Close/reconnect with bounded backoff and rate-limited diagnostics rather than continuing with potentially missing state.
- Publish valid commands into the same bus used by `W`. Do not stream pupil coordinates for Wake and do not send local keyboard commands back to the server.
- New commands keep the existing interruption policy: Wake restarts; Close/Reset cancel; an explicit gaze command interrupts the remaining scripted sequence.

The server must filter/route commands before assigning per-screen sequence numbers. Sending unrelated commands with gaps in a global sequence would cause unnecessary resynchronization. Do not replay queued transient commands when a browser reconnects: send the current snapshot, then future live cues.

### Liveness and reconnect

Use application-level heartbeat messages, independent of animation commands:

```json
{"v":1,"type":"ping","id":"1"}
{"v":1,"type":"pong","id":"1"}
```

The client sends its first ping 5 seconds after synchronization, then schedules the next 5 seconds after each matching pong; the server promptly echoes the ID. It closes and reconnects if that ping is unanswered after 10 seconds. Only one ping is outstanding. Unsolicited/mismatched pongs cause resynchronization. Heartbeats do not increment command sequence numbers. They never enter the animation bus, because that would cancel Wake.

The client uses a 5-second connect/snapshot deadline. Retry ceilings double from 500ms to a maximum of 10 seconds, with each delay randomized to 50–100% of that ceiling. Backoff resets after a synchronized connection has stayed healthy for 30 seconds, not immediately on TCP open. Failed/stale sockets close before replacement; only one live socket and one retry timer are allowed. Callbacks from retired sockets are ignored. Cleanup closes the socket and clears every timer, including React Strict Mode mount/unmount cycles.

While disconnected, let an already-running local animation finish and hold its result. Do not reset, replay Wake, reload the page, or put an error banner over the prop. Keep keyboard controls available. On reconnect, apply the server snapshot. This client is visual only: it is not a safety controller for the tipping mechanism.

Connection phase (`disabled`, `connecting`, `syncing`, `connected`, `retrying`, `config-error`), last accepted sequence, session ID, and last heartbeat are exposed as JSON in `document.body.dataset.eyeConnection`. Phase logs are rate limited (10 seconds); diagnostics never rerender React or enter the animation bus. There are no on-screen controls for show mode.

## Pi startup and deployment checklist

- [x] Implement and test the WebSocket source, bounded decoder, runtime config loader, and atomic snapshot action. Leave the approved animation unchanged.
- [x] Verify browser → mock server handshake, server-triggered Wake, heartbeat, and snapshot recovery after disconnect. This does not substitute for real fx/audio or Pi boot testing.
- [x] Add `/`, `/config.json`, `/healthz`, and `/ws` to `fx`. Serial reading and audio dispatch are independent of browser connection status; losing the eye does not stop audio.
- [ ] Run `fx` as the non-root user with the working PipeWire session. The current library invokes `wpctl`/`pw-play`, so a root system service will not automatically inherit that audio environment. Prefer a user service with the required audio/session dependencies; verify boot behavior on the actual Pi.
- [ ] Launch Chromium kiosk through the actual graphical user's session, after the compositor and HTTP readiness. A plain boot-time system unit without a working display/session environment is insufficient. Determine the Pi OS release, compositor, username, and Chromium executable before writing/installing units.
- [ ] Configure automatic boot/restart and restart delay for the unified runner. Runtime logs now append to `/tmp/fx-run.log` and Chromium logs to `/tmp/fx-kiosk.log`, but `/tmp` is not durable and no user service is installed yet. Account for systemd start-rate limits; test repeated failures, not just a single restart. [systemd's service documentation](https://manpages.debian.org/trixie/systemd/systemd.service.5.en.html) describes the relevant restart behavior.
- [x] Wait for the configured HTTP listener before launching the kiosk, and fail clearly if Chromium exits immediately. The browser's WebSocket reconnect logic still handles readiness after the initial page load.
- [ ] Use a stable `/dev/serial/by-id/...` path and verify serial permissions plus unplug/replug recovery on the Pi. `fx` now retains one serial owner and retries the configured stable path with bounded backoff.
- [ ] Build on the laptop with the lockfile; deploy only `dist/` and runtime config for the frontend. Copy assets atomically or use release directories; serve config/index without long-lived caching and hashed assets with immutable caching. Keep a previous release available for rollback.
- [ ] Test at the real display resolution, with screen blanking/power saving configured for the show, no missing external assets, and Wi-Fi disconnected. Do not assume desktop frame rate represents the Pi 4B.
- [ ] Cold-boot unattended; kill/restart `fx`; kill/restart Chromium; unplug USB; interrupt networking during Wake; send duplicates, expired cues, malformed JSON, and sequence gaps. Verify no unintended Wake replay, no timer/socket leak, and correct snapshot recovery.

Before exposing this beyond loopback, add explicit interface/firewall policy, an Origin allowlist, and appropriate authentication/TLS for that network. A screen ID or an unguessable URL is not authentication. Multi-Pi fan-out and simultaneous audio/animation timing are separate integration work, not guarantees of this v1 transport.
