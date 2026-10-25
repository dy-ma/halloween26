# TB6600 controller and battery pod

This is a removable TB6600-mounted carrier for the measured
69.96 × 30.20 mm perfboard and 65.63 × 36.22 × 10.00 mm LiPo.
The battery, perfboard, and TB6600 face are parallel: broad rectangular face to
broad rectangular face. Only the battery's 10 mm thickness adds to the stack.

## Layout

1. The carrier is one continuous 76.66 × 42.92 mm rounded outer box rather than
   a battery tray joined to a smaller PCB frame. A 67.13 × 37.72 mm battery
   tunnel and a 71.46 × 31.70 mm PCB pocket are subtracted from that body.
2. The installed top (+Y) edge of the battery tunnel is fully open, so the
   battery slides in on its broad face after the perfboard has already been
   screwed down. The 11.00 mm-high insertion opening provides 0.75 mm nominal
   clearance around each battery edge and 1 mm over its measured thickness.
3. Two 14.00 × 3.20 mm rounded floor slots and a recessed underside channel
   accept the 12.37 mm soft Velcro One-Wrap shown in the reference carrier.
   Loosen the strap, slide the pouch through the open edge, then close the
   strap across its exposed broad face.
4. The perfboard sits parallel to the battery with 5.00 mm between the battery
   envelope and board underside. This space accommodates the Velcro overlap,
   solder projections, and the bottoms of the M2 inserts.
5. Four M2 bosses merge directly into the continuous outer wall and remain
   above the battery rather than passing through its footprint.
6. Four flexible arms form two snap pairs around the TB6600. Each arm continues
   into a 4.50 mm-wide reinforcing rib that runs up the box to the PCB seating
   plane. This replaces the former short, expanded root blocks while retaining
   the 2.30 mm-wide hooks.

The driver-facing floor is 3.20 mm thick, the battery top is 13.20 mm above
that reference face, and the perfboard seat is at 18.20 mm. The single outer
wall ends at 20.45 mm—less than half the height of the rejected upright layout.

## Snap-arm spacing

The directly measured vent opening is 2.83 mm wide. The measured clear gap
between the nearest facing edges of the two selected vents is 27.00 mm, so the
model derives a 29.83 mm center-to-center spacing. The arm pairs are placed
symmetrically at Y = ±14.915 mm.

The complete pod and every hook test gauge use a 2.30 mm-wide hook, leaving
about 0.265 mm nominal clearance on each side of a vent. The complete model
uses the previously selected 1.60 mm hook reach.

Print `output/tb6600-dual-vent-spacing-fit-w2p3-gap27p0-d1p6.stl` before the
complete pod. Its two flexible tines check the derived 29.83 mm center spacing
against one side of the driver.

## Board and battery fit

The board cavity remains 1.50 mm larger than the measured perfboard in both
axes, providing 0.75 mm nominal edge clearance per side. The four M2 hole
centers remain tied to the measured board positions.

The battery is wider than the perfboard and projects about 3 mm beyond each
long board edge. This is intentional and keeps the pouch flat while leaving
its edges and strap accessible. The perfboard does not need to be removed for
battery insertion or replacement.

Boss centers use the measured 1.075 mm board-edge-to-hole-edge gap and an
initial 2.20 mm board-hole assumption. The current heat-set pockets are
3.20 mm diameter × 4.20 mm deep, with a 3.80 mm × 0.60 mm lead-in at the top.
Their lower faces maintain 0.60 mm nominal vertical clearance over the battery
envelope.

Print `output/tb6600-controller-pod-m2-insert-gauge.stl` first. It contains
3.10, 3.20, and 3.30 mm blind pockets for checking the actual inserts.

## Output files

- `output/tb6600-controller-pod.stl` — printable one-piece pod
- `output/tb6600-controller-pod.step` — editable solid CAD
- `output/tb6600-controller-pod-fit-check.step` — pod plus separate, parallel
  battery and perfboard envelopes
- `output/tb6600-controller-pod.3mf` — Bambu Lab A1 / 0.8 mm PETG project
- `output/tb6600-controller-pod-dimensions.png` and `.svg` — dimensioned plan
  view, clip spacing, nominal fit dimensions, and Z-stack values
- `output/tb6600-dual-vent-spacing-fit-w2p3-gap27p0-d1p6.stl` — small
  two-hook spacing coupon
- Matching SVG and PNG orthographic/preview views

## Print and safety

- Use PETG at minimum; ASA is preferable if the driver runs warm. Do not use
  PLA against a motor driver.
- The included 3MF targets a Bambu Lab A1 with a 0.8 mm nozzle and Generic
  PETG. It stands the part on its closed long wall so the battery tunnel and
  PCB pocket print vertically rather than becoming broad supported ceilings.
- The quality profile uses 0.24 mm layers, three structural perimeters, six
  top/bottom layers, and 20% gyroid infill. Visible outer walls run at 30 mm/s
  with 1000 mm/s² acceleration; inner walls run at 45 mm/s.
- Tree-auto supports are build-plate-only with three 0.24 mm interface layers.
  They should contact only the accessible undersides of the external snap ribs.
  An 8 mm brim stabilizes the edge-standing print.
- Dry PETG before printing; 60–65 °C for roughly 4–6 hours is a useful starting
  point when permitted by the filament manufacturer. Moist PETG is a common
  cause of fuzz, pitting, strings, and inconsistent glossy/matte surfaces.
- Run the printer's flow-dynamics and flow-rate calibration for the actual
  spool and 0.8 mm nozzle. The included temperature starts at 255 °C and then
  uses 250 °C, but the filament maker's specified range takes precedence.
- Keep the closed long wall on the plate when opening the 3MF; do not use an
  automatic reorientation that puts either broad cavity horizontal.
- Print the hook gauges in the same material and orientation as the pod arms.
- The 3.20 mm printed floor separates the pouch from the TB6600 face but is not
  a thermal insulator. Check pouch temperature during a representative loaded
  run before leaving the assembly unattended.
- Never install a swollen or damaged pouch, and do not tighten the strap
  against the center of the cell.

## Generate

```sh
XDG_CACHE_HOME=/tmp/codex-cad-cache \
  /tmp/codex-cadquery-venv/bin/python generate_controller_pod.py
python build_3mf.py
```

The generator verifies that every printable part is one valid OpenCascade
solid, checks board and battery interference plus the +Y slide-in path, reports
the derived vent spacing, and exports STEP, STL, SVG, and PNG files into
`output/`.
