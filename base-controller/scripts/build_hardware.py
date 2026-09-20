#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Check or package the base controller using KiCad 9; standard library only."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

PROJECT = Path(__file__).resolve().parents[1]
ROOT = PROJECT.parent
NAME = "base-controller"
MAC_APP = Path("/Applications/KiCad/KiCad.app/Contents")
LAYERS = "F.Cu,B.Cu,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def issue_count(report):
    """Include connection and parity findings as well as ordinary DRC issues."""
    count = len(report.get("violations", []))
    count += len(report.get("unconnected_items", []))
    count += len(report.get("schematic_parity", []))
    count += sum(len(sheet.get("violations", [])) for sheet in report.get("sheets", []))
    return count


def zip_tree(source, target):
    with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(source.rglob("*")):
            if path.is_file():
                archive.write(path, path.relative_to(source))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["check", "release"])
    parser.add_argument("--output", type=Path, help="New/empty output directory")
    args = parser.parse_args()
    output = (args.output or ROOT / "build" / NAME / args.mode).resolve()
    if output.exists() and any(output.iterdir()):
        parser.error(f"Output directory is not empty: {output}. Choose a new --output directory.")
    cli = os.environ.get("KICAD_CLI") or shutil.which("kicad-cli")
    if not cli and (MAC_APP / "MacOS/kicad-cli").exists():
        cli = str(MAC_APP / "MacOS/kicad-cli")
    if not cli:
        parser.error("Install KiCad 9, put kicad-cli on PATH, or set KICAD_CLI.")
    python = os.environ.get("KICAD_PYTHON") or sys.executable
    if sys.platform == "darwin" and not os.environ.get("KICAD_PYTHON"):
        bundled = MAC_APP / "Frameworks/Python.framework/Versions/3.9/bin/python3"
        if bundled.exists():
            python = str(bundled)
    version = subprocess.check_output([cli, "version"], text=True).strip()
    if not version.startswith("9.0."):
        parser.error(f"This workflow targets KiCad 9.0.x; found {version}.")
    output.mkdir(parents=True, exist_ok=True)
    logs = output / "logs"
    logs.mkdir()
    work = output / "work"
    work.mkdir()
    review = output / "review"
    review.mkdir()
    commands = []

    def run(command):
        command = [str(part) for part in command]
        commands.append(command)
        print("Running:", " ".join(command), flush=True)
        result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (logs / f"{len(commands):02d}.log").write_text(result.stdout)
        (logs / "commands.json").write_text(json.dumps(commands, indent=2) + "\n")
        if result.returncode:
            print(result.stdout, file=sys.stderr)
            raise RuntimeError(f"Command failed ({result.returncode}); see {logs}")

    sources = [PROJECT / f"{NAME}{ext}" for ext in (".kicad_pcb", ".kicad_sch", ".kicad_pro")]
    sources += [PROJECT / "fp-lib-table", PROJECT / "sym-lib-table"]
    sources += sorted(p for p in (PROJECT / "libraries").rglob("*") if p.is_file())
    rules = PROJECT / f"{NAME}.kicad_dru"
    if rules.exists():
        sources.append(rules)
    source_hashes = {str(path.relative_to(ROOT)): digest(path) for path in sources}
    for path in sources:
        target = work / path.relative_to(PROJECT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, target)
    board, schematic = work / f"{NAME}.kicad_pcb", work / f"{NAME}.kicad_sch"
    run([python, Path(__file__).with_name("refill_zones.py"), board])
    run([cli, "sch", "erc", "--format", "json", "--output", review / "erc.json", schematic])
    run([cli, "pcb", "drc", "--schematic-parity", "--format", "json", "--output", review / "drc.json", board])
    erc = json.loads((review / "erc.json").read_text())
    drc = json.loads((review / "drc.json").read_text())
    issues = issue_count(erc) + issue_count(drc)
    run([cli, "sch", "export", "pdf", "--output", review / "schematic.pdf", schematic])
    for side, copper, silk in (("front", "F.Cu", "F.Silkscreen"), ("back", "B.Cu", "B.Silkscreen")):
        command = [cli, "pcb", "export", "svg", "--mode-single", "--exclude-drawing-sheet",
                   "--page-size-mode", "2", "--layers", f"{copper},{silk},Edge.Cuts",
                   "--output", review / f"{side}.svg"]
        if side == "back":
            command.append("--mirror")
        run(command + [board])
    run([cli, "sch", "export", "bom", "--output", review / "bom.csv",
         "--fields", "Reference,Value,Footprint,${QUANTITY},Manufacturer,MPN,LCSC",
         "--labels", "Designators,Value,Footprint,Quantity,Manufacturer,MPN,LCSC",
         "--group-by", "Value,Footprint,Manufacturer,MPN,LCSC", "--exclude-dnp", schematic])
    run([cli, "pcb", "export", "pos", "--format", "csv", "--units", "mm", "--side", "both",
         "--exclude-dnp", "--output", review / "positions-kicad.csv", board])
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    dirty = bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip())
    manifest = {"project": NAME, "kicad_version": version, "commit": commit, "working_tree_dirty": dirty,
                "mode": args.mode, "erc_issues": issue_count(erc), "drc_issues": issue_count(drc),
                "source_sha256": source_hashes, "refilled_board_sha256": digest(board)}
    (review / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    (review / "README.txt").write_text(
        "Review outputs for base-controller. These are not an assembled-board order.\n"
        "BOM and native KiCad position CSV require sourcing, assembly-scope, and rotation review.\n"
        "Positions include non-excluded through-hole footprints; no JLC CPL conversion is implied.\n"
        "See manifest.json for exact source hashes and checks. Automated checks do not validate hardware.\n")
    for path in sources:
        if digest(path) != source_hashes[str(path.relative_to(ROOT))]:
            raise RuntimeError("Source changed while building; repeat the build from a saved snapshot.")
    print(f"ERC: {issue_count(erc)}; DRC/connections/parity: {issue_count(drc)}", flush=True)
    if issues:
        print(f"Checks failed; review {review}. No release ZIPs generated.", file=sys.stderr)
        return 1
    if args.mode == "check":
        return 0

    fabrication = output / "fabrication"
    fabrication.mkdir()
    run([cli, "pcb", "export", "gerbers", "--layers", LAYERS, "--subtract-soldermask",
         "--output", str(fabrication) + os.sep, board])
    run([cli, "pcb", "export", "drill", "--format", "excellon", "--drill-origin", "absolute",
         "--excellon-units", "mm", "--excellon-separate-th", "--output", str(fabrication) + os.sep, board])
    # Both exporters use absolute board coordinates; do not mix auxiliary origins.
    if len(list(fabrication.glob("*.g*"))) < 9 or not list(fabrication.glob("*.drl")):
        raise RuntimeError("Incomplete fabrication export")
    release = output / "release"
    release.mkdir()
    shutil.copyfile(ROOT / "LICENSE", review / "LICENSE")
    shutil.copytree(ROOT / "LICENSES", review / "LICENSES")
    shutil.copyfile(ROOT / "NOTICE.md", review / "NOTICE.md")
    (review / "fabrication-sha256.json").write_text(json.dumps(
        {p.name: digest(p) for p in sorted(fabrication.iterdir()) if p.is_file()}, indent=2) + "\n")
    zip_tree(fabrication, release / f"{NAME}-gerbers.zip")
    zip_tree(review, release / f"{NAME}-review.zip")
    (release / "SHA256SUMS.txt").write_text("".join(
        f"{digest(path)}  {path.name}\n" for path in sorted(release.glob("*.zip"))))
    print(f"Release candidates: {release}. Inspect Gerbers/drills before publishing or ordering.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        sys.exit(2)
