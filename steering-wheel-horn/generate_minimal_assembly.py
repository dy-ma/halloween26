#!/usr/bin/env python3
"""Build assembled and exploded references for the minimal horn retrofit.

This is a visualization/fit-reference assembly, not a one-piece print.  It
places the original supplied wheel halves and rounded horn together with the
new switch saddle and battery/PCB tray in one coordinate system.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont
import trimesh


ROOT = Path(__file__).resolve().parent.parent
SOURCE_UPPER = Path("/Users/dylanang/Downloads/prints/STERZO SOPRA.stl")
SOURCE_LOWER = Path("/Users/dylanang/Downloads/prints/STERZO SOTTA.stl")
SOURCE_HORN = Path("/Users/dylanang/Downloads/prints/clacson.stl")
OUTPUT = ROOT / "output/steering-wheel/minimal"

# Assembly Z=0 is the wheel-half mating plane.  +Z points toward the driver /
# rounded horn face; -Z points toward the rear wheel half.
TRAY_BOTTOM_Z = -25.8
BRACKET_RADIAL_Y = 42.5


@dataclass
class Part:
    name: str
    mesh: trimesh.Trimesh
    color: tuple[int, int, int, int]


def load_centered(path: Path) -> trimesh.Trimesh:
    mesh = trimesh.load_mesh(path, process=True)
    if not isinstance(mesh, trimesh.Trimesh):
        raise TypeError(f"Expected one mesh in {path}")
    mesh.apply_translation((-mesh.bounds.mean(axis=0)[0], -mesh.bounds.mean(axis=0)[1], 0))
    mesh.apply_translation((0, 0, -mesh.bounds[0, 2]))
    return mesh


def colored(mesh: trimesh.Trimesh, rgba: tuple[int, int, int, int]) -> trimesh.Trimesh:
    mesh = mesh.copy()
    mesh.visual.face_colors = np.tile(np.asarray(rgba, dtype=np.uint8), (len(mesh.faces), 1))
    return mesh


def mirror_z(mesh: trimesh.Trimesh) -> trimesh.Trimesh:
    mesh = mesh.copy()
    transform = np.eye(4)
    transform[2, 2] = -1
    mesh.apply_transform(transform)
    # Reflection reverses handedness.
    mesh.faces = np.fliplr(mesh.faces)
    mesh.fix_normals()
    return mesh


def box_mesh(size: tuple[float, float, float], center: tuple[float, float, float]) -> trimesh.Trimesh:
    mesh = trimesh.creation.box(extents=size)
    mesh.apply_translation(center)
    return mesh


def rod_between(start: tuple[float, float, float], end: tuple[float, float, float], radius: float) -> trimesh.Trimesh:
    start_v = np.asarray(start, dtype=float)
    end_v = np.asarray(end, dtype=float)
    vector = end_v - start_v
    rod = trimesh.creation.cylinder(radius=radius, height=float(np.linalg.norm(vector)), sections=24)
    rod.apply_transform(trimesh.geometry.align_vectors([0, 0, 1], vector))
    rod.apply_translation((start_v + end_v) / 2)
    return rod


def spring_mesh(center_xy: tuple[float, float], z_bottom: float = -8.4,
                z_top: float = -2.2, radius: float = 3.6,
                turns: float = 4.25, wire_radius: float = 0.55) -> trimesh.Trimesh:
    """A light reference mesh for one of the existing metal return springs."""
    samples = 72
    phase = np.linspace(0.0, turns * 2.0 * np.pi, samples)
    points = np.column_stack((
        center_xy[0] + radius * np.cos(phase),
        center_xy[1] + radius * np.sin(phase),
        np.linspace(z_bottom, z_top, samples),
    ))
    segments = [rod_between(tuple(a), tuple(b), wire_radius)
                for a, b in zip(points[:-1], points[1:])]
    return trimesh.util.concatenate(segments)


def build_assembled_parts() -> list[Part]:
    upper = load_centered(SOURCE_UPPER)
    lower = mirror_z(load_centered(SOURCE_LOWER))

    horn = load_centered(SOURCE_HORN)
    horn.apply_translation((0, 0, -2.0))

    # Preserve the saddle's local radial direction.  load_centered() used to
    # center its 14 mm foot through the horn; the correct placement starts the
    # saddle just outside the 41.7 mm horn flange.
    saddle = trimesh.load_mesh(OUTPUT / "minimal-switch-saddle.stl", process=True)
    saddle.apply_translation((-saddle.bounds.mean(axis=0)[0],
                              -saddle.bounds[0, 1],
                              -saddle.bounds[0, 2]))
    saddle = mirror_z(saddle)
    saddle.apply_translation((0, BRACKET_RADIAL_Y, 0))

    tray = load_centered(OUTPUT / "minimal-battery-pcb-tray.stl")
    tray.apply_translation((0, 0, TRAY_BOTTOM_Z))

    battery = box_mesh((67.0, 36.0, 10.0), (0, 0, TRAY_BOTTOM_Z + 2.4 + 5.0))
    board = box_mesh((48.26, 50.80, 1.60), (0, 0, TRAY_BOTTOM_Z + 17.2 + 0.8))
    antenna = box_mesh((37.4, 1.2, 17.5), (0, -29.1, TRAY_BOTTOM_Z + 9.6))
    coax_a = rod_between((18.7, -29.1, TRAY_BOTTOM_Z + 9.6),
                         (22.0, -29.1, TRAY_BOTTOM_Z + 17.2), 0.57)
    coax_b = rod_between((22.0, -29.1, TRAY_BOTTOM_Z + 17.2),
                         (20.0, -20.0, TRAY_BOTTOM_Z + 18.5), 0.57)
    coax = trimesh.util.concatenate([coax_a, coax_b])

    # The fixed switch body belongs low and outside the moving horn.  Only the
    # lever and red roller reach upward/inward beneath the flange.  The mounting
    # hole line is aligned to the saddle slots at assembly Z=-15 mm.
    switch_y = BRACKET_RADIAL_Y + 3.0 + 5.15
    switch = box_mesh((27.8, 10.3, 15.9), (0, switch_y, -17.2))
    lever_a = rod_between((0, switch_y - 2.0, -9.2), (0, 41.0, -5.0), 0.7)
    lever_b = rod_between((0, 41.0, -5.0), (0, 39.5, -5.0), 0.7)
    lever = trimesh.util.concatenate([lever_a, lever_b])
    roller = trimesh.creation.cylinder(radius=2.4, height=5.0, sections=40)
    roller.apply_transform(trimesh.transformations.rotation_matrix(np.pi / 2, (0, 1, 0)))
    roller.apply_translation((0, 39.5, -5.0))

    # The original design's return springs remain under the horn flange.  Three
    # representative springs are shown on the spoke-supported annulus, outside
    # the PCB footprint; use the same count/locations as the user's printed set.
    springs = []
    for angle_deg in (0.0, 120.0, 240.0):
        angle = np.deg2rad(angle_deg)
        springs.append(spring_mesh((29.0 * np.cos(angle), 29.0 * np.sin(angle))))
    spring_set = trimesh.util.concatenate(springs)

    return [
        Part("lower wheel", lower, (205, 211, 218, 42)),
        Part("electronics tray", tray, (78, 169, 255, 230)),
        Part("battery", battery, (244, 184, 96, 245)),
        Part("PCB / LEDs up", board, (73, 194, 112, 245)),
        Part("XIAO FPC antenna", antenna, (32, 35, 42, 255)),
        Part("antenna coax", coax, (28, 30, 34, 255)),
        Part("upper wheel", upper, (235, 238, 242, 48)),
        Part("rounded horn", horn, (58, 230, 121, 190)),
        Part("existing metal springs", spring_set, (255, 202, 72, 255)),
        Part("switch saddle", saddle, (72, 155, 255, 255)),
        Part("limit switch", switch, (35, 40, 48, 255)),
        Part("switch lever", lever, (220, 225, 232, 255)),
        Part("red switch roller", roller, (235, 61, 61, 255)),
    ]


def exploded_parts(parts: list[Part]) -> list[Part]:
    offsets = {
        "lower wheel": (0, 0, -75),
        "electronics tray": (0, 0, -32),
        "battery": (0, 0, -17),
        "PCB / LEDs up": (0, 0, -4),
        "XIAO FPC antenna": (0, 0, -32),
        "antenna coax": (0, 0, -32),
        "upper wheel": (0, 0, 18),
        "rounded horn": (0, 0, 62),
        "existing metal springs": (0, 0, 42),
        "switch saddle": (0, 34, 5),
        "limit switch": (0, 34, 5),
        "switch lever": (0, 34, 5),
        "red switch roller": (0, 34, 5),
    }
    result: list[Part] = []
    for part in parts:
        mesh = part.mesh.copy()
        mesh.apply_translation(offsets[part.name])
        color = part.color
        if part.name in {"lower wheel", "upper wheel"}:
            color = (*part.color[:3], 225)
        result.append(Part(part.name, mesh, color))
    return result


def render(parts: list[Part], width: int, height: int) -> Image.Image:
    """Small dependency-free orthographic triangle renderer."""
    background = (17, 21, 27, 255)
    image = Image.new("RGBA", (width, height), background)
    draw = ImageDraw.Draw(image, "RGBA")

    camera = np.asarray((1.0, -1.35, 0.85), dtype=float)
    camera /= np.linalg.norm(camera)
    right = np.cross((0.0, 0.0, 1.0), camera)
    right /= np.linalg.norm(right)
    up = np.cross(camera, right)
    up /= np.linalg.norm(up)

    all_vertices = np.vstack([p.mesh.vertices for p in parts])
    px = all_vertices @ right
    py = all_vertices @ up
    span_x = max(float(np.ptp(px)), 1.0)
    span_y = max(float(np.ptp(py)), 1.0)
    scale = min(width * 0.88 / span_x, height * 0.86 / span_y)
    centre_x = float((px.min() + px.max()) / 2)
    centre_y = float((py.min() + py.max()) / 2)

    triangles: list[tuple[float, np.ndarray, tuple[int, int, int, int]]] = []
    light = np.asarray((0.2, -0.35, 0.92), dtype=float)
    light /= np.linalg.norm(light)
    for part in parts:
        vertices = part.mesh.vertices
        faces = part.mesh.faces
        tri3 = vertices[faces]
        normals = np.cross(tri3[:, 1] - tri3[:, 0], tri3[:, 2] - tri3[:, 0])
        lengths = np.linalg.norm(normals, axis=1)
        valid = lengths > 1e-9
        normals[valid] /= lengths[valid, None]
        facing = normals @ camera
        for triangle, normal, visible in zip(tri3, normals, facing):
            if visible <= 0:
                continue
            sx = (triangle @ right - centre_x) * scale + width / 2
            sy = height / 2 - (triangle @ up - centre_y) * scale
            depth = float(np.mean(triangle @ camera))
            brightness = 0.55 + 0.45 * max(0.0, float(normal @ light))
            rgb = tuple(int(np.clip(c * brightness, 0, 255)) for c in part.color[:3])
            triangles.append((depth, np.column_stack((sx, sy)), (*rgb, part.color[3])))

    # camera points from object toward viewer, so low depth is farther away.
    triangles.sort(key=lambda item: item[0])
    for _, points, fill in triangles:
        draw.polygon([tuple(point) for point in points], fill=fill)
    return image


def export_scene(parts: list[Part], path: Path) -> None:
    scene = trimesh.Scene()
    for part in parts:
        scene.add_geometry(colored(part.mesh, part.color), node_name=part.name, geom_name=part.name)
    scene.export(path)


def make_overview(assembled: list[Part], exploded: list[Part], path: Path) -> None:
    panel_w, panel_h = 900, 820
    assembled_image = render(assembled, panel_w, panel_h)
    exploded_image = render(exploded, panel_w, panel_h)
    canvas = Image.new("RGBA", (1800, 1040), (17, 21, 27, 255))
    canvas.alpha_composite(assembled_image, (0, 105))
    canvas.alpha_composite(exploded_image, (900, 105))
    draw = ImageDraw.Draw(canvas, "RGBA")
    title_font = ImageFont.load_default(size=42)
    head_font = ImageFont.load_default(size=30)
    label_font = ImageFont.load_default(size=21)
    draw.text((900, 38), "STEERING-WHEEL HORN - COMPLETE ASSEMBLY", fill="white", font=title_font, anchor="mm")
    draw.text((450, 92), "ASSEMBLED / SHELLS TRANSPARENT", fill="#a7d4ff", font=head_font, anchor="mm")
    draw.text((1350, 92), "EXPLODED ORDER", fill="#a7d4ff", font=head_font, anchor="mm")

    sequence = [
        ("1 LOWER/BACK HALF", (215, 220, 226)),
        ("2 BLUE TRAY", (78, 169, 255)),
        ("3 BATTERY", (244, 184, 96)),
        ("4 PCB - LEDs UP", (73, 194, 112)),
        ("5 UPPER/FRONT HALF", (235, 238, 242)),
        ("6 METAL SPRINGS", (255, 202, 72)),
        ("7 ROUNDED HORN", (58, 230, 121)),
    ]
    x = 32
    for i, (text, color) in enumerate(sequence):
        draw.rounded_rectangle((x, 968, x + 25, 993), radius=5, fill=(*color, 255))
        draw.text((x + 34, 980), text, fill="#d9dee5", font=label_font, anchor="lm")
        x += 250
        if i < len(sequence) - 1:
            draw.text((x - 17, 980), ">", fill="#7cc7ff", font=head_font, anchor="mm")

    # Explicit callout for the one part that sits beside rather than within the
    # vertical stack.
    draw.rounded_rectangle((1220, 114, 1680, 172), radius=12, fill="#1b2635dd", outline="#489bff", width=2)
    draw.text((1450, 143), "SWITCH SADDLE SITS AT\nHORN FLANGE EDGE", fill="#9ecbff",
              font=label_font, anchor="mm", align="center")
    canvas.convert("RGB").save(path, quality=95)


def make_switch_closeup(path: Path) -> None:
    """Clear two-state diagram of the side-mounted roller switch."""
    canvas = Image.new("RGB", (1800, 1080), "#11151b")
    draw = ImageDraw.Draw(canvas, "RGBA")
    title_font = ImageFont.load_default(size=46)
    head_font = ImageFont.load_default(size=31)
    body_font = ImageFont.load_default(size=23)
    small_font = ImageFont.load_default(size=20)

    draw.text((900, 42), "WHERE THE ROLLER SWITCH GOES", fill="white", font=title_font, anchor="mm")
    draw.text((900, 87), "Side cutaway through the horn edge", fill="#a7d4ff", font=head_font, anchor="mm")

    def state_panel(x0: int, pressed: bool) -> None:
        y0 = 135
        draw.rounded_rectangle((x0, y0, x0 + 790, y0 + 750), radius=28, outline="#596573", width=3)
        draw.text((x0 + 395, y0 + 40), "2. PRESSED - SWITCH CLICKS" if pressed else "1. RELEASED - SWITCH OPEN",
                  fill="#ffcf70" if pressed else "#9ee6b4", font=head_font, anchor="mm")

        # Fixed wall and the blue saddle mounted to it.
        draw.rectangle((x0 + 660, y0 + 155, x0 + 715, y0 + 650), fill="#d4d8de")
        draw.text((x0 + 686, y0 + 685), "fixed wheel wall", fill="#d4d8de", font=small_font, anchor="mm")
        draw.rectangle((x0 + 590, y0 + 230, x0 + 660, y0 + 625), fill="#489bff")
        draw.rectangle((x0 + 540, y0 + 595, x0 + 660, y0 + 625), fill="#489bff")
        draw.text((x0 + 614, y0 + 205), "printed saddle", fill="#8bc4ff", font=small_font, anchor="mm")

        # Full-size 27.8 x 15.9 x 10.3 mm switch body.  It stays below and
        # outside the cap's travel; the lever rises toward the moving flange.
        switch_box = (x0 + 430, y0 + 390, x0 + 590, y0 + 585)
        draw.rounded_rectangle(switch_box, radius=10, fill="#252b33", outline="white", width=3)
        for cy in (y0 + 442, y0 + 530):
            draw.ellipse((x0 + 545, cy - 11, x0 + 567, cy + 11), outline="#89929d", width=3)
        draw.text((x0 + 510, y0 + 605), "your 28 mm roller switch", fill="white", font=small_font, anchor="mm")

        # Roller lever.  The horn flange moves downward over the red roller.
        roller_y = y0 + (358 if not pressed else 405)
        draw.line((x0 + 448, y0 + 405, x0 + 372, roller_y), fill="#dfe4ea", width=10)
        draw.ellipse((x0 + 350, roller_y - 22, x0 + 394, roller_y + 22), fill="#ed4b4b", outline="white", width=3)

        horn_shift = 0 if not pressed else 70
        # Ghosted rest position in the pressed panel.
        if pressed:
            draw.rounded_rectangle((x0 + 85, y0 + 135, x0 + 400, y0 + 330), radius=105,
                                   outline="#5f806a", width=3)
            draw.rectangle((x0 + 70, y0 + 300, x0 + 365, y0 + 340), outline="#5f806a", width=3)

        # Original rounded cap and its flange.
        draw.rounded_rectangle((x0 + 85, y0 + 135 + horn_shift, x0 + 400, y0 + 330 + horn_shift),
                               radius=105, fill="#39d978", outline="#a8f3c2", width=4)
        draw.rectangle((x0 + 70, y0 + 300 + horn_shift, x0 + 365, y0 + 340 + horn_shift),
                       fill="#39d978", outline="#a8f3c2", width=3)
        draw.text((x0 + 225, y0 + 220 + horn_shift), "original rounded horn", fill="#103c22",
                  font=body_font, anchor="mm")

        if not pressed:
            draw.line((x0 + 370, y0 + 342, x0 + 370, roller_y - 25), fill="#ffcf70", width=3)
            draw.text((x0 + 315, y0 + 405), "small gap at rest", fill="#ffcf70", font=small_font, anchor="mm")
            draw.line((x0 + 275, y0 + 455, x0 + 275, y0 + 540), fill="white", width=5)
            draw.polygon([(x0 + 275, y0 + 560), (x0 + 260, y0 + 535), (x0 + 290, y0 + 535)], fill="white")
            draw.text((x0 + 275, y0 + 595), "horn travels down", fill="white", font=body_font, anchor="mm")
        else:
            draw.text((x0 + 330, y0 + 485), "flange rolls over\nred roller", fill="#ffcf70",
                      font=body_font, anchor="mm", align="center")
            draw.text((x0 + 500, y0 + 315), "CLICK", fill="#ffcf70", font=head_font, anchor="mm")

    state_panel(70, False)
    state_panel(940, True)

    draw.rounded_rectangle((160, 925, 1640, 1035), radius=20, fill="#192536", outline="#489bff", width=3)
    draw.text((900, 958), "THE SWITCH IS SIDEWAYS AT THE HORN EDGE - NOT AT THE BOTTOM OF THE CASE",
              fill="#a7d4ff", font=head_font, anchor="mm")
    draw.text((900, 1002), "Only the red roller and metal lever enter the horn's vertical travel path.",
              fill="#d7dde5", font=body_font, anchor="mm")
    canvas.save(path)


def make_antenna_picture(path: Path) -> None:
    """Show the antenna landing pad and cable route on the tray."""
    canvas = Image.new("RGB", (1800, 1000), "#11151b")
    draw = ImageDraw.Draw(canvas, "RGBA")
    title_font = ImageFont.load_default(size=45)
    head_font = ImageFont.load_default(size=30)
    body_font = ImageFont.load_default(size=23)
    small_font = ImageFont.load_default(size=20)
    draw.text((900, 42), "XIAO ESP32-S3 FLEX ANTENNA LOCATION", fill="white", font=title_font, anchor="mm")
    draw.text((900, 88), "The antenna sticks to the outside of the tray's long flat wall",
              fill="#a7d4ff", font=head_font, anchor="mm")

    # Outside view of the 73 x 19.2 mm wall.
    draw.rounded_rectangle((80, 140, 1120, 690), radius=26, outline="#5b6673", width=3)
    draw.text((600, 180), "OUTSIDE VIEW", fill="#a7d4ff", font=head_font, anchor="mm")
    draw.rounded_rectangle((155, 275, 1045, 510), radius=28, fill="#489bff", outline="#a8d4ff", width=4)
    draw.text((600, 245), "73 x 19.2 mm flat tray wall", fill="#8bc4ff", font=body_font, anchor="mm")
    # Recess outline and the actual FPC antenna.
    draw.rounded_rectangle((365, 287, 855, 498), radius=12, fill="#2a313a", outline="#dce1e7", width=3)
    draw.text((610, 380), "SEEED 2.4 GHz\nFPC ANTENNA", fill="#e9edf2", font=head_font, anchor="mm", align="center")
    draw.text((610, 455), "37.4 x 17.5 mm", fill="#ffcf70", font=body_font, anchor="mm")
    # Cable exits to the right, then goes over the open rim notch.
    draw.line((855, 393, 930, 393, 930, 270), fill="#15171b", width=8)
    draw.arc((908, 244, 952, 288), 180, 270, fill="#15171b", width=8)
    draw.text((955, 245), "3 mm open cable notch", fill="#d7dde5", font=small_font, anchor="lm")
    draw.line((365, 530, 855, 530), fill="white", width=3)
    draw.polygon([(365, 530), (380, 522), (380, 538)], fill="white")
    draw.polygon([(855, 530), (840, 522), (840, 538)], fill="white")
    draw.text((610, 558), "40 mm recessed landing pad", fill="white", font=small_font, anchor="mm")
    draw.text((600, 625), "The FPC remains almost flat; the 0.6 mm recess only locates it.",
              fill="#d7dde5", font=body_font, anchor="mm")

    # Cross-section through the wall, antenna, battery, and board.
    draw.rounded_rectangle((1180, 140, 1720, 690), radius=26, outline="#5b6673", width=3)
    draw.text((1450, 180), "SIDE SECTION", fill="#a7d4ff", font=head_font, anchor="mm")
    draw.text((1255, 250), "outside / air", fill="#d7dde5", font=small_font, anchor="mm")
    draw.rectangle((1300, 275, 1320, 500), fill="#252b33", outline="white", width=2)
    draw.text((1288, 520), "FPC", fill="#ffcf70", font=small_font, anchor="mm")
    draw.rectangle((1320, 255, 1380, 530), fill="#489bff")
    draw.text((1350, 555), "plastic wall", fill="#8bc4ff", font=small_font, anchor="mm")
    draw.rectangle((1460, 395, 1660, 515), fill="#f4b860", outline="white", width=2)
    draw.text((1560, 455), "battery", fill="#513b1e", font=body_font, anchor="mm")
    draw.rectangle((1430, 305, 1665, 335), fill="#49c270", outline="white", width=2)
    draw.text((1548, 288), "PCB / XIAO", fill="#9ee6b4", font=small_font, anchor="mm")
    draw.line((1310, 280, 1370, 220, 1460, 305), fill="#15171b", width=7)
    draw.text((1500, 220), "65 mm coax to U.FL/I-PEX", fill="#d7dde5", font=small_font, anchor="mm")
    draw.line((1395, 380, 1435, 380), fill="#ffcf70", width=3)
    draw.text((1415, 360), "air gap", fill="#ffcf70", font=small_font, anchor="mm")

    draw.rounded_rectangle((120, 775, 1680, 930), radius=22, fill="#192536", outline="#489bff", width=3)
    draw.text((900, 820), "KEEP THE ANTENNA FLAT AND OUTSIDE THE BATTERY CAVITY",
              fill="#a7d4ff", font=head_font, anchor="mm")
    draw.text((900, 866), "Do not fold it around the battery or cover it with foil, screws, the switch, or a ground plane.",
              fill="#d7dde5", font=body_font, anchor="mm")
    draw.text((900, 903), "The cable notch is open at the top, so the tiny connector does not have to pass through a hole.",
              fill="#d7dde5", font=body_font, anchor="mm")
    canvas.save(path)


def make_spring_picture(path: Path) -> None:
    """Show where the existing compression springs remain in the stack."""
    canvas = Image.new("RGB", (1800, 1050), "#11151b")
    draw = ImageDraw.Draw(canvas, "RGBA")
    title_font = ImageFont.load_default(size=45)
    head_font = ImageFont.load_default(size=30)
    body_font = ImageFont.load_default(size=23)
    small_font = ImageFont.load_default(size=20)

    draw.text((900, 45), "WHERE THE EXISTING METAL SPRINGS GO", fill="white",
              font=title_font, anchor="mm")
    draw.text((900, 92), "They lift the horn; they do not mount in the electronics box",
              fill="#a7d4ff", font=head_font, anchor="mm")

    # Top view: springs around the centre, on the fixed support annulus.
    draw.rounded_rectangle((70, 145, 875, 850), radius=28, outline="#596573", width=3)
    draw.text((472, 185), "SCHEMATIC TOP VIEW - CAP REMOVED", fill="#a7d4ff",
              font=head_font, anchor="mm")
    centre = (472, 515)
    draw.ellipse((172, 215, 772, 815), outline="#d9dee5", width=26)
    draw.ellipse((322, 365, 622, 665), fill="#27313d", outline="#bfc7d0", width=14)
    draw.ellipse((382, 425, 562, 605), fill="#11151b", outline="#bfc7d0", width=8)
    for angle_deg in (0, 120, 240):
        angle = np.deg2rad(angle_deg)
        sx = centre[0] + 218 * np.cos(angle)
        sy = centre[1] + 218 * np.sin(angle)
        for rr in (36, 28, 20):
            draw.ellipse((sx - rr, sy - rr, sx + rr, sy + rr),
                         outline="#ffca48", width=5)
    draw.text((472, 805), "example layout - reuse the original spring seats",
              fill="#ffda7b", font=small_font, anchor="mm")

    # Side section: fixed support, spring, horn flange and separate switch.
    draw.rounded_rectangle((925, 145, 1730, 850), radius=28, outline="#596573", width=3)
    draw.text((1328, 185), "SIDE SECTION", fill="#a7d4ff", font=head_font, anchor="mm")
    draw.rectangle((1015, 655, 1625, 715), fill="#cfd5dc")
    draw.text((1320, 752), "fixed upper-wheel support", fill="#d9dee5",
              font=body_font, anchor="mm")
    draw.rectangle((1045, 345, 1435, 405), fill="#39d978", outline="#a8f3c2", width=4)
    draw.rounded_rectangle((1080, 220, 1400, 385), radius=95,
                           fill="#39d978", outline="#a8f3c2", width=4)
    draw.text((1240, 285), "rounded horn", fill="#103c22", font=body_font, anchor="mm")

    # Stylised compression spring.
    spring_points = []
    for i in range(70):
        t = i / 69
        spring_points.append((1190 + 42 * np.sin(t * 9 * np.pi), 645 - 225 * t))
    draw.line(spring_points, fill="#ffca48", width=11, joint="curve")
    draw.line((1145, 645, 1235, 645), fill="#ffca48", width=9)
    draw.line((1145, 420, 1235, 420), fill="#ffca48", width=9)
    draw.text((1080, 530), "metal spring", fill="#ffda7b", font=body_font, anchor="mm")

    # Switch remains outside the spring path.
    draw.rounded_rectangle((1480, 495, 1645, 650), radius=10,
                           fill="#252b33", outline="white", width=3)
    draw.line((1510, 500, 1435, 420), fill="#dfe4ea", width=9)
    draw.ellipse((1412, 397, 1458, 443), fill="#ed4b4b", outline="white", width=3)
    draw.text((1560, 680), "side switch", fill="white", font=small_font, anchor="mm")
    draw.text((1515, 370), "roller under edge", fill="#ffcf70", font=small_font, anchor="mm")

    draw.rounded_rectangle((150, 895, 1650, 1015), radius=20,
                           fill="#192536", outline="#489bff", width=3)
    draw.text((900, 934), "STACK: FIXED SUPPORT  >  METAL SPRINGS  >  MOVING HORN FLANGE",
              fill="#a7d4ff", font=head_font, anchor="mm")
    draw.text((900, 978), "The battery/PCB tray stays below this spring layer; the switch stays at the outside edge.",
              fill="#d7dde5", font=body_font, anchor="mm")
    canvas.save(path)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    assembled = build_assembled_parts()
    exploded = exploded_parts(assembled)

    export_scene(assembled, OUTPUT / "complete-assembly-reference.glb")
    export_scene(exploded, OUTPUT / "complete-assembly-exploded.glb")

    # Multi-shell STL is convenient in slicers for orbiting the complete model.
    # It is deliberately marked VIEW-ONLY because it is not a single print.
    view_only = trimesh.util.concatenate([p.mesh for p in assembled if p.name not in {"battery", "PCB / LEDs up", "XIAO FPC antenna", "antenna coax", "limit switch", "switch lever", "red switch roller"}])
    view_only.export(OUTPUT / "complete-assembly-VIEW-ONLY.stl")

    make_overview(assembled, exploded, OUTPUT / "complete-assembly-overview.png")
    make_switch_closeup(OUTPUT / "switch-placement-closeup.png")
    make_spring_picture(OUTPUT / "spring-placement.png")
    make_antenna_picture(OUTPUT / "antenna-placement.png")
    print("Wrote complete assembly GLB, exploded GLB, view-only STL, and overview PNG")
    for part in assembled:
        print(f"  {part.name}: {np.round(part.mesh.bounds, 1).tolist()}")


if __name__ == "__main__":
    main()
