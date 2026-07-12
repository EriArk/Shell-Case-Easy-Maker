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
now store typed sketch entities; the first supported entities are deterministic
rectangles and circles. It is intentionally not a freeform mesh/B-Rep editor
and does not store generated geometry as editable project state. Supported
`cut` circles and rectangles, including rotated rectangles, can generate
disposable native preview cutouts.

## Current sketch foundation

- `advanced_sketch` is stored as a normal `SemanticFeature`.
- `operation` is `helper`, and the geometry operation plan reports
  `helper.advanced_sketch`.
- Non-reference sketch entities can additionally appear in the request-scoped
  operation plan as `sketch.profile.cut` or `sketch.profile.add`, with
  deterministic semantic shape parameters. The native OCCT preview consumes
  `cut` circles and rectangles, including rotated rectangles, on supported
  workplanes as disposable generated B-Rep cut tools. `add` and richer sketch
  extrusion behavior remain future work.
- The feature stores its target surface, display name, surface workplane
  placement, and typed sketch entities in metadata.
- `SketchEntity` currently supports `rectangle` with center, width, height,
  corner-radius, and rotation parameters, plus `circle` with center and
  diameter parameters.
- Every sketch entity can carry a semantic `profileIntent`: `reference`,
  `cut`, or `add`. The intent is stored as entity metadata;
  `advanced_sketch.operation` remains `helper`.
- Selecting an advanced sketch shows a compact inspector section with contour
  count, rectangle/circle actions, and schema-backed entity parameter fields.
- The rectangle/circle actions start a click-to-place mode. The next click on
  the supported sketch workplane creates the entity at that semantic local
  position and focuses it.
- A selected sketch with rectangle or circle entities draws helper-only
  viewport overlays on supported top-lid/front-wall mock workplanes.
- Clicking a helper overlay focuses the semantic sketch entity in the
  inspector, while command context and viewport/native preview highlight remain
  scoped to the parent `advanced_sketch` feature. This is not mesh, B-Rep, or
  topology selection.
- Creation is undoable and save/load-safe.
- Rectangle/circle entity click placement is undoable and save/load-safe.
- Rectangle/circle parameter edits are undoable and save/load-safe.
- Profile intent edits are undoable and save/load-safe.
- Focused sketch entity nudge/move-to-click/resize/duplicate/delete actions
  are undoable and save/load-safe.
- Focused rectangle workplane quick actions can center the contour or fit it to
  the supported sketch workplane bounds while staying semantic.
- Focused rectangle rotation is a semantic parameter edit. The helper overlay,
  click target, and workplane-bounds warning account for the stored angle.
- Focused rectangle shape quick actions can increase/reset corner radius and
  reset rotation through the same schema-backed semantic parameter path.
- Focused rectangle keyboard edits reuse those semantic paths: arrows nudge by
  1 mm and Shift+arrows resize by 1 mm when a text field is not focused.
- Focused rectangle keyboard commands also stay semantic: Ctrl+D duplicates,
  Delete/Backspace removes, and Escape cancels active placement/move mode.
- Supported sketch workplanes report a warning when a contour extends beyond
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
- Do not make sketch entities drive geometry outside the validated
  circle/rectangle cut slice until drawing/editing rules, undo behavior, and
  geometry boundaries are designed.
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
