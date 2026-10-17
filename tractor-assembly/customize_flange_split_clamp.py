#!/usr/bin/env python3
"""Add an M3 split-clamp boss to the imported flange STL.

The original STL is left unchanged.  The clamp is placed between the two
nearest mounting holes, opposite the D-flat as closely as the six-hole pattern
allows.  Dimensions are in millimetres.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import trimesh


def chamfered_prism(
    radial_min: float,
    radial_max: float,
    tangent_min: float,
    tangent_max: float,
    z_min: float,
    z_max: float,
    chamfer: float,
    radial: np.ndarray,
    tangent: np.ndarray,
) -> trimesh.Trimesh:
    """Make an eight-sided vertical prism in radial/tangential coordinates."""
    outline = np.array(
        [
            [radial_min + chamfer, tangent_min],
            [radial_max - chamfer, tangent_min],
            [radial_max, tangent_min + chamfer],
            [radial_max, tangent_max - chamfer],
            [radial_max - chamfer, tangent_max],
            [radial_min + chamfer, tangent_max],
            [radial_min, tangent_max - chamfer],
            [radial_min, tangent_min + chamfer],
        ],
        dtype=float,
    )

    xy = outline[:, :1] * radial[None, :] + outline[:, 1:] * tangent[None, :]
    bottom = np.column_stack((xy, np.full(len(xy), z_min)))
    top = np.column_stack((xy, np.full(len(xy), z_max)))
    vertices = np.vstack((bottom, top))

    faces: list[list[int]] = []
    count = len(outline)
    # Bottom and top caps.
    for i in range(1, count - 1):
        faces.append([0, i + 1, i])
        faces.append([count, count + i, count + i + 1])
    # Vertical walls.
    for i in range(count):
        j = (i + 1) % count
        faces.append([i, j, count + j])
        faces.append([i, count + j, count + i])

    return trimesh.Trimesh(vertices=vertices, faces=np.asarray(faces), process=True)


def cylinder_between(
    center: np.ndarray,
    direction: np.ndarray,
    radius: float,
    length: float,
    sections: int = 96,
) -> trimesh.Trimesh:
    """Make a cylinder whose axis follows *direction*."""
    cylinder = trimesh.creation.cylinder(radius=radius, height=length, sections=sections)
    transform = trimesh.geometry.align_vectors([0.0, 0.0, 1.0], direction)
    transform[:3, 3] = center
    cylinder.apply_transform(transform)
    return cylinder


def build(input_path: Path, output_path: Path) -> trimesh.Trimesh:
    original = trimesh.load_mesh(input_path, process=True)
    if not isinstance(original, trimesh.Trimesh):
        raise TypeError("Expected a single STL mesh")
    if not original.is_watertight:
        raise ValueError("The source STL is not watertight")

    # D-flat points toward +Y.  300 degrees is the closest clear direction on
    # the opposite side, midway between the -Y and lower-right mounting holes.
    angle = np.deg2rad(300.0)
    radial = np.array([np.cos(angle), np.sin(angle)])
    tangent = np.array([-np.sin(angle), np.cos(angle)])

    # Main clamp ears.  Flat tangential end faces give the washer and nut a
    # proper seat.  The lower 0.2 mm overlaps the flange for a robust union.
    ears = chamfered_prism(
        radial_min=8.4,
        radial_max=15.6,
        tangent_min=-7.0,
        tangent_max=7.0,
        z_min=14.8,
        z_max=27.2,
        chamfer=0.8,
        radial=radial,
        tangent=tangent,
    )

    combined = trimesh.boolean.union([original, ears], engine="manifold")

    # A 1.2 mm radial slit opens the collar to the D-bore but leaves the flange
    # itself continuous below z=14.8 mm.
    slit = trimesh.creation.box(extents=[20.0, 1.2, 14.2])
    slit_transform = np.eye(4)
    slit_transform[:2, 0] = radial
    slit_transform[:2, 1] = tangent
    slit_transform[:3, 3] = [*(radial * 10.0), 21.9]
    slit.apply_transform(slit_transform)

    # Model the horizontal M3 clearance hole at 4.0 mm.  This intentionally
    # includes extra FDM allowance; a 3 mm drill can be used after printing if
    # the bridge sags or the hole still prints tight.
    bolt_center = np.array([*(radial * 12.0), 23.0])
    bolt_axis = np.array([*tangent, 0.0])
    bolt_hole = cylinder_between(
        center=bolt_center,
        direction=bolt_axis,
        radius=2.0,
        length=18.0,
    )

    result = trimesh.boolean.difference([combined, slit, bolt_hole], engine="manifold")
    result.remove_unreferenced_vertices()

    if not result.is_watertight or not result.is_winding_consistent:
        raise RuntimeError("Resulting mesh failed manifold validation")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    result.export(output_path, file_type="stl")
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        type=Path,
        default=Path(__file__).with_name("Flange v3 - Flange.stl"),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).with_name("Flange v3 - Split Clamp M3.stl"),
    )
    args = parser.parse_args()
    mesh = build(args.input, args.output)
    print(f"Wrote: {args.output}")
    print(f"Triangles: {len(mesh.faces):,}")
    print(f"Watertight: {mesh.is_watertight}")
    print(f"Winding consistent: {mesh.is_winding_consistent}")
    print(f"Bounds: {mesh.bounds.tolist()}")
    print(f"Volume: {mesh.volume:.3f} mm^3")


if __name__ == "__main__":
    main()
