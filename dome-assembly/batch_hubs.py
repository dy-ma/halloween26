#!/usr/bin/env python3
"""Arrange and slice a full set of cloth-facing hubs as multi-object plates.

Uses the installed Bambu Studio, isolated settings, and the A1 0.8 mm profile.
No connection to a printer is made. Each plate prints all objects by layer.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import xml.etree.ElementTree as ET
import zipfile
from collections import Counter
from pathlib import Path

import benchmark_hubs as benchmark

ROOT = Path(__file__).resolve().parent
KINDS = ("6-way", "5-way", "4-way-A", "4-way-B")


def metadata(element):
    return {item.attrib["key"]: item.attrib.get("value", "") for item in element.findall("metadata")}


def run(counts, layer_height, inspect_existing=False):
    tag = "-".join(map(str, counts))
    out = ROOT / "cloth-safe" / "batches" / f"set-{tag}-{layer_height:.2f}mm"
    out.mkdir(parents=True, exist_ok=True)
    machine = benchmark.load_preset("machine", "Bambu Lab A1 0.8 nozzle")
    machine["curr_bed_type"] = "Textured PEI Plate"
    name = "0.40mm Standard @BBL A1 0.8 nozzle" if layer_height == 0.4 else "0.56mm Extra Draft @BBL A1 0.8 nozzle"
    process = benchmark.load_preset("process", name)
    process.update({
        "print_sequence": "by layer", "wall_loops": "3",
        "sparse_infill_density": "15%", "sparse_infill_pattern": "grid",
        "top_shell_layers": "3", "bottom_shell_layers": "3",
        "enable_support": "0", "brim_type": "no_brim",
    })
    filament = benchmark.load_preset("filament", "Bambu PLA Basic @BBL A1")
    paths = {}
    for key, preset in (("machine", machine), ("process", process), ("filament", filament)):
        path = out / f"{key}.json"
        path.write_text(json.dumps(preset, indent=2))
        paths[key] = str(path)
    active = [(kind, count) for kind, count in zip(KINDS, counts) if count]
    filename = "dome-hub-batches.3mf"
    command = [
        benchmark.BINARY, "--datadir", str(out / "isolated-data"),
        "--load-settings", f"{paths['machine']};{paths['process']}",
        "--load-filaments", paths["filament"],
        "--clone-objects", ",".join(str(count) for _, count in active),
        "--orient", "0", "--allow-rotations", "--arrange", "1", "--ensure-on-bed",
        "--slice", "0", "--export-3mf", filename, "--outputdir", str(out),
    ] + [str(ROOT / "cloth-safe" / f"cloth-{kind}.stl") for kind, _ in active]
    if not inspect_existing:
        result = subprocess.run(command, capture_output=True, text=True)
        (out / "slice.log").write_text(result.stdout + result.stderr)
        if result.returncode:
            raise RuntimeError(f"Bambu Studio exited {result.returncode}; see {out / 'slice.log'}\n{result.stdout[-3000:]}\n{result.stderr[-1000:]}")
    report = {"layer_height_mm": layer_height, "material": "Bambu PLA Basic", "project": filename, "requested": dict(active), "plates": []}
    actual = Counter()
    with zipfile.ZipFile(out / filename) as archive:
        settings = ET.fromstring(archive.read("Metadata/model_settings.config"))
        info = ET.fromstring(archive.read("Metadata/slice_info.config"))
        for plate in info.findall("plate"):
            meta = metadata(plate)
            index = int(meta["index"])
            names = Counter(re.sub(r"\.stl_\d+$", ".stl", item.attrib["name"]) for item in plate.findall("object") if item.attrib.get("skipped") != "true")
            actual.update(names)
            layout = json.loads(archive.read(f"Metadata/plate_{index}.json"))
            gcode = archive.read(f"Metadata/plate_{index}.gcode").decode()
            summary = [line for line in gcode.splitlines() if line.startswith(";") and ("model printing time:" in line or "total filament weight" in line)]
            row = {
                "plate": index, "objects": dict(names), "count": sum(names.values()),
                "total_time_seconds": int(meta["prediction"]), "weight_g": float(meta["weight"]),
                "outside": meta["outside"], "support_used": meta["support_used"],
                "gcode_summary": summary, "bounds_mm": layout["bbox_all"],
                "warnings": [dict(item.attrib) for item in plate.findall("warning")],
            }
            report["plates"].append(row)
            for stem in ("plate", "top"):
                name = f"Metadata/{stem}_{index}.png"
                if name in archive.namelist():
                    (out / f"{stem}-{index}.png").write_bytes(archive.read(name))
        build = ET.fromstring(archive.read("3D/3dmodel.model"))
        ns = {"m": "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"}
        report["build_instances"] = len(build.findall("m:build/m:item", ns))
    expected = Counter({f"cloth-{kind}.stl": count for kind, count in active})
    if actual != expected:
        raise RuntimeError(f"arranged quantity mismatch: {actual} != {expected}")
    if any(row["outside"] != "false" for row in report["plates"]):
        raise RuntimeError("slicer reports a plate outside the printable area")
    (out / "batch-report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2), flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--counts", default="10,6,5,5", help="six-way,five-way,four-way-A,four-way-B quantities")
    parser.add_argument("--layer-height", choices=(0.4, 0.56), type=float, default=0.4)
    parser.add_argument("--inspect-existing", action="store_true", help="read an already exported batch project without reslicing")
    args = parser.parse_args()
    counts = tuple(map(int, args.counts.split(",")))
    if len(counts) != 4 or min(counts) < 0 or not sum(counts):
        parser.error("provide four nonnegative counts with at least one hub")
    run(counts, args.layer_height, args.inspect_existing)


if __name__ == "__main__":
    main()
