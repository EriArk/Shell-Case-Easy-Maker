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

---

## 2026-06-27 — Flutter GitHub Actions CI

## Question

What minimal GitHub Actions workflow should validate the current Flutter desktop project without starting platform packaging too early?

## Sources checked

- Flutter documentation: [Continuous delivery with Flutter](https://docs.flutter.dev/deployment/cd)
- GitHub official action: [actions/checkout](https://github.com/actions/checkout)
- Flutter setup action: [subosito/flutter-action](https://github.com/subosito/flutter-action)

## Findings

- Flutter's deployment documentation lists GitHub Actions as an available integration path for CI/CD.
- `actions/checkout` is the official GitHub checkout action. Its README now documents `actions/checkout@v7`; the repository is MIT licensed.
- `subosito/flutter-action@v2` is a maintained Flutter setup action for Linux, Windows, and macOS runners. It supports explicit Flutter versions, stable channel selection, and cache options. The repository is MIT licensed and had a latest release in 2026.
- The current project was created with Flutter `3.44.2`, so CI pins that version for deterministic validation instead of floating on latest stable.

## License / compatibility notes

- `actions/checkout`: MIT license.
- `subosito/flutter-action`: MIT license.
- No source code from either project was copied into this repository.

## Useful implementation references

- Use `actions/checkout@v7`.
- Use `subosito/flutter-action@v2` with `channel: stable`, `flutter-version: "3.44.2"`, `cache: true`, and `pub-cache: true`.
- Run `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test`.

## Decision

Add a lightweight `Flutter CI` workflow for push and pull request events on `main`. It validates formatting, static analysis, and tests only. Desktop build jobs will be added later when packaging dependencies and platform-specific build policies are ready.

## Follow-up tasks

- Add platform build jobs later for Windows, Linux, and macOS packaging.
- Decide whether to keep Flutter pinned in CI or adopt a `.fvmrc`/pubspec-based version source.
