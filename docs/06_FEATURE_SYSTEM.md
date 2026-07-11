# 06 — Feature System

## Feature types

A feature is a semantic object that generates or affects geometry.

Operation categories:

```text
positive   — adds material
negative   — removes material
composite  — adds and removes
helper     — visible guide/keepout/reference, not exported as solid
modifier   — changes shape/style of another body/surface
exportable — produces manufacturing profile or part
```

## Base feature fields

```json
{
  "id": "usb_c_front",
  "type": "usb_c_cutout",
  "targetSurface": "main_enclosure.front.outer",
  "placement": {},
  "parameters": {},
  "operation": "negative",
  "validation": {}
}
```

## Feature lifecycle

1. Create semantic feature.
2. Show ghost preview.
3. User positions/configures.
4. Validate semantic constraints.
5. Generate geometry.
6. Validate geometry.
7. Commit undo transaction.

## Current viewport markers

The mock viewport derives transient markers from semantic features:
- `usb_c_cutout`,
- `glass_recess`,
- `circular_cutout`,
- `rectangular_cutout`.

These markers are selectable affordances only. They return semantic feature IDs
to the selection model and are not saved geometry, mesh IDs, triangle IDs, or
OCCT topology IDs.

## Current feature parameter editing

The contextual inspector can edit the first numeric parameter banks for:
- `usb_c_cutout`: width, height, corner radius,
- `glass_recess`: width, height, recess depth, ledge width, corner radius,
  insert thickness,
- `circular_cutout`: diameter, depth, face-local X, and face-local Y,
- `rectangular_cutout`: width, height, depth, corner radius, face-local X, and
  face-local Y.
- `rectangular_cutout` with `parameters.preset=slot`: the first-pass slot
  preset; width/height/depth/X/Y remain editable semantic parameters and corner
  radius is derived as half of the smaller side at creation time and after
  inspector size edits.

These edits update the selected `SemanticFeature.parameters` map and commit a
semantic undo snapshot. They do not edit generated geometry directly. The mock
viewport marker is rebuilt from semantic parameters after the project changes.
When a selected surface workplane point is active, new `circular_cutout`
and `rectangular_cutout` features start from that clicked face-local X/Y.
Manual front-wall `usb_c_cutout`, `glass_recess`, and manual `button_group`
objects started from an active snap target store that clicked point in
`placement.surfacePosition`, but the snap target itself is not saved as project
state.
The native OCCT worker consumes supported front-wall and top-lid
`circular_cutout` and `rectangular_cutout` feature intents, including slot
presets, as generated B-Rep subtraction tools; the editable source remains the
semantic feature parameters above.

## Advanced sketch helpers

`advanced_sketch` is a helper feature exposed only through Advanced Mode. It
stores a selected surface workplane and typed `SketchEntity` metadata. The first
supported entity is `rectangle`, with center, width, height, and corner-radius
parameters.

Sketch entities are still semantic helper data only. They do not generate
B-Rep, mesh, cuts, extrusions, or topology IDs yet. The inspector can add the
first rectangle entity to a selected sketch as an undoable project edit and can
edit its X/Y center, width, height, and corner radius through
`SketchEntityParameterAdapter`.

Rectangle parameter edits replace the stored sketch entity semantically. The
corner radius is clamped to half of the smaller side so the stored rectangle
stays valid for later drawing and geometry conversion work.

## Feature groups

Repeated elements must be grouped:
- button group,
- screw pattern,
- vent pattern,
- LED row,
- magnet set,
- support rib grid.

Groups store:
- item prototype,
- pattern,
- placement,
- overrides.

Current inspector editing supports the first parameter banks for
`button_group` and `standoff_mounts`. These edits replace group pattern/item
prototype maps semantically and do not detach repeated items into independent
features.

## Detach behavior

User can detach:
- one item from group,
- entire group into independent features,
- generated geometry into advanced editable body.

Detachment must be explicit and warn that parametric group behavior may be lost.

## Validation rules

Each feature should declare validation:
- required target surface,
- min/max dimensions,
- clearance profile,
- keepout interactions,
- wall thickness impact,
- printability warnings.

## UI rule

The inspector should show human controls, not internal fields.
