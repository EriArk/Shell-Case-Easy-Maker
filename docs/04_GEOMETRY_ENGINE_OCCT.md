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
