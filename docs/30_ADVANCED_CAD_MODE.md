# 30 — Advanced CAD Mode

## Purpose

Provide escape hatches for professional users and edge cases without harming beginner UX.

## Default state

Advanced mode is hidden/collapsed.

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

## Use cases

- Manual small fix.
- Custom bracket.
- Custom decorative cut.
- Edge-case connector.
- Custom accessory detail.
