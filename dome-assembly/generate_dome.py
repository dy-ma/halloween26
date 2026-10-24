#!/usr/bin/env python3
"""Generate a parametric 2V geodesic dome and its printed dowel hubs.

The model is a hemispherical, frequency-2 subdivision of an icosahedron with
one five-way vertex at the crown.  It produces the exact topology visible in
the paper prototype:

* 6 five-way hubs (one crown and five around the dome)
* 10 six-way hubs
* 10 four-way boundary hubs (five of each mirrored handedness)
* 30 short and 35 long struts

Dimensions are millimetres internally.  The few user-facing dimensions at the
top of the file are deliberately easy to edit.  CadQuery 2.8 or newer is
recommended.
"""

from __future__ import annotations

import argparse
import itertools
import json
import math
import os
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

import cadquery as cq
import numpy as np
from cadquery import exporters


INCH = 25.4

# ---------------------------------------------------------------------------
# Primary design parameters
# ---------------------------------------------------------------------------

# A hemisphere has height == corner-to-corner base radius.  This value makes
# the theoretical center-to-center struts 14.48 and 16.38 inches, closely
# matching the measured 14 and 16.5 inch paper members.
DOME_RADIUS = 26.5 * INCH

DOWEL_DIAMETER = 0.5 * INCH
BORE_DIAMETER_CLEARANCE = 0.60

# Each socket is a tapered tube radiating from the mathematical node center.
# The blind end keeps adjacent dowels from colliding inside the joint.
SOCKET_OUTER_LENGTH = 42.0
SOCKET_BORE_STOP = 15.0
SOCKET_ROOT_RADIUS = 10.4
SOCKET_MOUTH_RADIUS = 9.5
# Socket cones begin behind the mathematical node center.  This hidden overlap
# avoids coincident/tangent faces at the core and gives OpenCascade a much more
# reliable, mechanically stronger union.
SOCKET_ROOT_OVERLAP = 5.0

# The small central puck makes the outside face obvious and gives the printed
# joint a flat contact patch when exported in print orientation.
CORE_RADIUS = 15.0
CORE_THICKNESS = 8.0

# A #6 / 3.5 mm wood screw can retain each dowel.  Set this to False if the
# joints will be glued instead.
ADD_RETAINING_HOLES = True
RETAINING_HOLE_DIAMETER = 3.6
RETAINING_HOLE_AXIS_DISTANCE = 32.5

# Short sockets receive one shallow witness dimple near the mouth.  Long
# sockets are left smooth.  This is much easier to read during assembly than
# trying to emboss text on several differently angled surfaces.
ADD_SHORT_SOCKET_MARKS = True
SHORT_MARK_RADIUS = 1.6

# Geometry/export quality.
STL_TOLERANCE = 0.08
STL_ANGULAR_TOLERANCE = 0.12

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "output"


@dataclass(frozen=True)
class DomeGeometry:
    unit_nodes: np.ndarray
    nodes: np.ndarray
    edges: tuple[tuple[int, int], ...]
    neighbors: dict[int, tuple[int, ...]]
    edge_classes: dict[tuple[int, int], str]
    node_labels: dict[int, str]
    node_types: dict[int, str]
    representatives: dict[str, int]


def normalize(vector: Sequence[float]) -> np.ndarray:
    value = np.asarray(vector, dtype=float)
    length = float(np.linalg.norm(value))
    if length < 1.0e-12:
        raise ValueError("cannot normalize a zero vector")
    return value / length


def rotation_between(source: Sequence[float], target: Sequence[float]) -> np.ndarray:
    """Return a proper 3x3 rotation taking source onto target."""
    a = normalize(source)
    b = normalize(target)
    cross = np.cross(a, b)
    sine = float(np.linalg.norm(cross))
    cosine = float(np.dot(a, b))
    if sine < 1.0e-12:
        if cosine > 0.0:
            return np.eye(3)
        # Choose any stable axis perpendicular to a for a 180 degree turn.
        trial = np.array((1.0, 0.0, 0.0))
        if abs(float(np.dot(a, trial))) > 0.9:
            trial = np.array((0.0, 1.0, 0.0))
        axis = normalize(np.cross(a, trial))
        return 2.0 * np.outer(axis, axis) - np.eye(3)

    skew = np.array(
        (
            (0.0, -cross[2], cross[1]),
            (cross[2], 0.0, -cross[0]),
            (-cross[1], cross[0], 0.0),
        )
    )
    return np.eye(3) + skew + skew @ skew * ((1.0 - cosine) / (sine * sine))


def proper_rotation_fit(source: np.ndarray, target: np.ndarray) -> tuple[np.ndarray, float]:
    """Kabsch fit for row-vector point sets, constrained to proper rotation."""
    u, _, vt = np.linalg.svd(source.T @ target)
    rotation = vt.T @ u.T
    if np.linalg.det(rotation) < 0.0:
        vt[-1, :] *= -1.0
        rotation = vt.T @ u.T
    transformed = (rotation @ source.T).T
    error = float(np.sqrt(np.mean(np.sum((transformed - target) ** 2, axis=1))))
    return rotation, error


def best_star_rotation(
    source_directions: np.ndarray,
    target_directions: np.ndarray,
    source_normal: np.ndarray | None = None,
    target_normal: np.ndarray | None = None,
) -> tuple[np.ndarray, float]:
    """Match an unordered socket star using only proper 3D rotations."""
    if len(source_directions) != len(target_directions):
        raise ValueError("socket stars have different valence")

    best_rotation: np.ndarray | None = None
    best_error = float("inf")
    for permutation in itertools.permutations(range(len(target_directions))):
        source = source_directions
        target = target_directions[list(permutation)]
        if source_normal is not None and target_normal is not None:
            # Repeating the normal gives the printable outside face enough
            # weight to disambiguate otherwise similar star alignments.
            source = np.vstack((source, source_normal, source_normal))
            target = np.vstack((target, target_normal, target_normal))
        rotation, error = proper_rotation_fit(source, target)
        if error < best_error:
            best_rotation = rotation
            best_error = error
    assert best_rotation is not None
    return best_rotation, best_error


def make_unit_2v_hemisphere() -> tuple[np.ndarray, tuple[tuple[int, int], ...]]:
    """Construct the exact 2V icosphere and retain its northern hemisphere."""
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    original = np.array(
        [(0.0, a, b) for a in (-1.0, 1.0) for b in (-phi, phi)]
        + [(a, b, 0.0) for a in (-1.0, 1.0) for b in (-phi, phi)]
        + [(a, 0.0, b) for a in (-phi, phi) for b in (-1.0, 1.0)],
        dtype=float,
    )

    distances = np.linalg.norm(original[:, None, :] - original[None, :, :], axis=2)
    original_edge_length = float(np.min(distances[distances > 1.0e-9]))
    original_edges = {
        (i, j)
        for i in range(len(original))
        for j in range(i + 1, len(original))
        if abs(distances[i, j] - original_edge_length) < 1.0e-7
    }
    original_faces = [
        face
        for face in itertools.combinations(range(len(original)), 3)
        if all(tuple(sorted(edge)) in original_edges for edge in itertools.combinations(face, 2))
    ]
    if (len(original_edges), len(original_faces)) != (30, 20):
        raise RuntimeError("failed to construct the base icosahedron")

    top_vertex = original[int(np.argmax(original[:, 2]))]
    orientation = rotation_between(top_vertex, (0.0, 0.0, 1.0))
    original = (orientation @ original.T).T
    original /= np.linalg.norm(original, axis=1)[:, None]

    nodes = [point.copy() for point in original]
    midpoints: dict[tuple[int, int], int] = {}
    for edge in sorted(original_edges):
        midpoint = normalize(original[edge[0]] + original[edge[1]])
        midpoints[edge] = len(nodes)
        nodes.append(midpoint)

    subdivided_faces: list[tuple[int, int, int]] = []
    for a, b, c in original_faces:
        ab = midpoints[tuple(sorted((a, b)))]
        bc = midpoints[tuple(sorted((b, c)))]
        ca = midpoints[tuple(sorted((c, a)))]
        subdivided_faces.extend(((a, ab, ca), (b, bc, ab), (c, ca, bc), (ab, bc, ca)))

    all_edges = {
        tuple(sorted(edge))
        for face in subdivided_faces
        for edge in itertools.combinations(face, 2)
    }
    unit_nodes = np.asarray(nodes)
    retained = {index for index, point in enumerate(unit_nodes) if point[2] >= -1.0e-9}
    retained_edges = tuple(sorted(edge for edge in all_edges if set(edge) <= retained))

    # Compact indices make manifests and preview labels much easier to use.
    ordered_old_indices = sorted(
        retained,
        key=lambda index: (
            -round(float(unit_nodes[index, 2]), 9),
            math.atan2(float(unit_nodes[index, 1]), float(unit_nodes[index, 0])),
        ),
    )
    remap = {old: new for new, old in enumerate(ordered_old_indices)}
    compact_nodes = unit_nodes[ordered_old_indices]
    compact_edges = tuple(sorted(tuple(sorted((remap[a], remap[b]))) for a, b in retained_edges))
    return compact_nodes, compact_edges


def socket_directions(geometry: DomeGeometry, node_index: int) -> np.ndarray:
    point = geometry.unit_nodes[node_index]
    return np.array(
        [normalize(geometry.unit_nodes[neighbor] - point) for neighbor in geometry.neighbors[node_index]]
    )


def classify_geometry(radius: float) -> DomeGeometry:
    unit_nodes, edges = make_unit_2v_hemisphere()
    neighbors_mutable: dict[int, list[int]] = defaultdict(list)
    lengths: dict[tuple[int, int], float] = {}
    for a, b in edges:
        neighbors_mutable[a].append(b)
        neighbors_mutable[b].append(a)
        lengths[(a, b)] = float(np.linalg.norm(unit_nodes[a] - unit_nodes[b]))
    neighbors = {index: tuple(sorted(values)) for index, values in neighbors_mutable.items()}

    unique_lengths = sorted({round(value, 9) for value in lengths.values()})
    if len(unique_lengths) != 2:
        raise RuntimeError(f"expected two strut lengths, found {unique_lengths}")
    split = sum(unique_lengths) / 2.0
    edge_classes = {edge: ("short" if value < split else "long") for edge, value in lengths.items()}

    node_labels = {index: f"N{index + 1:02d}" for index in range(len(unit_nodes))}
    degrees = {index: len(neighbors[index]) for index in range(len(unit_nodes))}
    if Counter(degrees.values()) != Counter({4: 10, 5: 6, 6: 10}):
        raise RuntimeError(f"unexpected dome topology: {Counter(degrees.values())}")

    node_types: dict[int, str] = {}
    representatives: dict[str, int] = {}
    for degree in (5, 6):
        indices = [index for index, value in degrees.items() if value == degree]
        representative = indices[0]
        name = f"{degree}-way"
        representatives[name] = representative
        node_types.update({index: name for index in indices})

    # The bottom stars share a Gram matrix but alternate chirality.  A proper
    # rotation cannot superimpose them, hence the A/B mirrored print files.
    boundary = [index for index, value in degrees.items() if value == 4]
    rep_a = boundary[0]
    rep_a_directions = np.array(
        [normalize(unit_nodes[n] - unit_nodes[rep_a]) for n in neighbors[rep_a]]
    )
    group_a: list[int] = []
    group_b: list[int] = []
    for index in boundary:
        directions = np.array([normalize(unit_nodes[n] - unit_nodes[index]) for n in neighbors[index]])
        _, error = best_star_rotation(rep_a_directions, directions)
        (group_a if error < 1.0e-6 else group_b).append(index)
    if (len(group_a), len(group_b)) != (5, 5):
        raise RuntimeError(f"unexpected boundary handedness: {len(group_a)} / {len(group_b)}")
    rep_b = group_b[0]
    representatives["4-way-A"] = rep_a
    representatives["4-way-B"] = rep_b
    node_types.update({index: "4-way-A" for index in group_a})
    node_types.update({index: "4-way-B" for index in group_b})

    return DomeGeometry(
        unit_nodes=unit_nodes,
        nodes=unit_nodes * radius,
        edges=edges,
        neighbors=neighbors,
        edge_classes=edge_classes,
        node_labels=node_labels,
        node_types=node_types,
        representatives=representatives,
    )


def cq_vector(value: Sequence[float]) -> cq.Vector:
    return cq.Vector(float(value[0]), float(value[1]), float(value[2]))


def solid_workplane(solid: cq.Solid) -> cq.Workplane:
    return cq.Workplane(obj=solid)


def cylinder_along(
    radius: float,
    length: float,
    start: Sequence[float],
    direction: Sequence[float],
) -> cq.Workplane:
    return solid_workplane(cq.Solid.makeCylinder(radius, length, cq_vector(start), cq_vector(direction)))


def cone_along(
    radius_a: float,
    radius_b: float,
    length: float,
    start: Sequence[float],
    direction: Sequence[float],
) -> cq.Workplane:
    return solid_workplane(
        cq.Solid.makeCone(radius_a, radius_b, length, cq_vector(start), cq_vector(direction))
    )


def accessible_normal(node_normal: np.ndarray, socket_direction: np.ndarray) -> np.ndarray:
    """Outside-facing direction perpendicular to one socket axis."""
    projected = node_normal - np.dot(node_normal, socket_direction) * socket_direction
    return normalize(projected)


def build_hub(
    node_normal: np.ndarray,
    directions: np.ndarray,
    socket_classes: Sequence[str],
) -> cq.Workplane:
    """Build one concave star hub in the supplied coordinate frame."""
    node_normal = normalize(node_normal)
    bore_radius = (DOWEL_DIAMETER + BORE_DIAMETER_CLEARANCE) / 2.0

    core_start = -node_normal * (CORE_THICKNESS / 2.0)
    model = cylinder_along(CORE_RADIUS, CORE_THICKNESS, core_start, node_normal)

    for direction in directions:
        model = model.union(
            cone_along(
                SOCKET_ROOT_RADIUS,
                SOCKET_MOUTH_RADIUS,
                SOCKET_OUTER_LENGTH + SOCKET_ROOT_OVERLAP,
                -direction * SOCKET_ROOT_OVERLAP,
                direction,
            )
        )
    model = model.clean()

    for direction in directions:
        bore_start = direction * SOCKET_BORE_STOP
        bore_length = SOCKET_OUTER_LENGTH - SOCKET_BORE_STOP + 2.0
        model = model.cut(cylinder_along(bore_radius, bore_length, bore_start, direction))

    if ADD_RETAINING_HOLES:
        for direction in directions:
            outside = accessible_normal(node_normal, direction)
            axis_point = direction * RETAINING_HOLE_AXIS_DISTANCE
            cutter_start = axis_point + outside * (SOCKET_ROOT_RADIUS + 1.5)
            cutter_length = SOCKET_ROOT_RADIUS - bore_radius + 4.0
            model = model.cut(
                cylinder_along(
                    RETAINING_HOLE_DIAMETER / 2.0,
                    cutter_length,
                    cutter_start,
                    -outside,
                )
            )

    if ADD_SHORT_SOCKET_MARKS:
        for direction, edge_class in zip(directions, socket_classes):
            if edge_class != "short":
                continue
            outside = accessible_normal(node_normal, direction)
            center = direction * (SOCKET_OUTER_LENGTH - 2.7) + outside * (SOCKET_MOUTH_RADIUS - 0.7)
            dimple = cq.Workplane("XY").sphere(SHORT_MARK_RADIUS).translate(tuple(center))
            model = model.cut(dimple)

    return model.clean()


def transform_workplane(model: cq.Workplane, rotation: np.ndarray, translation: np.ndarray) -> cq.Workplane:
    # A rigid placement preserves analytic circles/planes. transformGeometry
    # unnecessarily converts them to splines, bloating STEP and mesh exports.
    frame = cq.Plane(
        origin=cq_vector(translation),
        xDir=cq_vector(rotation[:, 0]),
        normal=cq_vector(rotation[:, 2]),
    )
    return cq.Workplane(obj=model.val().moved(cq.Location(frame)))


def move_to_print_orientation(model: cq.Workplane, node_normal: np.ndarray) -> cq.Workplane:
    rotation = rotation_between(node_normal, (0.0, 0.0, -1.0))
    oriented = transform_workplane(model, rotation, np.zeros(3))
    minimum_z = oriented.val().BoundingBox().zmin
    return oriented.translate((0.0, 0.0, -minimum_z))


def build_fit_gauge() -> cq.Workplane:
    """Three upright sockets for checking real dowel and printer variation."""
    clearances = (0.30, 0.60, 0.90)
    outer_radius = 10.0
    height = 25.0
    pitch = 24.0
    base = cq.Workplane("XY").box(68.0, 24.0, 2.4).translate((0.0, 0.0, 1.2))
    model = base
    for index, clearance in enumerate(clearances):
        x = (index - 1) * pitch
        sleeve = cq.Workplane("XY").center(x, 0.0).circle(outer_radius).extrude(height)
        bore = cq.Workplane("XY").center(x, 0.0).circle((DOWEL_DIAMETER + clearance) / 2.0).extrude(height + 1.0)
        model = model.union(sleeve).cut(bore)
    return model.clean()


def representative_data(
    geometry: DomeGeometry, type_name: str
) -> tuple[int, np.ndarray, np.ndarray, list[str]]:
    index = geometry.representatives[type_name]
    directions = socket_directions(geometry, index)
    classes = [
        geometry.edge_classes[tuple(sorted((index, neighbor)))] for neighbor in geometry.neighbors[index]
    ]
    return index, geometry.unit_nodes[index], directions, classes


def validate_solid(name: str, model: cq.Workplane) -> None:
    solids = model.solids().vals()
    if len(solids) != 1:
        raise RuntimeError(f"{name}: expected one solid, found {len(solids)}")
    if not solids[0].isValid():
        raise RuntimeError(f"{name}: OpenCascade reports an invalid solid")
    bounds = solids[0].BoundingBox()
    print(
        f"{name}: valid, volume={solids[0].Volume() / 1000.0:.1f} cm^3, "
        f"size={bounds.xlen:.1f} x {bounds.ylen:.1f} x {bounds.zlen:.1f} mm"
    )


def export_part(model: cq.Workplane, stem: str) -> None:
    exporters.export(model, str(OUTPUT / f"{stem}.step"), exportType="STEP")
    exporters.export(
        model,
        str(OUTPUT / f"{stem}.stl"),
        exportType="STL",
        tolerance=STL_TOLERANCE,
        angularTolerance=STL_ANGULAR_TOLERANCE,
    )


def rod_between(start: np.ndarray, end: np.ndarray, radius: float) -> cq.Workplane:
    vector = end - start
    length = float(np.linalg.norm(vector))
    return cylinder_along(radius, length, start, vector / length)


def build_full_assembly(
    geometry: DomeGeometry,
    representative_models: dict[str, cq.Workplane],
) -> cq.Assembly:
    assembly = cq.Assembly(name="2V_dowel_dome")

    for edge_index, (a, b) in enumerate(geometry.edges, start=1):
        direction = normalize(geometry.nodes[b] - geometry.nodes[a])
        start = geometry.nodes[a] + direction * SOCKET_BORE_STOP
        end = geometry.nodes[b] - direction * SOCKET_BORE_STOP
        edge_class = geometry.edge_classes[(a, b)]
        color = cq.Color(0.25, 0.55, 0.95) if edge_class == "short" else cq.Color(0.95, 0.60, 0.12)
        assembly.add(
            rod_between(start, end, DOWEL_DIAMETER / 2.0),
            name=f"{edge_class}_rod_{edge_index:02d}_{geometry.node_labels[a]}_{geometry.node_labels[b]}",
            color=color,
        )

    type_colors = {
        "4-way-A": cq.Color(0.30, 0.30, 0.30),
        "4-way-B": cq.Color(0.48, 0.48, 0.48),
        "5-way": cq.Color(0.70, 0.20, 0.20),
        "6-way": cq.Color(0.25, 0.65, 0.30),
    }
    for node_index in range(len(geometry.nodes)):
        type_name = geometry.node_types[node_index]
        rep_index = geometry.representatives[type_name]
        rep_directions = socket_directions(geometry, rep_index)
        target_directions = socket_directions(geometry, node_index)
        rotation, error = best_star_rotation(
            rep_directions,
            target_directions,
            geometry.unit_nodes[rep_index],
            geometry.unit_nodes[node_index],
        )
        if error > 1.0e-6:
            raise RuntimeError(
                f"cannot place {type_name} at {geometry.node_labels[node_index]}: fit error {error}"
            )
        placed = transform_workplane(representative_models[type_name], rotation, geometry.nodes[node_index])
        assembly.add(
            placed,
            name=f"{geometry.node_labels[node_index]}_{type_name}",
            color=type_colors[type_name],
        )
    return assembly


def build_manifest(geometry: DomeGeometry) -> dict[str, object]:
    edge_rows: list[dict[str, object]] = []
    class_lengths: dict[str, list[float]] = defaultdict(list)
    for index, (a, b) in enumerate(geometry.edges, start=1):
        center_length = float(np.linalg.norm(geometry.nodes[b] - geometry.nodes[a]))
        cut_length = center_length - 2.0 * SOCKET_BORE_STOP
        edge_class = geometry.edge_classes[(a, b)]
        class_lengths[edge_class].append(center_length)
        edge_rows.append(
            {
                "edge": f"E{index:02d}",
                "from": geometry.node_labels[a],
                "to": geometry.node_labels[b],
                "class": edge_class,
                "center_to_center_mm": round(center_length, 3),
                "center_to_center_in": round(center_length / INCH, 4),
                "dowel_cut_mm": round(cut_length, 3),
                "dowel_cut_in": round(cut_length / INCH, 4),
            }
        )

    strut_summary = {}
    for edge_class in ("short", "long"):
        center_length = float(np.mean(class_lengths[edge_class]))
        strut_summary[edge_class] = {
            "quantity": len(class_lengths[edge_class]),
            "center_to_center_mm": round(center_length, 3),
            "center_to_center_in": round(center_length / INCH, 4),
            "dowel_cut_mm": round(center_length - 2.0 * SOCKET_BORE_STOP, 3),
            "dowel_cut_in": round((center_length - 2.0 * SOCKET_BORE_STOP) / INCH, 4),
        }

    node_rows = []
    for index, point in enumerate(geometry.nodes):
        node_rows.append(
            {
                "node": geometry.node_labels[index],
                "joint": geometry.node_types[index],
                "xyz_mm": [round(float(value), 3) for value in point],
                "neighbors": [geometry.node_labels[value] for value in geometry.neighbors[index]],
            }
        )

    return {
        "design": {
            "name": "2V hemispherical dowel dome",
            "sphere_radius_mm": round(DOME_RADIUS, 3),
            "height_in": round(DOME_RADIUS / INCH, 4),
            "base_corner_to_corner_in": round(2.0 * DOME_RADIUS / INCH, 4),
            "base_flat_to_flat_in": round(2.0 * DOME_RADIUS * math.cos(math.pi / 10.0) / INCH, 4),
            "dowel_nominal_diameter_in": round(DOWEL_DIAMETER / INCH, 4),
            "bore_diameter_mm": round(DOWEL_DIAMETER + BORE_DIAMETER_CLEARANCE, 3),
            "socket_insertion_mm": round(SOCKET_OUTER_LENGTH - SOCKET_BORE_STOP, 3),
        },
        "joint_quantities": dict(sorted(Counter(geometry.node_types.values()).items())),
        "struts": strut_summary,
        "nodes": node_rows,
        "edges": edge_rows,
    }


def write_cut_list(manifest: dict[str, object]) -> None:
    design = manifest["design"]
    struts = manifest["struts"]
    joints = manifest["joint_quantities"]
    lines = [
        "# Generated dome cut list",
        "",
        f"- Finished height: **{design['height_in']:.2f} in**",
        f"- Base corner-to-corner: **{design['base_corner_to_corner_in']:.2f} in**",
        f"- Base flat-to-flat: **{design['base_flat_to_flat_in']:.2f} in**",
        f"- Dowel diameter: **{design['dowel_nominal_diameter_in']:.3f} in**",
        f"- Socket insertion: **{design['socket_insertion_mm']:.1f} mm**",
        "",
        "## Dowel cuts",
        "",
        "The cut lengths include the blind insertion into both printed hubs. The",
        "center-to-center values are the equivalent paper-arm measurements.",
        "",
    ]
    for edge_class in ("short", "long"):
        row = struts[edge_class]
        lines.append(
            f"- **{row['quantity']} × {edge_class}: {row['dowel_cut_in']:.3f} in "
            f"({row['dowel_cut_mm']:.1f} mm)** — node centers {row['center_to_center_in']:.3f} in apart"
        )
    lines.extend(("", "## Printed hubs", ""))
    for joint_name in ("4-way-A", "4-way-B", "5-way", "6-way"):
        lines.append(f"- **{joints[joint_name]} × {joint_name}**")
    lines.extend(
        (
            "",
            "Short sockets have one shallow dimple near the mouth; long sockets are smooth.",
            "The A/B boundary hubs alternate around the decagonal base.",
            "",
            "Print the fit gauge before committing to all 26 hubs. Its three sockets are",
            "0.30, 0.60, and 0.90 mm oversize from left to right.",
            "",
        )
    )
    (OUTPUT / "CUT-LIST.md").write_text("\n".join(lines), encoding="utf-8")


def write_preview(geometry: DomeGeometry, manifest: dict[str, object]) -> None:
    # Keep matplotlib's cache inside the generated-output folder rather than
    # touching the user's home directory.
    os.environ.setdefault("MPLCONFIGDIR", str(OUTPUT / ".matplotlib-cache"))
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D

    inches = geometry.nodes / INCH
    figure = plt.figure(figsize=(14, 7.5), constrained_layout=True)
    side = figure.add_subplot(1, 2, 1, projection="3d")
    top = figure.add_subplot(1, 2, 2)
    colors = {"short": "#3b82f6", "long": "#f59e0b"}

    for a, b in geometry.edges:
        edge_class = geometry.edge_classes[(a, b)]
        segment = inches[[a, b]]
        side.plot(segment[:, 0], segment[:, 1], segment[:, 2], color=colors[edge_class], lw=2.0)
        top.plot(segment[:, 0], segment[:, 1], color=colors[edge_class], lw=1.8)

    node_colors = {
        "4-way-A": "#1f2937",
        "4-way-B": "#9ca3af",
        "5-way": "#dc2626",
        "6-way": "#16a34a",
    }
    for index, point in enumerate(inches):
        color = node_colors[geometry.node_types[index]]
        side.scatter(*point, color=color, s=24, depthshade=False)
        top.scatter(point[0], point[1], color=color, s=22, zorder=3)
        top.text(point[0] + 0.35, point[1] + 0.25, geometry.node_labels[index], fontsize=6.5)

    side.set_title("Assembled 2V dome")
    side.set_xlabel("X (in)")
    side.set_ylabel("Y (in)")
    side.set_zlabel("height (in)")
    side.view_init(elev=18, azim=-58)
    side.set_box_aspect((2, 2, 1))
    top.set_title("Top view / node map")
    top.set_xlabel("X (in)")
    top.set_ylabel("Y (in)")
    top.set_aspect("equal", adjustable="box")
    top.grid(alpha=0.2)

    handles = [
        Line2D([0], [0], color=colors["short"], lw=3, label="short strut"),
        Line2D([0], [0], color=colors["long"], lw=3, label="long strut"),
    ] + [
        Line2D([0], [0], marker="o", linestyle="", color=color, label=name)
        for name, color in node_colors.items()
    ]
    figure.legend(handles=handles, loc="lower center", ncol=6, frameon=False)
    summary = manifest["struts"]
    figure.suptitle(
        "½-inch dowel dome — "
        f"{summary['short']['quantity']} short @ {summary['short']['center_to_center_in']:.2f} in c-c, "
        f"{summary['long']['quantity']} long @ {summary['long']['center_to_center_in']:.2f} in c-c",
        fontsize=14,
    )
    figure.savefig(OUTPUT / "dome-assembly-preview.png", dpi=220)
    plt.close(figure)


def generate(radius: float) -> None:
    global DOME_RADIUS
    DOME_RADIUS = radius
    OUTPUT.mkdir(parents=True, exist_ok=True)
    geometry = classify_geometry(radius)

    print(f"Dome: {len(geometry.nodes)} nodes, {len(geometry.edges)} struts")
    print(f"Joint counts: {dict(sorted(Counter(geometry.node_types.values()).items()))}")
    print(f"Strut counts: {dict(sorted(Counter(geometry.edge_classes.values()).items()))}")

    representative_models: dict[str, cq.Workplane] = {}
    for type_name in ("4-way-A", "4-way-B", "5-way", "6-way"):
        _, normal, directions, classes = representative_data(geometry, type_name)
        model = build_hub(normal, directions, classes)
        validate_solid(type_name, model)
        representative_models[type_name] = model
        print_model = move_to_print_orientation(model, normal)
        export_part(print_model, f"hub-{type_name}")

    gauge = build_fit_gauge()
    validate_solid("fit gauge", gauge)
    export_part(gauge, "half-inch-dowel-fit-gauge")

    assembly = build_full_assembly(geometry, representative_models)
    assembly.save(str(OUTPUT / "dome-full-assembly.step"), exportType="STEP")

    manifest = build_manifest(geometry)
    (OUTPUT / "build-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    write_cut_list(manifest)
    write_preview(geometry, manifest)

    print(f"Generated dome files in {OUTPUT}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--radius-in",
        type=float,
        default=DOME_RADIUS / INCH,
        help="hemisphere radius/height in inches (default: %(default)s)",
    )
    arguments = parser.parse_args()
    if arguments.radius_in <= 0.0:
        parser.error("--radius-in must be positive")
    generate(arguments.radius_in * INCH)


if __name__ == "__main__":
    main()
