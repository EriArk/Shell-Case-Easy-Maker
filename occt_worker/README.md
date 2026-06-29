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
typed Dart fixture project and the mock backend. No native executable is built
yet.

Regenerate protocol fixtures:

```powershell
dart run tool\generate_geometry_protocol_fixtures.dart
```

The generated request includes semantic `featureIntents`; the generated
response includes mock backend operation-plan metrics. These files are protocol
fixtures, not editable project geometry and not native OCCT output.

Smoke command:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart
```

The smoke harness is backed by `MockGeometryService`; it exercises request and
response JSON only.

Process-client smoke command:

```powershell
dart run tool\mock_geometry_worker_client_smoke.dart
```

This starts the mock harness as a child process and verifies the stdin/stdout
adapter path that the future native worker will use.

Worker-service smoke command:

```powershell
dart run tool\mock_worker_geometry_service_smoke.dart
```

This verifies the app-facing `GeometryService` adapter path against the mock
worker process.

Developer app backend switch:

```powershell
flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=worker --dart-define=SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE=dart "--dart-define=SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS=run|tool/mock_geometry_worker.dart"
```

Normal app builds still default to mock geometry. The worker backend is selected
only when explicitly configured.

## Planned responsibilities

- Read `shell_case.geometry.request` JSON from stdin or a local IPC transport.
- Generate B-Rep from semantic project data.
- Consume request `featureIntents` for semantic cutouts, recesses, button
  groups, and mounts.
- Consume deterministic operation-plan tasks derived from those feature
  intents.
- Mesh B-Rep for disposable preview output.
- Export STEP/STL later.
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

1. Build a box from enclosure dimensions.
2. Apply corner fillets from semantic corner radius.
3. Preserve semantic surface mapping for top lid, front wall, and bottom inside.
4. Read `featureIntents` and their derived operation plan to prepare
   deterministic future cutout/mount operations.
5. Mesh the generated B-Rep with explicit deflection settings.
6. Return preview mesh, bounds, issues, and metrics.

The worker implementation should be added only after the OCCT build/distribution
choice is finalized for Windows development.
