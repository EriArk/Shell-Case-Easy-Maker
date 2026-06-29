# occt_worker

This directory is the future native geometry worker boundary.

The Flutter app must not import OCCT headers, expose OCCT topology IDs, or store
generated B-Rep/mesh data as editable project state. Flutter sends semantic
geometry requests through `GeometryService`; the worker returns generated
preview/export results.

## Current status

M5 adds only the protocol skeleton. No native executable is built yet.

## Planned responsibilities

- Read `shell_case.geometry.request` JSON from stdin or a local IPC transport.
- Generate B-Rep from semantic project data.
- Consume request `featureIntents` for semantic cutouts, recesses, button
  groups, and mounts.
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
4. Read `featureIntents` to prepare deterministic future cutout/mount
   operations.
5. Mesh the generated B-Rep with explicit deflection settings.
6. Return preview mesh, bounds, issues, and metrics.

The worker implementation should be added only after the OCCT build/distribution
choice is finalized for Windows development.
