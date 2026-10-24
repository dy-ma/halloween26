# ½-inch dowel geodesic dome

**For the current hubs under decorative cloth, use `cloth-safe/README.md` and
`cloth-safe/cloth-*.stl`.** Their rounded sloping faces point outside against the
cloth, while the flat print bases face inside. They preserve this assembly's
node geometry and dowel cut list. `optimized/` is the earlier flat-outside speed
study; `output/` is the first curved-arm prototype.

This folder contains a parametric 2V hemispherical dome based on the paper
prototype. The exact geometry has three joint families—4-way boundary, 5-way,
and 6-way—but the boundary family alternates between mirrored A/B parts. The
generated print set therefore contains four hub files.

The default 26.5-inch spherical radius produces:

- 26 joints and 65 dowels
- 6 × 5-way hubs
- 10 × 6-way hubs
- 5 × 4-way-A and 5 × 4-way-B boundary hubs
- 30 short and 35 long struts
- 26.5-inch height
- 53-inch base corner-to-corner
- 50.4-inch base flat-to-flat
- 14.48-inch short and 16.38-inch long node-center spacing

The wooden cut lengths are shorter than the node-center measurements because
each dowel enters both printed sockets. Run the generator and see
`output/CUT-LIST.md` for the actual cuts.

## Generate the files

The repository's existing CadQuery environment can run the generator:

```sh
/tmp/codex-cadquery-venv/bin/python dome-assembly/generate_dome.py
```

To change the finished height/radius:

```sh
/tmp/codex-cadquery-venv/bin/python dome-assembly/generate_dome.py --radius-in 27
```

Important printable-fit and strength parameters are grouped near the top of
`generate_dome.py`. All internal dimensions are millimetres.

## Output

- `dome-full-assembly.step` — complete assembly with individual hubs and rods
- `hub-4-way-A.{step,stl}` and `hub-4-way-B.{step,stl}`
- `hub-5-way.{step,stl}` and `hub-6-way.{step,stl}`
- `half-inch-dowel-fit-gauge.{step,stl}`
- `dome-assembly-preview.png` — side view plus numbered top assembly map
- `CUT-LIST.md` — dowel lengths and print quantities
- `build-manifest.json` — every node, edge, type, and dimension

## Printing and assembly

Print the fit gauge first. Its three sockets provide 0.30, 0.60, and 0.90 mm
diameter clearance, left to right. The generated hubs default to the middle
0.60 mm fit. Measure the real dowels—nominal ½-inch stock often varies—and edit
`BORE_DIAMETER_CLEARANCE` if needed.

PETG is preferred. A practical starting point is four perimeters, 0.24–0.28 mm
layers, 25–35% gyroid infill, and five top/bottom layers. The models are
exported outside-face-down with the socket arms rising from the center. Depending
on the printer and chosen layer height, the lower sides of some sockets may need
light organic supports.

Short sockets have one small witness dimple near the mouth; long sockets are
smooth. The two boundary variants alternate around the base. The modeled 3.6 mm
access holes accept a #6 or similar wood screw into the dowel; polyurethane glue
or epoxy can be used instead.

This is a lightweight decorative frame, not a climbing structure or shelter.
