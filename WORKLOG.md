# WORKLOG.md

Append one entry per meaningful work session. Do not delete older entries.

## Entry template

```md
## YYYY-MM-DD — Short title

### Goal
What was attempted.

### Read before work
Docs/files reviewed before editing.

### Changes made
- File/path:
  - What changed.
  - Why.

### Tests run
- Command:
  - Result.

### Validation
- Geometry checked?
- Serialization checked?
- UI checked?
- Export checked?

### Known issues
- Issue:
  - Severity:
  - Next action:

### Next step
What should happen next.

### Notes for future Codex sessions
Anything important that would otherwise be forgotten.
```

---

## 2026-06-29 - M67 Native preview surface ranges

### Goal
Add the first native semantic preview surface mappings so generated preview mesh
responses can identify top/front/bottom face ranges without making triangle
indices editable project IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/occt_native_target_scaffold_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/33_VIEWPORT_MVP.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`, `occt_worker/README.md`, and
`README.md`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added preview surface mapping/range data structures.
  - Classified central planar top, front, and bottom face blocks from generated
    B-Rep bounds.
  - Emitted `PreviewSurfaceMapping` JSON with disposable triangle ranges.
  - Added mapping count and mapped triangle count metrics.
  - Updated native capabilities notes to mention first-pass semantic surface
    ranges.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Validates 3 semantic surface mappings for top lid, front wall, and bottom
    inside.
  - Validates positive triangle ranges within the emitted preview mesh.
  - Checks mapping metrics against parsed preview mesh ranges.
- Docs/tasks/roadmap:
  - Recorded M67 and clarified that only central planar face ranges are mapped;
    curved fillets remain unmapped.

### Tests run
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt native OCCT worker.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports 800 vertices, 1060 triangles, 3 surface mappings,
    and 6 mapped triangles.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 183 tests.
- `git diff --check`:
  - Passed; Git repeated existing CRLF normalization warnings for touched docs.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt latest Windows app and copied the rebuilt native worker.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `status=preview_mesh_smoke`, OCCT `8.0.0`,
    and notes first-pass semantic surface ranges.

### Validation
- Geometry checked?
  - Native worker smoke validates bounds, mesh counts, semantic surface IDs,
    triangle ranges, and mapping metrics.
- Serialization checked?
  - `PreviewMesh` protocol parsing of surface mappings remains covered by
    existing protocol tests; native smoke now exercises the native JSON path.
- UI checked?
  - Full widget suite passed. No new visible UI behavior is expected from this
    backend-only mapping slice.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Only central planar face blocks are mapped; curved fillets and richer
  side/back/left/right semantics are not mapped yet.
  - Severity: Expected.
  - Next action: Expand mapping after shell/cavity and face semantics are more
    explicit.
- Issue: Viewport still does not use preview surface ranges for picking or
  highlight.
  - Severity: Expected.
  - Next action: Add a separate UI selection/highlight slice after the backend
    contract is stable.

### Next step
Use the first-pass surface ranges in a later viewport highlight or semantic
face selection slice, or continue toward shell/cavity generation.

### Notes for future Codex sessions
`previewMesh.surfaces` is preview metadata only. Triangle ranges are disposable
and must not become saved project IDs or editable topology.

---

## 2026-06-29 - M66 Native preview mesh viewport

### Goal
Render the disposable `PreviewMesh` returned by the active geometry backend in
the Flutter viewport while keeping editing and picking semantic-first.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/geometry/geometry_service.dart`, `lib/geometry/geometry_protocol.dart`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/geometry_worker_service_test.dart`, `test/widget_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`, and
`README.md`.

### Changes made
- `lib/geometry/geometry_service.dart`:
  - Added optional `GeometryPreview.previewMesh`.
  - Passed worker/mock `GeometryResponse.previewMesh` through the app-facing
    preview DTO.
- `lib/ui/shell/workspace_shell.dart`:
  - Passed `previewMesh` into the viewport painter.
  - Added a faceted preview mesh painter path with bounds fallback, simple
    camera projection, depth sorting, and triangle shading.
  - Kept semantic overlays and hit testing separate from generated triangles.
  - Added a widget-test marker for active geometry preview mesh rendering.
- Tests:
  - Added worker service assertions that `preview.previewMesh` is preserved.
  - Added widget coverage proving a service-provided preview mesh activates the
    viewport mesh path.
- Docs/tasks/roadmap:
  - Recorded M66 and clarified that preview mesh rendering is display-only, not
    editable project state.

### Tests run
- `flutter test test\geometry_worker_service_test.dart test\widget_test.dart --reporter compact`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 183 tests.
- `git diff --check`:
  - Passed; Git repeated existing CRLF normalization warnings for touched docs.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt latest Windows app with native OCCT backend.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `status=preview_mesh_smoke` and OCCT
    `8.0.0`.

### Validation
- Geometry checked?
  - The release-bundled worker can report native preview mesh capability.
- Serialization checked?
  - Existing protocol tests still pass, and worker service tests now prove the
    preview mesh survives the service adapter.
- UI checked?
  - Widget coverage confirms the viewport consumes a service-provided preview
    mesh. Manual poke is meaningful in the latest native build.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Viewport picking still uses deterministic semantic mock zones rather
  than generated triangle picking.
  - Severity: Expected for this slice.
  - Next action: Add stable semantic face mapping before any mesh/surface
    picking work.
- Issue: The mesh renderer is a CPU `CustomPaint` path.
  - Severity: Acceptable for the current 800-vertex / 1060-triangle native
    sample.
  - Next action: Revisit renderer options once larger generated meshes exist.

### Next step
Manual poke the latest native build, then continue toward either semantic face
mapping or the next real geometry generation slice.

### Notes for future Codex sessions
The viewport can now draw `GeometryPreview.previewMesh`, but generated vertices
and triangle indices remain display-only and must not become editable state.

---

## 2026-06-29 - M65 Native OCCT app backend wiring

### Goal
Make the Flutter app able to select the native OCCT worker as a bundled
developer backend without hard-coding project-local absolute paths.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/geometry/geometry_backend.dart`, `lib/geometry/geometry_service.dart`,
`lib/ui/shell/workspace_shell.dart`, `tools/build_latest_windows.ps1`,
`test/geometry_backend_test.dart`, `test/geometry_worker_service_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`README.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_backend.dart`:
  - Added `GeometryBackendKind.nativeOcct` with wire value `native_occt`.
  - Resolves the bundled native worker beside the app executable at
    `occt_worker/native/occt_worker_native_occt.exe`.
  - Falls back to `MockGeometryService` when the bundled worker is missing.
  - Keeps explicit executable overrides available for development.
- `tools/build_latest_windows.ps1`:
  - Added explicit `-NativeOcct` and `-SkipNativeOcctBuild` switches.
  - Builds Flutter with `SHELL_CASE_GEOMETRY_BACKEND=native_occt` when
    requested.
  - Copies the native worker release bundle under
    `releases/latest/windows/occt_worker/native`.
- Tests:
  - Added backend resolution coverage for `native_occt`.
  - Added build-script safety coverage for native worker bundling.
- Docs/tasks/roadmap:
  - Recorded the `native_occt` backend preset and explicit latest build flow.

### Tests run
- `flutter test test\geometry_backend_test.dart test\build_latest_windows_script_test.dart --reporter compact`:
  - Passed, 8 tests after fixing a Dart raw-string expectation.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; built latest Windows app with the native OCCT backend define and
    copied the worker bundle.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `status=preview_mesh_smoke` and OCCT
    `8.0.0`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 182 tests.

### Validation
- Geometry checked?
  - The copied native worker can run from the latest release folder and report
    capabilities. The app still needs a future rendering slice to draw native
    mesh vertices in the viewport.
- Serialization checked?
  - Backend setting parsing and process-client boundary remain covered by the
    existing geometry tests.
- UI checked?
  - Full widget suite passed. Manual poke is now meaningful: open the latest exe
    and confirm the viewport label reports `occt_worker_native_occt`.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The viewport painter still draws the schematic mock body even when the
  backend is native OCCT.
  - Severity: Expected.
  - Next action: Add a viewport rendering path that consumes `PreviewMesh`
    vertices/triangles.
- Issue: Semantic surface mapping for native preview mesh is still pending.
  - Severity: Expected.
  - Next action: Add stable semantic face mapping later without exposing OCCT
    topology IDs.

### Next step
Commit and push M65, then continue toward rendering native preview mesh
vertices in the Flutter viewport.

### Notes for future Codex sessions
The default `tools\build_latest_windows.ps1` path stays mock. Use
`tools\build_latest_windows.ps1 -NativeOcct` when the latest manual exe should
launch against the bundled native worker. Do not commit `releases/`, `build/`,
`external/`, `occt_worker/native/vcpkg_installed/`, or copied OCCT DLLs.

## 2026-06-29 - M64 First native preview mesh

### Goal
Emit the first disposable native OCCT preview mesh from the generated rounded
enclosure B-Rep while keeping editable project state semantic-only.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/occt_native_target_scaffold_test.dart`, `lib/geometry/geometry_protocol.dart`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`, `occt_worker/README.md`, and local
OCCT headers for `BRepMesh_IncrementalMesh`, `BRep_Tool::Triangulation`,
`Poly_Triangulation`, and `Poly_Triangle`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Meshes the generated rounded enclosure B-Rep with
    `BRepMesh_IncrementalMesh`.
  - Extracts face triangulations through `BRep_Tool::Triangulation`.
  - Emits `previewMesh` vertices, triangle indices, bounds, and mesh metadata.
  - Updates capability status to `preview_mesh_smoke`.
  - Keeps semantic surface mapping empty with explicit pending metadata instead
    of exposing unstable OCCT face IDs.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated the existing smoke to verify preview mesh output plus deterministic
    metrics.
  - Checks 800 vertices, 1060 triangles, bounds, dimensions, area, volume,
    request ID preservation, and non-editable generated geometry flags.
- `test/occt_native_target_scaffold_test.dart`:
  - Updated source-contract expectations for OCCT meshing APIs and preview mesh
    response metadata.
- Docs/tasks/roadmap:
  - Recorded M64, marked OCCT preview mesh generation complete, and left
    shell/cavity, semantic face mapping, STEP, and STL open.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe` and deployed `TKMesh.dll`
    beside the worker.
- `dart format tool\native_occt_worker_metrics_smoke.dart test\occt_native_target_scaffold_test.dart`:
  - Passed; formatted 2 files.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; capabilities report `preview_mesh_smoke`, response status is `ok`,
    and sample preview mesh reports 800 vertices and 1060 triangles.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 178 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Yes. The native worker builds rounded enclosure B-Rep, meshes it, and emits
    deterministic disposable preview mesh data.
- Serialization checked?
  - Native request/response JSON is exercised through
    `GeometryWorkerProcessClient`; Dart parses `PreviewMesh`.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    default UI behavior changed; the app still uses mock geometry unless a
    worker backend is explicitly configured.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Preview mesh has no semantic surface mappings yet.
  - Severity: Expected.
  - Next action: Add stable semantic face mapping without exposing OCCT topology
    IDs.
- Issue: Shell/cavity, feature cutouts, STEP, and STL remain unimplemented in
  the native target.
  - Severity: Expected.
  - Next action: Continue in safe geometry slices.

### Next step
Commit and push M64, then continue toward semantic surface mapping or
shell/cavity.

### Notes for future Codex sessions
The smoke command name remains `native_occt_worker_metrics_smoke.dart` for
compatibility, but it now validates preview mesh output too. Do not commit
`external/`, `occt_worker/native/vcpkg_installed/`, `build/`, `releases/`, or
OCCT DLLs.

## 2026-06-29 - M63 First native rounded enclosure metrics

### Goal
Replace the native OCCT link-smoke response with the first deterministic
rounded enclosure generation slice while keeping generated B-Rep internal to
the worker.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`, `occt_worker/protocol/preview_request.example.json`,
`tool/native_worker_stub_smoke.dart`, `lib/project/project_model.dart`,
`lib/geometry/geometry_service.dart`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
and `occt_worker/README.md`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses the first semantic `rounded_box` enclosure from the worker request.
  - Validates dimensions, wall thickness, and corner radius.
  - Builds a centered OCCT box, applies fillets to enclosure edges, and computes
    bounds, dimensions, surface area, and volume.
  - Returns `occt.rounded_enclosure.metrics.v1` metrics for `preview_mesh`
    requests with `previewMeshEmitted=false`.
  - Keeps OCCT topology, generated B-Rep, preview mesh vertices, STL, and
    triangle IDs out of the response.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Added a process-client smoke for the OCCT target.
  - Verifies capabilities, request ID preservation, sample bounds, dimensions,
    surface area, volume, and non-editable generated geometry flags.
- `test/occt_native_target_scaffold_test.dart`:
  - Updated source-contract expectations from link smoke to metrics smoke.
  - Added smoke-tool contract coverage.
- Docs/tasks/roadmap:
  - Recorded M63 and marked the first rounded box B-Rep task complete while
    leaving shell/cavity, preview mesh, STEP, and STL open.

### Tests run
- `dart format tool\native_occt_worker_metrics_smoke.dart test\occt_native_target_scaffold_test.dart`:
  - Passed; formatted 2 files.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe` and reused already-installed
    OCCT packages.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; capabilities report `metrics_smoke`, response status is `ok`, and
    sample metrics match expected dimensions, area, and volume.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 178 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Yes. The native worker builds the first rounded enclosure B-Rep internally
    and computes deterministic metrics. It does not emit preview mesh yet.
- Serialization checked?
  - Native request/response JSON is exercised through
    `GeometryWorkerProcessClient`.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed; the app still uses the mock preview by
    default.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native OCCT still returns metrics only, not a preview mesh.
  - Severity: Expected.
  - Next action: Add deterministic preview mesh emission from the generated
    B-Rep.
- Issue: Shell/cavity, feature cutouts, STEP, and STL remain unimplemented in
  the native target.
  - Severity: Expected.
  - Next action: Continue in safe geometry slices after the metrics contract is
    stable.

### Next step
Commit and push M63, then continue toward native preview mesh emission.

### Notes for future Codex sessions
Use `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build` after
`tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall` to verify the native
metrics contract. Do not commit `external/`,
`occt_worker/native/vcpkg_installed/`, `build/`, `releases/`, or OCCT DLLs.

## 2026-06-29 - M62 Local OCCT restore and link smoke

### Goal
Restore OCCT locally through the explicit repo-local vcpkg path, make readiness
true, and prove the opt-in native OCCT worker can link and run.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`, `.gitignore`, `README.md`,
`tools/bootstrap_vcpkg_windows.ps1`, `tools/check_occt_windows_readiness.ps1`,
`tools/build_occt_worker_occt.ps1`, `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `occt_worker/README.md`,
`test/occt_windows_readiness_test.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- Local dependency output:
  - Cloned and bootstrapped repo-local vcpkg under ignored `external/vcpkg`.
  - Restored `opencascade[core,freetype]` `8.0.0#1`.
  - Manifest-mode packages landed under ignored
    `occt_worker/native/vcpkg_installed`.
- `.gitignore`:
  - Ignored `occt_worker/native/vcpkg_installed/`.
- `tools/check_occt_windows_readiness.ps1`:
  - Detects repo-local manifest install output.
  - Reports `manifestInstalledRoot`.
  - Fixed Windows PowerShell empty-list binding in `Add-ConfigCandidate`.
- `tools/build_occt_worker_occt.ps1`:
  - Gives a clean `EXIT:2` guidance when OCCT is ready from
    `vcpkg_installed` but `-AllowVcpkgInstall` is omitted.
  - Keeps manifest dependency resolution explicit for the manifest install
    path.
- Docs/tasks/roadmap:
  - Recorded M62 and documented the installed local OCCT path and linked build
    command.
- Tests:
  - Updated script-contract tests for `vcpkg_installed`,
    `manifestInstalledRoot`, and manifest build guidance.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade`:
  - Restored all requested packages successfully in about 1.5 hours.
  - The command then hit a readiness-script bug that was fixed in this chunk.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`:
  - Passed after the fix; reports `ready=true` and finds
    `occt_worker/native/vcpkg_installed/x64-windows/share/opencascade/OpenCASCADEConfig.cmake`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1`:
  - Returned expected `EXIT:2` with guidance to add `-AllowVcpkgInstall` for
    manifest-installed OCCT.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall -Clean`:
  - Passed; built
    `build\occt_worker_native_occt\Release\occt_worker_native_occt.exe` and
    deployed required OCCT DLLs beside it.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; repeat build is quick and reports packages already installed.
- `build\occt_worker_native_occt\Release\occt_worker_native_occt.exe --capabilities`:
  - Passed; reports `status=linked_smoke` and `occtVersion=8.0.0`.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | build\occt_worker_native_occt\Release\occt_worker_native_occt.exe`:
  - Returned expected `worker.backend.occt_link_smoke_only`, preserved request
    ID, and reports `linkSmokeShapeNull=false`.
- `dart format lib test tool occt_worker`:
  - Passed, no files changed.
- `flutter test test\occt_windows_readiness_test.dart test\occt_native_target_scaffold_test.dart test\vcpkg_bootstrap_script_test.dart`:
  - Passed, 8 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1 -RequireOcct`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 177 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.

### Validation
- Geometry checked?
  - Native OCCT link smoke only. The worker creates a smoke shape internally and
    reports `linkSmokeShapeNull=false`, but no semantic B-Rep generation,
    preview mesh, STL workflow, or editable generated geometry was added.
- Serialization checked?
  - Readiness JSON, capabilities JSON, and native request/response JSON were
    exercised. Full protocol tests passed.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `occt_worker_native_occt` still returns
  `worker.backend.occt_link_smoke_only` for geometry requests.
  - Severity: Expected.
  - Next action: Replace the link smoke with the first deterministic rounded
    enclosure B-Rep/metrics response.
- Issue: Manifest-installed OCCT requires `-AllowVcpkgInstall` for linked
  native builds so CMake can resolve transitive vcpkg dependencies.
  - Severity: Expected.
  - Next action: Keep using `tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
    for the repo-local manifest path.

### Next step
Implement the first deterministic OCCT rounded enclosure generation slice behind
the native worker protocol, starting with metrics or a minimal preview response
that remains disposable output and does not expose OCCT topology IDs to Flutter.

### Notes for future Codex sessions
OCCT is now locally ready on this machine. Do not commit `external/`,
`occt_worker/native/vcpkg_installed/`, `build/`, release output, or copied OCCT
DLLs. Use `-AllowVcpkgInstall` for the manifest-installed OCCT path.

## 2026-06-29 - M61 Repo-local vcpkg bootstrap helper

### Goal
Make the Windows OCCT dependency setup reproducible from the repository while
keeping vcpkg sources, installed packages, OCCT binaries, build output, and
release bundles out of Git.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`, `.gitignore`, `README.md`,
`tools/check_occt_windows_readiness.ps1`, `tools/build_occt_worker_occt.ps1`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `occt_worker/README.md`, and
`test/occt_windows_readiness_test.dart`.

### Changes made
- `.gitignore`:
  - Ignored `external/` so repo-local vcpkg output cannot be committed
    accidentally.
- `tools/bootstrap_vcpkg_windows.ps1`:
  - Added a repo-local vcpkg helper with `-PlanOnly`,
    `-InstallOpenCascade`, and `-SetUserEnvironment`.
  - Keeps `opencascade` manifest restore explicit instead of automatic.
- `tools/check_occt_windows_readiness.ps1`:
  - Added auto-detection for `external/vcpkg` when `VCPKG_ROOT` is not set.
  - Reports `rootSource` so readiness output explains where vcpkg came from.
- Tests:
  - Added bootstrap helper safety coverage.
  - Extended readiness script coverage for repo-local vcpkg detection.
- Docs/tasks/roadmap:
  - Recorded the M61 chunk and documented the new helper commands.

### Tests run
- `dart format lib test tool occt_worker`:
  - Formatted `test\vcpkg_bootstrap_script_test.dart`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly`:
  - Passed; printed `shell_case.occt.vcpkg_bootstrap` JSON without cloning or
    installing anything.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`:
  - Passed; readiness remains `false` because no local vcpkg/OCCT install
    exists yet, and now recommends the bootstrap helper.
- `flutter test test\occt_windows_readiness_test.dart test\vcpkg_bootstrap_script_test.dart`:
  - Passed, 4 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 177 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly -InstallOpenCascade`:
  - Passed; printed the large-install plan without restoring dependencies.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.

### Validation
- Geometry checked?
  - Dependency setup only. No generated B-Rep, preview mesh, STL workflow, or
    editable geometry state was added.
- Serialization checked?
  - Bootstrap `-PlanOnly` and readiness JSON contracts were exercised; full
    worker protocol tests passed in the full suite.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: OCCT readiness is still false on this machine.
  - Severity: Expected.
  - Next action: Run `tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade`
    when the long dependency restore is acceptable.
- Issue: The OCCT target remains link-smoke only.
  - Severity: Expected.
  - Next action: After readiness is true, build the OCCT target and add the
    first deterministic rounded enclosure generation response.

### Next step
Run the explicit repo-local vcpkg/OCCT restore, then use
`tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall` to validate the linked
worker before implementing real rounded enclosure B-Rep generation.

### Notes for future Codex sessions
The helper intentionally does not restore `opencascade` unless
`-InstallOpenCascade` is provided. Keep `external/` ignored and do not commit
dependency trees or native binaries.

## 2026-06-29 - M60 OCCT vcpkg manifest restore path

### Goal
Add an explicit opt-in vcpkg manifest restore path for the OCCT-linked native
worker target without making normal Flutter builds or default native checks
install packages silently.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `tools/build_occt_worker_occt.ps1`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/README.md`, and `test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/vcpkg.json`:
  - Added a minimal manifest that declares only the `opencascade` dependency.
- `tools/build_occt_worker_occt.ps1`:
  - Added `-AllowVcpkgInstall`.
  - Keeps the default path readiness-only when OCCT is missing.
  - Enables CMake vcpkg manifest mode only when the flag is present and the
    vcpkg toolchain is discoverable.
- `test/occt_native_target_scaffold_test.dart`:
  - Added manifest parsing coverage and script safety checks for the new flag.
- Docs/tasks/roadmap:
  - Documented the manifest restore path and marked the M60 task complete.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Returned expected `EXIT:2` because this machine still has no configured
    `VCPKG_ROOT`, vcpkg toolchain, or local OCCT config.
- `flutter test test\occt_native_target_scaffold_test.dart`:
  - Passed, 4 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 175 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.

### Validation
- Geometry checked?
  - Dependency plumbing only. No editable generated B-Rep, mesh, STL workflow,
    or product semantics were added to the worker.
- Serialization checked?
  - `vcpkg.json` is parsed by the scaffold test; existing worker protocol tests
    passed in the full suite.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `-AllowVcpkgInstall` cannot proceed until vcpkg is configured locally.
  - Severity: Expected.
  - Next action: Set `VCPKG_ROOT` or provide an explicit OCCT install before
    building the OCCT-linked worker.
- Issue: The OCCT target remains a link/readiness scaffold.
  - Severity: Expected.
  - Next action: After dependency readiness is true, add the first deterministic
    rounded enclosure B-Rep generation slice behind the worker protocol.

### Next step
Configure vcpkg/OCCT locally or add an explicit bootstrap helper, then run
`tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall` and continue toward the
first real rounded enclosure generation response.

### Notes for future Codex sessions
Keep manifest restore opt-in. Do not run a large vcpkg restore from the normal
Flutter build path, and do not commit generated vcpkg trees, OCCT binaries,
worker build output, or `releases/`.

## 2026-06-29 - M59 Opt-in OCCT native target scaffold

### Goal
Add the separate OCCT-linked native worker scaffold without making the default
stub build or normal Flutter app build depend on OCCT.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `occt_worker/native/CMakeLists.txt`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `occt_worker/native/CMakeLists.txt`:
  - Renamed the native project to `shell_case_occt_worker_native`.
  - Added `SHELL_CASE_ENABLE_OCCT`.
  - Kept `occt_worker_native_stub` as the default no-OCCT target.
  - Added opt-in `occt_worker_native_occt` target behind the OCCT option.
- `occt_worker/native/src/occt_main.cpp`:
  - Added OCCT link-smoke source that references `BRepPrimAPI_MakeBox`.
  - Emits capability JSON with `status=linked_smoke`.
  - Returns `worker.backend.occt_link_smoke_only` until semantic B-Rep
    generation is implemented.
- `tools/build_occt_worker_occt.ps1`:
  - Added opt-in build script for the OCCT-linked target.
  - Requires readiness through `tools/check_occt_windows_readiness.ps1`.
  - Does not install vcpkg/OCCT or touch release output.
- `test/occt_native_target_scaffold_test.dart`:
  - Added tests for CMake opt-in wiring, OCCT source contract, and build script
    safety.
- Docs/tasks/roadmap:
  - Recorded M59 and documented the OCCT target build command.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`:
  - Passed; default native stub still builds without OCCT.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1`:
  - Returned expected `EXIT:2` with readiness JSON because local OCCT readiness
    is still false.
- `flutter test test\native_worker_scaffold_test.dart test\occt_native_target_scaffold_test.dart`:
  - Passed, 8 tests.
- `dart format lib test tool occt_worker`:
  - Applied formatting to `test\occt_native_target_scaffold_test.dart`.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting was applied.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; native stub still reports expected not-implemented response and
    preserves request ID.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 174 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Link-smoke scaffold only. No semantic B-Rep generation, preview mesh output,
    STL workflow, or editable generated geometry was introduced.
- Serialization checked?
  - Capability/response contracts are textual in the OCCT source and covered by
    scaffold tests. Existing native stub process smoke still parses through the
    Dart process client.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `occt_worker_native_occt` cannot be built locally until OCCT readiness
  is true.
  - Severity: Expected.
  - Next action: Install/configure vcpkg or set `OpenCASCADE_DIR` / `CASROOT`,
    then rerun `tools\build_occt_worker_occt.ps1`.
- Issue: OCCT target is a link smoke only.
  - Severity: Expected.
  - Next action: After OCCT readiness is true, add deterministic rounded
    enclosure generation behind the same worker protocol.

### Next step
Make OCCT readiness true locally, then build `occt_worker_native_occt` and
replace `worker.backend.occt_link_smoke_only` with the first deterministic
rounded enclosure geometry response.

### Notes for future Codex sessions
Do not wire `occt_worker_native_occt` into normal Flutter builds. Keep it
opt-in behind `SHELL_CASE_ENABLE_OCCT` until native packaging and license
notices are ready.

## 2026-06-29 - M58 OCCT Windows dependency readiness

### Goal
Lock the first Windows OCCT dependency path and add a read-only readiness check
before adding an OCCT-linked native worker target.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `README.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`:
  - Added the Windows OCCT dependency decision note.
  - Records official OCCT build/licensing findings, vcpkg package status, local
    environment snapshot, and the opt-in target strategy.
- `tools/check_occt_windows_readiness.ps1`:
  - Added read-only JSON readiness checker for CMake, vcpkg, `VCPKG_ROOT`,
    `OpenCASCADE_DIR`, `CASROOT`, and common `OpenCASCADEConfig.cmake` paths.
  - Exits `0` by default and exits `2` only when `-RequireOcct` is used and no
    OCCT package config is found.
- `test/occt_windows_readiness_test.dart`:
  - Added tests that keep the checker read-only and keep the dependency note
    explicit about the worker boundary.
- Docs/tasks/roadmap:
  - Added M58, linked the readiness command from README and worker/OCCT docs,
    and appended the research decision to `docs/27_RESEARCH_AND_REFERENCES.md`.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`:
  - Passed with `ready=false`; CMake was found, vcpkg/OCCT package config were
    not found on this machine.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1 -RequireOcct`:
  - Returned expected exit code `2` with the same readiness JSON.
- `flutter test test\occt_windows_readiness_test.dart`:
  - Passed, 2 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format lib test tool occt_worker`:
  - Applied formatting to `test\occt_windows_readiness_test.dart`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting was applied.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; native stub still reports expected not-implemented response and
    preserves request ID.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 171 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Dependency/readiness planning only. No OCCT B-Rep generation, mesh output,
    STL workflow, or editable generated geometry was introduced.
- Serialization checked?
  - Readiness checker emits structured JSON; focused tests cover the contract
    textually and the command was run locally.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Local machine is not ready for OCCT linking yet.
  - Severity: Expected.
  - Next action: Install/configure vcpkg or set `OpenCASCADE_DIR` / `CASROOT`,
    then rerun `tools\check_occt_windows_readiness.ps1 -RequireOcct`.

### Next step
After readiness is true, add a separate opt-in OCCT-linked native target while
keeping `occt_worker_native_stub` buildable without OCCT.

### Notes for future Codex sessions
Do not make normal Flutter builds depend on OCCT. The first OCCT-linked worker
target should be separate from the stub and should only be enabled when
`OpenCASCADEConfig.cmake` is discoverable.

## 2026-06-29 - M57 Native worker request envelope

### Goal
Make the native worker stub read and validate the top-level worker request
envelope before returning scaffold responses.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `README.md`,
`occt_worker/native/src/main.cpp`, `tool/native_worker_stub_smoke.dart`,
`test/native_worker_scaffold_test.dart`, `occt_worker/README.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `occt_worker/native/src/main.cpp`:
  - Replaced stdin discard behavior with a small native request-envelope
    reader.
  - Preserves `requestId` in native scaffold responses.
  - Validates top-level `schema` and planned `operation` values.
  - Returns typed `worker.request.*` issues for empty payloads, non-object
    payloads, invalid schema, and invalid operation.
  - Adds `requestedOperation` response metrics when the operation is available.
- `tool/native_worker_stub_smoke.dart`:
  - Now fails if the native response does not preserve the smoke request ID.
  - Prints `requestId` and `requestIdPreserved` in the JSON summary.
- `test/native_worker_scaffold_test.dart`:
  - Updated scaffold coverage for envelope validation, request issue codes, and
    request ID preservation smoke coverage.
- Docs/tasks/roadmap:
  - Recorded M57 and documented the native envelope validation behavior.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`:
  - Passed; rebuilt
    `C:\Users\EriArk\Documents\CaseMaker\build\occt_worker_native\Release\occt_worker_native_stub.exe`.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; `requestIdPreserved=true` and expected
    `worker.backend.native_not_implemented`.
- Native stub invalid payload smokes:
  - Empty payload returned `worker.request.empty`.
  - Non-object payload returned `worker.request.invalid_json`.
  - Invalid schema preserved `requestId=bad_schema` and returned
    `worker.request.invalid_schema`.
  - Invalid operation preserved `requestId=bad_op` and returned
    `worker.request.invalid_operation`.
- `dart format lib test tool occt_worker`:
  - Applied formatting to `test\native_worker_scaffold_test.dart`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting was applied.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test\native_worker_scaffold_test.dart`:
  - Passed, 5 tests.
- `dart run tool\native_worker_stub_smoke.dart`:
  - Passed; rebuilt the native stub and verified request ID preservation.
- `flutter test --reporter compact`:
  - Passed, 169 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Protocol boundary only. No OCCT B-Rep, mesh generation, STL workflow, or
    editable generated geometry was introduced.
- Serialization checked?
  - Yes. Native responses are protocol-shaped JSON and the Dart process client
    parsed the smoke response successfully.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native worker still uses a minimal envelope reader instead of a full
  native JSON library.
  - Severity: Acceptable for the scaffold.
  - Next action: Decide the native JSON dependency together with OCCT packaging
    before parsing the full semantic project payload.
- Issue: Native worker still returns the expected not-implemented response for
  valid geometry requests.
  - Severity: Expected for the current scaffold.
  - Next action: Start the first real OCCT-backed rounded enclosure generation
    slice after dependency/build research is recorded.

### Next step
Research and lock the Windows OCCT/native dependency path, then add the first
native geometry slice behind the same worker protocol.

### Notes for future Codex sessions
`dart run tool\native_worker_stub_smoke.dart` now checks capability query,
request ID preservation, and the expected native scaffold issue. Native invalid
request responses use `worker.request.*` codes and should stay typed.

## 2026-06-29 - M56 Native worker stub smoke tool

### Goal
Add one developer smoke command that builds the native worker stub, queries
capabilities through the Dart process client, sends a preview request, and
verifies the expected `native_not_implemented` response.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `README.md`,
`occt_worker/README.md`, `docs/03_ARCHITECTURE_OVERVIEW.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`lib/geometry/geometry_service.dart`, and `test/native_worker_scaffold_test.dart`.

### Changes made
- `tool/native_worker_stub_smoke.dart`:
  - Added a smoke command for the native stub build and process-client path.
  - Supports `--skip-build` and `--configuration Debug|Release`.
  - Prints a compact JSON summary with executable path, capability status, and
    request smoke result.
  - Exits nonzero if capabilities fail or the expected native stub response is
    missing.
- `test/native_worker_scaffold_test.dart`:
  - Added coverage that keeps the smoke tool wired to the native build script,
    `GeometryWorkerProcessClient`, capability query, preview request, and
    expected native stub issue code.
- Docs/tasks/roadmap:
  - Documented M56, added the smoke command to developer docs, and kept
    `TASKS.md` aligned with the roadmap.

### Tests run
- `flutter test test\native_worker_scaffold_test.dart`:
  - Passed, 5 tests.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; found the Release native stub, queried capabilities, and received
    expected `worker.backend.native_not_implemented`.
- `dart run tool\native_worker_stub_smoke.dart`:
  - Passed; rebuilt the native stub before running the same smoke path.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 169 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Native stub path only. No OCCT B-Rep generation is implemented in this
    chunk, and no editable mesh/STL state was introduced.
- Serialization checked?
  - Yes. The smoke command sends a semantic `ProjectModel.initial()` preview
    request through the worker process contract.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native worker still returns the expected not-implemented response for
  geometry requests.
  - Severity: Expected for the current scaffold.
  - Next action: Start replacing the stub response with the first real OCCT
    rounded enclosure generation path once the native dependency/build decision
    is locked.

### Next step
Begin the first native geometry implementation slice: keep the semantic request
contract stable, add the minimum native protocol parsing needed by the worker,
and generate a deterministic rounded enclosure shape or a narrower preparatory
slice if OCCT packaging needs one more bridge.

### Notes for future Codex sessions
The fast smoke command is `dart run tool\native_worker_stub_smoke.dart`. It is
safe to use before the full app build because it only touches
`build/occt_worker_native` and expects the native stub to report
`worker.backend.native_not_implemented`.

## 2026-06-29 - M55 Native worker build scaffold

### Goal
Add a separately buildable native worker executable scaffold without linking
OCCT yet or pretending native B-Rep generation is implemented.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `occt_worker/README.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `windows/CMakeLists.txt`,
`windows/runner/CMakeLists.txt`, `.gitignore`, and
`tools/build_latest_windows.ps1`.

### Changes made
- `occt_worker/native/CMakeLists.txt`:
  - Added standalone `occt_worker_native_stub` CMake target.
  - Uses C++17 and compiler warnings as errors.
  - Does not add OCCT includes or dependencies yet.
- `occt_worker/native/src/main.cpp`:
  - Added native executable scaffold.
  - Emits `shell_case.geometry.worker.capabilities` for `--capabilities`.
  - Returns structured `worker.backend.native_not_implemented` response for
    geometry requests.
  - Keeps generated/native details out of editable project semantics.
- `tools/build_occt_worker_stub.ps1`:
  - Added safe build script for `build/occt_worker_native`.
  - Includes child-path checks before optional clean/removal.
- `test/native_worker_scaffold_test.dart`:
  - Added tests for CMake target shape, capability JSON, not-implemented
    response JSON, and build-script output confinement.
- Docs/tasks/roadmap:
  - Recorded M55 and documented the native stub build command.

### Tests run
- `flutter test test\native_worker_scaffold_test.dart`:
  - Passed, 4 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`:
  - Passed; built
    `C:\Users\EriArk\Documents\CaseMaker\build\occt_worker_native\Release\occt_worker_native_stub.exe`.
- `build\occt_worker_native\Release\occt_worker_native_stub.exe --capabilities`:
  - Passed; returned `shell_case.geometry.worker.capabilities`,
    `activeBackend=native`, `nativeStatus=stub`.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | build\occt_worker_native\Release\occt_worker_native_stub.exe`:
  - Returned expected exit code `2`, `backend=occt_worker_native_stub`, and
    `worker.backend.native_not_implemented`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 168 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Native executable scaffold only. No OCCT B-Rep, STL, editable mesh, or
    topology IDs were introduced.
- Serialization checked?
  - Yes. Tests parse native stub capability/response JSON from the C++ source,
    and executable smoke commands returned valid JSON.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native worker stub does not parse request JSON or preserve request IDs.
  - Severity: Expected scaffold limitation.
  - Next action: replace stub response path with a real native protocol handler
    once JSON dependency/build policy is chosen.
- Issue: OCCT is not linked yet.
  - Severity: Expected.
  - Next action: add OCCT dependency/build policy and first rounded enclosure
    B-Rep generation.

### Next step
Commit and push M55, then continue toward native protocol handling or the first
OCCT-backed rounded enclosure generation slice.

### Notes for future Codex sessions
The native stub build is intentionally separate from Flutter. Keep native worker
artifacts under `build/occt_worker_native` until packaging policy is decided.

---

## 2026-06-29 - M54 Worker capability process client

### Goal
Let Dart callers query worker capability metadata through the same process
adapter used for geometry requests, with typed parsing and normalized failures.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_worker_runtime.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`test/geometry_worker_runtime_test.dart`,
`test/geometry_worker_process_client_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_capabilities.dart`:
  - Added standalone capability model/parsers.
  - Moved capability JSON shape out of worker runtime.
  - Added typed backend capability parsing for supported/planned operations.
- `lib/geometry/geometry_worker_runtime.dart`:
  - Uses the shared capability model.
- `lib/geometry/geometry_worker_process_client.dart`:
  - Added `GeometryWorkerProcessCommand.copyWith`.
  - Added `GeometryWorkerCapabilitiesResult`.
  - Added `queryCapabilities()`.
  - Appends `--capabilities` without duplicating it.
  - Normalizes launch failures, timeouts, invalid capability JSON, and non-zero
    capability exits into typed issues.
- `lib/geometry/geometry_service.dart`:
  - Exports worker capability types through the geometry boundary.
- `test/geometry_worker_process_client_test.dart`:
  - Added capability query success and failure coverage.
- Docs/tasks/roadmap:
  - Recorded M54 and documented process-client capability querying.

### Tests run
- `flutter test test\geometry_worker_process_client_test.dart`:
  - Passed, 10 tests.
- `flutter test test\geometry_worker_runtime_test.dart`:
  - Passed, 8 tests.
- `dart run occt_worker\bin\occt_worker.dart --capabilities`:
  - Passed; emitted `shell_case.geometry.worker.capabilities`,
    `activeBackend=mock`, `mockStatus=available`, `nativeStatus=stub`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 164 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Process metadata only; no generated B-Rep, STL, editable mesh, or OCCT
    topology was introduced.
- Serialization checked?
  - Yes. Capability JSON parses into typed Dart models and process-client tests
    cover malformed responses.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Capability querying is not yet used by `GeometryBackendSettings` or
  the UI.
  - Severity: Low.
  - Next action: use it when native backend launch policy or user-visible
    backend diagnostics are added.
- Issue: Native backend is still a stub.
  - Severity: Expected.
  - Next action: continue toward the first native worker scaffold or rounded
    enclosure B-Rep slice.

### Next step
Commit and push M54, then continue toward native worker scaffold/build or first
OCCT-backed enclosure generation.

### Notes for future Codex sessions
Use `GeometryWorkerProcessClient.queryCapabilities()` before assuming a worker
command can handle native geometry. The query result is runtime metadata only
and must not become editable project data.

---

## 2026-06-29 - M53 Worker capability contract

### Goal
Let the local worker report backend readiness and supported/planned operations
without requiring a geometry request payload.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_worker_runtime.dart`,
`test/geometry_worker_runtime_test.dart`, `README.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_runtime.dart`:
  - Added `GeometryWorkerCapabilities`.
  - Added `GeometryWorkerBackendCapability`.
  - Added `--capabilities` runtime parsing.
  - Capability JSON reports protocol schema/version, active/default backend,
    semantic-project source of truth, and non-editable generated geometry.
  - Capability JSON marks `mock` as available for `preview_mesh`.
  - Capability JSON marks `native` as a stub with planned preview/export/validate
    operations and `worker.backend.native_not_implemented`.
- `test/geometry_worker_runtime_test.dart`:
  - Added unit coverage for capability metadata.
  - Added process coverage for
    `dart run occt_worker\bin\occt_worker.dart --capabilities`.
- Docs/tasks/roadmap:
  - Recorded M53 and documented the capability command in README, worker docs,
    and geometry architecture notes.

### Tests run
- `flutter test test\geometry_worker_runtime_test.dart`:
  - Passed, 8 tests.
- `dart run occt_worker\bin\occt_worker.dart --capabilities`:
  - Passed; emitted `shell_case.geometry.worker.capabilities` JSON with
    `mock` available and `native` stub.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 159 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Metadata contract only. No native OCCT geometry was generated.
- Serialization checked?
  - Yes. Capability JSON is generated deterministically and parsed in tests.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; capability JSON marks export as planned for native.

### Known issues
- Issue: Native backend remains a stub.
  - Severity: Expected.
  - Next action: continue toward native worker scaffold/build and first rounded
    enclosure B-Rep slice.
- Issue: Capability JSON is not consumed by the Flutter UI yet.
  - Severity: Low.
  - Next action: use it when worker backend selection becomes user-visible or
    when native backend launch policy is finalized.

### Next step
Commit and push M53, then continue toward the first native worker scaffold or
OCCT-backed rounded enclosure generation slice.

### Notes for future Codex sessions
Use `dart run occt_worker\bin\occt_worker.dart --capabilities` to inspect the
current worker readiness contract before changing worker launch or native
backend behavior.

---

## 2026-06-29 - M52 Local occt_worker CLI

### Goal
Create the canonical local worker command under `occt_worker/` so process
tests, smoke commands, and future worker integration target the real boundary
path instead of a temporary tool script.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_worker_protocol.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`lib/geometry/geometry_service.dart`, `tool/mock_geometry_worker.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_runtime.dart`:
  - Added `GeometryWorkerRuntime`.
  - Added backend mode parsing with `mock` default and explicit `native` stub.
  - Added stdin/stdout runner shared by worker entrypoints.
  - Returns structured JSON and exit code `2` for protocol/config/backend
    errors.
- `occt_worker/bin/occt_worker.dart`:
  - Added the canonical local worker CLI.
  - Reads geometry request JSON from stdin and emits geometry response JSON.
- `tool/mock_geometry_worker.dart`:
  - Kept as a compatibility alias over the shared local worker runtime.
- `tool/mock_geometry_worker_client_smoke.dart` and
  `tool/mock_worker_geometry_service_smoke.dart`:
  - Updated process commands to use `occt_worker/bin/occt_worker.dart`.
- `test/geometry_worker_runtime_test.dart`:
  - Added coverage for default mock runtime behavior, backend argument parsing,
    invalid payload responses, native not-implemented responses, invalid CLI
    argument JSON, and real process-client execution of the canonical CLI.
- Docs/tasks/roadmap:
  - Recorded M52, canonical worker commands, native stub behavior, and current
    limitations.

### Tests run
- `flutter test test\geometry_worker_runtime_test.dart`:
  - Passed, 6 tests.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart`:
  - Passed; returned `status=ok`, `backend=mock`, `featureIntents=4`, and
    `operationCount=10`.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart --backend=native`:
  - Returned expected exit code `2`, `backend=occt_worker_stub`, and
    `worker.backend.native_not_implemented`.
- `dart run tool\mock_geometry_worker_client_smoke.dart`:
  - Passed through the canonical CLI.
- `dart run tool\mock_worker_geometry_service_smoke.dart`:
  - Passed through the canonical CLI with `responseStatus=ok`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 157 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Worker CLI/protocol boundary only. The default backend is still mock
    geometry; native mode explicitly reports not implemented.
- Serialization checked?
  - Yes. CLI and process-client tests round-trip request/response JSON.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `--backend=native` is a stub and does not call OCCT yet.
  - Severity: Expected.
  - Next action: add the first native worker build/scaffold or OCCT-backed
    geometry slice after checking build/distribution details.
- Issue: Local worker CLI is Dart-only.
  - Severity: Acceptable bridge.
  - Next action: keep this protocol path stable while replacing the backend
    implementation behind it.

### Next step
Commit and push M52, then continue toward the first native worker scaffold or
rounded enclosure generation slice.

### Notes for future Codex sessions
Use `dart run occt_worker\bin\occt_worker.dart` as the canonical worker smoke.
Keep `tool/mock_geometry_worker.dart` only for compatibility unless old docs or
scripts still depend on it.

---

## 2026-06-29 - M51 Generated geometry protocol fixtures

### Goal
Make `occt_worker/protocol` example request/response JSON reproducible from
typed Dart models and the mock backend, instead of maintaining large protocol
fixtures by hand.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_service.dart`, `lib/project/project_model.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `tool/generate_geometry_protocol_fixtures.dart`:
  - Added a generator for the worker preview request and response examples.
  - Builds the fixture from `ProjectModel.initial()` plus projected button and
    standoff feature groups.
  - Uses `MockGeometryService` to produce the response fixture.
- `occt_worker/protocol/preview_request.example.json`:
  - Regenerated with four semantic `featureIntents`: `front_usb_c`,
    `abxy_buttons`, `projected_buttons`, and `standoff_mounts_1`.
  - Includes expanded projected button and standoff group items.
- `occt_worker/protocol/preview_response.example.json`:
  - Regenerated from the mock backend.
  - Includes operation-plan metrics with `operationCount=10`.
- `test/geometry_protocol_fixture_test.dart`:
  - Added fixture coverage for expected feature intents, group item counts,
    response metrics, and mock rebuild parity.
- Docs/tasks/roadmap:
  - Recorded M51 fixture regeneration command, current mock-backend limitation,
    and backend-only poke checklist.

### Tests run
- `dart run tool\generate_geometry_protocol_fixtures.dart`:
  - Passed; reported `featureIntents=4` and `operationCount=10`.
- `flutter test test\geometry_protocol_fixture_test.dart`:
  - Passed, 3 tests.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart`:
  - Passed; returned `status=ok`, `backend=mock`, `featureIntents=4`,
    `operationCount=10`, and 10 operation-plan entries.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 151 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Protocol/fixture path only. The response is mock backend output with a
    deterministic preview mesh and operation plan, not native OCCT B-Rep.
- Serialization checked?
  - Yes. Fixture request/response are decoded back into typed geometry models,
    and the request rebuilds through `MockGeometryService`.
- UI checked?
  - Full widget test suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The generated response fixture is still mock output, not native OCCT
  geometry.
  - Severity: Expected.
  - Next action: continue toward the first native `occt_worker` executable.
- Issue: The fixture project is a curated protocol sample, not a user-facing
  project template.
  - Severity: Acceptable.
  - Next action: keep fixture scenarios small and deterministic as worker
    coverage grows.

### Next step
Commit and push M51, then continue with the next safe worker/geometry chunk.

### Notes for future Codex sessions
Regenerate fixtures with `dart run tool\generate_geometry_protocol_fixtures.dart`
after changing feature intent serialization, operation planning, or mock
geometry response metrics.

---

## 2026-06-29 - M50 Geometry backend selection

### Goal
Add an explicit developer/runtime backend selector so the app can choose mock
or worker-backed geometry through one factory while keeping mock as the normal
default.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/app/case_maker_app.dart`,
`lib/main.dart`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_backend.dart`:
  - Added `GeometryBackendKind`.
  - Added `GeometryBackendSettings`.
  - Added `createGeometryService(settings)`.
  - Added `createGeometryServiceFromEnvironment()` using compile-time
    `--dart-define` values.
  - Added pipe-separated worker argument parsing for developer runs.
  - Falls back to mock when worker backend is requested without an executable.
- `lib/app/case_maker_app.dart`:
  - Uses the backend factory by default.
  - Keeps optional `geometryService` injection for tests and explicit callers.
- `test/geometry_backend_test.dart`:
  - Covers default mock selection, explicit worker selection, safe fallback,
    and argument parsing.
- Docs/tasks/roadmap:
  - Recorded M50 behavior, safe default, and the developer `--dart-define`
    switch.

### Tests run
- `flutter test test\geometry_backend_test.dart`:
  - Passed, 4 tests.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 148 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Backend selection only; no generated B-Rep, STL, editable mesh, or OCCT
    topology is introduced.
- Serialization checked?
  - Not affected.
- UI checked?
  - Full widget suite passes; normal app builds still instantiate mock geometry.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Worker backend selection still targets a mock worker unless a real
  worker executable is configured.
  - Severity: Expected.
  - Next action: add the first native `occt_worker` executable slice.
- Issue: Worker arguments are pipe-separated, which is simple but not a full
  shell parser.
  - Severity: Acceptable developer-only limitation.
  - Next action: replace with config-file or JSON args if worker launch needs
    complex quoting.

### Next step
Commit and push M50, then continue toward the native `occt_worker` executable
or a richer generated-geometry fixture.

### Notes for future Codex sessions
Keep backend selection behind `GeometryService`. Do not make widgets branch on
backend kind, process command, or native worker details.

---

## 2026-06-29 - M49 Worker GeometryService adapter

### Goal
Add an app-facing `GeometryService` adapter over the worker process client
without switching the default Flutter shell away from the stable mock backend.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`test/geometry_worker_process_client_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_service.dart`:
  - Added reusable `defaultSelectableSurfaces(project)`.
  - Updated `MockGeometryService` to use the shared semantic surface catalog.
  - Added `WorkerGeometryService`.
  - Routes `buildGeometry` through `GeometryWorkerProcessClient`.
  - Routes `generatePreview` through a preview-mesh worker request and reports
    backend/status/preview/intent/operation stats.
  - Keeps validation local through `ProjectSemanticValidator`.
- `test/geometry_worker_service_test.dart`:
  - Added coverage for build routing, preview stats, worker error stats, and
    local semantic validation.
- `tool/mock_worker_geometry_service_smoke.dart`:
  - Added a developer smoke command for the full
    `WorkerGeometryService -> process client -> mock worker` path.
- Docs/tasks/roadmap:
  - Recorded M49 behavior, current limitations, smoke command, and poke
    checklist.

### Tests run
- `flutter test test\geometry_worker_service_test.dart`:
  - Passed, 4 tests.
- `dart run tool\mock_worker_geometry_service_smoke.dart`:
  - Passed; `exit=0`, `backend=mock`, `responseStatus=ok`,
    `featureIntents=2`, `operationCount=2`, `surfaceCount=3`.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 144 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Adapter path only; it still uses mock geometry in smoke tests and does not
    introduce generated B-Rep, editable mesh, STL, or OCCT topology.
- Serialization checked?
  - Worker service tests verify preview requests carry feature intents through
    process payloads.
- UI checked?
  - Full widget suite passes; the default app shell still uses
    `MockGeometryService`.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `WorkerGeometryService` is not the default runtime backend.
  - Severity: Expected.
  - Next action: add a deliberate developer/backend switch only when useful.
- Issue: `WorkerGeometryService` uses semantic/local validation and selectable
  surface IDs until native worker validation/surface mapping exists.
  - Severity: Expected.
  - Next action: replace only the generated-geometry side first, keeping stable
    semantic IDs at the UI boundary.

### Next step
Commit and push M49, then continue toward either a deliberate backend switch or
the first native `occt_worker` executable slice.

### Notes for future Codex sessions
`WorkerGeometryService` is the intended app-facing bridge for native geometry.
Do not make widgets call process clients directly; keep all backend switching
behind `GeometryService`.

---

## 2026-06-29 - M48 Worker process client

### Goal
Add a process-boundary client for geometry requests so a future native
`occt_worker` can be launched through stdin/stdout without coupling Flutter to
OCCT internals.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_protocol.dart`, `lib/geometry/geometry_worker_protocol.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_process_client.dart`:
  - Added `GeometryWorkerProcessCommand`.
  - Added `GeometryWorkerProcessClient.buildGeometry`.
  - Added the default `Process.start` runner that writes request JSON to stdin
    and captures stdout/stderr.
  - Preserves structured worker error responses from non-zero worker exits.
  - Normalizes launch failures, timeouts, invalid response JSON, and non-zero
    clean responses into `GeometryResponse` errors.
- `tool/mock_geometry_worker_client_smoke.dart`:
  - Added a developer smoke command that launches `tool/mock_geometry_worker.dart`
    as a child process and prints the geometry response.
- `test/geometry_worker_process_client_test.dart`:
  - Added fake-runner coverage for request payloads, worker error preservation,
    invalid response JSON, non-zero exits, and timeouts.
- Docs/tasks/roadmap:
  - Recorded M48 behavior, smoke command, limitations, and poke checklist.

### Tests run
- `flutter test test\geometry_worker_process_client_test.dart`:
  - Passed, 5 tests.
- `dart run tool\mock_geometry_worker_client_smoke.dart`:
  - Passed; `exit=0`, `status=ok`, `backend=mock`, `featureIntents=2`,
    `operationCount=2`.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 140 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Process adapter only; no generated B-Rep, STL, editable mesh, or OCCT
    topology is introduced.
- Serialization checked?
  - Tests verify request JSON crosses the process client with feature intents.
- UI checked?
  - Full widget suite passes; the default app shell still uses the in-process
    mock service.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The process client is not yet wired into the default Flutter runtime.
  - Severity: Expected.
  - Next action: add an explicit backend switch only when a real worker or
    intentional developer mode needs it.
- Issue: `tool/mock_geometry_worker_client_smoke.dart` still uses mock geometry.
  - Severity: Expected.
  - Next action: replace the command target with native `occt_worker` once it
    exists.

### Next step
Commit and push M48, then continue toward a worker-backed `GeometryService`
adapter or the first native `occt_worker` executable slice.

### Notes for future Codex sessions
Keep worker failures as `GeometryResponse` issues. Native stderr, exit codes,
and process command details are diagnostics only; they must not become editable
project semantics or UI selection IDs.

---

## 2026-06-29 - M47 Mock worker protocol harness

### Goal
Exercise the worker JSON boundary through a local stdin/stdout harness before
the native OCCT executable exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_protocol.dart`, `test/geometry_protocol_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_protocol.dart`:
  - Added `GeometryWorkerProtocolHandler`.
  - Converts request JSON to response JSON.
  - Reports structured errors for invalid JSON, invalid top-level shape, and
    missing `project` payloads.
  - Uses a `buildGeometry` callback so the handler is backend-agnostic.
- `tool/mock_geometry_worker.dart`:
  - Added a Dart stdin/stdout smoke harness backed by `MockGeometryService`.
  - Returns exit code `2` when the geometry response contains errors.
- `lib/project/project_model.dart`:
  - Stopped exporting the Flutter/file-selector-backed dialog service so
    geometry/worker code can import the semantic model in a pure Dart CLI.
- `lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`, and
  `test/project_file_service_test.dart`:
  - Added explicit imports for `project_file_dialog_service.dart` where the
    desktop dialog helper is actually used.
- Docs/tasks/roadmap:
  - Recorded M47 behavior, smoke command, and the fact that the real native
    `occt_worker` executable is still future work.

### Tests run
- `flutter test test\geometry_protocol_test.dart`:
  - Passed, 12 tests.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart`:
  - Passed; `exit=0`, `status=ok`, `backend=mock`.
- `'{not json' | dart run tool\mock_geometry_worker.dart`:
  - Passed; `exit=2`, `status=error`, code
    `worker.request.invalid_json`.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 135 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Protocol harness only; no generated B-Rep, STL, editable mesh, or OCCT
    topology is introduced.
- Serialization checked?
  - Geometry protocol tests cover worker JSON handling and invalid request
    responses.
- UI checked?
  - Full widget suite passes; no user-facing UI behavior changed.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `tool/mock_geometry_worker.dart` is a Dart mock harness, not a native
  OCCT worker.
  - Severity: Expected.
  - Next action: implement the real native worker after the OCCT build path is
    ready.
- Issue: The sample protocol fixture does not yet include feature intents, so
  its mock `operationCount` is `0`.
  - Severity: Low.
  - Next action: add a richer protocol fixture when worker operation tests need
    request-time cutout/mount tasks.

### Next step
Commit and push M47, then continue toward the real worker adapter/native
`occt_worker` slice or a larger UI workflow chunk.

### Notes for future Codex sessions
Keep semantic model exports pure Dart. UI-only desktop services such as file
dialogs should be imported explicitly by UI/tests, not exported through
`project_model.dart`, because worker tooling needs to run with plain `dart run`.

---

## 2026-06-29 - M46 Geometry operation plan

### Goal
Convert geometry feature intents into deterministic backend operation tasks
without adding real OCCT/B-Rep generation yet.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_service.dart`, `test/geometry_protocol_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/33_COMPONENT_FEATURE_PROJECTION.md`,
and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_operation_plan.dart`:
  - Added `GeometryBuildOperation`.
  - Added `GeometryOperationPlanner.fromRequest`.
  - Maps semantic feature intents to backend operation kinds such as
    `cutout.usb_c` and `recess.glass`.
  - Maps button group items to `cutout.button` operations.
  - Maps standoff mount items to `mount.standoff` operations.
- `lib/geometry/geometry_service.dart`:
  - Exports the operation-plan API.
  - Mock backend reports `operationCount` and `operationPlan` metrics.
- `test/geometry_protocol_test.dart`:
  - Added deterministic operation-plan coverage.
  - Extended mock backend metrics coverage.
- Docs/tasks/roadmap:
  - Recorded M46 behavior and worker boundary expectations.

### Tests run
- `flutter test test\geometry_protocol_test.dart`:
  - Passed, 9 tests.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 132 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Operation planning only; no generated B-Rep, mesh, STL, or OCCT topology is
    stored.
- Serialization checked?
  - Geometry protocol tests cover request intents and operation-plan metrics.
- UI checked?
  - Full widget suite passes; no UI behavior changes are expected.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Operation plan is mock/backend planning data only.
  - Severity: Expected.
  - Next action: use these operations in a worker/adapter when real geometry
    generation begins.
- Issue: Operation kinds are first-pass labels, not final OCCT algorithm
  selection.
  - Severity: Expected.
  - Next action: refine operation kinds when implementing real cut/add/recess
    B-Rep steps.

### Next step
Commit and push M46, then continue toward worker/adapter consumption or the
next UI workflow slice.

### Notes for future Codex sessions
Operation plans are disposable backend task lists. Keep editable project state
semantic and grouped; do not persist operation-plan items as independent user
features.

---

## 2026-06-29 - M45 Geometry feature intent protocol

### Goal
Carry semantic feature and feature-group generation intent through
`GeometryRequest` so the future OCCT worker can consume prepared backend input
without depending on Flutter UI state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_service.dart`, `test/geometry_protocol_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/33_COMPONENT_FEATURE_PROJECTION.md`,
and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_protocol.dart`:
  - Added `GeometryFeatureIntent` and `GeometryFeatureItemIntent`.
  - `GeometryRequest.previewMesh(project)` now includes semantic feature
    intents derived from `ProjectModel.features` and
    `ProjectModel.featureGroups`.
  - Feature-group intents preserve pattern/itemPrototype/placement/source data.
  - Button group and standoff mount intents include derived item positions for
    backend consumption.
- `lib/geometry/geometry_service.dart`:
  - Mock backend reports received feature-intent count in metrics.
- `test/geometry_protocol_test.dart`:
  - Added request round-trip coverage for semantic feature intents.
  - Added button group item expansion coverage.
  - Added standoff mount template-hole fallback expansion coverage.
- Docs/tasks/roadmap:
  - Recorded M45 protocol behavior and worker boundary expectations.

### Tests run
- `flutter test test\geometry_protocol_test.dart`:
  - Passed, 8 tests.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 131 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Protocol payload only; no real B-Rep/mesh generation was added.
- Serialization checked?
  - Geometry request JSON round-trip covers feature intents and group items.
- UI checked?
  - Full widget suite passes; no UI behavior changes are expected.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Feature intents are consumed only by the mock backend metrics for now.
  - Severity: Expected first-pass limitation.
  - Next action: teach the real worker/adapter to generate cutout and mount
    operations from these intents.
- Issue: Group item expansion is request-time derived data.
  - Severity: Intentional.
  - Next action: keep editable project semantics as groups and avoid persisting
    derived geometry items into project JSON.

### Next step
Commit and push M45, then continue toward geometry-service consumption of these
feature intents or the next UI/placement workflow chunk.

### Notes for future Codex sessions
`featureIntents` are disposable backend request data. They must not become the
editable source of truth and must not include OCCT topology IDs or preview mesh
triangle IDs.

---

## 2026-06-29 - M44 Projected anchor validation

### Goal
Make projected component anchors participate in semantic validation before real
geometry generation consumes them.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/validation/project_semantic_validator.dart`,
`test/project_semantic_validator_test.dart`,
`docs/33_COMPONENT_FEATURE_PROJECTION.md`, and validation/status docs.

### Changes made
- `lib/validation/project_semantic_validator.dart`:
  - Validates projected USB-C `surfacePosition` against target surface bounds.
  - Validates component-sourced button group switch positions against target
    surface bounds.
  - Warns when projected feature/group source placement/template/feature
    references are missing.
  - Warns when projected `surfaceAxes` are missing or mismatch the target
    surface.
- `test/project_semantic_validator_test.dart`:
  - Added outside-surface USB-C validation coverage.
  - Added outside-lid button group validation coverage.
  - Added missing-source projected feature warning coverage.
- Docs/tasks/roadmap:
  - Added M44 to `ROADMAP.md`.
  - Marked projected anchor validation done in `TASKS.md`.
  - Updated projection, testing, and shell validation docs.

### Tests run
- `flutter test test\project_semantic_validator_test.dart`:
  - Passed, 11 tests.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 129 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic validation only; no B-Rep, mesh, STL, or topology IDs are stored.
- Serialization checked?
  - Existing project JSON tests and projected metadata tests still pass.
- UI checked?
  - Full widget suite passes; validation status continues to consume semantic
    validator results.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Surface-bound validation uses the first enclosure body's inner extents.
  - Severity: Expected first-pass limitation.
  - Next action: make target enclosure explicit before multi-body generation.
- Issue: Validation checks bounds and source references, not physical
  reachability/travel/clearance yet.
  - Severity: Expected.
  - Next action: add reachability checks before real cutouts/plungers.

### Next step
Commit and push M44, then continue toward either projected-anchor-driven
geometry requests or richer component-driven cutout/button generation.

### Notes for future Codex sessions
Projected-anchor validation should stay semantic. Do not validate by reading
preview pixels, mesh triangles, or OCCT face IDs.

---

## 2026-06-29 - M43 Projected component feature anchors

### Goal
Add a semantic projection layer that turns placed component feature anchors into
world and target-surface coordinates for component-driven ports and buttons.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`, `docs/17_SWITCH_MAPPING_SYSTEM.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
`docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/component_features/component_feature_projection.dart`:
  - Added `ComponentFeatureSurfaceProjector` and `ComponentFeatureProjection`.
  - Applies component placement `rotationZ` and emits component-local, rotated,
    world, and surface positions.
  - Maps `front/back` to `x,z`, `left/right` to `y,z`, and `top/bottom` to
    `x,y` target surface coordinates.
- `lib/ui/shell/workspace_shell.dart`:
  - Uses the projector for component-sourced USB-C and switch button group
    commands.
  - Stores projected USB-C anchor metadata in `SemanticFeature.placement`.
  - Stores projected switch positions in
    `FeatureGroup.pattern.switchPositions`.
- Tests:
  - Added unit coverage for connector/switch projection and unsupported
    directions.
  - Extended widget-save coverage for projected USB-C and switch metadata.
- Docs/tasks/roadmap:
  - Added `docs/33_COMPONENT_FEATURE_PROJECTION.md`.
  - Recorded the M43 chunk and marked projected component feature anchors done.

### Tests run
- `flutter test test\component_feature_projection_test.dart`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component USB-C rail command creates sourced cutout"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 126 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Projection metadata only; no B-Rep, mesh, STL, or OCCT topology is stored.
- Serialization checked?
  - Widget tests save the project and verify projected anchor metadata in JSON.
- UI checked?
  - Existing component-sourced USB-C and button commands still open/confirm via
    widget tests.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Projection targets the first enclosure body.
  - Severity: Expected first-pass limitation.
  - Next action: add explicit target enclosure selection before multi-body
    generation.
- Issue: Projection records positions but does not yet perform reachability or
  boundary validation on the target face.
  - Severity: Expected.
  - Next action: add face-local validation before real cutouts/plungers.

### Next step
Commit and push M43, then continue toward validation/geometry consumption of
projected anchors.

### Notes for future Codex sessions
Projected anchor metadata is a semantic bridge only. Do not replace it with
mesh coordinates or OCCT topology IDs; future geometry should consume these
semantic coordinates through `GeometryService`.

---

## 2026-06-29 - M42 Component switch button group

### Goal
Let a selected semantic component placement create one editable button group from
its switch centers, while keeping the old surface-selected manual button group
flow intact.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, `docs/17_SWITCH_MAPPING_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, and the existing
command/widget/pattern tests.

### Changes made
- `lib/commands/command_registry.dart`:
  - Allows `button.create_group` from surface and component contexts.
- `lib/ui/shell/workspace_shell.dart`:
  - Keeps the manual surface-selected button group command.
  - Enables the button group command for selected component placements with
    switch features.
  - Creates a semantic `button_group` with source placement/template IDs and
    saved switch-center positions.
  - Preserves source pattern, placement, overrides, and metadata when the dialog
    confirms.
- `lib/patterns/pattern_layout.dart`:
  - Uses saved `switchPositions` for `from_component_switches` groups.
  - Keeps generated row/grid/diamond fallback layouts available after manual
    detach/edit.
- Tests:
  - Added command availability, pattern layout, detach, and widget-save coverage
    for component-sourced button groups.
- Docs/tasks/roadmap:
  - Recorded M42 behavior, limitations, tests, and poke checklist.

### Tests run
- `flutter test test\pattern_layout_test.dart --plain-name "button group positions prefer saved semantic switch centers"`:
  - Passed.
- `flutter test test\command_registry_test.dart --plain-name "button group command works from surface and component context"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "button group rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "button group rail command can be cancelled"`:
  - Passed.
- `flutter test test\pattern_layout_test.dart --plain-name "button group layout can detach from saved switch centers"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 123 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic pattern generation only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Widget test saves the project and verifies group source IDs plus switch
    positions in JSON.
- UI checked?
  - Widget tests cover old surface flow, cancel flow, and new selected-component
    flow.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The generated group stores template switch centers, but not yet
  projected face-local component coordinates.
  - Severity: Expected first-pass limitation.
  - Next action: add projected placement metadata before real geometry cuts.
- Issue: This creates a semantic editable button group; it does not yet cut real
  generated geometry.
  - Severity: Expected.
  - Next action: connect semantic feature groups to geometry service/OCCT worker
    later.

### Next step
Commit and push M42, then continue with the next component-to-semantic feature
slice or projected component feature placement data.

### Notes for future Codex sessions
Component-driven buttons must remain one editable `FeatureGroup`; do not flatten
switches into unrelated individual holes unless the user explicitly detaches the
group later.

---

## 2026-06-27 — Documentation pack created

### Goal
Create initial documentation package for Codex based on product discussion.

### Changes made
- Added AGENTS.md, TASKS.md, WORKLOG.md.
- Added detailed subsystem docs under `docs/`.
- Added templates and examples.

### Next step
Import docs into repository and start Phase 0 / Phase 1 tasks.

---

## 2026-06-26 — Repository documentation orientation

### Goal
Study the newly added project documentation and check local/GitHub repository state.

### Read before work
`AGENTS.md`, `README.md`, `TASKS.md`, `MANIFEST.json`, all `docs/*.md`, examples, and templates.

### Changes made
- `TASKS.md`:
  - Added a Phase 0 task to configure the GitHub `origin` remote and push the initial documentation commit.
- `WORKLOG.md`:
  - Added this orientation entry.

### Tests run
- Not run; this was a documentation/repository orientation pass only.

### Validation
- Confirmed documentation pack contains 42 manifest entries.
- Confirmed local repository has no commits yet.
- Confirmed local repository has no configured `origin` remote.
- Confirmed the GitHub repository page is public but currently empty.

### Known issues
- Issue: local Git repository is not connected to `https://github.com/EriArk/Shell-Case-Easy-Maker`.
  - Severity: Medium.
  - Next action: add `origin`, create the first commit, and push.

### Next step
Bootstrap the Flutter desktop project or publish the documentation pack to GitHub first.

### Notes for future Codex sessions
The core product direction is semantic enclosure/device/accessory generation, not generic CAD. Keep Flutter isolated from OCCT internals through `GeometryService`, keep generated B-Rep/meshes as outputs, and add tests for geometry, serialization, validation, and UI state changes.

---

## 2026-06-26 — Flutter bootstrap and semantic shell

### Goal
Publish the initial documentation commit, create the Flutter desktop skeleton, and replace the counter app with a product-aligned shell.

### Read before work
`AGENTS.md`, `TASKS.md`, `docs/00_PROJECT_VISION.md`, `docs/01_PRODUCT_RULES.md`, `docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/05_PROJECT_FILE_FORMAT.md`, and `docs/26_TESTING_AND_QUALITY.md`.

### Changes made
- Git repository:
  - Renamed the initial branch to `main`.
  - Added `origin` as `https://github.com/EriArk/Shell-Case-Easy-Maker.git`.
  - Created and pushed the initial documentation commit.
- Flutter project:
  - Created Windows/Linux/macOS Flutter desktop scaffold with project name `shell_case_easy_maker`.
  - Replaced the default counter app with a viewport-first workspace shell.
- `lib/project/project_model.dart`:
  - Added an initial semantic project model with versioned JSON serialization.
- `lib/geometry/geometry_service.dart`:
  - Added `GeometryService`, selectable semantic surfaces, preview metadata, and a mock backend.
- `lib/commands/app_command.dart`:
  - Added an initial command metadata skeleton.
- `lib/validation/validation_result.dart`:
  - Added validation report/message models.
- `lib/ui/shell/workspace_shell.dart`:
  - Added top toolbar, left icon rail, central mock viewport, right inspector, view cube placeholder, and status bar.
- `test/`:
  - Added widget and project serialization tests.
- `README.md`:
  - Added development quick-start commands.
- `TASKS.md`:
  - Marked completed Phase 0 bootstrap items.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 3 tests.

### Validation
- Geometry checked?
  - Mock geometry service only; no OCCT geometry yet.
- Serialization checked?
  - Yes, `ProjectModel` JSON round-trip test.
- UI checked?
  - Yes, widget test caught and verified the shell after fixing a toolbar overflow.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: GitHub CLI is not installed in this environment.
  - Severity: Low.
  - Next action: continue using `git push`, or install `gh` later if PR automation is needed.
- Issue: Basic CI is still missing.
  - Severity: Medium.
  - Next action: add a Flutter analyze/test GitHub Actions workflow.
- Issue: Geometry is still mocked.
  - Severity: Expected for Phase 0.
  - Next action: research Flutter viewport options or begin deeper semantic model work before OCCT integration.

### Next step
Add basic CI, then continue Phase 1 with stronger typed semantic models, migrations, command registry, and undo/redo transaction design.

### Notes for future Codex sessions
Keep committing and pushing at the end of each meaningful work session. The current app shell intentionally uses semantic surface IDs and a mock `GeometryService`; do not let UI code depend on OCCT topology or generated mesh IDs.

---

## 2026-06-27 — Basic Flutter CI

### Goal
Add a basic GitHub Actions workflow that validates formatting, analysis, and tests on `main`.

### Read before work
`AGENTS.md`, `TASKS.md`, `docs/26_TESTING_AND_QUALITY.md`, `docs/27_RESEARCH_AND_REFERENCES.md`, GitHub Actions checkout documentation, Flutter continuous delivery documentation, and `subosito/flutter-action` documentation.

### Changes made
- `.github/workflows/flutter-ci.yml`:
  - Added `Flutter CI` workflow for pushes and pull requests targeting `main`.
  - Pinned Flutter to `3.44.2` and enabled Flutter/pub caching.
  - Runs dependency install, format check, analyzer, and tests.
- `README.md`:
  - Added CI status badge.
- `docs/27_RESEARCH_AND_REFERENCES.md`:
  - Added research note for Flutter GitHub Actions setup and license compatibility.
- `TASKS.md`:
  - Marked basic CI complete.
- `WORKLOG.md`:
  - Added this worklog entry.

### Tests run
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 3 tests.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; CI validates existing tests only.
- Serialization checked?
  - Covered by `flutter test`.
- UI checked?
  - Covered by widget test in `flutter test`.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: CI does not build desktop packages yet.
  - Severity: Low.
  - Next action: add platform build jobs later during packaging work.

### Next step
Continue Phase 1 by strengthening typed project models and introducing a real command registry/undo design.

### Notes for future Codex sessions
Keep CI lightweight until platform packaging dependencies are intentionally researched and documented.

---

## 2026-06-27 — Roadmap and latest Windows bundle path

### Goal
Create the working roadmap and make the latest Windows build easy to open manually.

### Read before work
`AGENTS.md`, `TASKS.md`, `docs/28_IMPLEMENTATION_PLAN.md`, `README.md`, `.gitignore`, and Windows Flutter CMake configuration.

### Changes made
- `ROADMAP.md`:
  - Added the main 1-2 day chunk roadmap with done criteria, tests, and poke checklists.
- `tools/build_latest_windows.ps1`:
  - Added a Windows release script that builds Flutter, refreshes `releases/latest/windows`, and prints the `.exe` path.
- `.gitignore`:
  - Ignored generated local release bundles under `releases/`.
- `README.md`:
  - Documented `ROADMAP.md`, the build script, and the latest local `.exe` path.
- `TASKS.md`:
  - Linked the roadmap and marked roadmap/latest Windows build tasks complete.
- `WORKLOG.md`:
  - Added this worklog entry.

### Tests run
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 3 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed and created `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed; Git reported expected CRLF normalization for `.gitignore`.

### Validation
- Geometry checked?
  - Not applicable; this chunk only changes roadmap/build access.
- Serialization checked?
  - Covered by existing tests after validation.
- UI checked?
  - Build bundle was created and is ready for manual launch.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: `releases/latest/windows` is local-only and must be regenerated after app changes.
  - Severity: Low.
  - Next action: run `tools/build_latest_windows.ps1` after each meaningful UI/runtime chunk.

### Next step
Continue with M1 Semantic Core from `ROADMAP.md`.

### Notes for future Codex sessions
The latest manual Windows app should be opened from `releases/latest/windows/shell_case_easy_maker.exe`, not by copying only the `.exe` elsewhere.

---

## 2026-06-27 — M1 Semantic Core

### Goal
Split the semantic project model into focused typed modules with versioned JSON parsing and tests.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`, `docs/28_IMPLEMENTATION_PLAN.md`, existing `lib/project/project_model.dart`, existing project tests, and example JSON fixtures.

### Changes made
- `lib/project/`:
  - Split the semantic model into focused files for schema constants, JSON helpers, enclosure, component placement, feature, feature group, component template, migration, and project model.
  - Added typed `ComponentTemplate`/board/hole/feature/zone models.
  - Added `ProjectMigration` as the central schema migration entrypoint.
  - Preserved unknown semantic metadata during JSON round-trips so future subsystem fields and root project metadata are not dropped.
- `test/project_model_test.dart`:
  - Added tests for minimal migration defaults, fixture parsing, component template round-trips, metadata preservation, and newer-version rejection.
- `docs/05_PROJECT_FILE_FORMAT.md`:
  - Documented the current implementation skeleton.
- `ROADMAP.md` and `TASKS.md`:
  - Marked completed M1/Phase 1 semantic model items.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 8 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; no geometry backend changes.
- Serialization checked?
  - Yes, project and component template round-trip tests cover fixtures and defaults.
- UI checked?
  - Widget test still covers shell rendering; latest Windows bundle was regenerated for manual launch.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Many subsystem-specific feature fields are preserved as metadata rather than fully typed.
  - Severity: Low.
  - Next action: type them as each subsystem is implemented.

### Next step
Run final validation, regenerate the latest Windows bundle, then continue with M2 Commands + Undo.

### Notes for future Codex sessions
Keep `ProjectModel` semantic-only. Do not add generated meshes, STL paths as source data, OCCT topology, or triangle IDs to these models.

---

## 2026-06-27 — M2 Commands and Undo

### Goal
Add command metadata, command availability rules, and undo/redo transaction foundations.

### Read before work
`AGENTS.md`, `ROADMAP.md`, existing `lib/commands/app_command.dart`, `lib/ui/shell/workspace_shell.dart`, and command/undo expectations from project docs.

### Changes made
- `lib/commands/`:
  - Added stable command IDs, command registry, command availability rules, and snapshot-based undo history.
  - Added continuous transaction grouping for future knob/drag/encoder edits.
- `lib/ui/shell/workspace_shell.dart`:
  - Connected toolbar and rail labels/icons to command metadata while preserving the existing layout.
- `docs/31_COMMANDS_AND_UNDO.md`:
  - Documented command metadata, context, registry, undo behavior, and current limitations.
- `test/`:
  - Added tests for core command metadata, availability, advanced mode gating, undo/redo, redo clearing, and continuous grouping.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M2 command/undo items complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 16 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; no geometry backend changes.
- Serialization checked?
  - Existing serialization tests still pass.
- UI checked?
  - Widget test still covers shell rendering; latest Windows bundle was regenerated for manual launch.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Commands are metadata-only and do not dispatch semantic edits yet.
  - Severity: Expected for M2.
  - Next action: wire commands into selection/project editing during M3/M2 follow-up.
- Issue: Undo history is not connected to UI state yet.
  - Severity: Expected for M2.
  - Next action: connect it when project editing commands exist.

### Next step
Run final validation, refresh latest Windows bundle, then continue with M3 Usable Shell.

### Notes for future Codex sessions
Keep command availability based on semantic context: selected object ID, active surface ID, advanced mode, and undo/redo state. Do not base command availability on raw mesh or OCCT IDs.

---

## 2026-06-27 — M3 Usable Shell

### Goal
Make the shell useful for manual semantic exploration by adding selection,
contextual inspector updates, a compact project browser, and basic project JSON
file service.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, existing project model files,
`lib/ui/shell/workspace_shell.dart`, command registry files, and current tests.

### Changes made
- `lib/selection/`:
  - Added `SelectionModel` for workspace/object/surface focus.
  - Added `ProjectSelectionResolver` to describe selected semantic state for
    inspector/status UI without putting business rules in widgets.
- `lib/ui/shell/workspace_shell.dart`:
  - Added a compact semantic project browser.
  - Connected selected project, enclosure, surface, component, template, and
    feature to the inspector and status hint.
  - Connected tool rail availability to selection-driven `CommandContext`.
  - Added mock viewport highlights for selected semantic items.
- `lib/project/project_file_service.dart`:
  - Added JSON encode/decode and disk read/write helpers for project files.
- `docs/32_USABLE_SHELL.md`:
  - Documented selection, browser, inspector details, and current limits.
- `docs/31_COMMANDS_AND_UNDO.md`:
  - Updated the limitation note now that selection context exists.
- `test/`:
  - Added tests for selection context, selection resolver, project file service,
    and contextual inspector widget behavior.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M3 usable shell items complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 26 tests.

### Validation
- Geometry checked?
  - Mock viewport only; selected semantic items now show mock highlights.
- Serialization checked?
  - Yes, `ProjectFileService` encode/decode and disk round-trip tests.
- UI checked?
  - Yes, widget tests cover selecting an enclosure and a semantic feature.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Save/load is service-level only and not wired to native file dialogs.
  - Severity: Expected for M3.
  - Next action: add explicit open/save command dispatch after the command
    controller layer exists.
- Issue: Viewport selection is still browser-driven, not direct hit testing.
  - Severity: Expected before M4.
  - Next action: research and implement viewport interaction in M4.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
continue with M4 Viewport MVP research and interaction model.

### Notes for future Codex sessions
Keep selection semantic. Do not introduce triangle IDs, raw OCCT IDs, or mesh
hit-test IDs as editable project state.

---

## 2026-06-27 — M4 Viewport MVP

### Goal
Research Flutter viewport options and add the first interactive mock viewport:
orbit, pan, zoom, fit, semantic hit testing, and ghost preview state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/27_RESEARCH_AND_REFERENCES.md`,
`lib/ui/shell/workspace_shell.dart`, selection files, and current tests.

### Changes made
- `docs/27_RESEARCH_AND_REFERENCES.md`:
  - Added research note for Flutter viewport options, package candidates,
    licensing, and the decision to keep M4 on `CustomPaint`.
- `lib/viewport/viewport_controller.dart`:
  - Added `ViewportController`, `ViewportState`, ghost preview state, shared
    mock layout, and semantic hit testing.
- `lib/ui/shell/workspace_shell.dart`:
  - Added primary-drag orbit, secondary/middle-drag pan, wheel zoom, click
    selection in the viewport, fit via the view cube, camera-aware mock drawing,
    and surface ghost previews.
- `docs/33_VIEWPORT_MVP.md`:
  - Documented the viewport state model, current controls, ghost previews,
    renderer decision, and limits.
- `test/viewport_controller_test.dart`:
  - Added tests for orbit/pan/zoom bounds, fit behavior, ghost preview state,
    and semantic hit-test outputs.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M4 viewport MVP items complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 31 tests.

### Validation
- Geometry checked?
  - Mock viewport only; no generated OCCT geometry yet.
- Serialization checked?
  - Existing project serialization tests still pass.
- UI checked?
  - Widget tests still pass; viewport controller tests cover interaction state.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Viewport is still a stylized mock, not generated preview mesh.
  - Severity: Expected for M4.
  - Next action: define preview mesh/worker protocol in M5.
- Issue: Hit testing uses deterministic mock zones.
  - Severity: Expected for M4.
  - Next action: later replace with semantic face/object mappings from
    generated preview data, never raw triangle IDs as editable state.
- Issue: View cube is a compact fit control, not full orientation navigation.
  - Severity: Low.
  - Next action: expand after real viewport behavior stabilizes.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
continue with M5 First Geometry Slice.

### Notes for future Codex sessions
M4 intentionally adds no 3D renderer dependency. Revisit renderer choices after
`GeometryService` has a concrete preview mesh protocol and semantic face mapping.

---

## 2026-06-27 — M5 First Geometry Slice

### Goal
Create the first real geometry boundary: OCCT research, typed request/response
protocol, `occt_worker` skeleton, deterministic mock preview mesh, and rounded
enclosure implementation plan.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
OCCT official overview/build/licensing/modeling/mesh/STEP documentation, and
current geometry/viewport tests.

### Changes made
- `lib/geometry/geometry_protocol.dart`:
  - Added typed JSON request/response models for geometry operations.
  - Added preview mesh, semantic surface mapping, bounds, artifact, and issue
    models.
- `lib/geometry/geometry_service.dart`:
  - Added `buildGeometry(GeometryRequest)` to the service boundary.
  - Kept existing mock preview behavior usable.
  - Added deterministic mock preview mesh response with semantic surface IDs.
- `occt_worker/`:
  - Added worker boundary README.
  - Added preview request/response example JSON files.
- `docs/27_RESEARCH_AND_REFERENCES.md`:
  - Added OCCT first geometry slice research with official source links.
- `docs/34_FIRST_GEOMETRY_SLICE.md`:
  - Documented protocol shape, preview mesh mapping, rounded enclosure plan,
    and current limitations.
- `test/geometry_protocol_test.dart`:
  - Added protocol round-trip tests, semantic mapping checks, deterministic mock
    mesh checks, and unsupported operation behavior.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M5 protocol/skeleton work complete while keeping real OCCT B-Rep,
    worker executable, and export tasks open.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 35 tests.

### Validation
- Geometry checked?
  - Protocol-level and mock mesh only; no native OCCT executable yet.
- Serialization checked?
  - Yes, request/response protocol round-trip tests.
- UI checked?
  - Existing widget tests still pass; mock preview remains usable.
- Export checked?
  - Not implemented yet; mock backend rejects export operations explicitly.

### Known issues
- Issue: No native `occt_worker` executable exists yet.
  - Severity: Expected for M5 protocol slice.
  - Next action: choose Windows OCCT distribution path, then add worker build.
- Issue: Mock preview mesh is a cuboid, not rounded B-Rep output.
  - Severity: Expected.
  - Next action: implement rounded box B-Rep generation behind the worker.
- Issue: STEP/STL export operations are protocol placeholders only.
  - Severity: Expected.
  - Next action: add exporters after B-Rep generation is stable.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
start the first native worker/build slice.

### Notes for future Codex sessions
Keep raw OCCT topology inside the worker. Flutter may receive disposable preview
triangle ranges for rendering, but semantic selection/editing must use semantic
IDs from the protocol.

---

## 2026-06-27 — M6 Parameter Model

### Goal
Add typed parameter schemas with units, ranges, steps, defaults, choices, and
validation before generator UI and geometry commands depend on raw maps.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, existing project JSON helpers, validation
model, and current geometry/selection tests.

### Changes made
- `lib/parameters/parameter_model.dart`:
  - Added parameter kinds for length, angle, count, ratio, boolean, choice, and
    text.
  - Added parameter definitions, ranges, options, schemas, issues, defaults,
    normalization, snap/clamp, and raw input validation.
  - Added `CoreParameterSchemas.roundedEnclosure` for first enclosure generator
    controls.
- `test/parameter_model_test.dart`:
  - Added tests for defaults, range snap/clamp, range/choice validation, JSON
    round-trip, and invalid raw values after default application.
- `docs/35_PARAMETER_MODEL.md`:
  - Documented the parameter model, defaults/validation flow, first schema, and
    current limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M6/parameter model complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 40 tests.

### Validation
- Geometry checked?
  - Not applicable; this chunk does not change generated geometry.
- Serialization checked?
  - Yes, parameter schema JSON round-trip test.
- UI checked?
  - Existing widget tests still pass; no new parameter UI yet.
- Export checked?
  - Not applicable.

### Known issues
- Issue: Parameter model is not wired into inspector widgets yet.
  - Severity: Expected for M6 foundation.
  - Next action: use schemas when implementing generator commands/inspector
    controls.
- Issue: Cross-parameter rules are not implemented.
  - Severity: Expected.
  - Next action: add generator-specific validation for constraints such as
    corner radius fitting within body dimensions.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
continue with generator command wiring or first native worker build slice.

### Notes for future Codex sessions
Keep parameter schemas separate from generated geometry. Use them to feed UI
controls and generator validation, not to replace semantic project models.

---

## 2026-06-27 — M7 Enclosure Parameter Inspector

### Goal
Wire the rounded enclosure parameter schema into the contextual inspector so
the first enclosure can be edited as semantic project data.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`docs/35_PARAMETER_MODEL.md`, current shell widgets, geometry service, viewport
controller, and widget/protocol tests.

### Changes made
- `lib/project/enclosure.dart` and `lib/project/project_model.dart`:
  - Added small immutable update helpers for enclosure/project edits.
- `lib/parameters/enclosure_parameter_adapter.dart`:
  - Added mapping between `Enclosure` fields and
    `CoreParameterSchemas.roundedEnclosure`.
  - Keeps edits semantic and applies schema defaults/snapping.
- `lib/ui/shell/workspace_shell.dart`:
  - Added local editable project state inside the shell.
  - Added compact inspector controls for selected enclosure parameters.
  - Refreshes mock preview and validation after parameter changes.
- `lib/geometry/geometry_service.dart`:
  - Mock preview mesh bounds now use semantic enclosure dimensions from the
    request project.
- `lib/viewport/viewport_controller.dart`:
  - Mock viewport layout can react to enclosure width/depth/corner radius.
- `docs/32_USABLE_SHELL.md` and `docs/35_PARAMETER_MODEL.md`:
  - Documented the first parameter inspector wiring and current limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M7 complete.

### Tests run
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 46 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed; refreshed `releases/latest/windows`.

### Validation
- Geometry checked?
  - Mock protocol bounds now follow semantic enclosure dimensions.
- Serialization checked?
  - Existing project serialization tests still pass.
- UI checked?
  - Widget test edits enclosure width through the inspector and observes the
    semantic size row update.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Inspector edits are local only; toolbar save/open is not wired.
  - Severity: Expected.
  - Next action: connect edits to command/undo/save flow.
- Issue: Undo history is not connected to parameter edits yet.
  - Severity: Important before larger editing workflows.
  - Next action: route parameter edits through commands/transactions.
- Issue: Cross-parameter validation is still minimal.
  - Severity: Expected.
  - Next action: add generator validation for wall/radius/body relationships.

### Next step
Commit and push M7, then continue with command/undo wiring for parameter edits
or the first native `occt_worker` executable slice.

### Notes for future Codex sessions
Keep the default enclosure workflow generator-first. The inspector should expose
semantic maker controls, not raw sketch/extrude/boolean operations.

---

## 2026-06-27 — M8 Parameter Undo/Redo

### Goal
Route first enclosure parameter edits through semantic undo/redo so parameter
exploration is reversible.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, current workspace shell, command registry, and
widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced local mutable project field with `UndoHistory<ProjectModel>`.
  - Commits effective enclosure parameter edits as semantic transactions.
  - Enables/disables toolbar undo/redo from real history state.
  - Restores project snapshots and refreshes preview/validation on undo/redo.
  - Added stable toolbar command keys for widget coverage.
- `test/widget_test.dart`:
  - Added coverage for editing enclosure width, undoing it, and redoing it.
- `docs/31_COMMANDS_AND_UNDO.md` and `docs/32_USABLE_SHELL.md`:
  - Documented first undo wiring and current command limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M8 complete.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 47 tests.

### Validation
- Geometry checked?
  - Mock preview/validation refresh after undo/redo.
- Serialization checked?
  - Existing project serialization tests still pass.
- UI checked?
  - Widget test verifies toolbar undo/redo availability and semantic size
    restoration.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: There is still no command dispatcher/controller layer.
  - Severity: Expected.
  - Next action: introduce command execution before wiring more tools.
- Issue: Undo grouping for continuous knobs/sliders is not used by inspector
  fields yet.
  - Severity: Expected.
  - Next action: use continuous transactions for drag/knob controls later.
- Issue: Save/load commands are still not wired to the edited project state.
  - Severity: Important before real project use.
  - Next action: connect file commands after command dispatcher shape is clear.

### Next step
Refresh latest Windows bundle, run final validation, commit, push, then continue
with command execution or save/load wiring.

### Notes for future Codex sessions
Keep undo snapshots semantic. Preview generation and any future OCCT artifacts
must be refreshable outputs, not undo state.

---

## 2026-06-27 — M9 Project Open/Save

### Goal
Wire native desktop open/save dialogs to semantic project JSON so edited
projects can be persisted and reopened.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `ProjectFileService`, command registry, and shell
widget tests.

### Dependency check
- Added `file_selector` `^1.1.0`.
- Checked pub.dev package metadata:
  - publisher: `flutter.dev`,
  - purpose: native file dialogs,
  - supported platforms include Windows,
  - license metadata: `BSD-3-Clause`.
- No plugin source code was copied.

### Changes made
- `lib/project/project_file_dialog_service.dart`:
  - Added `ProjectFileDialogService` seam.
  - Added `FileSelectorProjectFileDialogService` using `file_selector`.
  - Added `.enclosure.json` suffix helper.
- `lib/ui/shell/workspace_shell.dart`:
  - Added open/save toolbar wiring.
  - Save writes current semantic `ProjectModel`.
  - Open loads project JSON, resets undo history, selection, and preview state.
  - Status bar reports file operation state.
- `lib/commands/command_ids.dart` and `lib/commands/command_registry.dart`:
  - Added workspace open/save commands.
- `test/project_file_service_test.dart`, `test/command_registry_test.dart`,
  and `test/widget_test.dart`:
  - Added extension, command metadata, save, and open coverage.
  - Widget tests use fake dialog/file services instead of native dialogs or
    real disk IO.
- `docs/05_PROJECT_FILE_FORMAT.md`, `docs/27_RESEARCH_AND_REFERENCES.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented open/save behavior, dependency decision, and limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M9 complete.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 51 tests.

### Validation
- Geometry checked?
  - Preview refreshes after opening a project.
- Serialization checked?
  - Save/open tests verify semantic project JSON round-trip behavior.
- UI checked?
  - Widget tests verify save and open toolbar commands with fakes.
- Export checked?
  - STL/STEP export remains future work and is separate from project save.

### Known issues
- Issue: No unsaved-changes prompt before opening another project.
  - Severity: Important before real daily use.
  - Next action: add dirty tracking and confirm dialog.
- Issue: No separate "Save As" command yet.
  - Severity: Expected for compact first slice.
  - Next action: add when command/menu structure expands.
- Issue: Dependency license notices are not bundled yet.
  - Severity: Packaging-stage task.
  - Next action: handle in packaging/license chunk.

### Next step
Refresh latest Windows bundle, run final validation, commit, push, then add
dirty-state prompts or continue toward first real generator command.

### Notes for future Codex sessions
Project save/open is not geometry export. Keep editable files semantic; STEP,
STL, DXF, preview meshes, and OCCT artifacts must stay generated outputs.

---

## 2026-06-27 — M10 Unsaved Changes Guard

### Goal
Prevent accidental loss of unsaved semantic edits when opening another project.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/32_USABLE_SHELL.md`, current workspace shell, and widget save/open tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added persisted semantic project fingerprint tracking.
  - Added dirty status in the bottom status bar.
  - Saving updates the clean baseline.
  - Opening a project updates the clean baseline and resets undo history.
  - Opening while dirty shows a confirmation dialog before invoking the file
    picker.
  - Canceling the dirty dialog keeps the current project unchanged.
- `test/widget_test.dart`:
  - Added coverage for dirty open cancel.
  - Added coverage for dirty open confirm/discard.
- `docs/05_PROJECT_FILE_FORMAT.md` and `docs/32_USABLE_SHELL.md`:
  - Updated open/save behavior and limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M10 complete.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test/widget_test.dart -r expanded`:
  - Passed, 8 widget tests.
- `flutter test`:
  - Passed, 53 tests.

### Validation
- Geometry checked?
  - Not directly changed; preview refresh still happens on confirmed open.
- Serialization checked?
  - Dirty tracking compares semantic project JSON fingerprints.
- UI checked?
  - Widget tests verify cancel preserves current edits and does not call the
    file dialog; confirm loads the target project and resets undo.
- Export checked?
  - Not changed.

### Known issues
- Issue: Dirty tracking is currently in the shell rather than a document
  controller.
  - Severity: Expected for the current architecture slice.
  - Next action: move document state into a controller when more commands are
    wired.
- Issue: There is no separate "Save As" command yet.
  - Severity: Expected.
  - Next action: add when menu/command surface expands.

### Next step
Run full validation, refresh latest Windows bundle, commit, push, then continue
with either dirty/document controller cleanup or first real generator command.

### Notes for future Codex sessions
Dirty state must remain semantic. Do not include generated preview meshes,
OCCT artifacts, or transient viewport state in the persisted fingerprint.

---

## 2026-06-27 — Save Dialog Stability Fix

### Goal
Fix unstable Windows save dialog behavior where the native save window could
close before the user completed the save flow.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Removed the pre-picker `setState` before native open/save dialogs.
  - Kept the `_fileBusy` re-entry guard, but without rebuilding the toolbar
    while the native picker is opening.
  - Status messages now update after the native picker returns a file path, not
    before the picker opens.
- `test/widget_test.dart`:
  - Added a regression test proving save picker is invoked once, repeat clicks
    are ignored by the guard, and no "saving" status is shown before the picker
    returns.

### Tests run
- `dart format lib/ui/shell/workspace_shell.dart test/widget_test.dart`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test/widget_test.dart -r expanded`:
  - Passed, 9 widget tests.
- `flutter test`:
  - Passed, 54 tests.

### Validation
- UI checked?
  - Automated regression covers the risky pre-picker rebuild path.
- Serialization checked?
  - Existing save test still verifies written semantic project JSON.

### Next step
Run full validation, rebuild latest Windows bundle, commit, and push.

---

## 2026-06-28 — M11 First Generator Command

### Goal
Make the left tool rail execute the first real semantic generator command in a
safe, undoable slice.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/35_PARAMETER_MODEL.md`,
`lib/ui/shell/workspace_shell.dart`, command registry files, parameter adapter,
and current widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added a small command action map for first wired rail commands.
  - Wired `enclosure.create` to a compact create-enclosure dialog.
  - Reused the rounded enclosure parameter schema and adapter for dialog values.
  - Routed created enclosure state through the shared semantic undo pipeline.
  - Disabled rail commands that are not implemented yet.
- `test/widget_test.dart`:
  - Added coverage for create, cancel, undo, and disabled future rail commands.
- `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/35_PARAMETER_MODEL.md`:
  - Documented M11 and the first executable generator command.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 12 widget tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 57 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the created enclosure edit.
- Serialization checked?
  - Existing semantic project serialization and file tests still pass.
- UI checked?
  - Widget tests cover create, cancel, undo, and disabled unwired rail commands.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: There is still no central command dispatcher/controller.
  - Severity: Expected for this slice.
  - Next action: introduce it when more rail commands need shared execution
    behavior.
- Issue: The create-enclosure dialog is first-pass and not a guided wizard yet.
  - Severity: Low.
  - Next action: add presets, richer validation, and clearer generator flow in a
    later enclosure-first chunk.

### Next step
Commit and push M11, then continue with the next safe generator or shell
interaction chunk.

### Notes for future Codex sessions
Keep rail commands honest: visible future tools are okay, but they should stay
disabled until they have semantic behavior, tests, and undo considerations.

---

## 2026-06-28 — M12 Place Component Command

### Goal
Make the second left rail generator command create semantic component
placements from existing component templates.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`lib/project/project_model.dart`, component template/placement models, current
workspace shell, and command/widget tests.

### Changes made
- `lib/project/project_model.dart`:
  - Added `replaceComponentPlacement()` for stable-ID append/replace behavior.
- `lib/commands/command_registry.dart`:
  - Made `component.place` available from workspace and enclosure context.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `component.place` from the left rail when templates exist.
  - Added a compact placement dialog for template, X/Y/Z, mounting side, and
    lock state.
  - Commits new placements through semantic undo history.
  - Coerces selection back to workspace if undo removes the selected semantic
    object.
- `test/command_registry_test.dart`, `test/project_model_test.dart`, and
  `test/widget_test.dart`:
  - Added coverage for command scope, placement append/replace, create, cancel,
    undo, and no-template disabled state.
- `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/05_PROJECT_FILE_FORMAT.md`:
  - Documented M12 and the first component placement command.

### Tests run
- `flutter test test\command_registry_test.dart test\project_model_test.dart test\widget_test.dart`:
  - Passed, 29 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 62 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after placement changes; no generated geometry
    source state is added.
- Serialization checked?
  - Component placement append/replace is covered at model level.
- UI checked?
  - Widget tests cover place, cancel, undo, and no-template disabled state.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Component placement is still numeric-dialog driven, not viewport
  picking/snapping.
  - Severity: Expected for this slice.
  - Next action: add viewport picking and snapping after command flows settle.
- Issue: Component-driven cutouts/mounts are not generated from the placement
  yet.
  - Severity: Expected.
  - Next action: implement component-driven feature generation in a later chunk.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M12.

### Notes for future Codex sessions
Component templates remain semantic mechanical templates. Placements should
later drive holes, mounts, clearances, and keepouts without flattening those
requests into unrelated raw geometry.

---

## 2026-06-28 — M13 USB-C Cutout Command

### Goal
Make the first surface-based rail command create a semantic USB-C cutout on the
selected enclosure face.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`lib/project/feature.dart`, `lib/project/project_model.dart`, current
workspace shell, selection resolver, and widget/model tests.

### Changes made
- `lib/project/project_model.dart`:
  - Added `replaceFeature()` for stable-ID append/replace behavior.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `port.add_usb_c` from the left rail only when a semantic surface is
    selected.
  - Added a compact USB-C dialog for width, height, corner radius, and
    clearance profile.
  - Creates a semantic `usb_c_cutout` feature targeted at the active surface.
  - Commits the new feature through semantic undo history and selects it.
- `test/project_model_test.dart` and `test/widget_test.dart`:
  - Added coverage for feature append/replace, disabled-without-surface,
    create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/05_PROJECT_FILE_FORMAT.md`:
  - Documented M13 and the first surface-based generator command.

### Tests run
- `flutter test test\project_model_test.dart test\widget_test.dart`:
  - Passed, 26 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 65 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the feature edit; no generated geometry is
    stored as editable state.
- Serialization checked?
  - Semantic feature append/replace is covered at model level.
- UI checked?
  - Widget tests cover selected surface enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: USB-C placement is targeted by selected surface only, without
  face-local picking/snapping yet.
  - Severity: Expected for this slice.
  - Next action: add face-local placement controls after viewport picking is
    ready.
- Issue: The cutout is semantic only; no OCCT/B-Rep cut is generated yet.
  - Severity: Expected.
  - Next action: feed semantic features into real geometry generation later.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M13.

### Notes for future Codex sessions
Surface commands should continue to use semantic surface IDs from selection.
Do not couple feature creation to raw triangle IDs or OCCT topology names.

---

## 2026-06-28 — M14 Button Group Command

### Goal
Make the next surface-based rail command create an editable semantic button
pattern group instead of flattening repeated buttons into independent holes.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
`lib/project/feature_group.dart`, `lib/project/project_model.dart`,
`ProjectSelectionResolver`, and current widget/model tests.

### Changes made
- `lib/project/project_model.dart`:
  - Added `replaceFeatureGroup()` for stable-ID append/replace behavior.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `button.create_group` from the left rail only when a semantic surface
    is selected.
  - Added a compact button group dialog for layout, count, diameter, spacing,
    and mode.
  - Creates a semantic `FeatureGroup` with editable pattern and item prototype
    data.
  - Commits the new group through semantic undo history and selects it.
- `lib/selection/project_selection_resolver.dart`:
  - Improved feature group inspector details for layout/count/spacing/diameter.
- `test/project_model_test.dart`, `test/project_selection_resolver_test.dart`,
  and `test/widget_test.dart`:
  - Added coverage for feature group append/replace, inspector details,
    disabled-without-surface, create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
  `docs/32_USABLE_SHELL.md`:
  - Documented M14 and the first editable pattern group command.

### Tests run
- `flutter test test\project_model_test.dart test\project_selection_resolver_test.dart test\widget_test.dart`:
  - Passed, 33 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 69 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the group edit; generated geometry is still a
    future output.
- Serialization checked?
  - Feature group append/replace is covered at model level.
- UI checked?
  - Widget tests cover selected surface enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Button group placement is centered metadata only, without face-local
  picking/snapping.
  - Severity: Expected for this slice.
  - Next action: add face-local placement controls after viewport picking is
    ready.
- Issue: Pattern item positions are not generated or previewed yet.
  - Severity: Expected.
  - Next action: add deterministic pattern expansion tests before geometry
    generation consumes groups.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M14.

### Notes for future Codex sessions
Button groups must remain editable feature groups. Do not flatten them into
unrelated `SemanticFeature` holes unless the user explicitly detaches a pattern.

---

## 2026-06-28 — M15 Glass Recess Command

### Goal
Make the next surface-based rail command create a semantic glass/insert recess
on the selected enclosure face.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
current workspace shell, selection resolver, and widget/resolver tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `glass.create_recess` from the left rail only when a semantic surface
    is selected.
  - Added a compact glass recess dialog for window size, recess depth, ledge
    width, corner radius, insert thickness, and clearance profile.
  - Creates a semantic `glass_recess` feature targeted at the active surface.
  - Commits the new recess through semantic undo history and selects it.
- `lib/selection/project_selection_resolver.dart`:
  - Added a human label for `glass_recess` features.
- `test/project_selection_resolver_test.dart` and `test/widget_test.dart`:
  - Added coverage for the display label, disabled-without-surface state,
    create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M15 and the first glass recess command.

### Tests run
- `flutter test test\project_selection_resolver_test.dart test\widget_test.dart`:
  - Passed, 26 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 72 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the feature edit; generated geometry remains a
    future output.
- Serialization checked?
  - Existing semantic feature serialization path is reused.
- UI checked?
  - Widget tests cover selected surface enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Glass recess placement is selected-surface plus dialog dimensions only,
  without face-local picking/snapping.
  - Severity: Expected for this slice.
  - Next action: add face-local placement controls after viewport picking is
    ready.
- Issue: DXF/glass contour export is not generated yet.
  - Severity: Expected.
  - Next action: feed `glass_recess` features into geometry/export pipeline
    later.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M15.

### Notes for future Codex sessions
Glass/insert recesses are semantic features. Keep DXF contours, B-Rep, and mesh
outputs generated from this semantic source rather than storing them in the
editable project file.

---

## 2026-06-28 — M16 Mount Generation Command

### Goal
Make the first component-driven rail command create editable semantic standoff
mounts from the selected component placement's mounting holes.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
current workspace shell, selection resolver, component template model, and
widget/resolver tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `mount.generate` from the left rail only when a selected
    `ComponentPlacement` resolves to a template with mounting holes.
  - Added a compact mount dialog for standoff diameter, hole diameter, height,
    and clearance profile.
  - Creates a semantic `standoff_mounts` `FeatureGroup` with source
    placement/template IDs and template mounting-hole positions.
  - Commits the new group through semantic undo history and selects it.
  - Added human browser titles/icons for glass recess and standoff mount groups.
- `lib/selection/project_selection_resolver.dart`:
  - Added the human label and inspector details for `standoff_mounts`.
- `test/project_selection_resolver_test.dart` and `test/widget_test.dart`:
  - Added coverage for mount group display, disabled-without-component state,
    create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M16 and the current boundary between semantic mount groups and
    future generated geometry.

### Tests run
- `flutter test test\widget_test.dart test\project_selection_resolver_test.dart`:
  - Passed, 29 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 75 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the feature group edit; real stand-off
    geometry is still future OCCT/GeometryService work.
- Serialization checked?
  - The existing `FeatureGroup` JSON path stores the semantic mount group data.
- UI checked?
  - Widget tests cover component selection enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Mount generation currently creates semantic group data only, without
  generated OCCT/B-Rep stand-off bodies.
  - Severity: Expected for this slice.
  - Next action: feed `standoff_mounts` into geometry worker once the first
    real geometry generator is ready.
- Issue: Mount target surface mapping is coarse and follows current placement
  side values.
  - Severity: Expected.
  - Next action: refine target surfaces when face-local placement/snapping and
    inner lid surfaces are modeled.

### Next step
Start the next safe component-driven geometry slice: either derive preview
positions for `standoff_mounts` or wire the first geometry-worker request for
rounded enclosure/standoff generation.

### Notes for future Codex sessions
Mounts generated from component templates must remain semantic feature groups.
Do not flatten a board's mounting-hole mounts into unrelated holes or mesh
objects unless the user explicitly detaches the group.

---

## 2026-06-28 — M17 Feature Group Viewport Markers

### Goal
Make semantic mount groups visible and selectable in the mock viewport before
real OCCT geometry exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`, viewport controller,
workspace shell, and widget/viewport tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `ViewportHitKind.featureGroup`.
  - Added typed `MockViewportFeatureGroupPreview` data for standoff mount
    markers.
  - Added deterministic mapping from component board-local mounting-hole
    positions to mock viewport marker centers.
  - Hit-tests feature group markers before the board so marker clicks select
    the semantic group instead of the component placement underneath.
- `lib/ui/shell/workspace_shell.dart`:
  - Maps feature group hit results to `SelectionModel.featureGroup`.
  - Builds mock standoff marker data from `standoff_mounts` feature groups,
    using stored `holePositions` or falling back to the source template holes.
  - Draws schematic standoff markers and highlights the selected mount group.
  - Added a stable viewport canvas key for widget-level marker click tests.
- `test/viewport_controller_test.dart` and `test/widget_test.dart`:
  - Added coverage for marker coordinate mapping, semantic feature-group hit
    results, and full shell selection from a viewport marker click.
- `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`, `docs/32_USABLE_SHELL.md`, and
  `docs/33_VIEWPORT_MVP.md`:
  - Documented the M17 mock marker slice and its boundary from generated
    B-Rep/mesh geometry.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 29 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 76 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - The markers are mock viewport affordances derived from semantic group data;
    no generated geometry is created yet.
- Serialization checked?
  - Uses existing `FeatureGroup` data; no schema change.
- UI checked?
  - Widget test creates a mount group, deselects it, clicks a marker, and
    verifies the group inspector returns.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Markers are schematic circles projected onto the mock board, not B-Rep
  standoff bosses.
  - Severity: Expected for this slice.
  - Next action: feed the same `standoff_mounts` source data into the geometry
    worker when real standoff generation starts.
- Issue: Marker placement assumes the current sample board-local coordinate
  model.
  - Severity: Expected.
  - Next action: replace the mock transform with actual preview mesh mappings
    once component visual placement is generated by `GeometryService`.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M17.

### Notes for future Codex sessions
Viewport marker clicks must keep returning semantic IDs. Do not introduce mesh,
triangle, or OCCT topology IDs into default selection state.

---

## 2026-06-28 — M18 Button Group Viewport Markers

### Goal
Make newly created semantic button groups visible and selectable in the mock
viewport through the same feature-group marker path as mounts.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, viewport controller, workspace shell, and
widget/viewport tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportFeatureGroupKind.buttonGroup`.
  - Generalized feature-group preview dimensions from board-only to reference
    width/height so button groups can use the lid/surface frame while mounts
    keep using the board frame.
  - Hit-testing continues to return semantic `featureGroup` IDs before
    underlying board/sample features.
- `lib/ui/shell/workspace_shell.dart`:
  - Generates first-pass button marker positions from `layout`, `count`, and
    `spacing`.
  - Supports deterministic `diamond`, `row`, and `grid` marker expansion.
  - Draws created button-group markers in the mock viewport and highlights
    selected button groups.
- `test/viewport_controller_test.dart` and `test/widget_test.dart`:
  - Added coverage for button marker mapping to the lid frame and full shell
    marker-click selection after creating `button_group_1`.
- `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/33_VIEWPORT_MVP.md`:
  - Documented M18 and the current boundary between preview marker expansion
    and saved/generated geometry.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 30 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 77 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Markers are derived from semantic pattern data only; no generated B-Rep or
    mesh is created yet.
- Serialization checked?
  - No schema change; generated marker positions are not saved.
- UI checked?
  - Widget test creates a button group, deselects it, clicks a marker, and
    verifies the group inspector returns.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Pattern expansion lives in the mock viewport shell for now.
  - Severity: Expected for this slice.
  - Next action: promote pattern expansion into reusable layout logic before
    geometry generation consumes it.
- Issue: Marker expansion is first-pass for diamond, row, and grid only.
  - Severity: Expected.
  - Next action: add square/circle/arc/path expansion when those pattern types
    are introduced.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M18.

### Notes for future Codex sessions
Button groups must stay editable semantic `FeatureGroup` objects. Viewport
markers are transient affordances and must not become saved per-button project
items unless the user explicitly detaches the pattern.

---

## 2026-06-28 — M19 Surface Feature Viewport Markers

### Goal
Make created surface features visible and selectable in the mock viewport
before real generated geometry exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, viewport controller, workspace shell, and
widget/viewport tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added typed `MockViewportFeaturePreview` data for semantic feature markers.
  - Added `MockViewportFeatureKind.usbC` and `glassRecess`.
  - Added deterministic mock rectangles for USB-C and glass recess markers.
  - Hit-tests feature markers before generic surfaces and returns semantic
    feature IDs.
- `lib/ui/shell/workspace_shell.dart`:
  - Builds mock feature previews from `usb_c_cutout` and `glass_recess`
    `SemanticFeature` parameters.
  - Draws USB-C and glass/recess markers in the mock viewport.
  - Highlights selected feature markers.
- `test/viewport_controller_test.dart` and `test/widget_test.dart`:
  - Added coverage for feature marker layout, semantic hit results, and full
    shell marker-click selection after creating USB-C and glass recess features.
- `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
  `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`, `docs/32_USABLE_SHELL.md`,
  and `docs/33_VIEWPORT_MVP.md`:
  - Documented M19 and the boundary between schematic markers and generated
    geometry.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 31 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 78 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Markers are derived from semantic feature parameters only; no generated
    B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; generated marker rectangles are not saved.
- UI checked?
  - Widget tests create USB-C/glass features, deselect them, click their
    viewport markers, and verify the feature inspectors return.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Feature markers are schematic rectangles, not true generated cuts or
  recesses.
  - Severity: Expected for this slice.
  - Next action: feed `usb_c_cutout` and `glass_recess` into geometry service
    once real preview geometry starts.
- Issue: Multiple features on the same surface are offset schematically.
  - Severity: Expected.
  - Next action: replace slot offsets with face-local placement/snapping data.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M19.

### Notes for future Codex sessions
Surface feature marker clicks must keep returning semantic feature IDs. Do not
introduce mesh, triangle, or OCCT topology IDs into default selection state.

---

## 2026-06-28 - M20 Feature Parameter Inspector Editing

### Goal
Let selected semantic USB-C and glass recess features expose editable numeric
parameter banks in the contextual inspector, using semantic project updates and
existing undo history.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, workspace shell, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added feature parameter update handling for selected `SemanticFeature`
    objects.
  - Added first-pass inspector parameter schemas for `usb_c_cutout` and
    `glass_recess`.
  - Wired feature parameter submissions into semantic undo snapshots.
  - Kept mock viewport refresh derived from semantic project data.
- `test/widget_test.dart`:
  - Added USB-C feature parameter edit + undo coverage.
  - Added glass recess feature parameter edit + undo coverage.
- `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
  `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M20 and the semantic boundary for feature parameter edits.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 25 targeted widget tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 80 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Feature edits only update semantic parameters; mock markers are rebuilt
    from the project. No generated B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; existing `SemanticFeature.parameters` storage is reused.
- UI checked?
  - Widget tests select USB-C/glass features, submit inspector values, and undo
    the changes.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Feature inspector editing is numeric-only for now.
  - Severity: Expected for this slice.
  - Next action: add compact choice controls for clearance/profile parameters
    when those controls are promoted into shared inspector widgets.
- Issue: Feature placement is still centered/schematic.
  - Severity: Expected.
  - Next action: add face-local placement/snapping before real geometry consumes
    these features.

### Next step
Commit and push M20, then continue with the next safe semantic editing chunk.

### Notes for future Codex sessions
Feature inspector edits must keep replacing semantic `SemanticFeature` data.
Do not make generated viewport rectangles, mesh faces, or OCCT topology IDs the
editable source of truth.

---

## 2026-06-28 - M21 Feature Group Parameter Inspector Editing

### Goal
Let selected semantic button groups and standoff mount groups expose editable
parameter banks in the contextual inspector while keeping repeated items as one
semantic `FeatureGroup`.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, workspace shell,
feature-group model, viewport controller, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added feature-group parameter update handling for selected
    `FeatureGroup` objects.
  - Added first-pass inspector schemas for `button_group` and
    `standoff_mounts`.
  - Routed button group `layout`, `count`, and `spacing` edits to `pattern`.
  - Routed button `diameter`/`mode` and mount item edits to `itemPrototype`.
  - Kept mount hole diameter clamped below standoff diameter.
  - Made choice fields tolerate unknown imported values without crashing.
- `test/widget_test.dart`:
  - Added button group inspector edit + undo coverage.
  - Added standoff mount inspector edit + undo coverage, including hole
    diameter clamping.
- `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
  `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M21 and the semantic boundary for grouped repeated items.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 27 targeted widget tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 82 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Group edits only update semantic pattern/item data; mock markers are
    rebuilt from the project. No generated B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; existing `FeatureGroup.pattern` and `itemPrototype`
    storage are reused.
- UI checked?
  - Widget tests select button/mount groups from viewport markers, submit
    inspector values, and undo the changes.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Pattern expansion still lives in the mock viewport shell.
  - Severity: Expected for this slice.
  - Next action: promote pattern expansion into reusable layout logic before
    geometry generation consumes it.
- Issue: Group placement is still centered/schematic.
  - Severity: Expected.
  - Next action: add face-local placement/snapping before real geometry consumes
    these groups.

### Next step
Commit and push M21, then continue with reusable pattern/layout extraction or
the next safe semantic editing chunk.

### Notes for future Codex sessions
Feature group edits must keep repeated items grouped. Do not flatten button
groups or mount patterns into independent semantic features unless the user
explicitly chooses a detach workflow.

---

## 2026-06-28 - M22 Reusable Pattern Layout Engine

### Goal
Move first-pass button-group pattern expansion out of the workspace shell into
a reusable deterministic module that future geometry generation can consume.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/33_VIEWPORT_MVP.md`, workspace shell, viewport controller, and widget/
viewport tests.

### Changes made
- `lib/patterns/pattern_layout.dart`:
  - Added viewport-independent `PatternPoint`.
  - Added `PatternLayoutEngine` for `button_group` local point expansion.
  - Supports first-pass `diamond`, `row`, and `grid` layouts with deterministic
    clamping/fallback behavior.
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced local button pattern math with `PatternLayoutEngine`.
  - Kept mock viewport marker conversion as UI-only `Offset` mapping.
- `test/pattern_layout_test.dart`:
  - Added deterministic unit coverage for diamond, grid, fallback/clamping, and
    reading semantic `FeatureGroup.pattern` data.
- `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, and
  `docs/33_VIEWPORT_MVP.md`:
  - Documented M22 and the boundary between semantic pattern expansion and
    viewport marker rendering.

### Tests run
- `flutter test test\pattern_layout_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 39 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 86 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Layout expansion is deterministic local semantic data only; no generated
    B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; generated pattern points are not saved.
- UI checked?
  - Widget/viewport tests confirm existing marker selection behavior still
    passes through the mock viewport.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The reusable layout engine covers button `diamond`, `row`, and `grid`
  only.
  - Severity: Expected for this slice.
  - Next action: add square/circle/arc/path expansion when those semantic
    pattern types are introduced.
- Issue: Standoff hole positions are still read by the shell from source
  mounting-hole data.
  - Severity: Expected.
  - Next action: move source-anchor expansion into a reusable component-driven
    layout helper when geometry generation starts consuming standoff groups.

### Next step
Commit and push M22, then continue toward reusable source-anchor layout or the
next safe semantic geometry-prep slice.

### Notes for future Codex sessions
Pattern expansion should remain reusable and deterministic. Do not reintroduce
layout math into widgets or painters when adding geometry generation.

---

## 2026-06-28 - M23 Reusable Standoff Source Layout

### Goal
Move first-pass standoff source mounting-hole expansion out of the workspace
shell and into the reusable pattern/layout module.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/patterns/pattern_layout.dart`, workspace shell, viewport controller, and
widget/viewport/pattern tests.

### Changes made
- `lib/patterns/pattern_layout.dart`:
  - Added `PatternLayoutEngine.standoffMountPositions`.
  - Resolves saved semantic `FeatureGroup.pattern.holePositions`.
  - Falls back to `ComponentTemplate.mountingHoles` when saved source positions
    are absent.
  - Skips malformed saved positions instead of crashing preview generation.
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced local standoff source-hole parsing with `PatternLayoutEngine`.
  - Kept mock viewport conversion as UI-only `Offset` mapping.
- `test/pattern_layout_test.dart`:
  - Added deterministic coverage for saved standoff source positions and
    component-template fallback positions.
- `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`, and `docs/33_VIEWPORT_MVP.md`:
  - Documented M23 and the boundary between semantic source-anchor expansion
    and viewport marker rendering.

### Tests run
- `flutter test test\pattern_layout_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 41 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 88 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Standoff source expansion is deterministic local semantic data only; no
    generated B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; generated pattern points are not saved.
- UI checked?
  - Widget/viewport tests confirm existing standoff marker selection behavior
    still passes through the mock viewport.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Source-anchor expansion only covers component mounting holes.
  - Severity: Expected for this slice.
  - Next action: add source anchors for ports, switches, and keepouts when
    component-driven cutout generation begins.
- Issue: The mock viewport still owns screen-space marker placement.
  - Severity: Expected.
  - Next action: keep only semantic/local layout in reusable modules and move
    real geometry projection into the geometry service when OCCT preview starts.

### Next step
Commit and push M23, then continue toward the next safe semantic geometry-prep
slice.

### Notes for future Codex sessions
Standoff mount positions should keep coming from semantic group/template data.
Do not use generated mesh, triangle, or OCCT topology IDs for source anchors.

---

## 2026-06-28 - M24 First Semantic Validation Warnings

### Goal
Add the first project-level semantic validation pass before real OCCT geometry
exists, and surface warnings/errors in the shell status bar.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, validation model, geometry service,
workspace shell status bar, project semantic models, and geometry/widget tests.

### Changes made
- `lib/validation/project_semantic_validator.dart`:
  - Added first-pass semantic project validation.
  - Validates enclosure dimensions, thin walls, excessive wall thickness, and
    large corner radius.
  - Validates USB-C and glass recess dimensions/radii against the main
    enclosure.
  - Validates standoff mount source positions and hole/diameter safety.
- `lib/validation/validation_result.dart`:
  - Added warning detection and primary issue selection.
- `lib/geometry/geometry_service.dart`:
  - Wired mock `validateGeometry` to semantic validation instead of a static
    info-only placeholder.
- `lib/ui/shell/workspace_shell.dart`:
  - Added visible warning status-bar state with the first warning message.
- Tests:
  - Added semantic validator unit coverage.
  - Added geometry-service validation coverage.
  - Added widget coverage for visible warning status.
- Docs/tasks/roadmap:
  - Documented M24 and the pre-geometry validation boundary.

### Tests run
- `flutter test test\project_semantic_validator_test.dart test\geometry_protocol_test.dart test\widget_test.dart`:
  - Passed, 38 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 94 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Validation is semantic/pre-geometry only; no generated B-Rep or mesh is
    created.
- Serialization checked?
  - No schema change; validation messages are derived and not saved.
- UI checked?
  - Widget test confirms a thin-wall warning appears in the bottom status bar.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Semantic validation only checks the first-pass enclosure, USB-C, glass
  recess, and standoff mount constraints.
  - Severity: Expected for this slice.
  - Next action: add placement/keepout/face-local validation as those workflows
    become semantic.
- Issue: Status bar shows only the first warning/error.
  - Severity: Expected.
  - Next action: add a validation popover/panel when multiple messages become
    common.

### Next step
Commit and push M24, then continue toward the next safe validation/geometry
preparation slice.

### Notes for future Codex sessions
Validation must remain semantic before geometry generation. Do not use preview
triangle IDs, mesh IDs, or OCCT topology as validation targets in the default
workflow.

---

## 2026-06-29 - M25 Validation Details + Placement Bounds

### Goal
Make validation issues inspectable from the shell status bar and add first-pass
semantic component placement/keepout bounds checks before real OCCT geometry
exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `ProjectSemanticValidator`,
`ValidationReport`, component template/placement models, workspace shell status
bar, and validator/widget tests.

### Changes made
- `lib/validation/validation_result.dart`:
  - Added reusable `issues`, `errors`, `warnings`, and `hasIssues` accessors.
  - Kept `primaryIssue` error-first, then warning-first.
- `lib/validation/project_semantic_validator.dart`:
  - Validates missing component templates.
  - Validates placed component board outline/thickness against enclosure inner
    volume.
  - Validates component feature `keepout` boxes as non-blocking warnings.
- `lib/ui/shell/workspace_shell.dart`:
  - Added a compact status-bar details button when validation has issues.
  - Added a bottom sheet listing issue counts and all current warning/error
    messages.
- Tests:
  - Added unit coverage for placement-outside, missing-template, and keepout
    warnings.
  - Added widget coverage for opening the validation details sheet.
- Docs/tasks/roadmap:
  - Documented M25, first-pass placement/keepout validation, and the issue
    details UI.

### Tests run
- `flutter test test\project_semantic_validator_test.dart test\widget_test.dart`:
  - Passed, 36 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 98 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Validation is still semantic/pre-geometry only; no generated B-Rep or mesh
    is created.
- Serialization checked?
  - No schema change; validation messages remain derived state and are not
    saved.
- UI checked?
  - Widget test confirms the status-bar details button opens a list of all
    current warning/error messages.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Component bounds treat board outlines and keepouts as axis-aligned
  rectangles; placement rotation is not considered yet.
  - Severity: Expected for this pre-geometry slice.
  - Next action: add face-local placement and rotated bounds when placement
    workflow becomes viewport-driven.
- Issue: Validation details show target IDs but do not yet focus/select the
  affected object.
  - Severity: Expected.
  - Next action: wire issue rows to semantic selection after issue targets are
    normalized.

### Next step
Commit and push M25, then continue toward the next safe geometry-service or
viewport-prep slice.

### Notes for future Codex sessions
Keep validation issue targets semantic. Do not point issue rows at preview
triangles, generated mesh IDs, or OCCT topology.

---

## 2026-06-29 - M26 Validation Issue Target Selection

### Goal
Make validation issue rows navigate back to their semantic target so warnings
and errors are actionable from the details sheet.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `SelectionModel`,
`ProjectSelectionResolver`, `ValidationReport`, workspace shell status/details
UI, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added semantic validation-target resolution from `targetId` to
    `SelectionModel`.
  - Resolves direct enclosure, component placement, component template, feature,
    and feature group targets.
  - Resolves nested targets such as `button_board_placement.usb_c` to their
    semantic parent.
  - Keeps surface-like targets semantic by mapping body-prefixed IDs to surface
    selection.
  - Made validation issue rows selectable when a semantic target can be
    resolved.
  - Selecting a row closes the details sheet and updates the main shell
    selection.
- Tests:
  - Added widget coverage that clicks a validation issue row and verifies the
    target feature inspector opens.
- Docs/tasks/roadmap:
  - Documented M26 and the semantic target-selection behavior.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 30 widget tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 99 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; this is semantic UI navigation only.
- Serialization checked?
  - No schema change.
- UI checked?
  - Widget test confirms issue row selection closes the sheet and opens the
    target feature inspector.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Validation issue rows select semantic targets but do not yet provide
  one-click fix actions.
  - Severity: Expected.
  - Next action: add guided fixes after more validation rules stabilize.
- Issue: Nested component feature targets resolve to the parent placement, not
  to a per-feature component sub-selection.
  - Severity: Expected for the current selection model.
  - Next action: add component sub-feature selection when the component editor
    exists.

### Next step
Commit and push M26, then continue toward the next safe geometry-service or
viewport-prep slice.

### Notes for future Codex sessions
Validation navigation must remain semantic. Do not route issue rows through
preview triangle IDs, generated mesh IDs, or OCCT topology names.

---

## 2026-06-29 - M27 Component Placement Inspector Editing

### Goal
Make selected component placements directly editable from the contextual
inspector so validation errors can be corrected without reopening the placement
dialog.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `ComponentPlacement`,
`ProjectModel.replaceComponentPlacement`, parameter model helpers, workspace
shell inspector/editor code, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added a compact placement parameter schema for X/Y/Z, mounting side, and
    locked state.
  - Added a component placement editor to the contextual inspector.
  - Added a reusable boolean parameter field for the locked flag.
  - Added semantic placement update helpers that preserve stable placement IDs,
    template IDs, rotation, and metadata.
  - Routed placement inspector edits through `UndoHistory<ProjectModel>` and
    existing preview/validation refresh.
- Tests:
  - Added widget coverage for selecting a component placement, editing X,
    surfacing a validation error, and undoing the edit.
- Docs/tasks/roadmap:
  - Documented M27 and the placement editor workflow.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 31 widget tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 100 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; placement editing is semantic UI/state work.
- Serialization checked?
  - No schema change; edited placements remain standard `ComponentPlacement`
    JSON fields.
- UI checked?
  - Widget test confirms placement edit, validation refresh, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Placement editor still uses typed values instead of viewport picking,
  snapping, or face-local handles.
  - Severity: Expected.
  - Next action: add viewport-driven placement after local workplane/snapping
    foundations are ready.
- Issue: Placement rotation is still read-only in this slice.
  - Severity: Expected.
  - Next action: add rotation controls once rotated bounds are validated.
- Issue: Locked placement state is stored but not yet enforced by all editing
  pathways.
  - Severity: Expected.
  - Next action: define lock semantics before adding viewport placement tools.

### Next step
Commit and push M27, then continue toward the next safe viewport-prep or
geometry-service slice.

### Notes for future Codex sessions
Component placement edits must keep semantic placement IDs stable. Do not use
preview mesh positions or OCCT topology as editable placement state.

---

## 2026-06-29 - M28 Component Placement Rotation + Lock Guard

### Goal
Add Z rotation editing for component placements, make first-pass placement
validation account for that rotation, and make the locked state block placement
edits.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, component placement inspector/editor
code, `ProjectSemanticValidator`, component placement model, and validator/widget
tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Поворот Z` to the component placement inspector.
  - Added rotation update helpers that preserve stable placement IDs and typed
    semantic placement fields.
  - Added disabled-state support to shared number and choice parameter
    controls.
  - Disabled position/rotation/side controls while a placement is locked.
  - Kept the locked checkbox active so a locked placement can be unlocked.
  - Ignored non-lock placement parameter edits in shell state when the placement
    is locked.
- `lib/validation/project_semantic_validator.dart`:
  - Added rotation-aware board and keepout envelope checks for first-pass
    semantic component placement validation.
- Tests:
  - Added unit coverage for rotation-aware component placement bounds.
  - Extended widget coverage for Z rotation edit/undo.
  - Added widget coverage for locked placement fields and unlock behavior.
- Docs/tasks/roadmap:
  - Documented M28, rotation-aware validation, and first-pass lock behavior.

### Tests run
- `flutter test test\project_semantic_validator_test.dart test\widget_test.dart`:
  - Passed, 40 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 102 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Validation is still semantic/pre-geometry only; no generated B-Rep or mesh
    is created.
- Serialization checked?
  - No schema change; edited rotation/lock remain standard
    `ComponentPlacement` JSON fields.
- UI checked?
  - Widget tests confirm Z rotation edit/undo and locked-field behavior.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Rotation-aware validation uses conservative 2D bounding boxes, not
  exact geometry.
  - Severity: Expected.
  - Next action: replace with geometry-service validation when OCCT preview
    generation exists.
- Issue: Only Z rotation is editable.
  - Severity: Expected for board-like component placement.
  - Next action: add richer orientation controls if component workflows need
    non-planar placement.
- Issue: Locking blocks inspector edits but there are no viewport placement
  handles to lock yet.
  - Severity: Expected.
  - Next action: reuse lock state when viewport-driven placement is introduced.

### Next step
Commit and push M28, then continue toward the next safe viewport or geometry
service slice.

### Notes for future Codex sessions
Keep placement rotation and lock semantics in the semantic `ComponentPlacement`.
Do not infer editable placement state from preview mesh transforms or OCCT
topology.

---

## 2026-06-29 - M29 Component Placement Visibility

### Goal
Add a semantic visibility toggle for component placements so a placement can be
hidden from the mock viewport without deleting it from the editable project.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, component placement model, workspace
shell inspector/browser/viewport code, `ViewportController`, and related
model/viewport/widget tests.

### Changes made
- `lib/project/component_placement.dart`:
  - Added typed `visible` state with default `true`.
  - Kept older project JSON compatible by defaulting missing `visible` to
    `true`.
  - Preserved unknown placement metadata while excluding the typed `visible`
    field from metadata.
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Показывать` to the component placement inspector.
  - Preserved visibility through placement position, rotation, side, and lock
    edits.
  - Allowed visibility changes even while a placement is locked.
  - Marked hidden placements in the project browser with a visibility-off icon.
  - Built mock component placement previews from semantic placements and
    component template board outlines.
  - Omitted hidden placements from mock viewport drawing and hit-testing.
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportComponentPlacementPreview`.
  - Routed component placement hit-testing through supplied semantic placement
    previews instead of only one hard-coded board ID.
- `lib/selection/project_selection_resolver.dart`:
  - Added placement visibility to selection details.
- Tests:
  - Added placement visibility serialization coverage.
  - Added mock viewport hit-test coverage for omitted component previews.
  - Added widget coverage for visibility toggle, hidden hit target, and undo.
- Docs/tasks/roadmap:
  - Documented M29, component placement visibility, semantic viewport previews,
    and test expectations.

### Tests run
- `flutter test test\project_model_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 53 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 105 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Mock viewport drawing/hit-testing only; no generated B-Rep or mesh is
    created.
- Serialization checked?
  - Unit tests cover default `visible: true` for older JSON and hidden placement
    round-trip.
- UI checked?
  - Widget test confirms hide/show state, viewport hit omission, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Hidden component placement hides only the mock board placement marker;
  generated feature groups such as standoffs are still separate semantic objects.
  - Severity: Expected.
  - Next action: decide later whether component-driven generated objects need
    their own visibility/group isolation controls.
- Issue: Component placement preview is still a schematic rectangle.
  - Severity: Expected.
  - Next action: replace with geometry-service preview data when OCCT generated
    board/reference geometry exists.

### Next step
Commit and push M29, then continue toward the next safe viewport or placement
workflow slice.

### Notes for future Codex sessions
Keep `ComponentPlacement.visible` as semantic display state. Do not infer hidden
or visible placement state from preview mesh presence.

---

## 2026-06-29 - M30 Local Workplane Overlay + Snap Hints

### Goal
Add a transient local workplane overlay and first snap hints for selected
surfaces/component placements, preparing the mock viewport for later
viewport-driven placement edits.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `ViewportController`,
`workspace_shell.dart` viewport painter/wiring, and viewport/widget tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportWorkplaneKind` and `MockViewportWorkplaneOverlay`.
  - Added deterministic workplane rectangle and snap-point mapping helpers.
  - Extracted `frontWallRect` into `MockViewportLayout` so hit-testing and
    overlays share the same mock layout source.
- `lib/ui/shell/workspace_shell.dart`:
  - Builds active workplane overlays from the current semantic selection.
  - Shows surface overlays for `Top lid` and `Front wall`.
  - Shows component-placement overlays for visible placements.
  - Uses component template mounting holes plus board center as first snap
    hints.
  - Draws a subtle workplane grid and snap dots without changing
    `ProjectModel`.
  - Removes the placement overlay when the placement is hidden.
- Tests:
  - Added viewport layout coverage for surface snap mapping.
  - Added viewport layout coverage for rotated component placement snap hints.
  - Added widget coverage for surface/placement selection overlay wiring and
    hidden placement overlay removal.
- Docs/tasks/roadmap:
  - Documented M30, workplane overlay behavior, snap hints, and test
    expectations.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Failed once due to a stale test expectation that compared the new semantic
    placement workplane center with the old hard-coded mock board rect.
  - Passed after correcting the expectation, 45 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 108 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Mock viewport layout only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; overlay state is transient UI state and is not saved.
- UI checked?
  - Widget tests confirm overlay wiring for surface/placement selection and
    removal when a placement is hidden.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Snap hints are visual only and do not yet drive placement edits.
  - Severity: Expected.
  - Next action: use these snap points when adding viewport-driven placement
    workflows.
- Issue: Workplanes are still mock 2.5D rectangles, not OCCT face-local planes.
  - Severity: Expected.
  - Next action: map generated geometry faces back to semantic surfaces through
    `GeometryService` later.

### Next step
Commit and push M30, then continue toward viewport-driven placement or snapping
workflow edits.

### Notes for future Codex sessions
Keep workplane overlays transient. They may guide semantic edits later, but
should not become saved sketch geometry or generated topology references.

---

## 2026-06-29 - M31 Snap Picking Seeds Component Placement

### Goal
Turn mock viewport snap hints into selectable transient placement seeds without
saving snap UI state into the semantic project model.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/viewport/viewport_controller.dart`, `lib/ui/shell/workspace_shell.dart`,
and existing command/viewport/widget tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `ViewportHitKind.snapPoint` and snap hit metadata.
  - Added active workplane hit-testing.
  - Kept visible semantic objects above overlapping snap hints, while snap
    hints still win over bare surface hits.
- `lib/ui/shell/workspace_shell.dart`:
  - Added transient active snap target state.
  - Selects and highlights clicked snap hints.
  - Seeds the component placement dialog from active snap target X/Y/Z and
    mounting side.
  - Shows a snap label in the placement dialog.
  - Clears stale snap targets on normal selection, semantic edits, undo, and
    redo.
- `lib/commands/command_registry.dart`:
  - Allows `component.place` from surface context for snap-driven placement
    flow.
- Tests:
  - Added command availability coverage for surface-context component
    placement.
  - Added viewport coverage for snap-point hits and snap/object hit priority.
  - Added widget coverage for selecting a surface snap point and opening a
    seeded placement dialog.
- Docs/tasks/roadmap:
  - Recorded M31 behavior, test expectations, and the manual poke checklist.

### Tests run
- `flutter test test\command_registry_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Failed once while tightening the widget test and revealed that overlapping
    center snap hints could block selecting a restored visible placement.
  - Passed after adjusting hit-test priority.
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component placement visibility toggle hides viewport hit target"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 111 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport hit-testing only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; active snap target state is transient and not saved.
- UI checked?
  - Widget tests confirm snap picking seeds the placement dialog and visible
    component placement remains selectable over overlapping snap hints.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Snap-seeded placement still opens a dialog rather than supporting
  drag-to-place or click-to-confirm directly in the viewport.
  - Severity: Expected.
  - Next action: add the next guided placement slice with live preview and
    confirm/cancel controls.
- Issue: Snap points are still mock local workplane points, not OCCT face-local
  coordinates.
  - Severity: Expected.
  - Next action: replace mock mapping through `GeometryService` when generated
    geometry picking exists.

### Next step
Commit and push M31, then continue toward guided component placement workflow
or component anchor/connector mapping.

### Notes for future Codex sessions
Snap target state belongs to the shell only. Keep the saved project semantic:
component placements store normal position/rotation/mounting side data, not
snap indices or viewport hit IDs.

---

## 2026-06-29 - M32 Active Snap Inspector Action

### Goal
Make the currently selected snap hint visible and actionable from the contextual
inspector, while keeping snap selection as transient UI state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/ui/shell/workspace_shell.dart`, and snap/widget tests from M31.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added an active snap target inspector section.
  - Shows snap label, seeded project position, and human mounting side.
  - Adds a direct `Разместить компонент` action that opens the existing
    snap-seeded placement dialog.
  - Adds a clear action that removes only transient snap UI state.
- `test/widget_test.dart`:
  - Added coverage for opening placement from the active snap inspector action.
  - Added coverage for clearing the active snap target from the inspector.
  - Added a helper for deterministic top-lid snap tapping in widget tests.
- Docs/tasks/roadmap:
  - Recorded M32 behavior, task status, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target can be cleared from inspector"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 113 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport interaction only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; active snap target state is transient and not saved.
- UI checked?
  - Widget tests confirm the inspector action opens the seeded placement dialog
    and clear removes the snap section.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The inspector action still enters a dialog-based placement flow, not a
  direct viewport confirm/cancel workflow.
  - Severity: Expected.
  - Next action: add live preview/confirm placement as a later guided-placement
    slice.
- Issue: Active snap positions are still mock workplane positions.
  - Severity: Expected.
  - Next action: move to geometry-service face-local picking when real preview
    geometry exists.

### Next step
Commit and push M32, then continue toward guided viewport placement or semantic
component anchors.

### Notes for future Codex sessions
The active snap inspector should remain a context affordance, not saved model
state. Confirmed placements should continue to store normal
`ComponentPlacement` values.

---

## 2026-06-29 - M33 Snap Placement Footprint Preview

### Goal
Show a transient viewport footprint for the component that would be placed from
the active snap target.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/ui/shell/workspace_shell.dart`, and snap/widget tests from M31-M32.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Builds a mock active snap placement preview from the first component
    template and active snap target.
  - Draws a translucent component footprint at the snap-seeded position.
  - Keeps the footprint out of hit testing and out of `ProjectModel`.
  - Removes the footprint when the active snap target is cleared.
- `test/widget_test.dart`:
  - Extended snap widget coverage to assert the footprint preview appears after
    snap selection and disappears after clearing.
- Docs/tasks/roadmap:
  - Recorded M33 behavior, done criteria, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target can be cleared from inspector"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 113 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport drawing only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; footprint preview is transient and not saved.
- UI checked?
  - Widget tests confirm preview presence and clearing behavior.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The footprint is a schematic rectangle from the component template
  board outline, not generated board geometry.
  - Severity: Expected.
  - Next action: replace with geometry-service preview once real board/component
    preview data exists.
- Issue: The footprint does not yet show collision or clearance feedback.
  - Severity: Expected.
  - Next action: add validation-aware placement preview in a later guided
    placement slice.

### Next step
Commit and push M33, then continue toward full guided component placement or
semantic component anchors.

### Notes for future Codex sessions
Keep active snap footprint previews transient. They should guide the next
semantic action but never become editable saved placement data by themselves.

---

## 2026-06-29 - M34 Snap Placement Fit Feedback

### Goal
Show semantic fit feedback for snap-seeded component placement previews before
the user commits a new placement.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/validation/project_semantic_validator.dart`, `lib/ui/shell/workspace_shell.dart`,
and snap/widget tests from M31-M33.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Builds a temporary prospective `ComponentPlacement` from the active snap
    target.
  - Runs that placement through `ProjectSemanticValidator` without saving it.
  - Filters preview validation to messages targeted at the temporary placement.
  - Shows a compact fit/status row in the active snap inspector panel.
  - Tints the transient viewport footprint by validation severity.
- `test/widget_test.dart`:
  - Added coverage for the normal snap placement fit state.
  - Added coverage for an oversized component template that would fail before
    placement is committed.
- Docs/tasks/roadmap:
  - Recorded M34 behavior, limitations, test expectations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target can be cleared from inspector"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap placement check reports oversized footprint"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Initially reported `test/widget_test.dart` needed formatting; passed after
    formatting.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 114 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport drawing and semantic bounds validation only; no generated
    B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; prospective placement and fit status are transient and not
    saved.
- UI checked?
  - Widget tests confirm normal fit feedback and oversized preview warning.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Fit feedback uses coarse semantic placement bounds, not real generated
  geometry/collision.
  - Severity: Expected.
  - Next action: replace or augment with geometry-service collision/clearance
    checks when real preview geometry exists.
- Issue: Only the first component template is previewed from active snap state.
  - Severity: Expected.
  - Next action: connect template selection to live preview in a later placement
    flow slice.

### Next step
Commit and push M34, then continue toward guided component placement or
component anchor mapping.

### Notes for future Codex sessions
Use temporary semantic objects for preview validation. Do not store preview IDs,
snap indices, or validation state in `ProjectModel`.

---

## 2026-06-29 - M35 Placement Dialog Live Fit Check

### Goal
Show semantic fit feedback inside the component placement dialog while the user
edits candidate placement values.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `lib/ui/shell/workspace_shell.dart`, and placement
widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Passes the current semantic project into `_PlaceComponentDialog`.
  - Builds the current dialog candidate as a temporary `ComponentPlacement`.
  - Reuses prospective placement validation for dialog X/Y/Z/template values.
  - Shows a compact fit/status row in the dialog.
  - Keeps dialog validation as feedback only; commit still happens only after
    `Разместить`.
- `test/widget_test.dart`:
  - Added coverage that the dialog starts with a valid fit message.
  - Added coverage that editing X outside the enclosure reports a semantic
    placement error before commit.
- Docs/tasks/roadmap:
  - Recorded M35 behavior, done criteria, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 115 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic bounds validation only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; dialog candidate validation is transient and not saved.
- UI checked?
  - Widget tests confirm valid and invalid candidate dialog states.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Dialog fit feedback still uses coarse semantic bounds, not real
  generated geometry/collision.
  - Severity: Expected.
  - Next action: add geometry-service clearance checks when generated preview
    geometry exists.
- Issue: The dialog does not yet update the viewport footprint live while fields
  are edited.
  - Severity: Expected.
  - Next action: connect dialog edits to a live viewport placement session if we
    move beyond modal placement.

### Next step
Commit and push M35, then continue toward guided component placement or
component anchor mapping.

### Notes for future Codex sessions
Keep validation feedback transient until the user confirms a semantic placement.
Temporary candidate objects are fine for validation, but should not be persisted.

---

## 2026-06-29 - M36 Placement Dialog Viewport Candidate

### Goal
Mirror the component placement dialog candidate into the viewport while the
dialog is open, then clear that transient preview on cancel or confirm.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/ui/shell/workspace_shell.dart`, and placement widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added shell-level transient `ComponentPlacement?` candidate state for the
    placement dialog.
  - Seeds the candidate before the dialog opens.
  - Updates the candidate when dialog template/X/Y/Z/side/lock values change.
  - Reuses the existing candidate footprint painter path for dialog previews.
  - Clears candidate state on cancel and confirm before any semantic commit.
- `test/widget_test.dart`:
  - Added coverage that candidate footprint appears while the dialog is open.
  - Added coverage that the footprint clears on confirm.
  - Added coverage that the footprint clears on cancel without committing a
    component.
- Docs/tasks/roadmap:
  - Recorded M36 behavior, transient-state rules, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component rail command can be cancelled"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 115 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport drawing only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; dialog candidate state is transient and not saved.
- UI checked?
  - Widget tests confirm candidate preview appears and clears on cancel/confirm.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The modal dialog can visually cover part of the viewport footprint.
  - Severity: Expected.
  - Next action: move toward a non-modal guided placement flow when the
    viewport interaction model is ready.
- Issue: The candidate preview remains schematic and not collision-aware beyond
  semantic fit checks.
  - Severity: Expected.
  - Next action: connect to geometry-service clearance/collision checks later.

### Next step
Commit and push M36, then continue toward guided component placement or
component anchor mapping.

### Notes for future Codex sessions
`_placementDialogCandidate` is UI-only state. Do not serialize it, include it in
undo history, or let it become a real placement unless the dialog returns a
confirmed `ComponentPlacement`.

---

## 2026-06-29 - M37 Placement Template Size Summary

### Goal
Show selected component template board dimensions in the placement dialog so
candidate fit feedback is easier to interpret.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`lib/ui/shell/workspace_shell.dart`, and placement dialog widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Resolves the currently selected component template in the placement dialog.
  - Adds a compact board summary under the template selector.
  - Shows board width, height, and thickness.
  - Shows a missing-template fallback if the selected ID cannot be resolved.
- `test/widget_test.dart`:
  - Added coverage for the sample board dimension summary in the placement
    dialog.
- Docs/tasks/roadmap:
  - Recorded M37 behavior, done criteria, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 115 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; this is read-only semantic template UI.
- Serialization checked?
  - Not applicable; no project data changed.
- UI checked?
  - Widget test confirms the dimension summary is rendered.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The dialog still has only one sample component template in the default
  project.
  - Severity: Expected.
  - Next action: add template editing/loading before broader template selection
    polish matters.
- Issue: The summary is textual only; no board-specific mini preview yet.
  - Severity: Low.
  - Next action: use the viewport footprint as the primary visual preview for
    now.

### Next step
Commit and push M37, then continue toward guided placement or component anchor
mapping.

### Notes for future Codex sessions
Template summaries are read-only UI hints. Keep editable component template
work as a separate subsystem with its own tests/docs when it begins.

---

## 2026-06-29 - M38 Placement Quick Presets

### Goal
Make component placement faster by adding quick position controls to the
placement dialog while keeping the workflow semantic and undo-safe.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`docs/26_TESTING_AND_QUALITY.md`, `lib/ui/shell/workspace_shell.dart`, and
placement dialog widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added compact quick position icon controls to the component placement
    dialog.
  - Derives center/side offsets from the selected template board footprint and
    current enclosure inner dimensions.
  - Updates the transient dialog candidate, viewport candidate footprint, and
    semantic fit check when a preset is clicked.
  - Converted dialog number fields from `initialValue` to controller-backed
    fields so programmatic candidate updates are shown immediately.
- `test/widget_test.dart`:
  - Added coverage for quick preset candidate updates and confirmed semantic
    placement creation.
- Docs/tasks/roadmap:
  - Recorded M38 behavior, done criteria, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog quick presets update candidate position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 116 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport candidate only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; quick preset state is transient and only confirmed
    placement enters semantic project JSON.
- UI checked?
  - Widget test confirms a quick preset updates the dialog field, keeps the
    candidate preview alive, and commits a normal `ComponentPlacement`.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Quick presets are center/side shortcuts, not direct drag placement.
  - Severity: Expected.
  - Next action: continue toward guided viewport placement.
- Issue: Presets use board footprint and enclosure inner dimensions; deeper
  component keepout/collision polish remains semantic validation feedback.
  - Severity: Expected.
  - Next action: improve component anchors and geometry-service checks later.

### Next step
Commit and push M38, then continue toward guided component placement with
viewport picking or component anchor mapping.

### Notes for future Codex sessions
Quick preset controls must stay transient UI affordances. Do not serialize
them or create undo entries until the dialog returns a confirmed
`ComponentPlacement`.

---

## 2026-06-29 - M39 Placement Dialog Rotation

### Goal
Let component placement rotation be chosen before commit so the dialog
candidate, viewport preview, and semantic fit check match the final placement
orientation.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`docs/26_TESTING_AND_QUALITY.md`, `lib/ui/shell/workspace_shell.dart`,
`lib/viewport/viewport_controller.dart`, and placement dialog widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Поворот Z` state to the component placement dialog.
  - Added compact rotate-left/rotate-right 90 degree icon controls.
  - Feeds dialog rotation into the transient `ComponentPlacement` candidate.
  - Reuses existing rotation-aware semantic validation and mock viewport
    preview drawing.
  - Preserves the normal semantic commit path: rotation is saved only when the
    dialog returns a confirmed placement.
- `test/widget_test.dart`:
  - Added coverage proving a placement that fails at X=36 becomes valid after
    a 90 degree rotation and commits with `rotationZ = 90`.
- Docs/tasks/roadmap:
  - Recorded M39 behavior, done criteria, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog rotation updates candidate fit and commit"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog quick presets update candidate position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 117 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport candidate only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Rotation is already part of semantic `ComponentPlacement`; no schema change
    was needed.
- UI checked?
  - Widget test confirms rotation changes fit feedback and committed inspector
    state.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Rotation controls are still dialog-based, not direct viewport drag or
  handle editing.
  - Severity: Expected.
  - Next action: continue toward guided viewport placement.
- Issue: Fit feedback remains semantic envelope validation, not full collision
  or generated geometry validation.
  - Severity: Expected.
  - Next action: improve geometry-service checks after worker progress.

### Next step
Commit and push M39, then continue toward guided component placement with
viewport picking or component anchor mapping.

### Notes for future Codex sessions
Dialog rotation is transient until confirmation. Keep preview/candidate state
out of undo history and project JSON unless the dialog commits a real
`ComponentPlacement`.

---

## 2026-06-29 - M40 Snap Anchor Placement

### Goal
Let snap-seeded component placement align a chosen semantic component anchor,
such as a mounting hole, USB-C connector, or switch center, to the selected
surface snap point before commit.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/32_USABLE_SHELL.md`, `docs/26_TESTING_AND_QUALITY.md`,
`lib/ui/shell/workspace_shell.dart`, and snap/placement widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Passes the active snap target into the component placement dialog.
  - Builds transient anchor choices from the selected template center,
    mounting holes, and semantic component features.
  - Adds a compact `Якорь к точке` selector when placement starts from a snap.
  - Recalculates candidate X/Y so the selected anchor lands on the snap point.
  - Keeps anchor-lock active across rotation until the user manually changes
    X/Y or uses a quick position preset.
  - Normalizes tiny floating-point values when formatting dialog/inspector
    numbers so near-zero values render as `0`.
- `test/widget_test.dart`:
  - Added coverage for USB-C anchor alignment from a top-lid snap point and
    rotation-aware re-alignment.
- Docs/tasks/roadmap:
  - Recorded M40 behavior, done criteria, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "snap-seeded placement dialog can align a component anchor"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed after rerunning sequentially.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog rotation updates candidate fit and commit"`:
  - Passed after rerunning sequentially.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 118 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport candidate only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Selected anchor state is transient and not serialized. The project stores
    only the resulting semantic `ComponentPlacement` position and rotation.
- UI checked?
  - Widget test confirms anchor selection updates candidate coordinates and
    stays aligned through rotation.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The anchor selector exists only inside the dialog; direct viewport
  anchor picking is still future work.
  - Severity: Expected.
  - Next action: continue toward a guided viewport placement workflow.
- Issue: Running multiple targeted `flutter test` commands in parallel on
  Windows can collide on `build/test_cache`.
  - Severity: Tooling nuisance.
  - Next action: run Flutter tests sequentially unless using the single
    built-in `flutter test` runner.

### Next step
Commit and push M40, then continue toward guided component placement with more
viewport-driven confirmation or projected connector/switch workflows.

### Notes for future Codex sessions
Anchor selection is a placement aid, not project data. Do not serialize
selected anchor IDs unless the product explicitly grows editable placement
constraints later.

---

## 2026-06-29 - M41 Component USB-C Cutout Propagation

### Goal
Start component-driven enclosure generation by creating a semantic USB-C cutout
from a selected component placement's template connector metadata.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
`lib/commands/command_registry.dart`, `lib/ui/shell/workspace_shell.dart`, and
USB-C command widget tests.

### Changes made
- `lib/commands/command_registry.dart`:
  - Allows `port.add_usb_c` from surface and component scopes.
- `lib/ui/shell/workspace_shell.dart`:
  - Keeps existing surface-selected manual USB-C creation.
  - Enables `Порты` from a selected component placement only when its template
    has a USB-C feature with `cutout` metadata and a resolvable target surface.
  - Builds the initial `usb_c_cutout` dimensions/profile from component
    feature metadata.
  - Resolves the first target semantic surface from the component feature
    direction.
  - Preserves source placement/template/feature IDs plus component feature
    position/direction on the generated semantic feature.
  - Keeps `source`, `placement`, and metadata when the USB-C dialog confirms.
- `test/command_registry_test.dart`:
  - Updated command availability coverage for surface and component contexts.
- `test/widget_test.dart`:
  - Added coverage for component-driven USB-C creation and saved JSON source
    metadata.
- Docs/tasks/roadmap:
  - Recorded M41 behavior, limitations, tests, and poke checklist.

### Tests run
- `flutter test test\command_registry_test.dart --plain-name "USB-C command works from surface and component context"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component USB-C rail command creates sourced cutout"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "add USB-C rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "add USB-C rail command can be cancelled"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 119 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic feature generation only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Widget test saves the project and verifies generated cutout source metadata.
- UI checked?
  - Widget tests cover both the old surface-selected USB-C path and the new
    component-selected path.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The generated cutout uses the connector direction for the target
  surface but does not yet store face-local connector coordinates.
  - Severity: Expected first-pass limitation.
  - Next action: add face-local projected placement metadata before real
    geometry generation.
- Issue: This creates a semantic `usb_c_cutout`; it does not yet cut real
  generated geometry.
  - Severity: Expected.
  - Next action: connect semantic features to geometry service/OCCT worker
    later.

### Next step
Commit and push M41, then continue toward projected connector coordinates or
component-driven switch/button cutout propagation.

### Notes for future Codex sessions
Component-driven port creation should remain semantic and traceable. Do not
flatten it into generated mesh or OCCT topology; source IDs are the bridge for
future regeneration/update behavior.
