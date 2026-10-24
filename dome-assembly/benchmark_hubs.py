#!/usr/bin/env python3
"""Slice hub candidates in the installed Bambu Studio, without printing.

Writes isolated flattened presets and comparisons beside the optimized models.
The slicer never uses or changes the user's saved preferences or printer state.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "optimized" / "slicing"
PROFILES = Path("/Applications/BambuStudio.app/Contents/Resources/profiles/BBL")
BINARY = "/Applications/BambuStudio.app/Contents/MacOS/BambuStudio"


def load_preset(category, name):
    raw = json.loads((PROFILES / category / f"{name}.json").read_text())
    result = load_preset(category, raw["inherits"]) if raw.get("inherits") else {}
    for included in raw.get("include", []):
        result.update(load_preset(category, included))
    result.update(raw)
    for key in ("inherits", "include"):
        result.pop(key, None)
    return result


def write_preset(filename, preset):
    path = OUT / filename
    path.write_text(json.dumps(preset, indent=2))
    return str(path)


def slice_model(model, material, support, layer_height=0.4):
    machine = load_preset("machine", "Bambu Lab A1 0.8 nozzle")
    machine["curr_bed_type"] = "Textured PEI Plate"
    process_name = "0.40mm Standard @BBL A1 0.8 nozzle" if layer_height == 0.4 else "0.56mm Extra Draft @BBL A1 0.8 nozzle"
    process = load_preset("process", process_name)
    filament_name = {
        "pla": "Bambu PLA Basic @BBL A1",
        "pla-matte": "Bambu PLA Matte @BBL A1",
        "petg": "Generic PETG @BBL A1",
    }[material]
    filament = load_preset("filament", filament_name)
    process.update({
        "wall_loops": "3",
        "sparse_infill_density": "15%",
        "sparse_infill_pattern": "grid",
        "top_shell_layers": "3",
        "bottom_shell_layers": "3",
        "enable_support": "1" if support else "0",
        "support_type": "tree(auto)",
        "support_on_build_plate_only": "0",
        "brim_type": "no_brim",
    })
    stem = f"{model.stem}-{material}" + ("-0.56mm" if layer_height == 0.56 else "")
    run_dir = OUT / stem
    run_dir.mkdir(parents=True, exist_ok=True)
    machine_path = write_preset("machine.json", machine)
    process_path = write_preset(f"process-{'supports' if support else 'none'}.json", process)
    filament_path = write_preset(f"filament-{material}.json", filament)
    command = [
        BINARY, "--datadir", str(OUT / "isolated-data"),
        "--load-settings", f"{machine_path};{process_path}",
        "--load-filaments", filament_path,
        "--orient", "0", "--arrange", "1", "--ensure-on-bed",
        "--slice", "0", "--export-3mf", f"{stem}.3mf",
        "--outputdir", str(run_dir), str(model),
    ]
    completed = subprocess.run(command, capture_output=True, text=True)
    (run_dir / "slice.log").write_text(completed.stdout + completed.stderr)
    if completed.returncode:
        raise RuntimeError(f"slice failed ({completed.returncode}): {run_dir / 'slice.log'}\n{completed.stdout[-3000:]}\n{completed.stderr[-1500:]}")
    result = {"model": model.stem, "material": material, "supports": support, "layer_height_mm": layer_height}
    with zipfile.ZipFile(run_dir / f"{stem}.3mf") as archive:
        for name in archive.namelist():
            if name.endswith(".gcode"):
                gcode = archive.read(name).decode("utf-8")
                comments = [line for line in gcode.splitlines() if line.startswith(";") and any(term in line.lower() for term in ("estimated printing time", "total estimated time", "total filament weight", "total filament volume", "total filament length", "model printing time"))]
                result["gcode_summary"] = comments
                for line in comments:
                    if "model printing time" in line.lower():
                        result["model_time"] = re.split(r"[:=]", line, maxsplit=1)[-1].split(";", 1)[0].strip()
                    if "total filament weight" in line.lower():
                        result["filament_g"] = float(re.split(r"[:=]", line, maxsplit=1)[-1].strip())
            if name.endswith("slice_info.config"):
                (run_dir / "slice_info.config").write_bytes(archive.read(name))
    print(json.dumps(result), flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--material", default="pla", choices=("pla", "pla-matte", "petg"))
    parser.add_argument("--kind", default="6-way")
    parser.add_argument("--styles", nargs="+", default=["original", "star", "polygon"])
    parser.add_argument("--layer-height", type=float, choices=(0.4, 0.56), default=0.4)
    arguments = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    results = []
    for style in arguments.styles:
        if style == "cloth":
            model = ROOT / "cloth-safe" / f"cloth-{arguments.kind}.stl"
        elif style == "cloth-coupon":
            model = ROOT / "cloth-safe" / "cloth-socket-test.stl"
        elif style == "coupon":
            model = ROOT / "optimized" / "angled-socket-test.stl"
        elif style == "original":
            model = ROOT / "output" / f"hub-{arguments.kind}.stl"
        else:
            model = ROOT / "optimized" / f"{style}-{arguments.kind}.stl"
        results.append(slice_model(model, arguments.material, style == "original", arguments.layer_height))
    (OUT / f"results-{arguments.kind}-{arguments.material}-{arguments.layer_height}.json").write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
