"""Parametric side-by-side carrier for the custom controller and BTS 7960.

The model reuses the supplied BTS 7960 standoff STEP solid, lays it flat, and
joins it to an open controller-board bumper.  The controller PCB sits on four
M2 heat-set-insert bosses.  A top-loaded LiPo tray lives below the empty
right-hand portion of the PCB; installing the PCB makes the battery captive.

Run with the project CadQuery environment:

    /tmp/codex-cadquery-venv/bin/python generate_carrier.py

All dimensions are millimetres.  The dimensions most likely to need tuning are
grouped at the top of this file.
"""

from __future__ import annotations

import math
from pathlib import Path

import cadquery as cq
from cadquery import exporters, importers


ROOT = Path(__file__).resolve().parent
REFERENCE = ROOT / "reference" / "BTS 7960 Standoff.step"
OUT = ROOT / "output"


# ---------------------------------------------------------------------------
# Controller PCB: photo-derived board size plus user-measured hole spacing.
# ---------------------------------------------------------------------------

PCB_WIDTH = 90.00
PCB_DEPTH = 52.00
PCB_THICKNESS = 1.60
PCB_CORNER_RADIUS = 4.00

PCB_HOLE_SPACING_X = 78.11
PCB_HOLE_SPACING_Y = 35.33

# Total clearance around the PCB.  Increase this if the bumper grips the edge.
PCB_FIT_CLEARANCE = 0.50


# ---------------------------------------------------------------------------
# Open bumper and M2 heat-set insert bosses.
# ---------------------------------------------------------------------------

BUMPER_WALL = 2.40
BUMPER_HEIGHT = 14.50
BASE_FLANGE_INSET = 8.00
BASE_FLANGE_THICKNESS = 2.80
PCB_SUPPORT_HEIGHT = 11.50

BOSS_DIAMETER = 7.00
INSERT_POCKET_DIAMETER = 3.20
INSERT_POCKET_DEPTH = 4.20
INSERT_LEAD_DIAMETER = 3.70
INSERT_LEAD_DEPTH = 0.60


# ---------------------------------------------------------------------------
# Battery sled.  The pouch in the photo appears about 28 x 38 x 7 mm.
# Measure the actual pouch (including tape/wrinkles) before the final print.
# ---------------------------------------------------------------------------

BATTERY_WIDTH = 28.00
BATTERY_LENGTH = 38.00
BATTERY_THICKNESS = 7.00
BATTERY_X_FROM_PCB_LEFT = 48.00

BATTERY_XY_CLEARANCE = 0.60
BATTERY_Z_CLEARANCE = 0.60
BATTERY_FLOOR = 1.40
BATTERY_RAIL = 1.80
BATTERY_REAR_STOP = 1.80
BATTERY_CABLE_NOTCH = 10.00

# A connector-sized side portal lets the XIAO pigtail wrap from the top of the
# PCB, around its left edge, and into the open underside.  It is centered on the
# long side between the two external mounting ears.
PIGTAIL_PORT_WIDTH = 16.00
PIGTAIL_PORT_SILL = 1.20


# ---------------------------------------------------------------------------
# Carrier joins and mounting ears.
# ---------------------------------------------------------------------------

BTS_GAP = 6.00
BRIDGE_THICKNESS = 4.00

# The four carrier mounting holes live outside the long bumper walls so an M4
# screw, washer, and driver remain accessible with both PCBs installed.
MOUNT_EAR_RADIUS = 7.00
MOUNT_EAR_OUTBOARD = 8.00
MOUNT_EAR_X_INSET = 12.00
MOUNT_EAR_HOLE_DIAMETER = 4.20
MOUNT_EAR_THICKNESS = 3.20

# The BTS heatsink is a flat rectangle.  Reinforce each post horizontally away
# from the module, then cut opposing vertical D-flats: both left-post flats face
# right and both right-post flats face left.  The resulting minimum wall beside
# the 3 mm screw hole is 0.50 mm, backed by substantially more material on the
# outer side.
BTS_POST_CENTERS = (
    (3.50, 3.50),
    (3.50, 43.50),
    (43.50, 3.50),
    (43.50, 43.50),
)
BTS_PATTERN_CENTER = (23.50, 23.50)
BTS_POST_FLAT_OFFSET = 2.00
BTS_POST_REINFORCE_RADIUS = 4.25
BTS_POST_REINFORCE_SHIFT = 1.00
BTS_SCREW_HOLE_DIAMETER = 3.00
BTS_BASE_HEIGHT = 4.00
BTS_GUSSET_REACH = 4.00
BTS_GUSSET_HEIGHT = 10.00
BTS_GUSSET_THICKNESS = 2.40


def box(
    size: tuple[float, float, float],
    center: tuple[float, float, float],
) -> cq.Workplane:
    return cq.Workplane("XY").box(*size).translate(center)


def cylinder_z(
    radius: float,
    height: float,
    x: float,
    y: float,
    z0: float,
) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        height,
        cq.Vector(x, y, z0),
        cq.Vector(0, 0, 1),
    )
    return cq.Workplane(obj=solid)


def rounded_rect_prism(
    width: float,
    depth: float,
    height: float,
    radius: float,
    x0: float = 0.0,
    y0: float = 0.0,
    z0: float = 0.0,
) -> cq.Workplane:
    """Axis-aligned rounded rectangular prism located by its lower corner."""
    if radius <= 0.0 or width <= 2.0 * radius or depth <= 2.0 * radius:
        return box(
            (width, depth, height),
            (x0 + width / 2.0, y0 + depth / 2.0, z0 + height / 2.0),
        )

    model = box(
        (width - 2.0 * radius, depth, height),
        (x0 + width / 2.0, y0 + depth / 2.0, z0 + height / 2.0),
    ).union(
        box(
            (width, depth - 2.0 * radius, height),
            (x0 + width / 2.0, y0 + depth / 2.0, z0 + height / 2.0),
        )
    )
    for x in (x0 + radius, x0 + width - radius):
        for y in (y0 + radius, y0 + depth - radius):
            model = model.union(cylinder_z(radius, height, x, y, z0))
    return model


def pcb_geometry() -> dict[str, float | list[tuple[float, float]]]:
    cavity_width = PCB_WIDTH + PCB_FIT_CLEARANCE
    cavity_depth = PCB_DEPTH + PCB_FIT_CLEARANCE
    outer_width = cavity_width + 2.0 * BUMPER_WALL
    outer_depth = cavity_depth + 2.0 * BUMPER_WALL

    # The PCB is centered inside the clearance envelope.
    pcb_x0 = BUMPER_WALL + PCB_FIT_CLEARANCE / 2.0
    pcb_y0 = BUMPER_WALL + PCB_FIT_CLEARANCE / 2.0
    x_margin = (PCB_WIDTH - PCB_HOLE_SPACING_X) / 2.0
    y_margin = (PCB_DEPTH - PCB_HOLE_SPACING_Y) / 2.0
    hole_centers = [
        (pcb_x0 + x, pcb_y0 + y)
        for x in (x_margin, PCB_WIDTH - x_margin)
        for y in (y_margin, PCB_DEPTH - y_margin)
    ]
    return {
        "cavity_width": cavity_width,
        "cavity_depth": cavity_depth,
        "outer_width": outer_width,
        "outer_depth": outer_depth,
        "pcb_x0": pcb_x0,
        "pcb_y0": pcb_y0,
        "hole_centers": hole_centers,
    }


def build_bumper() -> cq.Workplane:
    g = pcb_geometry()
    cavity_width = float(g["cavity_width"])
    cavity_depth = float(g["cavity_depth"])
    outer_width = float(g["outer_width"])
    outer_depth = float(g["outer_depth"])

    outer_radius = PCB_CORNER_RADIUS + BUMPER_WALL
    inner_radius = PCB_CORNER_RADIUS + PCB_FIT_CLEARANCE / 2.0
    outer = rounded_rect_prism(
        outer_width,
        outer_depth,
        BUMPER_HEIGHT,
        outer_radius,
    )
    cavity = rounded_rect_prism(
        cavity_width,
        cavity_depth,
        BUMPER_HEIGHT + 2.0,
        inner_radius,
        BUMPER_WALL,
        BUMPER_WALL,
        -1.0,
    )
    model = outer.cut(cavity)

    # A broad, low ring ties the insert bosses and battery sled into the wall
    # while leaving the controller underside open for solder joints and wiring.
    flange_void_width = cavity_width - 2.0 * BASE_FLANGE_INSET
    flange_void_depth = cavity_depth - 2.0 * BASE_FLANGE_INSET
    flange = rounded_rect_prism(
        outer_width,
        outer_depth,
        BASE_FLANGE_THICKNESS,
        outer_radius,
    ).cut(
        rounded_rect_prism(
            flange_void_width,
            flange_void_depth,
            BASE_FLANGE_THICKNESS + 2.0,
            1.0,
            BUMPER_WALL + BASE_FLANGE_INSET,
            BUMPER_WALL + BASE_FLANGE_INSET,
            -1.0,
        )
    )
    model = model.union(flange)

    # Four elevated PCB supports.  The insert pockets are cut only after all
    # nearby support geometry has been united, so their diameters stay exact.
    for x, y in g["hole_centers"]:  # type: ignore[index]
        model = model.union(
            cylinder_z(BOSS_DIAMETER / 2.0, PCB_SUPPORT_HEIGHT, x, y, 0.0)
        )

    for x, y in g["hole_centers"]:  # type: ignore[index]
        main_z0 = PCB_SUPPORT_HEIGHT - INSERT_POCKET_DEPTH
        model = model.cut(
            cylinder_z(
                INSERT_POCKET_DIAMETER / 2.0,
                INSERT_POCKET_DEPTH + 0.05,
                x,
                y,
                main_z0,
            )
        )
        model = model.cut(
            cylinder_z(
                INSERT_LEAD_DIAMETER / 2.0,
                INSERT_LEAD_DEPTH + 0.05,
                x,
                y,
                PCB_SUPPORT_HEIGHT - INSERT_LEAD_DEPTH,
            )
        )
    return model


def battery_sled_dimensions() -> dict[str, float]:
    g = pcb_geometry()
    inner_width = BATTERY_WIDTH + BATTERY_XY_CLEARANCE
    inner_length = BATTERY_LENGTH + BATTERY_XY_CLEARANCE
    rail_height = BATTERY_FLOOR + BATTERY_THICKNESS + BATTERY_Z_CLEARANCE
    inner_x0 = float(g["pcb_x0"]) + BATTERY_X_FROM_PCB_LEFT
    # Leave material between the front bumper wall and the battery pocket.  The
    # pouch is placed from above before the controller PCB is screwed down.
    inner_y0 = float(g["pcb_y0"]) + 3.00
    return {
        "inner_width": inner_width,
        "inner_length": inner_length,
        "inner_x0": inner_x0,
        "inner_y0": inner_y0,
        "rail_height": rail_height,
    }


def build_battery_sled() -> cq.Workplane:
    d = battery_sled_dimensions()
    inner_width = d["inner_width"]
    inner_length = d["inner_length"]
    inner_x0 = d["inner_x0"]
    inner_y0 = d["inner_y0"]
    rail_height = d["rail_height"]

    outer_x0 = inner_x0 - BATTERY_RAIL
    outer_width = inner_width + 2.0 * BATTERY_RAIL
    floor_y0 = inner_y0 - BATTERY_REAR_STOP
    sled_length = inner_length + 2.0 * BATTERY_REAR_STOP

    floor = box(
        (outer_width, sled_length, BATTERY_FLOOR),
        (
            outer_x0 + outer_width / 2.0,
            floor_y0 + sled_length / 2.0,
            BATTERY_FLOOR / 2.0,
        ),
    )
    model = floor

    for rail_x in (outer_x0, inner_x0 + inner_width):
        model = model.union(
            box(
                (BATTERY_RAIL, inner_length, rail_height),
                (
                    rail_x + BATTERY_RAIL / 2.0,
                    inner_y0 + inner_length / 2.0,
                    rail_height / 2.0,
                ),
            )
        )

    # Front and rear stops keep the battery from sliding out.  The installed
    # controller PCB becomes the roof of this otherwise top-loading pocket.
    stop_overlap = 0.20
    for stop_y in (
        inner_y0 - BATTERY_REAR_STOP,
        inner_y0 + inner_length - stop_overlap,
    ):
        model = model.union(
            box(
                (
                    outer_width,
                    BATTERY_REAR_STOP + stop_overlap,
                    rail_height,
                ),
                (
                    outer_x0 + outer_width / 2.0,
                    stop_y + (BATTERY_REAR_STOP + stop_overlap) / 2.0,
                    rail_height / 2.0,
                ),
            )
        )

    # The pouch leads emerge at its rear-left corner.  Remove the upper wall
    # material at that corner while preserving the floor beneath the battery.
    notch_y0 = inner_y0 + inner_length - BATTERY_CABLE_NOTCH
    model = model.cut(
        box(
            (
                BATTERY_RAIL + BATTERY_CABLE_NOTCH,
                BATTERY_CABLE_NOTCH + BATTERY_REAR_STOP + 1.0,
                rail_height - BATTERY_FLOOR + 1.0,
            ),
            (
                outer_x0 + (BATTERY_RAIL + BATTERY_CABLE_NOTCH) / 2.0,
                notch_y0
                + (BATTERY_CABLE_NOTCH + BATTERY_REAR_STOP + 1.0) / 2.0,
                BATTERY_FLOOR
                + (rail_height - BATTERY_FLOOR + 1.0) / 2.0,
            ),
        )
    )
    return model


def normalized_bts_standoff() -> cq.Workplane:
    if not REFERENCE.exists():
        raise FileNotFoundError(f"missing supplied BTS standoff: {REFERENCE}")
    model = importers.importStep(str(REFERENCE))
    # In the supplied file the four long standoffs run along Y.  Rotate them so
    # the square frame becomes the ground-contact base and the four screw-in
    # prongs rise in +Z, then move the complete part onto the XY print bed.
    model = model.rotate((0, 0, 0), (1, 0, 0), 90.0)
    bounds = model.val().BoundingBox()
    model = model.translate((-bounds.xmin, -bounds.ymin, -bounds.zmin))

    # Turn the four circular posts into outward-reinforced D profiles.  The two
    # left flats face +X and the two right flats face -X, matching the flat
    # rectangular heatsink rather than aiming diagonally at its corners.
    post_height = model.val().BoundingBox().zmax - BTS_BASE_HEIGHT
    cutter_depth = 8.0
    cutter_width = 10.0
    for post_x, post_y in BTS_POST_CENTERS:
        toward_x = 1.0 if post_x < BTS_PATTERN_CENTER[0] else -1.0
        toward_y = 0.0
        away_x = -toward_x
        away_y = 0.0

        # Add strength outside the board/heatsink envelope.
        model = model.union(
            cylinder_z(
                BTS_POST_REINFORCE_RADIUS,
                post_height,
                post_x + away_x * BTS_POST_REINFORCE_SHIFT,
                post_y + away_y * BTS_POST_REINFORCE_SHIFT,
                BTS_BASE_HEIGHT,
            )
        )

        # Add two low exterior gussets at each root.  They overlap the post and
        # floor frame, restoring positive contact even after the post profile
        # is flattened.  Keeping them outside the module volume preserves the
        # heatsink clearance above.
        outward_x = -1.0 if post_x < BTS_PATTERN_CENTER[0] else 1.0
        outward_y = -1.0 if post_y < BTS_PATTERN_CENTER[1] else 1.0
        for gusset_dx, gusset_dy in ((outward_x, 0.0), (0.0, outward_y)):
            gusset_angle = math.degrees(math.atan2(gusset_dy, gusset_dx))
            gusset = (
                cq.Workplane("XZ")
                .polyline(
                    [
                        (0.0, 0.0),
                        (BTS_GUSSET_REACH, 0.0),
                        (0.0, BTS_GUSSET_HEIGHT),
                    ]
                )
                .close()
                .extrude(BTS_GUSSET_THICKNESS / 2.0, both=True)
            )
            gusset = gusset.rotate(
                (0, 0, 0),
                (0, 0, 1),
                gusset_angle,
            ).translate((post_x, post_y, BTS_BASE_HEIGHT - 0.20))
            model = model.union(gusset)

        # Remove the horizontally inward side with an X-normal plane.
        angle = math.degrees(math.atan2(toward_y, toward_x))
        cutter = cq.Workplane("XY").box(
            cutter_depth,
            cutter_width,
            post_height + 0.20,
            centered=(True, True, False),
        )
        cutter = cutter.rotate((0, 0, 0), (0, 0, 1), angle)
        cutter = cutter.translate(
            (
                post_x
                + toward_x * (BTS_POST_FLAT_OFFSET + cutter_depth / 2.0),
                post_y
                + toward_y * (BTS_POST_FLAT_OFFSET + cutter_depth / 2.0),
                BTS_BASE_HEIGHT,
            )
        )
        model = model.cut(cutter)

        # Restore the original centered screw bore after adding reinforcement.
        model = model.cut(
            cylinder_z(
                BTS_SCREW_HOLE_DIAMETER / 2.0,
                post_height + 2.0,
                post_x,
                post_y,
                BTS_BASE_HEIGHT - 1.0,
            )
        )
    return model.clean()


def add_mounting_ears(model: cq.Workplane) -> cq.Workplane:
    g = pcb_geometry()
    outer_width = float(g["outer_width"])
    outer_depth = float(g["outer_depth"])
    ear_x_positions = (MOUNT_EAR_X_INSET, outer_width - MOUNT_EAR_X_INSET)
    ear_y_positions = (-MOUNT_EAR_OUTBOARD, outer_depth + MOUNT_EAR_OUTBOARD)
    neck_depth = MOUNT_EAR_OUTBOARD + 2.0
    for x in ear_x_positions:
        for y in ear_y_positions:
            model = model.union(
                cylinder_z(
                    MOUNT_EAR_RADIUS,
                    MOUNT_EAR_THICKNESS,
                    x,
                    y,
                    0.0,
                )
            )

            wall_y = 0.0 if y < 0.0 else outer_depth
            model = model.union(
                box(
                    (2.0 * MOUNT_EAR_RADIUS, neck_depth, MOUNT_EAR_THICKNESS),
                    (
                        x,
                        (y + wall_y) / 2.0,
                        MOUNT_EAR_THICKNESS / 2.0,
                    ),
                )
            )
            model = model.cut(
                cylinder_z(
                    MOUNT_EAR_HOLE_DIAMETER / 2.0,
                    MOUNT_EAR_THICKNESS + 2.0,
                    x,
                    y,
                    -1.0,
                )
            )
    return model


def build_carrier() -> cq.Workplane:
    g = pcb_geometry()
    outer_width = float(g["outer_width"])
    outer_depth = float(g["outer_depth"])

    model = build_bumper().union(build_battery_sled())

    # Connector-sized portal for the XIAO pigtail.  It opens through the left
    # side wall from just above a small protective sill to the top of the
    # bumper.  The 16 x 13.3 mm opening passes the complete 2-pin JST housing,
    # not only the red/black wires.
    port_y = outer_depth / 2.0
    model = model.cut(
        box(
            (
                BUMPER_WALL + 3.0,
                PIGTAIL_PORT_WIDTH,
                BUMPER_HEIGHT - PIGTAIL_PORT_SILL + 2.0,
            ),
            (
                BUMPER_WALL / 2.0 - 1.0,
                port_y,
                PIGTAIL_PORT_SILL
                + (BUMPER_HEIGHT - PIGTAIL_PORT_SILL + 2.0) / 2.0,
            ),
        )
    )

    bts = normalized_bts_standoff()
    bts_bounds = bts.val().BoundingBox()
    bts_x0 = outer_width + BTS_GAP
    bts_y0 = (outer_depth - bts_bounds.ylen) / 2.0
    bts = bts.translate((bts_x0, bts_y0, 0.0))
    model = model.union(bts)

    # Two separated bridges preserve the BTS base's central mounting hole and
    # make the side-by-side assembly one load-bearing print.
    bridge_x0 = outer_width - 1.50
    bridge_x1 = bts_x0 + 3.00
    bridge_length = bridge_x1 - bridge_x0
    for local_y in (8.0, bts_bounds.ylen - 8.0):
        y = bts_y0 + local_y
        model = model.union(
            box(
                (bridge_length, 7.0, BRIDGE_THICKNESS),
                (
                    bridge_x0 + bridge_length / 2.0,
                    y,
                    BRIDGE_THICKNESS / 2.0,
                ),
            )
        )

    model = add_mounting_ears(model)
    return model.clean()


def build_fit_gauge() -> cq.Workplane:
    """Small coupon for checking one insert and the battery cross-section."""
    d = battery_sled_dimensions()
    gauge_depth = 12.0
    inner_width = d["inner_width"]
    rail_height = d["rail_height"]
    outer_width = inner_width + 2.0 * BATTERY_RAIL

    model = box(
        (outer_width, gauge_depth, BATTERY_FLOOR),
        (outer_width / 2.0, gauge_depth / 2.0, BATTERY_FLOOR / 2.0),
    )
    for rail_x in (0.0, BATTERY_RAIL + inner_width):
        model = model.union(
            box(
                (BATTERY_RAIL, gauge_depth, rail_height),
                (
                    rail_x + BATTERY_RAIL / 2.0,
                    gauge_depth / 2.0,
                    rail_height / 2.0,
                ),
            )
        )

    boss_x = outer_width + 7.0
    boss_y = gauge_depth / 2.0
    model = model.union(
        cylinder_z(BOSS_DIAMETER / 2.0, PCB_SUPPORT_HEIGHT, boss_x, boss_y, 0.0)
    )
    model = model.union(
        box(
            (7.0, gauge_depth, BASE_FLANGE_THICKNESS),
            (
                outer_width + 3.5,
                gauge_depth / 2.0,
                BASE_FLANGE_THICKNESS / 2.0,
            ),
        )
    )
    model = model.cut(
        cylinder_z(
            INSERT_POCKET_DIAMETER / 2.0,
            INSERT_POCKET_DEPTH + 0.05,
            boss_x,
            boss_y,
            PCB_SUPPORT_HEIGHT - INSERT_POCKET_DEPTH,
        )
    )
    model = model.cut(
        cylinder_z(
            INSERT_LEAD_DIAMETER / 2.0,
            INSERT_LEAD_DEPTH + 0.05,
            boss_x,
            boss_y,
            PCB_SUPPORT_HEIGHT - INSERT_LEAD_DEPTH,
        )
    )
    return model.clean()


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
        tolerance=0.05,
        angularTolerance=0.10,
    )


def export_svg(model: cq.Workplane) -> None:
    for filename, direction, show_hidden in (
        ("motor-driver-carrier-preview.svg", (1.0, -1.0, 0.72), False),
        ("motor-driver-carrier-top.svg", (0.0, 0.0, 1.0), True),
    ):
        exporters.export(
            model,
            str(OUT / filename),
            exportType="SVG",
            opt={
                "width": 1400,
                "height": 850,
                "marginLeft": 25,
                "marginTop": 25,
                "projectionDir": direction,
                "showAxes": False,
                "showHidden": show_hidden,
                "strokeWidth": 0.7,
            },
        )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    carrier = build_carrier()
    gauge = build_fit_gauge()
    bts_fit_test = normalized_bts_standoff()
    validate("carrier", carrier)
    validate("fit gauge", gauge)
    validate("BTS D-post fit test", bts_fit_test)
    export_model(carrier, "motor-driver-carrier")
    export_model(gauge, "motor-driver-carrier-fit-gauge")
    export_model(bts_fit_test, "bts7960-d-flat-fit-test")
    export_svg(carrier)
    print(f"Generated carrier files in {OUT}")


if __name__ == "__main__":
    main()
