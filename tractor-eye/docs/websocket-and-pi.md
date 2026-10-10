# Tractor eye WebSocket client and Pi deployment

Proposed v1 contract for the browser client and the `fx` server. The animation is checkpointed at `7586eec`. The transport, runtime configuration, snapshot handler, and service units below are implementation work, not existing functionality.

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

The two supervised processes are `fx` and Chromium. There is no Vite/Node process needed on the Pi if `fx` serves the static build. Serving the assets and WebSocket on the same origin also avoids a second browser endpoint to configure. Bind loopback only for the first deployment.

If static hosting must stay separate, use a small production HTTP server on 8080 and the `fx` WebSocket on 8081, or reverse-proxy `/ws` through the static server. Keep the endpoint configurable. Do not run `vite dev` or `vite preview` as the production server; [Vite explicitly describes preview as local testing only](https://vite.dev/guide/static-deploy.html).

## Ports and Portless

Allocate 8080 in the Pi configuration and check that it is free during installation; this is a convention, not an OS reservation. Fail clearly if another process owns it, instead of silently choosing another port.

[Portless](https://github.com/vercel-labs/portless) supplies named local URLs through a proxy and can install that proxy as a startup service. It is useful on a development laptop with many apps. For this fixed appliance, it adds routing and proxy configuration without removing the need to supervise `fx` and Chromium. Keep it optional for laptop development, not a Pi dependency.

## Client interface

Implement `createWebSocketCommandSource(config): AnimationCommandSource` using the existing `start(commandBus)` / cleanup interface. Mount it once beside the keyboard source. It owns the socket, handshake, reconnection, heartbeat, and inbound validation. It does not own animation timing or serial access.

Runtime configuration should come from `/config.json`, fetched without caching:

```json
{
  "screenId": "tractor-eye",
  "websocket": {
    "enabled": true,
    "url": "/ws"
  }
}
```

Resolve `/ws` against the page origin, with `ws:` for HTTP and `wss:` for HTTPS. An explicit absolute WebSocket URL supports laptop-to-Pi testing or separate hosting. Reject insecure `ws:` endpoints on an HTTPS page. Do not bake the Pi's IP into the JS bundle. Supply an explicit disabled config for keyboard-only development; missing or invalid config should keep the scene closed and log a configuration error, not invent an endpoint.

## Wire protocol

JSON text frames, protocol version `v: 1`, at most 8 KiB per frame. All messages below are proposed. Screen IDs are routing labels, not authentication credentials.

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

The client needs a new atomic local snapshot action: cancel the wake sequence, set mode/gaze/aperture without a blink or transition, and clear transient animation state. A freshly loaded browser starts closed until this snapshot arrives. On reconnect, the snapshot replaces the current pose, even if it differs; this deliberate recovery correction is separate from the uninterrupted animation's smooth phase transitions.

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
- Validate before publishing. Reject unknown versions/types, nonfinite or out-of-range gaze values, invalid sequence/timestamps, and durations outside 0–10000ms. Add these bounds to the network decoder; the current local command schema alone does not enforce all of them.
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

The client sends one ping every 5 seconds after synchronization; the server promptly echoes the ID as pong. Close and reconnect if that ping is unanswered after 10 seconds. Allow only one outstanding ping. Heartbeats do not increment command sequence numbers. They must never enter the animation bus, because that would cancel Wake.

Use a 5-second connect/snapshot deadline. Retry with exponential backoff starting at 500ms, capped at 10 seconds, with randomized delay. Reset the backoff after a synchronized connection has stayed healthy for 30 seconds, not immediately on TCP open. Close failed/stale sockets before replacing them; allow one live socket and one retry timer. Ignore callbacks from retired sockets. Cleanup closes the socket and clears every timer, including React Strict Mode mount/unmount cycles.

While disconnected, let an already-running local animation finish and hold its result. Do not reset, replay Wake, reload the page, or put an error banner over the prop. Keep keyboard controls available. On reconnect, apply the server snapshot. This client is visual only: it is not a safety controller for the tipping mechanism.

Expose connection phase (`disabled`, `connecting`, `syncing`, `connected`, `retrying`, `config-error`), last accepted sequence, and last heartbeat in diagnostic state/logs. No on-screen controls are needed for show mode.

## Pi startup and deployment checklist

- [ ] Implement and test the WebSocket source, bounded decoder, runtime config loader, and atomic snapshot action. Leave the approved animation unchanged.
- [ ] Add `/`, `/config.json`, `/healthz`, and `/ws` to `fx`. Keep serial reading independent of browser connection status; losing the eye must not stop audio.
- [ ] Run `fx` as the non-root user with the working PipeWire session. The current library invokes `wpctl`/`pw-play`, so a root system service will not automatically inherit that audio environment. Prefer a user service with the required audio/session dependencies; verify boot behavior on the actual Pi.
- [ ] Launch Chromium kiosk through the actual graphical user's session, after the compositor and HTTP readiness. A plain boot-time system unit without a working display/session environment is insufficient. Determine the Pi OS release, compositor, username, and Chromium executable before writing/installing units.
- [ ] Configure automatic restart, restart delay, and useful logs for `fx` and the kiosk. Account for systemd start-rate limits; test repeated failures, not just a single restart. [systemd's service documentation](https://manpages.debian.org/trixie/systemd/systemd.service.5.en.html) describes the relevant restart behavior.
- [ ] Make the kiosk launcher wait/retry `/healthz` before first navigation. Dependency ordering alone does not prove HTTP readiness. If initial navigation fails, the launcher must retry it; the JS reconnect logic cannot help before the page loads.
- [ ] Use a stable `/dev/serial/by-id/...` path and verify serial permissions plus unplug/replug recovery in `fx`.
- [ ] Build on the laptop with the lockfile; deploy only `dist/` and runtime config for the frontend. Copy assets atomically or use release directories; serve config/index without long-lived caching and hashed assets with immutable caching. Keep a previous release available for rollback.
- [ ] Test at the real display resolution, with screen blanking/power saving configured for the show, no missing external assets, and Wi-Fi disconnected. Do not assume desktop frame rate represents the Pi 4B.
- [ ] Cold-boot unattended; kill/restart `fx`; kill/restart Chromium; unplug USB; interrupt networking during Wake; send duplicates, expired cues, malformed JSON, and sequence gaps. Verify no unintended Wake replay, no timer/socket leak, and correct snapshot recovery.

Before exposing this beyond loopback, add explicit interface/firewall policy, an Origin allowlist, and appropriate authentication/TLS for that network. A screen ID or an unguessable URL is not authentication. Multi-Pi fan-out and simultaneous audio/animation timing are separate integration work, not guarantees of this v1 transport.
