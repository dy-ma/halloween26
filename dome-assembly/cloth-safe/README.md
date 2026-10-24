# Rounded fabric-facing dome hubs

This version replaces the flat-outside rib hubs for use beneath the decorative
cloth. The **rounded face faces outside, toward the cloth**. The flat printing
base faces the dome interior. The models are exported in that print orientation:
flat interior face on the bed, rounded exterior face upward.

For batch printing, `batches/set-10-6-5-5-0.40mm/dome-hub-batches.3mf` contains all
26 hubs on **two plates**: 14 hubs / 8 h 17 min, and 12 hubs / 5 h 37 min, including
startup. No clearing is needed during either plate; clear the bed once between
the two jobs. See `batches/README.md` for the overnight plan and filament amounts.

## What changed

- One shallow, continuous sloping outer cap replaces the broad flat outside face.
- A tangent spherical crown rounds the center of the cap.
- The footprint corners have 2.4 mm radii, and the top lip has a 1.6 mm fillet.
- The cap slopes approximately with the struts, reducing the ledge near the
  socket mouths. CAD samples along socket centerlines show about 3–4 mm proud of
  the wood near the mouths, rather than approximately 7–8 mm for the flat version.
- Screw access and screw heads are on the interior side. The cuts stop inside
  the bores rather than opening through the fabric-facing cap.
- The circular dowel seat now has a short, flat-topped arch above it. Its
  approximately 5.5 mm bridge avoids a tall teardrop point under the cloth.

The surface is a fabric-facing prototype, not a claim that the finished print
will be perfectly flush or snag-free. FDM layer steps and the actual cloth tension
still matter. Test one printed hub with the real cloth before printing the set.

## Print files

- `cloth-4-way-A.stl` — 5 copies
- `cloth-4-way-B.stl` — 5 copies
- `cloth-5-way.stl` — 6 copies
- `cloth-6-way.stl` — 10 copies
- `cloth-socket-test.stl` — optional small fit/bridge/fabric test

Matching STEP files are provided, along with `dome-cloth-assembly.step`.
`design-comparison.png` shows the rounded OUTSIDE of all four hub variants.
`cloth-interface-profile.png` compares the real CAD outside profile to the old
flat face and the dowel surface along one long socket.

## Slicer estimates

Measured with the installed Bambu Studio 2.8.2.61 using an A1, 0.8 mm nozzle,
Bambu PLA Basic, textured PEI plate, 3 walls, 15% grid infill, 3 top/bottom layers,
supports off, and no brim. These are model print-time estimates; add about six
minutes of startup per plate.

| Model | Layer height | Print time | Filament |
| --- | --- | --- | --- |
| Previous flat-outside six-way | 0.56 mm | 33 min 59 s | 34.35 g |
| Rounded six-way | 0.56 mm | 36 min 49 s | 39.53 g |
| Rounded six-way | 0.40 mm | 38 min 51 s | 37.59 g |
| Rounded five-way | 0.56 mm | 33 min 2 s | 35.57 g |
| Rounded four-way A | 0.56 mm | 27 min 27 s | 29.29 g |
| Rounded socket test | 0.56 mm | 12 min 38 s | 12.80 g |

The 0.40 mm profile is a useful starting point for the cloth-contact surface:
it has smaller layer steps and costs only about two extra minutes on a six-way.
At 0.56 mm, all 26 hubs total roughly 14 hours and 902 g of PLA Basic, before
startup, treating the mirrored four-way B as equivalent to A. Batch parts per
plate. Physical print, fabric abrasion, and joint strength are still untested.

## Dowel cuts and fitting

The mathematical nodes, socket axes, and blind stops are unchanged. Use the
existing dome assembly map and these same cuts:

- 30 short 1/2-inch dowels: 337.87 mm / 13.302 inches
- 35 long 1/2-inch dowels: 386.00 mm / 15.197 inches

The nominal circular seat is 13.30 mm for a 12.70 mm dowel. Insertion at the mouth
center is 18 mm. Four-way A/B alternate around the base. There are no short-strut
dimples in this design; mark the connection types from the original node map.

The 3.6 mm screw access holes enter from the flat interior face. Predrill the wood
and choose a screw length on the test piece so the tip stays inside the wood and
cannot emerge through the cloth side.

## Verification and regeneration

All four reimported hub STEP files are one valid solid. Nominal dowels placed in
every socket have zero CAD interference. The full assembly reimports as 91 valid
solids: 26 hubs and 65 dowels. This verifies the digital geometry, not the physical
fit of nominal dowel stock or the behavior of the fabric.

```sh
/tmp/codex-cadquery-venv/bin/python dome-assembly/cloth_hubs.py --all --assembly
python3 dome-assembly/benchmark_hubs.py --material pla --styles cloth --layer-height 0.56
```

Slice projects and logs are retained under `../optimized/slicing/cloth-*`.
