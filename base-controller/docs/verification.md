# Verification before the first fabrication order

Status recorded 2026-09-20 using KiCad 9.0.6. The initial design is complete enough for review; no hardware performance is yet established. This is the current checklist, superseding the earlier placement and schematic-review notes.

## Automated checks

| Check | Result |
|---|---|
| Schematic ERC | 0 issues |
| PCB unconnected items | 0 |
| Schematic/PCB parity | 0 mismatches |
| PCB DRC | 0 errors/warnings after the U3 thermal-via update |
| QR render | Decodes to `https://www.dyma.dev/articles/tractor-driver` from the underside |

These results include refilling zones in a disposable copy. Run `python3 base-controller/scripts/build_hardware.py check` from the repository root for current JSON reports, schematic PDF, PCB SVGs, BOM, and native KiCad position CSV. Generated reports remain local under `build/`; they are not a substitute for the checks below.

## Sourcing metadata found during this review

The exported schematic BOM still contains two specific issues:

- **SW1:** `MPN` currently contains `C720477`, and `LCSC` is blank. The documented selection is XUNPU `TS-1088-AR02016`, LCSC `C720477`; confirm it before correcting the fields.
- **U3:** `Manufacturer`, `MPN`, and `LCSC` are blank. The documented selection is Texas Instruments `TPS26600PWPR`, LCSC `C544399`; confirm it before assigning the fields.

Some passives also omit the manufacturer field while retaining MPN and LCSC. The planning parts list does not automatically populate schematic properties. These metadata items were documented, not silently changed during repository preparation.

## Resolve before fabrication

- [x] **U3 hole geometry:** all twelve thermal vias use 0.30 mm drills and 0.60 mm circular pads (0.15 mm nominal annular ring) in `Halloween:TPS26600_HTSSOP16_ThermalVias_0.3mm`. Schematic and PCB use the same local footprint; zones refilled; ERC/DRC/parity pass. No design rules were lowered.
- [ ] **U3 assembly:** review the unchanged thermal-pad mask/paste apertures with the assembler. Six outer-row vias are outside the top mask opening; six inner-row vias are at least partly exposed. The two center-column inner vias lie within the paste apertures, and enlarging the side-column inner drills slightly overlaps the paste-aperture edges. Backside thermal copper has no mask opening. Confirm solder-wicking/voiding control, stencil, and any plugging/filling process before assembly; DRC does not validate reflow.
- [ ] **Converter review:** independently check the LMR51420 circuit and layout against TI guidance, including switching-current loops, bootstrap connection, feedback routing, effective capacitor values under DC bias, inductor saturation/ripple, startup, and thermal expectations.
- [ ] **Protection review:** verify TPS26600 settings, GND/EFUSE_RTN separation, startup/inrush, component tolerances, and input transient margin. The eFuse protects the logic branch; the external fuse protects the upstream harness/pass-through as selected.
- [ ] **Power path:** select supply, fuse, wire/contact sizes and copper thickness together; check 5 A design-target necks/vias/connector derating. Choose a conservative prototype test envelope. Final temperature qualification comes after fabrication.
- [ ] **Motor interface:** confirm the exact purchased driver's optical-input voltage/current, pulse timing, and ENA polarity. The documented DM542T V4 candidate must use its 5 V input setting. Verify reset behavior; ENA is not an emergency stop.
- [ ] **Assembly:** check footprints/polarity/pin 1 against drawings, XIAO castellated and underside connections, solder/paste apertures, and U3 thermal pad. Decide which through-hole connectors are factory fitted versus hand soldered.
- [ ] **BOM:** recheck current JLC stock, exact MPN/LCSC codes and substitutions. Fill any missing manufacturer fields. Exclude graphics/test pads/mounting holes appropriately; order the J6 shunt and cable-side connectors separately as needed. Native KiCad positions require assembler-specific rotation/origin review before use as a CPL.
- [ ] **Mechanics and RF:** verify USB plug shell/cable access, XH and Micro-Fit mating access, mounting screws/washers, enclosure spacing, and antenna clearance against the exact XIAO guidance. Check placement above the metal driver and heat sources.
- [ ] **Labels and operation:** check the back reference against actual connector numbering/mating views and intended USB jumper use. Check the QR with intended soldermask/silkscreen colors. Maintain the printed article URL.
- [ ] **Final saved source:** save, refill, run ERC/DRC/parity again, and inspect the 3D view. Commit the exact reviewed source used for export.
- [ ] **Manufacturing outputs:** inspect Gerbers and both drill files in GerbView and the fabricator preview. Confirm two copper layers, closed outline/R2 corners, drill alignment/plating, mask/paste openings, mirrored back silk, antenna clearance, and no clipped labels or QR modules.

## After receiving prototypes

- [ ] Inspect assembly and resistance/shorts before power.
- [ ] Bring up from a current-limited supply without the motor; measure protected 24 V, 5 V and 3.3 V, startup/ripple, and component temperature.
- [ ] Test J6 power-source operation, USB flashing, button, both switch inputs and spare I/O.
- [ ] Measure STEP/DIR/ENA waveforms and test the chosen driver unloaded, then with the mechanism.
- [ ] Implement and test travel limits, homing, timeouts, wireless-loss behavior, reset behavior and the actual mechanical stop strategy.
- [ ] Test full-load operation, stalls/deceleration, supply transients, and temperatures in the intended enclosure before unattended use.

Hardware findings may require another PCB revision. Passing ERC/DRC means the design satisfies the configured checks; it does not establish these operating characteristics.
