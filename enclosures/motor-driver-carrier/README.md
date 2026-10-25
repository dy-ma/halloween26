# Motor-driver carrier

This is an open, single-piece carrier for the custom controller PCB and the
BTS 7960 motor-driver module.  It deliberately leaves both component faces,
the controller JST connectors, the BTS screw terminals, and the BTS heatsink
uncovered.

## Layout

- The **90 × 52 mm controller PCB** sits in a low perimeter bumper.
- Four bosses use the measured **78.11 × 35.33 mm** hole-center pattern.
- Each boss has a **3.20 mm × 4.20 mm** pocket plus a short lead-in for an M2
  heat-set insert.
- The supplied BTS 7960 standoff is rotated with its square frame against the
  floor and its four screw-in prongs pointing upward, then joined to the right
  side with two low bridges.
- The four BTS posts have opposing horizontal **D-flats** for the rectangular
  heatsink: the left pair faces right and the right pair faces left.  The posts
  are reinforced on their outer sides, and each root has two extended exterior
  triangular gussets that overlap the post and floor frame.  The flats recover
  about **3 mm** across opposing posts without moving the screw centers.
- A top-loading battery tray sits below the unused right-hand portion of the
  controller PCB.  The installed PCB becomes its roof, so the battery cannot
  fall out.  A relief at the tray's rear-left corner matches the battery lead
  location shown in the reference photo.
- A **16 × 13.3 mm** portal through the controller bumper's left wall lets the
  complete two-pin JST housing—not just its wires—pass between the top and
  underside of the board.
- Four M4-clearance mounting ears project from the controller bumper corners.
  Their hole centers are 8 mm outside the walls, leaving room for a washer and
  vertical driver even when both boards remain installed.

The main side-by-side body is about **148 × 57 × 39 mm**.  The complete print
is about **149.8 × 87.3 × 39 mm** including the four mounting ears and outward
BTS-post reinforcement.

The model, validation, drawings, STEP, and STL are generated entirely with
**CadQuery/OpenCascade**.  Blender is not used.

## Important dimensions to verify

The hole-center pattern is based on the supplied measurements.  These values
remain estimates from the photos and should be checked with calipers before a
full print:

- PCB outside size: `PCB_WIDTH`, `PCB_DEPTH`
- Actual M2 insert outside diameter and length:
  `INSERT_POCKET_DIAMETER`, `INSERT_POCKET_DEPTH`
- Battery pouch size, including tape and wrinkles:
  `BATTERY_WIDTH`, `BATTERY_LENGTH`, `BATTERY_THICKNESS`

All are grouped near the top of `generate_carrier.py`.

## Files

- `output/motor-driver-carrier.stl` — ready to slice in the modeled flat
  orientation.
- `output/motor-driver-carrier.step` — editable solid CAD.
- `output/motor-driver-carrier-fit-gauge.stl` — small first print that checks
  one insert pocket and the battery-tray cross-section.
- `output/bts7960-d-flat-fit-test.stl` — standalone revised BTS bracket for
  checking heatsink clearance before printing the complete carrier.
- `output/motor-driver-carrier-preview.svg` and `.png` — generated isometric
  drawing; the matching `motor-driver-carrier-top` files show all four ears.
- `reference/BTS 7960 Standoff.step` — supplied source standoff used by the
  generator.

### Removable vertical-battery sidecar

- `output/vertical-battery-sidecar-wing-mount.stl` — separate printable
  sidecar for the 67 × 36 × 10 mm battery.  It bolts above either matching
  pair of long-side wing tabs and leaves the USB-C end open.
- `output/vertical-battery-sidecar-wing-mount.step` — editable sidecar solid.
- `output/vertical-battery-sidecar-wing-mount-assembly.step` — the revised
  four-wing carrier and sidecar shown in their installed positions.
- `output/vertical-battery-sidecar-wing-mount-fit-check.step` — assembly plus
  the battery envelope and two M3 fastener proxies.  The sidecar uses a
  continuous bottom foot and full-length attachment rail rather than isolated
  mounting ears.

### Single-piece integrated vertical-battery carrier

- `output/motor-driver-carrier-integrated-vertical-battery.stl` — the revised
  motor-driver carrier and vertical battery holder fused into one printable
  solid, with no overlapping attachment hardware.
- `output/motor-driver-carrier-integrated-vertical-battery.step` — editable
  single-solid STEP.
- `output/motor-driver-carrier-integrated-vertical-battery-fit-check.step` —
  integrated carrier plus the 67 × 36 × 10 mm battery envelope.

The integrated holder uses a top-open access window instead of a closed
rectangular window, removing its long horizontal bridge.  Print it flat in the
exported orientation; the battery holder and carrier do not require generated
supports.  The obsolete small-battery sled beneath the controller PCB is
removed from this integrated revision.  The outer 13.5 × 4 mm Velcro slot
begins at floor level.  The inner
slot is raised above the adjacent controller-bumper wall, avoiding a narrow
enclosed passage between the two printed walls.  Thread the strap through the
low outer slot, across the pocket floor beneath the battery, upward inside the
inner wall, and out the raised slot before closing it over the battery.  The
printed underside is flat; there is no recessed strap channel beneath the part.

## Generate

```sh
/tmp/codex-cadquery-venv/bin/python generate_carrier.py
magick -background white output/motor-driver-carrier-preview.svg \
  output/motor-driver-carrier-preview.png
```

## Print and assembly

- Print flat as exported; no support should be needed.
- PETG is a good default around a warm motor driver.  Use 4 perimeters and
  25–35% infill as a starting point.
- Print the fit gauge before the full carrier.
- Heat the M2 inserts into the four bosses before installing the PCB.  Stop
  when each insert is flush; driving it deeper can soften the battery area.
- Place the battery into the lower tray, route its corner lead through the tray
  relief, and bring the XIAO pigtail through the left-side bumper portal before
  attaching the controller PCB.  Keep the pouch away from sharp solder tails
  and verify that it does not contact the PCB underside when the board is
  tightened.
- Do not enclose the BTS heatsink or operate the assembly where loose metal can
  bridge the exposed terminals.
