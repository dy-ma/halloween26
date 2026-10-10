# Tractor Eye

Fullscreen browser animation for the Halloween tractor prop. The app is a static Vite build intended to run in Chromium kiosk mode on a Raspberry Pi. Animation input is routed through typed commands so keyboard controls and the future WebSocket client use the same path.

The reference-inspired prop uses one tall, narrow white eye set into a rusty brown body panel. Its level frame extends beyond the right edge of the display so the white appears to wrap around the tractor's front corner. The iris looks forward to the right, foreshortened by the viewing angle, with rusty brown sliding lids. While open, it makes small hesitant glances and occasional double blinks. Arrow-key gaze overrides the idle glances; `Home` restores the forward-looking pose and idle motion. Reduced-motion preferences disable the idle animation.

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

The eye rests closed on startup, with no on-screen controls. `W` publishes `eye/wake` through the same command bus a WebSocket source will use later. Wake takes about 3.8 seconds: settle closed, open into a startled expression, then three quick blinks with glances moving underneath the eyelids. Each glance begins 50ms into its 220ms blink so it finishes as the lids reopen. At 1.4 seconds, directly after the final blink, the eye starts a smooth 2.4-second upward drift from the last glance's position, with no extra shakes or horizontal recentering. Tipping mode keeps the wide-eyed expression but reduces tremor amplitude to roughly a quarter of alert mode and slows it down. The frame does not rotate. Another Wake restarts the sequence; other commands cancel pending cues. `C`, `S`, or `R` returns the eye to rest.

`eye/look` accepts an optional `durationMs`, independent of eyelid timing, for slow gaze movements. `eye/mode` also accepts `tipping` for the calmer tremor. Keyboard gaze input restores a quick transition after a slow drift.

## Build

```sh
npm run build
```

The static output is written to `dist/`. It can be served by the Rust `fx` service or any small local HTTP server.

## Command boundary

Commands and their Effect schema live in `src/commands/animation-command.ts`. Sources publish them through `AnimationCommandBus`; the React reducer and Motion renderer do not know whether a command came from a keyboard, WebSocket, serial bridge, or demo sequence.

The future WebSocket source should:

1. Parse incoming JSON.
2. Validate it with `decodeAnimationCommand`.
3. Publish valid commands to the shared bus.
4. Reconnect with bounded backoff.
5. Accept an authoritative state snapshot after reconnecting.
