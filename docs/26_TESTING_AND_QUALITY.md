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
- Pattern positions.
- Clearance profile calculations.
- Command system.
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
