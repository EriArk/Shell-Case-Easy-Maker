# occt_worker

This directory is the future native geometry worker boundary.

The Flutter app must not import OCCT headers, expose OCCT topology IDs, or store
generated B-Rep/mesh data as editable project state. Flutter sends semantic
geometry requests through `GeometryService`; the worker returns generated
preview/export results.

## Current status

M5 adds the protocol skeleton, M47 adds a Dart-only mock protocol harness, M48
adds the Dart-side process client, and M49 adds the worker-backed
`GeometryService` adapter. M50 adds an explicit backend selection switch for
development runs. M51 keeps the checked-in protocol examples generated from a
typed Dart fixture project and the mock backend. M52 adds
`occt_worker/bin/occt_worker.dart` as the canonical local worker CLI. M53 adds
worker capability JSON for backend readiness and supported operations. M55 adds
a separately buildable native stub executable; it does not link OCCT. M56 adds a
native smoke command. M57 makes the native stub read and validate the top-level
request envelope before returning scaffold responses. M58 records the Windows
OCCT dependency decision. M59-M62 add and locally restore the separate opt-in
`occt_worker_native_occt` target. M63 makes that target build the first rounded
enclosure B-Rep internally and return deterministic metrics. M64 emits the first
disposable native preview mesh from that B-Rep.

Regenerate protocol fixtures:

```powershell
dart run tool\generate_geometry_protocol_fixtures.dart
```

The generated request includes semantic `featureIntents`; the generated
response includes mock backend operation-plan metrics. These files are protocol
fixtures, not editable project geometry and not native OCCT output.

Smoke command:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart
```

The local CLI is backed by `MockGeometryService` by default; it exercises
request and response JSON only. `tool/mock_geometry_worker.dart` remains as a
compatibility alias.

Native backend stub command:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart --backend=native
```

This currently returns a structured `worker.backend.native_not_implemented`
error response.

Capability command:

```powershell
dart run occt_worker\bin\occt_worker.dart --capabilities
```

This emits `shell_case.geometry.worker.capabilities` JSON. Today it reports the
mock backend as `available` for `preview_mesh` and the native backend as
`stub`. Capability JSON is metadata only; it is not editable project geometry.
Dart callers can query the same metadata through
`GeometryWorkerProcessClient.queryCapabilities()`.

Native stub build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1
```

The resulting executable is local build output under `build/occt_worker_native`.
It can report capabilities and returns `worker.backend.native_not_implemented`
for valid geometry request envelopes. It also returns structured
`worker.request.*` errors for empty payloads, non-object payloads, invalid
schemas, and invalid operations. This target is a scaffold for the future OCCT
worker, not native B-Rep generation.

Native stub smoke command:

```powershell
dart run tool\native_worker_stub_smoke.dart
```

The smoke command builds the native stub, queries capabilities through
`GeometryWorkerProcessClient.queryCapabilities()`, sends a preview request, and
expects `worker.backend.native_not_implemented` while also verifying that the
native response preserves the request ID.

Windows OCCT readiness command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1
```

The command is read-only. It reports whether `OpenCASCADEConfig.cmake` is
discoverable through `OpenCASCADE_DIR`, `CASROOT`, or a vcpkg-style install.
The dependency decision is recorded in
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`.

Preview repo-local vcpkg setup without cloning or installing:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly
```

The bootstrap helper uses ignored `external/vcpkg` output and installs the OCCT
manifest dependency only when `-InstallOpenCascade` is passed. Manifest-mode
package output is ignored under `occt_worker/native/vcpkg_installed`.

Opt-in OCCT target build command after readiness is true:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1
```

If `VCPKG_ROOT` is configured but OCCT is not installed yet, add
`-AllowVcpkgInstall` to let vcpkg restore `occt_worker/native/vcpkg.json`
explicitly.
Use `-Clean` once if the build directory was configured with different manifest
mode settings.

This builds `occt_worker_native_occt` under `build/occt_worker_native_occt`.
The target references OCCT modeling APIs, reports `status=preview_mesh_smoke`,
and returns a disposable rounded enclosure preview mesh plus deterministic
metrics for `preview_mesh` requests. It also supports the first `export_step`
and `export_stl` operations, writing generated artifacts to an explicit
`options.outputPath`. It still does not emit editable generated geometry.

Native OCCT metrics smoke command:

```powershell
dart run tool\native_occt_worker_metrics_smoke.dart --skip-build
```

The smoke command queries capabilities through
`GeometryWorkerProcessClient.queryCapabilities()`, sends the sample preview
request, and verifies bounds, dimensions, surface area, volume, preview mesh
counts, request ID preservation, and `editableGeneratedGeometry=false`.

Native OCCT geometry regression test:

```powershell
flutter test test\native_occt_geometry_regression_test.dart --reporter compact
```

The test launches the built native OCCT worker when it exists locally and
checks the same known sample dimensions, mesh counts, mapped semantic ranges,
and non-editable generated geometry contract. It is skipped on machines where
the opt-in native worker has not been built.

Native OCCT STEP export test:

```powershell
flutter test test\native_occt_step_export_test.dart --reporter compact
```

The test sends an `export_step` request with an explicit temporary
`options.outputPath`, verifies that the worker returns a STEP artifact response,
and checks that the generated file is an `ISO-10303-21` payload. STEP output is
generated from OCCT B-Rep and is not editable project state.

Native OCCT STL export test:

```powershell
flutter test test\native_occt_stl_export_test.dart --reporter compact
```

The test sends an `export_stl` request with an explicit temporary
`options.outputPath`, verifies that the worker returns a binary STL artifact
response, and checks the STL byte layout and triangle count. STL output is
generated from OCCT B-Rep tessellation and is not editable project state.

Process-client smoke command:

```powershell
dart run tool\mock_geometry_worker_client_smoke.dart
```

This starts the mock harness as a child process and verifies the stdin/stdout
adapter path used by the native worker.

Worker-service smoke command:

```powershell
dart run tool\mock_worker_geometry_service_smoke.dart
```

This verifies the app-facing `GeometryService` adapter path against the mock
worker process.

Developer app backend switch:

```powershell
flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=worker --dart-define=SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE=dart "--dart-define=SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS=run|occt_worker/bin/occt_worker.dart"
```

Bundled native OCCT app backend:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct
```

This builds the app with `SHELL_CASE_GEOMETRY_BACKEND=native_occt` and copies
the worker bundle to `releases/latest/windows/occt_worker/native`.

Normal app builds still default to mock geometry. The worker backend is selected
only when explicitly configured.

## Planned responsibilities

- Read `shell_case.geometry.request` JSON from stdin or a local IPC transport.
- Validate request envelope schema, operation, and request ID before geometry
  generation.
- Generate B-Rep from semantic project data.
- Consume request `featureIntents` for semantic cutouts, recesses, button
  groups, and mounts.
- Consume deterministic operation-plan tasks derived from those feature
  intents.
- Mesh B-Rep for disposable preview output.
- Export STEP/STL artifacts.
- Return `shell_case.geometry.response` JSON.
- Map preview faces back to semantic IDs.

## Non-goals

- Do not own or mutate product semantics.
- Do not return raw OCCT `TopoDS_*` IDs to Flutter.
- Do not make preview mesh the editable source of truth.
- Do not flatten semantic feature groups as the default workflow.

## First target

Generate a deterministic rounded enclosure preview from the sample semantic
project:

1. Build a box from enclosure dimensions. Done for the native metrics slice.
2. Apply corner fillets from semantic corner radius. Done for the native metrics
   slice.
3. Return deterministic bounds, dimensions, surface area, and volume. Done for
   the native metrics slice.
4. Mesh the generated B-Rep with explicit deflection settings. Done for the
   native preview mesh slice.
5. Return preview mesh, bounds, issues, and metrics. Done for the native
   preview mesh slice.
6. Preserve first-pass semantic surface mapping for top lid, front wall, and
   bottom inside. Done for disposable preview ranges.
7. Generate a top-open shell/cavity from semantic wall thickness. Done for the
   native shell slice.
8. Read first-pass `featureIntents` and cut the front-wall USB-C opening from
   semantic dimensions. Done for the native USB-C slice.
9. Continue with button/glass cutouts, mounts, STEP, and STL.

The worker remains replaceable and must keep generated B-Rep, OCCT topology IDs,
and preview triangle IDs out of editable project state.
