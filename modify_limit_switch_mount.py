#!/usr/bin/env python3
"""Create a longer, two-point LimitSwitchMount from the supplied 3MF mesh.

The original mesh is preserved.  The mounting end is stretched by 12 mm,
the two switch/insert holes are opened from 1.8 to 2.2 mm, and a second
stepped mounting hole is added 9 mm inboard of the relocated original.
"""

from pathlib import Path
import argparse

import numpy as np
import trimesh
from PIL import Image, ImageDraw, ImageFont


EXTENSION_MM = 12.0
STRETCH_SPLIT_Y = 1.0
INSERT_HOLE_DIAMETER_MM = 2.2
INSERT_HOLE_CENTERS = ((-2.0, -12.5), (-2.0, -3.5))
NEW_MOUNT_CENTER = (0.0, 8.5)
MOUNT_THROUGH_DIAMETER_MM = 3.4
MOUNT_COUNTERBORE_DIAMETER_MM = 5.4
MOUNT_COUNTERBORE_FLOOR_Z = -0.5


def cylinder(radius: float, z_min: float, z_max: float, center_xy, sections=128):
    result = trimesh.creation.cylinder(
        radius=radius,
        height=z_max - z_min,
        sections=sections,
    )
    result.apply_translation((center_xy[0], center_xy[1], (z_min + z_max) / 2.0))
    return result


def load_single_mesh(path: Path) -> trimesh.Trimesh:
    loaded = trimesh.load(path, force="scene")
    meshes = tuple(loaded.geometry.values())
    if len(meshes) != 1:
        raise ValueError(f"Expected one mesh in {path}, found {len(meshes)}")
    return meshes[0].copy()


def make_revision(source: Path) -> trimesh.Trimesh:
    mesh = load_single_mesh(source)

    # Stretch only the mounting end.  All original switch-side dimensions,
    # including the 9 mm insert-hole spacing, remain unchanged.
    moved = mesh.vertices[:, 1] > STRETCH_SPLIT_Y
    mesh.vertices[moved, 1] += EXTENSION_MM

    cutters = []
    for center in INSERT_HOLE_CENTERS:
        cutters.append(
            cylinder(
                INSERT_HOLE_DIAMETER_MM / 2.0,
                -3.5,
                3.5,
                center,
            )
        )

    # Match the original mounting feature: a 3.4 mm through hole with a
    # 5.4 mm counterbore from z=-0.5 through the top face.
    cutters.append(
        cylinder(
            MOUNT_THROUGH_DIAMETER_MM / 2.0,
            -3.5,
            3.5,
            NEW_MOUNT_CENTER,
        )
    )
    cutters.append(
        cylinder(
            MOUNT_COUNTERBORE_DIAMETER_MM / 2.0,
            MOUNT_COUNTERBORE_FLOOR_Z,
            3.5,
            NEW_MOUNT_CENTER,
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
    """Render an orthographic top view directly from a mesh cross-section."""
    width, height = 820, 1200
    background = (18, 20, 25)
    image = Image.new("RGB", (width, height), background)
    draw = ImageDraw.Draw(image)
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 34)
        label_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 24)
    except OSError:
        title_font = label_font = ImageFont.load_default()

    section = mesh.section(plane_origin=(0, 0, 0), plane_normal=(0, 0, 1))
    loops = [np.asarray(loop)[:-1, :2] for loop in section.discrete]

    def signed_area(points):
        return 0.5 * (
            np.dot(points[:, 0], np.roll(points[:, 1], -1))
            - np.dot(points[:, 1], np.roll(points[:, 0], -1))
        )

    outer = max(loops, key=lambda points: abs(signed_area(points)))
    holes = [points for points in loops if points is not outer]
    scale = 18.0
    origin = np.array((width / 2, 610.0))

    def screen(points, offset=(0, 0)):
        transformed = np.column_stack((points[:, 0], -points[:, 1])) * scale + origin
        transformed += np.asarray(offset)
        return [tuple(point) for point in transformed]

    # A small offset shadow hints at the 5 mm thickness without obscuring the
    # hole layout that matters for this revision.
    draw.polygon(screen(outer, (13, 15)), fill=(6, 8, 12))
    draw.polygon(screen(outer), fill=(242, 112, 28), outline=(255, 174, 78), width=3)
    for hole in holes:
        draw.polygon(screen(hole), fill=background, outline=(255, 185, 96), width=2)

    draw.text((48, 32), "LimitSwitchMount v2", font=title_font, fill=(244, 246, 250))
    draw.text((48, 82), "20 × 47 × 5 mm", font=label_font, fill=(178, 186, 201))
    draw.text((48, 1040), "Insert holes: 2 × Ø2.2 mm", font=label_font, fill=(222, 226, 235))
    draw.text((48, 1080), "Mount holes: 2 × Ø3.4 / Ø5.4 counterbore", font=label_font, fill=(222, 226, 235))
    draw.text((48, 1120), "Mount-hole spacing: 9 mm", font=label_font, fill=(222, 226, 235))
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
