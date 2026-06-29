# 33 - Viewport MVP

## Purpose

The viewport MVP adds interaction state before real OCCT preview rendering.

It is still a mock preview, but orbit, pan, zoom, fit, semantic hit testing, and
ghost previews now live in a small viewport subsystem rather than inside the
project model or geometry backend.

## Architecture

`ViewportController` owns transient viewport state:
- yaw,
- pitch,
- zoom,
- pan offset,
- selected semantic ID,
- ghost preview.

This state is UI interaction state. It is not saved into `ProjectModel` and it
is not sent to `GeometryService`.

`MockViewportLayout` computes the current mock drawing rectangles and button
centers from `ViewportState`.

`MockViewportHitTester` uses the same layout to return semantic hit results:
- enclosure ID,
- surface ID with parent object ID,
- component placement ID,
- feature ID,
- feature group ID.

It does not return mesh IDs, triangle IDs, OCCT face IDs, or generated topology.

## Feature Markers

The mock viewport draws selectable markers for semantic features:
- `usb_c_cutout`,
- `glass_recess`.

The marker data is derived from semantic feature parameters such as width,
height, and corner radius. The markers are only viewport affordances; clicking
one selects the semantic feature ID.

## Feature Group Markers

The mock viewport can now draw semantic feature-group markers for:
- `button_group`,
- `standoff_mounts`.

Button-group markers are derived from the editable pattern data:
- layout,
- count,
- spacing,
- item diameter.

The local button positions come from `PatternLayoutEngine`, not from ad hoc
math inside the viewport painter. The viewport converts those local pattern
points into mock screen markers only.

Standoff markers are derived from component mounting data:
- source mounting-hole positions,
- source component board size,
- standoff diameter.

The local standoff positions come from `PatternLayoutEngine`, which resolves
saved semantic hole positions or falls back to component template mounting
holes. The viewport keeps only the mock screen-space conversion and hit zones.

The markers are a viewport affordance only. Clicking one marker selects the
whole feature group, not an individual mesh primitive or flattened hole.

## Current Controls

- Primary drag: orbit.
- Secondary or middle drag: pan.
- Mouse wheel: zoom.
- Click viewport mock objects: select semantic object.
- Click the view cube: fit view.

These controls are deliberately simple and can be refined after manual testing.

## Ghost Preview

Selecting a semantic surface creates a temporary ghost:
- front wall: USB-C placement ghost,
- top lid: button group placement ghost.

The ghost is a preview affordance only. It does not create or mutate a project
feature.

## Renderer Decision

M4 intentionally keeps `CustomPaint` for the mock viewer and does not add a 3D
package yet.

The real renderer decision should wait until the preview mesh protocol is
defined. At that point the app can compare renderer candidates against actual
requirements: mesh throughput, semantic face mapping, desktop stability,
license, and packaging complexity.

## Current Limitations

- The viewport is still a stylized 2.5D mock drawing, not generated geometry.
- Hit zones are deterministic mock zones, not mesh picking.
- Surface feature markers are schematic rectangles, not generated cut/recess
  B-Rep.
- Button-group marker expansion supports first-pass diamond, row, and grid
  layouts only.
- Standoff markers are schematic circles, not generated B-Rep bosses.
- View cube is a compact fit control, not a full orientation gizmo.
- Ghost previews are hard-coded for the sample semantic surfaces.
