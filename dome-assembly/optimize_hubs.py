#!/usr/bin/env python3
"""Compare compact, flat-bottom dowel hubs against filled polygon hubs.

Uses the same node centers and blind stops as generate_dome.py, so the dome
and dowel cut lengths are unchanged. The parts are constructed in print
coordinates, then rotated back into the assembly as needed.
"""
from __future__ import annotations

import argparse
import json
import math
import os
from pathlib import Path

import cadquery as cq
import numpy as np
from scipy.spatial import ConvexHull

import generate_dome as dome

OUT = Path(__file__).resolve().parent / "optimized"
MOUTH_DISTANCE = 33.0
WALL = 2.4
BORE_RADIUS = (dome.DOWEL_DIAMETER + dome.BORE_DIAMETER_CLEARANCE) / 2
HALF_WIDTH = BORE_RADIUS + WALL
FLOOR = -4.8
HEIGHT = 28.0
STOP = dome.SOCKET_BORE_STOP


def print_frame(normal, directions):
    rotation = dome.rotation_between(normal, (0, 0, -1))
    return rotation, (rotation @ directions.T).T


def footprint(directions):
    points = []
    for direction in directions:
        radial = dome.normalize((direction[0], direction[1], 0))
        side = np.array((-radial[1], radial[0], 0))
        end = direction * MOUTH_DISTANCE
        for along in (0.0, 1.0):
            for sign in (-1, 1):
                point = end * along + side * HALF_WIDTH * sign
                points.append(point[:2])
    return np.asarray(points)


def body(directions, style):
    if style == "polygon":
        points = footprint(directions)
        hull = ConvexHull(points)
        outline = [tuple(point) for point in points[hull.vertices]]
        model = cq.Workplane("XY").polyline(outline).close().extrude(HEIGHT).translate((0, 0, FLOOR))
    elif style in ("star", "rib"):
        model = cq.Workplane("XY").circle(11).extrude(12).translate((0, 0, FLOOR))
        for direction in directions:
            radial = dome.normalize((direction[0], direction[1], 0))
            side = np.array((-radial[1], radial[0], 0))
            horizontal = float(np.linalg.norm(direction[:2]))
            end = horizontal * MOUTH_DISTANCE
            rise = direction[2] / horizontal
            roof = BORE_RADIUS * math.sqrt(2) / horizontal + WALL
            # A sloping outer roof follows each socket instead of filling a
            # tall block all the way down to the node center.
            if style == "rib":
                # Outer 45-degree roof follows the inner teardrop roof. This
                # removes the bulky rectangular roof corners of the star.
                roof = (BORE_RADIUS + WALL) * math.sqrt(2) / horizontal
                wires = []
                for x in (0, end):
                    peak = roof + rise * x
                    shoulder = peak - HALF_WIDTH / horizontal
                    plane = cq.Plane(origin=dome.cq_vector(radial*x), xDir=dome.cq_vector(side), normal=dome.cq_vector(radial))
                    wires.append(cq.Workplane(plane).polyline([(-HALF_WIDTH,FLOOR),(HALF_WIDTH,FLOOR),(HALF_WIDTH,shoulder),(0,peak),(-HALF_WIDTH,shoulder)]).close().val())
                arm = cq.Workplane(obj=cq.Solid.makeLoft(wires, ruled=True))
            else:
                plane = cq.Plane(origin=dome.cq_vector(side * HALF_WIDTH), xDir=dome.cq_vector(radial), normal=dome.cq_vector(-side))
                arm = cq.Workplane(plane).polyline([(0, FLOOR), (end, FLOOR), (end, roof + rise * end), (0, roof)]).close().extrude(2 * HALF_WIDTH)
            model = model.union(arm)
        model = model.clean()
    else:
        raise ValueError(style)
    # Rounding vertical edges gives a clean footprint without changing the
    # flat bed face or introducing unsupported undersides.
    if style == "polygon":
        return model.edges("|Z").fillet(1.2).clean()
    return model.clean()


def bore_cutter(direction):
    outside = dome.accessible_normal(np.array((0, 0, -1.0)), direction)
    up = -outside
    sideways = dome.normalize(np.cross(direction, up))
    plane = cq.Plane(origin=dome.cq_vector(direction * STOP), xDir=dome.cq_vector(sideways), normal=dome.cq_vector(direction))
    # Choose the positive local Y direction to point toward the print roof.
    if np.dot(np.array(plane.yDir.toTuple()), up) < 0:
        plane = cq.Plane(origin=dome.cq_vector(direction * STOP), xDir=dome.cq_vector(-sideways), normal=dome.cq_vector(direction))
    length = MOUTH_DISTANCE - STOP + 4
    circle = cq.Workplane(plane).circle(BORE_RADIUS).extrude(length)
    tangent = BORE_RADIUS / math.sqrt(2)
    roof = (
        cq.Workplane(plane)
        .polyline([(-tangent, tangent), (0, BORE_RADIUS * math.sqrt(2)), (tangent, tangent)])
        .close().extrude(length)
    )
    return circle.union(roof).clean()


def build(directions, style):
    model = body(directions, style)
    for direction in directions:
        model = model.cut(bore_cutter(direction))
    # Vertical screw access prints as a vertical hole, without an internal
    # support pocket. Predrill the wood through it before fitting a screw.
    for direction in directions:
        point = direction * 25.5
        model = model.cut(dome.cylinder_along(1.8, HEIGHT, (point[0], point[1], point[2]), (0, 0, 1)))
    return model.clean().translate((0, 0, -FLOOR))


def export(model, path):
    cq.exporters.export(model, str(path.with_suffix(".step")))
    cq.exporters.export(model, str(path.with_suffix(".stl")), tolerance=0.06, angularTolerance=0.12)


def render(models, title="Flat-bottom prototypes — actual surfaces, triangle edges hidden"):
    os.environ.setdefault("MPLCONFIGDIR", "/private/tmp/dome-matplotlib")
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    figure = plt.figure(figsize=(12, 8), constrained_layout=True)
    for index, (name, model) in enumerate(models.items(), 1):
        vertices, triangles = model.val().tessellate(0.18, 0.18)
        vertices = np.array([vertex.toTuple() for vertex in vertices])
        faces = vertices[np.asarray(triangles)]
        normals = np.cross(faces[:, 1] - faces[:, 0], faces[:, 2] - faces[:, 0])
        normals /= np.maximum(np.linalg.norm(normals, axis=1)[:, None], 1e-12)
        light = dome.normalize((-0.4, -0.5, 1))
        shade = 0.5 + 0.5 * np.maximum(normals @ light, 0)
        color = np.array((0.24, 0.55, 0.71)) if "polygon" not in name else np.array((0.86, 0.55, 0.23))
        colors = shade[:, None] * color
        # A real depth buffer prevents matplotlib's triangle painter from
        # showing hidden edges/surfaces through holes and broad flat faces.
        camera = dome.normalize((0.35, -0.85, 0.5))
        right = dome.normalize(np.cross((0, 0, 1), camera))
        up = np.cross(camera, right)
        projection = np.array((right, up, camera))
        projected = vertices @ projection.T
        span = max(np.ptp(projected[:, 0]), np.ptp(projected[:, 1]))
        size = 800
        scale = (size - 70) / span
        projected[:, 0] = (projected[:, 0] - (projected[:, 0].min() + projected[:, 0].max())/2) * scale + size/2
        projected[:, 1] = size/2 - (projected[:, 1] - (projected[:, 1].min() + projected[:, 1].max())/2) * scale
        depth = np.full((size, size), -np.inf)
        pixels = np.full((size, size, 3), 255, dtype=np.uint8)
        for triangle, face_color in zip(triangles, colors):
            points = projected[list(triangle)]
            xmin = max(0, int(np.floor(points[:, 0].min())))
            xmax = min(size - 1, int(np.ceil(points[:, 0].max())))
            ymin = max(0, int(np.floor(points[:, 1].min())))
            ymax = min(size - 1, int(np.ceil(points[:, 1].max())))
            if xmax < xmin or ymax < ymin:
                continue
            a, b, c = points
            denominator = (b[1]-c[1])*(a[0]-c[0]) + (c[0]-b[0])*(a[1]-c[1])
            if abs(denominator) < 1e-9:
                continue
            xx, yy = np.meshgrid(np.arange(xmin, xmax+1)+0.5, np.arange(ymin, ymax+1)+0.5)
            wa = ((b[1]-c[1])*(xx-c[0])+(c[0]-b[0])*(yy-c[1]))/denominator
            wb = ((c[1]-a[1])*(xx-c[0])+(a[0]-c[0])*(yy-c[1]))/denominator
            wc = 1-wa-wb
            z = wa*a[2]+wb*b[2]+wc*c[2]
            region = depth[ymin:ymax+1, xmin:xmax+1]
            mask = (wa >= -1e-7) & (wb >= -1e-7) & (wc >= -1e-7) & (z > region)
            region[mask] = z[mask]
            pixels[ymin:ymax+1, xmin:xmax+1][mask] = np.clip(face_color*255, 0, 255).astype(np.uint8)
        axis = figure.add_subplot(2, 2, index)
        axis.imshow(pixels)
        bounds = model.val().BoundingBox()
        axis.set_title(f"{name}\n{model.val().Volume()/1000:.1f} cm³, {bounds.zlen:.0f} mm tall")
        axis.set_axis_off()
    figure.suptitle(title, fontsize=15)
    figure.savefig(OUT / "design-comparison.png", dpi=180)
    plt.close(figure)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--all", action="store_true", help="export all four hub families")
    parser.add_argument("--styles", nargs="+", default=["star", "polygon"])
    parser.add_argument("--assembly", action="store_true", help="export rib-hub assembly; requires --all --styles rib")
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    geometry = dome.classify_geometry(dome.DOME_RADIUS)
    rows = []
    previews = {}
    representatives = {}
    kinds = ("4-way-A", "4-way-B", "5-way", "6-way") if args.all else ("5-way", "6-way")
    for kind in kinds:
        _, normal, directions, _ = dome.representative_data(geometry, kind)
        rotation, local = print_frame(normal, directions)
        for style in args.styles:
            model = build(local, style)
            name = f"{style}-{kind}"
            dome.validate_solid(name, model)
            export(model, OUT / name)
            rows.append({"name": name, "volume_cm3": model.val().Volume()/1000, "height_mm": model.val().BoundingBox().zlen})
            if style == "rib":
                representatives[kind] = dome.transform_workplane(model.translate((0, 0, FLOOR)), rotation.T, np.zeros(3))
            if kind in ("5-way", "6-way") or args.styles == ["rib"]:
                previews[name] = model
    render(previews)
    (OUT / "comparison.json").write_text(json.dumps(rows, indent=2) + "\n")
    if "rib" in args.styles:
        # One tilted socket tests the actual 0.8 mm print orientation and
        # roof shape before committing to a batch of 26 hubs.
        angle = math.radians(18)
        coupon = build(np.array([(math.cos(angle), 0, math.sin(angle))]), "rib")
        dome.validate_solid("angled socket test", coupon)
        export(coupon, OUT / "angled-socket-test")
    if args.assembly:
        if len(representatives) != 4:
            parser.error("--assembly needs --all and the rib style")
        assembly = dome.build_full_assembly(geometry, representatives)
        assembly.export(str(OUT / "dome-optimized-assembly.step"), exportType="STEP")
        print("Exported optimized assembly", flush=True)


if __name__ == "__main__":
    main()
