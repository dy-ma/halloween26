#!/usr/bin/env python3
"""Convert the imported flange collar into a two-piece M3 clamp.

Outputs a main flange body and a separate, print-oriented clamp cap.  The
original STL is never modified.  Dimensions are millimetres.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import trimesh


def box_from_bounds(lo: tuple[float, float, float], hi: tuple[float, float, float]) -> trimesh.Trimesh:
    lo_v = np.asarray(lo, dtype=float)
    hi_v = np.asarray(hi, dtype=float)
    box = trimesh.creation.box(extents=hi_v - lo_v)
    box.apply_translation((lo_v + hi_v) / 2.0)
    return box


def cylinder_y(x: float, z: float, diameter: float, length: float) -> trimesh.Trimesh:
    cylinder = trimesh.creation.cylinder(radius=diameter / 2.0, height=length, sections=96)
    transform = trimesh.geometry.align_vectors([0.0, 0.0, 1.0], [0.0, 1.0, 0.0])
    transform[:3, 3] = [x, 0.0, z]
    cylinder.apply_transform(transform)
    return cylinder


def union(meshes: list[trimesh.Trimesh]) -> trimesh.Trimesh:
    return trimesh.boolean.union(meshes, engine="manifold")


def difference(meshes: list[trimesh.Trimesh]) -> trimesh.Trimesh:
    return trimesh.boolean.difference(meshes, engine="manifold")


def build(input_path: Path, main_output: Path, cap_output: Path, cap_assembly_output: Path) -> tuple[trimesh.Trimesh, trimesh.Trimesh]:
    original = trimesh.load_mesh(input_path, process=True)
    if not isinstance(original, trimesh.Trimesh) or not original.is_watertight:
        raise ValueError("The source must be one watertight STL mesh")

    # The D-flat is on +Y.  Keep that side fixed to the flange and make the
    # opposite (-Y) circular half removable, so tightening pushes the shaft
    # firmly into its torque-carrying flat.
    split_gap = 0.8
    fixed_face_y = split_gap / 2.0
    cap_face_y = -split_gap / 2.0

    # Remove only the upper negative-Y half of the original collar; the full
    # 15 mm flange and its central D hole remain unchanged.
    cap_removal = box_from_bounds((-20.0, -20.0, 15.0), (20.0, fixed_face_y, 30.0))
    main_core = difference([original, cap_removal])

    # Recover the removable half from the original collar with 0.2 mm vertical
    # running clearance above the flange top.
    cap_region = box_from_bounds((-20.0, -20.0, 15.2), (20.0, cap_face_y, 30.0))
    cap_core = trimesh.boolean.intersection([original, cap_region], engine="manifold")

    # Two substantial lug pairs flank the D bore.  Their outer Y faces are
    # flat so ordinary M3 washers and nuts seat correctly.
    main_lugs = [
        box_from_bounds((4.5, fixed_face_y, 17.2), (11.5, 7.0, 27.2)),
        box_from_bounds((-11.5, fixed_face_y, 17.2), (-4.5, 7.0, 27.2)),
    ]
    cap_lugs = [
        box_from_bounds((4.5, -7.0, 17.2), (11.5, cap_face_y, 27.2)),
        box_from_bounds((-11.5, -7.0, 17.2), (-4.5, cap_face_y, 27.2)),
    ]

    # Twin registration tongues keep the cap located in X and Z while the
    # bolts are installed.  Matching cap pockets include 0.25 mm clearance per
    # side and extra depth for clamp travel.
    tongues = [
        box_from_bounds((4.7, -1.2, 17.0), (6.5, 0.6, 20.0)),
        box_from_bounds((-6.5, -1.2, 17.0), (-4.7, 0.6, 20.0)),
    ]
    pockets = [
        box_from_bounds((4.45, -1.5, 16.75), (6.75, -0.1, 20.25)),
        box_from_bounds((-6.75, -1.5, 16.75), (-4.45, -0.1, 20.25)),
    ]

    main = union([main_core, *main_lugs, *tongues])
    cap = union([cap_core, *cap_lugs])

    # 4.0 mm modeled holes compensate for horizontal FDM hole shrinkage.  An
    # ordinary 3 mm drill can clean them up if a bridge droops slightly.
    bolt_holes = [cylinder_y(-8.0, 23.0, 4.0, 18.0), cylinder_y(8.0, 23.0, 4.0, 18.0)]
    main = difference([main, *bolt_holes])
    cap = difference([cap, *pockets, *bolt_holes])

    for name, mesh in (("main", main), ("cap", cap)):
        mesh.remove_unreferenced_vertices()
        if not mesh.is_watertight or not mesh.is_winding_consistent:
            raise RuntimeError(f"{name} mesh failed manifold validation")

    # Preserve an assembly-coordinate cap for visual verification and future
    # edits, then rotate the delivered cap so its mating face prints on the bed.
    cap.export(cap_assembly_output, file_type="stl")
    cap_print = cap.copy()
    cap_print.apply_transform(trimesh.transformations.rotation_matrix(np.deg2rad(-90.0), [1.0, 0.0, 0.0]))
    cap_print.apply_translation([0.0, 0.0, -cap_print.bounds[0, 2]])

    main_output.parent.mkdir(parents=True, exist_ok=True)
    main.export(main_output, file_type="stl")
    cap_print.export(cap_output, file_type="stl")
    return main, cap_print


def main() -> None:
    folder = Path(__file__).parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=folder / "Flange v3 - Flange.stl")
    parser.add_argument("--main-output", type=Path, default=folder / "Flange v3 - Two Piece Clamp - Main.stl")
    parser.add_argument("--cap-output", type=Path, default=folder / "Flange v3 - Two Piece Clamp - Cap.stl")
    parser.add_argument(
        "--cap-assembly-output",
        type=Path,
        default=folder / "Flange v3 - Two Piece Clamp - Cap assembly orientation.stl",
    )
    args = parser.parse_args()
    main_mesh, cap_mesh = build(args.input, args.main_output, args.cap_output, args.cap_assembly_output)
    print(f"Wrote: {args.main_output}")
    print(f"Wrote: {args.cap_output}")
    print(f"Main: {len(main_mesh.faces):,} triangles, watertight={main_mesh.is_watertight}")
    print(f"Cap: {len(cap_mesh.faces):,} triangles, watertight={cap_mesh.is_watertight}")


if __name__ == "__main__":
    main()
