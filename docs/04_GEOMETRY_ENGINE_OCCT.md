# 04 — Geometry Engine: OpenCascade / OCCT

## Decision

OpenCascade is the primary geometry kernel. The app is B-Rep-first, not mesh-first.

## Why OCCT

The app needs:
- accurate enclosures,
- light rounding,
- proper fillets/chamfers,
- precise holes,
- STEP export,
- STL generated from exact geometry,
- controlled booleans,
- CAD-grade surfaces.

Mesh-first libraries are useful later for limited tasks, but not as the core.

## Worker architecture

`occt_worker` should be a standalone native executable or service.

Inputs:
- semantic project JSON,
- derived semantic feature intents for the current request,
- export request,
- feature preview request,
- validation request.

Outputs:
- preview mesh path/buffer,
- STEP/STL/DXF path,
- selectable surfaces metadata,
- warnings,
- errors,
- geometry stats.

## Critical rule

Do not expose raw OCCT topology as the product model. OCCT topology can change after boolean/fillet operations. Product semantics must remain stable.

## Surface IDs

Use semantic surface IDs:
- `enclosure.top_lid.outer`
- `enclosure.front_wall.outer`
- `slot.battery.cover.outer`
- `case.back.outer`

Do not store selected triangle IDs as permanent model references.

## Fillet/chamfer policy

Avoid a universal “fillet all edges” workflow in MVP.

Instead, each semantic generator should build controlled geometry:
- rounded box generator,
- rounded rectangular cutout,
- chamfered screw boss,
- rounded glass recess,
- smooth button cap,
- rib with filleted base.

This reduces unpredictable OCCT edge cases.

## Boolean policy

Use controlled boolean operations:
- base solid minus inner cavity,
- cutout prisms,
- boss unions,
- slot cavities,
- insert recesses.

Batch operations where possible. Keep feature order deterministic.

## Feature intents

`GeometryRequest.previewMesh(project)` now carries a `featureIntents` list
derived from `ProjectModel.features` and `ProjectModel.featureGroups`.

Each intent keeps stable semantic IDs, target surfaces, operation category,
parameters, placement/source metadata, and derived group items for repeated
features such as button groups and standoff mounts. These derived items are
request payload for the geometry backend only; they are not editable project
state and they do not flatten feature groups in `ProjectModel`.

The worker must consume these semantic intents, not Flutter widget state, mesh
triangle IDs, or raw OCCT topology IDs.

## Operation plan

`GeometryOperationPlanner` turns feature intents into deterministic backend
operations before real B-Rep generation exists:

- `usb_c_cutout` -> `cutout.usb_c`,
- `glass_recess` -> `recess.glass`,
- `button_group` items -> `cutout.button`,
- `standoff_mounts` items -> `mount.standoff`.

The mock backend exposes this plan in response metrics for testing and worker
development. The plan is disposable backend input. It must not be saved as the
editable project model and must not contain OCCT topology IDs.

## Mock worker protocol harness

Before the native OCCT executable exists, `tool/mock_geometry_worker.dart`
provides a stdin/stdout JSON harness over the same request/response protocol.
It is backed by `MockGeometryService` and exits with a non-zero code when the
response contains errors.

This harness is only a protocol and integration aid. It does not generate
OpenCascade B-Rep, and it must not become the editable geometry source.

## Worker process client

`GeometryWorkerProcessClient` is the Dart-side process adapter for the future
native worker. It writes request JSON to stdin, reads response JSON from stdout,
and treats stderr/exit codes as process metadata rather than product semantics.

It preserves structured worker error responses, but reports adapter-level
issues for invalid JSON, process launch failures, timeouts, and non-zero exits
that do not return an error response. This keeps Flutter isolated from native
worker crashes and prevents native process details from becoming editable
project data.

## Preview mesh

Preview mesh is generated from B-Rep with adjustable quality:
- fast preview during drag,
- high-quality preview after edit,
- export quality for STL.

## Geometry validation examples

- Body is valid solid.
- Minimum wall thickness.
- Cutout does not remove entire wall.
- Fillet radius fits local geometry.
- Component keepout not violated.
- Slot insertion direction is clear.
- Hard case does not contain impossible undercut unless split.

## Research tasks

Before implementing:
- Review OCCT shape creation.
- Review OCCT boolean operations.
- Review OCCT fillet/chamfer APIs.
- Review STEP export.
- Review STL mesh generation/tessellation.
- Review DXF generation strategy, either direct library or extracted curves written by own exporter.
