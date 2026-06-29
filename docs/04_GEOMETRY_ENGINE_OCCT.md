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

## Generated protocol fixtures

The protocol example files under `occt_worker/protocol/` are generated from a
typed Dart fixture project:

```powershell
dart run tool\generate_geometry_protocol_fixtures.dart
```

The request example contains semantic feature intents and expanded repeated
items. The response example is produced by `MockGeometryService`, including the
mock preview mesh and operation plan metrics. These fixtures let the future
native worker develop against realistic payloads without making mock mesh,
B-Rep, STL, or OCCT topology editable project state.

## Local worker CLI

Before the native OCCT backend exists, `occt_worker/bin/occt_worker.dart`
provides the canonical stdin/stdout JSON command over the same request/response
protocol. It is backed by `GeometryWorkerRuntime`, defaults to
`MockGeometryService`, and exits with a non-zero code when the response contains
errors.

Smoke command:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart
```

`tool/mock_geometry_worker.dart` remains as a compatibility alias. Passing
`--backend=native` intentionally returns `worker.backend.native_not_implemented`
until the real OCCT implementation is available.

This CLI is only a protocol and integration aid. It does not generate
OpenCascade B-Rep yet, and it must not become the editable geometry source.

Worker backend readiness can be inspected separately from geometry generation:

```powershell
dart run occt_worker\bin\occt_worker.dart --capabilities
```

The capability response marks the Dart mock backend as available for
`preview_mesh` and the future OCCT backend as a `native` stub. The planned native
operations are preview mesh, STEP export, STL export, and validation. Capability
JSON is metadata; it must not contain raw OCCT topology IDs or generated B-Rep.
`GeometryWorkerProcessClient.queryCapabilities()` consumes this JSON through the
same configured process command that will later launch the native worker.

## Native worker scaffold

`occt_worker/native` contains the first standalone native executable scaffold:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1
```

The target is `occt_worker_native_stub` and its build output stays under
`build/occt_worker_native`. It currently supports `--capabilities` and returns a
structured `worker.backend.native_not_implemented` response for valid geometry
request envelopes. Before returning that scaffold response, it reads the
top-level request envelope, preserves `requestId`, validates the protocol
schema and operation, and emits typed `worker.request.*` issues for malformed
or unsupported envelopes.

This scaffold intentionally does not link OCCT yet. It exists to prove the
native worker build boundary, process invocation, and protocol-shaped error
responses before B-Rep generation is added.

The Windows dependency decision for the first OCCT-linked worker target is
recorded in `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`. The current decision is
to keep the stub build independent of OCCT, use vcpkg or an explicit
`OpenCASCADE_DIR`/`CASROOT` as the first developer acquisition path, and add a
separate opt-in OCCT-linked target only after local readiness is true.

Readiness command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1
```

Opt-in OCCT target build command after readiness is true:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1
```

If `VCPKG_ROOT` is configured and the developer intentionally wants vcpkg to
restore the manifest dependency, add `-AllowVcpkgInstall`. The manifest lives at
`occt_worker/native/vcpkg.json` and currently declares only `opencascade`.

This builds `occt_worker_native_occt`, a separate link-smoke target that
references OCCT modeling APIs but still returns
`worker.backend.occt_link_smoke_only` for geometry requests. It does not replace
the stub, and it does not generate semantic B-Rep yet.

Native scaffold smoke command:

```powershell
dart run tool\native_worker_stub_smoke.dart
```

The smoke command builds the stub, queries capabilities through the Dart process
client, sends a preview request, verifies request ID preservation, and treats
`worker.backend.native_not_implemented` as the expected result while OCCT is
still absent.

## Worker process client

`GeometryWorkerProcessClient` is the Dart-side process adapter for the future
native worker. It writes request JSON to stdin, reads response JSON from stdout,
and treats stderr/exit codes as process metadata rather than product semantics.

It preserves structured worker error responses, but reports adapter-level
issues for invalid JSON, process launch failures, timeouts, and non-zero exits
that do not return an error response. This keeps Flutter isolated from native
worker crashes and prevents native process details from becoming editable
project data.

## Worker-backed GeometryService

`WorkerGeometryService` is the replaceable service adapter that UI code can use
later instead of `MockGeometryService`. It speaks only the public geometry
protocol and process-client API; it does not expose native OCCT types, topology
IDs, process stderr, or generated mesh as editable project state.

Until native geometry validation exists, semantic validation remains local in
Dart. Selectable surface IDs are also semantic and local, not derived from
preview triangle IDs.

## Backend selection

`GeometryBackendSettings` and `createGeometryService` provide the intentional
runtime switch between mock and worker-backed geometry services. The switch is
compile-time configured with `--dart-define` values and defaults to mock.

The worker path requires an explicit executable. If it is missing, startup uses
the mock backend so the app remains usable. This is a developer integration
switch, not a user-facing modeling mode.

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
