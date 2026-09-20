# Converter placement starting point

> Design history: positions, counts, and pending-work statements below describe that stage of development. See [current verification status](../docs/verification.md) before making changes or ordering.

Local routing was subsequently added; see [converter-routing-notes.md](converter-routing-notes.md). The notes below describe the earlier placement-only step.

Updated 2026-09-19 at Dylan's request. Only U2, L1, C1–C7 and R1/R2 were repositioned/rotated or had reference text adjusted. Other footprint blocks were preserved byte-for-byte. No tracks, vias, zones or board outline were added; pad identities and net assignments were preserved.

The arrangement follows the topology of [TI LMR51420 datasheet Figure 9-10, page 23](https://www.ti.com/lit/ds/symlink/lmr51420.pdf), adapted to the actual component sizes and additional parallel capacitors:

- U2 retains its original orientation. L1 is to its left, with the SW pad facing U2 and +5 V on its left.
- C5 is immediately below U2; C1/C2 are below C5. Their input pads face left and ground pads right. The local ground connection under the IC and ground copper must still be routed.
- C3/C4 sit above L1, with +5 V on the left and ground on the right.
- C6 is above U2, with CB on its right. Its SW return can use a short bottom-layer connection as in TI's example; route this deliberately rather than creating a large switching-node area.
- R2/R1 sit to the right of FB; their common FB pads are at the bottom, R2 ground and R1 +5 V at the top. Sense +5 V at the output capacitors and keep this route away from SW/inductor copper.
- C7 is the bulk input capacitor, lower-left of the group, with its positive pad toward the input-capacitor bus.

This is placement for guided routing, not a validated power converter or a final board layout. The whole island may move once the outline and connectors are established. Reference text is provisional.

## Check performed

Rendered and visually inspected placement. KiCad DRC found no courtyard overlaps or copper-clearance violations in the candidate. All 59 footprints and pad/net identities were retained. The unrouted board still has expected unconnected pads and no outline. The check also exposed existing U3 thermal-hole size versus default drill-constraint warnings (0.2 mm holes versus 0.3 mm minimum), and U1 silkscreen/text warnings. Review those against the intended fabrication process during board setup; do not blindly lower constraints. The standalone temporary-board check could not resolve the project-local footprint library; the actual project registration remains unchanged.

## Backup

Previous board: `before-converter-placement-20260919-171208.kicad_pcb` in `placement-backups/`.

After this external edit, close the old PCB Editor view without saving and reopen the board from the project to load the saved placement.
