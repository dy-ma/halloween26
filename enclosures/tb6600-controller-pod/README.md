# TB6600 controller bumper

This is a deliberately simple removable bumper for the photographed TB6600,
69.96 × 30.20 mm perfboard, XIAO ESP32-S3, and
26.71 × 18.37 × 8.13 mm LiPo.

The perfboard itself is the platform. There is no raised tray, second shelf,
or battery pocket.

## Three features

1. One shallow perimeter bumper supports the perfboard at its four M2 holes.
2. Two flexible rear arms wrap around the driver's flat body and hook into the
   small side vents. They remain centered in their original position. Nothing
   clips to the heatsink or mounting ears.
3. Two enclosed 7.50 x 2.20 mm windows accept a narrow soft Velcro One-Wrap
   strap without leaving a fragile open-bottom bridge.
   The strap loops beneath the perfboard and gently over the battery, adapting
   to the real pouch thickness without a rigid printed clip.

The antenna wall was intentionally removed after the first physical print. For
now the antenna remains unsupported rather than making the bumper difficult to
orient and print. Removing it also returns the perimeter rails to their original
2.40 mm thickness instead of the wider antenna-matching rails.

## Board fit and battery strap

The cavity is 1.50 mm larger than the measured perfboard in both axes, providing
0.75 mm nominal clearance on every edge. This adds 1.00 mm overall clearance
relative to the successful test print so small wall artifacts do not prevent the
board from seating. The four M2 hole centers remain at their measured positions;
only the perimeter moves outward.

Thread a roughly 6 mm-wide soft Velcro strap through the two enclosed windows and
under the perfboard before tightening its M2 screws. Bring the strap gently over
the battery and fasten it without compressing the pouch. Avoid a narrow hard
zip tie across the battery.

## M2 mounting

Boss centers use the measured 1.075 mm board-edge-to-hole-edge gap and an
initial 2.20 mm board-hole assumption. The current heat-set pockets are
3.20 mm diameter × 4.20 mm deep, with a 3.80 mm × 0.60 mm lead-in at the top.

Print `output/tb6600-controller-pod-m2-insert-gauge.stl` first. It contains
3.10, 3.20, and 3.30 mm blind pockets so the real inserts can be checked before
printing the bumper.

## Vent fit test

The directly measured vent slot is 2.83 mm wide. The complete bumper and every
test gauge now use a 2.30 mm-wide hook, leaving about 0.26 mm nominal clearance
on each side. The filenames below describe hook reach/depth, not hook width:

1. `output/tb6600-vent-fit-w2p3-d1p2.stl`
2. `output/tb6600-vent-fit-w2p3-d1p6.stl`
3. `output/tb6600-vent-fit-w2p3-d2p0.stl`

These are the vent-fit parts; they are unrelated to the battery clip. Try the
1.2 mm reach first. The right gauge should enter without force, retain under a
gentle pull, and release when flexed outward. Set `HOOK_REACH_X` in the
generator to the best result. The complete model currently uses 1.60 mm.

## Output files

- `output/tb6600-controller-pod.stl` — the single-piece bumper
- Matching STEP files — editable CAD
- SVG and PNG orthographic/preview views

## Print and safety

- Use PETG at minimum; ASA is preferable if the driver runs warm. Do not use
  PLA against a motor driver.
- The included 3MF targets a Bambu Lab A1 with a 0.8 mm nozzle and Generic
  PETG: 0.32 mm layers, three 0.82 mm walls, five top/bottom layers, and 20%
  gyroid infill.
- It uses 45 mm/s outer walls, 60 mm/s inner walls, 25 mm/s bridges, tree-auto
  supports from the build plate only, and a 6 mm auto brim.
- The embedded starting temperatures are 255 C nozzle and 80 C textured bed.
  Use the filament maker's temperature range if it differs.
- Print hook gauges in the same material and orientation as the full snap arms.
- Keep the LiPo away from a driver that warms its mounting face. Never install
  a swollen or damaged pouch, and do not tighten the strap against its center.

## Generate

```sh
XDG_CACHE_HOME=/tmp/codex-cad-cache \
  /tmp/codex-cadquery-venv/bin/python generate_controller_pod.py
```

The script verifies that every exported part is one valid OpenCascade solid,
checks the nominal board and battery clearances, and exports STEP, STL, SVG,
and PNG files into `output/`.
