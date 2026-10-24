"""Parametric CadQuery model for the BOSYTRO SJK-24V-480W safety tunnel.

This is genuine solid CAD built with CadQuery/OpenCascade. It exports editable
STEP plus manifold STL files without using Blender.

Run with the project CAD environment:

    /tmp/codex-cadquery-venv/bin/python generate_tunnel.py
"""

from __future__ import annotations

from pathlib import Path

import cadquery as cq
from cadquery import exporters


# ---------------------------------------------------------------------------
# Measured PSU and requested design dimensions (millimetres)
# ---------------------------------------------------------------------------

CHASSIS_WIDTH = 113.09
CHASSIS_HEIGHT = 51.26

# Total clearance around the metal chassis: 0.40 mm nominally per side.
FIT_CLEARANCE = 0.80

WALL = 3.00
FRONT_RECESS = 55.00
PSU_OVERLAP = 40.00
STOP_LIP = 3.00
STOP_THICKNESS = 3.00

# Existing side mounting holes. X is measured back from the terminal face;
# vertical offsets are measured down from the top edge of the chassis.
SIDE_HOLE_X_FROM_FACE = 31.00
SIDE_HOLE_TOP_OFFSETS = (13.40, 38.00)

# Capsule-shaped printed clearance slots tolerate the approximate hole-center
# measurements. Use a washer under the fastener head.
SIDE_SLOT_DIAMETER = 5.50
SIDE_SLOT_LENGTH = 9.00

# Four mounting ears for M3 screws into the mounting surface.
EAR_THICKNESS = 3.00
EAR_LENGTH = 18.00
EAR_OUTBOARD = 12.00
EAR_OVERLAP = 2.00
EAR_HOLE_DIAMETER = 3.60
EAR_X_CENTERS = (18.00, 78.00)
EAR_TOP_ROOT_FILLET = 2.00

GAUGE_LENGTH = 10.00


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"


def box(size: tuple[float, float, float], center: tuple[float, float, float]) -> cq.Workplane:
    """Return an axis-aligned box centered at the supplied coordinate."""
    return cq.Workplane("XY").box(*size).translate(center)


def cylinder_z(radius: float, height: float, x: float, y: float, z0: float) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        height,
        cq.Vector(x, y, z0),
        cq.Vector(0, 0, 1),
    )
    return cq.Workplane(obj=solid)


def cylinder_y(radius: float, depth: float, x: float, y0: float, z: float) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        depth,
        cq.Vector(x, y0, z),
        cq.Vector(0, 1, 0),
    )
    return cq.Workplane(obj=solid)


def rectangular_tube(length: float, inner_width: float, inner_height: float) -> cq.Workplane:
    outer_width = inner_width + 2.0 * WALL
    outer_height = inner_height + 2.0 * WALL
    outer = box(
        (length, outer_width, outer_height),
        (length / 2.0, 0.0, outer_height / 2.0),
    )
    void = box(
        (length + 2.0, inner_width, inner_height),
        (length / 2.0, 0.0, WALL + inner_height / 2.0),
    )
    return outer.cut(void)


def stop_ring(inner_width: float, inner_height: float) -> cq.Workplane:
    """Make the perimeter shoulder that establishes the face recess."""
    ring_center_x = FRONT_RECESS - STOP_THICKNESS / 2.0
    overlap = 0.30
    outer = box(
        (STOP_THICKNESS, inner_width + overlap, inner_height + overlap),
        (ring_center_x, 0.0, WALL + inner_height / 2.0),
    )
    opening = box(
        (
            STOP_THICKNESS + 2.0,
            inner_width - 2.0 * STOP_LIP,
            inner_height - 2.0 * STOP_LIP,
        ),
        (ring_center_x, 0.0, WALL + inner_height / 2.0),
    )
    return outer.cut(opening)


def side_slot_cutter(
    x_center: float,
    z_center: float,
    outer_width: float,
) -> cq.Workplane:
    """Make an X-elongated capsule passing through both side walls."""
    diameter = SIDE_SLOT_DIAMETER
    radius = diameter / 2.0
    straight = SIDE_SLOT_LENGTH - diameter
    span = outer_width + 4.0
    y0 = -span / 2.0

    cutter = box(
        (straight, span, diameter),
        (x_center, 0.0, z_center),
    )
    for x in (x_center - straight / 2.0, x_center + straight / 2.0):
        cutter = cutter.union(cylinder_y(radius, span, x, y0, z_center))
    return cutter


def build_tunnel() -> cq.Workplane:
    inner_width = CHASSIS_WIDTH + FIT_CLEARANCE
    inner_height = CHASSIS_HEIGHT + FIT_CLEARANCE
    outer_width = inner_width + 2.0 * WALL
    outer_height = inner_height + 2.0 * WALL
    total_length = FRONT_RECESS + PSU_OVERLAP

    model = rectangular_tube(total_length, inner_width, inner_height)
    model = model.union(stop_ring(inner_width, inner_height))

    # Four mounting ears. Their inner edges overlap the tunnel slightly so the
    # result is one continuous load-bearing solid.
    outer_edge = outer_width / 2.0
    ear_width = EAR_OUTBOARD + EAR_OVERLAP
    for x_center in EAR_X_CENTERS:
        for sign in (-1.0, 1.0):
            y_center = sign * (outer_edge + (EAR_OUTBOARD - EAR_OVERLAP) / 2.0)
            ear = box(
                (EAR_LENGTH, ear_width, EAR_THICKNESS),
                (x_center, y_center, EAR_THICKNESS / 2.0),
            )
            model = model.union(ear)

            hole_y = sign * (outer_edge + EAR_OUTBOARD / 2.0)
            model = model.cut(
                cylinder_z(
                    EAR_HOLE_DIAMETER / 2.0,
                    EAR_THICKNESS + 2.0,
                    x_center,
                    hole_y,
                    -1.0,
                )
            )

    # Round the concave top edge where each horizontal mounting ear meets the
    # vertical tunnel wall. This adds material through the thin/bending axis of
    # the ear instead of merely rounding its outline in plan view.
    outer_edge = outer_width / 2.0
    root_edges = []
    for edge in model.edges("|X").vals():
        center = edge.Center()
        at_root_y = abs(abs(center.y) - outer_edge) < 0.05
        at_ear_x = any(abs(center.x - x) < 0.05 for x in EAR_X_CENTERS)
        at_ear_top = abs(center.z - EAR_THICKNESS) < 0.05
        if at_root_y and at_ear_x and at_ear_top:
            root_edges.append(edge)
    if len(root_edges) != 4:
        raise RuntimeError(f"expected 4 mounting-ear top-root edges, found {len(root_edges)}")
    model = model.newObject(root_edges).fillet(EAR_TOP_ROOT_FILLET)

    # Cut both left and right mounting slots with each through-cutter.
    psu_bottom = WALL + FIT_CLEARANCE / 2.0
    side_hole_x = FRONT_RECESS + SIDE_HOLE_X_FROM_FACE
    for top_offset in SIDE_HOLE_TOP_OFFSETS:
        z_center = psu_bottom + CHASSIS_HEIGHT - top_offset
        model = model.cut(side_slot_cutter(side_hole_x, z_center, outer_width))

    return model.clean()


def build_fit_gauge() -> cq.Workplane:
    inner_width = CHASSIS_WIDTH + FIT_CLEARANCE
    inner_height = CHASSIS_HEIGHT + FIT_CLEARANCE
    return rectangular_tube(GAUGE_LENGTH, inner_width, inner_height).clean()


def print_oriented(model: cq.Workplane) -> cq.Workplane:
    """Put the large front opening on the print bed to avoid roof bridging."""
    oriented = model.rotate((0, 0, 0), (0, 1, 0), -90.0)
    bounds = oriented.val().BoundingBox()
    return oriented.translate((-bounds.xmin, -bounds.ymin, -bounds.zmin))


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
    exporters.export(
        model,
        str(OUT / f"{stem}.step"),
        exportType="STEP",
    )
    exporters.export(
        model,
        str(OUT / f"{stem}.stl"),
        exportType="STL",
        tolerance=0.05,
        angularTolerance=0.10,
    )


def export_svg(model: cq.Workplane) -> None:
    exporters.export(
        model,
        str(OUT / "bosytro-480w-tunnel-preview.svg"),
        exportType="SVG",
        opt={
            "width": 1200,
            "height": 900,
            "marginLeft": 25,
            "marginTop": 25,
            "projectionDir": (-1.0, -1.0, 0.65),
            "showAxes": False,
            "showHidden": False,
            "strokeWidth": 0.7,
        },
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    tunnel = build_tunnel()
    gauge = build_fit_gauge()
    tunnel_print = print_oriented(tunnel)
    gauge_print = print_oriented(gauge)

    validate("tunnel", tunnel)
    validate("print-oriented tunnel", tunnel_print)
    validate("fit gauge", gauge)

    export_model(tunnel, "bosytro-480w-tunnel-assembly")
    export_model(tunnel_print, "bosytro-480w-tunnel-print-orientation")
    export_model(gauge_print, "bosytro-480w-fit-gauge")
    export_svg(tunnel)

    print(f"Generated CadQuery files in {OUT}")


if __name__ == "__main__":
    main()
