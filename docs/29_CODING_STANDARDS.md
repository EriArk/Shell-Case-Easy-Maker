# 29 — Coding Standards

## General

- Prefer clarity over cleverness.
- Keep modules small.
- Use explicit typed models.
- Write tests.
- Keep UI, model, geometry, and export concerns separate.

## Dart/Flutter

- Use immutable state where practical.
- Keep widgets thin.
- Put business rules in services/models, not widget build methods.
- Avoid hard-coded strings in core widgets.
- Avoid direct file/network/native calls in widgets.
- Use providers/controllers consistently.

## Native/OCCT

- Keep geometry functions deterministic.
- Wrap OCCT errors and return structured errors.
- Do not throw raw backend exceptions across protocol boundary.
- Keep geometry request/response schema stable.
- Add fixtures for generated bodies.

## JSON schemas

- Include version.
- Include units.
- Use stable IDs.
- Avoid storing generated geometry.
- Write migrations.

## Commands

Every command should declare:
- ID,
- label,
- icon,
- context availability,
- input bindings,
- undo behavior,
- parameter effects.

## Parameters

Every numeric parameter should declare:
- unit,
- default,
- min/max,
- normal/fine/coarse step,
- precision,
- validation.

## Dependencies

Before adding dependency:
- check license,
- check maintenance,
- check platform support,
- document why needed.

## Error handling

Errors should be visible and actionable:
- what failed,
- why likely failed,
- what user can change.

## Performance

- Debounce geometry regeneration during drags.
- Use low-quality preview during continuous edits.
- Generate high-quality geometry after edit commit.
- Keep UI responsive while worker runs.

## Accessibility basics

- Keyboard navigable.
- High contrast theme.
- Tooltips.
- Do not rely only on color for warnings.
