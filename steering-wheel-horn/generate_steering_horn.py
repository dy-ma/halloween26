#!/usr/bin/env python3
"""Parametric retrofit horn module for the supplied 270 mm steering wheel.

The source wheel is a triangulated STL, so the revised lower wheel remains a
mesh.  All new horn/electronics parts are generated as editable CadQuery
solids and exported as both STEP and STL.

Coordinate convention for the assembly:
    Z = 0       mating plane between the original upper and lower wheel halves
    +Z          rearward, into the electronics pod
    -Z          forward, toward the translucent horn face

All dimensions are millimetres.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path

import cadquery as cq
from cadquery import exporters
import numpy as np
import trimesh


ROOT = Path(__file__).resolve().parent
DEFAULT_LOWER = Path("/Users/dylanang/Downloads/prints/STERZO SOTTA.stl")

# Dimensions measured from the supplied meshes.
ORIGINAL_HORN_OPENING = 67.16
ORIGINAL_HORN_BODY = 65.78
ORIGINAL_HORN_FLANGE = 83.58

# Sliding horn button.  The radial clearance is deliberately close to the
# supplied horn's proven fit while leaving a little more room for PETG.
BUTTON_OD = 65.60
BUTTON_ID = 60.80
BUTTON_VISIBLE_HEIGHT = 39.00
BUTTON_FACE = 2.40
BUTTON_FLANGE_OD = 83.00
BUTTON_FLANGE_THICKNESS = 2.40
BUTTON_GLUE_PLUG_OD = 60.20
BUTTON_GLUE_PLUG_ID = 52.00
BUTTON_GLUE_PLUG_DEPTH = 4.20
BUTTON_TRAVEL = 3.00

# Revised straight-wall rear pod.
POD_OD = 98.00
POD_ID = 87.00
POD_FRONT_Z = 8.00
POD_REAR_Z = 48.00
DECK_FRONT_Z = 9.00
DECK_THICKNESS = 3.20

# Three small compression springs.  Recommended starting point is 6-7 mm OD,
# approximately 7 mm free length, around these 3.2 mm pilot posts.
SPRING_POST_DIAMETER = 3.20
SPRING_POST_RADIUS = 37.00
SPRING_ANGLES = (90.0, 210.0, 330.0)

# Moving hollow skirt and the fixed wall-mounted switch tower.  At rest the
# chamfered rear edge of the skirt is just ahead of the switch lever.  A press
# moves the edge 3 mm past the lever, matching the arrangement in IMG_4829.
SKIRT_OD = 50.00
SKIRT_ID = 45.00
SKIRT_LENGTH = 11.00
SKIRT_BASE_OD = 58.00
SKIRT_BASE_THICKNESS = 2.00
DECK_SLIDE_BORE = 53.00

# User's miniature limit-switch pattern from the photo and prior mounts.
SWITCH_HOLE_SPACING = 9.00
SWITCH_SLOT_WIDTH = 2.40
SWITCH_SLOT_LENGTH = 6.00
SWITCH_TOWER_INNER_X = 26.50
SWITCH_TOWER_OUTER_X = 44.00
SWITCH_TOWER_WIDTH = 24.00
SWITCH_TOWER_Z0 = 8.00
SWITCH_TOWER_Z1 = 26.00
SWITCH_POCKET = (8.50, 21.00, 11.00)  # radial X, tangential Y, axial Z
SWITCH_POCKET_Z = 18.50
SWITCH_SLOT_Z = 18.50

LED_RADIUS = 29.00
LED_ANGLES = (30.0, 150.0, 270.0)

# Known battery envelope from the existing case designs.
BATTERY = (67.00, 36.00, 10.00)
BATTERY_CAVITY = (68.50, 37.50, 11.50)

# Conservative universal shelf for a XIAO expansion-board-sized controller.
BOARD_ENVELOPE = (58.00, 42.00, 12.00)
BOARD_SHELF = (70.00, 44.00, 2.40)
BOARD_POST_X = 32.50
BOARD_POST_Y = 19.50

# Four rear-cover fasteners sit in the otherwise unused diagonal corners.
COVER_SCREW_RADIUS = 40.50
COVER_SCREW_ANGLES = (45.0, 135.0, 225.0, 315.0)


def box(size: tuple[float, float, float], center: tuple[float, float, float]) -> cq.Workplane:
    return cq.Workplane("XY").box(*size).translate(center)


def cylinder(radius: float, z0: float, z1: float, x: float = 0.0, y: float = 0.0) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        z1 - z0,
        cq.Vector(x, y, z0),
        cq.Vector(0, 0, 1),
    )
    return cq.Workplane(obj=solid)


def cylinder_x(radius: float, x0: float, x1: float, y: float, z: float) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        x1 - x0,
        cq.Vector(x0, y, z),
        cq.Vector(1, 0, 0),
    )
    return cq.Workplane(obj=solid)


def rounded_rect(
    width: float,
    depth: float,
    height: float,
    radius: float,
    z0: float = 0.0,
) -> cq.Workplane:
    """Centered rounded rectangle extruded along +Z."""
    result = box((width - 2 * radius, depth, height), (0, 0, z0 + height / 2))
    result = result.union(box((width, depth - 2 * radius, height), (0, 0, z0 + height / 2)))
    for x in (-width / 2 + radius, width / 2 - radius):
        for y in (-depth / 2 + radius, depth / 2 - radius):
            result = result.union(cylinder(radius, z0, z0 + height, x, y))
    return result


def slot_x(length: float, width: float, z0: float, z1: float, x: float, y: float) -> cq.Workplane:
    """Capsule slot whose long axis is X."""
    straight = length - width
    result = box((straight, width, z1 - z0), (x, y, (z0 + z1) / 2))
    for end_x in (x - straight / 2, x + straight / 2):
        result = result.union(cylinder(width / 2, z0, z1, end_x, y))
    return result


def slot_z_through_x(
    length: float,
    width: float,
    x0: float,
    x1: float,
    y: float,
    z: float,
) -> cq.Workplane:
    """Vertical capsule slot in a YZ wall, extruded along X."""
    straight = length - width
    result = box((x1 - x0, width, straight), ((x0 + x1) / 2, y, z))
    for end_z in (z - straight / 2, z + straight / 2):
        result = result.union(cylinder_x(width / 2, x0, x1, y, end_z))
    return result


def build_horn_cap() -> cq.Workplane:
    """Hollow translucent cap matching the supplied horn's rounded profile.

    The source horn is cylindrical for about 23 mm, then closes as a shallow
    spherical cap: R32.9 at the shoulder and approximately R42 curvature.
    """
    sphere_center_z = 3.0
    sphere_radius = 42.0
    outer_r = BUTTON_OD / 2
    outer_shoulder_z = sphere_center_z - math.sqrt(sphere_radius**2 - outer_r**2)
    outer_tip_z = sphere_center_z - sphere_radius

    inner_sphere_radius = sphere_radius - BUTTON_FACE
    inner_r = BUTTON_ID / 2
    inner_shoulder_z = sphere_center_z - math.sqrt(inner_sphere_radius**2 - inner_r**2)
    inner_tip_z = sphere_center_z - inner_sphere_radius

    # Revolving one closed radial section avoids coincident Boolean seams and
    # produces a genuinely hollow, watertight dome.
    outer_zs = np.linspace(outer_shoulder_z, outer_tip_z, 28)
    inner_zs = np.linspace(inner_tip_z, inner_shoulder_z, 28)
    profile: list[tuple[float, float]] = [(outer_r, 0.0), (outer_r, outer_shoulder_z)]
    profile.extend(
        (
            math.sqrt(max(0.0, sphere_radius**2 - (float(z) - sphere_center_z) ** 2)),
            float(z),
        )
        for z in outer_zs[1:]
    )
    profile.append((0.0, inner_tip_z))
    profile.extend(
        (
            math.sqrt(max(0.0, inner_sphere_radius**2 - (float(z) - sphere_center_z) ** 2)),
            float(z),
        )
        for z in inner_zs[1:]
    )
    profile.extend(((inner_r, 0.0), (outer_r, 0.0)))
    return cq.Workplane("XZ").polyline(profile).close().revolve(360, (0, 0), (0, 1)).clean()


def build_button_retainer() -> cq.Workplane:
    """Glue-in annular plug plus the hidden retaining/spring flange."""
    plug = cylinder(BUTTON_GLUE_PLUG_OD / 2, -BUTTON_GLUE_PLUG_DEPTH, 0).cut(
        cylinder(BUTTON_GLUE_PLUG_ID / 2, -BUTTON_GLUE_PLUG_DEPTH - 0.5, 0.5)
    )
    flange = cylinder(BUTTON_FLANGE_OD / 2, 0, BUTTON_FLANGE_THICKNESS).cut(
        cylinder(BUTTON_GLUE_PLUG_ID / 2, -0.5, BUTTON_FLANGE_THICKNESS + 0.5)
    )
    return plug.union(flange).clean()


def build_sliding_skirt() -> cq.Workplane:
    """Moving hollow tube whose chamfered edge passes the wall switch lever."""
    base = cylinder(SKIRT_BASE_OD / 2, 0, SKIRT_BASE_THICKNESS).cut(
        cylinder(SKIRT_ID / 2, -0.5, SKIRT_BASE_THICKNESS + 0.5)
    )
    tube = cylinder(SKIRT_OD / 2, 0, SKIRT_LENGTH).cut(
        cylinder(SKIRT_ID / 2, -0.5, SKIRT_LENGTH + 0.5)
    )
    try:
        tube = tube.edges(">Z").chamfer(1.0)
    except Exception:
        pass
    return base.union(tube).clean()


def build_center_pod_reference() -> cq.Workplane:
    """Editable reference solid matching the pod integrated into the mesh."""
    wall = cylinder(POD_OD / 2, POD_FRONT_Z, POD_REAR_Z).cut(
        cylinder(POD_ID / 2, POD_FRONT_Z - 0.5, POD_REAR_Z + 0.5)
    )
    deck = cylinder(POD_ID / 2, DECK_FRONT_Z, DECK_FRONT_Z + DECK_THICKNESS).cut(
        cylinder(DECK_SLIDE_BORE / 2, DECK_FRONT_Z - 0.5, DECK_FRONT_Z + DECK_THICKNESS + 0.5)
    )

    tower = box(
        (
            SWITCH_TOWER_OUTER_X - SWITCH_TOWER_INNER_X,
            SWITCH_TOWER_WIDTH,
            SWITCH_TOWER_Z1 - SWITCH_TOWER_Z0,
        ),
        (
            (SWITCH_TOWER_INNER_X + SWITCH_TOWER_OUTER_X) / 2,
            0,
            (SWITCH_TOWER_Z0 + SWITCH_TOWER_Z1) / 2,
        ),
    )

    # Heat-set-insert bosses for the rear cover.
    bosses = None
    for angle in COVER_SCREW_ANGLES:
        a = math.radians(angle)
        boss = cylinder(
            5.0,
            POD_REAR_Z - 12.0,
            POD_REAR_Z,
            COVER_SCREW_RADIUS * math.cos(a),
            COVER_SCREW_RADIUS * math.sin(a),
        )
        bosses = boss if bosses is None else bosses.union(boss)

    model = wall.union(deck).union(tower).union(bosses)

    # Spring pilots project toward the button.
    for angle in SPRING_ANGLES:
        a = math.radians(angle)
        model = model.union(
            cylinder(
                SPRING_POST_DIAMETER / 2,
                DECK_FRONT_Z - 3.0,
                DECK_FRONT_Z + 0.2,
                SPRING_POST_RADIUS * math.cos(a),
                SPRING_POST_RADIUS * math.sin(a),
            )
        )

    cutters: list[cq.Workplane] = []

    # Pocket opens toward the moving skirt. The M2 mounting slots run
    # vertically so the exact click point can be tuned after test assembly.
    pocket_x, pocket_y, pocket_z = SWITCH_POCKET
    cutters.append(
        box(
            (pocket_x, pocket_y, pocket_z),
            (SWITCH_TOWER_INNER_X + pocket_x / 2 - 0.25, 0, SWITCH_POCKET_Z),
        )
    )
    for y in (-SWITCH_HOLE_SPACING / 2, SWITCH_HOLE_SPACING / 2):
        cutters.append(
            slot_z_through_x(
                SWITCH_SLOT_LENGTH,
                SWITCH_SLOT_WIDTH,
                SWITCH_TOWER_INNER_X + pocket_x - 0.5,
                POD_OD / 2 + 0.5,
                y,
                SWITCH_SLOT_Z,
            )
        )

    # Three 5 mm LEDs surround the moving hollow skirt.
    for angle in LED_ANGLES:
        a = math.radians(angle)
        cutters.append(
            cylinder(
                2.65,
                DECK_FRONT_Z - 0.5,
                DECK_FRONT_Z + DECK_THICKNESS + 0.5,
                LED_RADIUS * math.cos(a),
                LED_RADIUS * math.sin(a),
            )
        )

    # Rear insert pilots.
    for angle in COVER_SCREW_ANGLES:
        a = math.radians(angle)
        cutters.append(
            cylinder(
                2.05,
                POD_REAR_Z - 6.5,
                POD_REAR_Z + 0.5,
                COVER_SCREW_RADIUS * math.cos(a),
                COVER_SCREW_RADIUS * math.sin(a),
            )
        )

    # USB/service window moves to the opposite wall, away from the switch.
    cutters.append(box((10.0, 18.0, 11.0), (-POD_OD / 2, 0, 23.0)))
    for cutter in cutters:
        model = model.cut(cutter)
    return model.clean()


def build_rear_cover() -> cq.Workplane:
    """Rear cover with a strapped 67 x 36 x 10 mm battery pocket."""
    cover = cylinder(POD_OD / 2, 0, 3.0)

    cavity_x, cavity_y, cavity_z = BATTERY_CAVITY
    wall = 2.40
    outer_x = cavity_x + 2 * wall
    outer_y = cavity_y + 2 * wall
    pocket = rounded_rect(outer_x, outer_y, cavity_z + 1.0, 3.0, 3.0)
    pocket = pocket.cut(rounded_rect(cavity_x, cavity_y, cavity_z + 1.5, 1.6, 5.4))
    cover = cover.union(pocket)

    # Locating lip inside the pod.
    lip = cylinder(POD_ID / 2 - 0.30, 3.0, 5.0).cut(cylinder(POD_ID / 2 - 2.20, 2.5, 5.5))
    cover = cover.union(lip)

    # Four board-shelf supports rise above the battery.
    for x in (-BOARD_POST_X, BOARD_POST_X):
        for y in (-BOARD_POST_Y, BOARD_POST_Y):
            cover = cover.union(cylinder(3.8, 3.0, 18.0, x, y))

    cutters: list[cq.Workplane] = []
    # Velcro slots: a 12-13 mm strap loops under the cover and over the cell.
    for y in (-14.0, 14.0):
        cutters.append(slot_x(14.0, 3.0, -0.5, 4.0, 0.0, y))

    # Cover screws and board-shelf pilots.
    for angle in COVER_SCREW_ANGLES:
        a = math.radians(angle)
        cutters.append(
            cylinder(
                1.75,
                -0.5,
                3.5,
                COVER_SCREW_RADIUS * math.cos(a),
                COVER_SCREW_RADIUS * math.sin(a),
            )
        )
    for x in (-BOARD_POST_X, BOARD_POST_X):
        for y in (-BOARD_POST_Y, BOARD_POST_Y):
            cutters.append(cylinder(1.25, 12.0, 18.5, x, y))

    for cutter in cutters:
        cover = cover.cut(cutter)
    return cover.clean()


def build_board_shelf() -> cq.Workplane:
    width, depth, thickness = BOARD_SHELF
    shelf = rounded_rect(width, depth, thickness, 4.0)
    cutters: list[cq.Workplane] = []
    for x in (-BOARD_POST_X, BOARD_POST_X):
        for y in (-BOARD_POST_Y, BOARD_POST_Y):
            cutters.append(cylinder(1.75, -0.5, thickness + 0.5, x, y))

    # Two zip ties can capture many boards without committing to one hole map.
    for x in (-21.0, 21.0):
        for y in (-18.0, 18.0):
            cutters.append(slot_x(7.0, 2.40, -0.5, thickness + 0.5, x, y))
    cutters.append(slot_x(14.0, 6.0, -0.5, thickness + 0.5, 0.0, 0.0))
    for cutter in cutters:
        shelf = shelf.cut(cutter)
    return shelf.clean()


def build_switch_shim(thickness: float) -> cq.Workplane:
    shim = rounded_rect(18.0, 10.0, thickness, 2.0)
    for y in (-SWITCH_HOLE_SPACING / 2, SWITCH_HOLE_SPACING / 2):
        shim = shim.cut(cylinder(1.25, -0.5, thickness + 0.5, 0.0, y))
    return shim.clean()


def build_fit_gauge() -> cq.Workplane:
    """Fast print to test the existing front opening before printing the cap."""
    body = cylinder(BUTTON_OD / 2, 0, 6.0)
    flange = cylinder(BUTTON_FLANGE_OD / 2, 6.0, 7.6)
    finger_hole = cylinder(24.0, -0.5, 8.1)
    return body.union(flange).cut(finger_hole).clean()


def export_solid(shape: cq.Workplane, out: Path, stem: str) -> tuple[Path, Path]:
    stl = out / f"{stem}.stl"
    step = out / f"{stem}.step"
    exporters.export(shape, str(stl), tolerance=0.08, angularTolerance=0.15)
    exporters.export(shape, str(step))
    # OCC emits zero-area pole triangles where a revolved spherical surface
    # meets its axis. Removing only those degenerate facets leaves the exact
    # solid unchanged and gives slicers a strictly manifold STL.
    mesh = trimesh.load_mesh(stl, process=True)
    mesh.update_faces(mesh.nondegenerate_faces())
    mesh.remove_unreferenced_vertices()
    mesh.merge_vertices()
    mesh.fix_normals()
    mesh.export(stl)
    return stl, step


def mesh_cylinder(radius: float, z0: float, z1: float, x: float = 0.0, y: float = 0.0, sections: int = 128) -> trimesh.Trimesh:
    mesh = trimesh.creation.cylinder(radius=radius, height=z1 - z0, sections=sections)
    mesh.apply_translation((x, y, (z0 + z1) / 2))
    return mesh


def mesh_cylinder_x(radius: float, x0: float, x1: float, y: float, z: float, sections: int = 64) -> trimesh.Trimesh:
    mesh = trimesh.creation.cylinder(radius=radius, height=x1 - x0, sections=sections)
    mesh.apply_transform(trimesh.transformations.rotation_matrix(math.pi / 2, (0, 1, 0)))
    mesh.apply_translation(((x0 + x1) / 2, y, z))
    return mesh


def mesh_box(size: tuple[float, float, float], center: tuple[float, float, float]) -> trimesh.Trimesh:
    mesh = trimesh.creation.box(extents=size)
    mesh.apply_translation(center)
    return mesh


def mesh_slot_x(length: float, width: float, z0: float, z1: float, x: float, y: float) -> trimesh.Trimesh:
    straight = length - width
    parts = [mesh_box((straight, width, z1 - z0), (x, y, (z0 + z1) / 2))]
    for end_x in (x - straight / 2, x + straight / 2):
        parts.append(mesh_cylinder(width / 2, z0, z1, end_x, y, 48))
    return trimesh.boolean.union(parts, engine="manifold")


def mesh_slot_z_through_x(
    length: float,
    width: float,
    x0: float,
    x1: float,
    y: float,
    z: float,
) -> trimesh.Trimesh:
    straight = length - width
    parts = [mesh_box((x1 - x0, width, straight), ((x0 + x1) / 2, y, z))]
    for end_z in (z - straight / 2, z + straight / 2):
        parts.append(mesh_cylinder_x(width / 2, x0, x1, y, end_z, 48))
    return trimesh.boolean.union(parts, engine="manifold")


def revised_lower_mesh(source: Path) -> trimesh.Trimesh:
    """Replace the original tapered central boss with the horn/electronics pod."""
    lower = trimesh.load_mesh(source, process=True)
    if not isinstance(lower, trimesh.Trimesh):
        raise ValueError(f"Expected one mesh in {source}")
    lower.apply_translation((-lower.bounds.mean(axis=0)[0], -lower.bounds.mean(axis=0)[1], -lower.bounds[0, 2]))
    if not lower.is_watertight:
        raise ValueError("The lower-wheel STL must be watertight for the retrofit boolean")

    # Open the center all the way through, then remove the old tapered stem
    # above the retained spoke/ring junction.
    cavity = mesh_cylinder(POD_ID / 2, -1.0, 80.0)
    old_stem = mesh_cylinder(48.0, 12.0, 80.0)
    base = trimesh.boolean.difference([lower, cavity, old_stem], engine="manifold")

    # Build the same pod geometry as the CadQuery reference.
    outer = mesh_cylinder(POD_OD / 2, POD_FRONT_Z, POD_REAR_Z)
    inner = mesh_cylinder(POD_ID / 2, POD_FRONT_Z - 0.5, POD_REAR_Z + 0.5)
    wall = trimesh.boolean.difference([outer, inner], engine="manifold")
    deck = trimesh.boolean.difference(
        [
            mesh_cylinder(POD_ID / 2, DECK_FRONT_Z, DECK_FRONT_Z + DECK_THICKNESS),
            mesh_cylinder(DECK_SLIDE_BORE / 2, DECK_FRONT_Z - 0.5, DECK_FRONT_Z + DECK_THICKNESS + 0.5),
        ],
        engine="manifold",
    )
    tower = mesh_box(
        (
            SWITCH_TOWER_OUTER_X - SWITCH_TOWER_INNER_X,
            SWITCH_TOWER_WIDTH,
            SWITCH_TOWER_Z1 - SWITCH_TOWER_Z0,
        ),
        (
            (SWITCH_TOWER_INNER_X + SWITCH_TOWER_OUTER_X) / 2,
            0,
            (SWITCH_TOWER_Z0 + SWITCH_TOWER_Z1) / 2,
        ),
    )

    additions = [base, wall, deck, tower]
    for angle in COVER_SCREW_ANGLES:
        a = math.radians(angle)
        additions.append(
            mesh_cylinder(
                5.0,
                POD_REAR_Z - 12.0,
                POD_REAR_Z,
                COVER_SCREW_RADIUS * math.cos(a),
                COVER_SCREW_RADIUS * math.sin(a),
            )
        )
    for angle in SPRING_ANGLES:
        a = math.radians(angle)
        additions.append(
            mesh_cylinder(
                SPRING_POST_DIAMETER / 2,
                DECK_FRONT_Z - 3.0,
                DECK_FRONT_Z + 0.2,
                SPRING_POST_RADIUS * math.cos(a),
                SPRING_POST_RADIUS * math.sin(a),
                64,
            )
        )
    model = trimesh.boolean.union(additions, engine="manifold")

    cutters: list[trimesh.Trimesh] = []
    pocket_x, pocket_y, pocket_z = SWITCH_POCKET
    cutters.append(
        mesh_box(
            (pocket_x, pocket_y, pocket_z),
            (SWITCH_TOWER_INNER_X + pocket_x / 2 - 0.25, 0, SWITCH_POCKET_Z),
        )
    )
    for y in (-SWITCH_HOLE_SPACING / 2, SWITCH_HOLE_SPACING / 2):
        cutters.append(
            mesh_slot_z_through_x(
                SWITCH_SLOT_LENGTH,
                SWITCH_SLOT_WIDTH,
                SWITCH_TOWER_INNER_X + pocket_x - 0.5,
                POD_OD / 2 + 0.5,
                y,
                SWITCH_SLOT_Z,
            )
        )
    for angle in LED_ANGLES:
        a = math.radians(angle)
        cutters.append(
            mesh_cylinder(
                2.65,
                DECK_FRONT_Z - 0.5,
                DECK_FRONT_Z + DECK_THICKNESS + 0.5,
                LED_RADIUS * math.cos(a),
                LED_RADIUS * math.sin(a),
                64,
            )
        )
    for angle in COVER_SCREW_ANGLES:
        a = math.radians(angle)
        cutters.append(
            mesh_cylinder(
                2.05,
                POD_REAR_Z - 6.5,
                POD_REAR_Z + 0.5,
                COVER_SCREW_RADIUS * math.cos(a),
                COVER_SCREW_RADIUS * math.sin(a),
                64,
            )
        )
    cutters.append(mesh_box((10.0, 18.0, 11.0), (-POD_OD / 2, 0, 23.0)))
    model = trimesh.boolean.difference([model, *cutters], engine="manifold")
    model.remove_unreferenced_vertices()
    model.fix_normals()
    return model


def validate_mesh(path: Path, expected_max_extent: float | None = None) -> None:
    mesh = trimesh.load_mesh(path, process=True)
    if not isinstance(mesh, trimesh.Trimesh) or not mesh.is_watertight:
        raise RuntimeError(f"Non-watertight output: {path}")
    if expected_max_extent is not None and max(mesh.extents) > expected_max_extent:
        raise RuntimeError(f"Unexpected size for {path}: {mesh.extents}")
    print(
        f"{path.name}: extents={np.round(mesh.extents, 2).tolist()} "
        f"faces={len(mesh.faces)} watertight={mesh.is_watertight}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--lower-stl", type=Path, default=DEFAULT_LOWER)
    parser.add_argument("--out", type=Path, default=ROOT / "output")
    args = parser.parse_args()
    out = args.out
    out.mkdir(parents=True, exist_ok=True)

    solids = {
        # Rear opening on the bed; the rounded hollow dome closes upward.
        "horn-cap-translucent-print": build_horn_cap().mirror("XY"),
        # Flip the retainer so its broad flange is on the print bed and the
        # glue plug points upward.
        "horn-button-retainer-print": build_button_retainer().mirror("XY").translate((0, 0, BUTTON_FLANGE_THICKNESS)),
        "horn-moving-switch-skirt": build_sliding_skirt(),
        "center-pod-reference": build_center_pod_reference(),
        "rear-cover-battery-tray": build_rear_cover(),
        "universal-board-shelf": build_board_shelf(),
        "horn-button-fit-gauge": build_fit_gauge(),
        "switch-shim-0p5mm": build_switch_shim(0.50),
        "switch-shim-1p0mm": build_switch_shim(1.00),
        "switch-shim-1p5mm": build_switch_shim(1.50),
    }
    for stem, shape in solids.items():
        stl, _ = export_solid(shape, out, stem)
        validate_mesh(stl, 110.0)

    revised = revised_lower_mesh(args.lower_stl)
    revised_path = out / "steering-wheel-lower-horn-pod.stl"
    revised.export(revised_path)
    validate_mesh(revised_path, 300.0)

    print(f"outputs={out.resolve()}")
    print(f"button diametral clearance in measured opening={ORIGINAL_HORN_OPENING - BUTTON_OD:.2f} mm")
    print(f"button travel={BUTTON_TRAVEL:.2f} mm")
    print(f"battery cavity={BATTERY_CAVITY} mm board envelope={BOARD_ENVELOPE} mm")


if __name__ == "__main__":
    main()
