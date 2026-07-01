# 25 — Export Pipeline

## Export types

MVP:
- STL.
- STEP.
- Project JSON.

Important:
- DXF for glass/inserts/panels/covers.

Later:
- 3MF.
- SVG.
- exploded assembly / BOM.
- screenshots/renders.

## Source of export

Exports are generated from semantic model through geometry backend.

Do not use exported STL as source for future editing.

## STL

Generated from B-Rep tessellation.

Options:
- preview quality,
- print quality,
- high quality,
- unit metadata via sidecar if needed.

## STEP

Export B-Rep model for CAD interoperability.

Current native status:
- `occt_worker_native_occt` supports the first `export_step` operation.
- The request must provide `options.outputPath`.
- The response returns a `step` artifact generated from OCCT B-Rep.
- The exported STEP file is output only and is not editable project state.
- User-facing export commands and part-selection options are still future work.

Options:
- entire device,
- individual parts,
- selected body,
- case/accessory part.

## DXF

Use for:
- glass insert contour,
- acrylic panel,
- metal faceplate,
- slot cover,
- labels,
- laser/CNC cutting.

Layers:
- `OUTER_CUT`
- `INNER_CUT`
- `ENGRAVE`
- `MARKING`
- `CONSTRUCTION`
- `NOTES`

DXF settings:
- kerf compensation,
- tool diameter,
- dogbone/corner relief,
- tolerance,
- closed contours,
- preserve arcs where possible,
- optional reference marks.

## 3MF later

Useful for:
- multi-part export,
- colors/materials,
- units,
- print profiles.

## Export validation

Before export:
- body validity,
- closed solids,
- minimum thickness,
- insert profiles closed,
- no missing generated geometry,
- no suppressed required features.

## File naming

Use predictable names:
- `project_body_main.step`
- `project_enclosure_base.stl`
- `project_lid.stl`
- `project_screen_glass.dxf`
- `project_case_tpu.stl`
