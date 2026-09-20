# Motor controller parts sourcing

For the consolidated current architecture and planning BOM, use [README.md](../README.md), [parts-list.md](parts-list.md), and [electrical-decisions.md](electrical-decisions.md). Older sections below preserve sourcing history and may describe superseded choices. Stock values are dated snapshots.

## Current connector and debug decisions — supersedes shortlist below

- User selected JST XH for J2/J3/J4, superseding the earlier PA and GH choices. XH has friction retention; secure external cable bundles against pulling on the connectors. The user's existing kit has not yet been verified as matching XH.
- J2: manufacturer JST, MPN `S6B-XH-A(LF)(SN)`, LCSC `C157919`, footprint `Connector_JST:JST_XH_S6B-XH-A_1x06_P2.50mm_Horizontal`. Live JLC stock checked 2026-09-19: 22,492 available to order, $0.1720 at 1+. https://jlcpcb.com/partdetail/JST-S6B_XH_A_LF_SN/C157919
- J3/J4: manufacturer JST, MPN `S2B-XH-A(LF)(SN)`, LCSC `C157931`, footprint `Connector_JST:JST_XH_S2B-XH-A_1x02_P2.50mm_Horizontal`. Live JLC stock checked 2026-09-19: 16,199 available to order, $0.0821 at 1+. https://jlcpcb.com/partdetail/JST-S2B_XH_A_LF_SN/C157931
- Both exact XH footprints are present in the installed KiCad library. These are right-angle through-hole headers with 2.50 mm pitch. Matching cable housings are XHP-6 and XHP-2 with SXH contacts selected for wire size. Existing generic symbols, net assignments and functional Value fields stay the same. The saved schematic has these assignments.
- Previously prepared PA footprints remain in `base-controller/libraries/Halloween.pretty` as unused alternatives; no need to assign them for the XH design.
- J1 remains the Molex Micro-Fit listed below. J5 remains the 8-pin 2.54 mm header below.
- User clarified: KEEP SW1/R18 and DEBUG_BTN on D5, and add test pads independently. J5 pin 8 stays GND. The earlier proposal to remove the button and repurpose D5 is cancelled.

Saved schematic checked after test-point additions: J2/J3/J4 have the correct horizontal XH MPNs, LCSC numbers and footprints. J1/J5 also match. TP1–TP12 are present; TP10 now correctly uses ENABLE. TP2–TP12 need footprints; all bare test pads need BOM exclusion. SW1/R18 are intentionally retained. Separate motor power output J6 and proposed USB power jumper JP1 are still absent. See schematic-review-notes.md for the next-session checklist and electrical-decisions.md for their rationale.

## Debug, spare I/O and connector shortlist — 2026-09-19

Proposed additions for the user to place; no schematic edits made by the assistant. Stock is not reserved. Connector counts below were checked on the live JLC browser detail pages, rather than LCSC's separate inventory. Exact mechanical drawing/land-pattern checks remain before PCB release.

### Debug button and spare header

- SW1: `Switch:SW_Push`; XUNPU TS-1088-AR02016, C720477. Footprint `Button_Switch_SMD:SW_SPST_TS-1088-xR020` is installed and explicitly references this manufacturer's datasheet in its description. JLC web page reports Basic, 742,278 orderable, $0.0556 at 1+. https://jlcpcb.com/partdetail/TS-1088-AR02016/C720477
- R18 (expected next reference): copy an existing 10k resistor, UNI-ROYAL 0603WAF1002T5E, C25804, `Resistor_SMD:R_0603_1608Metric`.
- Wiring: +3V3 → R18 → DEBUG_BTN junction → SW1 → GND. DEBUG_BTN connects to U1 D5, physical pin 6. This is a software input, with software debounce; its action will be chosen in firmware. It is not a power cutoff.
- Spare connector: `Connector_Generic:Conn_01x08`, value SPARE_IO, XFCN PZ254V-11-08P, C492407. Footprint candidate `Connector_PinHeader_2.54mm:PinHeader_1x08_P2.54mm_Vertical`. Live 347,294 orderable (352,190 total), $0.0479 at 1+. Through-hole/wave soldering. https://jlcpcb.com/partdetail/Xfcn-PZ254V_1108P/C492407
- Proposed header pinout: 1 GND; 2 +3V3; 3 D6 (U1 pad7); 4 D7 (pad8); 5 D8 (pad9); 6 D9 (pad10); 7 D10 (pad11); 8 GND. Use matching local labels IO_D6 through IO_D10 at MCU and header. All GPIO are 3.3V signals; this is a direct local expansion header, without the long-cable input protection used for the limits. Keep spare +5V on a separate connector to avoid presenting it as a GPIO voltage.
- Add flat test points on GND, 24V_IN, 24V_PROTECTED, +5V and +3V3: `Connector:TestPoint`, `TestPoint:TestPoint_Pad_D2.0mm`. Exclude bare-pad test points from BOM (no purchased component). Existing TP1 is eFuse FLT at nominal 24V, not a 3.3V signal. Firmware/debug serial uses existing USB; spare D6/D7 can also be UART if needed.

### External connector choices

| Function | Candidate | JLC | Orderable now | 1+ USD | Footprint status |
|---|---|---|---:|---:|---|
| J1 24V input; proposed separate 24V motor output | Molex 436500215, 2-pin Micro-Fit 3.0, vertical through-hole | C293740 | 2,650 | 0.6104 | Installed: `Connector_Molex:Molex_Micro-Fit_3.0_43650-0215_1x02_P3.00mm_Vertical` |
| J2 six motor control signals | JST SM06B-GHS-TB(LF)(SN), 6-pin GH, right-angle SMD | C133065 | 15,669 | 0.2945 | Installed: `Connector_JST:JST_GH_SM06B-GHS-TB_1x06-1MP_P1.25mm_Horizontal` |
| J3/J4 limit switches | JST B02B-PASK(LF)(SN), 2-pin PA, vertical through-hole | C158050 | 1,219 | 0.1148 | No exact installed KiCad PA footprint found; import/create and check before assigning. Do not substitute a PH footprint just because pitch is also 2mm. |

- Power: https://jlcpcb.com/partdetail/MOLEX-436500215/C293740 . JLC identifies Wave Soldering. Suitable family candidate; allowable system current must still be established from wire/contact/temperature derating, actual PSU and motor demand. Do not treat its headline rating as the finished board's current rating. Motor output branch protection and USB power-path review remain unfinished.
- Signals: https://jlcpcb.com/partdetail/JST-SM06B_GHS_TB_LF_SN/C133065 . GH has a positive latch; matching cable housing GHR-06V-S. Manufacturer: https://www.jst-mfg.com/product/pdf/eng/eGH.pdf . Buy assembled/precrimped leads rather than assuming any 1.25mm cable fits.
- Limits: https://jlcpcb.com/partdetail/JST-B02B_PASK_LF_SN/C158050 . PA has a positive latch; matching housing PAP-02V-S and SPHD contacts appropriate to wire size. Manufacturer combinations: https://www.jst-mfg.com/product/pdf/eng/ePA-F.pdf . Precrimped cables still need specific sourcing.
- Rejected for stock: GH 2-pin right-angle C189893 had only 4 orderable (19 total), and GH 2-pin vertical C161690 only 1 total. Avoid recommending those for the 5–10-board batch on the basis of old LCSC search-result stock.

Latest saved netlist before these additions: both LIMIT_A (U1 D3/pad4) and LIMIT_B (D4/pad5) have independent 1k series resistance, 10k pullup, 100n shunt to GND, BAT54S rail clamps. +3V3 reaches U1 pad12. C9 is now the first limit filter capacitor, replacing the deleted old C9 reference; C10 is correctly 22n. Both eFuse SHDN and IMON have no-connect markers.

Checked JLCPCB's live browser listings on 2026-09-18 (Pacific). Stock is a snapshot, not reserved. Prices below are USD at the displayed 1+ tier, excluding PCB, assembly/setup fees, attrition, shipping and tax. Search-result stock is total stock; the regulator detail page separately reports orderable quantity.

## Confirmed MCU choice

Seeed XIAO ESP32-C6, manufacturer SKU **113991254**, JLC **C27675191**. User selected this board. https://jlcpcb.com/partdetail/Seeed-113991254/C27675191

## Proposed 24 V to 5 V converter core

This is a stocked sourcing shortlist, not a released or tested circuit. Intended output capability is 2 A, subject to layout and thermal verification. Final capacitor count requires effective-capacitance/DC-bias and transient checks.

### Controller-branch eFuse and setting resistors

Selected TPS26600PWPR (TI), JLC C544399, for the controller's 24 V branch, upstream of the buck. The motor power branch does not pass through this eFuse. Live check 2026-09-19: 4,864 available to order, Extended. https://jlcpcb.com/partdetail/TexasInstruments-TPS26600PWPR/C544399

Four setting resistors selected 2026-09-19. All are 1%, 100 mW, 75 V, imperial 0603; symbol `Device:R`, footprint `Resistor_SMD:R_0603_1608Metric`. References below are intended next references, not edits to the user's schematic.

| Ref | Value | Manufacturer | MPN | JLC/LCSC | Live stock snapshot |
|---|---|---|---|---|---|
| R3 | 715k | YAGEO | RC0603FR-07715KL | C137685 | 14,283 orderable |
| R4 | 20k | UNI-ROYAL | 0603WAF2002T5E | C4184 | 6,091,724 orderable |
| R5 | 30k1 | UNI-ROYAL | 0603WAF3012T5E | C23000 | 63,905 orderable |
| R6 | 11k8 | UNI-ROYAL | 0603WAF1182T5E | C22861 | 176,327 total (search listing) |

R4 is Basic; the other three are Extended. Stock is not reserved.

- https://jlcpcb.com/partdetail/YAGEO-RC0603FR07715KL/C137685
- https://jlcpcb.com/partdetail/0603WAF2002T5E/C4184
- https://jlcpcb.com/partdetail/23727-0603WAF3012T5E/C23000
- https://jlcpcb.com/partdetail/23588-0603WAF1182T5E/C22861

Design basis: TI TPS2660 datasheet Figure 50 and design procedure, https://www.ti.com/lit/ds/symlink/tps2660.pdf . Chain: IN → R3 → UVLO → R4 → OVP → R5 → RTN. R6 connects ILIM to RTN. Nominal thresholds are approximately 18.17 V UV turn-on and 30.25 V OV cutoff; nominal input current limit is approximately 1.02 A on the 24 V branch. Actual thresholds vary with tolerances and hysteresis. RTN remains separate from system GND. Startup/slew capacitor selection and remaining configuration wiring are still pending.

### eFuse capacitors and latest wiring check (2026-09-19)

Saved schematic check: C9 removed; C8 connects 24V_IN to GND; C10 connects dVdT to EFUSE_RTN. R5/R6/MODE return to EFUSE_RTN, which remains separate from GND. SHDN and IMON are unconnected. R7 is another C25803 100k resistor, pulling FLT/TP1 up to 24V_PROTECTED; TP1 is therefore a nominal 24 V test point, not a logic-level output.

| Ref | Proposed value | Manufacturer / MPN | LCSC | Footprint | Available order quantity | USD at 1+ |
|---|---|---|---|---|---:|---:|
| C8 | 1u, 50 V X7R, 10% | Samsung CL21B105KBFNNNE | C28323 | Capacitor_SMD:C_0805_2012Metric | 2,342,428 | 0.0399 |
| C10 | 22n, 50 V X7R, 10% | Samsung CL10B223KB8NNNC | C21122 | Capacitor_SMD:C_0603_1608Metric | 908,429 | 0.0083 |

Both are Basic parts, live browser stock snapshot, not reserved. Both use Device:C.

- https://jlcpcb.com/partdetail/SamsungElectroMechanics-CL21B105KBFNNNE/C28323
- https://jlcpcb.com/partdetail/21834-CL10B223KB8NNNC/C21122

C10 is a provisional design selection, not validated hardware. The saved schematic still says 2u2; user should change it to 22n. TI Eq. 2 gives nominal ramp t = 8000 × Vin × Cdvdt = 4.224 ms at 24 V. C1+C2+C5+C7 total 31.5 uF nominal on the protected rail, so capacitive inrush alone is approximately 0.179 A. Using 37.95 uF (20% bulk and 10% ceramic upper tolerances), 22n minus 10% tolerance and minus 15% temperature variation, maximum 5.5 uA charging current, and maximum gain 25.5 gives approximately 0.316 A capacitive inrush. This does not include downstream converter startup or ESP/accessory load. Buck output capacitors are behind the switching converter and must not simply be added to the protected-rail capacitance. Loaded startup, thermal margin, and simultaneous external loads still require verification; full 5 V / 2 A startup is not established with the approximately 1 A input limit. TI Figure 38 also demonstrates 22n timing with a 47u output load, but at a different current limit. Input capacitor DC bias and input transient exposure remain release checks.

### XIAO supply isolation diode (D1)

Selected 2026-09-19: **MDD SS14**, JLC/LCSC **C2480**, quantity 1. KiCad symbol `Device:D_Schottky`, footprint `Diode_SMD:D_SMA`. Connect anode (pad 2) to the buck's +5V rail and cathode (pad 1, banded end) to XIAO VBUS. This diode carries the XIAO branch current, not the full 2 A converter output.

JLC live listing: **Basic**, 872,177 total stock; **779,396 available to order**, **$0.0191 at 1+**. Stock is not reserved. https://jlcpcb.com/partdetail/MDDMicrodiodeSemiconductor-SS14/C2480

MDD datasheet Rev 2025A5: 1 A average forward current, 40 V reverse rating, maximum 0.55 V forward drop at 1 A; DO-214AC/SMA package, band identifies cathode. Checked against installed KiCad SMA footprint dimensions and cathode pad 1 marking. https://www.lcsc.com/datasheet/C2480.pdf

The series diode blocks USB-fed VBUS from feeding back into the buck output. It does not by itself provide isolation in the external-supply-to-USB-host direction; verify the XIAO's onboard USB power path before approving simultaneous supplies.

### Converter components

| Role | Qty/board, provisional | Manufacturer / MPN | JLC part | Stock shown | Unit USD | Package |
|---|---:|---|---|---:|---:|---|
| Buck regulator, 500 kHz PFM | 1 | TI LMR51420XDDCR | C5246146 | 4,440 total; 4,317 orderable | 1.0222 | SOT-23-6, TI DDC drawing |
| 10 uH shielded molded inductor | 1 | Sunlord MWSA0804S-100MT | C17700171 | 6,699 | 0.3122 | 8.8 x 8.2 mm |
| 4.7 uF, 50 V X7R input ceramic | 2 | Samsung CL31B475KBHNNNE | C51205 | 540,858 | 0.0752 | 1206 |
| 22 uF, 25 V X5R output ceramic | 2 | Samsung CL31A226KAHNNNE | C12891 | 964,186 | 0.1759 | 1206 |
| 100 nF, 50 V X7R, input bypass + bootstrap | 2 | Yageo CC0603KRX7R9BB104 | C14663 | 52,165,306 | 0.0124 | 0603 |
| 100 kohm, 1% upper feedback | 1 | Uni-Royal 0603WAF1003T5E | C25803 | 23,914,065 | 0.0031 | 0603 |
| 13.7 kohm, 1% lower feedback | 1 | Uni-Royal 0603WAF1372T5E | C22793 | 46,404 | 0.0017 | 0603 |
| 22 uF, 50 V input bulk candidate | 1 | Honor Elec RVT1H220M0605 | C27783 | 12,876 | 0.0357 | SMD, diameter 6.3 x height 5.4 mm |

Provisional total: **$1.9019 per board**, converter components only. The 100 kohm, 22 uF ceramic and 100 nF capacitor listings are Basic; the other listed converter parts are Extended. Assembly/setup costs need a quote at the intended 5–10 board quantity.

### JLC links

- https://jlcpcb.com/partdetail/TexasInstruments-LMR51420XDDCR/C5246146
- https://jlcpcb.com/partdetail/Sunlord-MWSA0804S100MT/C17700171
- https://jlcpcb.com/partdetail/52218-CL31B475KBHNNNE/C51205
- https://jlcpcb.com/partdetail/13537-CL31A226KAHNNNE/C12891
- https://jlcpcb.com/partdetail/YAGEO-CC0603KRX7R9BB104/C14663
- https://jlcpcb.com/partdetail/26546-0603WAF1003T5E/C25803
- https://jlcpcb.com/partdetail/23520-0603WAF1372T5E/C22793
- https://jlcpcb.com/partdetail/HonorElec-RVT1H220M0605/C27783

### Design basis and checks remaining

- TI datasheet https://www.ti.com/lit/ds/symlink/lmr51420.pdf : 500 kHz 5 V example uses 10 uH and two 22 uF output capacitors. Detailed input recommendation is two 4.7 uF / 50 V ceramics plus 100 nF. Nominal 100k / 13.7k feedback gives about 4.98 V.
- 24 V, 5 V, 10 uH, 500 kHz gives approximately 0.79 A peak-to-peak inductor ripple and 2.40 A peak at 2 A output (nominal components).
- Chose MWSA0804S-100MT instead of SWPA8040S100MT because TI specifies high-side current limit up to 5.1 A. Sunlord MWSA series table gives 7 A minimum / 8 A typical saturation and 5.5 A minimum / 6.5 A typical heating current for the selected inductor. Check actual supplier datasheet revision and temperature derating before release.
- Samsung output capacitor specifications: https://product.samsungsem.com/mlcc/CL31A226KAHNNN.do . DC-bias curves, temperature/tolerance margin and total load capacitance still need checking; do not assume all nominal ceramic capacitance is available.
- Confirm input bulk capacitor ripple/ESR and suitability with supply cable and local ceramics before finalizing it.
- Complete input protection and supply transient assessment for the shared motor supply. LMR51420 operates up to 36 V; 50 V capacitors do not give the IC a 50 V input rating.
- Resolve USB/external-5-V power interaction from the exact XIAO C6 schematic before wiring supplies together.
- Follow TI layout, validate footprints and assembly compatibility, then test startup, load steps, ripple and temperature.
- This sourcing check does not cover the motor interface, switch protection, connectors, LEDs or buttons; those circuits are not finalized yet.
