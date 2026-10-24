# Six-wire cable combs

This compact cable comb is sized for six approximately 1.4 mm OD insulated
wires. The wire seats are arranged around a circular pitch so the harness stays
round and every conductor has a repeatable position.

The folder also includes a flat six-position version. Its left-to-right order
is the easiest arrangement to trace and it is the quickest first print.

## Included versions

- `round-six-wire-cable-comb-snap-in`: six radial snap openings; installable
  after the connector is assembled.
- `round-six-wire-cable-comb-closed`: closed holes; thread the conductors before
  terminating the connector.
- `round-six-wire-cable-comb-fit-gauge`: three seats measuring 1.55, 1.70, and
  1.85 mm. Print this first if the wire or printer calibration is uncertain.
- `flat-six-wire-cable-comb-snap-in`: six snap-in seats arranged in one row.
- `flat-six-wire-cable-comb-closed`: closed-hole version of the flat comb.

The shallow notch beside the first radial opening marks conductor 1. Install
multiple combs with their notches facing the same direction to preserve the
wire order along the harness.

## Default dimensions

- Wire OD: 1.40 mm
- Nominal seat: 1.65 mm
- Snap opening: 1.05 mm
- Overall diameter: 10.50 mm
- Length along the cable: 4.00 mm

## Printing

Print flat on either circular face with no supports. PETG is preferred for the
snap-in version. Use 0.2 mm layers, at least three perimeters, and 100% infill;
the part is tiny, so the infill choice has little practical cost. PLA is fine
for the closed-hole version.

Print the fit gauge before a batch. If the nominal 1.70 mm seat is too tight or
loose, adjust `FIT_CLEARANCE` and regenerate.

## Regenerating

```sh
/tmp/codex-cadquery-venv/bin/python generate_round_cable_comb.py
```

The script exports editable STEP and printable STL files into `output/`.

Generate the flat version with:

```sh
/tmp/codex-cadquery-venv/bin/python generate_flat_cable_comb.py
```
