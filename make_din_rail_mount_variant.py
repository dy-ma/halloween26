#!/usr/bin/env python3
"""Create DIN-rail mount variants by changing only the ear-hole spacing."""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import trimesh


EAR_X = -60.425
ORIGINAL_EAR_Y = (227.0, 277.0)
ORIGINAL_SPACING = 50.0

# Dimensions measured from the source mesh.
OUTER_RADIUS_TOP = 6.25
OUTER_RADIUS_BOTTOM = 5.25
BOTTOM_Z = -530.0
CHAMFER_Z = -529.0
TOP_Z = -525.4
THROUGH_RADIUS = 2.25
COUNTERBORE_RADIUS = 5.0
COUNTERBORE_BOTTOM_Z = -526.0


def rotational_solid(
    center_x: float,
    center_y: float,
    rings: list[tuple[float, float]],
    sections: int = 192,
) -> trimesh.Trimesh:
    """Build a capped solid of revolution around the Z axis."""
    angles = np.linspace(0.0, 2.0 * np.pi, sections, endpoint=False)
    vertices: list[list[float]] = []
    for z, radius in rings:
        vertices.extend(
            [
                center_x + radius * np.cos(angle),
                center_y + radius * np.sin(angle),
                z,
            ]
            for angle in angles
        )

    bottom_center = len(vertices)
    vertices.append([center_x, center_y, rings[0][0]])
    top_center = len(vertices)
    vertices.append([center_x, center_y, rings[-1][0]])

    faces: list[list[int]] = []
    for ring_index in range(len(rings) - 1):
        lower = ring_index * sections
        upper = (ring_index + 1) * sections
        for i in range(sections):
            j = (i + 1) % sections
            faces.append([lower + i, lower + j, upper + j])
            faces.append([lower + i, upper + j, upper + i])

    for i in range(sections):
        j = (i + 1) % sections
        faces.append([bottom_center, j, i])
        top_ring = (len(rings) - 1) * sections
        faces.append([top_center, top_ring + i, top_ring + j])

    return trimesh.Trimesh(
        vertices=np.asarray(vertices),
        faces=np.asarray(faces),
        process=True,
    )


def cylinder(
    radius: float,
    z_min: float,
    z_max: float,
    x: float,
    y: float,
    sections: int = 192,
) -> trimesh.Trimesh:
    solid = trimesh.creation.cylinder(
        radius=radius,
        height=z_max - z_min,
        sections=sections,
    )
    solid.apply_translation([x, y, (z_min + z_max) / 2.0])
    return solid


def make_variant(source: Path, output: Path, spacing: float) -> None:
    mesh = trimesh.load_mesh(source, process=True)
    if not isinstance(mesh, trimesh.Trimesh) or not mesh.is_watertight:
        raise ValueError("Source must be a single watertight mesh")

    midpoint = sum(ORIGINAL_EAR_Y) / 2.0
    new_ys = (midpoint - spacing / 2.0, midpoint + spacing / 2.0)

    # Fill only the two original ear holes.  The filler remains inside the
    # original 6.25 mm tab outline and is flush with its top and bottom.
    fillers = [
        cylinder(5.05, BOTTOM_Z, TOP_Z, EAR_X, y)
        for y in ORIGINAL_EAR_Y
    ]
    mesh = trimesh.boolean.union([mesh, *fillers], engine="manifold")

    # Add full-strength tab material around each relocated hole.  The new and
    # old outlines overlap, producing a smooth elongated attachment without
    # thinning the material at the outer edge.
    tab_profile = [
        (BOTTOM_Z, OUTER_RADIUS_BOTTOM),
        (CHAMFER_Z, OUTER_RADIUS_TOP),
        (TOP_Z, OUTER_RADIUS_TOP),
    ]
    new_tabs = [rotational_solid(EAR_X, y, tab_profile) for y in new_ys]
    mesh = trimesh.boolean.union([mesh, *new_tabs], engine="manifold")

    # Recreate the source hole geometry at the new centers: a 4.5 mm through
    # hole with a 10 mm, 0.6 mm-deep counterbore on the top face.
    cutters: list[trimesh.Trimesh] = []
    for y in new_ys:
        cutters.append(
            cylinder(
                THROUGH_RADIUS,
                BOTTOM_Z - 0.2,
                TOP_Z + 0.2,
                EAR_X,
                y,
            )
        )
        cutters.append(
            cylinder(
                COUNTERBORE_RADIUS,
                COUNTERBORE_BOTTOM_Z,
                TOP_Z + 0.2,
                EAR_X,
                y,
            )
        )
    cutter = trimesh.boolean.union(cutters, engine="manifold")
    mesh = trimesh.boolean.difference([mesh, cutter], engine="manifold")

    mesh.remove_unreferenced_vertices()
    if not mesh.is_watertight or not mesh.is_winding_consistent:
        raise RuntimeError("Generated mesh failed watertightness checks")

    output.parent.mkdir(parents=True, exist_ok=True)
    mesh.export(output)

    print(f"output={output}")
    print(f"new_centers=({EAR_X:.3f}, {new_ys[0]:.3f}), ({EAR_X:.3f}, {new_ys[1]:.3f})")
    print(f"spacing={new_ys[1] - new_ys[0]:.3f} mm")
    print(f"watertight={mesh.is_watertight}")
    print(f"faces={len(mesh.faces)}")
    print(f"bounds={mesh.bounds.tolist()}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--spacing", type=float, default=57.0)
    args = parser.parse_args()
    make_variant(args.source, args.output, args.spacing)


if __name__ == "__main__":
    main()
