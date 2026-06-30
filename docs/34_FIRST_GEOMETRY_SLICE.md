# 34 - First Geometry Slice

## Purpose

M5 establishes the boundary for real generated geometry without making Flutter
depend on OCCT internals.

The app can still use the mock viewport, but geometry requests and responses now
have typed JSON models shared with the native worker.

## Boundary

Flutter talks to `GeometryService`.

`GeometryService` can build a `GeometryRequest` and receive a `GeometryResponse`.

`occt_worker` consumes the same JSON protocol. It owns generated B-Rep and OCCT
topology internally, then returns disposable preview/export data.

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

The native stub now reads the top-level worker request envelope before returning
that scaffold response. It preserves `requestId`, validates the request schema
and operation, and returns typed `worker.request.*` issues for invalid payloads.
This is protocol hardening only; it does not make native generated geometry
editable or replace the semantic project model.

The Windows OCCT dependency plan is recorded in
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`. Before adding an OCCT-linked target,
run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1
```

To inspect the repo-local vcpkg setup before changing local files, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly
```

The helper uses ignored `external/vcpkg` output and restores `opencascade` only
when `-InstallOpenCascade` is passed. Manifest-mode installed packages are
local-only under ignored `occt_worker/native/vcpkg_installed`.

Once readiness is true, build the opt-in OCCT target:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1
```

To let vcpkg restore `occt_worker/native/vcpkg.json` explicitly, rerun that
command with `-AllowVcpkgInstall` after `VCPKG_ROOT` is configured.
Use `-Clean` once if the native build directory was configured before OCCT
readiness became true or before manifest mode was enabled.

The target is `occt_worker_native_occt`. It is separate from
`occt_worker_native_stub`, references OCCT modeling APIs, and now implements the
first rounded enclosure preview mesh slice for `preview_mesh` requests.
Capabilities report `status=preview_mesh_smoke`.

The native OCCT smoke command verifies the built target through the Dart process
client:

```powershell
dart run tool\native_occt_worker_metrics_smoke.dart --skip-build
```

The current native response returns deterministic bounds, dimensions, surface
area, volume, disposable preview mesh data, and first-pass semantic surface
ranges for the first semantic enclosure. For the sample enclosure it emits a
top-open rounded shell/cavity with one native USB-C front-wall cutout, 1418
vertices, 1754 triangles, 3 surface mappings, and 538 mapped triangles. It still
does not return STL, B-Rep, OCCT topology IDs, or triangle IDs as stable editable
references.

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

The app also has a native OCCT preset:

```powershell
flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=native_occt
```

For local manual builds, `tools/build_latest_windows.ps1 -NativeOcct` builds the
app with that backend and bundles the native worker under
`releases/latest/windows/occt_worker/native`. The factory resolves that worker
relative to the app executable and falls back to mock if the bundled worker is
missing.

The shell now carries `GeometryResponse.previewMesh` through
`GeometryPreview.previewMesh` and draws it as a disposable faceted viewport body
layer. Semantic component, feature, workplane, snap, ghost, and selection
overlays remain separate, and viewport picking still resolves semantic IDs
rather than generated triangle IDs or OCCT topology.

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

For the first top-open native shell, the selected `top_lid.outer` semantic ID
maps to the generated top rim because the original top face is cut away by the
cavity generator. This keeps selection highlighting semantic while the separate
lid/body split is still future work.

Triangle ranges are allowed only as disposable preview metadata. They are not
stable project IDs and must not leak into semantic editing.

The native preview mesh can also expose generated feature ranges by semantic
feature ID. Current feature mappings include `front_usb_c` for the generated
USB-C cutout faces and `front_glass_recess` for the first shallow front-wall
glass recess. `main_enclosure.front_wall.outer` remains the front wall surface
mapping.

## Initial Rounded Enclosure Plan

The first native OCCT slices now:

1. Read the semantic enclosure body.
2. Validate dimensions, wall thickness, and corner radius.
3. Build a box from `size`.
4. Apply radius to eligible enclosure edges.
5. Build one rounded internal cavity tool from semantic wall thickness.
6. Cut a top-open shell/cavity from the rounded outer B-Rep.
7. Check the resulting shell/cavity shape with `BRepCheck_Analyzer`.
8. Read first-pass USB-C and glass-recess `featureIntents` targeting the front
   wall.
9. Build a rounded rectangular USB-C cut tool and subtract it from the shell.
10. Build a shallow rounded rectangular glass-recess tool and subtract it from
    the shell without cutting through the wall.
11. Return deterministic bounds, dimensions, surface area, and volume.
12. Mesh the generated B-Rep with explicit linear/angular deflection settings.
13. Return disposable preview mesh vertices and triangle indices.
14. Return first-pass semantic preview surface ranges for top rim, front, and
    bottom face blocks.
15. Return disposable `front_usb_c` and `front_glass_recess` feature ranges for
    generated feature highlighting.

The next native geometry slices should:

1. Consume button-group feature intents.
2. Generate real standoff/mount geometry.
3. Add screw-boss/lid-body split geometry.
4. Add top-lid glass recess support after a real lid/body split exists.
5. Expand semantic face mapping beyond the first top/front/bottom ranges.

Expected sample dimensions:
- size: `120 x 70 x 28 mm`,
- wall thickness: `2 mm`,
- corner radius: `4 mm`,
- native preview bounds: `[-60, -35, 0]` to `[60, 35, 27.464102]`,
- native preview volume after USB-C plus front glass recess:
  `33427.951321 mm^3`,
- native preview surface area after USB-C plus front glass recess:
  `34797.533162 mm^2`,
- native preview surface mappings after feature ranges: `5`,
- native preview mapped triangles after feature ranges: `796`,
- native feature metrics: `featureIntentCount=3`,
  `nativeFeatureCutCount=2`, `nativeIgnoredFeatureIntentCount=1`,
  `nativeUsbCCutoutCount=1`, `nativeGlassRecessCount=1`.

## Current Limitations

- `occt_worker/bin/occt_worker.dart` is a Dart-only local worker CLI backed by
  mock geometry by default.
- `dart run occt_worker\bin\occt_worker.dart --capabilities` reports worker
  backend readiness, not generated geometry.
- `occt_worker/native` has both a no-OCCT stub and an opt-in OCCT target. The
  OCCT target can build a rounded enclosure B-Rep internally and return a
  disposable preview mesh plus first-pass semantic surface ranges and metrics.
- `tool/mock_geometry_worker.dart` is only a compatibility alias for the local
  worker runtime.
- `--backend=native` currently returns a structured not-implemented response,
  not native OCCT output.
- `tool/mock_geometry_worker_client_smoke.dart` runs the local worker CLI
  through the process client, not through native OCCT.
- `tool/mock_worker_geometry_service_smoke.dart` runs the worker-backed
  `GeometryService` adapter through the same mock worker process.
- `tool/native_occt_worker_metrics_smoke.dart` runs the native OCCT target
  through the Dart process client and checks the preview mesh, semantic surface
  ranges, and metrics response.
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
- Rounded edges, first top-open native shell/cavity generation, first native
  USB-C front-wall cutout, first native preview mesh emission, and first-pass
  semantic surface ranges are implemented; button/glass feature cuts,
  screw/lid geometry, and richer face mapping are still planned.
- STEP/STL export operations intentionally return unsupported in the mock
  backend.
