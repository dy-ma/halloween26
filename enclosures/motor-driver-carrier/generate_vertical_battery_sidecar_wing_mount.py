"""Vertical battery sidecar mounted to the carrier's long-side wing tabs.

The battery pocket is dimensionally identical to the first sidecar, but it is
turned parallel to the controller PCB.  Two elevated lugs stack on one pair of
the revised carrier's wing tabs, leaving the short USB-C end unobstructed.

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
EXISTING_CASE = OUT / "motor-driver-carrier-user-cutouts-4-tabs.step"

# Battery and pocket dimensions are unchanged from the proven first sidecar.
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

# Revised carrier wing geometry from add_four_mounting_tabs.py.  This sidecar
# uses the Y-negative pair, visible on the left side in the supplied photo.
BUMPER_DEPTH = 57.30
CASE_WING_XS = (12.00, 83.30)
CASE_WING_Y = -8.00
CASE_WING_TOP = 3.20
WING_RADIUS = 7.00
# The carrier holes are 4.2 mm, but the removable sidecar uses close-clearance
# M3 holes.  The smaller holes leave substantially more plastic around each
# fastener while an M3 bolt and washer still pass through the carrier wings.
WING_HOLE_DIAMETER = 3.40
INTERFACE_GAP = 0.15
INTERFACE_LUG_THICKNESS = 3.20

# The pocket runs parallel to the controller board.  Its ends sit 1 mm beyond
# the wing centers, while its near wall remains 0.5 mm clear of the R7 tabs.
POCKET_X_CENTER = sum(CASE_WING_XS) / 2.0
POCKET_X0 = POCKET_X_CENTER - POCKET_OUTER_LENGTH / 2.0
POCKET_NEAR_Y = CASE_WING_Y - WING_RADIUS - 0.50
POCKET_Y0 = POCKET_NEAR_Y - POCKET_OUTER_WIDTH

# 12.37 mm Velcro strap and recessed underside channel.
STRAP_SLOT_LENGTH = 13.50
STRAP_SLOT_WIDTH = 3.00
STRAP_CHANNEL_DEPTH = 1.80

# One rounded-rectangle footprint surrounds the complete sidecar.  A negative
# underside cut on the carrier-facing side provides clearance for the existing
# printed wings; the remaining upper skin becomes the attachment surface.
OUTER_EAR_CENTER_Y = POCKET_Y0 - 8.00
OUTER_EAR_HOLE_DIAMETER = WING_HOLE_DIAMETER
OUTER_EAR_THICKNESS = 3.20
FOOT_X0 = CASE_WING_XS[0] - WING_RADIUS
FOOT_X1 = CASE_WING_XS[1] + WING_RADIUS
FOOT_Y0 = OUTER_EAR_CENTER_Y - WING_RADIUS
FOOT_Y1 = CASE_WING_Y + WING_RADIUS
ATTACHMENT_FOOT_Y0 = POCKET_NEAR_Y - 1.50


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
    """Axis-aligned rounded rectangular prism located by its lower corner."""
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
    width: float,
    length: float,
    height: float,
    x: float,
    y: float,
    z0: float,
) -> cq.Workplane:
    """Rounded slot with its long direction parallel to X."""
    radius = width / 2.0
    straight = length - width
    model = box((straight, width, height), (x, y, z0 + height / 2.0))
    for end_x in (x - straight / 2.0, x + straight / 2.0):
        model = model.union(cylinder_z(radius, height, end_x, y, z0))
    return model


def build_sidecar() -> cq.Workplane:
    outer = rounded_rect_prism(
        POCKET_OUTER_LENGTH,
        POCKET_OUTER_WIDTH,
        POCKET_HEIGHT,
        3.00,
        POCKET_X0,
        POCKET_Y0,
        0.0,
    )
    # Start with one clean rounded-rectangle footprint for the entire part.
    # Remove the lower carrier-facing band so the already-printed carrier
    # wings can slide underneath it.  The same footprint is intersected with
    # a shallow upper band to form the attachment surface above those wings.
    full_lower_foot = rounded_rect_prism(
        FOOT_X1 - FOOT_X0,
        FOOT_Y1 - FOOT_Y0,
        OUTER_EAR_THICKNESS,
        WING_RADIUS,
        FOOT_X0,
        FOOT_Y0,
        0.0,
    )
    underside_cut_y0 = POCKET_NEAR_Y
    underside_cut_y1 = FOOT_Y1 + 1.0
    underside_cut = box(
        (
            FOOT_X1 - FOOT_X0 + 2.0,
            underside_cut_y1 - underside_cut_y0,
            OUTER_EAR_THICKNESS + 2.0,
        ),
        (
            POCKET_X_CENTER,
            (underside_cut_y0 + underside_cut_y1) / 2.0,
            OUTER_EAR_THICKNESS / 2.0,
        ),
    )
    lower_foot = full_lower_foot.cut(underside_cut)

    full_upper_foot = rounded_rect_prism(
        FOOT_X1 - FOOT_X0,
        FOOT_Y1 - FOOT_Y0,
        INTERFACE_LUG_THICKNESS,
        WING_RADIUS,
        FOOT_X0,
        FOOT_Y0,
        CASE_WING_TOP + INTERFACE_GAP,
    )
    upper_keep = box(
        (
            FOOT_X1 - FOOT_X0 + 2.0,
            FOOT_Y1 - ATTACHMENT_FOOT_Y0 + 1.0,
            INTERFACE_LUG_THICKNESS + 2.0,
        ),
        (
            POCKET_X_CENTER,
            (ATTACHMENT_FOOT_Y0 + FOOT_Y1) / 2.0,
            CASE_WING_TOP
            + INTERFACE_GAP
            + INTERFACE_LUG_THICKNESS / 2.0,
        ),
    )
    attachment_foot = full_upper_foot.intersect(upper_keep)
    model = outer.union(lower_foot).union(attachment_foot)

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

    # Large window on the outward face for lifting the battery out.
    model = model.cut(
        box(
            (46.0, SIDE_WALL + 2.0, 24.0),
            (
                POCKET_X_CENTER,
                POCKET_Y0 + SIDE_WALL / 2.0 - 0.5,
                22.5,
            ),
        )
    )

    # Cable notch through the wall facing the controller.  The USB-C end at
    # X=0 remains completely open because the sidecar begins near X=11.
    model = model.cut(
        box(
            (16.0, SIDE_WALL + 2.0, 15.0),
            (
                POCKET_X_CENTER,
                POCKET_NEAR_Y - SIDE_WALL / 2.0 + 0.5,
                POCKET_HEIGHT - 7.0,
            ),
        )
    )

    # Two rounded strap slots and the recessed channel joining them underneath.
    cavity_far_y = POCKET_Y0 + SIDE_WALL
    cavity_near_y = cavity_far_y + CAVITY_THICKNESS
    slot_ys = (
        POCKET_Y0 + SIDE_WALL / 2.0,
        cavity_near_y + SIDE_WALL / 2.0,
    )
    for slot_y in slot_ys:
        model = model.cut(
            capsule_slot_x(
                STRAP_SLOT_WIDTH,
                STRAP_SLOT_LENGTH,
                BASE_THICKNESS + 0.4,
                POCKET_X_CENTER,
                slot_y,
                -0.2,
            )
        )
    channel_y0 = slot_ys[0] - STRAP_SLOT_WIDTH / 2.0
    channel_y1 = slot_ys[1] + STRAP_SLOT_WIDTH / 2.0
    model = model.cut(
        box(
            (STRAP_SLOT_LENGTH, channel_y1 - channel_y0, STRAP_CHANNEL_DEPTH),
            (
                POCKET_X_CENTER,
                (channel_y0 + channel_y1) / 2.0,
                STRAP_CHANNEL_DEPTH / 2.0,
            ),
        )
    )

    # M3 attachment holes pass through the elevated portion of the same
    # rounded-rectangle footprint.
    lug_z0 = CASE_WING_TOP + INTERFACE_GAP
    for x in CASE_WING_XS:
        model = model.cut(
            cylinder_z(
                WING_HOLE_DIAMETER / 2.0,
                INTERFACE_LUG_THICKNESS + 2.0,
                x,
                CASE_WING_Y,
                lug_z0 - 1.0,
            )
        )

    # Two M3 holes in the far corners of the continuous bottom foot preserve
    # four accessible mounting points for the combined assembly.
    for x in CASE_WING_XS:
        model = model.cut(
            cylinder_z(
                OUTER_EAR_HOLE_DIAMETER / 2.0,
                OUTER_EAR_THICKNESS + 2.0,
                x,
                OUTER_EAR_CENTER_Y,
                -1.0,
            )
        )

    return model.clean()


def build_battery_envelope() -> cq.Workplane:
    """Non-printing fit-check solid used only in the assembly STEP."""
    return box(
        (BATTERY_LENGTH, BATTERY_THICKNESS, BATTERY_HEIGHT),
        (
            POCKET_X_CENTER,
            POCKET_Y0 + SIDE_WALL + CAVITY_THICKNESS / 2.0,
            BASE_THICKNESS + BATTERY_HEIGHT / 2.0,
        ),
    )


def build_fastener(x: float) -> cq.Workplane:
    """Simple M3 fastener proxy showing an attachment axis."""
    lug_top = CASE_WING_TOP + INTERFACE_GAP + INTERFACE_LUG_THICKNESS
    shaft = cylinder_z(1.50, lug_top + 0.2, x, CASE_WING_Y, -0.1)
    head = cylinder_z(2.80, 2.20, x, CASE_WING_Y, lug_top)
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
    fasteners = [build_fastener(x) for x in CASE_WING_XS]
    validate("wing-mounted vertical battery sidecar", sidecar)

    case_overlap = case.intersect(sidecar)
    overlap_volume = sum(abs(solid.Volume()) for solid in case_overlap.solids().vals())
    if overlap_volume > 0.001:
        raise RuntimeError(f"case/sidecar interference: {overlap_volume:.4f} mm^3")
    battery_overlap = battery.intersect(sidecar)
    battery_overlap_volume = sum(
        abs(solid.Volume()) for solid in battery_overlap.solids().vals()
    )
    if battery_overlap_volume > 0.001:
        raise RuntimeError(
            f"battery/sidecar interference: {battery_overlap_volume:.4f} mm^3"
        )
    print("fit check: case/sidecar interference=0; battery/sidecar interference=0")

    stem = OUT / "vertical-battery-sidecar-wing-mount"
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

    assembly = cq.Assembly(name="motor-driver-carrier-with-wing-mounted-sidecar")
    assembly.add(
        case,
        name="four-wing-motor-driver-carrier",
        color=cq.Color(0.72, 0.75, 0.80),
    )
    assembly.add(
        sidecar,
        name="wing-mounted-vertical-battery-sidecar",
        color=cq.Color(0.95, 0.55, 0.12),
    )
    assembly.save(str(OUT / "vertical-battery-sidecar-wing-mount-assembly.step"))

    fit_check = cq.Assembly(name="wing-mounted-battery-sidecar-fit-check")
    fit_check.add(
        case,
        name="four-wing-motor-driver-carrier",
        color=cq.Color(0.72, 0.75, 0.80),
    )
    fit_check.add(
        sidecar,
        name="wing-mounted-vertical-battery-sidecar",
        color=cq.Color(0.95, 0.55, 0.12),
    )
    fit_check.add(
        battery,
        name="67x36x10-battery-envelope",
        color=cq.Color(0.20, 0.35, 0.75, 0.65),
    )
    for index, fastener in enumerate(fasteners, start=1):
        fit_check.add(
            fastener,
            name=f"M3-wing-attachment-axis-{index}",
            color=cq.Color(0.35, 0.35, 0.35),
        )
    fit_check.save(str(OUT / "vertical-battery-sidecar-wing-mount-fit-check.step"))

    assembly_shape = cq.Workplane(
        obj=cq.Compound.makeCompound(
            [case.val(), sidecar.val(), battery.val(), *(item.val() for item in fasteners)]
        )
    )
    export_svg(
        sidecar,
        OUT / "vertical-battery-sidecar-wing-mount-preview.svg",
        (1.0, -1.0, 0.72),
    )
    export_svg(
        sidecar,
        OUT / "vertical-battery-sidecar-wing-mount-top.svg",
        (0.0, 0.0, 1.0),
    )
    export_svg(
        assembly_shape,
        OUT / "vertical-battery-sidecar-wing-mount-assembly-preview.svg",
        (1.0, -1.0, 0.72),
    )
    export_svg(
        assembly_shape,
        OUT / "vertical-battery-sidecar-wing-mount-assembly-top.svg",
        (0.0, 0.0, 1.0),
    )
    print(f"Generated wing-mounted sidecar files in {OUT}")


if __name__ == "__main__":
    main()
