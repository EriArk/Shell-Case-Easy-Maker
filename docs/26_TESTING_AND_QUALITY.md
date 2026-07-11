# 26 — Testing and Quality

## Testing philosophy

If it changes geometry, serialization, validation, or UI state, test it.

## Test categories

### Unit tests

- Project model serialization.
- Feature parameter validation.
- Project semantic validation warnings/errors.
- Component placement and keepout semantic validation.
- Rotation-aware placement bounds validation.
- Projected component anchor source and surface-bound validation.
- Component placement visibility serialization and mock viewport hit-test
  behavior.
- Mock local workplane and snap-hint layout behavior.
- Snap-point hit-test priority and snap-seeded component placement defaults.
- Pattern positions.
- Clearance profile calculations.
- Command system.
- Geometry request feature-intent serialization and group item expansion.
- Geometry operation-plan generation from feature intents.
- Undo/redo grouping.
- Input mapping.
- Step system.
- Theme selection.

### Geometry tests

For each generator:
- create known input,
- run geometry backend,
- assert dimensions,
- assert output validity,
- assert warnings/errors,
- export test if relevant.

Use deterministic test fixtures.

### Golden/snapshot tests

- Semantic JSON before/after migration.
- Generated pattern item positions.
- DXF layer contents.
- Validation outputs.

### UI tests

- Inspector changes with selection.
- Guided enclosure presets update the same semantic enclosure parameters as
  manual entry, and dialog validation blocks unusable size/wall/radius
  combinations before commit.
- Inspector visibility toggles update semantic state and viewport selection
  affordances.
- Surface/component selection wires local workplane overlays without saving UI
  state into the project.
- Clicked snap hints seed component placement dialogs without blocking visible
  semantic object selection.
- Active snap inspector actions open the same seeded placement flow and can
  clear transient snap state.
- Active snap footprint previews appear and clear with transient snap state.
- Snap placement fit feedback uses semantic validation and reports oversized
  previews before commit.
- Component placement dialogs validate current candidate values before commit.
- Component placement dialog viewport candidates appear while dialogs are open
  and clear on cancel/confirm.
- Guided component placement pick mode reuses semantic viewport snap targets,
  reopens the normal placement dialog from the clicked point, and does not save
  pending guide state.
- Component placement dialogs show selected template board dimensions.
- Component placement dialog quick presets update candidate coordinates and
  commit normal semantic placements.
- Component placement dialog rotation updates candidate fit feedback and
  committed inspector state.
- Workspace side panels collapse and expand without changing semantic project
  state or hiding the command rail.
- Viewport context popovers expose only valid semantic quick actions and start
  existing snap-seeded command dialogs without saving popover state.
- Command palettes filter available commands by semantic context and launch
  existing command handlers without saving palette/search state.
- Advanced Mode UI tests verify that low-level tools are hidden by default,
  appear only after enabling the transient switch, and remain disabled until
  implemented.
- Advanced sketch tests verify that `Эскиз` creates an undoable/saveable
  semantic `advanced_sketch` helper feature, that the inspector can start and
  cancel rectangle click placement, create the first typed rectangle entity from
  a workplane click, edit its rectangle parameters, show the helper-only
  rectangle overlay, click the overlay into semantic rectangle focus,
  nudge/move-to-click/resize/duplicate/delete the selected rectangle, apply
  keyboard nudge/resize edits and keyboard duplicate/delete/cancel commands,
  center/fit the rectangle to the sketch workplane, rotate the rectangle
  through semantic inspector actions, keep command scope on the parent sketch,
  show/remove workplane-bounds warnings, and keep the sketch as
  `helper.advanced_sketch` rather than generated geometry.
- Sketch entity adapter tests verify rectangle parameter defaults, semantic
  updates, numeric cleanup, stable entity replacement/removal, and
  corner-radius clamping plus semantic duplication and rotation-aware
  workplane-bounds warnings.
- Viewport controller tests verify that rotated sketch helper hit targets do
  not select the rectangle outside its rotated contour.
- Snap-seeded component placement can align semantic component anchors to the
  selected snap point without saving anchor UI state.
- Snap-seeded manual USB-C creation stores front-wall face-local
  `surfacePosition` metadata and keeps the viewport marker selectable at that
  saved point.
- Snap-seeded glass recess creation preserves surface placement through the
  dialog and keeps the viewport marker selectable at the saved point.
- Snap-seeded manual button groups store one group-level surface position,
  offset backend item intents from that center, and keep marker selection
  grouped.
- Native preview hides schematic feature/group overlays when the same semantic
  IDs already have generated OCCT preview ranges, while preserving mesh-range
  selection highlights.
- Native preview reduces active surface snap workplanes to a point-only marker
  so snap-seeded actions stay usable without a large schematic rectangle.
- Component-driven USB-C cutout generation preserves source placement/template
  data and projected surface anchors in saved project JSON.
- Component-driven button group generation preserves source switch centers in
  saved project JSON, stores projected switch positions, and keeps the result
  grouped.
- Projected USB-C/button anchors outside target surfaces report semantic
  validation errors; missing projection sources report warnings.
- Geometry preview requests include semantic feature/group intents without
  generated mesh, B-Rep, or topology IDs in the editable project model.
- Geometry operation plans map feature/group intents to deterministic backend
  tasks without flattening editable feature groups.
- Validation status/details show warning and error messages.
- Context popovers show correct actions.
- Parameter knob updates model.
- Keyboard-emulated controller commands change active parameter.
- Panels collapse/expand.

### Integration tests

- Component template → placed component → generated enclosure.
- Board with switches → generated button plungers.
- Screen window → glass recess → DXF export.
- Device → TPU case → propagated cutouts.
- Slot → cover → access cutout.

## CI expectations

- Format check.
- Static analysis.
- Unit tests.
- Worker tests if environment supports.
- Basic export tests.

## Geometry failure policy

Geometry operations may fail. The app must:
- return clear error,
- not crash UI,
- keep semantic model safe,
- allow user to adjust parameters.

## Performance checks

Test:
- many cutouts,
- vent grids,
- texture patches,
- large pattern groups,
- repeated knob edits,
- worker regeneration latency.

## Worklog

Every implemented feature must record:
- what was changed,
- tests run,
- known issues.
