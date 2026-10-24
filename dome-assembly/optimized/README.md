# Faster-printing dome hubs

**Superseded for the cloth-covered dome:** use `../cloth-safe/README.md` and the
new `cloth-*.stl` files. This older design puts a flat plate toward the fabric.

Use the **rib** STLs in this folder. These are the fastest shapes tested. Their
flat bottoms, short arms, and sloping flat roofs replace the original intersecting
cylinders. A small point above each circular dowel seat makes the socket roof
printable without internal supports; the wood still seats against a circular
surface. The surface triangulation seen in earlier previews was a display effect,
not an intentional texture.

## Recommended files and quantities

- `rib-4-way-A.stl` — 5 copies
- `rib-4-way-B.stl` — 5 copies
- `rib-5-way.stl` — 6 copies
- `rib-6-way.stl` — 10 copies
- `angled-socket-test.stl` — print one before a batch

Each STL is one solid and is already oriented with its flat bottom on Z = 0.
Matching STEP files are also provided. The full assembly is
`dome-optimized-assembly.step`.

The `star-` and `polygon-` files are comparison prototypes, not the recommended
print set. The `fast-hub-print-pack.zip` archive contains only the recommended
STLs, test piece, preview, and these notes.

## A1 / 0.8 mm nozzle settings used for comparison

- Bambu Studio 2.8.2.61, A1 with a 0.8 mm nozzle
- Textured PEI plate
- 3 walls
- 15% grid infill
- 3 top and bottom layers
- Supports off for all new designs
- No brim
- 0.40 mm Standard or 0.56 mm Extra Draft process
- Bambu PLA Basic / Bambu PLA Matte profiles for the user's Bambu PLA
- Standard Generic PETG profile as a conservative baseline for Overture PETG

These are slicer estimates, not measured prints. Startup adds roughly six minutes
per plate. The PETG comparison uses the stock 8 mm³/s flow limit, while the PLA
profiles use 21–22 mm³/s; a calibrated Overture profile can change that comparison.

| Six-way hub | Layers | Model print time | Filament |
| --- | --- | --- | --- |
| Original curved arms, automatic tree supports, PLA Basic | 0.40 mm | 71 min 28 s | 50.97 g |
| Filled polygon, supports off, PLA Basic | 0.40 mm | 43 min 29 s | 49.37 g |
| Optimized ribs, supports off, PLA Basic | 0.40 mm | 36 min 30 s | 33.43 g |
| Optimized ribs, supports off, PLA Basic | 0.56 mm | 33 min 59 s | 34.35 g |
| Optimized ribs, supports off, PLA Matte | 0.56 mm | 33 min 11 s | 35.98 g |
| Original curved arms, automatic tree supports, Generic PETG | 0.40 mm | 118 min 42 s | 49.80 g |
| Filled polygon, supports off, Generic PETG | 0.40 mm | 93 min 38 s | 48.24 g |
| Optimized ribs, supports off, Generic PETG | 0.40 mm | 69 min 21 s | 32.66 g |
| Optimized ribs, supports off, Generic PETG | 0.56 mm | 68 min 6 s | 33.56 g |

The smaller optimized hubs, in PLA Basic at 0.56 mm, estimate 29 min 13 s / 29.78 g
for the five-way and 24 min 47 s / 24.74 g for the four-way A. Treat the mirrored B
as approximately the same. Weighted across all 26 hubs, that is roughly **12 h
43 min and 770 g of PLA Basic**, before plate startup. Batch multiple hubs per
plate to avoid repeating startup for every part. The angled test piece estimates
10 min 29 s / 9.39 g plus startup.

## Fit and assembly

The dome node centers and blind insertion stops match the original model, so the
cut list is unchanged:

- 30 short dowels: 337.87 mm / 13.302 inches
- 35 long dowels: 386.00 mm / 15.197 inches

Sockets have a 13.30 mm nominal circular seat for 12.70 mm dowels. The center of
the mouth is 33 mm from the node and the blind stop is 15 mm from the node,
giving 18 mm insertion at the centerline. This is shorter than the original
27 mm socket and trades some engagement length for speed. The vertical 3.6 mm
holes give access for a retaining screw; predrill the wood. Choose a screw length
on the physical test piece so it engages the wood without emerging through the
other side.

The rib variants omit the old shallow short-strut dimples to keep the model
simple. Use the existing numbered node map and build manifest to identify short
and long connections, and mark them with a pen before assembly. Four-way A/B
alternate around the base.

Print `angled-socket-test.stl` first with the intended filament and layer height.
Check insertion, hole-roof quality, and screw retention with the real dowel.
The 0.56 mm profile has more obvious layer steps; 0.40 mm costs only a few extra
minutes per hub if the coarse socket needs too much cleanup. Physical fit and
joint strength have not yet been tested.

## CAD checks

All four STEP hub files reimport as one valid solid. A nominal 12.70 mm dowel
was intersected with every socket in CAD and produced zero interference volume.
The full optimized assembly reimports as 91 valid solids: 26 hubs and 65 dowels.

To regenerate:

```sh
/tmp/codex-cadquery-venv/bin/python dome-assembly/optimize_hubs.py --all --styles rib --assembly
```

To reproduce a slice comparison, with the installed Bambu Studio:

```sh
python3 dome-assembly/benchmark_hubs.py --material pla --styles original polygon rib
python3 dome-assembly/benchmark_hubs.py --material pla --styles rib --layer-height 0.56
```

Local slice projects and logs are in `slicing/`. They are retained as comparison
evidence; the printer has not been sent a job.
