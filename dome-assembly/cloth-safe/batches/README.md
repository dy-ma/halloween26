# Two-plate overnight print plan

Open `set-10-6-5-5-0.40mm/dome-hub-batches.3mf` as a project in Bambu Studio.
It contains all 26 rounded cloth-facing hubs, arranged and sliced on two plates.

| Plate | Contents | Total estimate, including startup | PLA Basic |
| --- | --- | --- | --- |
| 1 | 10 six-way + 4 five-way = 14 hubs | 8 h 17 min | 511.93 g |
| 2 | 2 five-way + 5 four-way A + 5 four-way B = 12 hubs | 5 h 37 min | 348.11 g |

The total is about 13 h 54 min, plus one manual bed clearing between the two
batches. Either plate fits a 12-hour overnight window. Print plate 1 overnight,
then clear the bed in the morning and print plate 2 during the day or the next
night. The printer finishes a whole plate before stopping; individual hubs do
not need to be removed between layers or between parts.

These are actual Bambu Studio 2.8.2.61 slice estimates for the A1 with a 0.8 mm
nozzle, Bambu PLA Basic, 0.40 mm layers, textured PEI plate, 3 walls, 15% grid
infill, 3 top/bottom layers, no supports, and no brim. The project uses **Print
sequence: By layer**. Keep that setting for this closely packed layout. The green
thumbnail color is just the preset preview color; map the project to the actual
PLA Basic spool when printing.

The first plate needs about 512 g of available filament and the second about
348 g. Both estimates include the slicer's calculated filament consumption.
After confirming one hub's real dowel fit, bridge quality, and fabric contact,
the remaining parts can be batched this way.

The project includes two virtual plates; it does not automatically clear the
physical bed or start the second plate. One manual clearing is required.

## Evidence

The batch report verifies exactly 26 build instances, including all requested
quantities. Both plates are marked inside the printable area and use no supports.
Only timelapse-related slicer warnings were present. The arranged 3MF also
contains the generated toolpaths and separate plate previews.

- `set-10-6-5-5-0.40mm/batch-report.json` — counts, time, material, and plate bounds
- `set-10-6-5-5-0.40mm/plate-1.png` and `plate-2.png` — slicer previews
- `set-10-6-5-5-0.40mm/top-1.png` and `top-2.png` — top views

Regenerate with:

```sh
python3 dome-assembly/batch_hubs.py
```

This only creates local projects and estimates; it does not connect to a printer.
