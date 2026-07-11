# 30 — Advanced CAD Mode

## Purpose

Provide escape hatches for professional users and edge cases without harming beginner UX.

## Default state

Advanced mode is hidden/collapsed.

The workspace shell now has a transient Advanced Mode toggle in the lower part
of the left tool rail. It is off by default, is not saved in `ProjectModel`, and
does not participate in undo/redo, file save/load, or geometry requests.

When enabled, the rail reveals a separate advanced section. The first exposed
tool is `advanced.sketch` (`Эскиз`). It creates a saved semantic
`advanced_sketch` helper feature on a selected surface. The selected sketch can
now store typed sketch entities; the first supported entity is a deterministic
rectangle. It is intentionally not a freeform mesh/B-Rep editor and does not
generate geometry yet.

## Current sketch foundation

- `advanced_sketch` is stored as a normal `SemanticFeature`.
- `operation` is `helper`, and the geometry operation plan reports
  `helper.advanced_sketch`.
- The feature stores its target surface, display name, surface workplane
  placement, and typed sketch entities in metadata.
- `SketchEntity` currently supports the first `rectangle` entity with center,
  width, height, and corner-radius parameters.
- Selecting an advanced sketch shows a compact inspector section with contour
  count, a rectangle action, and rectangle parameter fields.
- A selected sketch with rectangle entities draws a helper-only viewport
  rectangle overlay on supported top-lid/front-wall mock workplanes.
- Clicking that rectangle overlay focuses the semantic rectangle entity in the
  inspector, while command context and viewport/native preview highlight remain
  scoped to the parent `advanced_sketch` feature. This is not mesh, B-Rep, or
  topology selection.
- Creation is undoable and save/load-safe.
- Rectangle entity creation is undoable and save/load-safe.
- Rectangle parameter edits are undoable and save/load-safe.
- Focused rectangle nudge/delete actions are undoable and save/load-safe.
- Supported sketch workplanes report a warning when a rectangle extends beyond
  the surface bounds.
- Rectangle corner radius is clamped to half of the smaller side.
- The default workflow remains generator-first; sketch creation is available
  only after Advanced Mode is enabled.

## Tools later

- Sketch.
- Extrude.
- Cut.
- Revolve.
- Sweep.
- Loft.
- Boolean.
- Fillet.
- Chamfer.
- Split body.
- Offset face/surface where safe.

## Rules

- Advanced geometry should not be required for core workflows.
- Converting semantic feature to advanced geometry must warn that generator behavior may be lost.
- Advanced operations must still be tracked in project model if possible.
- Maintain undo/redo.
- Maintain validation.
- Keep advanced UI separate from beginner tool rail.
- Do not make sketch entities drive geometry before validation, drawing/editing
  rules, undo behavior, and geometry boundaries are designed.
- Do not make sketch overlay hit testing depend on generated mesh triangles,
  B-Rep ids, or OCCT topology ids.
- Keep sketch entity focus semantic and parent-scoped until real drawing/edit
  handles are designed.

## Use cases

- Manual small fix.
- Custom bracket.
- Custom decorative cut.
- Edge-case connector.
- Custom accessory detail.
