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
