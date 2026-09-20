# Current parts list

Prepared from the saved schematic on 2026-09-19. **Planning BOM, not an order-ready assembly file.** Quantities below cover parts already placed; J6/J7 are included after checking the latest saved schematic; harness items are separate. TP1–TP12 are bare PCB pads, not purchased parts. All 0603/0805/1206 sizes below are imperial package names.

MPNs and LCSC numbers reflect the selected parts. U3 and SW1 are corrected here from prior sourcing decisions; those corrections still need to be entered in the schematic. Some manufacturer fields were filled from the existing sourcing notes. Values, footprints and quantities were checked against the exported netlist. JLC stock is not reserved, and this document is not a fresh stock check for every part. Where a direct detail URL was not retained, the link opens JLC's exact C-number search.

## Components already placed

| References | Qty | Value / type | Manufacturer | MPN | JLC | Footprint key |
|---|---:|---|---|---|---|---|
| C1, C2 | 2 | 4u7 | Samsung | `CL31B475KBHNNNE` | [C51205](https://jlcpcb.com/partdetail/52218-CL31B475KBHNNNE/C51205) | FP1 |
| C3, C4 | 2 | 22u | Samsung | `CL31A226KAHNNNE` | [C12891](https://jlcpcb.com/partdetail/13537-CL31A226KAHNNNE/C12891) | FP1 |
| C5, C6, C9, C11 | 4 | 100n | YAGEO | `CC0603KRX7R9BB104` | [C14663](https://jlcpcb.com/partdetail/YAGEO-CC0603KRX7R9BB104/C14663) | FP2 |
| C7 | 1 | 22u | Honor Elec | `RVT1H220M0605` | [C27783](https://jlcpcb.com/partdetail/HonorElec-RVT1H220M0605/C27783) | FP3 |
| C8 | 1 | 1u | Samsung | `CL21B105KBFNNNE` | [C28323](https://jlcpcb.com/partdetail/SamsungElectroMechanics-CL21B105KBFNNNE/C28323) | FP4 |
| C10 | 1 | 22n | Samsung | `CL10B223KB8NNNC` | [C21122](https://jlcpcb.com/partdetail/21834-CL10B223KB8NNNC/C21122) | FP2 |
| D1 | 1 | SS14 | MDD | `SS14` | [C2480](https://jlcpcb.com/partdetail/MDDMicrodiodeSemiconductor-SS14/C2480) | FP5 |
| D2, D3 | 2 | BAT54S | JSCJ | `BAT54S KL4` | [C8592](https://jlcpcb.com/parts/componentSearch?searchTxt=C8592) | FP6 |
| J1 | 1 | 24V_IN | MOLEX | `436500215` | [C293740](https://jlcpcb.com/partdetail/MOLEX-436500215/C293740) | FP7 |
| J2 | 1 | MOTOR_CONTROL | JST | `S6B-XH-A(LF)(SN)` | [C157919](https://jlcpcb.com/partdetail/JST-S6B_XH_A_LF_SN/C157919) | FP8 |
| J3 | 1 | LIMIT_A | JST | `S2B-XH-A(LF)(SN)` | [C157931](https://jlcpcb.com/partdetail/JST-S2B_XH_A_LF_SN/C157931) | FP9 |
| J4 | 1 | LIMIT_B | JST | `S2B-XH-A(LF)(SN)` | [C157931](https://jlcpcb.com/partdetail/JST-S2B_XH_A_LF_SN/C157931) | FP9 |
| J5 | 1 | SPARE_IO | XFCN | `PZ254V-11-08P` | [C492407](https://jlcpcb.com/partdetail/Xfcn-PZ254V_1108P/C492407) | FP10 |
| J6 | 1 | XIAO_POWER_LINK | XFCN | `PZ254V-11-02P` | [C492401](https://jlcpcb.com/partdetail/PZ254V-11-02P/C492401) | FP17 |
| J7 | 1 | MOTOR_24V_OUT | MOLEX | `436500215` | [C293740](https://jlcpcb.com/partdetail/MOLEX-436500215/C293740) | FP7 |
| L1 | 1 | 10u | Sunlord | `MWSA0804S-100MT` | [C17700171](https://jlcpcb.com/partdetail/Sunlord-MWSA0804S100MT/C17700171) | FP11 |
| Q1, Q2, Q3 | 3 | MMBT3904 | JSCJ | `MMBT3904(RANGE:100-300)` | [C20526](https://jlcpcb.com/parts/componentSearch?searchTxt=C20526) | FP6 |
| R1, R7 | 2 | 100k | UNI-ROYAL | `0603WAF1003T5E` | [C25803](https://jlcpcb.com/partdetail/26546-0603WAF1003T5E/C25803) | FP12 |
| R2 | 1 | 13k7 | UNI-ROYAL | `0603WAF1372T5E` | [C22793](https://jlcpcb.com/partdetail/23520-0603WAF1372T5E/C22793) | FP12 |
| R3 | 1 | 715k | YAGEO | `RC0603FR-07715KL` | [C137685](https://jlcpcb.com/partdetail/YAGEO-RC0603FR07715KL/C137685) | FP12 |
| R4 | 1 | 20k | UNI-ROYAL | `0603WAF2002T5E` | [C4184](https://jlcpcb.com/partdetail/0603WAF2002T5E/C4184) | FP12 |
| R5 | 1 | 30k1 | UNI-ROYAL | `0603WAF3012T5E` | [C23000](https://jlcpcb.com/partdetail/23727-0603WAF3012T5E/C23000) | FP12 |
| R6 | 1 | 11k8 | UNI-ROYAL | `0603WAF1182T5E` | [C22861](https://jlcpcb.com/partdetail/23588-0603WAF1182T5E/C22861) | FP12 |
| R8, R10, R12, R15, R16 | 5 | 1k | UNI-ROYAL | `0603WAF1001T5E` | [C21190](https://jlcpcb.com/parts/componentSearch?searchTxt=C21190) | FP12 |
| R9, R11, R13, R14, R17, R18 | 6 | 10k | UNI-ROYAL | `0603WAF1002T5E` | [C25804](https://jlcpcb.com/parts/componentSearch?searchTxt=C25804) | FP12 |
| SW1 | 1 | Momentary pushbutton | XUNPU | `TS-1088-AR02016` | [C720477](https://jlcpcb.com/partdetail/TS-1088-AR02016/C720477) | FP13 |
| U1 | 1 | XIAO-ESP32-C6 | Seeed Studio | `113991254` | [C27675191](https://jlcpcb.com/partdetail/Seeed-113991254/C27675191) | FP14 |
| U2 | 1 | LMR51420XDDCR | Texas Instruments | `LMR51420XDDCR` | [C5246146](https://jlcpcb.com/partdetail/TexasInstruments-LMR51420XDDCR/C5246146) | FP15 |
| U3 | 1 | TPS26600 eFuse | Texas Instruments | `TPS26600PWPR` | [C544399](https://jlcpcb.com/partdetail/TexasInstruments-TPS26600PWPR/C544399) | FP16 |

## Exact footprint names

| Key | KiCad footprint |
|---|---|
| FP1 | `Capacitor_SMD:C_1206_3216Metric` |
| FP2 | `Capacitor_SMD:C_0603_1608Metric` |
| FP3 | `Capacitor_SMD:CP_Elec_6.3x5.4` |
| FP4 | `Capacitor_SMD:C_0805_2012Metric` |
| FP5 | `Diode_SMD:D_SMA` |
| FP6 | `Package_TO_SOT_SMD:SOT-23` |
| FP7 | `Connector_Molex:Molex_Micro-Fit_3.0_43650-0215_1x02_P3.00mm_Vertical` |
| FP8 | `Connector_JST:JST_XH_S6B-XH-A_1x06_P2.50mm_Horizontal` |
| FP9 | `Connector_JST:JST_XH_S2B-XH-A_1x02_P2.50mm_Horizontal` |
| FP10 | `Connector_PinHeader_2.54mm:PinHeader_1x08_P2.54mm_Vertical` |
| FP11 | `Inductor_SMD:L_Sunlord_MWSA0804S` |
| FP12 | `Resistor_SMD:R_0603_1608Metric` |
| FP13 | `Button_Switch_SMD:SW_SPST_TS-1088-xR020` |
| FP14 | `Halloween:XIAO-ESP32-C6-SMD` |
| FP15 | `Package_TO_SOT_SMD:TSOT-23-6` |
| FP16 | `Halloween:TPS26600_HTSSOP16_ThermalVias_0.3mm` |
| FP17 | `Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical` |

## Ratings and circuit roles worth retaining

| Parts | Design intent |
|---|---|
| C1/C2 | 4.7 µF, 50 V X7R converter input ceramics |
| C3/C4 | 22 µF, 25 V X5R output ceramics; effective capacitance needs checking |
| C5/C6 | 100 nF, 50 V X7R input bypass / bootstrap |
| C7 | 22 µF, 50 V polarized input bulk capacitor; observe polarity |
| C8 | 1 µF, 50 V X7R at raw 24 V input |
| C9/C11 | 100 nF limit-input filters |
| C10 | 22 nF, 50 V X7R eFuse slew setting |
| R1/R2 | Buck output feedback divider |
| R3/R4/R5 | eFuse undervoltage/overvoltage divider referenced to EFUSE_RTN |
| R6 | eFuse current-limit setting |
| R7 | 100 kΩ FLT pullup to 24V_PROTECTED, not 3.3 V |
| R8/R10/R12 | NPN base current limiting |
| R9/R11/R13 | NPN base pulldowns |
| R14/R17 | Limit input pullups |
| R15/R16 | Limit input series resistors |
| R18 | Button pullup |
| D1 | XIAO-feed Schottky diode; source selection uses removable shunt on J6 |
| D2/D3 | Dual Schottky rail clamps for limit inputs |
| L1 | 10 µH converter inductor; current rating, dimensions and exact part matter |

## Proposed additions, not yet in the schematic

| Ref | Qty | Component | MPN / JLC | Footprint |
|---|---:|---|---|---|
| H1–H4, suggested | 4 | M3 clearance mounting holes | No purchased electrical component | Candidate `MountingHole:MountingHole_3.2mm_M3`; verify enclosure fastener clearances |

J6 and J7 are already placed. J6 needs a separately supplied removable 2.54 mm shunt; the header listing does not include one. Mounting holes and test pads should be excluded from the component BOM.

## External and final-assembly items

- See the [non-PCB component recommendations](non-pcb-components.md) for power supplies, inline holder/fuse and Deutsch/XT60 pigtail options, with purchase links. Preferred supply candidate: Mean Well GST120A24-P1M, 24 V / 5 A brick.
- Inline holder candidate: Littelfuse 0FHM0003ZXJB; separate MINI fuse with amperage still to validate. Fits in the incoming positive power lead. No PCB fuse holder is selected.
- External DM542-class driver: STEPPERONLINE DM542T V4.0 is the documented compatible-topology candidate. Earlier EASON listing remains unverified in detail.
- Motor: supplied candidate drawing is STEPPERONLINE 23HS30-2804S; mechanics/load still to validate.
- XH cable housings: XHP-6 for J2 and XHP-2 for J3/J4; contacts selected for actual wire gauge. Existing kit compatibility not established.
- Micro-Fit mating housings/contacts and power leads: select for the header, wire size and derated current. These are separate from the PCB header.
- Two dry-contact limit switches, mounting hardware, cable restraints, standoffs and enclosure.
- One removable 2.54 mm shunt for J6: BOOMELE [C100114](https://jlcpcb.com/partdetail/101329-2_54Short_Circuit_CapClosed/C100114), closed-style shorting cap. Request fitting on J6 in assembly instructions and confirm with JLC; it has no separate PCB footprint. Alternatively fit it yourself. No solder bridge intended.
- Spare +5 V accessory connector remains an optional unimplemented idea, not included in this BOM.

## Manufacturing notes

All populated references need correct footprint, value and sourcing fields before BOM/CPL export. SW1 currently has its LCSC number in MPN; U3 lacks sourcing fields. Bare test points remain marked for BOM inclusion in the reviewed schematic and need exclusion. The XIAO footprint is local: register `Halloween.pretty` before transferring to PCB. Through-hole connector assembly, module assembly and any underside pads must be confirmed in JLC's actual quote/preview. This parts list does not authorize substitutions solely on matching resistance/capacitance or package size.
