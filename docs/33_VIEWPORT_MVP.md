# 33 - Viewport MVP

## Purpose

The viewport MVP adds interaction state and the first generated preview mesh
rendering path without making generated geometry editable project state.

Orbit, pan, zoom, fit, semantic hit testing, and ghost previews live in a small
viewport subsystem rather than inside the project model or geometry backend.
When `GeometryService` provides a disposable `PreviewMesh`, the shell can draw
that faceted body preview. Selection and editing still use semantic IDs.

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
- feature group ID,
- snap point hit data for the active local workplane.

It does not return mesh IDs, triangle IDs, OCCT face IDs, or generated topology.

`GeometryPreview.previewMesh` is an optional display-only mesh. The viewport
painter projects its vertices with the current `ViewportState`, draws sorted
triangles as a faceted body layer, derives boundary edges from triangle
connectivity to avoid drawing every internal triangulation diagonal, and keeps
component, feature, workplane, snap, ghost, and selection overlays above it.
When a mesh is present, those semantic overlays switch into an annotation style:
lower opacity, lighter strokes, and no duplicate heavy mock selection outline
when the selected semantic id already has mapped preview ranges.
Project/workspace selection keeps component, feature, and feature-group
annotations muted so the native body stays the primary visual layer; selecting a
feature, feature group, or component placement focuses the relevant annotation
again for inspection. The mesh is never hit-tested as the editable source of
truth. Native preview meshes may include disposable semantic surface ranges.
When the current selection is a matching semantic surface, feature, or feature
group, the viewport can tint those mapped preview triangles and draw only the
selected range boundary plus a screen-space halo as a display-only highlight.
First-pass native mesh picking uses those same disposable triangle ranges only
inside the viewport event handler: a click is projected against the current
preview mesh, the hit range is translated immediately back to a semantic id, and
selection stores only that semantic id. Triangle IDs remain preview
implementation details and are not written into `ProjectModel`.

Component placement hit zones are now supplied as
`MockViewportComponentPlacementPreview` values derived from semantic
`ComponentPlacement` objects and their `ComponentTemplate` board outlines. The
mock viewer omits placements whose semantic `visible` flag is false, while the
project browser and inspector can still select and restore those placements.

`MockViewportWorkplaneOverlay` describes the currently active local workplane
for the mock viewer. It is derived from the current semantic selection and is
not saved into `ProjectModel`. The first overlays support:
- top-lid surfaces,
- front-wall surfaces,
- visible component placements.

The overlay draws a subtle local grid plus snap hints. Surface snap hints use
deterministic center/quarter points. Component placement snap hints use the
selected component template's mounting holes plus the board center. Snap hints
can be clicked; the hit result carries the workplane kind, snap index, and
local point so shell commands can seed semantic actions. Snap hints are
transient interaction affordances only; they do not create sketch constraints,
change placement data by themselves, or expose generated topology.

When a native preview mesh is visible, selected surface workplanes are hidden
during passive inspection. Component-placement workplanes and active snap
targets remain focused so placement actions are still easy to inspect. This
keeps surface selection useful without letting a large rectangular 2D workplane
dominate the generated mesh.

Hit-test priority keeps visible semantic objects above overlapping snap hints,
then places snap hints above bare surface selection. This lets a visible board
remain selectable even when a surface workplane has a center snap point.

When a snap hint is active and the project has a component template, the mock
viewport also draws a translucent component footprint at the snap-seeded
position. This footprint is preview-only: it is not included in hit testing and
does not become a saved `ComponentPlacement` unless the user confirms the
placement dialog. The footprint is tinted by the semantic fit status from a
temporary what-if placement.

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
- Click a visible snap hint: select/highlight that transient snap target.
- Click inside a selected top-lid/front-wall workplane: select a transient
  face-local target for surface commands.
- Use the inspector snap action: open the snap-seeded component placement dialog.
- Use the inspector hole action: open the circular cutout dialog seeded from
  the clicked surface point.
- Active snap target: show a transient component footprint preview.
- Open placement dialog: show a transient candidate footprint until cancel or
  confirm.
- Click TOP, FRT, RGT, LFT, or ISO in the viewport navigation controls: switch
  to that standard view and recenter the model.
- Click the fit icon in the viewport navigation controls: fit view.
- Select a supported surface or visible component placement: show the local
  workplane overlay and snap hints.
- Select a supported surface with mapped preview ranges: show a generated mesh
  surface highlight.
- In native preview mode, unselected schematic annotations stay muted; selecting
  a feature, feature group, or component placement brings that semantic helper
  forward.
- Click a mapped native preview mesh range: select the semantic part behind
  that range, then show the generated mesh highlight.
- Native preview mesh rendering hides shared internal triangle edges and keeps
  only boundary/selection contours visible.
- Selected surface workplanes are hidden in native preview mode; component
  placement workplanes and active snap targets remain focused.

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

The first native preview mesh slice is still rendered through `CustomPaint`.
This is acceptable for the current deterministic rounded-enclosure sample
(`800` vertices / `1060` triangles) and keeps packaging simple. A later renderer
decision can compare candidates against larger mesh throughput, semantic face
mapping, desktop stability, license, and packaging complexity.

## Current Limitations

- The viewport can draw a generated preview mesh body and selected mapped
  surface highlights when a backend provides them. Other semantic overlays are
  still first-pass schematic affordances, now muted by default in native preview
  mode and focused only when their semantic item is selected. Rendering hides
  internal mesh diagonals, but the `CustomPaint` preview still uses simple
  per-triangle shading rather than a final material/normal pipeline.
- Native preview mesh picking is first-pass semantic picking from mapped
  preview ranges. It is not raw triangle editing, and it falls back to mock hit
  zones when no mapped mesh range is hit.
- Component placement previews are semantic mock rectangles, not generated
  board meshes or OCCT bodies.
- Workplane overlays and snap hints are mock interaction affordances. Surface
  workplane clicks can seed component placement and circular cutout dialogs, but
  they are not a saved sketch/workplane subsystem yet. In native preview mode,
  passive surface workplanes are hidden because they are not projected onto real
  generated faces.
- Snap placement footprints are schematic rectangles derived from component
  template board outlines, not generated board meshes or collision-aware
  previews. Current feedback checks the same coarse semantic placement bounds as
  committed components.
- Dialog candidate footprints are also transient and are not included in
  viewport hit-testing.
- Surface feature markers are schematic rectangles, not generated cut/recess
  B-Rep.
- Button-group marker expansion supports first-pass diamond, row, and grid
  layouts only.
- Standoff markers are schematic circles, not generated B-Rep bosses.
- View cube is a compact fit control, not a full orientation gizmo.
- Ghost previews are hard-coded for the sample semantic surfaces.
