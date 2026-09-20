# Libraries for the base controller

Prepared for KiCad 9.0.6. Project-relative `fp-lib-table` and `sym-lib-table` files are checked in and register these libraries automatically. The manual registration steps below are for recovery if needed. See [license notices](../../NOTICE.md) for retained upstream terms.

## Register the libraries

1. Open the base-controller schematic from the KiCad project manager.
2. Preferences → Manage Symbol Libraries → Project Specific Libraries → Add existing library (folder icon). Select `libraries/Halloween.kicad_sym`. Keep nickname `Halloween`.
3. Preferences → Manage Footprint Libraries → Project Specific Libraries → Add existing library. Select the folder `libraries/Halloween.pretty`. Keep nickname `Halloween`.
4. Use project-relative paths (`${KIPRJMOD}/libraries/...`) when offered so the project can move between computers.

## Historical initial placement checklist

Press A to add a symbol. Hover a placed symbol and press E to edit its properties. Put the short electrical value in Value, assign Footprint, and add hidden Manufacturer, MPN, LCSC and Voltage fields where applicable. The two Halloween symbols already contain manufacturer, MPN, LCSC and footprint fields. Use the [parts-sourcing document](../docs/parts-sourcing.md) for the passive manufacturers and exact MPNs.

Place all 12 components below (one C6 plus 11 converter parts). Leave space around the regulator for subsequent wiring. References are automatically assigned; do not worry about matching a particular U/C/R number yet.

| Symbol to search | Count | Value | Voltage field | Footprint | LCSC field |
|---|---:|---|---|---|---|
| Halloween:XIAO-ESP32-C6-SMD | 1 | XIAO-ESP32-C6 | — | Halloween:XIAO-ESP32-C6-SMD | C27675191 |
| Halloween:LMR51420XDDCR | 1 | LMR51420XDDCR | — | Package_TO_SOT_SMD:TSOT-23-6 | C5246146 |
| Device:L | 1 | 10u | — | Inductor_SMD:L_Sunlord_MWSA0804S | C17700171 |
| Device:C | 2 | 4.7u | 50V | Capacitor_SMD:C_1206_3216Metric | C51205 |
| Device:C | 2 | 22u | 25V | Capacitor_SMD:C_1206_3216Metric | C12891 |
| Device:C | 2 | 100n | 50V | Capacitor_SMD:C_0603_1608Metric | C14663 |
| Device:R | 1 | 100k | — | Resistor_SMD:R_0603_1608Metric | C25803 |
| Device:R | 1 | 13.7k | — | Resistor_SMD:R_0603_1608Metric | C22793 |
| Device:C_Polarized | 1 | 22u | 50V | Capacitor_SMD:CP_Elec_6.3x5.4 | C27783 |

For pairs, configure one completely, then duplicate it with Shift+D. The 22u/25V ceramics and 22u/50V polarized bulk capacitor are different parts with different symbols and footprints. Footprints and values here are provisional selections, not a manufacturing release; bulk capacitor land pattern and capacitor derating require final datasheet review.

## Sources and changes

### JST PA connectors — added 2026-09-19

These are now unused alternatives. The user subsequently selected JST XH: J2 uses `Connector_JST:JST_XH_S6B-XH-A_1x06_P2.50mm_Horizontal`; J3/J4 use `Connector_JST:JST_XH_S2B-XH-A_1x02_P2.50mm_Horizontal`. Both are included in the installed KiCad library. See the current decisions at the top of [parts sourcing](../docs/parts-sourcing.md) for sourcing fields.

- J2: `Halloween:B06B-PASK` for JST B06B-PASK(LF)(SN), LCSC C158044.
- J3 and J4: `Halloween:B02B-PASK` for JST B02B-PASK(LF)(SN), LCSC C158050.
- Adapted from Adam Greig's MIT-licensed agg-kicad footprints: https://github.com/adamgreig/agg-kicad/tree/master/agg.pretty . License retained in `LICENSE-agg-kicad.txt`.
- Checked against JST's public PA catalog, PCB mounting-surface drawing and standard top-entry header dimensions: https://www.jst-mfg.com/product/pdf/eng/ePA-F.pdf (PDF pages 3 and 9).
- Removed the upstream locating-peg hole: the selected parts are the versions without a boss. Corrected body position relative to the pin row. Signal holes are 0.75 mm within the drawing's 0.7–0.8 mm range; pitch is 2 mm. Body dimensions are 6 × 5.3 mm (2-pin) and 14 × 5.3 mm (6-pin). Pin 1 is on the right in the mounting-surface view. Added rectangular pad 1, silkscreen identification and a 0.5 mm courtyard margin.
- Both footprints successfully loaded/exported through KiCad 9 CLI, and their rendered outlines/pad numbering were visually inspected. No 3D models supplied. Manufacturing hole tolerances and final board assembly still require review.

### MCU and converter

2026-09-19 placement cleanup: moved the XIAO footprint's F.Silkscreen graphic primitives to F.Fab in the local library and placed board instance. The imported body/USB graphics crossed pads and the carrier edge. Pads and numbering are unchanged; the reference remains on silkscreen. See [placement history](../docs/history/overall-placement-notes.md) for the provisional antenna reservation and remaining review.

- C6 symbol geometry and pin numbering, and the matching footprint, come from Seeed's official library: https://github.com/Seeed-Studio/OPL_Kicad_Library/tree/master/Seeed%20Studio%20XIAO%20Series%20Library . Retrieved 2026-09-18. Source symbol library was KiCad 10 format; wrapper/properties rebuilt in KiCad 9 syntax. Pin geometry and numbering preserved. Footprint pad geometry was retained; artwork was later moved to F.Fab as described above. Source symbol treats all pins as passive; ERC cannot fully validate their electrical direction. Antenna keepout and underside-pad assembly requirements still need review before PCB layout.
- LMR51420XDDCR symbol is adapted from the installed KiCad Regulator_Switching:LMR51430 symbol. Pin numbers verified against TI's LMR51420 datasheet: 1 GND, 2 SW, 3 VIN, 4 FB, 5 EN, 6 CB. Value, description, datasheet and footprint changed for the selected 2 A part. Added sourcing fields. https://www.ti.com/lit/ds/symlink/lmr51420.pdf
- KiCad library source and license: https://gitlab.com/kicad/libraries/kicad-symbols ; CC-BY-SA 4.0 with KiCad libraries exception: https://www.kicad.org/libraries/license/ . Attribution: KiCad library contributors. Retain upstream licensing for redistributed library data.
- KiCad 9 CLI successfully loaded and exported both symbols. C6 symbol and footprint pad-number sets match. These checks do not replace dimension, electrical or PCB review.


### Documentation QR — added 2026-09-19

`Halloween:QR_TractorDriver` is a graphics-only, board-only footprint, excluded from BOM and placement exports. It encodes `https://www.dyma.dev/articles/tractor-driver`. Generated using KiCad's bundled `kicad_qrcode` encoder: 33 × 33 modules, Q error correction, 0.5 mm module pitch, and a four-module quiet zone; total 20.5 × 20.5 mm. Light regions and the quiet zone are printed in silkscreen; dark regions use the underlying solder mask. Use white silkscreen on a dark mask for this version.

The library footprint is front-facing. The PCB instance QR1 is flipped onto B.Silkscreen and reads correctly from the underside. Move it as one footprint; keep its entire square clear of exposed pads, holes, and other markings. The article can be published later at that exact URL. No electrical geometry was changed. The post-addition DRC still reports only the 12 existing U3 thermal-drill size violations, with zero unconnected items.

Validation: the mirrored B.Silkscreen SVG export was rasterized and successfully decoded with ZXing-C++ to the exact URL above. Physical scan quality still depends on fabrication contrast and finish.


### TPS26600 thermal-via footprint — updated 2026-09-20

`Halloween:TPS26600_HTSSOP16_ThermalVias_0.3mm` derives from KiCad 9’s `Package_SO:HTSSOP-16-1EP_4.4x5mm_P0.65mm_EP3.4x5mm_Mask2.66x2.46mm_ThermalVias`. All twelve small plated pad-17 holes use 0.30 mm drills and 0.60 mm copper pads, leaving a nominal 0.15 mm ring. The large rectangular thermal copper pads, hole centers, signal pads, F.Mask aperture, and two F.Paste apertures are unchanged. The schematic footprint assignment and PCB library ID both point to this project-local version.

The change resolves the drill-size conflict without lowering project rules. Refilling the board and running KiCad 9.0.6 ERC/DRC with schematic parity gives zero findings. Imported geometry retains KiCad’s CC-BY-SA-4.0 with library exception; see [NOTICE](../../NOTICE.md).

TI’s device land-pattern example uses 0.20 mm thermal holes; its [general PowerPAD application note, page 9](https://www.ti.com/lit/an/slma002h/slma002h.pdf#page=9) discusses drills of 0.33 mm or smaller for controlling solder wicking under the stated process conditions. This supports considering 0.30 mm, but does not certify our assembly process. Six inner-row holes remain at least partly exposed by the front mask opening. The center pair is directly under paste; the larger side-column holes also slightly intersect the paste edges. Backside mask coverage is unchanged. Review stencil and any plugging/filling requirements with the assembler before ordering; see [verification](../docs/verification.md).
