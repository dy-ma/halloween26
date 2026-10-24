"""Vertical battery sidecar for the already-printed motor-driver carrier.

The sidecar attaches above the two original left-edge mounting ears.  The
battery stands on its 67 x 10 mm edge in an open-top pocket.  A 12.37 mm
Velcro strap threads through two rounded floor slots and a recessed underside
channel.  Two new outer ears restore accessible mounting points.

All dimensions are millimetres.  The model is generated with CadQuery/OCC.
"""

from __future__ import annotations

from collections import Counter
from pathlib import Path
import struct

import cadquery as cq
from cadquery import exporters, importers


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"
EXISTING_CASE = Path(
    "/Users/dylanang/Downloads/prints/"
    "motor-driver-carrier-BATTERY-SHELF-ITERATION - Part 1.step"
)

# Battery envelope supplied by the user.
BATTERY_LENGTH = 67.00
BATTERY_THICKNESS = 10.00
BATTERY_HEIGHT = 36.00

# A little freedom for heat-shrink, labels, and normal print variation.  The
# Velcro strap removes any rattle without rigidly squeezing a pouch cell.
CAVITY_LENGTH = 68.50
CAVITY_THICKNESS = 11.50
BASE_THICKNESS = 3.20
SIDE_WALL = 3.50
END_WALL = 2.40
TOP_CLEARANCE = 1.00

# Existing carrier geometry: its two original M4-clearance ears are centered
# at X=-3 and Y=10 / 47.3.  The new attachment stacks above those ears with a
# 0.15 mm assembly gap.  M3 hardware fits more comfortably beside the bumper
# wall than M4 heads or nuts do.
CASE_TAB_X = -3.00
CASE_TAB_YS = (10.00, 47.30)
CASE_TAB_TOP = 3.20
INTERFACE_GAP = 0.15
INTERFACE_LUG_RADIUS = 6.00
INTERFACE_LUG_THICKNESS = 3.20
INTERFACE_HOLE_DIAMETER = 3.40

# Pocket placement.  The closest wall stops 0.5 mm before the original case
# ears, leaving them free while the elevated lugs bridge across their tops.
POCKET_Y_CENTER = 28.65
POCKET_RIGHT_X = -9.50
POCKET_OUTER_WIDTH = CAVITY_THICKNESS + 2.0 * SIDE_WALL
POCKET_OUTER_LENGTH = CAVITY_LENGTH + 2.0 * END_WALL
POCKET_LEFT_X = POCKET_RIGHT_X - POCKET_OUTER_WIDTH
POCKET_Y0 = POCKET_Y_CENTER - POCKET_OUTER_LENGTH / 2.0
POCKET_HEIGHT = BASE_THICKNESS + BATTERY_HEIGHT + TOP_CLEARANCE

# 12.37 mm Velcro strap.
STRAP_SLOT_LENGTH = 13.50
STRAP_SLOT_WIDTH = 3.00
STRAP_CHANNEL_DEPTH = 1.80

# New accessible outer mounting ears.
OUTER_EAR_RADIUS = 7.00
OUTER_EAR_CENTER_X = POCKET_LEFT_X - 8.00
OUTER_EAR_HOLE_DIAMETER = 4.20
OUTER_EAR_THICKNESS = 3.20


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
    x0: float,
    y0: float,
    z0: float,
) -> cq.Workplane:
    """Axis-aligned rounded rectangular prism located by its lower corner."""
    core_x = box(
        (width - 2.0 * radius, depth, height),
        (x0 + width / 2.0, y0 + depth / 2.0, z0 + height / 2.0),
    )
    core_y = box(
        (width, depth - 2.0 * radius, height),
        (x0 + width / 2.0, y0 + depth / 2.0, z0 + height / 2.0),
    )
    model = core_x.union(core_y)
    for x in (x0 + radius, x0 + width - radius):
        for y in (y0 + radius, y0 + depth - radius):
            model = model.union(cylinder_z(radius, height, x, y, z0))
    return model


def capsule_slot_z(
    width: float,
    length: float,
    height: float,
    x: float,
    y: float,
    z0: float,
) -> cq.Workplane:
    """Rounded slot with its long direction parallel to Y."""
    radius = width / 2.0
    straight = length - width
    model = box((width, straight, height), (x, y, z0 + height / 2.0))
    for end_y in (y - straight / 2.0, y + straight / 2.0):
        model = model.union(cylinder_z(radius, height, x, end_y, z0))
    return model


def build_sidecar() -> cq.Workplane:
    outer = rounded_rect_prism(
        POCKET_OUTER_WIDTH,
        POCKET_OUTER_LENGTH,
        POCKET_HEIGHT,
        3.00,
        POCKET_LEFT_X,
        POCKET_Y0,
        0.0,
    )
    cavity = rounded_rect_prism(
        CAVITY_THICKNESS,
        CAVITY_LENGTH,
        POCKET_HEIGHT + 2.0,
        1.60,
        POCKET_LEFT_X + SIDE_WALL,
        POCKET_Y0 + END_WALL,
        BASE_THICKNESS,
    )
    model = outer.cut(cavity)

    # Large outer-face window for pushing and lifting the battery.  The end
    # towers, bottom rail, and top rim remain continuous around the opening.
    model = model.cut(
        box(
            (SIDE_WALL + 2.0, 46.0, 24.0),
            (
                POCKET_LEFT_X + SIDE_WALL / 2.0 - 0.5,
                POCKET_Y_CENTER,
                22.5,
            ),
        )
    )

    # The cable exits toward the existing bumper's pigtail portal.
    model = model.cut(
        box(
            (SIDE_WALL + 2.0, 16.0, 15.0),
            (
                POCKET_RIGHT_X - SIDE_WALL / 2.0 + 0.5,
                POCKET_Y_CENTER,
                POCKET_HEIGHT - 7.0,
            ),
        )
    )

    # Two rounded strap slots sit in the broad side rails.  The channel cut
    # from below lets the strap lie nearly flush instead of rocking the holder.
    cavity_left_x = POCKET_LEFT_X + SIDE_WALL
    cavity_right_x = cavity_left_x + CAVITY_THICKNESS
    slot_xs = (
        POCKET_LEFT_X + SIDE_WALL / 2.0,
        cavity_right_x + SIDE_WALL / 2.0,
    )
    for slot_x in slot_xs:
        model = model.cut(
            capsule_slot_z(
                STRAP_SLOT_WIDTH,
                STRAP_SLOT_LENGTH,
                BASE_THICKNESS + 0.4,
                slot_x,
                POCKET_Y_CENTER,
                -0.2,
            )
        )
    channel_x0 = slot_xs[0] - STRAP_SLOT_WIDTH / 2.0
    channel_x1 = slot_xs[1] + STRAP_SLOT_WIDTH / 2.0
    model = model.cut(
        box(
            (
                channel_x1 - channel_x0,
                STRAP_SLOT_LENGTH,
                STRAP_CHANNEL_DEPTH,
            ),
            (
                (channel_x0 + channel_x1) / 2.0,
                POCKET_Y_CENTER,
                STRAP_CHANNEL_DEPTH / 2.0,
            ),
        )
    )

    # Elevated D-shaped lugs stack above the existing printed tabs.  Their
    # X=0 side is flattened for clearance from the controller bumper wall.
    lug_z0 = CASE_TAB_TOP + INTERFACE_GAP
    for y in CASE_TAB_YS:
        lug = cylinder_z(
            INTERFACE_LUG_RADIUS,
            INTERFACE_LUG_THICKNESS,
            CASE_TAB_X,
            y,
            lug_z0,
        ).union(
            box(
                (10.0, 10.0, INTERFACE_LUG_THICKNESS),
                (-5.0, y, lug_z0 + INTERFACE_LUG_THICKNESS / 2.0),
            )
        )
        lug = lug.cut(
            box(
                (10.0, 20.0, INTERFACE_LUG_THICKNESS + 2.0),
                (4.85, y, lug_z0 + INTERFACE_LUG_THICKNESS / 2.0),
            )
        )
        lug = lug.cut(
            cylinder_z(
                INTERFACE_HOLE_DIAMETER / 2.0,
                INTERFACE_LUG_THICKNESS + 2.0,
                CASE_TAB_X,
                y,
                lug_z0 - 1.0,
            )
        )
        model = model.union(lug)

    # Two new outer M4-clearance ears.  Together with the two stacked interface
    # holes, they provide four mounting points for the combined assembly.
    for y in CASE_TAB_YS:
        ear = cylinder_z(
            OUTER_EAR_RADIUS,
            OUTER_EAR_THICKNESS,
            OUTER_EAR_CENTER_X,
            y,
            0.0,
        ).union(
            box(
                (10.0, 2.0 * OUTER_EAR_RADIUS, OUTER_EAR_THICKNESS),
                (
                    (OUTER_EAR_CENTER_X + POCKET_LEFT_X) / 2.0,
                    y,
                    OUTER_EAR_THICKNESS / 2.0,
                ),
            )
        )
        ear = ear.cut(
            cylinder_z(
                OUTER_EAR_HOLE_DIAMETER / 2.0,
                OUTER_EAR_THICKNESS + 2.0,
                OUTER_EAR_CENTER_X,
                y,
                -1.0,
            )
        )
        model = model.union(ear)

    return model.clean()


def build_battery_envelope() -> cq.Workplane:
    """Non-printing fit-check solid used only in the assembly STEP."""
    return box(
        (BATTERY_THICKNESS, BATTERY_LENGTH, BATTERY_HEIGHT),
        (
            POCKET_LEFT_X + SIDE_WALL + CAVITY_THICKNESS / 2.0,
            POCKET_Y_CENTER,
            BASE_THICKNESS + BATTERY_HEIGHT / 2.0,
        ),
    )


def build_fastener(x: float, y: float) -> cq.Workplane:
    """Simple M3 fastener proxy showing the two attachment axes."""
    lug_top = CASE_TAB_TOP + INTERFACE_GAP + INTERFACE_LUG_THICKNESS
    shaft = cylinder_z(1.45, lug_top + 0.2, x, y, -0.1)
    head = cylinder_z(2.70, 2.00, x, y, lug_top)
    return shaft.union(head)


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


def export_svg(model: cq.Workplane, path: Path, direction: tuple[float, float, float]) -> None:
    exporters.export(
        model,
        str(path),
        exportType="SVG",
        opt={
            "width": 1400,
            "height": 900,
            "marginLeft": 25,
            "marginTop": 25,
            "projectionDir": direction,
            "showAxes": False,
            "showHidden": False,
            "strokeWidth": 0.7,
        },
    )


def main() -> None:
    if not EXISTING_CASE.exists():
        raise FileNotFoundError(EXISTING_CASE)
    OUT.mkdir(parents=True, exist_ok=True)

    sidecar = build_sidecar()
    case = importers.importStep(str(EXISTING_CASE))
    battery = build_battery_envelope()
    fasteners = [build_fastener(CASE_TAB_X, y) for y in CASE_TAB_YS]
    validate("vertical battery sidecar", sidecar)

    stem = OUT / "vertical-battery-sidecar"
    exporters.export(sidecar, str(stem.with_suffix(".step")), exportType="STEP")
    stl_path = stem.with_suffix(".stl")
    exporters.export(
        sidecar,
        str(stl_path),
        exportType="STL",
        tolerance=0.05,
        angularTolerance=0.10,
    )
    validate_binary_stl(stl_path)

    assembly = cq.Assembly(name="motor-driver-carrier-with-battery-sidecar")
    assembly.add(case, name="existing-motor-driver-carrier", color=cq.Color(0.72, 0.75, 0.80))
    assembly.add(sidecar, name="vertical-battery-sidecar", color=cq.Color(0.95, 0.55, 0.12))
    assembly.save(str(OUT / "vertical-battery-sidecar-assembly.step"))

    fit_check = cq.Assembly(name="motor-driver-carrier-sidecar-fit-check")
    fit_check.add(case, name="existing-motor-driver-carrier", color=cq.Color(0.72, 0.75, 0.80))
    fit_check.add(sidecar, name="vertical-battery-sidecar", color=cq.Color(0.95, 0.55, 0.12))
    fit_check.add(battery, name="67x36x10-battery-envelope", color=cq.Color(0.20, 0.35, 0.75, 0.65))
    for index, fastener in enumerate(fasteners, start=1):
        fit_check.add(fastener, name=f"M3-attachment-axis-{index}", color=cq.Color(0.35, 0.35, 0.35))
    fit_check.save(str(OUT / "vertical-battery-sidecar-fit-check.step"))

    assembly_shape = cq.Workplane(
        obj=cq.Compound.makeCompound(
            [case.val(), sidecar.val(), battery.val(), *(item.val() for item in fasteners)]
        )
    )
    export_svg(sidecar, OUT / "vertical-battery-sidecar-preview.svg", (1.0, -1.0, 0.72))
    export_svg(
        assembly_shape,
        OUT / "vertical-battery-sidecar-assembly-preview.svg",
        (1.0, -1.0, 0.72),
    )
    export_svg(
        assembly_shape,
        OUT / "vertical-battery-sidecar-assembly-top.svg",
        (0.0, 0.0, 1.0),
    )
    print(f"Generated sidecar files in {OUT}")


if __name__ == "__main__":
    main()
