#!/usr/bin/env python3
"""Make the sideways-switch revision of LimitSwitchMount.

Revision 3 keeps the original 35 mm length, widens the body to 24 mm,
rotates the limit-switch insert pattern 90 degrees, and places two stepped
attachment holes across the mounting end.
"""

from pathlib import Path
import argparse

import numpy as np
import trimesh
from PIL import Image, ImageDraw, ImageFont


BODY_WIDTH_MM = 24.0
BODY_LENGTH_MM = 35.0
BODY_THICKNESS_MM = 5.0
WIDTH_ADDED_EACH_SIDE_MM = 2.0
WIDTH_STRETCH_SPLIT_X = 4.0

INSERT_HOLE_DIAMETER_MM = 3.0
INSERT_HOLE_SPACING_MM = 9.0
INSERT_ROW_Y = -8.0
INSERT_HOLE_CENTERS = ((-4.5, INSERT_ROW_Y), (4.5, INSERT_ROW_Y))

MOUNT_ROW_Y = 6.5
MOUNT_HOLE_SPACING_MM = 10.0
MOUNT_HOLE_CENTERS = ((-5.0, MOUNT_ROW_Y), (5.0, MOUNT_ROW_Y))
MOUNT_THROUGH_DIAMETER_MM = 3.4
MOUNT_COUNTERBORE_DIAMETER_MM = 5.4
MOUNT_COUNTERBORE_FLOOR_Z = -0.5

ORIGINAL_INSERT_CENTERS = ((-2.0, -12.5), (-2.0, -3.5))
ORIGINAL_MOUNT_CENTER = (0.0, 5.5)


def cylinder(radius: float, z_min: float, z_max: float, center_xy, sections=128):
    shape = trimesh.creation.cylinder(
        radius=radius,
        height=z_max - z_min,
        sections=sections,
    )
    shape.apply_translation((center_xy[0], center_xy[1], (z_min + z_max) / 2.0))
    return shape


def load_single_mesh(path: Path) -> trimesh.Trimesh:
    loaded = trimesh.load(path, force="scene")
    meshes = tuple(loaded.geometry.values())
    if len(meshes) != 1:
        raise ValueError(f"Expected one mesh in {path}, found {len(meshes)}")
    return meshes[0].copy()


def make_revision(source: Path) -> trimesh.Trimesh:
    mesh = load_single_mesh(source)

    # Add 2 mm through the flat middle of each side. This preserves the
    # original corner and top/bottom fillet radii instead of scaling them.
    mesh.vertices[mesh.vertices[:, 0] < -WIDTH_STRETCH_SPLIT_X, 0] -= WIDTH_ADDED_EACH_SIDE_MM
    mesh.vertices[mesh.vertices[:, 0] > WIDTH_STRETCH_SPLIT_X, 0] += WIDTH_ADDED_EACH_SIDE_MM

    # Close the three original bores before cutting the new sideways layout.
    fills = [
        cylinder(1.3, -2.5, 2.5, center)
        for center in ORIGINAL_INSERT_CENTERS
    ]
    fills.append(cylinder(2.8, -2.5, 2.5, ORIGINAL_MOUNT_CENTER))
    mesh = trimesh.boolean.union([mesh, *fills], engine="manifold")

    cutters = [
        cylinder(INSERT_HOLE_DIAMETER_MM / 2.0, -3.5, 3.5, center)
        for center in INSERT_HOLE_CENTERS
    ]
    for center in MOUNT_HOLE_CENTERS:
        cutters.append(
            cylinder(MOUNT_THROUGH_DIAMETER_MM / 2.0, -3.5, 3.5, center)
        )
        cutters.append(
            cylinder(
                MOUNT_COUNTERBORE_DIAMETER_MM / 2.0,
                MOUNT_COUNTERBORE_FLOOR_Z,
                3.5,
                center,
            )
        )

    result = trimesh.boolean.difference([mesh, *cutters], engine="manifold")
    if isinstance(result, list):
        if len(result) != 1:
            raise ValueError(f"Boolean produced {len(result)} meshes")
        result = result[0]
    result.remove_unreferenced_vertices()
    result.fix_normals()
    return result


def render_preview(mesh: trimesh.Trimesh, output: Path):
    width, height = 1000, 1100
    background = (18, 20, 25)
    image = Image.new("RGB", (width, height), background)
    draw = ImageDraw.Draw(image)
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 36)
        label_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 25)
    except OSError:
        title_font = label_font = ImageFont.load_default()

    section = mesh.section(plane_origin=(0, 0, 0), plane_normal=(0, 0, 1))
    loops = [np.asarray(loop)[:-1, :2] for loop in section.discrete]

    def area(points):
        return 0.5 * abs(
            np.dot(points[:, 0], np.roll(points[:, 1], -1))
            - np.dot(points[:, 1], np.roll(points[:, 0], -1))
        )

    outer = max(loops, key=area)
    holes = [points for points in loops if points is not outer]
    scale = 23.0
    origin = np.array((width / 2, 500.0))

    def screen(points, offset=(0, 0)):
        result = np.column_stack((points[:, 0], -points[:, 1])) * scale + origin
        result += np.asarray(offset)
        return [tuple(point) for point in result]

    draw.polygon(screen(outer, (14, 16)), fill=(6, 8, 12))
    draw.polygon(screen(outer), fill=(242, 112, 28), outline=(255, 174, 78), width=3)
    for hole in holes:
        draw.polygon(screen(hole), fill=background, outline=(255, 185, 96), width=2)

    draw.text((54, 30), "LimitSwitchMount v3 — sideways switch", font=title_font, fill=(244, 246, 250))
    draw.text((54, 82), "24 × 35 × 5 mm", font=label_font, fill=(178, 186, 201))
    draw.text((54, 936), "M2 heat-set pilots: 2 × Ø3.0 mm, 9 mm apart", font=label_font, fill=(222, 226, 235))
    draw.text((54, 978), "Attachment holes: 2 × Ø3.4 / Ø5.4 counterbore", font=label_font, fill=(222, 226, 235))
    draw.text((54, 1020), "Attachment-hole spacing: 10 mm", font=label_font, fill=(222, 226, 235))
    image.save(output)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--stl", type=Path)
    parser.add_argument("--preview", type=Path)
    args = parser.parse_args()

    revised = make_revision(args.source)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    revised.export(args.output)
    if args.stl:
        revised.export(args.stl)
    if args.preview:
        render_preview(revised, args.preview)

    print(f"bounds_mm={np.round(revised.bounds, 4).tolist()}")
    print(f"extents_mm={np.round(revised.extents, 4).tolist()}")
    print(f"faces={len(revised.faces)} vertices={len(revised.vertices)}")
    print(f"watertight={revised.is_watertight} volume_mm3={revised.volume:.3f}")


if __name__ == "__main__":
    main()
