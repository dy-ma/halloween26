# Manual hardware releases

Keep editable KiCad sources, library files, docs, and selected previews in Git. Keep generated Gerbers, drills, reports, and order ZIPs out of Git; attach them to a GitHub Release. No CI or automatic publishing is configured.

## 1. Review and save the source

Complete the [pre-fabrication checklist](verification.md). Save schematic and PCB, refill zones, and run ERC/DRC with schematic parity. Do not publish manufacturing files with unresolved findings.

Commit the source you intend to release. Use a tag such as `base-controller-v0.1.0` for the first prototype; the tag should identify exactly the commit that produced the attachments. The silkscreen `Rev A` is a physical revision label, while the tag identifies a particular source snapshot. Record their relationship in release notes.

## 2. Generate the files

### Optional local export script

Install KiCad 9.0.6 and its standard libraries, plus Python 3. Run from the repository root:

```sh
python3 scripts/build_hardware.py check
# Once checks pass:
python3 scripts/build_hardware.py release
```

The script finds the usual macOS KiCad installation automatically. On other systems put `kicad-cli` on PATH and run with a Python that can import `pcbnew`, or set `KICAD_CLI` and `KICAD_PYTHON` explicitly. No Python packages need installing.

Output directories must be new/empty, to avoid mixing old exports with a new revision. For subsequent attempts choose a fresh path:

```sh
python3 scripts/build_hardware.py release --output build/rev-a-review-2
```

The helper copies the design and local libraries, refills that copy, and checks that filling did not reassign track/via nets. It runs ERC and DRC including unconnected items and schematic parity. Any reported issue blocks release ZIPs. It never changes the source board or lowers a design rule. The current U3 footprint passes the drill rules. A successful package is still a review candidate until the manual checklist is complete.

When checks pass, `build/release/release/` contains:

| File | Purpose |
|---|---|
| `base-controller-gerbers.zip` | Nine Gerber layers, Gerber job file, and separate PTH/NPTH Excellon drill files for the bare PCB |
| `base-controller-review.zip` | Schematic PDF, front/back SVGs, ERC/DRC reports, planning BOM, native KiCad positions, source hashes/tool version, fabrication hashes, and license notices |
| `SHA256SUMS.txt` | Checksums of the two ZIPs |

The bare-PCB ZIP does not order assembled boards. BOM/CPL preparation, sourcing, through-hole assembly selection, and component rotation review remain separate. The native position CSV is labeled as such and is not advertised as a JLC-ready CPL.

### KiCad GUI alternative

You can export without the script:

1. In PCB Editor, open **File → Fabrication Outputs → Gerbers (.gbr)** (or **File → Plot**, depending on menu layout).
2. Choose a fresh output directory under `build/`. Plot `F.Cu`, `B.Cu`, `F.Paste`, `B.Paste`, `F.Silkscreen`, `B.Silkscreen`, `F.Mask`, `B.Mask`, and `Edge.Cuts`. Do not include Fab/Courtyard/User layers in the fabrication upload.
3. Use Gerber X2, generate the Gerber job file, and subtract soldermask openings from silkscreen. Leave plot mirroring off, including for back layers. Do not plot the drawing sheet.
4. Generate Excellon drill files in millimeters, with PTH and NPTH separate. Use the **same origin for Gerbers and drills**; the script uses absolute coordinates for both. Do not mirror drills.
5. ZIP only the fabrication files together. Export a schematic PDF and BOM separately if useful. Record the KiCad version and source commit in your release notes.

## 3. Inspect and attach manually

Open the generated Gerbers and drills together in GerbView, then inspect the fabricator's preview. Review alignment, layer count, cutout/outline dimensions, holes, mask/paste openings, silkscreen, and QR readability. Export success alone is not approval to order.

On [GitHub Releases](https://github.com/dy-ma/halloween26/releases), draft a new release against your reviewed tag/commit. Attach the Gerber ZIP and review ZIP/checksums if using the helper. GitHub provides source archives automatically.

Suggested notes:

```text
Base controller Rev A — first prototype
Source tag: base-controller-v0.1.0
KiCad: 9.0.6
Board: 92 × 69 mm, 2 copper layers
Fabrication specification: [record chosen thickness, copper, finish, mask, etc.]
Checks: [ERC / DRC / parity results, date, reviewer]
Manufacturing preview: [reviewed / pending]
Hardware testing: not yet tested
Assembly: [what is included, hand-soldered parts, approved substitutions]
Known limitations: [remaining limitations]
```

Use a **pre-release** for an untested prototype, and publish only after reviewing the attached files. Hardware results can be added to release notes later. If copper, holes, footprints, or other manufacturing data change, make a new tag/release instead of silently replacing old order files.
