# 21 — Grid, Snap, and Symmetry

## Grid

Each active face/workplane can have a grid:
- spacing,
- subdivisions,
- origin,
- rotation,
- visibility,
- snap strength.

## Snap targets

- Grid.
- Face centerlines.
- Edges.
- Corners.
- Feature centers.
- Component anchors.
- Switch centers.
- Mounting holes.
- Port centers.
- Slot edges.
- Keepout boundaries.
- Construction lines/curves.
- Symmetry axes.
- Other pattern items.
- Equal spacing guides.

## Snap modes

- Snap to grid.
- Snap to components.
- Snap to features.
- Snap to center.
- Snap to edge.
- Snap to equal spacing.
- Snap to tangent/path.
- Snap to projected switch centers.

## Visual hints

Snapping should show:
- target point,
- guide line,
- distance,
- centerline,
- equal spacing marker,
- projected anchor.

## Symmetry

Symmetry can be global or tool-local.

Symmetry sources:
- body center plane,
- face centerline,
- selected line,
- custom plane,
- another feature/group.

Modes:
- live mirrored creation,
- linked mirrored feature,
- independent mirrored copy,
- mirror pattern group,
- mirror component placement,
- mirror case/grip feature.

## Semantic storage

Symmetry should be stored as semantic relation, not flattened copy, unless user detaches.

## UI

- Symmetry toggle.
- Axis/plane visible in viewport.
- Quick popover for symmetry options.
- Warnings when target is impossible.
