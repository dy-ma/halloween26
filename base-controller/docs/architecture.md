# Controller architecture and design decisions

This board controls the stationary chain-driven mechanism for a moving Halloween tractor/cart prop. It receives wireless commands, produces step/direction signals for an external stepper driver, reads two end-of-travel switches, and provides accessible debugging and spare I/O.

The aim is a board that is understandable, easy to move as one assembly, and practical to diagnose and replace. Dylan is building the schematic and PCB in KiCad as a learning project. Expected first batch: roughly 5–10 boards, with one working mechanism initially required.

**Status: two-layer routing draft complete; not ready for manufacture.** All PCB nets are connected. Saved-board DRC reports zero errors/warnings and zero unconnected items after updating U3’s thermal vias to 0.30 mm drills with 0.60 mm pads in a project-local footprint. The current outline is 92 × 69 mm. See [routing notes and front/back previews](interconnect-routing-notes.md) for power paths, ground pours and remaining review. Checks on 2026-09-20 also report zero ERC issues and zero schematic/PCB mismatches; PCB performance and protection have not been verified on hardware.

- [Current parts list and footprints](parts-list.md)
- [Non-PCB recommendations: supplies, inline fuse and pigtail connectors](non-pcb-components.md)
- [Electrical decisions and remaining power work](electrical-decisions.md)
- [Historical schematic cleanup notes](history/schematic-review-notes.md)
- [KiCad library registration and provenance](../libraries/README.md)
- [Earlier sourcing research](parts-sourcing.md), including superseded options and dated stock snapshots
- KiCad project: [base-controller](../base-controller.kicad_pro)

The board README and parts list describe the current direction. The original pasted brief and older sourcing notes contain earlier S3, CAN, external-converter and connector proposals; those are not the current design.

## System architecture

```text
Wireless trigger / other prop controllers
                    |
                 ESP-NOW
                    |
          XIAO ESP32-C6 on this PCB
             |               |
        STEP/DIR/ENA     Two wired limits
             |
       NPN output interface
             |
       External DM542-class driver
             |
         Stepper motor
             |
   Reduction / chain / sprockets / moving prop
```

The mechanics and exact motor/driver/supply purchases are still open. The supplied motor drawing describes a STEPPERONLINE **23HS30-2804S**, 2.8 A per phase, 1.89 N·m holding torque. This is a candidate, not a measured requirement for the final mechanism. Holding torque alone does not establish torque at the intended speed.

Audio is separate: the discussed architecture is a Raspberry Pi audio controller, with an ESP connected over USB for wireless messages, and commodity speakers. No audio amplifier, speaker power stage, Raspberry Pi carrier, or CAN transceiver belongs on this PCB. Bluetooth speaker routing is a separate software/prototyping task, not validated by this board design.

## Power architecture

Power arrangement (the inline holder is recommended in the [non-PCB shortlist](non-pcb-components.md); final fuse amperage remains open):

```text
Regulated 24 V DC supply
    |
Replaceable inline fuse near the supply
    |
J1: 24V_IN, GND
    +---- J7: MOTOR_24V_OUT, GND ---- external driver power
    |
    +---- U3 eFuse ---- 24V_PROTECTED ---- U2 buck ---- +5V
                                                     +---- driver control optocouplers
                                                     |
                                                     +---- D1 ---- J6 ---- XIAO VBUS
                                                                            |
                                                               XIAO onboard 3.3 V supply
```

J7 shares the **24V_IN** net, not **24V_PROTECTED**. Input and motor-return paths need generous copper, with the logic supply branching near the input. The high motor current must not flow through thin logic-ground connections. Net names are functional: `24V_PROTECTED` specifically means the output of U3, not that every other conductor lacks upstream protection.

The working design envelope is **24 V nominal**, a **5 A-class regulated supply**, and a PCB power path to be designed and checked for **5 A continuous**. That is a layout target, not a present board rating. A bigger or 48 V supply is not a drop-in upgrade; review the input protection, connector/contact derating and copper first. The final fuse rating remains selectable without changing the PCB.

### Why put conversion on the board?

The priority is making the assembly easy to handle. Loose modules joined by branching cables become awkward to move and mount. The board consolidates the low-voltage supply and signal wiring while leaving the demanding motor power stage in a replaceable external driver.

A TRACO module was considered for simplicity. We moved to a **TI LMR51420XDDCR** buck plus standard passives for cost and sourcing flexibility. The tradeoff is real: this converter needs careful placement, switching-loop layout and hardware testing. Its design follows the [TI application circuit and layout guidance](https://www.ti.com/lit/ds/symlink/lmr51420.pdf).

U2 is a 2 A-class converter with a nominal output near 5 V; R1/R2 set the voltage. L1 and the output capacitors smooth the switching waveform. C6 is a bootstrap capacitor between CB and SW, not a capacitor to ground. C1/C2/C5 provide local input bypassing; C7 is the bulk input capacitor. Two 22 µF output capacitors give 44 µF nominal, but effective ceramic capacitance still needs a DC-bias check. A 2 A chip rating does not establish the finished board's thermal or accessory-current rating.

### Why the eFuse?

U3 is a TPS26600 with settings intended for roughly 1.02 A on the **24 V logic branch**, undervoltage turn-on near 18.2 V, and overvoltage cutoff near 30.3 V. These are nominal design calculations, with tolerances and startup behavior still to verify. This is not a 1 A limit on the 5 V output: a buck converts power between different voltages.

The eFuse provides configurable protection and controlled startup for the converter/ESP branch. Its `EFUSE_RTN` net is deliberately separate from system `GND`; do not join them merely to simplify routing. The fault output has a test pad rather than using another ESP pin. Its pullup is to protected 24 V, so **TP1 is not a 3.3 V logic test point**. See the [TI datasheet](https://www.ti.com/lit/ds/symlink/tps2660.pdf) and [power decisions](electrical-decisions.md).

## Controller and communications

Selected module: **Seeed XIAO ESP32-C6, SKU 113991254, JLC C27675191**. The dev board supplies USB-C, the ESP32-C6 circuitry and its own 3.3 V supply, reducing the custom design work. A bare-module carrier may be a later learning exercise; it is not part of this revision.

ESP-NOW is the initial communication plan. MQTT is an application/networking choice that would also require Wi-Fi/network infrastructure; no separate MQTT chip is needed. Future mesh experiments are software/SDK projects, not a promised drop-in replacement for ESP-NOW. Keep the antenna clear of copper and the driver/enclosure metal according to the module guidance. Keep USB accessible in the finished enclosure.

See [Seeed's board documentation](https://wiki.seeedstudio.com/xiao_esp32c6_getting_started/) and the [official KiCad source library](https://github.com/Seeed-Studio/OPL_Kicad_Library/tree/master/Seeed%20Studio%20XIAO%20Series%20Library). The imported symbol marks pins passive, which limits what ERC can infer.

## Motor interface

J2 carries three pairs: PUL+/PUL−, DIR+/DIR− and ENA+/ENA−. The positive sides connect to the buck's +5V rail **before D1**. Q1–Q3 sink the negative sides, driven through 1 kΩ base resistors with 10 kΩ pulldowns. This gives the ESP a low-current 3.3 V control interface to the driver's 5 V optical inputs.

This topology matches the documented common-anode/open-collector connection for [STEPPERONLINE DM542T V4.0](https://omc-stepperonline.com/download/DM542T_V4.0.pdf). That is a documented candidate, not a purchase decision or proof that the earlier EASON clone is identical. See [the interface contract](electrical-decisions.md#driver-interface-contract) before buying.

No motor winding current passes through J2. The external driver handles winding-current regulation and high-current switching. The software `ENABLE` name does not establish physical polarity: on the documented candidate, energizing the ENA optocoupler disables the drive. The input must not be treated as an emergency stop or a guarantee of power-off when the ESP resets.

## Limit switches, button and spare I/O

Two wired contact inputs provide repeatable endpoints and a way to detect travel independent of commanded step count. A stepper can miss steps, and its initial position is not known merely because a number of pulses was sent. Switch/tab placement on the chain or mechanism is still a mechanical decision.

Each limit input uses a 1 kΩ series resistor, a 10 kΩ pullup to 3.3 V, a 100 nF filter capacitor, and BAT54S rail clamps. The extra components address noise and modest excursions from cables near the motor. They do not turn these into arbitrary 24 V sensor inputs or certified surge-protected industrial I/O. Switches connect signal to GND. Firmware still needs debounce, travel timeout, limit plausibility checks and defined fault handling. Normally-open versus normally-closed operation remains to be selected with the actual switches.

**Keep SW1 and R18.** SW1 is a firmware-readable button on D5, with a 10 kΩ pullup. Its final action is a firmware decision. Test pads are additional measurement access and do not replace the button or consume GPIO.

| XIAO label | Module pad | Function |
|---|---:|---|
| D0 | 1 | STEP |
| D1 | 2 | DIR |
| D2 | 3 | ENABLE |
| D3 | 4 | LIMIT_A |
| D4 | 5 | LIMIT_B |
| D5 | 6 | DEBUG_BTN |
| D6–D10 | 7–11 | Spare GPIO on J5 |

Module pad numbers above are not ESP chip GPIO numbers. J5 is a local unprotected 3.3 V expansion header; its pins are not 5 V tolerant power/sensor inputs.

## Connector decisions and pinouts

XH was selected for signal cables because both sizes have good JLC availability and exact installed KiCad footprints. The right-angle version routes the plugs sideways at the board edge. XH uses friction retention; support the harness so cable movement does not pull on it. The existing kit still needs to be identified/test-fitted. Genuine XH pitch is 2.50 mm. Cable plugs are XHP-6 and XHP-2 with appropriate SXH contacts.

GH offered a positive latch but the checked two-pin part had too little stock. PA had adequate stock but required imported/adapted footprints. Those unused PA library files are retained for provenance, not selected for assembly. Micro-Fit remains the power connector family; spare I/O stays on a flexible 2.54 mm pin header.

| Connector | Pins, in numbered order | Status |
|---|---|---|
| J1 | 1: 24V_IN; 2: GND | Existing vertical Micro-Fit |
| J2 | 1: +5V/PUL+; 2: PUL−; 3: +5V/DIR+; 4: DIR−; 5: +5V/ENA+; 6: ENA− | Existing right-angle 6-pin XH |
| J3 | 1: limit A cable signal, before R15; 2: GND | Existing right-angle 2-pin XH |
| J4 | 1: limit B cable signal, before R16; 2: GND | Existing right-angle 2-pin XH |
| J5 | 1: GND; 2: +3V3; 3–7: IO_D6–IO_D10; 8: GND | Existing 8-pin header |
| J7 | 1: 24V_IN; 2: GND | Existing motor power output; same part as J1 |
| J6 | 1: D1 cathode; 2: XIAO VBUS | Existing removable power-jumper header |

All pin numbers must be checked from the connector's mating view when building cables. Rotation in the schematic is not permission to reorder electrical pin numbers.

## Debug access

| Test point | Net / purpose |
|---|---|
| TP1 | U3 FLT, pulled up to protected 24 V |
| TP2, TP3 | GND, two convenient reference locations |
| TP4 | 24V_IN |
| TP5 | 24V_PROTECTED |
| TP6 | +5V, converter side of D1 |
| TP7 | +3V3 |
| TP8 | STEP |
| TP9 | DIR |
| TP10 | ENABLE |
| TP11, TP12 | LIMIT_A, LIMIT_B at the filtered MCU side |

Use `Connector:TestPoint` and `TestPoint:TestPoint_Pad_D2.0mm`. Bare pads are excluded from the assembly BOM but included on the PCB. One pad anywhere on a net gives access to that net; components such as resistors and diodes separate different nets. Place pads where probes can reach, preferably near the relevant circuit with nearby GND. Avoid long branches off switching nodes. No dedicated SW-node pad is planned.

## Verification and manufacture

Initial schematic, placement, routing, mounting holes, and silkscreen are complete. Final review and hardware testing are still required. The current checklist and check results are maintained in [verification.md](verification.md), and the export/release procedure is in [releases.md](releases.md).

The board is not a complete machinery safety system. Stopping pulses, releasing motor holding torque and mechanically preventing a fall can be different actions; settle the actual stop behavior with the mechanism rather than assuming ENA handles all of them.
