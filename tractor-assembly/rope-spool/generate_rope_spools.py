#!/usr/bin/env python3
"""Parametric rope spools for a 32 mm, four-hole 8 mm shaft flange.

The models are intentionally generated from measured dimensions rather than an
imported mesh.  All dimensions are millimetres.  Run with a Python environment
that contains CadQuery 2.4 or newer.
"""

from __future__ import annotations

import math
from pathlib import Path

import cadquery as cq
from cadquery import exporters
import trimesh


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"

# Measured metal coupling interface.  The two independent measurements imply
# a 23.92--24.17 mm bolt circle, so a 24.05 mm centre value and generous M4
# clearance cover the observed part without making the spool visibly sloppy.
METAL_FLANGE_DIAMETER = 31.97
PILOT_RECESS_DIAMETER = 32.30
PILOT_RECESS_DEPTH = 1.20
BOLT_CIRCLE_DIAMETER = 24.05
M4_CLEARANCE_DIAMETER = 4.60

# A 7.55 mm across-flats pocket captures a normal 7 mm M4 nut with enough FDM
# clearance to insert it by hand.  Screws enter from the metal-flange/hub side.
M4_POCKET_ACROSS_FLATS = 7.55
M4_POCKET_CORNER_DIAMETER = M4_POCKET_ACROSS_FLATS / math.cos(math.radians(30.0))
M4_POCKET_DEPTH = 3.50

# The user's best D-shaft fit was an 8.13 mm circle with the flat 3.185 mm from
# centre.  Add 0.12 mm per side for a non-binding printed passage.
D_BORE_DIAMETER = 8.37
D_FLAT_FROM_CENTRE = 3.305

REAR_FLANGE_THICKNESS = 4.50
FRONT_FLANGE_THICKNESS = 4.50
ROPE_DIAMETER = 5.0
ROPE_ANCHOR_DIAMETER = 6.20
ROPE_ANCHOR_RADIUS = 20.50
ROPE_ANCHOR_ANGLE_DEG = 45.0
ROPE_KNOT_RECESS_DIAMETER = 12.0
ROPE_KNOT_RECESS_DEPTH = 2.30

def cylinder(radius: float, height: float, z0: float = 0.0) -> cq.Workplane:
    """Return a Z-axis cylinder as a Workplane."""
    return cq.Workplane(
        obj=cq.Solid.makeCylinder(
            radius,
            height,
            cq.Vector(0.0, 0.0, z0),
            cq.Vector(0.0, 0.0, 1.0),
        )
    )


def cone(radius1: float, radius2: float, height: float, z0: float) -> cq.Workplane:
    """Return a Z-axis conical frustum as a Workplane."""
    return cq.Workplane(
        obj=cq.Solid.makeCone(
            radius1,
            radius2,
            height,
            cq.Vector(0.0, 0.0, z0),
            cq.Vector(0.0, 0.0, 1.0),
        )
    )


def d_bore(total_height: float) -> cq.Workplane:
    """Create the user's D profile with its flat toward +X."""
    radius = D_BORE_DIAMETER / 2.0
    round_bore = cylinder(radius, total_height + 2.0, -1.0)
    width = radius + D_FLAT_FROM_CENTRE
    clipping_box = (
        cq.Workplane("XY")
        .box(width, D_BORE_DIAMETER + 2.0, total_height + 2.0)
        .translate(((D_FLAT_FROM_CENTRE - radius) / 2.0, 0.0, total_height / 2.0))
    )
    return round_bore.intersect(clipping_box)


def hex_prism(corner_diameter: float, height: float, x: float, y: float, z0: float) -> cq.Workplane:
    """Create a flat-topped hexagonal pocket tool."""
    return (
        cq.Workplane("XY", origin=(x, y, z0))
        .polygon(6, corner_diameter)
        .extrude(height)
    )


def radial_hex_prism(
    corner_diameter: float,
    height: float,
    radius: float,
    angle_deg: float,
    z0: float,
) -> cq.Workplane:
    """Hex prism with flats facing radially inward and outward."""
    pocket = (
        cq.Workplane("XY")
        .polygon(6, corner_diameter)
        .extrude(height)
        .rotate((0.0, 0.0, 0.0), (0.0, 0.0, 1.0), angle_deg + 30.0)
    )
    angle = math.radians(angle_deg)
    return pocket.translate((radius * math.cos(angle), radius * math.sin(angle), z0))


def radial_box(
    radial_min: float,
    radial_max: float,
    tangential_width: float,
    height: float,
    angle_deg: float,
    z0: float,
) -> cq.Workplane:
    """Box extending radially outward at the requested polar angle."""
    length = radial_max - radial_min
    box = (
        cq.Workplane("XY")
        .box(length, tangential_width, height)
        .translate(((radial_min + radial_max) / 2.0, 0.0, z0 + height / 2.0))
    )
    return box.rotate((0.0, 0.0, 0.0), (0.0, 0.0, 1.0), angle_deg)


def cut_common_interface(model: cq.Workplane, total_height: float) -> cq.Workplane:
    """Cut the flange pilot, D passage, and four M4 bolt/nut paths."""
    # The shallow recess is a close printed pilot over the 31.97 mm metal rim.
    model = model.cut(cylinder(PILOT_RECESS_DIAMETER / 2.0, PILOT_RECESS_DEPTH + 0.02, -0.01))
    model = model.cut(d_bore(total_height))

    bolt_radius = BOLT_CIRCLE_DIAMETER / 2.0
    pocket_z = total_height - M4_POCKET_DEPTH
    for angle_deg in (0.0, 90.0, 180.0, 270.0):
        angle = math.radians(angle_deg)
        x = bolt_radius * math.cos(angle)
        y = bolt_radius * math.sin(angle)
        hole = (
            cq.Workplane(
                obj=cq.Solid.makeCylinder(
                    M4_CLEARANCE_DIAMETER / 2.0,
                    total_height + 2.0,
                    cq.Vector(x, y, -1.0),
                    cq.Vector(0.0, 0.0, 1.0),
                )
            )
        )
        model = model.cut(hole)
        model = model.cut(
            hex_prism(
                M4_POCKET_CORNER_DIAMETER,
                M4_POCKET_DEPTH + 0.02,
                x,
                y,
                pocket_z,
            )
        )

    return model


def cut_rope_anchor(model: cq.Workplane, total_height: float) -> cq.Workplane:
    """Add a radiused axial becket hole and outer-face stopper-knot recess."""
    angle = math.radians(ROPE_ANCHOR_ANGLE_DEG)
    x = ROPE_ANCHOR_RADIUS * math.cos(angle)
    y = ROPE_ANCHOR_RADIUS * math.sin(angle)
    anchor_z = total_height - FRONT_FLANGE_THICKNESS - 1.0
    anchor_hole = cq.Workplane(
        obj=cq.Solid.makeCylinder(
            ROPE_ANCHOR_DIAMETER / 2.0,
            FRONT_FLANGE_THICKNESS + 1.02,
            cq.Vector(x, y, anchor_z),
            cq.Vector(0.0, 0.0, 1.0),
        )
    )
    # A generous bellmouth on the drum side removes the sharp printed edge
    # that would otherwise saw into loaded rope as it bends through the cheek.
    entry_bellmouth = cq.Workplane(
        obj=cq.Solid.makeCone(
            4.20,
            ROPE_ANCHOR_DIAMETER / 2.0,
            1.20,
            cq.Vector(x, y, anchor_z),
            cq.Vector(0.0, 0.0, 1.0),
        )
    )
    knot_recess = cq.Workplane(
        obj=cq.Solid.makeCylinder(
            ROPE_KNOT_RECESS_DIAMETER / 2.0,
            ROPE_KNOT_RECESS_DEPTH + 0.02,
            cq.Vector(x, y, total_height - ROPE_KNOT_RECESS_DEPTH),
            cq.Vector(0.0, 0.0, 1.0),
        )
    )
    return model.cut(anchor_hole).cut(entry_bellmouth).cut(knot_recess)


def finish_spool(model: cq.Workplane, total_height: float) -> cq.Workplane:
    return cut_rope_anchor(cut_common_interface(model, total_height), total_height).clean()


def cut_short_screw_interface(
    model: cq.Workplane,
    total_height: float,
    rear_flange_thickness: float,
    barrel_radius: float,
) -> cq.Workplane:
    """Interface for M4x12 screws and radially side-loaded M4 nuts."""
    model = model.cut(cylinder(PILOT_RECESS_DIAMETER / 2.0, PILOT_RECESS_DEPTH + 0.02, -0.01))
    model = model.cut(d_bore(total_height))

    bolt_radius = BOLT_CIRCLE_DIAMETER / 2.0
    nut_height = 3.50
    for angle_deg in (0.0, 90.0, 180.0, 270.0):
        angle = math.radians(angle_deg)
        x = bolt_radius * math.cos(angle)
        y = bolt_radius * math.sin(angle)

        # The axial hole stops shortly after the nut instead of weakening the
        # entire drum with a full-length fastener tunnel.
        axial_hole = cq.Workplane(
            obj=cq.Solid.makeCylinder(
                M4_CLEARANCE_DIAMETER / 2.0,
                rear_flange_thickness + nut_height + 2.0,
                cq.Vector(x, y, -1.0),
                cq.Vector(0.0, 0.0, 1.0),
            )
        )
        nut_socket = radial_hex_prism(
            M4_POCKET_CORNER_DIAMETER,
            nut_height,
            bolt_radius,
            angle_deg,
            rear_flange_thickness,
        )
        # A narrow radial loading window admits a 7 mm M4 nut.  Its floor is
        # flush with the front face of the rear cheek, and the ungrooved collar
        # keeps rope away from these windows.
        loading_window = radial_box(
            bolt_radius,
            barrel_radius + 1.0,
            7.30,
            nut_height,
            angle_deg,
            rear_flange_thickness,
        )
        model = model.cut(axial_hole).cut(nut_socket).cut(loading_window)
    return model


def helical_level_lay_spool_m4x12() -> cq.Workplane:
    """Six-wrap level-lay spool using side-loaded nuts and M4x12 screws."""
    flange_radius = 27.0
    barrel_radius = 17.0
    rear_flange_thickness = 5.0
    barrel_width = 46.5
    total_height = rear_flange_thickness + barrel_width + FRONT_FLANGE_THICKNESS

    rear = cylinder(flange_radius, rear_flange_thickness)
    barrel = cylinder(barrel_radius, barrel_width, rear_flange_thickness)
    front = cylinder(flange_radius, FRONT_FLANGE_THICKNESS, rear_flange_thickness + barrel_width)
    model = rear.union(barrel).union(front)

    pitch = 5.50
    turns = 6.0
    helix_height = pitch * turns
    cutter_radius = 2.70
    cutter_path_radius = 18.30
    # The first groove edge starts 2 mm beyond the 3.5 mm-tall nut windows.
    helix_z0 = rear_flange_thickness + 3.50 + cutter_radius + 2.0
    path = cq.Wire.makeHelix(pitch, helix_height, cutter_path_radius)
    cutter = (
        cq.Workplane("XZ")
        .center(cutter_path_radius, 0.0)
        .circle(cutter_radius)
        .sweep(path, isFrenet=True)
        .rotate((0.0, 0.0, 0.0), (0.0, 0.0, 1.0), ROPE_ANCHOR_ANGLE_DEG)
        .translate((0.0, 0.0, helix_z0))
    )
    model = model.cut(cutter)
    model = cut_short_screw_interface(
        model,
        total_height,
        rear_flange_thickness,
        barrel_radius,
    )
    return cut_rope_anchor(model, total_height).clean()


def helical_level_lay_spool() -> cq.Workplane:
    """Wide single-layer spool with a shallow 7-turn rope guide."""
    flange_radius = 27.0
    barrel_radius = 17.0
    barrel_width = 44.0
    total_height = REAR_FLANGE_THICKNESS + barrel_width + FRONT_FLANGE_THICKNESS

    rear = cylinder(flange_radius, REAR_FLANGE_THICKNESS)
    barrel = cylinder(barrel_radius, barrel_width, REAR_FLANGE_THICKNESS)
    front = cylinder(flange_radius, FRONT_FLANGE_THICKNESS, REAR_FLANGE_THICKNESS + barrel_width)
    model = rear.union(barrel).union(front)

    # A 5.5 mm pitch gives a small allowance around nominal 5 mm rope.  The
    # cutter is only 1.4 mm deep, preserving material around the axial M4 paths.
    pitch = 5.50
    turns = 7.0
    helix_height = pitch * turns
    cutter_radius = 2.70
    cutter_path_radius = 18.30
    helix_z0 = REAR_FLANGE_THICKNESS + cutter_radius
    path = cq.Wire.makeHelix(pitch, helix_height, cutter_path_radius)
    cutter = (
        cq.Workplane("XZ")
        .center(cutter_path_radius, 0.0)
        .circle(cutter_radius)
        .sweep(path, isFrenet=True)
        # Rotate the completed sweep, not just its path.  Rotating only the
        # path makes OpenCascade bridge the unrotated profile to the path with
        # an unwanted straight cutter segment.
        .rotate((0.0, 0.0, 0.0), (0.0, 0.0, 1.0), ROPE_ANCHOR_ANGLE_DEG)
        .translate((0.0, 0.0, helix_z0))
    )
    model = model.cut(cutter)
    return finish_spool(model, total_height)


def hourglass_self_centering_spool() -> cq.Workplane:
    """Smooth, forgiving drum whose shallow waist encourages centred winding."""
    flange_radius = 27.0
    barrel_width = 20.0
    half_width = barrel_width / 2.0
    total_height = REAR_FLANGE_THICKNESS + barrel_width + FRONT_FLANGE_THICKNESS

    rear = cylinder(flange_radius, REAR_FLANGE_THICKNESS)
    first_half = cone(18.0, 16.0, half_width, REAR_FLANGE_THICKNESS)
    second_half = cone(16.0, 18.0, half_width, REAR_FLANGE_THICKNESS + half_width)
    front = cylinder(flange_radius, FRONT_FLANGE_THICKNESS, REAR_FLANGE_THICKNESS + barrel_width)
    model = rear.union(first_half).union(second_half).union(front)
    return finish_spool(model, total_height)


def compact_stack_spool() -> cq.Workplane:
    """Narrow spool that forces the rope to build in one compact radial stack."""
    flange_radius = 30.0
    barrel_radius = 15.5
    barrel_width = 8.0
    total_height = REAR_FLANGE_THICKNESS + barrel_width + FRONT_FLANGE_THICKNESS

    rear = cylinder(flange_radius, REAR_FLANGE_THICKNESS)
    barrel = cylinder(barrel_radius, barrel_width, REAR_FLANGE_THICKNESS)
    front = cylinder(flange_radius, FRONT_FLANGE_THICKNESS, REAR_FLANGE_THICKNESS + barrel_width)
    model = rear.union(barrel).union(front)
    return finish_spool(model, total_height)


def flange_fit_gauge() -> cq.Workplane:
    """A fast, low-material check of the measured coupling interface."""
    diameter = 38.0
    height = 3.0
    model = cylinder(diameter / 2.0, height)
    model = model.cut(cylinder(PILOT_RECESS_DIAMETER / 2.0, PILOT_RECESS_DEPTH + 0.02, -0.01))
    model = model.cut(d_bore(height))

    bolt_radius = BOLT_CIRCLE_DIAMETER / 2.0
    for angle_deg in (0.0, 90.0, 180.0, 270.0):
        angle = math.radians(angle_deg)
        x = bolt_radius * math.cos(angle)
        y = bolt_radius * math.sin(angle)
        hole = cq.Workplane(
            obj=cq.Solid.makeCylinder(
                M4_CLEARANCE_DIAMETER / 2.0,
                height + 2.0,
                cq.Vector(x, y, -1.0),
                cq.Vector(0.0, 0.0, 1.0),
            )
        )
        model = model.cut(hole)
    return model.clean()


def validate(label: str, model: cq.Workplane) -> None:
    solids = model.solids().vals()
    if len(solids) != 1:
        raise RuntimeError(f"{label}: expected one solid, found {len(solids)}")
    solid = solids[0]
    if not solid.isValid():
        raise RuntimeError(f"{label}: OpenCascade reports an invalid solid")
    bounds = solid.BoundingBox()
    print(
        f"{label}: valid solid; "
        f"size={bounds.xlen:.2f} x {bounds.ylen:.2f} x {bounds.zlen:.2f} mm; "
        f"volume={solid.Volume():.1f} mm^3"
    )


def export_model(stem: str, model: cq.Workplane) -> None:
    exporters.export(model, str(OUT / f"{stem}.step"), exportType="STEP")
    exporters.export(
        model,
        str(OUT / f"{stem}.stl"),
        exportType="STL",
        tolerance=0.025,
        angularTolerance=0.08,
    )
    exporters.export(
        model,
        str(OUT / f"{stem}.svg"),
        exportType="SVG",
        opt={
            "width": 900,
            "height": 700,
            "marginLeft": 30,
            "marginTop": 30,
            "projectionDir": (1.0, -1.0, 0.75),
            "showAxes": False,
            "showHidden": False,
            "strokeWidth": 0.025,
        },
    )

    mesh = trimesh.load_mesh(OUT / f"{stem}.stl", process=True)
    if not isinstance(mesh, trimesh.Trimesh):
        raise RuntimeError(f"{stem}: STL did not reload as one triangle mesh")
    if not mesh.is_watertight or not mesh.is_winding_consistent:
        raise RuntimeError(f"{stem}: STL failed watertight/manifold validation")
    print(
        f"{stem}: STL triangles={len(mesh.faces):,}; "
        f"watertight={mesh.is_watertight}; winding={mesh.is_winding_consistent}"
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    models = {
        "helical-level-lay-spool-m4x12": helical_level_lay_spool_m4x12(),
        "helical-level-lay-spool": helical_level_lay_spool(),
        "hourglass-self-centering-spool": hourglass_self_centering_spool(),
        "compact-stack-spool": compact_stack_spool(),
        "flange-fit-gauge": flange_fit_gauge(),
    }
    for stem, model in models.items():
        validate(stem, model)
        export_model(stem, model)
    print(f"Generated STEP, STL, and SVG files in {OUT}")


if __name__ == "__main__":
    main()
