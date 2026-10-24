# Displays, audio, assemblies, and dependency workflows

One `fx` process serves the dashboard and display pages, schedules actions,
plays audio through the Pi's PipeWire devices, and exchanges Cue messages with
assemblies. MQTT is a separate service, addressed by `mqtt.dylfi`. It can be
moved to a different host. Browser displays use WebSockets, not MQTT directly.

## Display clients

Open the display page on any browser: it registers itself automatically and
appears in the dashboard. There are no preset Pi/iPad device slots. Each live
connection gets its own Wake/Reset pair and independent command state/sequence,
including multiple tabs in the same browser. Audio remains separate.

Open these on different devices (use the host address reachable from that
device; the Tailscale address below requires Tailscale connectivity):

```text
http://100.110.38.16:8080/
http://fx.dylfi:8080/?name=Porch-eye
```

`name` is an optional human-readable device label. Without one, the server
uses a browser label from the user-agent plus a short ID. User-agent is
descriptive metadata, never the identity: identical browsers stay distinct.
A small versioned local-storage
record supplies a persistent browser client ID. `client=IDENTIFIER` can set
an explicit ID. Storage is scoped to the browser and website origin, so
switching between an IP URL and a DNS URL creates a separate browser identity.
Multiple tabs with the same client ID have distinct connection IDs and separate
controls. The saved device stays listed offline after its tabs disconnect;
Forget removes an offline test device. Reopening its page registers it again.
Clear/blocked browser storage can create a new identity; this is not hardware
fingerprinting or authentication.

Saved identity/name/user-agent and last-seen data live in the Pi user's
`~/.config/fx/display-devices.json` (or under `XDG_CONFIG_HOME`). Writes use a
versioned JSON file and atomic replacement. `FX_DISPLAY_REGISTRY` overrides the
path for an isolated instance. Up to 256 devices and 128 live connections are
supported. The registry survives `fx` restarts; connection IDs do not.

Configured screen sinks now serve as optional **show groups**, not device
inventory. With no `screen` query, a browser joins `server.screen_id`. An
explicit `screen` can select another configured group. Existing show cues and
the E shortcut address the group; individual dashboard controls address only
the selected connection. Group acknowledgments are correlated correctly even
after private commands diverge the connections' sequence counters. The MQTT
show keeps just its original `tractor-eye` group; a second group is not needed
to control a second browser.

The Pi kiosk uses an explicit `pi-eye` client ID and `Pi-eye` label. HTML entry
pages are served with `Cache-Control: no-cache` so a reload revalidates the
current build; content-hashed JavaScript assets can still be cached. Refresh
already-open displays after deploying a new browser client.

`/api/displays` returns saved devices and their live connections, individual
states, and accepted command sequences. `DELETE /api/displays/{id}` forgets an
offline device; it rejects deletion while tabs are connected. `/api/screens`
remains available for show-group diagnostics. Live sessions are removed on
disconnect, but saved device records remain. Clients
heartbeat every five seconds; the server disconnects an unresponsive session
after about twenty seconds.

An `applied` reply means a client accepted a command into its command bus.
It **does not** prove an animation finished or a physical screen displayed it.
Group actions complete when at least one client in that group acknowledges
the command. They fail at `expires_after_ms` if no client acknowledges. A
reconnect snapshot restores desired state, but does not falsely complete a
missed animation command.

## Audio outputs

Audio sinks remain independent of display roles. Two eyes can share one
speaker, or three configured audio sinks can route to three PipeWire outputs.
Audio does not automatically play on a browser/iPad. An audio action finishes
when its `pw-play` process finishes successfully. This is process completion,
not acoustic or microphone feedback.
See [AUDIO.md](AUDIO.md) for the dedicated Audio devices section, source-track
catalog, per-voice playback/Stop, Bluetooth readiness, and DAG mixing.

## Dependency graphs

Root `at_ms` nodes use offsets from the trigger. For MQTT assemblies, `fx`
immediately transmits those nodes with an absolute execution time; the board
queues them and begins locally at that time. Local audio/screens and legacy
serial or ESP-NOW paths still wait in `fx`. Add `after = ["node-id", ...]` to
wait for all named nodes in that flow to complete. With `after`, `at_ms` is an
additional delay after the dependencies; `fx` transmits the child as soon as
the dependencies finish and converts that delay to a new execution timestamp.
Unknown edges, duplicates, self-dependencies, and cycles are rejected.

For example, inside a flow whose sinks/assets are already configured:

```toml
[[flows.tip.nodes]]
id = "raise"
action = { type = "cue.emit", sink = "dc_a", cue = "dc:fwd:70:10000", wait_for = "dc:limit:fwd", timeout_ms = 13000 }

[[flows.tip.nodes]]
id = "sound"
after = ["raise"]
action = { type = "audio.play", sink = "speaker", asset = "tractor_tip" }

[[flows.tip.nodes]]
id = "wake"
after = ["raise"]
action = { type = "screen.command", sink = "eye", command = { type = "eye/wake" }, final_state = { mode = "tipping", gaze = { x = -0.25, y = -0.65 } } }

[[flows.tip.nodes]]
id = "reset"
after = ["sound", "wake"]
action = { type = "screen.command", sink = "eye", command = { type = "system/reset" }, final_state = { mode = "sleeping", gaze = { x = 0.0, y = 0.0 } } }
```

This starts sound and eye actions in parallel after the forward limit is
reported; reset waits for audio to finish and the eye command to be accepted.
It does not promise sample-accurate synchronization between network clients.
The motor cue is bounded: reaching its timer without the requested limit is
a failure of `raise`, not success. Physical stop is enforced on the board.

A cue action without `wait_for` completes when queued, preserving the old
fire-and-forget behavior. Set `wait_for` to opt into assembly completion.
`timeout_ms` defaults to 10000, with a maximum of 600000. Failures/timeouts
skip dependent nodes; independent branches continue. No automatic rollback
or motor reversal is attempted. STOP ALL (`stop_all` control or `show:stop`
event) advances the controller generation, cancels pending nodes of previous
runs, and sends its configured stop actions. MQTT boards discard queued work
from older generations before accepting the stop. It also stops active
FX-managed audio; stopped audio nodes fail rather than release their
dependencies as if playback had finished normally.

## Prop and controller state

Optional `[props.*]` sections define named prop states and allowed transitions.
A node opts into one with `transition = "prop.transition"`. Scheduling reserves
the transition but leaves the observed state unchanged; the prop enters its
active state at the execution time and reaches its destination state only after
the action completes successfully. Failure selects the transition's configured
failure state.

Flows use `role = "show"`, `"reset"`, `"stop"`, or the default `"utility"`.
Stateful shows are accepted only from `Ready`. A completed show becomes
`Needs reset`; stop becomes `Halted`; a successful reset becomes `Ready` only
when every prop is in its configured ready state. Direct board-motion controls
invalidate position assumptions and require another reset. The complete state
snapshot, including pending transitions and their execution times, is available
through `/api/status` for the future graph UI.

One wire event may intentionally match multiple flows. Utility flows dispatch
first, then stateful flows. The horn uses this to split one `horn:pushed` packet
into immediate resident audio and a separate `show` request: audio feedback is
not permission-gated, while choreography remains accepted only from Ready.
Trigger `aliases` allow the same choreography to retain an operator/legacy cue
without copying its node graph.

The dashboard has a fixed-height scrolling activity log of the latest 500
events: workflow starts, action state changes, completion/failure details,
and changed assembly reports. Repeated identical input snapshots do not
flood the log. It follows new entries until you scroll back; enable Follow
latest to resume. `/api/status` returns the log, each assembly's most recent
report, and 64 recent/active runs with per-node state. Log/history and active
workflows do not survive an `fx` restart.

## Assembly return status and correlation

Cue v3 keeps the 31-byte cue-name capacity and adds execution time, validity,
and cancellation fields. All MQTT participants must be upgraded together.
Each returned status has its own event
ID for reliable delivery/deduplication. The status name carries the original
command's ID as a 16-digit hexadecimal suffix:

```text
dc:complete:0123456789ABCDEF
dc:limit:fwd:0123456789ABCDEF
step:complete:0123456789ABCDEF
```

`fx` matches the link, source node, original command ID, and expected status.
A stale event, another motor's event, MQTT broker receipt, or transport ACK
cannot satisfy a physical completion dependency. Status names before the
suffix are limited to 14 bytes. A different terminal report (stopped,
replaced, invalid, expired, or another limit) fails the waiting node.

The updated DC firmware reports running/pending, stopped, superseded,
timer completion, jog lease expiry, invalid commands, and configured limits.
Stepper completion means the requested step pulses were generated; it does
not prove the shaft reached a measured position.

Both MQTT and ESP-NOW can carry these statuses. For correlated waits over
ESP-NOW, also flash the updated USB gateway: it preserves the host-supplied
`message_id`. An older gateway still handles ordinary cues, but its generated
command IDs will not match tracked completion waits. Older assembly images
without correlation do not release completion waits; the node times out.

## DC limit inputs

Both MQTT DC builds (`sync-dc-mqtt` and `sync-dc-expansion-mqtt`) use the
same perfboard harness, in both Arduino and PlatformIO:

| Signal | XIAO pin |
| --- | --- |
| R_EN and L_EN, tied together | D9 |
| RPWM | D7 |
| LPWM | D8 |
| Forward limit | D6 |
| Reverse limit | D5 |

Both limit inputs are always configured in these builds, including when a
switch has not yet been installed. They use plain `INPUT` (no internal
pull-up) and are active HIGH, matching the working serial limit-switch test:
each signal has a 10k pull-up to 3V3, a 100 nF capacitor to GND, and a 1k
resistor to the switch's NC contact; COM goes directly to GND. A closed,
unpressed NC circuit reads LOW/clear. A pressed switch or broken/disconnected
switch wire reads HIGH/asserted through the external pull-up. An unwired D5
with its pull-up fitted therefore blocks reverse motion. Fit the external
network on both inputs; a bare, unconnected INPUT pin floats. There is no
arming flag or switch-installation toggle.

The original ESP-NOW wrappers retain their previous wiring and omit limit
inputs. For a different harness, configure the macros before the source
include in the Arduino wrapper, or pass them as compiler defines:

```cpp
#define DC_LIMIT_FWD_PIN /* verified GPIO or D-pin */
#define DC_LIMIT_REV_PIN /* verified GPIO or D-pin */
#define DC_LIMIT_ACTIVE_LEVEL HIGH
#define DC_LIMIT_INPUT_MODE INPUT
```

Enabled inputs cannot overlap the configured motor
outputs. The selected level must match the actual switch circuit. An asserted limit blocks motion toward that limit and
stops it locally, including a queued reversal. Motion away is allowed. The
assertion is acted on immediately; inputs are not debounced or calibrated.
Verify wiring, polarity, and noise behavior with motor power disconnected.

Configured inputs return an uncorrelated `dc:limits:XY` snapshot every second:
X is forward and Y is reverse; `1` means asserted, `0` clear, and `-` disabled.
`dc:status` requests a snapshot without commanding motion. MQTT builds default
idle status to coordinator `020000000001`; override `CUE_STATUS_TARGET_NODE`
if that changes. ESP-NOW reports to the most recent commanding coordinator.
These inputs report switch levels, not continuous physical position.

## Isolated end-to-end verification

`sync/shows/orchestration-smoke.toml` uses port 18080, MQTT topic prefix
`halloween-smoke`, a separate coordinator/client ID, and a fake motor node.
It can run beside the production show. No real motor subscribes to that prefix.
Run it with a separate registry so test devices cannot enter the production
inventory:
`FX_DISPLAY_REGISTRY=/tmp/fx-smoke-displays.json fx run --config sync/shows/orchestration-smoke.toml --no-kiosk`.

With the smoke coordinator and Mosquitto reachable, run from the laptop:

```sh
node tractor-eye/scripts/verify-orchestration.mjs http://PI_ADDRESS:18080 BROKER_ADDRESS BROKER_PORT
```

The script opens two WebSocket clients, emulates a motor, verifies that neither
a transport ACK nor a stale limit status releases the workflow, then sends the
matching limit status and verifies parallel display branches and a dependency
join. For a loopback-only broker, use an SSH local port forward for the broker
connection; no broker firewall exposure is required.

`node tractor-eye/scripts/verify-display-devices.mjs http://PI_ADDRESS:18080`
checks automatic registration, identical-UA/different-ID devices, independently
controlled tabs, group acknowledgment after private actions, and Forget.
Use `--retain` to leave its two offline records for a server-restart persistence
check, then delete those records through `/api/displays/{id}`.
