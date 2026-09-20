# Power and driver review

Reviewed 2026-09-19. These are recommended next design steps, not changes already made to the KiCad schematic. No supply or driver has been purchased or finalized. The objective is to define compatible hardware now without pretending that unknown mechanical load can be calculated from a motor's holding-torque label.

## 1. Supply and current envelope

Use **regulated 24 V DC**. A reputable **5 A / 120 W-class enclosed adapter** is a reasonable candidate for one driver plus logic. [Mean Well GST120A24](https://www.meanwell.com/Upload/PDF/GST120A/GST120A-SPEC.PDF) is a documented example; it is not yet selected or purchased. Its protection is hiccup-mode overload at 105–160% of rated output power, so “5 A supply” is not a precise instantaneous 5 A clamp. At nominal voltage, that published range corresponds to roughly 5.25–8 A.

The earlier Amazon candidates were a listed 24 V/6 A brick, a listed 24 V/6.5 A LED supply, and a listed 24 V/10 A supply. Their marketing descriptions do not provide enough protection/timing detail to coordinate the PCB around them. Do not silently treat all three as interchangeable.

**PCB design target:** a 5 A continuous path from J1 to J7, including both positive and return conductors. Wire harness starting point: short 18 AWG copper power leads with compatible contacts. Trace width/copper weight, contact derating, fuse clearing energy and enclosure temperature must still be checked against the actual layout. No arbitrary 5 A fuse installation grants a 5 A board rating. The [Molex header page](https://www.molex.com/en-us/products/part-detail/436500215) lists 8.5 A maximum per contact, but the complete mated connector and wire/temperature conditions govern the usable rating.

The supplied 23HS30-2804S drawing specifies 2.8 A per winding, not 2.8 A drawn from the 24 V supply. The driver's switching conversion, speed, acceleration and load determine input current. It is therefore reasonable to select a supply later within the agreed voltage/current envelope. A need for greater speed, torque, bus voltage or total current can force a redesign; that uncertainty is mechanical, not solved by adding a larger fuse.

## 2. One upstream fuse, not another eFuse circuit

Recommended topology:

```text
PSU +24 V -> replaceable inline fuse -> J1 pin 1 / 24V_IN
                                      +-> J7 pin 1 -> driver +V
                                      +-> U3 logic eFuse -> buck
PSU return -------------------------> J1 pin 2 / GND -> J7 pin 2
```

One appropriately coordinated upstream fuse can protect the input lead and board distribution; a second motor-branch fuse is not intrinsically required when that entire pass-through path has adequate capacity. U3 remains the more restrictive protection for the converter branch. This proposal avoids another IC circuit and avoids depending solely on an unspecified PSU's short-circuit behavior.

Put the replaceable holder near the supply in the positive DC lead and secure it within the assembly/harness. A MINI blade format is a practical option; choose a reputable holder and fuse with a suitable **DC** voltage and interrupt rating. [Littelfuse 297](https://www.littelfuse.com/assetdocs/littelfuse-datasheet-297-mini32v?assetguid=42c9dd21-a88e-4328-8e67-2f832444faf1) is an example 32 V family for a bounded 24 V system. Fuse voltage rating also needs to cover the actual maximum bus voltage; regenerative voltage rise must be assessed before choosing a 32 V part.

**Do not finalize fuse amperage yet.** A 3 A fuse is a candidate for initial evaluation, not an approved operating rating. Select the time-current characteristic using normal current, driver capacitor inrush, ambient temperature, supply fault behavior and wire/copper withstand. A fuse can carry more than its marked current for a while, and a hiccup supply may prevent it from blowing promptly. Both the sustained limited fault and the clearing event must be tolerable. Follow the [Littelfuse selection guide](https://www.littelfuse.com/assetdocs/fuseology-selection-guide?assetguid=fa4aa360-f6c4-4eec-88a6-3d7ec3fe57d5).

This is why choosing a replaceable external holder now leaves room to size the fuse later without respinning the board. The currently investigated PCB holders, Keystone 3568 (C5249699) and 3568-20 (C3206956), both had **zero JLC stock** during this review; neither is being recommended as a stocked assembly part. A Littelfuse 0FHM0003ZXJB inline holder is now recommended in the [non-PCB shortlist](non-pcb-components.md); nothing has been purchased, and final fuse amperage remains open.

J7 now duplicates J1's part and footprint: Molex 436500215, [C293740](https://jlcpcb.com/partdetail/MOLEX-436500215/C293740), `Connector_Molex:Molex_Micro-Fit_3.0_43650-0215_1x02_P3.00mm_Vertical`. This is the placed vertical power output; right-angle XH selection applies to the signal connectors only. Label IN and MOTOR OUT clearly.

This direct motor branch does not inherit U3's reverse-polarity or overvoltage protection. Verify harness polarity before power-up. A fuse is not a voltage clamp or a brake. With a back-driven or descending mechanism, measure the DC bus during deceleration; a supply that delivers current need not absorb returned energy. If that raises the bus beyond component ratings, change the deceleration/mechanics or add a properly sized regenerative-energy solution. Do not pick a small TVS and assume it can dissipate sustained mechanical energy.

## 3. USB power: the actual issue and simple resolution

In [Seeed's XIAO ESP32-C6 v1.0 schematic](https://files.seeedstudio.com/wiki/SeeedStudio-XIAO-ESP32C6/XIAO_ESP32_C6_v1.0_SCH_260114.pdf), the power sheet connects USB-C VBUS directly to module pad 14, also named VBUS. The onboard diode is downstream of that node. It therefore does **not** isolate external power applied at pad 14 from USB-C VBUS.

Our D1 conducts from the carrier's buck +5V into pad 14. It blocks USB power flowing backward to the carrier converter. It does not block externally supplied current flowing from pad 14 toward the USB host. A forward diode drop is not a guaranteed source-priority circuit.

**Implemented in the saved schematic:** J6 is a removable two-pin power-link header in series between D1's cathode and XIAO pad 14. Its connections were checked on 2026-09-19; the shunt is a separate assembly item:

```text
buck +5V -> D1 anode -> D1 cathode -> J6 -> XIAO VBUS (pad 14)
```

Use a physical jumper, not a solder bridge: XFCN PZ254V-11-02P, [C492401](https://jlcpcb.com/partdetail/PZ254V-11-02P/C492401), footprint `Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical`. JLC showed 1,223,568 available to order at $0.0183 at 1+ during this review. The removable 2.54 mm shunt is a separate harness/assembly item, not included with the header. Check the header and shunt's current ratings for the XIAO feed. Use `Jumper:Jumper_2_Open` or an equivalent explicit two-pin symbol; assignment does not imply an electronically controlled switch.

| Mode | J6 | USB | Behavior |
|---|---|---|---|
| Normal prop operation | Fitted | Disconnected | Buck powers XIAO through D1 |
| USB programming, 24 V absent | Either | Connected | USB powers XIAO; carrier buck/driver signals' +5V rail stays off |
| USB debugging with 24 V present | Removed | Connected | USB powers XIAO; buck separately powers driver signal +5V; grounds remain common |

Mark **REMOVE FOR USB + 24V** beside J6. With 24 V absent, D1 blocks USB backfeed toward the buck, so the shunt may stay fitted for USB-only use. Disconnect sources before changing the shunt; do not hot-swap power modes around a moving mechanism. Ordinary USB with J6 fitted and external power on remains an invalid configuration. This is a manual selection solution, not automatic foolproof power arbitration. If simultaneous plug-and-play power becomes a requirement, revisit the power entry arrangement rather than adding a mux upstream of two sources already joined on the XIAO.

No new regulator or conversion redesign is needed for this proposal. No battery is planned.

## Driver interface contract

Use a documented driver supporting 24 V motor supply and **5 V common-anode opto inputs**, with each negative input sinkable by the existing NPN stage. A concrete compatible-topology candidate is [STEPPERONLINE DM542T V4.0](https://omc-stepperonline.com/download/DM542T_V4.0.pdf), whose manual specifies 7–16 mA input current and a 5 V/24 V selector. Set that selector to **5 V**. This is not verification of the EASON DM542 clone.

Keep Q1–Q3, their 1 kΩ series base resistors and 10 kΩ pulldowns. Nominal base drive is approximately (3.3−0.8)/1000 minus 0.8/10000 = 2.42 mA, giving reasonable margin for a 16 mA sink at nominal conditions. Validate low-state voltage and pulse edges with the purchased driver; this calculation is not a worst-case transistor/timing qualification.

For the documented candidate, use at least 2.5 µs pulse width and 5 µs DIR setup; firmware can start conservatively at 10 µs. Follow its enable sequencing, including the stated 200 ms enable time. ENA optical current means **disabled**: an ESP high turns Q3 on and disables that driver. ESP reset/power loss turns Q3 off and can leave the driver enabled. Keep STEP quiet at startup; do not call ENA a fail-safe stop.

The chosen driver must be checked against this contract before ordering it. If its manual matches, model selection need not change the PCB. The external driver’s motor-current settings must distinguish peak and RMS values.

## What changes on the PCB next?

1. **J7 is placed** on 24V_IN/GND and **J6 is placed** between D1 cathode and XIAO VBUS; their net connections have been checked.
2. Plan J6 shunt access and its operating-mode label.
3. Add the planned mounting holes and finish existing schematic cleanup.

The inline fuse is part of the power harness. No second eFuse circuit is proposed. Remaining load-dependent fuse/thermal/regeneration tests are explicit bring-up requirements, not claims of completed protection coordination.
