#!/usr/bin/env python3
"""Generate the minimal horn-switch retrofit requested for the original wheel.

The supplied steering-wheel and horn STLs are deliberately not modified.  The
retrofit adds only two printable parts:

1. a small L-shaped saddle for the existing miniature lever switch; and
2. an open electronics tray which stacks the known battery below the exact
   DigiKey SOLDERBREAD#01 board, with the component/LED side facing the horn.

All dimensions are millimetres.  STEP and STL files are exported together.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import shutil

import cadquery as cq
from cadquery import exporters
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import trimesh


ROOT = Path(__file__).resolve().parent
DEFAULT_HORN = Path("/Users/dylanang/Downloads/prints/clacson.stl")

# Full-size KW7 / Omron-V-format roller microswitch shown in IMG_4830.  The
# standard body is 27.8 x 15.9 x 10.3 mm, with two 3.1 mm holes 22.2 mm apart.
# The vertical slots allow the click point to be tuned after assembly.
SWITCH_BODY = (27.8, 10.3, 15.9)
SWITCH_HOLE_SPACING = 22.2
SWITCH_SLOT_WIDTH = 3.4
SWITCH_SLOT_LENGTH = 6.0

BRACKET_WIDTH = 35.0
BRACKET_FOOT_DEPTH = 14.0
BRACKET_PLATE_HEIGHT = 25.0
BRACKET_THICKNESS = 3.0

# Exact manufacturer drawing dimensions for DKS-SOLDERBREAD-01.
BOARD = (48.26, 50.80, 1.60)
BOARD_HOLE_DIAMETER = 3.00
BOARD_HOLE_SPACING = 38.10

# Battery envelope established by the user's earlier battery cases.
BATTERY = (67.0, 36.0, 10.0)

# Included XIAO ESP32-S3 2.4 GHz FPC antenna.  The official drawing gives a
# 37.4 x 17.5 mm adhesive flex section and a 65 mm, 1.13 mm coax lead.
ANTENNA = (37.4, 17.5, 1.8)
ANTENNA_POCKET = (40.0, 18.0, 0.6)

# The tray's 73 x 57 mm rectangle has a 92.6 mm corner-to-corner diagonal and
# therefore stays inside a nominal 98 mm steering-wheel centre envelope.
# Kept below 20 mm so it nests in the shallow centre space between the wheel
# halves instead of becoming a new, deep rear pod.
TRAY_OUTER = (73.0, 57.0, 19.2)
TRAY_WALL = 2.4
TRAY_CORNER_RADIUS = 6.0
BOARD_SUPPORT_Z = 17.2


def box(size: tuple[float, float, float], center: tuple[float, float, float]) -> cq.Workplane:
    return cq.Workplane("XY").box(*size).translate(center)


def cylinder_z(radius: float, z0: float, z1: float, x: float = 0.0, y: float = 0.0) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius, z1 - z0, cq.Vector(x, y, z0), cq.Vector(0, 0, 1)
    )
    return cq.Workplane(obj=solid)


def cylinder_y(radius: float, y0: float, y1: float, x: float, z: float) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius, y1 - y0, cq.Vector(x, y0, z), cq.Vector(0, 1, 0)
    )
    return cq.Workplane(obj=solid)


def rounded_rect(width: float, depth: float, height: float, radius: float, z0: float = 0.0) -> cq.Workplane:
    """Centered rounded rectangle extruded along +Z."""
    shape = box((width - 2 * radius, depth, height), (0, 0, z0 + height / 2))
    shape = shape.union(box((width, depth - 2 * radius, height), (0, 0, z0 + height / 2)))
    for x in (-width / 2 + radius, width / 2 - radius):
        for y in (-depth / 2 + radius, depth / 2 - radius):
            shape = shape.union(cylinder_z(radius, z0, z0 + height, x, y))
    return shape


def vertical_slot_through_y(
    x: float,
    z: float,
    length: float,
    width: float,
    y0: float,
    y1: float,
) -> cq.Workplane:
    """Capsule slot in an XZ plate, with its long axis vertical."""
    straight = length - width
    slot = box((width, y1 - y0, straight), (x, (y0 + y1) / 2, z))
    for end_z in (z - straight / 2, z + straight / 2):
        slot = slot.union(cylinder_y(width / 2, y0, y1, x, end_z))
    return slot


def build_switch_saddle() -> cq.Workplane:
    """Small screw-or-glue L bracket for the original pressable horn.

    The switch mounts on the vertical face.  Its lever hangs below the switch
    and is positioned under the original horn flange.  The original flange
    then slides past the lever during the existing spring travel.
    """
    foot = box(
        (BRACKET_WIDTH, BRACKET_FOOT_DEPTH, BRACKET_THICKNESS),
        (0, BRACKET_FOOT_DEPTH / 2, BRACKET_THICKNESS / 2),
    )
    plate = box(
        (BRACKET_WIDTH, BRACKET_THICKNESS, BRACKET_PLATE_HEIGHT),
        (0, BRACKET_THICKNESS / 2, BRACKET_THICKNESS + BRACKET_PLATE_HEIGHT / 2),
    )
    model = foot.union(plate)

    # Small end gussets keep the plate rigid without obstructing the lever.
    for x in (-BRACKET_WIDTH / 2 + 2.0, BRACKET_WIDTH / 2 - 2.0):
        gusset = (
            cq.Workplane("YZ")
            .moveTo(0.0, BRACKET_THICKNESS)
            .lineTo(BRACKET_FOOT_DEPTH - 1.0, BRACKET_THICKNESS)
            .lineTo(0.0, BRACKET_THICKNESS + 8.0)
            .close()
            .extrude(2.4)
            .translate((x - 1.2, 0, 0))
        )
        model = model.union(gusset)

    slot_z = BRACKET_THICKNESS + 12.0
    for x in (-SWITCH_HOLE_SPACING / 2, SWITCH_HOLE_SPACING / 2):
        model = model.cut(
            vertical_slot_through_y(
                x,
                slot_z,
                SWITCH_SLOT_LENGTH,
                SWITCH_SLOT_WIDTH,
                -0.5,
                BRACKET_THICKNESS + 0.5,
            )
        )

    # Optional M3 attachment holes.  The broad underside remains suitable for
    # epoxy or VHB tape if the already-printed wheel should not be drilled.
    for x in (-13.5, 13.5):
        model = model.cut(cylinder_z(1.7, -0.5, BRACKET_THICKNESS + 0.5, x, 9.5))
    return model


def build_electronics_tray() -> cq.Workplane:
    """Open tray: battery at the bottom, PCB above it, LEDs facing upward."""
    width, depth, height = TRAY_OUTER
    inner_width = width - 2 * TRAY_WALL
    inner_depth = depth - 2 * TRAY_WALL

    outer = rounded_rect(width, depth, height, TRAY_CORNER_RADIUS)
    inner = rounded_rect(
        inner_width,
        inner_depth,
        height,
        TRAY_CORNER_RADIUS - TRAY_WALL,
        TRAY_WALL,
    )
    tray = outer.cut(inner)

    # A narrow bridge passes above the 10 mm battery.  It carries the two PCB
    # screws while leaving the rest of the board open for LEDs and components.
    bridge_bottom = 13.0
    bridge = box(
        (inner_width, 4.8, BOARD_SUPPORT_Z - bridge_bottom),
        (0, 0, (bridge_bottom + BOARD_SUPPORT_Z) / 2),
    )
    tray = tray.union(bridge)
    for x in (-BOARD_HOLE_SPACING / 2, BOARD_HOLE_SPACING / 2):
        boss = cylinder_z(4.0, bridge_bottom, BOARD_SUPPORT_Z, x, 0)
        tray = tray.union(boss)
        # A 2.8 mm pilot lets a normal M3 screw form threads in the 4.2 mm
        # bridge.  Drill to 3.2 mm later if captive nuts are preferred.
        tray = tray.cut(cylinder_z(1.40, bridge_bottom - 0.5, BOARD_SUPPORT_Z + 0.5, x, 0))

    # Two external ears attach the complete tray to the original wheel with
    # only two screws.  They can instead be clipped off for adhesive mounting.
    for y in (-34.0, 34.0):
        tray = tray.union(cylinder_z(7.0, 0, TRAY_WALL, 0, y))
        connector_y = (np.sign(y) * (depth / 2 + abs(y) - 7.0) / 2)
        connector_depth = abs(y) - 7.0 - depth / 2 + 1.0
        if connector_depth > 0:
            tray = tray.union(
                box((14.0, connector_depth, TRAY_WALL), (0, connector_y, TRAY_WALL / 2))
            )
        tray = tray.cut(cylinder_z(1.7, -0.5, TRAY_WALL + 0.5, 0, y))

    # The battery slides in through the +X side after the tray is attached.
    # This avoids forcing a soft pouch cell past the fixed PCB bridge.
    tray = tray.cut(
        box((TRAY_WALL + 1.5, BATTERY[1] + 2.0, BATTERY[2] + 0.8),
            (width / 2, 0, TRAY_WALL + (BATTERY[2] + 0.8) / 2))
    )

    # Two simple strap slots retain the battery without squeezing it between
    # rigid printed features.  A 10-15 mm hook-and-loop strap is preferable to
    # a tightly pulled zip tie for a pouch cell.
    for y in (-20.5, 20.5):
        tray = tray.cut(box((18.0, 3.0, TRAY_WALL + 1.0), (0, y, TRAY_WALL / 2)))

    # Top-opening wire notch for the switch and LED leads.
    tray = tray.cut(box((TRAY_WALL + 1.5, 10.0, 8.0), (width / 2, 0, height - 4.0)))

    # Shallow adhesive landing pad for the XIAO ESP32-S3 FPC antenna.  It is
    # recessed into the *outside* of the -Y long wall, keeping the antenna away
    # from the battery and leaving the radiating face next to plastic/air.
    antenna_width, antenna_height, antenna_recess = ANTENNA_POCKET
    tray = tray.cut(
        box(
            (antenna_width, antenna_recess + 0.2, antenna_height),
            (0, -depth / 2 + antenna_recess / 2, height / 2),
        )
    )
    # Open notch over the rim for the 1.13 mm coax.  The cable can be laid into
    # the notch after the U.FL/I-PEX connector is attached to the XIAO.
    tray = tray.cut(
        box(
            (3.0, TRAY_WALL + 1.0, 4.0),
            (22.0, -depth / 2 + TRAY_WALL / 2, height - 1.0),
        )
    )
    return tray


def export_solid(shape: cq.Workplane, out: Path, stem: str) -> tuple[Path, Path]:
    stl = out / f"{stem}.stl"
    step = out / f"{stem}.step"
    exporters.export(shape, str(stl), tolerance=0.06, angularTolerance=0.12)
    exporters.export(shape, str(step))
    mesh = trimesh.load_mesh(stl, process=True)
    mesh.update_faces(mesh.nondegenerate_faces())
    mesh.remove_unreferenced_vertices()
    mesh.merge_vertices()
    mesh.fix_normals()
    mesh.export(stl)
    return stl, step


def validate(path: Path) -> None:
    mesh = trimesh.load_mesh(path, process=True)
    if not isinstance(mesh, trimesh.Trimesh) or not mesh.is_watertight:
        raise RuntimeError(f"Non-watertight output: {path}")
    print(
        f"{path.name}: extents={np.round(mesh.extents, 2).tolist()} "
        f"faces={len(mesh.faces)} watertight={mesh.is_watertight}"
    )


def draw_preview(path: Path) -> None:
    """Make an assembly-oriented drawing so the two parts are unambiguous."""
    image = Image.new("RGB", (1800, 900), "#11151b")
    draw = ImageDraw.Draw(image, "RGBA")
    font = ImageFont.load_default(size=24)
    title_font = ImageFont.load_default(size=42)
    small_font = ImageFont.load_default(size=20)
    draw.text((900, 42), "MINIMAL HORN RETROFIT", fill="white", font=title_font, anchor="mm")

    # Left panel: section through the switch and original horn flange.
    ox, oy = 100, 155
    draw.rounded_rectangle((ox, oy, ox + 700, oy + 620), radius=24, outline="#5c6673", width=3)
    draw.text((ox + 350, oy + 42), "Original horn and springs stay unchanged", fill="#c8d0da", font=font, anchor="mm")
    draw.rectangle((ox + 115, oy + 470, ox + 445, oy + 500), fill="#7cc7ff")
    draw.rectangle((ox + 115, oy + 235, ox + 145, oy + 500), fill="#7cc7ff")
    draw.rectangle((ox + 145, oy + 280, ox + 230, oy + 425), fill="#252b33", outline="white", width=3)
    draw.line((ox + 185, oy + 425, ox + 305, oy + 480, ox + 440, oy + 480), fill="#d7dce2", width=8)
    draw.rectangle((ox + 395, oy + 430, ox + 635, oy + 463), fill="#65d985")
    draw.text((ox + 570, oy + 505), "original flange slides\npast the switch lever", fill="#8ff1ad", font=small_font, anchor="mm", align="center")
    draw.line((ox + 565, oy + 250, ox + 565, oy + 405), fill="white", width=5)
    draw.polygon([(ox + 565, oy + 425), (ox + 550, oy + 398), (ox + 580, oy + 398)], fill="white")
    draw.text((ox + 565, oy + 220), "PRESS", fill="white", font=font, anchor="mm")
    draw.text((ox + 190, oy + 200), "existing switch", fill="white", font=small_font, anchor="mm")
    draw.text((ox + 350, oy + 580), "ONE SMALL ADJUSTABLE SADDLE", fill="#7cc7ff", font=font, anchor="mm")

    # Right panel: top view of the stacked electronics tray.
    ox = 1000
    draw.rounded_rectangle((ox, oy, ox + 700, oy + 620), radius=24, outline="#5c6673", width=3)
    tray_box = (ox + 150, oy + 125, ox + 550, oy + 500)
    draw.rounded_rectangle(tray_box, radius=35, fill="#7cc7ff55", outline="white", width=3)
    for cy in (oy + 90, oy + 535):
        draw.ellipse((ox + 315, cy - 35, ox + 385, cy + 35), fill="#7cc7ff88", outline="white", width=3)
        draw.ellipse((ox + 341, cy - 9, ox + 359, cy + 9), fill="#11151b", outline="white", width=2)
    draw.rectangle((ox + 165, oy + 230, ox + 535, oy + 425), fill="#f4b86077", outline="white", width=3)
    draw.rectangle((ox + 218, oy + 175, ox + 482, oy + 450), fill="#65d98599", outline="white", width=3)
    hole_y = oy + 312
    for hx in (ox + 245, ox + 455):
        draw.ellipse((hx - 8, hole_y - 8, hx + 8, hole_y + 8), fill="white")
    draw.line((ox + 245, hole_y + 30, ox + 455, hole_y + 30), fill="white", width=3)
    draw.polygon([(ox + 245, hole_y + 30), (ox + 260, hole_y + 22), (ox + 260, hole_y + 38)], fill="white")
    draw.polygon([(ox + 455, hole_y + 30), (ox + 440, hole_y + 22), (ox + 440, hole_y + 38)], fill="white")
    draw.text((ox + 350, hole_y + 52), "38.10 mm", fill="white", font=small_font, anchor="mm")
    draw.text((ox + 350, oy + 205), "48.26 × 50.80 PCB\nLED side up", fill="#d9ffe5", font=small_font, anchor="mm", align="center")
    draw.text((ox + 350, oy + 398), "67 × 36 × 10 battery below", fill="#ffe0aa", font=small_font, anchor="mm")
    draw.text((ox + 350, oy + 580), "ONE OPEN BATTERY + PCB TRAY", fill="#7cc7ff", font=font, anchor="mm")

    image.save(path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, default=ROOT / "output-minimal")
    parser.add_argument("--horn-stl", type=Path, default=DEFAULT_HORN)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    parts = {
        "minimal-switch-saddle": build_switch_saddle(),
        "minimal-battery-pcb-tray": build_electronics_tray(),
    }
    for stem, shape in parts.items():
        stl, _ = export_solid(shape, args.out, stem)
        validate(stl)
    if args.horn_stl.exists():
        unchanged_horn = args.out / "original-rounded-horn-UNCHANGED.stl"
        shutil.copy2(args.horn_stl, unchanged_horn)
        validate(unchanged_horn)
    draw_preview(args.out / "minimal-retrofit-preview.png")

    print(f"outputs={args.out.resolve()}")
    print(f"board={BOARD} mounting holes=3.00 mm at {BOARD_HOLE_SPACING:.2f} mm centres")
    print(f"battery={BATTERY} board underside z={BOARD_SUPPORT_Z:.1f} mm")


if __name__ == "__main__":
    main()
