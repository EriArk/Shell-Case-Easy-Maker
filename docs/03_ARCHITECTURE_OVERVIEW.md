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
items to describe future cut/add/recess tasks for the worker. It is still
request/response-scoped backend input, not saved editable project state.

## Mock Worker Protocol Harness

`GeometryWorkerProtocolHandler` is the first stdin/stdout-style boundary for
worker requests. It receives request JSON, validates the top-level worker
payload, decodes a `GeometryRequest`, calls a supplied `buildGeometry`
function, and returns response JSON.

The current CLI harness is Dart-only:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart
```

It uses `MockGeometryService` so protocol tests and smoke checks can exercise
the worker boundary before the native OCCT executable exists. It does not make
generated mesh, B-Rep, STL, or topology IDs editable project state.

## Worker Process Client

`GeometryWorkerProcessClient` is the first external-process adapter. It sends a
`GeometryRequest` JSON payload to a configured worker command through stdin,
captures stdout/stderr, parses a `GeometryResponse`, and converts process-level
failures into normal geometry response issues.

Current normalized failures:
- worker launch/process failure,
- timeout,
- invalid response JSON,
- non-zero exit code without a worker error response.

The client is not wired into the default app shell yet. The app still uses
`MockGeometryService` for interactive preview until a real worker executable
exists and the runtime switch is deliberate.

Smoke command:

```powershell
dart run tool\mock_geometry_worker_client_smoke.dart
```

## Worker GeometryService Adapter

`WorkerGeometryService` implements the same app-facing `GeometryService`
contract as the in-process mock service, but routes preview/build requests
through `GeometryWorkerProcessClient`.

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
