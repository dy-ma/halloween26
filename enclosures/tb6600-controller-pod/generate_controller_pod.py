"""Generate the TB6600 perfboard pod as one box with two internal cutouts.

The battery's broad 65.63 x 36.22 mm face is parallel to the perfboard and the
TB6600 face.  A continuous rounded outer body contains a slide-in battery
tunnel and a PCB pocket.  The installed +Y edge stays open so the battery can
be inserted after the PCB is fastened.  Two reinforced snap pairs engage the
driver's vents.

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

# Battery envelope supplied in the second physical-fit revision.  Its broad
# face stays parallel to the perfboard; only the 10 mm thickness adds height.
BATTERY_LENGTH = 65.63
BATTERY_WIDTH = 36.22
BATTERY_THICKNESS = 10.00
DRIVER_BODY_SPAN = 80.27

# Bumper fit
# Total cavity oversize. Hole centers stay tied to the measured board, while
# the perimeter moves outward to give 0.75 mm clearance on every board edge.
BOARD_CLEARANCE = 1.50
# 2.60 mm avoids a narrow residual gap when sliced as three structural
# perimeters with a 0.8 mm nozzle and 0.82-0.86 mm extrusion widths.
WALL = 2.60
BOSS_DIAMETER = 7.60

# The battery tunnel is cut from the unified body.  The pouch lies flat, with
# 0.75 mm nominal clearance on every XY edge.  Its installed +Y edge is open
# for insertion after the PCB is fastened.  The board sits 5 mm above the pouch
# for solder projections, the Velcro overlap, and suspended M2 insert bosses.
BATTERY_XY_CLEARANCE = 1.50
BATTERY_CAVITY_LENGTH = BATTERY_LENGTH + BATTERY_XY_CLEARANCE
BATTERY_CAVITY_WIDTH = BATTERY_WIDTH + BATTERY_XY_CLEARANCE
BATTERY_BASE_THICKNESS = 3.20
BATTERY_SIDE_WALL = 2.60
BATTERY_END_WALL = 2.60
BATTERY_TOP_CLEARANCE = 1.00
BOARD_BATTERY_CLEARANCE = 5.00
BATTERY_POCKET_HEIGHT = (
    BATTERY_BASE_THICKNESS + BATTERY_THICKNESS + BATTERY_TOP_CLEARANCE
)
BOARD_SEAT_Z = (
    BATTERY_BASE_THICKNESS + BATTERY_THICKNESS + BOARD_BATTERY_CLEARANCE
)
BUMPER_HEIGHT = BOARD_SEAT_Z + BOARD_THICKNESS + 0.80
# The PCB cavity begins above the 11 mm battery insertion aperture.  Both are
# subtracted from one continuous outer body rather than built as stacked parts.
BOARD_CAVITY_BOTTOM_Z = BATTERY_POCKET_HEIGHT

# 12.37 mm One-Wrap shown in the reference carrier.  Two floor slots and a
# recessed underside channel route it under the pouch and across its broad
# face without obstructing the open +Y slide-in edge.
# A little extra PETG allowance prevents first-layer bulge or light stringing
# from making the One-Wrap difficult to thread.
BATTERY_STRAP_SLOT_LENGTH = 14.00
BATTERY_STRAP_SLOT_WIDTH = 3.20
BATTERY_STRAP_SLOT_Y = 14.50
BATTERY_STRAP_CHANNEL_DEPTH = 1.80

# Heat-set inserts: change these to match the actual inserts after gauging.
INSERT_DIAMETER = 3.20
INSERT_DEPTH = 4.20
INSERT_LEAD_DIAMETER = 3.80
INSERT_LEAD_DEPTH = 0.60
BOSS_BOTTOM_Z = BOARD_SEAT_Z - INSERT_DEPTH - 0.20

# Driver vent snap. The three exported gauges bracket this uncertain dimension.
SNAP_CLEARANCE = 0.30
SNAP_ARM_THICKNESS = 2.40
SNAP_ARM_WIDTH_Y = 4.50
SNAP_ARM_DEPTH_Z = 11.10
# Keep each reinforcement no wider than its flexible arm.  Instead of a short,
# bulky root block, a narrow rib runs up the unified body to the PCB seat.
SNAP_ROOT_WIDTH_Y = SNAP_ARM_WIDTH_Y
SNAP_ROOT_RISE_Z = BOARD_SEAT_Z
HOOK_REACH_X = 1.60
HOOK_HEIGHT_Z = 1.80
VENT_OPENING_WIDTH_Y = 2.83
HOOK_WIDTH_Y = 2.30

# The user's 27 mm caliper reading is the clear edge-to-edge gap between the
# two 2.83 mm vent slots, not their centre spacing.
VENT_SLOT_EDGE_GAP_Y = 27.00
VENT_SLOT_CENTER_SPACING_Y = VENT_SLOT_EDGE_GAP_Y + VENT_OPENING_WIDTH_Y
SNAP_OFFSETS_Y = (
    -VENT_SLOT_CENTER_SPACING_Y / 2.0,
    VENT_SLOT_CENTER_SPACING_Y / 2.0,
)

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"

CAVITY_X = BOARD_LENGTH + BOARD_CLEARANCE
CAVITY_Y = BOARD_WIDTH + BOARD_CLEARANCE
OUTER_X = CAVITY_X + 2.0 * WALL
OUTER_Y = CAVITY_Y + 2.0 * WALL

HOLE_X = BOARD_LENGTH / 2.0 - HOLE_CENTER_INSET
HOLE_Y = BOARD_WIDTH / 2.0 - HOLE_CENTER_INSET

BATTERY_POCKET_OUTER_X = BATTERY_CAVITY_LENGTH + 2.0 * BATTERY_END_WALL
BATTERY_POCKET_OUTER_Y = BATTERY_CAVITY_WIDTH + 2.0 * BATTERY_SIDE_WALL
BODY_OUTER_X = max(OUTER_X, BATTERY_POCKET_OUTER_X)
BODY_OUTER_Y = max(OUTER_Y, BATTERY_POCKET_OUTER_Y)


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


def rounded_rect_prism(
    x_size: float,
    y_size: float,
    height: float,
    radius: float,
    x0: float,
    y0: float,
    z0: float,
) -> cq.Workplane:
    """Axis-aligned rounded prism located by its lower XY corner."""
    core_x = box(
        (x_size - 2.0 * radius, y_size, height),
        (x0 + x_size / 2.0, y0 + y_size / 2.0, z0 + height / 2.0),
    )
    core_y = box(
        (x_size, y_size - 2.0 * radius, height),
        (x0 + x_size / 2.0, y0 + y_size / 2.0, z0 + height / 2.0),
    )
    model = core_x.union(core_y)
    for x in (x0 + radius, x0 + x_size - radius):
        for y in (y0 + radius, y0 + y_size - radius):
            model = model.union(cylinder_z(radius, height, x, y, z0))
    return model


def capsule_slot_x(
    length: float,
    width: float,
    height: float,
    x: float,
    y: float,
    z0: float,
) -> cq.Workplane:
    """Rounded through-slot whose long direction is parallel to X."""
    radius = width / 2.0
    straight = length - width
    model = box((straight, width, height), (x, y, z0 + height / 2.0))
    for end_x in (x - straight / 2.0, x + straight / 2.0):
        model = model.union(cylinder_z(radius, height, end_x, y, z0))
    return model


def build_bumper() -> cq.Workplane:
    """One-piece outer box with battery/PCB cutouts and four vent snaps."""

    # Begin with one uninterrupted rounded box using the larger required span
    # on each axis.  All functional spaces are carved from this common body so
    # the outside has no tray/frame step or visible joined-part transition.
    model = rounded_rect_prism(
        BODY_OUTER_X,
        BODY_OUTER_Y,
        BUMPER_HEIGHT,
        3.00,
        -BODY_OUTER_X / 2.0,
        -BODY_OUTER_Y / 2.0,
        0.0,
    )

    # The battery tunnel continues up to the board seat, preserving the full
    # 5 mm clearance above the pouch for solder projections and the strap.
    # Its +Y wall is opened separately only over the 11 mm insertion aperture.
    battery_cavity = rounded_rect_prism(
        BATTERY_CAVITY_LENGTH,
        BATTERY_CAVITY_WIDTH,
        BOARD_SEAT_Z - BATTERY_BASE_THICKNESS + 0.05,
        1.60,
        -BATTERY_CAVITY_LENGTH / 2.0,
        -BATTERY_CAVITY_WIDTH / 2.0,
        BATTERY_BASE_THICKNESS,
    )
    model = model.cut(battery_cavity)

    # The board opening is a second subtraction from the same body.  The PCB
    # is supported by its four bosses while the continuous perimeter becomes a
    # clean, uniform outer wall.
    board_cavity = rounded_rect_prism(
        CAVITY_X,
        CAVITY_Y,
        BUMPER_HEIGHT - BOARD_CAVITY_BOTTOM_Z + 1.0,
        1.60,
        -CAVITY_X / 2.0,
        -CAVITY_Y / 2.0,
        BOARD_CAVITY_BOTTOM_Z,
    )
    model = model.cut(board_cavity)

    # Completely remove the +Y wall over the cavity width.  In the installed
    # orientation this is the upper edge shown in the reference photo, letting
    # the battery slide into the box after the PCB has been screwed down.
    model = model.cut(
        box(
            (
                BATTERY_CAVITY_LENGTH,
                (BODY_OUTER_Y - BATTERY_CAVITY_WIDTH) / 2.0 + 2.0,
                BATTERY_POCKET_HEIGHT - BATTERY_BASE_THICKNESS + 0.40,
            ),
            (
                0.0,
                (BATTERY_CAVITY_WIDTH / 2.0 + BODY_OUTER_Y / 2.0) / 2.0,
                BATTERY_BASE_THICKNESS
                + (BATTERY_POCKET_HEIGHT - BATTERY_BASE_THICKNESS + 0.40)
                / 2.0,
            ),
        )
    )

    # Two rounded floor slots route the Velcro under the flat pouch.  A shallow
    # underside channel keeps the strap nearly flush against the driver face.
    for slot_y in (-BATTERY_STRAP_SLOT_Y, BATTERY_STRAP_SLOT_Y):
        model = model.cut(
            capsule_slot_x(
                BATTERY_STRAP_SLOT_LENGTH,
                BATTERY_STRAP_SLOT_WIDTH,
                BATTERY_BASE_THICKNESS + 0.40,
                0.0,
                slot_y,
                -0.20,
            )
        )
    model = model.cut(
        box(
            (
                BATTERY_STRAP_SLOT_LENGTH,
                2.0 * BATTERY_STRAP_SLOT_Y + BATTERY_STRAP_SLOT_WIDTH,
                BATTERY_STRAP_CHANNEL_DEPTH,
            ),
            (0.0, 0.0, BATTERY_STRAP_CHANNEL_DEPTH / 2.0),
        )
    )

    # The insert bosses merge directly into the continuous box wall.  Their
    # lower faces stay above the battery envelope rather than passing through.
    for x in (-HOLE_X, HOLE_X):
        for y in (-HOLE_Y, HOLE_Y):
            model = model.union(
                cylinder_z(
                    BOSS_DIAMETER / 2.0,
                    BOARD_SEAT_Z - BOSS_BOTTOM_Z,
                    x,
                    y,
                    BOSS_BOTTOM_Z,
                )
            )
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

    # Four arms wrap around the driver at the two measured vent positions.  A
    # narrow rib matching each arm's width runs to the PCB seating plane.  This
    # creates a long bonded edge without the former expanded cube-like roots.
    arm_inner_x = DRIVER_BODY_SPAN / 2.0 + SNAP_CLEARANCE
    arm_center_abs_x = arm_inner_x + SNAP_ARM_THICKNESS / 2.0
    for offset_y in SNAP_OFFSETS_Y:
        for sign in (-1.0, 1.0):
            bridge_inner_x = sign * (BODY_OUTER_X / 2.0)
            bridge_outer_x = sign * (arm_inner_x + SNAP_ARM_THICKNESS)
            bridge_center_x = (bridge_inner_x + bridge_outer_x) / 2.0
            bridge_length_x = abs(bridge_outer_x - bridge_inner_x) + 0.30
            model = model.union(
                box(
                    (bridge_length_x, SNAP_ROOT_WIDTH_Y, SNAP_ROOT_RISE_Z),
                    (bridge_center_x, offset_y, SNAP_ROOT_RISE_Z / 2.0),
                )
            )

            arm_center_z = (WALL - SNAP_ARM_DEPTH_Z) / 2.0
            model = model.union(
                box(
                    (SNAP_ARM_THICKNESS, SNAP_ARM_WIDTH_Y, SNAP_ARM_DEPTH_Z),
                    (sign * arm_center_abs_x, offset_y, arm_center_z),
                )
            )

            hook_center_x = sign * (arm_inner_x - HOOK_REACH_X / 2.0)
            hook_center_z = WALL - SNAP_ARM_DEPTH_Z + HOOK_HEIGHT_Z / 2.0
            model = model.union(
                box(
                    (HOOK_REACH_X, HOOK_WIDTH_Y, HOOK_HEIGHT_Z),
                    (hook_center_x, offset_y, hook_center_z),
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


def build_dual_hook_spacing_gauge(reach: float) -> cq.Workplane:
    """Two-tine coupon checking the derived 29.83 mm vent center spacing."""
    gauge_y = VENT_SLOT_CENTER_SPACING_Y + 10.0
    gauge = box((18.0, gauge_y, 3.0), (9.0, 0.0, 10.5))
    for offset_y in SNAP_OFFSETS_Y:
        gauge = gauge.union(
            box(
                (SNAP_ARM_THICKNESS, SNAP_ARM_WIDTH_Y, 12.0),
                (SNAP_ARM_THICKNESS / 2.0, offset_y, 6.0),
            )
        )
        gauge = gauge.union(
            box(
                (reach, HOOK_WIDTH_Y, HOOK_HEIGHT_Z),
                (-reach / 2.0, offset_y, HOOK_HEIGHT_Z / 2.0),
            )
        )
    return gauge.clean()


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
        ("preview", (1.0, 1.0, 0.75), False),
        ("top", (0.0, 0.0, 1.0), True),
        ("front", (0.0, 1.0, 0.0), True),
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


def export_dimension_drawing() -> None:
    """Export a dimensioned plan view and a compact nominal-dimension table."""
    width = 1800
    height = 1200
    scale = 9.0
    center_x = 500.0
    center_y = 450.0
    arm_inner_x = DRIVER_BODY_SPAN / 2.0 + SNAP_CLEARANCE
    arm_center_x = arm_inner_x + SNAP_ARM_THICKNESS / 2.0
    arm_outer_x = arm_inner_x + SNAP_ARM_THICKNESS
    model_outer_x = 2.0 * (arm_outer_x + 0.15)
    arm_clear_gap = VENT_SLOT_CENTER_SPACING_Y - SNAP_ARM_WIDTH_Y
    hook_clear_gap = VENT_SLOT_CENTER_SPACING_Y - HOOK_WIDTH_Y
    opposing_arm_clearance = 2.0 * arm_inner_x

    def sx(x: float) -> float:
        return center_x + x * scale

    def sy(y: float) -> float:
        return center_y - y * scale

    def rect_centered(
        x: float,
        y: float,
        x_size: float,
        y_size: float,
        style: str,
        radius: float = 0.0,
    ) -> str:
        return (
            f'<rect x="{sx(x - x_size / 2.0):.2f}" '
            f'y="{sy(y + y_size / 2.0):.2f}" '
            f'width="{x_size * scale:.2f}" height="{y_size * scale:.2f}" '
            f'rx="{radius * scale:.2f}" class="{style}"/>'
        )

    def dim_h(x1: float, x2: float, y: float, label: str) -> str:
        y_px = sy(y)
        return (
            f'<line x1="{sx(x1):.2f}" y1="{y_px:.2f}" x2="{sx(x2):.2f}" '
            f'y2="{y_px:.2f}" class="dim" marker-start="url(#arrow)" '
            f'marker-end="url(#arrow)"/>'
            f'<text x="{(sx(x1) + sx(x2)) / 2.0:.2f}" y="{y_px - 10:.2f}" '
            f'class="dimtext" text-anchor="middle">{label}</text>'
        )

    def dim_v(y1: float, y2: float, x: float, label: str) -> str:
        x_px = sx(x)
        y1_px = sy(y1)
        y2_px = sy(y2)
        text_y = (y1_px + y2_px) / 2.0
        return (
            f'<line x1="{x_px:.2f}" y1="{y1_px:.2f}" x2="{x_px:.2f}" '
            f'y2="{y2_px:.2f}" class="dim" marker-start="url(#arrow)" '
            f'marker-end="url(#arrow)"/>'
            f'<text x="{x_px + 18:.2f}" y="{text_y:.2f}" class="dimtext" '
            f'text-anchor="middle" transform="rotate(-90 {x_px + 18:.2f} '
            f'{text_y:.2f})">{label}</text>'
        )

    elements = [
        f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
<defs>
  <marker id="arrow" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto-start-reverse"><path d="M 8 0 L 0 4 L 8 8 z" fill="#174a7e"/></marker>
</defs>
<style>
  text {{ font-family: Arial, Helvetica, sans-serif; fill: #18212a; }}
  .title {{ font-size: 34px; font-weight: 700; }}
  .subtitle {{ font-size: 20px; fill: #4a5968; }}
  .body {{ fill: #edf1f4; stroke: #18212a; stroke-width: 4; }}
  .board {{ fill: none; stroke: #238636; stroke-width: 3; stroke-dasharray: 12 8; }}
  .battery {{ fill: none; stroke: #d97706; stroke-width: 3; stroke-dasharray: 12 8; }}
  .root {{ fill: #bdc8d2; stroke: #18212a; stroke-width: 3; }}
  .arm {{ fill: #dbe3e9; stroke: #18212a; stroke-width: 3; }}
  .hook {{ fill: #5d6b78; stroke: #18212a; stroke-width: 2; }}
  .centerline {{ stroke: #8a96a3; stroke-width: 2; stroke-dasharray: 8 8; }}
  .dim {{ stroke: #174a7e; stroke-width: 2.5; }}
  .ext {{ stroke: #7f8b96; stroke-width: 1.5; }}
  .dimtext {{ font-size: 19px; font-weight: 700; fill: #174a7e; paint-order: stroke; stroke: white; stroke-width: 5; }}
  .section {{ font-size: 24px; font-weight: 700; }}
  .tablehead {{ font-size: 19px; font-weight: 700; fill: white; }}
  .tabletext {{ font-size: 18px; }}
  .note {{ font-size: 17px; fill: #4a5968; }}
</style>
<rect width="100%" height="100%" fill="white"/>
<text x="70" y="58" class="title">TB6600 controller pod — nominal dimensions</text>
<text x="70" y="90" class="subtitle">All dimensions in millimetres. Plan view is looking at the PCB face.</text>
<text x="70" y="135" class="section">PLAN VIEW / CLIP SPACING</text>'''
    ]

    elements.append(rect_centered(0.0, 0.0, BODY_OUTER_X, BODY_OUTER_Y, "body", 3.0))
    elements.append(rect_centered(0.0, 0.0, CAVITY_X, CAVITY_Y, "board", 1.6))
    elements.append(
        rect_centered(
            0.0,
            0.0,
            BATTERY_CAVITY_LENGTH,
            BATTERY_CAVITY_WIDTH,
            "battery",
            1.6,
        )
    )
    elements.append(
        f'<line x1="{sx(0):.2f}" y1="{sy(BODY_OUTER_Y / 2 + 7):.2f}" '
        f'x2="{sx(0):.2f}" y2="{sy(-BODY_OUTER_Y / 2 - 7):.2f}" class="centerline"/>'
    )

    for offset_y in SNAP_OFFSETS_Y:
        for sign in (-1.0, 1.0):
            root_x = sign * ((BODY_OUTER_X / 2.0 + arm_outer_x) / 2.0)
            root_length = arm_outer_x - BODY_OUTER_X / 2.0 + 0.30
            elements.append(
                rect_centered(
                    root_x,
                    offset_y,
                    root_length,
                    SNAP_ROOT_WIDTH_Y,
                    "root",
                )
            )
            elements.append(
                rect_centered(
                    sign * arm_center_x,
                    offset_y,
                    SNAP_ARM_THICKNESS,
                    SNAP_ARM_WIDTH_Y,
                    "arm",
                )
            )
            hook_x = sign * (arm_inner_x - HOOK_REACH_X / 2.0)
            elements.append(
                rect_centered(
                    hook_x,
                    offset_y,
                    HOOK_REACH_X,
                    HOOK_WIDTH_Y,
                    "hook",
                )
            )

    body_left = -BODY_OUTER_X / 2.0
    body_right = BODY_OUTER_X / 2.0
    body_top = BODY_OUTER_Y / 2.0
    body_bottom = -BODY_OUTER_Y / 2.0
    elements.extend(
        [
            f'<line x1="{sx(body_left):.2f}" y1="{sy(body_bottom):.2f}" x2="{sx(body_left):.2f}" y2="{sy(body_bottom - 8):.2f}" class="ext"/>',
            f'<line x1="{sx(body_right):.2f}" y1="{sy(body_bottom):.2f}" x2="{sx(body_right):.2f}" y2="{sy(body_bottom - 8):.2f}" class="ext"/>',
            dim_h(body_left, body_right, body_bottom - 6.0, f"BODY {BODY_OUTER_X:.2f}"),
            dim_h(-arm_inner_x, arm_inner_x, body_top + 7.0, f"{opposing_arm_clearance:.2f} BETWEEN OPPOSING ARM INNER FACES"),
            dim_v(body_bottom, body_top, body_right + 7.5, f"BODY {BODY_OUTER_Y:.2f}"),
            dim_v(SNAP_OFFSETS_Y[0], SNAP_OFFSETS_Y[1], arm_outer_x + 7.0, f"CLIP CENTRES {VENT_SLOT_CENTER_SPACING_Y:.2f}"),
            dim_v(
                SNAP_OFFSETS_Y[0] + HOOK_WIDTH_Y / 2.0,
                SNAP_OFFSETS_Y[1] - HOOK_WIDTH_Y / 2.0,
                arm_outer_x + 12.0,
                f"HOOK CLEAR GAP {hook_clear_gap:.2f}",
            ),
            '<text x="75" y="760" class="note"><tspan fill="#238636">Green dashed:</tspan> PCB pocket</text>',
            '<text x="330" y="760" class="note"><tspan fill="#d97706">Orange dashed:</tspan> battery tunnel</text>',
            '<text x="75" y="792" class="note">The measured 27.00 mm value is the driver vent edge gap, not the printed hook gap.</text>',
        ]
    )

    table_rows = [
        ("Unified body", f"{BODY_OUTER_X:.2f} × {BODY_OUTER_Y:.2f}"),
        ("Overall X including root ribs", f"{model_outer_x:.2f}"),
        ("PCB pocket", f"{CAVITY_X:.2f} × {CAVITY_Y:.2f}"),
        ("Battery tunnel", f"{BATTERY_CAVITY_LENGTH:.2f} × {BATTERY_CAVITY_WIDTH:.2f} × {BATTERY_THICKNESS + BATTERY_TOP_CLEARANCE:.2f}"),
        ("Clip centre spacing along Y", f"{VENT_SLOT_CENTER_SPACING_Y:.2f}"),
        ("Flexible-arm clear gap", f"{arm_clear_gap:.2f}"),
        ("Hook clear edge gap", f"{hook_clear_gap:.2f}"),
        ("Target vent clear edge gap", f"{VENT_SLOT_EDGE_GAP_Y:.2f}"),
        ("Vent slot / printed hook width", f"{VENT_OPENING_WIDTH_Y:.2f} / {HOOK_WIDTH_Y:.2f}"),
        ("Opposing arm inner faces", f"{opposing_arm_clearance:.2f}"),
        ("Driver body span", f"{DRIVER_BODY_SPAN:.2f}"),
        ("Arm-to-driver clearance", f"{SNAP_CLEARANCE:.2f} each side"),
        ("Hook reach", f"{HOOK_REACH_X:.2f}"),
    ]
    table_x = 1030
    table_y = 142
    row_height = 48
    table_width = 700
    elements.extend(
        [
            f'<rect x="{table_x}" y="{table_y}" width="{table_width}" height="48" rx="8" fill="#174a7e"/>',
            f'<text x="{table_x + 20}" y="{table_y + 31}" class="tablehead">DIMENSION</text>',
            f'<text x="{table_x + 500}" y="{table_y + 31}" class="tablehead">VALUE</text>',
        ]
    )
    for index, (name, value) in enumerate(table_rows):
        row_y = table_y + 48 + index * row_height
        fill = "#f4f7f9" if index % 2 == 0 else "#ffffff"
        elements.extend(
            [
                f'<rect x="{table_x}" y="{row_y}" width="{table_width}" height="{row_height}" fill="{fill}" stroke="#c9d2da"/>',
                f'<text x="{table_x + 20}" y="{row_y + 31}" class="tabletext">{name}</text>',
                f'<text x="{table_x + 500}" y="{row_y + 31}" class="tabletext">{value}</text>',
            ]
        )

    stack_y = 835
    elements.extend(
        [
            f'<text x="1030" y="{stack_y}" class="section">STACK / Z LEVELS</text>',
            f'<rect x="1030" y="{stack_y + 35}" width="700" height="250" rx="10" fill="#f4f7f9" stroke="#c9d2da"/>',
            f'<text x="1060" y="{stack_y + 78}" class="tabletext">Driver-facing floor thickness</text><text x="1540" y="{stack_y + 78}" class="tabletext">{BATTERY_BASE_THICKNESS:.2f}</text>',
            f'<text x="1060" y="{stack_y + 116}" class="tabletext">Battery envelope top</text><text x="1540" y="{stack_y + 116}" class="tabletext">Z = {BATTERY_BASE_THICKNESS + BATTERY_THICKNESS:.2f}</text>',
            f'<text x="1060" y="{stack_y + 154}" class="tabletext">PCB seating plane</text><text x="1540" y="{stack_y + 154}" class="tabletext">Z = {BOARD_SEAT_Z:.2f}</text>',
            f'<text x="1060" y="{stack_y + 192}" class="tabletext">Battery-to-PCB clearance</text><text x="1540" y="{stack_y + 192}" class="tabletext">{BOARD_BATTERY_CLEARANCE:.2f}</text>',
            f'<text x="1060" y="{stack_y + 230}" class="tabletext">Outer body height</text><text x="1540" y="{stack_y + 230}" class="tabletext">{BUMPER_HEIGHT:.2f}</text>',
            '<text x="70" y="1160" class="note">Nominal CAD values. Print the dual-hook spacing coupon before the full pod and compensate for measured PETG shrink or elephant foot.</text>',
            '</svg>',
        ]
    )

    svg = OUT / "tb6600-controller-pod-dimensions.svg"
    png = OUT / "tb6600-controller-pod-dimensions.png"
    svg.write_text("\n".join(elements), encoding="utf-8")
    svg_to_png(svg, png, width, height)


def build_battery_envelope() -> cq.Workplane:
    """Non-printing battery solid used for clearance validation."""
    return box(
        (BATTERY_LENGTH, BATTERY_WIDTH, BATTERY_THICKNESS),
        (0.0, 0.0, BATTERY_BASE_THICKNESS + BATTERY_THICKNESS / 2.0),
    )


def validate_assembly_clearances(bumper: cq.Workplane) -> None:
    board = box(
        (BOARD_LENGTH, BOARD_WIDTH, BOARD_THICKNESS),
        (0.0, 0.0, BOARD_SEAT_Z + BOARD_THICKNESS / 2.0),
    )
    battery = build_battery_envelope()
    battery_top_z = BATTERY_BASE_THICKNESS + BATTERY_THICKNESS
    boss_clearance = BOSS_BOTTOM_Z - battery_top_z
    board_overlap = bumper.intersect(board).val().Volume()
    battery_overlap = bumper.intersect(battery).val().Volume()
    slide_positions = tuple(float(y) for y in range(0, 46, 5))
    slide_overlaps = tuple(
        bumper.intersect(battery.translate((0.0, y, 0.0))).val().Volume()
        for y in slide_positions
    )
    max_slide_overlap = max(slide_overlaps)
    if board_overlap > 0.05:
        raise RuntimeError(f"board overlaps bumper by {board_overlap:.3f} mm^3")
    if battery_overlap > 0.05:
        raise RuntimeError(
            f"battery envelope overlaps bumper by {battery_overlap:.3f} mm^3"
        )
    if max_slide_overlap > 0.05:
        raise RuntimeError(
            "+Y battery insertion path overlaps bumper by "
            f"{max_slide_overlap:.3f} mm^3"
        )
    if boss_clearance < 0.50:
        raise RuntimeError(
            f"insert-boss clearance over battery is only {boss_clearance:.3f} mm"
        )
    print(
        f"assembly clearance: board overlap={board_overlap:.3f} mm^3; "
        f"battery overlap={battery_overlap:.3f} mm^3; "
        f"battery-to-board={BOARD_BATTERY_CLEARANCE:.2f} mm; "
        f"boss-to-battery={boss_clearance:.2f} mm"
    )
    print(
        "+Y battery slide-in path: clear from seated position through "
        f"{slide_positions[-1]:.0f} mm travel "
        f"(max overlap={max_slide_overlap:.3f} mm^3)"
    )
    print(
        f"vent hook: {HOOK_WIDTH_Y:.2f} mm wide in a {VENT_OPENING_WIDTH_Y:.2f} mm slot "
        f"({(VENT_OPENING_WIDTH_Y - HOOK_WIDTH_Y) / 2.0:.3f} mm nominal clearance per side); "
        f"slot edge gap={VENT_SLOT_EDGE_GAP_Y:.2f} mm; "
        f"arm-pair centres={VENT_SLOT_CENTER_SPACING_Y:.2f} mm"
    )


def export_fit_check(bumper: cq.Workplane) -> None:
    """Export assembly STEP and drawing with board and battery envelopes."""
    board = box(
        (BOARD_LENGTH, BOARD_WIDTH, BOARD_THICKNESS),
        (0.0, 0.0, BOARD_SEAT_Z + BOARD_THICKNESS / 2.0),
    )
    battery = build_battery_envelope()
    assembly = cq.Assembly(name="tb6600-controller-pod-fit-check")
    assembly.add(bumper, name="printed-pod", color=cq.Color(0.72, 0.75, 0.80))
    assembly.add(
        battery,
        name="65p63x36p22x10-battery-envelope",
        color=cq.Color(0.95, 0.65, 0.12, 0.70),
    )
    assembly.add(
        board,
        name="69p96x30p20-perfboard-envelope",
        color=cq.Color(0.18, 0.55, 0.25, 0.70),
    )
    assembly.save(str(OUT / "tb6600-controller-pod-fit-check.step"))

    fit_shape = cq.Workplane(
        obj=cq.Compound.makeCompound([bumper.val(), battery.val(), board.val()])
    )
    fit_svg = OUT / "tb6600-controller-pod-fit-preview.svg"
    fit_png = OUT / "tb6600-controller-pod-fit-preview.png"
    exporters.export(
        fit_shape,
        str(fit_svg),
        exportType="SVG",
        opt={
            "width": 1400,
            "height": 900,
            "marginLeft": 30,
            "marginTop": 30,
            "projectionDir": (1.0, 1.0, 0.75),
            "showAxes": False,
            "showHidden": False,
            "strokeWidth": 0.7,
        },
    )
    svg_to_png(fit_svg, fit_png, 1400, 900)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    bumper = build_bumper()
    insert_gauge = build_insert_gauge()

    validate("bumper", bumper)
    validate("M2 insert gauge", insert_gauge)
    validate_assembly_clearances(bumper)

    export_model(bumper, "tb6600-controller-pod")
    export_fit_check(bumper)
    export_model(insert_gauge, "tb6600-controller-pod-m2-insert-gauge")

    for reach in (1.20, 1.60, 2.00):
        gauge = build_hook_gauge(reach)
        validate(f"vent hook gauge {reach:.1f}", gauge)
        width_token = f"{HOOK_WIDTH_Y:.1f}".replace(".", "p")
        depth_token = f"{reach:.1f}".replace(".", "p")
        export_model(gauge, f"tb6600-vent-fit-w{width_token}-d{depth_token}")

    spacing_gauge = build_dual_hook_spacing_gauge(HOOK_REACH_X)
    validate("dual vent spacing gauge", spacing_gauge)
    export_model(
        spacing_gauge,
        "tb6600-dual-vent-spacing-fit-w2p3-gap27p0-d1p6",
    )

    export_views(bumper)
    export_dimension_drawing()
    print(f"Generated battery pod files in {OUT}")


if __name__ == "__main__":
    main()
