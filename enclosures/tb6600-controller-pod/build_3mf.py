"""Rebuild the Bambu Studio 3MF around the current bumper STL.

The existing project supplies Bambu's complete project schema. This script
replaces its meshes and plate metadata with the single current bumper, then
applies the checked-in A1/0.8 mm PETG structural settings.
"""

from __future__ import annotations

import io
import json
from pathlib import Path
import struct
import zipfile

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parent
STL = ROOT / "output" / "tb6600-controller-pod.stl"
PROJECT = ROOT / "output" / "tb6600-controller-pod.3mf"
PREVIEW = ROOT / "output" / "tb6600-controller-pod-preview.png"
TOP_PREVIEW = ROOT / "output" / "tb6600-controller-pod-top.png"


def read_binary_stl(path: Path):
    data = path.read_bytes()
    face_count = struct.unpack_from("<I", data, 80)[0]
    expected = 84 + 50 * face_count
    if len(data) != expected:
        raise ValueError(f"Expected binary STL ({expected} bytes), got {len(data)}")

    vertices: list[tuple[float, float, float]] = []
    vertex_ids: dict[tuple[float, float, float], int] = {}
    triangles: list[tuple[int, int, int]] = []
    for face in range(face_count):
        record = struct.unpack_from("<12fH", data, 84 + 50 * face)
        tri = []
        for offset in (3, 6, 9):
            vertex = tuple(float(value) for value in record[offset : offset + 3])
            if vertex not in vertex_ids:
                vertex_ids[vertex] = len(vertices)
                vertices.append(vertex)
            tri.append(vertex_ids[vertex])
        triangles.append(tuple(tri))
    return vertices, triangles


def mesh_xml(vertices, triangles) -> str:
    vertex_xml = "\n".join(
        f'     <vertex x="{x:.9g}" y="{y:.9g}" z="{z:.9g}"/>'
        for x, y, z in vertices
    )
    triangle_xml = "\n".join(
        f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>'
        for a, b, c in triangles
    )
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p">
 <metadata name="BambuStudio:3mfVersion">1</metadata>
 <resources>
  <object id="1" p:UUID="00040000-81cb-4c03-9d28-80fed5dfa1dc" type="model">
   <mesh>
    <vertices>
{vertex_xml}
    </vertices>
    <triangles>
{triangle_xml}
    </triangles>
   </mesh>
  </object>
 </resources>
 <build/>
</model>
'''


def main_model_xml(z_max: float) -> str:
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p">
 <metadata name="Application">BambuStudio-02.08.02.61</metadata>
 <metadata name="BambuStudio:3mfVersion">1</metadata>
 <metadata name="CreationDate">2026-10-21</metadata>
 <metadata name="ModificationDate">2026-10-21</metadata>
 <metadata name="Thumbnail_Middle">/Metadata/plate_1.png</metadata>
 <metadata name="Thumbnail_Small">/Metadata/plate_1_small.png</metadata>
 <metadata name="Title">TB6600 controller bumper</metadata>
 <resources>
  <object id="2" p:UUID="00000004-61cb-4c03-9d28-80fed5dfa1dc" type="model">
   <components>
    <component p:path="/3D/Objects/object_4.model" objectid="1" p:UUID="00040000-b206-40ff-9872-83e8017abed1" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>
   </components>
  </object>
 </resources>
 <build p:UUID="2c7c17d8-22b5-4d84-8835-1976022ea369">
  <item objectid="2" p:UUID="00000002-b1ec-4553-aec9-835e5b724bb4" transform="-1 0 0 0 1 0 0 0 -1 128 128 {z_max:.9g}" printable="1"/>
 </build>
</model>
'''


def relationships_xml() -> str:
    return '''<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Target="/3D/Objects/object_4.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>'''


def model_settings_xml(face_count: int) -> str:
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<config>
  <object id="2">
    <metadata key="name" value="tb6600-controller-pod.stl"/>
    <metadata key="extruder" value="1"/>
    <metadata face_count="{face_count}"/>
    <part id="1" subtype="normal_part" uuid="7ea6cc83-2953-480f-848b-a2a14ad8dbce">
      <metadata key="name" value="tb6600-controller-pod.stl"/>
      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>
      <metadata key="source_file" value="tb6600-controller-pod.stl"/>
      <metadata key="source_object_id" value="0"/>
      <metadata key="source_volume_id" value="0"/>
      <metadata key="source_offset_x" value="0"/>
      <metadata key="source_offset_y" value="0"/>
      <metadata key="source_offset_z" value="0"/>
      <mesh_stat face_count="{face_count}" edges_fixed="0" degenerate_facets="0" facets_removed="0" facets_reversed="0" backwards_edges="0"/>
    </part>
  </object>
  <plate>
    <metadata key="plater_id" value="1"/>
    <metadata key="plater_name" value="TB6600 controller bumper"/>
    <metadata key="locked" value="false"/>
    <metadata key="filament_map_mode" value="Auto For Flush"/>
    <metadata key="filament_maps" value="1"/>
    <metadata key="filament_volume_maps" value="0"/>
    <metadata key="thumbnail_file" value="Metadata/plate_1.png"/>
    <metadata key="thumbnail_no_light_file" value="Metadata/plate_no_light_1.png"/>
    <metadata key="top_file" value="Metadata/top_1.png"/>
    <metadata key="pick_file" value="Metadata/pick_1.png"/>
    <model_instance>
      <metadata key="object_id" value="2"/>
      <metadata key="instance_id" value="0"/>
      <metadata key="identify_id" value="96"/>
    </model_instance>
  </plate>
</config>
'''


def image_bytes(path: Path, size: tuple[int, int]) -> bytes:
    with Image.open(path) as source:
        image = ImageOps.contain(source.convert("RGBA"), size)
        canvas = Image.new("RGBA", size, (248, 248, 248, 255))
        canvas.alpha_composite(image, ((size[0] - image.width) // 2, (size[1] - image.height) // 2))
        output = io.BytesIO()
        canvas.save(output, format="PNG", optimize=True)
        return output.getvalue()


def update_project_settings(settings: dict) -> dict:
    # The template originally carried four AMS material slots. This part uses
    # one external PETG spool, so collapse material-specific arrays to one slot.
    for key, value in tuple(settings.items()):
        material_array = (
            key.startswith("filament_")
            or key.startswith("fan_")
            or key.endswith("_fan_speed")
            or "plate_temp" in key
            or key.startswith("nozzle_temperature")
        )
        if material_array and isinstance(value, list) and len(value) > 1:
            settings[key] = [value[0]]

    settings.update(
        {
            "print_settings_id": "TB6600 PETG Structural @BBL A1 0.8 nozzle",
            "printer_settings_id": "Bambu Lab A1 0.8 nozzle",
            "printer_model": "Bambu Lab A1",
            "printer_variant": "0.8",
            "nozzle_diameter": ["0.8"],
            "filament_settings_id": ["Generic PETG @BBL A1"],
            "filament_ids": ["GFSG99_03"],
            "filament_colour": ["#000000"],
            "filament_type": ["PETG"],
            "filament_vendor": ["Generic"],
            "filament_max_volumetric_speed": ["8"],
            "nozzle_temperature": ["255"],
            "nozzle_temperature_initial_layer": ["255"],
            "hot_plate_temp": ["80"],
            "hot_plate_temp_initial_layer": ["80"],
            "textured_plate_temp": ["80"],
            "textured_plate_temp_initial_layer": ["80"],
            "fan_min_speed": ["20"],
            "fan_max_speed": ["90"],
            "overhang_fan_speed": ["90"],
            "layer_height": "0.32",
            "initial_layer_print_height": "0.32",
            "line_width": "0.82",
            "initial_layer_line_width": "0.82",
            "outer_wall_line_width": "0.82",
            "inner_wall_line_width": "0.82",
            "wall_loops": "3",
            "top_shell_layers": "5",
            "bottom_shell_layers": "5",
            "sparse_infill_density": "20%",
            "sparse_infill_pattern": "gyroid",
            "outer_wall_speed": ["45"],
            "inner_wall_speed": ["60"],
            "sparse_infill_speed": ["70"],
            "internal_solid_infill_speed": ["60"],
            "top_surface_speed": ["45"],
            "gap_infill_speed": ["40"],
            "bridge_speed": ["25"],
            "initial_layer_speed": ["25"],
            "initial_layer_infill_speed": ["30"],
            "default_acceleration": ["4000"],
            "outer_wall_acceleration": ["2000"],
            "top_surface_acceleration": ["1500"],
            "initial_layer_acceleration": ["500"],
            "enable_support": "1",
            "support_type": "tree(auto)",
            "support_on_build_plate_only": "1",
            "support_threshold_angle": "30",
            "support_top_z_distance": "0.32",
            "support_bottom_z_distance": "0.32",
            "support_interface_top_layers": "2",
            "support_interface_bottom_layers": "2",
            "support_interface_spacing": "0.8",
            "support_object_xy_distance": "0.5",
            "brim_type": "auto_brim",
            "brim_width": "6",
            "brim_object_gap": "0.1",
            "elefant_foot_compensation": "0.15",
        }
    )
    return settings


def main() -> None:
    vertices, triangles = read_binary_stl(STL)
    xs = [point[0] for point in vertices]
    ys = [point[1] for point in vertices]
    zs = [point[2] for point in vertices]
    x_min, x_max = min(xs), max(xs)
    y_min, y_max = min(ys), max(ys)
    z_min, z_max = min(zs), max(zs)

    with zipfile.ZipFile(PROJECT) as source:
        settings = update_project_settings(
            json.loads(source.read("Metadata/project_settings.config"))
        )
        preserved = {
            item.filename: source.read(item.filename)
            for item in source.infolist()
            if item.filename
            not in {
                "3D/3dmodel.model",
                "3D/Objects/object_2.model",
                "3D/Objects/object_4.model",
                "3D/_rels/3dmodel.model.rels",
                "Metadata/model_settings.config",
                "Metadata/project_settings.config",
                "Metadata/plate_1.json",
                "Metadata/plate_1.png",
                "Metadata/plate_1_small.png",
                "Metadata/plate_no_light_1.png",
                "Metadata/pick_1.png",
                "Metadata/top_1.png",
                "Metadata/cut_information.xml",
            }
        }

    # The 180-degree Y rotation places the bumper perimeter on the plate and
    # leaves the vent-snap arms pointing upward, matching the successful print.
    transformed_bbox = [
        128.0 - x_max,
        128.0 + y_min,
        128.0 - x_min,
        128.0 + y_max,
    ]
    plate = {
        "bbox_all": transformed_bbox,
        "bbox_objects": [
            {
                "area": (x_max - x_min) * (y_max - y_min),
                "bbox": transformed_bbox,
                "id": 2,
                "layer_height": 0.32,
                "name": "tb6600-controller-pod.stl",
            }
        ],
        "bed_type": "textured_plate",
        "filament_colors": ["#000000"],
        "filament_ids": ["GFSG99_03"],
        "first_extruder": 0,
        "is_seq_print": False,
        "nozzle_diameter": 0.8,
        "version": 2,
    }

    temporary = PROJECT.with_suffix(".3mf.tmp")
    with zipfile.ZipFile(temporary, "w", zipfile.ZIP_DEFLATED) as output:
        for name, data in preserved.items():
            output.writestr(name, data)
        output.writestr("3D/3dmodel.model", main_model_xml(z_max))
        output.writestr("3D/Objects/object_4.model", mesh_xml(vertices, triangles))
        output.writestr("3D/_rels/3dmodel.model.rels", relationships_xml())
        output.writestr("Metadata/model_settings.config", model_settings_xml(len(triangles)))
        output.writestr(
            "Metadata/project_settings.config",
            json.dumps(settings, separators=(",", ":")),
        )
        output.writestr("Metadata/plate_1.json", json.dumps(plate, separators=(",", ":")))
        plate_png = image_bytes(PREVIEW, (512, 512))
        output.writestr("Metadata/plate_1.png", plate_png)
        output.writestr("Metadata/plate_no_light_1.png", plate_png)
        output.writestr("Metadata/pick_1.png", plate_png)
        output.writestr("Metadata/plate_1_small.png", image_bytes(PREVIEW, (128, 128)))
        output.writestr("Metadata/top_1.png", image_bytes(TOP_PREVIEW, (512, 512)))

    temporary.replace(PROJECT)
    print(
        f"Updated {PROJECT.name}: {len(vertices)} vertices, {len(triangles)} faces; "
        f"raw bounds {x_max - x_min:.2f} x {y_max - y_min:.2f} x {z_max - z_min:.2f} mm"
    )


if __name__ == "__main__":
    main()
