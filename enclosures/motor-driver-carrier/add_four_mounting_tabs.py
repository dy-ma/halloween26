"""Apply Dylan's manual cutouts to a clean base and add four mounting tabs.

The clean base was generated from the battery-shelf revision before its two
original side tabs were added.  The Boolean difference between the original
revision and Dylan's hand-edited STEP isolates his manual cutouts.  Applying
that difference to the clean base preserves the cutouts without leaving any
embedded remnants of the old tabs.
"""

from __future__ import annotations

from pathlib import Path

import cadquery as cq
from cadquery import exporters, importers


EDITED_SOURCE = Path(
    "/Users/dylanang/Downloads/prints/"
    "motor-driver-carrier-BATTERY-SHELF-ITERATION - Part 1.step"
)
OUT = Path(__file__).resolve().parent / "output"
ORIGINAL_WITH_TABS = OUT / "motor-driver-carrier-BATTERY-SHELF-ITERATION.step"
CLEAN_BASE = (
    Path(__file__).resolve().parent
    / "reference"
    / "motor-driver-carrier-battery-shelf-no-tabs.step"
)

# The hand-edited STEP retains the original 95.30 x 57.30 mm controller
# bumper.  These are the same tab dimensions and positions used in the later
# four-tab CadQuery revision.
BUMPER_WIDTH = 95.30
BUMPER_DEPTH = 57.30
TAB_RADIUS = 7.00
TAB_CENTER_OUTBOARD = 8.00
TAB_X_INSET = 12.00
TAB_HOLE_DIAMETER = 4.20
TAB_THICKNESS = 3.20
TAB_NECK_DEPTH = TAB_CENTER_OUTBOARD + 2.00


def box(
    size: tuple[float, float, float],
    center: tuple[float, float, float],
) -> cq.Workplane:
    return cq.Workplane("XY").box(*size).translate(center)


def cylinder_z(
    radius: float,
    height: float,
    x: float,
    y: float,
    z0: float,
) -> cq.Workplane:
    solid = cq.Solid.makeCylinder(
        radius,
        height,
        cq.Vector(x, y, z0),
        cq.Vector(0, 0, 1),
    )
    return cq.Workplane(obj=solid)


def build() -> cq.Workplane:
    for required in (EDITED_SOURCE, ORIGINAL_WITH_TABS, CLEAN_BASE):
        if not required.exists():
            raise FileNotFoundError(required)

    edited = importers.importStep(str(EDITED_SOURCE))
    original = importers.importStep(str(ORIGINAL_WITH_TABS))
    clean_base = importers.importStep(str(CLEAN_BASE))

    # Isolate the four substantial regions removed from the BTS posts.  A
    # direct subtraction of that complete difference contains microscopic
    # STEP-tolerance slivers, so read the exact flat planes and vertical spans
    # from the four valid regions and rebuild clean rectangular cutters.
    difference = original.cut(edited)
    removed_regions = [
        solid
        for solid in difference.solids().vals()
        if abs(solid.Volume()) > 1.0
    ]
    if len(removed_regions) != 4:
        raise RuntimeError(
            f"expected four manual post cutouts, found {len(removed_regions)}"
        )

    model = clean_base
    bts_center_x = sum(
        (solid.BoundingBox().xmin + solid.BoundingBox().xmax) / 2.0
        for solid in removed_regions
    ) / 4.0
    for removed in removed_regions:
        bounds = removed.BoundingBox()
        y_center = (bounds.ymin + bounds.ymax) / 2.0
        cutter_z0 = bounds.zmin - 0.02
        cutter_height = bounds.zmax - cutter_z0 + 1.0

        if (bounds.xmin + bounds.xmax) / 2.0 < bts_center_x:
            # Left post pair: preserve the user's right-facing flat plane.
            flat_x = bounds.xmin
            cutter_x = flat_x + 10.0
        else:
            # Right post pair: preserve the user's left-facing flat plane.
            flat_x = bounds.xmax
            cutter_x = flat_x - 10.0

        cutter = box(
            (20.0, 10.0, cutter_height),
            (cutter_x, y_center, cutter_z0 + cutter_height / 2.0),
        )
        model = model.cut(cutter).clean()

    x_positions = (TAB_X_INSET, BUMPER_WIDTH - TAB_X_INSET)
    y_positions = (-TAB_CENTER_OUTBOARD, BUMPER_DEPTH + TAB_CENTER_OUTBOARD)

    tabs: cq.Workplane | None = None
    for x in x_positions:
        for y in y_positions:
            wall_y = 0.0 if y < 0.0 else BUMPER_DEPTH
            tab = cylinder_z(TAB_RADIUS, TAB_THICKNESS, x, y, 0.0).union(
                box(
                    (2.0 * TAB_RADIUS, TAB_NECK_DEPTH, TAB_THICKNESS),
                    (x, (y + wall_y) / 2.0, TAB_THICKNESS / 2.0),
                )
            )
            tab = tab.cut(
                cylinder_z(
                    TAB_HOLE_DIAMETER / 2.0,
                    TAB_THICKNESS + 2.0,
                    x,
                    y,
                    -1.0,
                )
            )
            tabs = tab if tabs is None else tabs.union(tab)

    if tabs is None:
        raise RuntimeError("no mounting tabs were generated")
    return model.union(tabs).clean()


def validate(model: cq.Workplane) -> None:
    solids = model.solids().vals()
    if len(solids) != 1:
        raise RuntimeError(f"expected one solid, found {len(solids)}")
    if not solids[0].isValid():
        raise RuntimeError("OpenCascade reports an invalid solid")
    bounds = solids[0].BoundingBox()
    print(
        "four-tab carrier: valid solid; "
        f"size={bounds.xlen:.2f} x {bounds.ylen:.2f} x {bounds.zlen:.2f} mm; "
        f"volume={solids[0].Volume():.2f} mm^3"
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    model = build()
    validate(model)

    stem = OUT / "motor-driver-carrier-user-cutouts-4-tabs"
    exporters.export(model, str(stem.with_suffix(".step")), exportType="STEP")
    exporters.export(
        model,
        str(stem.with_suffix(".stl")),
        exportType="STL",
        tolerance=0.05,
        angularTolerance=0.10,
    )
    for suffix, direction, show_hidden in (
        ("-preview.svg", (1.0, -1.0, 0.72), False),
        ("-top.svg", (0.0, 0.0, 1.0), True),
    ):
        exporters.export(
            model,
            str(stem.parent / f"{stem.name}{suffix}"),
            exportType="SVG",
            opt={
                "width": 1400,
                "height": 850,
                "marginLeft": 25,
                "marginTop": 25,
                "projectionDir": direction,
                "showAxes": False,
                "showHidden": show_hidden,
                "strokeWidth": 0.7,
            },
        )


if __name__ == "__main__":
    main()
