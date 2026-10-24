# BOSYTRO 480 W PSU safety tunnel

This is a two-ended rectangular safety tunnel for the BOSYTRO
SJK-24V-480W power supply. It recesses the complete terminal/IEC face rather
than trying to route each cable through a fitted opening.

## Design

- Measured PSU cross-section: **113.09 × 51.26 mm**
- Total modeled clearance: **0.80 mm** (0.40 mm nominally per side)
- Front recess: **55 mm**
- PSU overlap: **40 mm**
- Total tunnel length: **95 mm**
- Wall thickness: **3 mm**
- Internal stop lip: **3 mm**
- Side retention openings: **5.5 × 9 mm capsule slots**
- Mounting ears: four **3.6 mm** holes for M3 fasteners, with **2 mm top-root fillets**

The PSU slides through the rear opening until its front metal perimeter meets
the internal stop. The entire switch, IEC inlet, terminals, and cables remain
inside one unobstructed opening. Four side slots align approximately with the
PSU mounting holes 31 mm behind the terminal face. The sleeve has no additional
ventilation cutouts; both ends of the tunnel remain completely open.

## Files

- `output/bosytro-480w-fit-gauge.stl` — print this first to verify clearance.
- `output/bosytro-480w-tunnel-print-orientation.stl` — recommended printable STL.
- `output/bosytro-480w-tunnel-assembly.stl` — assembly orientation for CAD/reference.
- Matching `.step` files — editable neutral CAD solids.
- `output/bosytro-480w-tunnel-preview.svg` — generated isometric drawing.
- `generate_tunnel.py` — parametric CadQuery/OpenCascade source and exporter.

No Blender files or Blender modeling are used.

## Printing

Print the `print-orientation` STL with the large front opening on the build
plate. Suggested starting point:

- PETG or ASA
- 0.20 mm layers
- 4 perimeters
- 5 top/bottom layers
- 25–35% infill
- No support expected; inspect the slicer preview around the small horizontal
  fastener openings.

Print the fit gauge before the complete part. It should slide over the metal
chassis without force and without obvious side-to-side movement. Change
`FIT_CLEARANCE` in `generate_tunnel.py` if required.

## Fasteners and safety

The PSU holes appear likely to be M4, but confirm the thread before assembly.
Use washers on the printed slots. Use only screws short enough for the PSU
manufacturer's permitted penetration depth; an overlong screw can contact
internal live circuitry. Never force an uncertain thread.

This part is an accidental-contact and cable-snag guard, not a certified
electrical enclosure. Disconnect mains power before installing or servicing it.
