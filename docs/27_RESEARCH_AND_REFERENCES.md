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

---

## 2026-06-27 — Flutter viewport MVP approach

## Question

What should the first interactive viewport use before real OCCT preview mesh
integration exists?

## Sources checked

- Flutter docs: [Taps, drags, and other gestures](https://docs.flutter.dev/ui/interactivity/gestures)
- Flutter API: [InteractiveViewer](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html)
- Flutter API: [CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- Flutter API: [PointerScrollEvent](https://api.flutter.dev/flutter/gestures/PointerScrollEvent-class.html)
- Flutter blog: [Getting started with Flutter GPU](https://blog.flutter.dev/getting-started-with-flutter-gpu-f33d497b7c11)
- Pub.dev: [flutter_scene](https://pub.dev/packages/flutter_scene)
- Pub.dev: [three_js](https://pub.dev/packages/three_js)
- Pub.dev: [flutter_3d_controller](https://pub.dev/packages/flutter_3d_controller)

## Findings

- Flutter separates raw pointer events from higher-level gestures, so a desktop
  viewport can use raw pointer movement for CAD-like mouse button behavior while
  keeping semantic actions in app code.
- `InteractiveViewer` gives pan/zoom for child widgets, but the current app
  needs orbit, right/middle-button pan, wheel zoom, semantic hit-test routing,
  and later mesh-backed selection. A small controller is more explicit for this
  first slice.
- `CustomPainter` is appropriate for the current mock preview and supports
  repaint/hit-test patterns without adding a renderer dependency yet.
- `flutter_scene` is promising and MIT licensed, but it currently depends on
  Flutter GPU / Impeller preview flow. That is too early for the default stable
  Windows workflow.
- `three_js` is MIT licensed and supports desktop targets, but it introduces a
  rendering stack before the geometry/preview mesh protocol is defined.
- `flutter_3d_controller` is MIT licensed and useful for loading general 3D
  assets, but it is model-viewer oriented and not a precise CAD preview path.

## License / compatibility notes

- `flutter_scene`: MIT license.
- `three_js`: MIT license.
- `flutter_3d_controller`: MIT license.
- No package source code was copied.
- No new dependency was added in this chunk.

## Useful implementation references

- Use `Listener`/pointer events for desktop drag button handling.
- Use `PointerScrollEvent` for mouse wheel zoom.
- Keep viewport state separate from `GeometryService` and project data.
- Keep selection hit results semantic: object IDs, surface IDs, feature IDs.

## Decision

Implement M4 with the existing Flutter canvas stack:
- `ViewportController` for orbit, pan, zoom, fit, selection ID, and ghost
  preview state.
- `MockViewportLayout` shared by painter and hit tester.
- `MockViewportHitTester` returning semantic IDs only.

Defer a real 3D rendering dependency until the preview mesh protocol and OCCT
worker output are defined.

## Follow-up tasks

- Re-evaluate `three_js`, `flutter_scene`, or a lower-level renderer after the
  `GeometryService` preview mesh protocol exists.
- Add viewport hit testing against generated preview mesh using semantic face
  mappings, not raw triangle IDs.
