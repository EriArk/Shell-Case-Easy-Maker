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
If a native OCCT preview range already exists for a semantic feature or feature
group, the viewport hides that object's schematic 2D marker instead of drawing
a duplicate shape on top of the generated geometry. Objects without a native
range still use schematic markers as fallback selection affordances.
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
during passive inspection. Active top-lid/front-wall snap targets draw only a
compact point/crosshair instead of the whole rectangular workplane. Component
placement workplanes remain focused because the board rectangle is still useful
for placement. This keeps surface selection useful without letting a large 2D
workplane dominate the generated mesh.

Hit-test priority keeps visible semantic objects above overlapping snap hints,
then places snap hints above bare surface selection. This lets a visible board
remain selectable even when a surface workplane has a center snap point.

When a snap hint is active and the project has a component template, the mock
viewport also draws a translucent component footprint at the snap-seeded
position. This footprint is preview-only: it is not included in hit testing and
does not become a saved `ComponentPlacement` unless the user confirms the
placement dialog. The footprint is tinted by the semantic fit status from a
temporary what-if placement.

Component placement can also enter a guided viewport-pick mode from the
placement dialog. The viewport shows a compact transient banner while waiting
for a snap point. Clicking a semantic snap point immediately converts the hit
back into the existing active snap target data and reopens the normal placement
dialog. The guide mode is shell interaction state only; it does not persist to
project JSON and does not introduce generated topology IDs into selection.

## Feature Markers

The mock viewport draws selectable markers for semantic features:
- `usb_c_cutout`,
- `glass_recess`,
- `circular_cutout`,
- `rectangular_cutout`.

The marker data is derived from semantic feature parameters such as width,
height, diameter, face-local X/Y, saved USB-C/glass `surfacePosition`, and
corner radius. The markers are only viewport affordances; clicking one selects
the semantic feature ID.

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
Manual button groups with saved `placement.surfacePosition` offset the whole
pattern around that semantic surface point.

## Sketch Helper Overlays

When an `advanced_sketch` helper feature is selected, the viewport can draw its
rectangle and circle `SketchEntity` values as helper-only overlays on
supported mock surface workplanes:
- top lid,
- front wall.

The overlay reuses the same semantic local-to-canvas mapping as surface
workplanes, but it does not bring back the full passive 2D workplane rectangle.
Only the helper contour and center marker are drawn. This keeps the selected
sketch inspectable while avoiding the old large surface ghost over the native
preview.

Sketch helper overlays are display-only. They do not create preview mesh,
B-Rep, cuts, extrusions, topology ids, or generated-geometry sub-entities. The
visible contour can be clicked as a semantic sketch-entity focus target: the UI
selection can point at `rect_1` or `circle_1`, while command context and
viewport/native preview highlighting stay scoped to the owning
`advanced_sketch` feature id. Entity editing currently happens through the
selected sketch inspector, including schema-backed fields, 1 mm nudge actions,
type-specific size actions, move-to-click center placement, duplication,
profile-intent selection, deletion, keyboard nudge/resize shortcuts, keyboard
command shortcuts, workplane center/fit actions, and semantic workplane-bounds
warnings. Rectangle helpers also support corner-radius and rotation actions.
The helper contour can be tinted by profile intent (`reference`, `cut`, `add`)
without changing hit testing or creating geometry. The helper contour, its hit
target, and bounds check still resolve back only to semantic sketch ids.

The selected sketch inspector can also start transient rectangle or circle
click-to-place modes. While active, the viewport uses the owning sketch surface
workplane as the hit target, shows a compact cancel banner, and converts the
next workplane click into a semantic local contour center. This interaction
does not read generated mesh triangles or OCCT topology ids.

Focused sketch entities can reuse the same viewport pick path for
move-to-click: the next supported workplane click replaces the selected
entity's semantic center and commits an undoable project edit.

Focused sketch entities can also be moved by direct primary-button drag when
the drag starts on that same selected helper contour. The viewport converts the
release point back into the owning sketch workplane's local coordinates and
commits only the semantic center update. Drags that do not start on the focused
contour keep the normal orbit/pan behavior.

## Current Controls

- Primary drag: orbit.
- Secondary or middle drag: pan.
- Mouse wheel: zoom.
- Click viewport mock objects: select semantic object.
- Click inside a selected sketch helper contour: focus the semantic sketch
  entity while keeping parent-sketch command scope.
- Drag the focused sketch helper contour: move its semantic center on the
  sketch workplane with undo support.
- Use the selected sketch rectangle/circle action, then click the supported
  workplane: create a semantic entity at the clicked local position.
- Use selected rectangle inspector arrows: nudge the helper rectangle by 1 mm.
- Use selected circle inspector arrows: nudge the helper circle by 1 mm.
- Use keyboard arrows while a rectangle is selected: nudge the helper rectangle
  by 1 mm.
- Use Shift+keyboard arrows while a rectangle is selected: resize width or
  height by 1 mm.
- Use Ctrl+D while a rectangle is selected: duplicate the semantic rectangle.
- Use Delete or Backspace while a rectangle is selected: remove the semantic
  rectangle.
- Use Escape during rectangle placement or move-to-click: cancel the active
  viewport pick mode.
- Use selected rectangle move-to-click: move the helper rectangle center to the
  next supported workplane click.
- Use selected rectangle inspector resize buttons: change width or height by
  1 mm.
- Use selected circle diameter buttons or the `Диаметр` field: change the
  circle diameter semantically.
- Use selected sketch entity intent buttons: mark the contour as reference,
  cut, or add; native preview can render supported cut/add contours as
  generated geometry while the editable sketch stays semantic.
- Use selected rectangle radius buttons: round corners by 1 mm or reset back
  to square corners.
- Use selected rectangle rotation buttons or the `Поворот` field: rotate the
  helper contour as a semantic angle edit.
- Use selected rectangle rotation reset: return the helper angle to 0 degrees.
- Use selected rectangle workplane actions: center the helper contour on its
  sketch workplane or fit it to that workplane's bounds.
- Use selected sketch entity duplicate: create a new offset semantic contour
  and focus it.
- Use selected sketch entity inspector delete: remove the semantic entity.
- Click a visible snap hint: select/highlight that transient snap target.
- Click inside a selected top-lid/front-wall workplane: select a transient
  face-local target for surface commands.
- Use the inspector snap action: open the snap-seeded component placement dialog.
- Use `Выбрать точку` in the placement dialog: enter transient component
  placement pick mode, then click a snap hint to reopen the placement dialog
  from that point.
- Use the inspector hole action: open the circular cutout dialog seeded from
  the clicked surface point.
- Use the inspector USB-C action on a front-wall snap target: open the USB-C
  dialog seeded from the clicked surface point.
- Use the inspector glass or button actions on a surface snap target: open the
  normal semantic dialogs and save the clicked point as feature/group placement.
- Select an Advanced Sketch with a rectangle entity: show the helper-only
  rectangle overlay.
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
- In native preview mode, mapped feature/group schematic markers are hidden so
  the generated mesh range is the primary visual representation.
- Click a mapped native preview mesh range: select the semantic part behind
  that range, then show the generated mesh highlight.
- Click a mapped native Advanced Sketch contour range such as
  `advanced_sketch_1.circle_1`: focus that semantic `SketchEntity` in the
  inspector and highlight the generated child range. This uses stable semantic
  ids from the worker mapping, not raw triangle or OCCT topology ids.
- Native preview mesh rendering hides shared internal triangle edges and keeps
  only boundary/selection contours visible.
- Selected surface workplanes are hidden in native preview mode; active surface
  snap targets use a compact point-only marker, while component placement
  workplanes remain focused.

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
  surface highlights when a backend provides them. Mapped feature/group
  schematic markers are hidden in native mode to avoid duplicate 2D ghosts.
  Unmapped semantic overlays are still first-pass schematic affordances, now
  muted by default in native preview mode and focused only when their semantic
  item is selected. Rendering hides internal mesh diagonals, but the
  `CustomPaint` preview still uses simple per-triangle shading rather than a
  final material/normal pipeline.
- Native preview mesh picking is first-pass semantic picking from mapped
  preview ranges. It is not raw triangle editing, and it falls back to mock hit
  zones when no mapped mesh range is hit.
- Component placement previews are semantic mock rectangles, not generated
  board meshes or OCCT bodies.
- Workplane overlays and snap hints are mock interaction affordances. Surface
  workplane clicks can seed component placement and hole/cutout dialogs, but
  they are not a saved sketch/workplane subsystem yet. In native preview mode,
  passive surface workplanes are hidden and active surface snap targets are
  reduced to a point marker because they are not projected onto real generated
  faces.
- Snap placement footprints are schematic rectangles derived from component
  template board outlines, not generated board meshes or collision-aware
  previews. Current feedback checks the same coarse semantic placement bounds as
  committed components.
- Dialog candidate footprints are also transient and are not included in
  viewport hit-testing.
- Surface feature markers are schematic circles/rounded rectangles, not
  generated cut/recess B-Rep.
- Button-group marker expansion supports first-pass diamond, row, and grid
  layouts only.
- Standoff markers are schematic circles, not generated B-Rep bosses.
- View cube is a compact fit control, not a full orientation gizmo.
- Ghost previews are hard-coded for the sample semantic surfaces.
