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

## 2026-06-30 - OCCT cylindrical button cutout tools

## Question

How should the first native button-group slice build simple circular front-wall
cutouts without exposing low-level CAD operations in the default UX?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/gp_Ax2.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  `BRepPrimAPI_MakeBox`, `BRepAlgoAPI_Cut`, and deterministic preview meshing.

## Findings

- `BRepPrimAPI_MakeCylinder` can build a complete cylinder from a `gp_Ax2`,
  radius, and height.
- The cylinder height is along the local Z/main direction of the `gp_Ax2`.
- `gp_Ax2` provides an origin plus orthogonal directions, so a front-wall cut
  can place the cylinder origin just outside the front face and set the main
  direction to `+Y`.
- The resulting cylinder is suitable as a disposable boolean cut tool. It should
  not become editable project state.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Useful implementation references

- Use `BRepPrimAPI_MakeCylinder(gp_Ax2(origin, gp_Dir(0, 1, 0)), radius, height)`
  for front-wall circular button cut tools.
- Continue validating generated shapes with `BRepCheck_Analyzer`.
- Keep preview mesh triangle ranges disposable and keyed by the semantic
  `button_group` id, not by raw topology or per-triangle IDs.

## Decision

Implement first native button cutouts as controlled semantic generator output
for front-wall `button_group` feature intents. A group stays one editable
semantic object; native button holes are generated B-Rep preview output.

## Follow-up tasks

- Add top-lid button cutouts after the lid/body split exists.
- Add richer button geometry later: bevels, caps, support rings, and clearance
  profiles.

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

---

## 2026-06-27 — OCCT first geometry slice

## Question

What is the safest first OCCT integration boundary for generated enclosure
geometry?

## Sources checked

- Open CASCADE official overview:
  [Introduction](https://dev.opencascade.org/doc/overview/html/)
- Open CASCADE official build docs:
  [Build OCCT](https://dev.opencascade.org/doc/overview/html/build_upgrade__building_occt.html)
- Open CASCADE official licensing page:
  [Licensing](https://dev.opencascade.org/resources/licensing)
- Open CASCADE reference:
  [BRepPrimAPI_MakeBox](https://dev.opencascade.org/doc/refman/html/class_b_rep_prim_a_p_i___make_box.html)
- Open CASCADE user guide:
  [Modeling Algorithms - Fillets and Chamfers](https://dev.opencascade.org/doc/overview/html/occt_user_guides__modeling_algos.html)
- Open CASCADE user guide:
  [Mesh](https://dev.opencascade.org/doc/overview/html/occt_user_guides__mesh.html)
- Open CASCADE reference:
  [STEPControl_Writer](https://dev.opencascade.org/doc/refman/html/class_s_t_e_p_control___writer.html)

## Findings

- OCCT is a C++ library platform for geometric modeling, CAD data exchange, and
  visualization. The app should keep it behind a worker/adapter boundary.
- The current official build path is CMake-based. The docs also describe a
  vcpkg-based quick start for provisioning third-party dependencies.
- OCCT 6.7.0+ is licensed as LGPL 2.1 with the Open CASCADE additional
  exception. Bundling and license notices need deliberate packaging work later.
- `BRepPrimAPI_MakeBox` is the obvious first solid primitive for a rectangular
  enclosure body and exposes named box faces that can be mapped to semantic
  surface IDs.
- OCCT filleting uses `BRepFilletAPI_MakeFillet`: construct with a shape, add
  edge/radius descriptions, then build the result.
- `BRepMesh_IncrementalMesh` is the standard first meshing path. Its key control
  settings are linear and angular deflection, which should be explicit and
  deterministic.
- `STEPControl_Writer` is the later STEP export path after B-Rep generation is
  stable.

## License / compatibility notes

- OCCT is not a dependency in this repository yet.
- No OCCT source code was copied.
- Before distributing binaries, add license files/notices and document whether
  OCCT is dynamically linked, bundled, or installed externally.

## Decision

M5 should not compile OCCT yet. It should define the protocol boundary first:
- Flutter sends semantic project JSON through `GeometryRequest`.
- Worker/adapter returns `GeometryResponse`.
- Preview mesh is disposable output.
- Surface selection maps through semantic IDs.
- Raw OCCT topology IDs stay inside the worker.

## Follow-up tasks

- Decide Windows dev distribution path: source CMake + vcpkg, prebuilt package,
  or project-managed binary cache.
- Add the first `occt_worker` executable after the protocol is stable.
- Add deterministic geometry tests around known dimensions and warning outputs.
- Add license-notice packaging before distributing an OCCT-backed app.

---

## 2026-06-27 — Native project file dialogs

## Question

What dependency should provide desktop open/save file dialogs for project JSON
files?

## Sources checked

- pub.dev package page:
  [file_selector](https://pub.dev/packages/file_selector)
- pub.dev license/version metadata:
  [file_selector license metadata](https://pub.dev/packages/file_selector/versions/0.9.5/license)

## Findings

- `file_selector` is published by `flutter.dev`.
- The package purpose matches this slice: native file selection UI for opening,
  saving, and directory selection.
- The pub.dev package metadata lists Android, iOS, Linux, macOS, Web, and
  Windows support; Windows support is required for the manual build.
- The package metadata lists `BSD-3-Clause`.
- The repository should keep file dialogs behind a small service seam so tests
  can use fakes and project JSON logic can remain independent of plugin APIs.

## Decision

Use `file_selector` for native project open/save dialogs.

`ProjectFileService` stays responsible for JSON encode/decode/read/write.
`ProjectFileDialogService` is responsible only for choosing a file path.

## Follow-up tasks

- Add unsaved-changes prompts before opening another project.
- Add "Save As" when the command system grows beyond the compact toolbar.
- Bundle dependency license notices during packaging work.

---

## 2026-06-29 - OCCT Windows dependency path

## Question

What Windows dependency path should the native worker use before the first real
OCCT-generated enclosure slice?

## Sources checked

- OpenCascade official documentation: [Build OCCT](https://dev.opencascade.org/doc/overview/html/build_upgrade__building_occt.html)
- OpenCascade official licensing page: [Licensing](https://dev.opencascade.org/resources/licensing)
- vcpkg package page: [opencascade](https://vcpkg.io/en/package/opencascade.html)
- OpenCascade forum: [OCCT VCPKG Extended Package Support Now Available](https://dev.opencascade.org/content/occt-vcpkg-extended-package-support-now-available)

## Findings

- OCCT's official build path is CMake-based and requires C++17. Windows support
  expects Visual Studio 2019 or later, with Visual Studio 2022 preferred.
- Official OCCT docs call vcpkg the fastest path to a working OCCT build for
  dependency provisioning.
- The public vcpkg package page lists `opencascade` as available and currently
  exposes version `8.0.0#1`.
- OCCT 6.7.0 and later are LGPL 2.1 with the Open CASCADE additional exception.
- Some OCCT developer tools such as DRAWEXE may need manual source/CMake paths,
  but the first app worker slice does not need DRAWEXE.

## License / compatibility notes

- Do not vendor OCCT source into this repository.
- Do not copy GPL/AGPL application code while studying OCCT integrations.
- Before distributing OCCT-backed binaries, add third-party license notices and
  document bundled DLLs.

## Useful implementation references

- Full task-specific note: `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`.
- Readiness command:
  `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`

## Decision

Use vcpkg as the first Windows developer acquisition path, but keep normal
Flutter builds and the current native stub independent of OCCT. Add a separate
opt-in OCCT-linked native target only after local readiness is true.

## Follow-up tasks

- Install/configure vcpkg locally or set `OpenCASCADE_DIR` / `CASROOT`.
- Add an opt-in OCCT CMake target after readiness is true.
- Keep generated B-Rep/mesh disposable and behind the worker protocol.

---

## 2026-06-29 - OCCT shell/cavity generation

## Question

What OCCT operation should produce the first editable-enclosure body shell while
keeping Flutter behind the `GeometryService` boundary?

## Sources checked

- OpenCascade reference:
  [BRepOffsetAPI_MakeThickSolid](https://dev.opencascade.org/doc/refman/html/class_b_rep_offset_a_p_i___make_thick_solid.html)
- OpenCascade package reference:
  [BRepOffsetAPI](https://dev.opencascade.org/doc/refman/html/package_brepoffsetapi.html)
- OpenCascade reference:
  [BRepAlgoAPI_Cut](https://dev.opencascade.org/doc/refman/html/class_b_rep_algo_a_p_i___cut.html)

## Findings

- `BRepOffsetAPI_MakeThickSolid` is intended for hollowed solids from an initial
  solid plus faces to remove. In local experiments, the `GeomAbs_Arc` join
  produced the expected visible cavity but failed the first strict
  `BRepCheck_Analyzer` pass; `GeomAbs_Intersection` passed validity but kept
  the sample metrics equivalent to the old solid preview.
- `BRepAlgoAPI_Cut` is the official Boolean subtraction API. A semantic
  generator can build one rounded internal cavity tool from `wallThickness` and
  cut it from the rounded outer body without exposing Boolean operations in the
  default UI.
- The Boolean-cavity result for the sample enclosure passes
  `BRepCheck_Analyzer`, meshes with status `0`, and produces deterministic
  shell metrics.

## Decision

Use a generator-owned `BRepAlgoAPI_Cut` for the first top-open shell/cavity
slice:
- outer rounded box comes from semantic enclosure size/corner radius;
- inner rounded cavity tool comes from semantic wall thickness;
- top opening is implicit because the cavity tool starts above the bottom floor
  and extends through the top;
- Flutter receives only disposable preview mesh data, semantic surface ranges,
  and metrics.

## Follow-up tasks

- Revisit `BRepOffsetAPI_MakeThickSolid` for later lid/body variants if it gives
  cleaner wall construction for less-rounded or multi-part bodies.
- Add feature-intent cuts for USB-C/glass/buttons against the generated shell.
- Add STEP/STL export only after native B-Rep validation and license notices are
  ready.

## Update - first feature-intent cut

M70 reuses the generator-owned `BRepAlgoAPI_Cut` path for the first native
USB-C feature intent. The worker builds a rounded rectangular cut tool from
semantic USB-C dimensions and optional `placement.surfacePosition`, cuts only
the supported front-wall surface slice, and reports unsupported button/glass
intents as ignored metrics instead of exposing Boolean tools in the default UI.
