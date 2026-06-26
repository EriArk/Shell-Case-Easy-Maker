# 27 — Research and References

Use this file to record research done by Codex/developers before implementation.

## Research requirements

Research before implementing:
- OCCT operations.
- Flutter 3D viewport/rendering.
- STEP/STL/DXF export.
- KiCad footprint/board import.
- Input mapping and Stream Deck/custom controllers.
- Licensing of libraries.
- Existing open-source UX references.

## License caution

Do not copy AGPL/GPL code into incompatible project code.

Ideas and algorithms can be studied. Implementation must be original unless license-compatible.

Be careful with:
- slicer infill code,
- KiCad libraries,
- external model libraries,
- controller SDKs.

## Potential reference areas

### CAD kernels / geometry
- OpenCascade documentation and examples.
- FreeCAD source as conceptual reference, respecting license.
- build123d/CadQuery as conceptual high-level API references.

### ECAD/MCAD
- KiCad file formats.
- KiCad StepUp workflow concepts.
- KiCad 3D model libraries.

### UI
- Fusion/Onshape for viewport conventions.
- Blender/FreeCAD for navigation preset references.
- Modern 3D editor UI patterns.

### Slicers
- PrusaSlicer/Cura/Slic3r only as conceptual references for patterns.
- Do not copy AGPL code unless project licensing intentionally allows it.

### Hardware input
- QMK/VIA keyboard/encoder mapping concepts.
- Stream Deck command concepts.
- HID/serial keyboard-emulated workflows.

## Research note format

Use `templates/RESEARCH_NOTE_TEMPLATE.md`.
