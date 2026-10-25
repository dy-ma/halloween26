# Minimal steering-wheel horn retrofit

This revision deliberately keeps the mechanism that already works:

- the original upper and lower steering-wheel parts stay unchanged;
- the original rounded `clacson.stl` horn stays unchanged;
- the existing metal springs continue to provide the motion and return force.

Only two new printed parts are required: a small adjustable switch saddle and
one open battery/PCB tray.

![Minimal retrofit layout](../output/steering-wheel/minimal/minimal-retrofit-preview.png)

## 1. Sliding limit-switch saddle

`minimal-switch-saddle.stl` holds the photographed full-size roller switch next
to the edge of the original horn flange. The horn flange moves past the lever
when the horn is pressed; the switch is not placed at the bottom of the case and
must not act as the horn's hard stop.

![Switch placement close-up](../output/steering-wheel/minimal/switch-placement-closeup.png)

The saddle has:

- two 3.4 x 6 mm vertical switch slots on 22.2 mm centres;
- about 6 mm of click-height adjustment;
- two optional M3 attachment holes in the foot;
- a broad flat underside which can instead be attached with epoxy or VHB tape.

The switch is the full-size roller microswitch shown in `IMG_4830`, using the
standard 27.8 x 15.9 x 10.3 mm body and 22.2 mm mounting-hole spacing. Print
this small saddle first and physically verify the switch before final assembly.

### Positioning

1. Reassemble the original horn and metal springs.
2. Fasten the switch loosely to the saddle with M3 screws and nuts.
3. Place the saddle beside the original horn flange, with the metal lever under
   the flange's moving edge. The black switch body stays lower and farther out;
   only the lever and red roller point upward/inward into the travel path.
4. At rest, leave a small gap so the switch is released.
5. Press the horn and slide the switch in its slots until it clicks after about
   1.5-2 mm of travel, before the original mechanical stop.
6. Confirm reliable release, then fasten or bond the saddle to the fixed wheel
   wall. Do not glue the moving horn or spring surfaces.

## 2. Battery and PCB tray

`minimal-battery-pcb-tray.stl` is a single 19.2 mm shallow open tray intended
to sit in the centre space beneath the horn. The 67 x 36 x 10 mm battery slides
through the side opening. The board mounts above it, with its LED/component
side facing the translucent horn.

The board mount follows the DigiKey DKS-SOLDERBREAD-01 drawing rather than a
photo estimate:

- board: 48.26 x 50.80 x 1.60 mm;
- two 3.00 mm mounting holes;
- hole centres: 38.10 mm apart across the board centreline.

The printed bridge uses 2.8 mm pilot holes so ordinary M3 screws can form
threads in the 4.2 mm plastic thickness. Drill the pilots to 3.2 mm only if
changing to through-bolts and captive nuts.

Use a soft foam pad and a lightly tensioned hook-and-loop strap through the two
floor slots. Never pull a zip tie tightly around a pouch cell, and keep screws
away from the battery. The board sits at Z=17.2 mm and retains the battery from
above. The tray's two outer ears accept M3 screws; they may be clipped off when
using adhesive mounting.

### XIAO ESP32-S3 antenna

The outside of the tray's long wall includes a 40 x 18 x 0.6 mm shallow
adhesive pocket for the included 37.4 x 17.5 mm flexible 2.4 GHz antenna. A
3 mm open notch carries the 1.13 mm coax over the rim to the XIAO connector.
Install the antenna on the outside of the battery cavity, with plastic/air on
its exposed side; do not fold it around the battery or place foil, screws, or
the switch directly over it.

![Antenna placement](../output/steering-wheel/minimal/antenna-placement.png)

## Files

Print-ready files are in `output/steering-wheel/minimal/`:

- `original-rounded-horn-UNCHANGED.stl` - an unchanged copy of the supplied
  rounded horn, ready to reprint in translucent green PETG;
- `minimal-switch-saddle.stl` and `.step`;
- `minimal-battery-pcb-tray.stl` and `.step`;
- `minimal-retrofit-preview.png`.
- `switch-placement-closeup.png` - released and pressed switch positions.
- `spring-placement.png` - top and side views of the retained spring layer.

The older `prototype/` folder is not the recommended design. It is retained
only as design history; this minimal version supersedes it.

## Print settings

- PETG or PLA, 0.2 mm layers, 4 perimeters.
- Print the switch saddle with its broad foot on the bed.
- Print the tray with its closed floor on the bed; use supports only beneath
  the fixed PCB bridge if the slicer's bridge preview is poor.
- First fit the empty tray and switch. Install the battery only after verifying
  that no screw, sharp edge, or hot component can contact it.

## Regenerate

From the repository root:

```sh
PYTHONPATH=.mesh_tools ./.venv-cad/bin/python \
  steering-wheel-horn/generate_minimal_horn_retrofit.py \
  --out output/steering-wheel/minimal
```

The generator validates all three STL files as watertight and reports their
final dimensions.

## Complete assembly reference

The pieces are also positioned together in these view-only files:

- `complete-assembly-overview.png` - assembled and exploded views;
- `complete-assembly-reference.glb` - colored assembled model for orbiting;
- `complete-assembly-exploded.glb` - colored exploded model;
- `complete-assembly-VIEW-ONLY.stl` - multi-shell slicer reference, not a
  one-piece printable STL.

Assembly order from rear to front is: original lower half, blue electronics
tray, battery, PCB with LEDs facing forward/up, original upper half, the
existing metal springs, and the unchanged rounded horn. The springs remain
between the fixed support/spokes and the underside of the moving horn flange;
they do not sit in the electronics tray. The small switch saddle mounts beside
the horn flange, not underneath the horn.

![Spring placement](../output/steering-wheel/minimal/spring-placement.png)
