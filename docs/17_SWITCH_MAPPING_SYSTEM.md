# 17 — Switch Mapping System

## Purpose

Use switch centers from internal component templates to generate external controls.

## Workflow

1. Place board/component.
2. App projects switch centers to surface/lid.
3. User sees center markers.
4. User chooses:
   - generate holes,
   - generate full buttons/plungers,
   - create button group/pattern,
   - use as snap anchors.

## Projection

Switch center has:
- source component,
- local position,
- direction,
- actuation height,
- target surface,
- projected point,
- normal direction.

## Tools

- Show switch centers.
- Hide switch centers.
- Generate holes.
- Generate plungers.
- Convert to button group.
- Align button pattern to switch centers.
- Adjust cap pattern independently while stems target switches.

## Current implementation slice

Selecting a component placement and running `Кнопки` creates one semantic
`button_group` from template switch centers. The switch centers are stored in
`FeatureGroup.pattern.switchPositions`, and the group remains editable as a
pattern rather than becoming independent holes or generated geometry.

## Validation

- Projection reaches target surface.
- Surface normal compatible.
- Board/switch height known.
- Stem target clear.
- Switch travel/clearance valid.
