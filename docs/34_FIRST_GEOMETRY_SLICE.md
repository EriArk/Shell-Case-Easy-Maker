# 34 - First Geometry Slice

## Purpose

M5 establishes the boundary for real generated geometry without making Flutter
depend on OCCT internals.

The app still uses the mock viewport, but geometry requests and responses now
have typed JSON models that can be shared with a future native worker.

## Boundary

Flutter talks to `GeometryService`.

`GeometryService` can build a `GeometryRequest` and receive a `GeometryResponse`.

The future `occt_worker` consumes the same JSON protocol. It owns generated
B-Rep and OCCT topology internally, then returns disposable preview/export data.

## Request

`GeometryRequest` contains:
- protocol schema/version,
- request ID,
- operation,
- semantic project JSON,
- optional target IDs,
- generation options.

Supported initial operation:
- `preview_mesh`

Planned operations:
- `export_step`,
- `export_stl`,
- `validate`.

## Local Worker CLI

The current Dart worker CLI can exercise the JSON worker boundary without
native OCCT:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart
```

`GeometryWorkerProtocolHandler` validates the top-level payload, decodes the
request, calls a supplied build function, and emits response JSON. The harness
uses `MockGeometryService`, so it is useful for protocol smoke tests but not a
replacement for real B-Rep generation.

`tool/mock_geometry_worker.dart` remains as a compatibility alias, but new
worker-process tests and developer runs should target
`occt_worker/bin/occt_worker.dart`.

The CLI defaults to `--backend=mock`. Passing `--backend=native` returns a
structured `worker.backend.native_not_implemented` response until the real OCCT
backend exists.

The CLI can also report backend readiness without reading stdin:

```powershell
dart run occt_worker\bin\occt_worker.dart --capabilities
```

This emits `shell_case.geometry.worker.capabilities` JSON. Current capability
metadata marks mock geometry as available for `preview_mesh` and native OCCT as
a stub with planned preview/export/validate operations.

`GeometryWorkerProcessClient.queryCapabilities()` can request the same metadata
through the configured worker process and return typed capability data or typed
issues for timeouts, launch failures, invalid JSON, and non-zero exits.

The first native worker executable scaffold is separate from the Flutter
Windows runner:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1
```

It builds `occt_worker_native_stub` under `build/occt_worker_native`. The stub
can emit capabilities and structured not-implemented responses, but it does not
link OCCT or generate B-Rep yet.

The scaffold smoke command wraps build, capability query, and request smoke:

```powershell
dart run tool\native_worker_stub_smoke.dart
```

`GeometryWorkerProcessClient` can also exercise the same harness across a real
process boundary:

```powershell
dart run tool\mock_geometry_worker_client_smoke.dart
```

The process client captures stdout/stderr, preserves worker error responses,
normalizes geometry process failures into `GeometryResponse` issues, and
normalizes capability query failures into a capability result with issues.

`WorkerGeometryService` wraps the process client behind the app-facing
`GeometryService` interface. It can be smoke-tested against the mock worker:

```powershell
dart run tool\mock_worker_geometry_service_smoke.dart
```

The default app can now select its geometry backend through a small factory.
Normal builds use mock geometry. A developer can opt into a worker command with
`--dart-define` values, for example:

```powershell
flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=worker --dart-define=SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE=dart "--dart-define=SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS=run|occt_worker/bin/occt_worker.dart"
```

## Generated Protocol Fixtures

The example worker payloads are generated from typed Dart models instead of
being hand-edited:

```powershell
dart run tool\generate_geometry_protocol_fixtures.dart
```

The generator writes:
- `occt_worker/protocol/preview_request.example.json`,
- `occt_worker/protocol/preview_response.example.json`.

The request fixture contains the semantic sample project plus derived
`featureIntents` for USB-C, the source button group, projected button-group
items, and standoff work. The response fixture is produced by
`MockGeometryService`, so it records the current mock preview mesh and
operation-plan metrics while the native OCCT worker is still absent.

Current fixture smoke expectations:
- `featureIntents`: `4`,
- `operationCount`: `10`,
- backend: `mock`.

## Response

`GeometryResponse` contains:
- protocol schema/version,
- request ID,
- status,
- backend label,
- optional preview mesh,
- optional artifacts,
- issues,
- metrics.

Preview mesh data is generated output. It must not become editable project
state.

## Preview Mesh Mapping

`PreviewMesh` stores:
- units,
- flattened vertices,
- flattened triangle indices,
- bounds,
- semantic surface mappings.

`PreviewSurfaceMapping` uses semantic IDs such as:
- `main_enclosure.top_lid.outer`,
- `main_enclosure.front_wall.outer`,
- `main_enclosure.bottom_inside`.

Triangle ranges are allowed only as disposable preview metadata. They are not
stable project IDs and must not leak into semantic editing.

## Initial Rounded Enclosure Plan

The first real worker implementation should:

1. Read the semantic enclosure body.
2. Validate dimensions, wall thickness, and corner radius.
3. Build a box from `size`.
4. Apply radius to eligible enclosure edges.
5. Preserve named semantic surface mappings.
6. Mesh with explicit linear/angular deflection settings.
7. Return bounds, mesh stats, warnings, and preview mesh.

Expected sample dimensions:
- size: `120 x 70 x 28 mm`,
- wall thickness: `2 mm`,
- corner radius: `4 mm`,
- initial bounds: `[-60, -35, 0]` to `[60, 35, 28]`.

## Current Limitations

- No native OCCT executable is built yet.
- `occt_worker/bin/occt_worker.dart` is a Dart-only local worker CLI backed by
  mock geometry by default.
- `dart run occt_worker\bin\occt_worker.dart --capabilities` reports worker
  backend readiness, not generated geometry.
- `occt_worker/native` is a buildable native stub only; OCCT B-Rep generation is
  still planned.
- `tool/mock_geometry_worker.dart` is only a compatibility alias for the local
  worker runtime.
- `--backend=native` currently returns a structured not-implemented response,
  not native OCCT output.
- `tool/mock_geometry_worker_client_smoke.dart` runs the local worker CLI
  through the process client, not through native OCCT.
- `tool/mock_worker_geometry_service_smoke.dart` runs the worker-backed
  `GeometryService` adapter through the same mock worker process.
- The normal app backend selector defaults to mock unless worker backend and
  executable are both explicitly configured.
- The protocol example files are generated fixtures backed by the typed Dart
  sample project and mock backend, not native OCCT output.
- Mock backend returns a deterministic cuboid preview mesh.
- Mock backend validation now runs first-pass semantic checks for enclosure
  dimensions, wall thickness, USB-C/glass feature sizes, component placement
  bounds, component feature keepouts, and standoff mount safety. Component
  placement/keepout bounds account for Z rotation using conservative envelopes.
  This is still pre-geometry validation, not OCCT body validation.
- Rounded edges and shell/cavity generation are planned, not implemented.
- STEP/STL export operations intentionally return unsupported in the mock
  backend.
