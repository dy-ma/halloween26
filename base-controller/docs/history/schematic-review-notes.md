# Saved schematic review — before PCB placement

> Historical pre-layout review. Its ERC counts and proposed connector references are superseded by [the current verification checklist](../verification.md). The saved design now has J6 (USB power jumper), J7 (motor power output), and zero ERC issues.

Read-only schematic review requested at the end of the user's session. Schematic and PCB were not modified. KiCad netlist export and ERC completed; ERC reported 12 errors and 4 warnings. This is a connectivity and completion check, not a manufacturing release or complete electrical validation.

## Fixes found

- TP10 label case is now fixed: the latest netlist puts TP10 on `/ENABLE` with U1 and R12. All twelve test points reach their intended nets.
- TP2–TP12 have empty Footprint fields. Assign `TestPoint:TestPoint_Pad_D2.0mm`.
- TP1–TP12 currently have `in_bom yes`. Exclude these bare pads from BOM, but keep them on the board.
- ERC cannot resolve the `Halloween` footprint library for U1. Register the existing `base-controller/libraries/Halloween.pretty` as a project footprint library named `Halloween` before updating PCB from schematic.
- Unused U1 pins 15, 16, 17, 19, 20, 21, 22, 23 need deliberate no-connect markers after checking intended usage. These are XIAO module pads; do not apply bare-chip EN/BOOT assumptions.
- ERC reports four undriven-power errors, at #PWR01, #PWR010, #PWR026 and U3 IN. Review the actual sources and add PWR_FLAG only where justified; passive custom module pin types limit ERC's inference.
- ERC reports three free wire endpoints at (72.39,36.83), (121.92,135.89), (283.21,45.72) mm. Inspect and trim unused stubs or repair intended connections.
- SW1 sourcing metadata is misplaced: MPN currently `C720477`; intended MPN is `TS-1088-AR02016`, Manufacturer `XUNPU`, LCSC `C720477`.
- U3 has no sourcing fields; previous selection is TI `TPS26600PWPR`, LCSC `C544399`. Confirm sourcing at ordering time.

## Confirmed choices and connectivity

- Keep SW1/R18 and DEBUG_BTN at U1 D5; user explicitly confirmed this. J5 pin 8 stays GND. Test points do not replace the button.
- J2: right-angle JST XH S6B-XH-A(LF)(SN), C157919, correct installed footprint. J3/J4: S2B-XH-A(LF)(SN), C157931, correct installed footprints. J1 Micro-Fit and J5 pin header sourcing/footprint assignments match their selections.
- TP1 eFuse FLT; TP2/TP3 GND; TP4 24V_IN; TP5 24V_PROTECTED; TP6 +5V; TP7 +3V3; TP8 STEP; TP9 DIR; TP10 ENABLE; TP11 LIMIT_A; TP12 LIMIT_B.
- Converter/eFuse, three transistor control channels, limit input filters/clamps and button connectivity remain as previously reviewed. This does not resolve the design questions below.

## Before committing to routing

- Add J6 motor power output on 24V_IN/GND. The recommendation is now one replaceable inline upstream fuse and a 5 A PCB distribution design target; final fuse rating and protection coordination depend on hardware/load. See [electrical decisions](../electrical-decisions.md). Existing approximately 1 A eFuse remains on the logic branch.
- XIAO pad 14 is directly connected to USB VBUS in Seeed's schematic. Proposed resolution: removable JP1 between D1 cathode and pad 14; remove it whenever using USB. This is not implemented yet. See [electrical decisions](../electrical-decisions.md) for operating modes.
- Documented interface candidate: STEPPERONLINE DM542T V4.0 with 5 V selection. Existing open-collector topology matches; EASON clone specifics remain unverified. Driver purchase must meet the documented interface contract. Transistor-off is not automatically motor-disabled.
- Plan board outline, mounting holes, connector access, XIAO antenna keepout and converter placement/layout from the datasheet before routing.
- Complete ERC cleanup. Buck capacitor effective capacitance, thermal/current sizing and final mechanical footprint checks remain part of final design validation.

Suggested next session: fix labels/metadata/footprints, complete outstanding power decisions, then board outline and placement. Route the converter carefully before the less constrained signals.

## Current documentation

See [the board README](../../README.md) for architecture, [the parts list](../parts-list.md) for the grouped planning BOM, and [electrical decisions](../electrical-decisions.md) for proposed J6/JP1 and the power-harness approach. These files distinguish current schematic contents from additions; no schematic edits were made during the documentation work.
