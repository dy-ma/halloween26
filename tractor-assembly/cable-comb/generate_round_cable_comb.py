"""Parametric six-wire round cable comb for the tractor harness.

The default dimensions target six approximately 1.40 mm OD insulated wires.
The wires sit around a circular pitch, making a compact and traceable bundle.

Run with the project CadQuery environment:

    /tmp/codex-cadquery-venv/bin/python generate_round_cable_comb.py

Outputs are written to the adjacent ``output`` directory in STEP, STL, and
SVG formats. Dimensions are millimetres.
"""

from __future__ import annotations

import math
from pathlib import Path

import cadquery as cq
from cadquery import exporters


# ---------------------------------------------------------------------------
# Harness dimensions
# ---------------------------------------------------------------------------

WIRE_COUNT = 6
WIRE_DIAMETER = 1.40

# Clearance is on diameter. The nominal 1.65 mm seat allows the wire to slide
# without rattling excessively on a typical 0.4 mm-nozzle FDM print.
FIT_CLEARANCE = 0.25
SEAT_DIAMETER = WIRE_DIAMETER + FIT_CLEARANCE

# The entry is narrower than the insulation so each wire snaps into place.
# PETG is preferred; for brittle PLA, increase this to 1.15-1.25 mm.
SNAP_OPENING = 1.05

# Wire centers lie on this radius. At 2.65 mm, adjacent 1.65 mm seats retain
# about 1.0 mm of printable material between them.
PITCH_RADIUS = 2.65

OUTER_DIAMETER = 10.50
COMB_LENGTH = 4.00

# A shallow pin-1 witness notch makes multiple combs easy to orient the same
# way. Pin 1 is the seat whose entry points toward +X.
PIN1_NOTCH_WIDTH = 1.20
PIN1_NOTCH_DEPTH = 0.60


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"


def cylinder(radius: float, height: float, x: float, y: float, z0: float = 0.0) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        height,
        cq.Vector(x, y, z0),
        cq.Vector(0, 0, 1),
    )
    return cq.Workplane(obj=solid)


def radial_slot(angle_deg: float, width: float) -> cq.Workplane:
    """Cutter running from a wire seat through the outside perimeter."""
    radius = OUTER_DIAMETER / 2.0
    cutter_length = radius - PITCH_RADIUS + SEAT_DIAMETER
    center_x = PITCH_RADIUS + cutter_length / 2.0
    slot = (
        cq.Workplane("XY")
        .box(cutter_length, width, COMB_LENGTH + 2.0)
        .translate((center_x, 0.0, COMB_LENGTH / 2.0))
    )
    return slot.rotate((0, 0, 0), (0, 0, 1), angle_deg)


def base_disk() -> cq.Workplane:
    return cq.Workplane("XY").circle(OUTER_DIAMETER / 2.0).extrude(COMB_LENGTH)


def cut_wire_seats(model: cq.Workplane, snap_openings: bool) -> cq.Workplane:
    for index in range(WIRE_COUNT):
        angle_deg = index * 360.0 / WIRE_COUNT
        angle_rad = math.radians(angle_deg)
        x = PITCH_RADIUS * math.cos(angle_rad)
        y = PITCH_RADIUS * math.sin(angle_rad)

        model = model.cut(cylinder(SEAT_DIAMETER / 2.0, COMB_LENGTH + 2.0, x, y, -1.0))
        if snap_openings:
            model = model.cut(radial_slot(angle_deg, SNAP_OPENING))
    return model


def add_pin1_notch(model: cq.Workplane) -> cq.Workplane:
    radius = OUTER_DIAMETER / 2.0
    notch = (
        cq.Workplane("XY")
        .box(PIN1_NOTCH_DEPTH + 0.2, PIN1_NOTCH_WIDTH, COMB_LENGTH + 2.0)
        .translate((radius - PIN1_NOTCH_DEPTH / 2.0, 1.55, COMB_LENGTH / 2.0))
    )
    return model.cut(notch)


def build_comb(snap_openings: bool) -> cq.Workplane:
    model = cut_wire_seats(base_disk(), snap_openings)
    model = add_pin1_notch(model)
    return model.clean()


def build_fit_gauge() -> cq.Workplane:
    """Three snap seats to check printer compensation before a full batch."""
    diameters = (1.55, 1.70, 1.85)
    openings = (0.95, 1.05, 1.15)
    pitch = 4.25
    width = 3.4
    length = pitch * (len(diameters) - 1) + 4.0

    gauge = cq.Workplane("XY").box(length, width, COMB_LENGTH)
    x0 = -pitch * (len(diameters) - 1) / 2.0

    for index, (diameter, opening) in enumerate(zip(diameters, openings)):
        x = x0 + index * pitch
        gauge = gauge.cut(cylinder(diameter / 2.0, COMB_LENGTH + 2.0, x, 0.0, -1.0))
        slot_length = width / 2.0 + diameter
        slot = (
            cq.Workplane("XY")
            .box(opening, slot_length, COMB_LENGTH + 2.0)
            .translate((x, width / 2.0, COMB_LENGTH / 2.0))
        )
        gauge = gauge.cut(slot)

    return gauge.clean()


def validate(label: str, model: cq.Workplane) -> None:
    solids = model.solids().vals()
    if len(solids) != 1:
        raise RuntimeError(f"{label}: expected one solid, found {len(solids)}")
    if not solids[0].isValid():
        raise RuntimeError(f"{label}: OpenCascade reports an invalid solid")

    bounds = solids[0].BoundingBox()
    print(
        f"{label}: valid solid; "
        f"size={bounds.xlen:.2f} x {bounds.ylen:.2f} x {bounds.zlen:.2f} mm; "
        f"volume={solids[0].Volume():.2f} mm^3"
    )


def export_model(model: cq.Workplane, stem: str) -> None:
    exporters.export(model, str(OUT / f"{stem}.step"), exportType="STEP")
    exporters.export(
        model,
        str(OUT / f"{stem}.stl"),
        exportType="STL",
        tolerance=0.025,
        angularTolerance=0.08,
    )


def export_preview(model: cq.Workplane) -> None:
    exporters.export(
        model,
        str(OUT / "round-six-wire-cable-comb-preview.svg"),
        exportType="SVG",
        opt={
            "width": 900,
            "height": 900,
            "marginLeft": 40,
            "marginTop": 40,
            "projectionDir": (0.0, 0.0, 1.0),
            "showAxes": False,
            "showHidden": False,
            "strokeWidth": 0.025,
        },
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    snap_comb = build_comb(snap_openings=True)
    closed_comb = build_comb(snap_openings=False)
    fit_gauge = build_fit_gauge()

    validate("snap-in comb", snap_comb)
    validate("closed-hole comb", closed_comb)
    validate("fit gauge", fit_gauge)

    export_model(snap_comb, "round-six-wire-cable-comb-snap-in")
    export_model(closed_comb, "round-six-wire-cable-comb-closed")
    export_model(fit_gauge, "round-six-wire-cable-comb-fit-gauge")
    export_preview(snap_comb)

    print(f"Generated cable-comb files in {OUT}")


if __name__ == "__main__":
    main()
