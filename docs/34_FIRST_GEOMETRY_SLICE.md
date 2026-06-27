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
- Mock backend returns a deterministic cuboid preview mesh.
- Rounded edges and shell/cavity generation are planned, not implemented.
- STEP/STL export operations intentionally return unsupported in the mock
  backend.
