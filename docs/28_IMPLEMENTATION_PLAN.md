# 28 — Implementation Plan

## Strategy

Build the product in vertical slices. Do not implement every subsystem before seeing a working enclosure flow.

## First vertical slice

Goal: create a simple precise rounded enclosure with a component board and generated standoffs/cutouts.

Includes:
- semantic project model,
- Flutter shell,
- mock viewport or simple viewer,
- OCCT worker generating rounded box,
- component template with mounting holes and USB-C,
- auto standoffs,
- USB-C cutout,
- export STL/STEP.

## Second vertical slice

Goal: switch centers to button holes/plungers.

Includes:
- switch mapping,
- projected markers,
- button group pattern,
- simple plunger/hole generation,
- validation.

## Third vertical slice

Goal: glass insert and DXF export.

Includes:
- screen window,
- glass recess,
- ledge,
- insert contour generation,
- DXF layers.

## Fourth vertical slice

Goal: input/parameter polish.

Includes:
- parameter knobs,
- focused parameter,
- keyboard-emulated controller steps,
- right-click popovers,
- undo grouping.

## Fifth vertical slice

Goal: case/accessory generation.

Includes:
- device envelope,
- TPU case,
- open front,
- propagated cutouts,
- pseudo-buttons.

## Avoid big-bang development

Do not build:
- entire advanced CAD mode first,
- massive UI before geometry works,
- all texture/shape systems before basic enclosure is solid,
- import system before manual templates work.

## MVP definition

A useful MVP can:
1. Create simple precise enclosure.
2. Create/import manual component template.
3. Place board.
4. Generate standoffs.
5. Generate port cutout.
6. Generate button holes or simple plungers.
7. Export STL/STEP.
8. Export DXF for a simple glass/acrylic insert.
9. Save/load project.
10. Validate common mistakes.
