"""Parametric flat six-wire cable comb for the tractor harness.

The default dimensions target six approximately 1.40 mm OD insulated wires.
Run with:

    /tmp/codex-cadquery-venv/bin/python generate_flat_cable_comb.py

Outputs are written to the adjacent ``output`` directory. Dimensions are mm.
"""

from __future__ import annotations

from pathlib import Path

import cadquery as cq
from cadquery import exporters


WIRE_COUNT = 6
WIRE_DIAMETER = 1.40
FIT_CLEARANCE = 0.25
SEAT_DIAMETER = WIRE_DIAMETER + FIT_CLEARANCE
SNAP_OPENING = 1.05

WIRE_PITCH = 2.45
SIDE_WALL = 1.25
BOTTOM_WALL = 1.20
TOP_MARGIN = 1.60
COMB_LENGTH = 4.00

# A small notch above wire 1 makes both ends easy to orient consistently.
PIN1_NOTCH_WIDTH = 0.80
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


def dimensions() -> tuple[float, float, float]:
    width = (WIRE_COUNT - 1) * WIRE_PITCH + SEAT_DIAMETER + 2.0 * SIDE_WALL
    seat_center_y = BOTTOM_WALL + SEAT_DIAMETER / 2.0
    height = seat_center_y + SEAT_DIAMETER / 2.0 + TOP_MARGIN
    return width, height, seat_center_y


def base_plate() -> cq.Workplane:
    width, height, _ = dimensions()
    return (
        cq.Workplane("XY")
        .box(width, height, COMB_LENGTH)
        .translate((0.0, height / 2.0, COMB_LENGTH / 2.0))
    )


def build_comb(snap_openings: bool) -> cq.Workplane:
    width, height, seat_center_y = dimensions()
    x0 = -(WIRE_COUNT - 1) * WIRE_PITCH / 2.0
    model = base_plate()

    for index in range(WIRE_COUNT):
        x = x0 + index * WIRE_PITCH
        model = model.cut(
            cylinder(SEAT_DIAMETER / 2.0, COMB_LENGTH + 2.0, x, seat_center_y, -1.0)
        )

        if snap_openings:
            slot_height = height - seat_center_y + SEAT_DIAMETER
            slot = (
                cq.Workplane("XY")
                .box(SNAP_OPENING, slot_height, COMB_LENGTH + 2.0)
                .translate((x, seat_center_y + slot_height / 2.0, COMB_LENGTH / 2.0))
            )
            model = model.cut(slot)

    # Pin-1 witness notch at the upper-left edge. It does not weaken the first
    # snap finger or touch the wire seat.
    notch_x = -width / 2.0 + PIN1_NOTCH_WIDTH / 2.0
    notch = (
        cq.Workplane("XY")
        .box(PIN1_NOTCH_WIDTH, PIN1_NOTCH_DEPTH + 0.2, COMB_LENGTH + 2.0)
        .translate((notch_x, height - PIN1_NOTCH_DEPTH / 2.0, COMB_LENGTH / 2.0))
    )
    return model.cut(notch).clean()


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
        str(OUT / "flat-six-wire-cable-comb-preview.svg"),
        exportType="SVG",
        opt={
            "width": 1100,
            "height": 500,
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

    validate("flat snap-in comb", snap_comb)
    validate("flat closed-hole comb", closed_comb)

    export_model(snap_comb, "flat-six-wire-cable-comb-snap-in")
    export_model(closed_comb, "flat-six-wire-cable-comb-closed")
    export_preview(snap_comb)

    print(f"Generated flat cable-comb files in {OUT}")


if __name__ == "__main__":
    main()
