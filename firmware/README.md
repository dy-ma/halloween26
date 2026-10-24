# Cue firmware

This directory contains the embedded Cue protocol and the applications flashed
onto individual prop controllers. A cue is a small command-like event such as
`tractor:tipped` or `horn:pushed`.

## Reliability model

Cue v2 uses addressed ESP-NOW unicast rather than repeated broadcast packets.
Every cue has a source, destination, session-scoped ID, and name. The transport:

1. sends the cue immediately;
2. waits for an application-level ACK from the destination;
3. retries the same ID with bounded exponential backoff if the ACK is lost;
4. reports either `DELIVERED` or `TIMED_OUT` to the sender; and
5. ACKs duplicate packets but exposes the cue to application code only once.

The default schedule makes five attempts. It waits about 70 ms after the first
attempt, then 140 ms, then at most 240 ms between subsequent attempts, with a
small random jitter. A healthy link therefore remains nearly immediate, while a
temporarily obstructed link gets roughly one second to recover.

An ACK means the destination accepted the cue into its application queue. A
physical controller that needs to confirm an action finished should still send
a separate completion/failure result. Motor limit switches, watchdogs, and
local fail-safe behavior remain the controller's responsibility.

Delivery reports expose:

- attempts used and end-to-end ACK latency;
- `remote_rssi`, measured when the destination received the cue; and
- `ack_rssi`, measured when the sender received the ACK.

The transport never reports success if its destination-side application queue
was full. In that case it withholds the ACK so the sender can retry.

ESP32-S3 long-range mode is enabled by default. All boards must use the same
mode and channel.

## Multiple effects

One source may have several unicast cues pending simultaneously. For a scene,
the coordinator can send one cue to each participating controller and collect
their independent delivery reports like a wait group. It should not block an
immediate local effect such as the horn while waiting for remote props: play
the horn locally, dispatch the other cues, and report any remote timeout.

This avoids an all-or-nothing distributed barrier in the latency-sensitive
path. Tighter choreography can later add a scene/correlation ID and a future
execution timestamp without changing the ACK/retry mechanism.

Peer discovery HELLO packets carry the board's service name when one is set in
`EspNowTransport::Config`. Applications can enumerate the discovered node ID,
service, last-seen time, and RSSI with `peerAt()`. Production commands should
still use explicit intended peer IDs so adding another powered board cannot
change the chosen recipient.

## Structure

```text
firmware/
├── lib/cue-core/             addressed messages, IDs, wire format, dedupe
├── lib/cue-transport/        non-blocking receive and delivery contracts
├── lib/cue-espnow/           peers, ACKs, retries, RSSI, discovery, LR mode
├── lib/cue-mqtt/             Wi-Fi/MQTT adapter, ACKs, retries, presence
├── src/reliable_button_test.cpp
├── src/button_node.cpp
├── src/pi_gateway.cpp
├── src/espnow_range_*.cpp
└── arduino/                  Arduino IDE/CLI entry-point wrappers
```

ESP-NOW callbacks only copy frames into a fixed queue. Application code,
decoding, ACK generation, retries, and delivery reporting happen from `poll()`.
No transport method blocks, and each poll performs a bounded amount of work.

## Symmetric two-board test

Flash the same `reliable-button-test` sketch onto both XIAO ESP32-S3 boards.
The boards discover one another through a periodic HELLO, then all button cues
use acknowledged unicast.

- Press BOOT on either board.
- The opposite board's yellow user LED stays on for one second when it accepts
  the cue.
- The sender flashes for 100 ms after the ACK.
- Three flashes mean no peer was available or delivery timed out.
- Serial output shows `attempts`, `latency_ms`, `remote_rssi`, and `ack_rssi`.

Use Arduino-ESP32 3.x for real ESP-NOW RSSI metadata. From the repository root:

```sh
arduino-cli compile --upload -p /dev/cu.usbmodemBOARD \
  --fqbn 'esp32:esp32:XIAO_ESP32S3' \
  --libraries firmware/lib \
  firmware/arduino/reliable-button-test
```

Wait until Serial Monitor reports `PEER ... ready for button presses` before
the first test. Example healthy delivery output:

```text
SEND id=89ABCDEF:1 destination=90AABBCCDDEE
DELIVERED id=89ABCDEF:1 destination=90AABBCCDDEE attempts=1 latency_ms=5 remote_rssi=-61 ack_rssi=-59
```

If the first transmission is lost but a retry succeeds, `attempts` will be
greater than one. `TIMEOUT` means all five attempts failed.

## Pi gateway

The gateway remains bidirectional. A received radio cue is emitted as JSON:

```json
{"event":"tractor:tipped","sequence":123,"source":"AABBCCDDEEFF","rssi":-67}
```

The host may submit:

```json
{"type":"emit","request":42,"event":"tractor:stepper:stroke"}
```

For now the gateway targets the most recently seen discovery peer. It emits a
later `delivery` object containing the acknowledged/timed-out result. Production
scene routing should provide an explicit destination or named peer map.

## Raw range test

The range sender and receiver still use one over-the-air attempt per sequence,
so they measure the raw link rather than the hardened five-attempt behavior.
They now discover each other and use unicast; allow about one second for peer
discovery before collecting results.

## Host test

The core wire protocol contains no Arduino dependencies:

```sh
c++ -std=c++17 -Wall -Wextra -Werror \
  -Ifirmware/lib/cue-core/src \
  firmware/lib/cue-core/src/Cue.cpp firmware/test/test_cue.cpp \
  -o /tmp/cue-core-test
/tmp/cue-core-test
```

## Wired transports

A future CAN or RS-485 adapter can implement the same transport contract while
preserving addressed Cue IDs, duplicate safety, and delivery reports. Radio
delivery is not a substitute for local safety logic or a wired emergency stop.
