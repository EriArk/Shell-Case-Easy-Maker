# 03 — Architecture Overview

## Target stack

```text
Flutter UI
  ↓
Dart state / command / semantic project model
  ↓
GeometryService API
  ↓
OCCT worker process or backend adapter
  ↓
OpenCascade B-Rep generation
  ↓
Preview mesh / STEP / STL / DXF / 3MF
```

## Why this architecture

Flutter provides a clean, animated, minimal desktop UI. OpenCascade provides precise B-Rep geometry, fillets, chamfers, booleans, STEP, and reliable CAD-grade operations.

The semantic project model prevents the app from becoming a fragile mesh editor.

## Main modules

```text
lib/
  app/
  ui/
  viewport/
  project/
  features/
  components/
  patterns/
  geometry/
  export/
  validation/
  commands/
  input/
  themes/

native/
  occt_worker/

docs/
tests/
```

## Flutter side responsibilities

- App shell.
- Panels and inspectors.
- Viewport display.
- Selection.
- Command system.
- Project model editing.
- Serialization.
- Undo/redo.
- Parameter knobs and input mapping.
- Validation display.
- Sending geometry requests.

Flutter must not implement precise B-Rep operations.

## OCCT worker responsibilities

- Consume semantic geometry requests.
- Generate B-Rep bodies.
- Perform controlled booleans.
- Generate fillets/chamfers where requested by semantic generators.
- Tessellate preview mesh.
- Export STEP/STL.
- Extract 2D profiles for DXF export.
- Return warnings/errors.

The worker should not own user-facing UX decisions.

## GeometryService

A stable interface:

```text
generatePreview(project)
generateFeaturePreview(project, featureId)
validateGeometry(project)
exportSTEP(project, target)
exportSTL(project, target)
exportDXF(project, exportSpec)
getSelectableSurfaces(project)
```

## Worker process vs FFI

Start with a separate worker process:
- easier debugging,
- backend can crash without killing UI,
- testable independently,
- easier to replace later.

Direct FFI can be considered later.

## Undo/redo

Semantic edits create undo transactions. Continuous edits, knob drags, and repeated encoder steps should be grouped into one transaction after inactivity/release.

## Validation flow

Semantic validation happens before geometry:
- missing targets,
- impossible constraints,
- clearances,
- keepout conflicts.

The current first-pass implementation is `ProjectSemanticValidator` in
`lib/validation/project_semantic_validator.dart`. It checks semantic project
data such as enclosure dimensions, wall thickness, USB-C/glass feature sizes,
component placement bounds, component feature keepouts, and standoff mount
item/source data before any generated mesh or OCCT topology exists.
`GeometryService.validateGeometry(project)` exposes this pass to the Flutter
shell, where the status bar can show the primary issue and open a compact list
of all warning/error messages.

Geometry validation happens after generation:
- failed boolean,
- invalid body,
- self-intersection risk,
- export failure.

## Geometry Request Intents

`GeometryRequest.previewMesh(project)` includes derived `featureIntents` for
semantic features and feature groups. This lets the geometry backend consume
prepared USB-C cutout, glass recess, button group, and standoff intent without
depending on Flutter UI state.

Feature-group item expansion in the request is disposable backend input. The
editable project still stores the source `FeatureGroup` pattern and does not
store generated mesh, B-Rep, or topology IDs.

`GeometryOperationPlanner` can now convert these request intents into a
deterministic backend operation plan. The plan uses semantic IDs, target
surfaces, operation categories, placement/source metadata, and expanded group
items to describe cut/add/recess tasks for the worker. Advanced Sketch profile
intent now also becomes request-scoped plan entries:
`helper.advanced_sketch` remains the parent helper operation, while
`profileIntent=cut/add` entities become `sketch.profile.cut/add` future
operations with semantic shape parameters. The native OCCT worker now consumes
the first USB-C cutout intent; sketch profile operations and other unsupported
entries remain request/response scoped backend input, not saved editable
project state.

## Generated Geometry Protocol Fixtures

`tool/generate_geometry_protocol_fixtures.dart` regenerates the protocol
examples from typed Dart models and `MockGeometryService`:

```powershell
dart run tool\generate_geometry_protocol_fixtures.dart
```

The checked-in request fixture includes semantic feature intents and expanded
group items for the sample worker project. The checked-in response fixture is
mock backend output with operation-plan metrics. These files are test fixtures
for protocol development; they are not editable project state and they are not
native OCCT B-Rep output.

## Local Worker CLI

`GeometryWorkerProtocolHandler` is the stdin/stdout-style boundary for worker
requests. It receives request JSON, validates the top-level worker payload,
decodes a `GeometryRequest`, calls a supplied `buildGeometry` function, and
returns response JSON.

The canonical local worker command is Dart-only until native OCCT is wired:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart
```

It uses `GeometryWorkerRuntime`, defaults to the mock backend, and keeps
`tool/mock_geometry_worker.dart` as a compatibility alias. Passing
`--backend=native` returns a structured not-implemented response until the
native OCCT backend exists.

The local CLI lets protocol tests and smoke checks exercise the worker boundary
before native OCCT is available. It does not make generated mesh, B-Rep, STL,
or topology IDs editable project state.

Capability metadata is available without a geometry payload:

```powershell
dart run occt_worker\bin\occt_worker.dart --capabilities
```

The command emits `shell_case.geometry.worker.capabilities` JSON. It records
protocol schema/version, the active backend, and backend readiness. Current
metadata marks `mock` as available for `preview_mesh` and `native` as a stub for
planned OCCT-backed preview/export/validate operations. This metadata is not
project state and does not expose OCCT topology.

`GeometryWorkerProcessClient.queryCapabilities()` can request and parse the
same metadata through the configured worker command. Capability launch failures,
timeouts, invalid JSON, and non-zero exits are normalized into typed issues so
callers can inspect worker readiness without crashing or reading native process
details directly.

`occt_worker/native` is the first standalone native executable scaffold. It is
not part of the Flutter Windows runner and builds into `build/occt_worker_native`
through `tools/build_occt_worker_stub.ps1`. The scaffold can report capabilities
and structured not-implemented responses, but it does not link OCCT or generate
B-Rep yet. It reads the top-level worker request envelope, preserves request
IDs, validates schema/operation, and reports invalid payloads through typed
`worker.request.*` issues before any future geometry generation runs.

`tool/native_worker_stub_smoke.dart` wraps the native stub build, capability
query, and preview request smoke into one developer command.

The first OCCT dependency decision is documented in
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`. Normal Flutter builds and the native
stub stay independent of OCCT until `tools/check_occt_windows_readiness.ps1`
finds a local `OpenCASCADEConfig.cmake`.

`occt_worker_native_occt` is the separate opt-in OCCT target. It is configured
with `SHELL_CASE_ENABLE_OCCT=ON` through `tools/build_occt_worker_occt.ps1` and
should remain separate from `occt_worker_native_stub`. It now builds the sample
rounded enclosure B-Rep, emits disposable preview mesh data plus first-pass
semantic surface ranges, and still keeps generated B-Rep/mesh out of editable
project state. Its vcpkg manifest is also opt-in: the build script uses
`occt_worker/native/vcpkg.json` only when
`-AllowVcpkgInstall` is provided. `tools/bootstrap_vcpkg_windows.ps1` can create
a repo-local `external/vcpkg` checkout, and the readiness checker auto-detects
that path without requiring a global `VCPKG_ROOT`. Manifest-mode installed
packages live under ignored `occt_worker/native/vcpkg_installed`; they are
native dependency output, not project state.

## Worker Process Client

`GeometryWorkerProcessClient` is the first external-process adapter. It sends a
`GeometryRequest` JSON payload to a configured worker command through stdin,
captures stdout/stderr, parses a `GeometryResponse`, can query worker
capabilities, and converts process-level failures into normal typed issues.

Current normalized failures:
- worker launch/process failure,
- timeout,
- invalid response JSON,
- non-zero exit code without a worker error response,
- invalid capability JSON.

The client is reachable through `WorkerGeometryService` and the developer
backend selection switch. Normal app builds still use `MockGeometryService` for
interactive preview unless the worker backend is explicitly configured.

Smoke command:

```powershell
dart run tool\mock_geometry_worker_client_smoke.dart
```

## Worker GeometryService Adapter

`WorkerGeometryService` implements the same app-facing `GeometryService`
contract as the in-process mock service, but routes preview/build requests
through `GeometryWorkerProcessClient`.

`GeometryPreview` may include a disposable `PreviewMesh` returned by the worker.
The Flutter viewport can render that mesh for visual feedback, but selection,
commands, inspector state, undo/redo, and saved project JSON remain semantic.
Generated preview vertices, triangle indices, B-Rep, and OCCT topology IDs are
not editable source-of-truth data.

Current split:
- `buildGeometry(request)` goes to the worker process client.
- `generatePreview(project)` builds a preview-mesh request and reports response
  stats such as backend, status, preview vertex/triangle counts, feature
  intents, and operation count.
- `validateGeometry(project)` stays semantic/local through
  `ProjectSemanticValidator`.
- selectable surfaces stay semantic/local through `defaultSelectableSurfaces`.

The default app shell still instantiates `MockGeometryService`. The worker
adapter exists so a future runtime switch or native worker can be introduced
without changing UI widgets.

Adapter smoke command:

```powershell
dart run tool\mock_worker_geometry_service_smoke.dart
```

## Geometry Backend Selection

`CaseMakerApp` now asks a small backend factory for its `GeometryService`.
Normal builds still resolve to `MockGeometryService`.

Compile-time developer switch:

```powershell
flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=worker --dart-define=SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE=dart "--dart-define=SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS=run|occt_worker/bin/occt_worker.dart"
```

Bundled native OCCT worker preset:

```powershell
flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=native_occt
```

For local release bundles, `tools/build_latest_windows.ps1 -NativeOcct` builds
the app with that backend and copies the native worker bundle beside the app at
`occt_worker/native/occt_worker_native_occt.exe`.

Supported values:
- `SHELL_CASE_GEOMETRY_BACKEND`: `mock`, `worker`, or `native_occt`.
- `SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE`: executable path/name.
- `SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS`: pipe-separated argument list.
- `SHELL_CASE_GEOMETRY_WORKER_WORKING_DIRECTORY`: optional working directory.
- `SHELL_CASE_GEOMETRY_WORKER_TIMEOUT_MS`: optional timeout, default `30000`.

If `worker` is requested without an executable, the factory falls back to the
mock backend. If `native_occt` is requested without an executable override, the
factory looks for a bundled worker next to the app executable and falls back to
mock when it is missing. Widgets still receive only `GeometryService`; they do
not know about process clients or native worker command details.
