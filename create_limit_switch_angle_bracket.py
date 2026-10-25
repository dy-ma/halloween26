#!/usr/bin/env python3
"""Create a reinforced 45-degree limit-switch bracket variation."""

from pathlib import Path
import argparse
import math

import numpy as np
import trimesh
from PIL import Image, ImageDraw, ImageFont


ANGLE_DEG = 45.0
WIDTH_MM = 24.0
BACK_HEIGHT_MM = 35.0
DECK_LENGTH_MM = 25.0
THICKNESS_MM = 5.0

INSERT_DIAMETER_MM = 3.0
INSERT_SPACING_MM = 9.0

BACK_MOUNT_THROUGH_DIAMETER_MM = 3.4
BACK_MOUNT_COUNTERBORE_DIAMETER_MM = 5.4
BACK_MOUNT_CENTERS_LOCAL = ((-5.0, 10.0), (5.0, 10.0))

RAIL_EXTRA_MM = 76.2  # Three inches beyond the existing bracket edge.
RAIL_HEIGHT_MM = 14.0
RAIL_THICKNESS_MM = 4.0
RAIL_SLOT_WIDTH_MM = 4.0
RAIL_COUNTERBORE_WIDTH_MM = 8.0
TRIM_INTERVAL_MM = 12.7  # Half-inch trim guides.


def rounded_prism(width, height, depth, radius, corner_segments=16):
    """Rounded rectangle in local XY, extruded symmetrically along local Z."""
    corners = (
        (width / 2 - radius, -height / 2 + radius, -90, 0),
        (width / 2 - radius, height / 2 - radius, 0, 90),
        (-width / 2 + radius, height / 2 - radius, 90, 180),
        (-width / 2 + radius, -height / 2 + radius, 180, 270),
    )
    boundary = []
    for cx, cy, a0, a1 in corners:
        for angle in np.linspace(a0, a1, corner_segments, endpoint=False):
            radians = math.radians(float(angle))
            boundary.append((cx + radius * math.cos(radians), cy + radius * math.sin(radians)))
    boundary = np.asarray(boundary)
    count = len(boundary)
    vertices = np.vstack(
        (
            np.column_stack((boundary, np.full(count, -depth / 2))),
            np.column_stack((boundary, np.full(count, depth / 2))),
            (0.0, 0.0, -depth / 2),
            (0.0, 0.0, depth / 2),
        )
    )
    bottom_center = 2 * count
    top_center = 2 * count + 1
    faces = []
    for index in range(count):
        following = (index + 1) % count
        faces.append((bottom_center, following, index))
        faces.append((top_center, count + index, count + following))
        faces.append((index, following, count + following))
        faces.append((index, count + following, count + index))
    return trimesh.Trimesh(vertices=vertices, faces=np.asarray(faces), process=True)


def triangular_prism_x(x_min, x_max, yz_points):
    """Triangle in world YZ extruded from x_min to x_max."""
    vertices = []
    for x in (x_min, x_max):
        vertices.extend((x, y, z) for y, z in yz_points)
    faces = np.asarray(
        (
            (0, 2, 1),
            (3, 4, 5),
            (0, 1, 4), (0, 4, 3),
            (1, 2, 5), (1, 5, 4),
            (2, 0, 3), (2, 3, 5),
        )
    )
    mesh = trimesh.Trimesh(vertices=np.asarray(vertices), faces=faces, process=True)
    mesh.fix_normals()
    return mesh


def cylinder(radius, height, center=(0, 0, 0), sections=128):
    result = trimesh.creation.cylinder(radius=radius, height=height, sections=sections)
    result.apply_translation(center)
    return result


def rotation_x(degrees):
    return trimesh.transformations.rotation_matrix(math.radians(degrees), (1, 0, 0))


def rotated_insert_centers(rotation_degrees):
    angle = math.radians(rotation_degrees)
    cosine = math.cos(angle)
    sine = math.sin(angle)
    centers = []
    for x, y in ((-INSERT_SPACING_MM / 2, 0.0), (INSERT_SPACING_MM / 2, 0.0)):
        centers.append((x * cosine - y * sine, x * sine + y * cosine))
    return tuple(centers)


def build_bracket(switch_rotation_degrees=0.0, rail_side="none", rail_extra_mm=RAIL_EXTRA_MM):
    # Vertical back plate: local Y becomes world Z, and local Z becomes -world Y.
    back_transform = rotation_x(90)
    back_transform[:3, 3] = (0.0, THICKNESS_MM / 2, 0.0)
    back = rounded_prism(WIDTH_MM, BACK_HEIGHT_MM, THICKNESS_MM, 4.0)
    back.apply_transform(back_transform)

    # Deck center plane slopes outward and downward at 45 degrees. Its inner
    # edge overlaps the front of the back plate for a strong boolean union.
    angle = math.radians(ANGLE_DEG)
    deck_direction = np.array((0.0, math.cos(angle), -math.sin(angle)))
    inner_edge = np.array((0.0, THICKNESS_MM, 5.0))
    deck_center = inner_edge + deck_direction * (DECK_LENGTH_MM / 2)
    deck_transform = rotation_x(-ANGLE_DEG)
    deck_transform[:3, 3] = deck_center
    deck = rounded_prism(WIDTH_MM, DECK_LENGTH_MM, THICKNESS_MM, 3.5)
    deck.apply_transform(deck_transform)

    # Two 3 mm side gussets tie the underside of the deck into the back plate.
    gusset_profile = ((4.5, 2.5), (4.5, -11.0), (17.5, -11.0))
    gussets = (
        triangular_prism_x(-12.0, -9.0, gusset_profile),
        triangular_prism_x(9.0, 12.0, gusset_profile),
    )
    solids = [back, deck, *gussets]
    rail_data = None
    if rail_side in ("left", "right"):
        direction = 1.0 if rail_side == "right" else -1.0
        bracket_edge_x = direction * (WIDTH_MM / 2)
        outer_x = bracket_edge_x + direction * rail_extra_mm
        # Four millimetres of overlap makes the rail a continuous part of the
        # original back plate while keeping the long adjustment tail light.
        inner_x = bracket_edge_x - direction * 4.0
        rail_center_x = (inner_x + outer_x) / 2
        rail_width = abs(outer_x - inner_x)
        rail_transform = rotation_x(90)
        rail_transform[:3, 3] = (rail_center_x, RAIL_THICKNESS_MM / 2, 10.0)
        rail = rounded_prism(
            rail_width,
            RAIL_HEIGHT_MM,
            RAIL_THICKNESS_MM,
            3.0,
        )
        rail.apply_transform(rail_transform)
        solids.append(rail)
        rail_data = (direction, bracket_edge_x, outer_x, rail_center_x, rail_transform)

    bracket = trimesh.boolean.union(solids, engine="manifold")

    cutters = []

    # Wood/frame attachment: the compact bracket keeps its original pair of
    # holes, while extended variations use a continuous recessed channel.
    if rail_data is None:
        for x, local_y in BACK_MOUNT_CENTERS_LOCAL:
            through = cylinder(
                BACK_MOUNT_THROUGH_DIAMETER_MM / 2,
                7.0,
                (x, local_y, 0.0),
            )
            through.apply_transform(back_transform)
            cutters.append(through)

            counterbore = cylinder(
                BACK_MOUNT_COUNTERBORE_DIAMETER_MM / 2,
                4.0,
                (x, local_y, -1.5),
            )
            counterbore.apply_transform(back_transform)
            cutters.append(counterbore)
    else:
        direction, bracket_edge_x, outer_x, _, _ = rail_data
        slot_inner_x = bracket_edge_x + direction * 4.0
        slot_outer_x = outer_x - direction * 6.0
        slot_center_x = (slot_inner_x + slot_outer_x) / 2
        slot_length = abs(slot_outer_x - slot_inner_x)
        slot_transform = rotation_x(90)
        slot_transform[:3, 3] = (slot_center_x, RAIL_THICKNESS_MM / 2, 10.0)

        through_slot = rounded_prism(
            slot_length,
            RAIL_SLOT_WIDTH_MM,
            7.0,
            RAIL_SLOT_WIDTH_MM / 2,
        )
        through_slot.apply_transform(slot_transform)
        cutters.append(through_slot)

        recessed_slot = rounded_prism(
            slot_length,
            RAIL_COUNTERBORE_WIDTH_MM,
            3.2,
            RAIL_COUNTERBORE_WIDTH_MM / 2,
        )
        recessed_slot.apply_translation((0.0, 0.0, -1.4))
        recessed_slot.apply_transform(slot_transform)
        cutters.append(recessed_slot)

        # Front-face score grooves every half inch, starting at one inch.
        # A 2 mm backing web remains, so PETG can be cut with snips and PLA
        # can usually be snapped cleanly after scoring.
        distance = 25.4
        while distance < rail_extra_mm - 6.0:
            groove_x = bracket_edge_x + direction * distance
            groove = trimesh.creation.box(extents=(1.2, 2.1, RAIL_HEIGHT_MM + 0.4))
            groove.apply_translation((groove_x, RAIL_THICKNESS_MM - 1.05, 10.0))
            cutters.append(groove)
            distance += TRIM_INTERVAL_MM

    # M2 brass-insert pilots perpendicular to the angled switch deck.
    for x, local_y in rotated_insert_centers(switch_rotation_degrees):
        insert = cylinder(INSERT_DIAMETER_MM / 2, 7.0, (x, local_y, 0.0))
        insert.apply_transform(deck_transform)
        cutters.append(insert)

    result = trimesh.boolean.difference([bracket, *cutters], engine="manifold")
    if isinstance(result, list):
        if len(result) != 1:
            raise ValueError(f"Boolean produced {len(result)} bodies")
        result = result[0]
    result.remove_unreferenced_vertices()
    result.fix_normals()
    return result


def orient_for_print(mesh):
    """Lay the back plate on the bed; the deck then rises at self-supporting 45°."""
    printable = mesh.copy()
    printable.apply_transform(rotation_x(90))
    printable.apply_translation((0.0, 0.0, -printable.bounds[0, 2]))
    return printable


def render_preview(output: Path, switch_rotation_degrees=0.0, rail_side="none", rail_extra_mm=RAIL_EXTRA_MM):
    width, height = 1300, 900
    bg = (18, 20, 25)
    image = Image.new("RGB", (width, height), bg)
    draw = ImageDraw.Draw(image)
    try:
        title = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 38)
        label = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 26)
    except OSError:
        title = label = ImageFont.load_default()

    draw.text((54, 38), "LimitSwitchMount — 45° bracket", font=title, fill=(244, 246, 250))
    draw.text((54, 92), "Separate variation; flat v3 is unchanged", font=label, fill=(176, 186, 202))

    # Side elevation, scaled from the actual YZ design coordinates.
    scale = 18.0
    origin = np.array((300.0, 440.0))
    def p(y, z):
        return tuple(origin + np.array((y, -z)) * scale)

    draw.rounded_rectangle((p(0, 17.5), p(5, -17.5)), radius=14, fill=(210, 82, 22), outline=(255, 172, 76), width=3)
    angle = math.radians(ANGLE_DEG)
    d = np.array((math.cos(angle), -math.sin(angle)))
    n = np.array((math.sin(angle), math.cos(angle)))
    inner = np.array((5.0, 5.0))
    outer = inner + d * DECK_LENGTH_MM
    deck_poly = (inner - n * 2.5, outer - n * 2.5, outer + n * 2.5, inner + n * 2.5)
    draw.polygon([p(y, z) for y, z in deck_poly], fill=(242, 112, 28), outline=(255, 182, 88))
    draw.polygon([p(y, z) for y, z in ((4.5, 2.5), (4.5, -11), (17.5, -11))], fill=(197, 70, 18), outline=(255, 159, 58))
    draw.arc((p(5, 5)[0] - 110, p(5, 5)[1] - 110, p(5, 5)[0] + 110, p(5, 5)[1] + 110), 0, 45, fill=(255, 214, 145), width=4)
    draw.text((505, 280), "45° switch platform", font=label, fill=(244, 246, 250))

    if rail_side in ("left", "right"):
        # Front view of the adjustable mounting rail.
        rail_scale = 4.2
        direction = 1 if rail_side == "right" else -1
        bracket_edge = direction * WIDTH_MM / 2
        outer = bracket_edge + direction * rail_extra_mm
        min_x, max_x = sorted((-WIDTH_MM / 2, WIDTH_MM / 2, outer))[:1][0], max(-WIDTH_MM / 2, WIDTH_MM / 2, outer)
        if rail_side == "left":
            min_x, max_x = min(outer, -WIDTH_MM / 2), WIDTH_MM / 2
        center_x = (min_x + max_x) / 2
        view_center = np.array((1010.0, 475.0))

        def rail_point(x, z):
            return tuple(view_center + np.array(((x - center_x) * rail_scale, -z * rail_scale)))

        draw.rounded_rectangle(
            tuple(rail_point(-WIDTH_MM / 2, 17.5)) + tuple(rail_point(WIDTH_MM / 2, -17.5)),
            radius=18,
            fill=(210, 82, 22),
            outline=(255, 172, 76),
            width=3,
        )
        rail_inner = bracket_edge - direction * 4.0
        draw.rounded_rectangle(
            tuple(rail_point(min(rail_inner, outer), 17.0)) + tuple(rail_point(max(rail_inner, outer), 3.0)),
            radius=12,
            fill=(242, 112, 28),
            outline=(255, 182, 88),
            width=3,
        )
        slot_inner = bracket_edge + direction * 4.0
        slot_outer = outer - direction * 6.0
        draw.rounded_rectangle(
            tuple(rail_point(min(slot_inner, slot_outer), 14.0)) + tuple(rail_point(max(slot_inner, slot_outer), 6.0)),
            radius=15,
            fill=bg,
            outline=(255, 208, 138),
            width=2,
        )
        distance = 25.4
        while distance < rail_extra_mm - 6.0:
            gx = bracket_edge + direction * distance
            p1, p2 = rail_point(gx, 17.0), rail_point(gx, 3.0)
            draw.line((p1, p2), fill=(255, 209, 142), width=3)
            distance += TRIM_INTERVAL_MM
        draw.text((820, 300), f"{rail_side}-hand mounting face", font=label, fill=(244, 246, 250))
    else:
        # Face view of the angled deck so the switch-hole rotation is explicit.
        face_scale = 8.0
        face_center = np.array((1030.0, 465.0))
        face_half = np.array((WIDTH_MM, DECK_LENGTH_MM)) * face_scale / 2
        face_box = tuple(face_center - face_half) + tuple(face_center + face_half)
        draw.rounded_rectangle(face_box, radius=28, fill=(242, 112, 28), outline=(255, 182, 88), width=3)
        for x, y in rotated_insert_centers(switch_rotation_degrees):
            center = face_center + np.array((x, y)) * face_scale
            radius = INSERT_DIAMETER_MM * face_scale / 2
            draw.ellipse((center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius), fill=bg, outline=(255, 208, 138), width=2)
        draw.text((900, 310), "angled-deck face", font=label, fill=(244, 246, 250))
    draw.text((54, 785), "Back plate: 24 × 35 × 5 mm    •    Deck: 24 × 25 × 5 mm", font=label, fill=(220, 225, 235))
    if rail_side in ("left", "right"):
        draw.text((54, 830), f"3-inch {rail_side} rail    •    4 mm recessed slot    •    1/2-inch trim guides", font=label, fill=(220, 225, 235))
    else:
        draw.text((54, 830), f"M2 pilots: Ø3.0 mm    •    Switch rotation: {switch_rotation_degrees:.0f}°", font=label, fill=(220, 225, 235))
    image.save(output)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    parser.add_argument("--stl", type=Path)
    parser.add_argument("--preview", type=Path)
    parser.add_argument("--switch-rotation", type=float, default=0.0)
    parser.add_argument("--rail-side", choices=("none", "left", "right"), default="none")
    parser.add_argument("--rail-extra-mm", type=float, default=RAIL_EXTRA_MM)
    args = parser.parse_args()

    installed_mesh = build_bracket(args.switch_rotation, args.rail_side, args.rail_extra_mm)
    mesh = orient_for_print(installed_mesh)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    mesh.export(args.output)
    if args.stl:
        mesh.export(args.stl)
    if args.preview:
        render_preview(args.preview, args.switch_rotation, args.rail_side, args.rail_extra_mm)

    print(f"bounds_mm={np.round(mesh.bounds, 4).tolist()}")
    print(f"extents_mm={np.round(mesh.extents, 4).tolist()}")
    print(f"faces={len(mesh.faces)} vertices={len(mesh.vertices)}")
    print(f"watertight={mesh.is_watertight} winding={mesh.is_winding_consistent}")
    print(f"euler={mesh.euler_number} volume_mm3={mesh.volume:.3f}")


if __name__ == "__main__":
    main()
