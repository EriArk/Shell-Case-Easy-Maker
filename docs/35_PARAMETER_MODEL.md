# 35 - Parameter Model

## Purpose

The parameter model defines reusable typed controls for semantic generators.

Generators should not pass around unvalidated number maps. A parameter schema
declares human labels, units, defaults, ranges, steps, choices, and validation
rules before UI controls or geometry code consume values.

## Core Types

`ParameterSchema` groups parameter definitions for one semantic tool or
generator.

`ParameterDefinition` declares:
- stable ID,
- label,
- kind,
- unit,
- default value,
- optional range,
- optional choices,
- required flag.

`ParameterRange` declares:
- min,
- max,
- optional step.

`ParameterOption` declares one available choice.

`ParameterIssue` reports validation problems by parameter ID.

## Supported Kinds

- `length`
- `angle`
- `count`
- `ratio`
- `boolean`
- `choice`
- `text`

The model is intentionally UI-neutral. Widgets can render sliders, steppers,
choice menus, toggles, and text fields from the same schema later.

## Defaults and Validation

`applyDefaults()` normalizes incoming values and fills missing values from the
schema.

`validate()` checks raw incoming values for:
- invalid type,
- range violations,
- unavailable choices,
- required missing values.

This keeps generator inputs predictable while still letting the UI snap values
to configured steps.

## First Schema

`CoreParameterSchemas.roundedEnclosure` defines the first enclosure generator
bank:
- width,
- depth,
- height,
- wall thickness,
- corner radius,
- lid type.

The schema uses millimeters for length values and Russian human labels for
future default UI controls.

## Inspector Adapter

`EnclosureParameterAdapter` maps the first semantic `Enclosure` fields to the
rounded enclosure schema:
- `size[0]` to width,
- `size[1]` to depth,
- `size[2]` to height,
- `wallThickness`,
- `cornerRadius`,
- `lid.type` to lid type.

The adapter applies schema defaults and snapping before returning a new
`Enclosure`. It does not store generated mesh, B-Rep, or preview state in the
project model.

The contextual inspector uses this adapter for the first editable enclosure
controls. Changes update the local semantic `ProjectModel`, then refresh the
mock `GeometryService` preview and validation futures.

The first create-enclosure rail command also uses this schema and adapter. Its
dialog edits normalized schema values, then applies them to the semantic
`Enclosure` before committing one undoable project snapshot.

The contextual inspector also uses a small schema-backed parameter bank for
selected component placements. It edits X/Y/Z position, Z rotation, mounting
side, the locked flag, and the visibility flag, then writes those values back
to the semantic `ComponentPlacement`. This is still UI-side schema usage; the
saved project continues to store the typed placement fields.

`SketchEntityParameterAdapter` maps the first Advanced Sketch rectangle entity
to a schema-backed parameter bank:
- center X,
- center Y,
- width,
- height,
- corner radius.

The adapter writes values back to `SketchEntity.parameters`, normalizes numeric
precision for stable JSON, and clamps corner radius to half of the smaller
side. Inspector nudge, move-to-click, and resize actions reuse these normalized
values so each movement or size edit stays a semantic undoable edit. When a
supported sketch workplane size is available, the adapter can also report a
warning if the rectangle extends outside that workplane. These values remain
semantic helper data until sketch drawing and geometry conversion are designed.

## Current Limitations

- Parameter values are not stored as a separate typed layer in `ProjectModel`
  yet; current semantic objects still store their existing fields/maps.
- Cross-parameter validation, such as "corner radius must fit body dimensions",
  and cross-object validation, such as "placed board must fit inside the
  enclosure", belong in generator-specific semantic validation. The first pass
  now lives in `ProjectSemanticValidator`, not in `ParameterSchema`.
- Only the rounded enclosure schema, first component placement editor schema,
  and first sketch rectangle entity schema are wired into object-level UI
  controls so far.
