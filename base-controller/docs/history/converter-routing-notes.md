# Converter routing: first pass

> Design history: positions, counts, and pending-work statements below describe that stage of development. See [current verification status](../verification.md) before making changes or ordering.

2026-09-19. Local routing added at Dylan's request. Existing component placement, reference text and the user's U2-SW-to-L1 track were preserved byte-for-byte. A backup of the previous PCB is in `placement-backups/before-converter-routing-20260919-173011.kicad_pcb`.

## Reading the routes

- **Input power:** C7 positive feeds the C2/C1 input bus, then C5 and U2 VIN. Main local input bus is 1.0 mm; the short capacitor-to-IC approach narrows to 0.6/0.4 mm.
- **Enable:** U2 pin 5 connects to this same input net through a 0.25 mm branch with two vias and a short B.Cu segment. It is a physical connection, not an internal VIN/EN tie.
- **Switching node:** the user's 0.5 mm front track joins U2 SW to L1. A short 0.25 mm back-layer branch connects SW to the bootstrap capacitor C6, following the two-layer routing idea in TI's example. C6's other pad connects to CB on the front.
- **Output power:** a 1.0 mm path joins L1's +5 V side to C3/C4. The separate 0.25 mm trace around the top/right feeds only the feedback divider R1, sensing at the output capacitor. External +5 V loads must branch from the output power path, not use this thin sense trace as their supply bus.
- **Feedback:** U2 FB connects directly to the nearby common R1/R2 pads using 0.25 mm tracks, away from SW copper.
- **Ground:** a short 0.4 mm path under U2 joins its GND pad to the input-capacitor ground, with wider connections along C1/C2. Nearby vias connect input/output capacitors, IC ground and R2 ground to local copper on both layers. This is ordinary GND; EFUSE_RTN is untouched.

The local F.Cu/B.Cu ground-zone rectangles are temporary extents for this circuit island, not a board outline. Merge/resize them as the actual outline, antenna keepout and remaining placement are established. Keep the regulator's local return paths intact. Zones use direct pad connections here for short ground paths and heat spreading. Via sizes are 0.6/0.3 mm (diameter/drill), with 0.8/0.4 mm vias by C7.

Reference: [TI LMR51420 datasheet, layout pages 21–23](https://www.ti.com/lit/ds/symlink/lmr51420.pdf).

## Verification and limits

KiCad filled the zones and ran DRC with a copy of the actual project settings and the local footprint library registered. No new DRC violations were introduced: no copper-clearance, short-circuit or courtyard violations were reported. Unconnected entries decreased from 114 to 95; the remaining circuit sections and connections between sections are intentionally unfinished. Existing warnings/errors remain for the absent outline, U3's thermal-hole sizes versus the default minimum drill constraint, and U1 silkscreen/text.

This is a reviewed routing starting point, not a manufacturing release or measured EMI/thermal validation. Final board copper, routing, current/thermal checks and bring-up remain necessary. Neither placement nor routing changed the schematic, the power design or any outside component.

[Traces-only preview](../../previews/converter-routing-traces.png) hides ground fills for readability. [Filled-copper preview](../../previews/converter-routing-with-zones.png) shows the actual local zones.

To view the saved change, close the old PCB Editor view without saving and reopen the board from the project.
