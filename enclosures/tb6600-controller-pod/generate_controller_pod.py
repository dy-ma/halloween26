"""Generate the intentionally simple TB6600 perfboard bumper.

The perfboard is the platform: this model adds only a shallow perimeter bumper,
four M2 insert bosses, two rear vent-snap arms, and two soft-strap windows.

Run with:

    XDG_CACHE_HOME=/tmp/codex-cad-cache \
      /tmp/codex-cadquery-venv/bin/python generate_controller_pod.py
"""

from __future__ import annotations

from pathlib import Path
import subprocess

import cadquery as cq
from cadquery import exporters


# Measured parts (millimetres)
BOARD_LENGTH = 69.96
BOARD_WIDTH = 30.20
BOARD_THICKNESS = 1.45
BOARD_HOLE_DIAMETER = 2.20
BOARD_EDGE_TO_HOLE_EDGE = 1.075
HOLE_CENTER_INSET = BOARD_EDGE_TO_HOLE_EDGE + BOARD_HOLE_DIAMETER / 2.0

BATTERY_LENGTH_Y = 26.71
BATTERY_WIDTH_X = 18.37
BATTERY_THICKNESS = 8.13
DRIVER_BODY_SPAN = 80.27

# Bumper fit
# Total cavity oversize. Hole centers stay tied to the measured board, while
# the perimeter moves outward to give 0.75 mm clearance on every board edge.
BOARD_CLEARANCE = 1.50
WALL = 2.40
BOARD_SEAT_Z = 6.00
BUMPER_HEIGHT = BOARD_SEAT_Z + BOARD_THICKNESS + 0.80
BOSS_DIAMETER = 7.60

# Heat-set inserts: change these to match the actual inserts after gauging.
INSERT_DIAMETER = 3.20
INSERT_DEPTH = 4.20
INSERT_LEAD_DIAMETER = 3.80
INSERT_LEAD_DEPTH = 0.60

# Driver vent snap. The three exported gauges bracket this uncertain dimension.
SNAP_CLEARANCE = 0.30
SNAP_ARM_THICKNESS = 2.40
SNAP_ARM_WIDTH_Y = 4.50
SNAP_ARM_DEPTH_Z = 11.10
SNAP_OFFSET_Y = 0.00
HOOK_REACH_X = 1.60
HOOK_HEIGHT_Z = 1.80
VENT_OPENING_WIDTH_Y = 2.83
HOOK_WIDTH_Y = 2.30

# Battery rests directly on the perfboard. A soft strap threads through two
# enclosed windows, underneath the PCB, and gently over the battery.
BATTERY_EDGE_CLEARANCE_X = 1.50
BATTERY_STRAP_WINDOW_X = 7.50
BATTERY_STRAP_WINDOW_Z = 2.20
BATTERY_STRAP_WINDOW_BOTTOM_Z = 2.20

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"

CAVITY_X = BOARD_LENGTH + BOARD_CLEARANCE
CAVITY_Y = BOARD_WIDTH + BOARD_CLEARANCE
OUTER_X = CAVITY_X + 2.0 * WALL
OUTER_Y = CAVITY_Y + 2.0 * WALL
LONG_RAIL = WALL

HOLE_X = BOARD_LENGTH / 2.0 - HOLE_CENTER_INSET
HOLE_Y = BOARD_WIDTH / 2.0 - HOLE_CENTER_INSET

BATTERY_CENTER_X = (
    BOARD_LENGTH / 2.0 - BATTERY_EDGE_CLEARANCE_X - BATTERY_WIDTH_X / 2.0
)


def box(size: tuple[float, float, float], center: tuple[float, float, float]) -> cq.Workplane:
    return cq.Workplane("XY").box(*size).translate(center)


def cylinder_z(radius: float, height: float, x: float, y: float, z0: float) -> cq.Workplane:
    return cq.Workplane(
        obj=cq.Solid.makeCylinder(
            radius,
            height,
            cq.Vector(x, y, z0),
            cq.Vector(0, 0, 1),
        )
    )


def cone_z(
    radius_bottom: float,
    radius_top: float,
    height: float,
    x: float,
    y: float,
    z0: float,
) -> cq.Workplane:
    return cq.Workplane(
        obj=cq.Solid.makeCone(
            radius_bottom,
            radius_top,
            height,
            cq.Vector(x, y, z0),
            cq.Vector(0, 0, 1),
        )
    )


def build_bumper() -> cq.Workplane:
    """One shallow perimeter bumper with integral bosses and vent snaps."""
    model = box(
        (OUTER_X, LONG_RAIL, BUMPER_HEIGHT),
        (0.0, OUTER_Y / 2.0 - LONG_RAIL / 2.0, BUMPER_HEIGHT / 2.0),
    )
    model = model.union(
        box(
            (OUTER_X, LONG_RAIL, BUMPER_HEIGHT),
            (0.0, -OUTER_Y / 2.0 + LONG_RAIL / 2.0, BUMPER_HEIGHT / 2.0),
        )
    )
    for x in (-OUTER_X / 2.0 + WALL / 2.0, OUTER_X / 2.0 - WALL / 2.0):
        model = model.union(box((WALL, OUTER_Y, BUMPER_HEIGHT), (x, 0.0, BUMPER_HEIGHT / 2.0)))

    # Four corner bosses touch both surrounding bumper walls. There is no tray.
    for x in (-HOLE_X, HOLE_X):
        for y in (-HOLE_Y, HOLE_Y):
            model = model.union(cylinder_z(BOSS_DIAMETER / 2.0, BOARD_SEAT_Z, x, y, 0.0))
            model = model.cut(
                cylinder_z(
                    INSERT_DIAMETER / 2.0,
                    INSERT_DEPTH + 0.10,
                    x,
                    y,
                    BOARD_SEAT_Z - INSERT_DEPTH,
                )
            )
            model = model.cut(
                cone_z(
                    INSERT_DIAMETER / 2.0,
                    INSERT_LEAD_DIAMETER / 2.0,
                    INSERT_LEAD_DEPTH,
                    x,
                    y,
                    BOARD_SEAT_Z - INSERT_LEAD_DEPTH + 0.05,
                )
            )

    # Enclosed windows accept a roughly 6 mm soft strap while retaining thick,
    # continuous rails above and below the cutout.
    for sign in (-1.0, 1.0):
        model = model.cut(
            box(
                (
                    BATTERY_STRAP_WINDOW_X,
                    WALL + 0.60,
                    BATTERY_STRAP_WINDOW_Z,
                ),
                (
                    BATTERY_CENTER_X,
                    sign * (OUTER_Y / 2.0 - WALL / 2.0),
                    BATTERY_STRAP_WINDOW_BOTTOM_Z
                    + BATTERY_STRAP_WINDOW_Z / 2.0,
                ),
            )
        )

    # Two simple rear arms wrap around the driver and hook into its side vents.
    arm_inner_x = DRIVER_BODY_SPAN / 2.0 + SNAP_CLEARANCE
    arm_center_abs_x = arm_inner_x + SNAP_ARM_THICKNESS / 2.0
    bridge_z = WALL / 2.0
    for sign in (-1.0, 1.0):
        bridge_inner_x = sign * OUTER_X / 2.0
        bridge_outer_x = sign * (arm_inner_x + SNAP_ARM_THICKNESS)
        bridge_center_x = (bridge_inner_x + bridge_outer_x) / 2.0
        bridge_length_x = abs(bridge_outer_x - bridge_inner_x) + 0.30
        model = model.union(
            box(
                (bridge_length_x, SNAP_ARM_WIDTH_Y, WALL),
                (bridge_center_x, SNAP_OFFSET_Y, bridge_z),
            )
        )

        arm_center_z = (WALL - SNAP_ARM_DEPTH_Z) / 2.0
        model = model.union(
            box(
                (SNAP_ARM_THICKNESS, SNAP_ARM_WIDTH_Y, SNAP_ARM_DEPTH_Z),
                (sign * arm_center_abs_x, SNAP_OFFSET_Y, arm_center_z),
            )
        )

        hook_center_x = sign * (arm_inner_x - HOOK_REACH_X / 2.0)
        hook_center_z = WALL - SNAP_ARM_DEPTH_Z + HOOK_HEIGHT_Z / 2.0
        model = model.union(
            box(
                (HOOK_REACH_X, HOOK_WIDTH_Y, HOOK_HEIGHT_Z),
                (hook_center_x, SNAP_OFFSET_Y, hook_center_z),
            )
        )
    return model.clean()


def build_insert_gauge() -> cq.Workplane:
    """Blind pockets at nominal insert diameter and +/-0.10 mm."""
    gauge = box((26.0, 12.0, 6.0), (0.0, 0.0, 3.0))
    for x, diameter in zip((-8.0, 0.0, 8.0), (3.10, 3.20, 3.30)):
        gauge = gauge.cut(cylinder_z(diameter / 2.0, INSERT_DEPTH + 0.10, x, 0.0, 6.0 - INSERT_DEPTH))
    return gauge.clean()


def build_hook_gauge(reach: float) -> cq.Workplane:
    """Small one-arm vent test; try the shallowest reach first."""
    arm = box((SNAP_ARM_THICKNESS, 10.0, 12.0), (SNAP_ARM_THICKNESS / 2.0, 0.0, 6.0))
    handle = box((18.0, 10.0, 3.0), (9.0, 0.0, 10.5))
    hook = box((reach, HOOK_WIDTH_Y, HOOK_HEIGHT_Z), (-reach / 2.0, 0.0, HOOK_HEIGHT_Z / 2.0))
    return arm.union(handle).union(hook).clean()


def validate(label: str, model: cq.Workplane) -> None:
    solids = model.solids().vals()
    if len(solids) != 1:
        raise RuntimeError(f"{label}: expected one solid, found {len(solids)}")
    if not solids[0].isValid():
        raise RuntimeError(f"{label}: OpenCascade reports an invalid solid")
    bounds = solids[0].BoundingBox()
    print(
        f"{label}: valid; {bounds.xlen:.2f} x {bounds.ylen:.2f} x {bounds.zlen:.2f} mm; "
        f"volume={solids[0].Volume():.1f} mm^3"
    )


def export_model(model: cq.Workplane, stem: str) -> None:
    exporters.export(model, str(OUT / f"{stem}.step"), exportType="STEP")
    exporters.export(
        model,
        str(OUT / f"{stem}.stl"),
        exportType="STL",
        tolerance=0.05,
        angularTolerance=0.10,
    )


def svg_to_png(svg: Path, png: Path, width: int, height: int) -> None:
    subprocess.run(
        [
            "rsvg-convert",
            "-b",
            "white",
            "-w",
            str(width),
            "-h",
            str(height),
            "-o",
            str(png),
            str(svg),
        ],
        check=True,
    )


def export_views(model: cq.Workplane) -> None:
    views = (
        ("preview", (1.0, -1.0, 0.75), False),
        ("top", (0.0, 0.0, 1.0), True),
        ("front", (0.0, -1.0, 0.0), True),
        ("side", (1.0, 0.0, 0.0), True),
    )
    for suffix, direction, hidden in views:
        svg = OUT / f"tb6600-controller-pod-{suffix}.svg"
        png = OUT / f"tb6600-controller-pod-{suffix}.png"
        exporters.export(
            model,
            str(svg),
            exportType="SVG",
            opt={
                "width": 1400,
                "height": 900,
                "marginLeft": 30,
                "marginTop": 30,
                "projectionDir": direction,
                "showAxes": False,
                "showHidden": hidden,
                "strokeWidth": 0.7,
            },
        )
        svg_to_png(svg, png, 1400, 900)

def validate_assembly_clearances(bumper: cq.Workplane) -> None:
    board = box(
        (BOARD_LENGTH, BOARD_WIDTH, BOARD_THICKNESS),
        (0.0, 0.0, BOARD_SEAT_Z + BOARD_THICKNESS / 2.0),
    )
    board_overlap = bumper.intersect(board).val().Volume()
    if board_overlap > 0.05:
        raise RuntimeError(f"board overlaps bumper by {board_overlap:.3f} mm^3")
    print(
        f"assembly clearance: board overlap={board_overlap:.3f} mm^3; "
        f"board edge clearance={BOARD_CLEARANCE / 2.0:.2f} mm per side"
    )
    print(
        f"vent hook: {HOOK_WIDTH_Y:.2f} mm wide in a {VENT_OPENING_WIDTH_Y:.2f} mm slot "
        f"({(VENT_OPENING_WIDTH_Y - HOOK_WIDTH_Y) / 2.0:.3f} mm nominal clearance per side)"
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    bumper = build_bumper()
    insert_gauge = build_insert_gauge()

    validate("bumper", bumper)
    validate("M2 insert gauge", insert_gauge)
    validate_assembly_clearances(bumper)

    export_model(bumper, "tb6600-controller-pod")
    export_model(insert_gauge, "tb6600-controller-pod-m2-insert-gauge")

    for reach in (1.20, 1.60, 2.00):
        gauge = build_hook_gauge(reach)
        validate(f"vent hook gauge {reach:.1f}", gauge)
        width_token = f"{HOOK_WIDTH_Y:.1f}".replace(".", "p")
        depth_token = f"{reach:.1f}".replace(".", "p")
        export_model(gauge, f"tb6600-vent-fit-w{width_token}-d{depth_token}")

    export_views(bumper)
    print(f"Generated simplified bumper files in {OUT}")


if __name__ == "__main__":
    main()
