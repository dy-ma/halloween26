"""Single-piece motor-driver carrier with an integrated vertical battery pocket.

The proven 67 x 36 x 10 mm battery cavity is placed directly beside the long
edge of the controller bumper.  It is fused to the existing four-wing carrier
at floor level, eliminating the elevated sidecar interface and its supports.
The outer access window is open to the top, so it has no horizontal bridge.

All dimensions are millimetres.  Generated with CadQuery/OpenCascade.
"""

from __future__ import annotations

from collections import Counter
from pathlib import Path
import struct

import cadquery as cq
from cadquery import exporters, importers

import generate_carrier as legacy_carrier


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"
CARRIER_STEP = OUT / "motor-driver-carrier-user-cutouts-4-tabs.step"

# Battery and proven cavity dimensions.
BATTERY_LENGTH = 67.00
BATTERY_THICKNESS = 10.00
BATTERY_HEIGHT = 36.00
CAVITY_LENGTH = 68.50
CAVITY_THICKNESS = 11.50
BASE_THICKNESS = 3.20
SIDE_WALL = 3.50
END_WALL = 2.40
TOP_CLEARANCE = 1.00
POCKET_OUTER_LENGTH = CAVITY_LENGTH + 2.0 * END_WALL
POCKET_OUTER_WIDTH = CAVITY_THICKNESS + 2.0 * SIDE_WALL
POCKET_HEIGHT = BASE_THICKNESS + BATTERY_HEIGHT + TOP_CLEARANCE

# Match the revised carrier's long-side wing spacing.  The old near-side
# wings become buried reinforcement inside the integrated base; no alignment
# or separate fasteners are required.
CASE_WING_XS = (12.00, 83.30)
POCKET_X_CENTER = sum(CASE_WING_XS) / 2.0
POCKET_X0 = POCKET_X_CENTER - POCKET_OUTER_LENGTH / 2.0

# Leave a narrow service gap beside the Y=0 controller-bumper wall so the
# inner Velcro leg can rise outside the battery pocket.  The continuous foot
# still spans the gap and fuses the holder to the carrier at floor level.
POCKET_NEAR_Y = -2.50
POCKET_Y0 = POCKET_NEAR_Y - POCKET_OUTER_WIDTH

# One flat rounded base replaces the integrated-side wings and provides two
# accessible outer M3 mounting holes.
FOOT_RADIUS = 7.00
FOOT_X0 = CASE_WING_XS[0] - FOOT_RADIUS
FOOT_X1 = CASE_WING_XS[1] + FOOT_RADIUS
OUTER_HOLE_Y = POCKET_Y0 - 8.00
FOOT_Y0 = OUTER_HOLE_Y - FOOT_RADIUS
FOOT_Y1 = 0.20
MOUNT_HOLE_DIAMETER = 3.40

# Wall slots for a 12.37 mm Velcro strap.  The outer slot starts at the cavity
# floor.  The inner slot is raised above the 14.5 mm controller-bumper wall,
# preventing a narrow enclosed passage between the two walls and making that
# end easy to thread from above.
STRAP_SLOT_LENGTH = 13.50
STRAP_SLOT_HEIGHT = 4.00
OUTER_STRAP_SLOT_Z0 = BASE_THICKNESS
INNER_STRAP_SLOT_Z0 = 15.50


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
    x_size: float,
    y_size: float,
    height: float,
    radius: float,
    x0: float,
    y0: float,
    z0: float,
) -> cq.Workplane:
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


def remove_legacy_battery_sled(carrier: cq.Workplane) -> cq.Workplane:
    """Remove the small under-PCB battery sled while preserving the bumper."""
    sled = legacy_carrier.build_battery_sled()

    # The old sled was Boolean-united into the controller bumper, so simply
    # subtracting it also removes their coincident flange/wall intersections.
    # Restore the clean bumper afterward, including its original JST portal.
    bumper = legacy_carrier.build_bumper()
    geometry = legacy_carrier.pcb_geometry()
    outer_depth = float(geometry["outer_depth"])
    port_y = outer_depth / 2.0
    bumper = bumper.cut(
        legacy_carrier.box(
            (
                legacy_carrier.BUMPER_WALL + 3.0,
                legacy_carrier.PIGTAIL_PORT_WIDTH,
                legacy_carrier.BUMPER_HEIGHT
                - legacy_carrier.PIGTAIL_PORT_SILL
                + 2.0,
            ),
            (
                legacy_carrier.BUMPER_WALL / 2.0 - 1.0,
                port_y,
                legacy_carrier.PIGTAIL_PORT_SILL
                + (
                    legacy_carrier.BUMPER_HEIGHT
                    - legacy_carrier.PIGTAIL_PORT_SILL
                    + 2.0
                )
                / 2.0,
            ),
        )
    )
    return carrier.cut(sled).union(bumper).clean()


def build_integrated_carrier() -> cq.Workplane:
    if not CARRIER_STEP.exists():
        raise FileNotFoundError(CARRIER_STEP)
    carrier = importers.importStep(str(CARRIER_STEP))
    carrier = remove_legacy_battery_sled(carrier)

    pocket_outer = rounded_rect_prism(
        POCKET_OUTER_LENGTH,
        POCKET_OUTER_WIDTH,
        POCKET_HEIGHT,
        3.00,
        POCKET_X0,
        POCKET_Y0,
        0.0,
    )
    foot = rounded_rect_prism(
        FOOT_X1 - FOOT_X0,
        FOOT_Y1 - FOOT_Y0,
        BASE_THICKNESS,
        FOOT_RADIUS,
        FOOT_X0,
        FOOT_Y0,
        0.0,
    )
    model = carrier.union(pocket_outer).union(foot)

    cavity = rounded_rect_prism(
        CAVITY_LENGTH,
        CAVITY_THICKNESS,
        POCKET_HEIGHT + 2.0,
        1.60,
        POCKET_X0 + END_WALL,
        POCKET_Y0 + SIDE_WALL,
        BASE_THICKNESS,
    )
    model = model.cut(cavity)

    # Support-free U-shaped access opening: it begins above a 10 mm bottom
    # rail and remains open through the top, eliminating the former 46 mm
    # horizontal bridge while preserving both end towers.
    window_z0 = 10.00
    model = model.cut(
        box(
            (46.0, SIDE_WALL + 2.0, POCKET_HEIGHT - window_z0 + 2.0),
            (
                POCKET_X_CENTER,
                POCKET_Y0 + SIDE_WALL / 2.0 - 0.5,
                (window_z0 + POCKET_HEIGHT + 2.0) / 2.0,
            ),
        )
    )

    # Open-top cable relief through the wall facing the controller.
    cable_z0 = 24.00
    model = model.cut(
        box(
            (16.0, SIDE_WALL + 2.0, POCKET_HEIGHT - cable_z0 + 2.0),
            (
                POCKET_X_CENTER,
                POCKET_NEAR_Y - SIDE_WALL / 2.0 + 0.5,
                (cable_z0 + POCKET_HEIGHT + 2.0) / 2.0,
            ),
        )
    )

    # The outer horizontal slot is flush with the cavity floor.  The inner
    # slot is raised above the adjacent 14.5 mm controller wall, so it opens
    # directly into free space instead of a narrow 2.5 mm vertical passage.
    # The strap lies under the battery, turns upward inside the pocket, exits
    # through the raised slot, and closes over the top.
    cavity_far_y = POCKET_Y0 + SIDE_WALL
    cavity_near_y = cavity_far_y + CAVITY_THICKNESS
    slots = (
        (POCKET_Y0 + SIDE_WALL / 2.0, OUTER_STRAP_SLOT_Z0),
        (cavity_near_y + SIDE_WALL / 2.0, INNER_STRAP_SLOT_Z0),
    )
    for slot_y, slot_z0 in slots:
        model = model.cut(
            box(
                (STRAP_SLOT_LENGTH, SIDE_WALL + 1.0, STRAP_SLOT_HEIGHT),
                (
                    POCKET_X_CENTER,
                    slot_y,
                    slot_z0 + STRAP_SLOT_HEIGHT / 2.0,
                ),
            )
        )

    for x in CASE_WING_XS:
        model = model.cut(
            cylinder_z(
                MOUNT_HOLE_DIAMETER / 2.0,
                BASE_THICKNESS + 2.0,
                x,
                OUTER_HOLE_Y,
                -1.0,
            )
        )

    return model.clean()


def build_battery_envelope() -> cq.Workplane:
    return box(
        (BATTERY_LENGTH, BATTERY_THICKNESS, BATTERY_HEIGHT),
        (
            POCKET_X_CENTER,
            POCKET_Y0 + SIDE_WALL + CAVITY_THICKNESS / 2.0,
            BASE_THICKNESS + BATTERY_HEIGHT / 2.0,
        ),
    )


def build_strap_path_envelope() -> cq.Workplane:
    """A connected gauge following the low slot, riser, and raised exit."""
    gauge_x = STRAP_SLOT_LENGTH - 1.0
    cavity_far_y = POCKET_Y0 + SIDE_WALL
    cavity_near_y = cavity_far_y + CAVITY_THICKNESS

    low_y0 = POCKET_Y0 - 0.5
    low_y1 = cavity_near_y - 0.35
    low_leg = box(
        (gauge_x, low_y1 - low_y0, STRAP_SLOT_HEIGHT - 1.0),
        (
            POCKET_X_CENTER,
            (low_y0 + low_y1) / 2.0,
            OUTER_STRAP_SLOT_Z0 + (STRAP_SLOT_HEIGHT - 1.0) / 2.0,
        ),
    )

    riser_y0 = cavity_near_y - 0.70
    riser_y1 = cavity_near_y - 0.10
    riser_z0 = OUTER_STRAP_SLOT_Z0 + 0.5
    riser_z1 = INNER_STRAP_SLOT_Z0 + STRAP_SLOT_HEIGHT - 0.5
    riser = box(
        (gauge_x, riser_y1 - riser_y0, riser_z1 - riser_z0),
        (
            POCKET_X_CENTER,
            (riser_y0 + riser_y1) / 2.0,
            (riser_z0 + riser_z1) / 2.0,
        ),
    )

    high_y0 = cavity_near_y - 0.5
    high_y1 = POCKET_NEAR_Y + 0.5
    high_exit = box(
        (gauge_x, high_y1 - high_y0, STRAP_SLOT_HEIGHT - 1.0),
        (
            POCKET_X_CENTER,
            (high_y0 + high_y1) / 2.0,
            INNER_STRAP_SLOT_Z0 + (STRAP_SLOT_HEIGHT - 1.0) / 2.0,
        ),
    )
    return low_leg.union(riser).union(high_exit).clean()


def validate_solid(label: str, model: cq.Workplane) -> None:
    solids = model.solids().vals()
    if len(solids) != 1:
        raise RuntimeError(f"{label}: expected one solid, found {len(solids)}")
    if not solids[0].isValid():
        raise RuntimeError(f"{label}: OpenCascade reports an invalid solid")
    bounds = solids[0].BoundingBox()
    print(
        f"{label}: one valid solid; "
        f"size={bounds.xlen:.2f} x {bounds.ylen:.2f} x {bounds.zlen:.2f} mm; "
        f"volume={solids[0].Volume():.2f} mm^3"
    )


def validate_binary_stl(path: Path) -> None:
    data = path.read_bytes()
    triangle_count = struct.unpack_from("<I", data, 80)[0]
    if len(data) != 84 + triangle_count * 50:
        raise RuntimeError(f"{path.name}: incomplete binary STL")

    edges: Counter[tuple[tuple[int, int, int], tuple[int, int, int]]] = Counter()
    degenerate = 0
    offset = 84
    for _ in range(triangle_count):
        vertices = []
        for vertex_index in range(3):
            vertex = struct.unpack_from(
                "<3f", data, offset + 12 + vertex_index * 12
            )
            vertices.append(tuple(round(value * 1_000_000) for value in vertex))
        if len(set(vertices)) != 3:
            degenerate += 1
        for first, second in ((0, 1), (1, 2), (2, 0)):
            edges[tuple(sorted((vertices[first], vertices[second])))] += 1
        offset += 50

    bad_edges = sum(count != 2 for count in edges.values())
    if degenerate or bad_edges:
        raise RuntimeError(
            f"{path.name}: {degenerate} degenerate triangles, "
            f"{bad_edges} boundary/non-manifold edges"
        )
    print(
        f"{path.name}: watertight mesh; triangles={triangle_count}; "
        "degenerate=0; boundary/non-manifold edges=0"
    )


def export_svg(
    model: cq.Workplane,
    path: Path,
    direction: tuple[float, float, float],
) -> None:
    exporters.export(
        model,
        str(path),
        exportType="SVG",
        opt={
            "width": 1500,
            "height": 950,
            "marginLeft": 25,
            "marginTop": 25,
            "projectionDir": direction,
            "showAxes": False,
            "showHidden": False,
            "strokeWidth": 0.7,
        },
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    model = build_integrated_carrier()
    battery = build_battery_envelope()
    strap_path = build_strap_path_envelope()
    validate_solid("integrated motor-driver and battery carrier", model)

    battery_overlap = battery.intersect(model)
    overlap_volume = sum(abs(solid.Volume()) for solid in battery_overlap.solids().vals())
    if overlap_volume > 0.001:
        raise RuntimeError(f"battery interference: {overlap_volume:.4f} mm^3")
    print("fit check: battery/carrier interference=0")

    strap_path_overlap = strap_path.intersect(model)
    strap_path_overlap_volume = sum(
        abs(solid.Volume()) for solid in strap_path_overlap.solids().vals()
    )
    if strap_path_overlap_volume > 0.001:
        raise RuntimeError(
            f"strap path obstruction: {strap_path_overlap_volume:.4f} mm^3"
        )
    print("strap check: low outer slot, internal riser, and raised exit are clear")

    stem = OUT / "motor-driver-carrier-integrated-vertical-battery"
    step_path = stem.with_suffix(".step")
    stl_path = stem.with_suffix(".stl")
    exporters.export(model, str(step_path), exportType="STEP")
    exporters.export(
        model,
        str(stl_path),
        exportType="STL",
        tolerance=0.05,
        angularTolerance=0.10,
    )
    validate_binary_stl(stl_path)

    reimported = importers.importStep(str(step_path))
    validate_solid("re-imported integrated STEP", reimported)

    fit_check = cq.Assembly(name="integrated-carrier-battery-fit-check")
    fit_check.add(
        model,
        name="single-piece-integrated-carrier",
        color=cq.Color(0.82, 0.84, 0.88),
    )
    fit_check.add(
        battery,
        name="67x36x10-battery-envelope",
        color=cq.Color(0.20, 0.35, 0.75, 0.65),
    )
    fit_check.save(
        str(OUT / "motor-driver-carrier-integrated-vertical-battery-fit-check.step")
    )

    preview = cq.Workplane(
        obj=cq.Compound.makeCompound([model.val(), battery.val()])
    )
    section_y0 = POCKET_Y0 - 1.0
    section_y1 = 4.0
    strap_section = model.intersect(
        box(
            (0.6, section_y1 - section_y0, POCKET_HEIGHT + 2.0),
            (
                POCKET_X_CENTER,
                (section_y0 + section_y1) / 2.0,
                POCKET_HEIGHT / 2.0,
            ),
        )
    )
    export_svg(
        model,
        OUT / "motor-driver-carrier-integrated-vertical-battery-preview.svg",
        (1.0, -1.0, 0.72),
    )
    export_svg(
        model,
        OUT / "motor-driver-carrier-integrated-vertical-battery-top.svg",
        (0.0, 0.0, 1.0),
    )
    export_svg(
        model,
        OUT / "motor-driver-carrier-integrated-vertical-battery-strap-side.svg",
        (0.0, -1.0, 0.12),
    )
    export_svg(
        strap_section,
        OUT / "motor-driver-carrier-integrated-vertical-battery-strap-section.svg",
        (1.0, 0.0, 0.0),
    )
    export_svg(
        preview,
        OUT / "motor-driver-carrier-integrated-vertical-battery-fit-preview.svg",
        (1.0, -1.0, 0.72),
    )
    print(f"Generated integrated-carrier files in {OUT}")


if __name__ == "__main__":
    main()
