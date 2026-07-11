# 32 - Usable Shell

## Purpose

The usable shell connects the semantic project model to compact UI context.

The shell can now display a backend-provided disposable preview mesh, but
selection, inspector text, command availability, and project browsing are still
driven by semantic IDs rather than widget-only state or generated mesh data.

## Selection model

`SelectionModel` stores the current semantic focus:
- workspace,
- enclosure,
- surface,
- component placement,
- component template,
- feature,
- feature group.

Surface selection stores both the surface ID and parent semantic object ID.
This keeps commands such as "add USB-C" tied to semantic surfaces without using
OCCT topology, mesh triangles, or viewport-only IDs.

## Selection details

`ProjectSelectionResolver` turns a selection into inspector/status data:
- title,
- subtitle,
- status hint,
- properties.

Widgets render these details but do not own the business rules for describing
project objects.

## Parameter inspector

When the main enclosure is selected, the inspector renders the first rounded
enclosure parameter bank:
- width,
- depth,
- height,
- wall thickness,
- corner radius,
- lid type.

These controls update the semantic `ProjectModel` through
`EnclosureParameterAdapter`. The viewport and geometry protocol then refresh
from the updated project. The editable source remains semantic enclosure data,
not generated mesh or preview triangles.

Effective parameter edits are committed to `UndoHistory<ProjectModel>`. The top
toolbar enables undo/redo when semantic snapshots are available, then refreshes
the inspector and mock preview after restoring a snapshot.

When a supported semantic feature is selected, the inspector also renders a
feature-specific numeric parameter bank. The first supported feature editors
are `usb_c_cutout`, `glass_recess`, `circular_cutout`, and
`rectangular_cutout`. Submitting a value replaces the selected `SemanticFeature`
in the semantic project model and commits the edit through the same undo
history. The mock viewport marker is refreshed from semantic parameters; no
generated mesh, B-Rep, or topology ID becomes editable state.
Slot presets are still `rectangular_cutout` features, but the inspector shows a
`Слот` parameter bank without a manual radius field and recomputes the radius
from the current length/width.

When a supported semantic feature group is selected, the inspector renders a
group-specific parameter bank. The first supported group editors are
`button_group` and `standoff_mounts`. Button group edits update
`FeatureGroup.pattern` and `FeatureGroup.itemPrototype`; mount edits update the
standoff item prototype while preserving source mounting-hole pattern data.
Repeated items stay grouped and undoable as one semantic object.

When a component placement is selected, the inspector renders a compact
placement editor for X/Y/Z position, Z rotation, mounting side, locked state,
and viewport visibility. Edits replace the selected semantic
`ComponentPlacement`, refresh preview/validation, and commit through the same
undo history. This lets placement validation issues be corrected directly after
selecting an issue row. When a placement is locked, position/rotation/side
controls are disabled and the lock checkbox remains available so it can be
unlocked. The visibility checkbox remains available too; hiding a placement
removes only its mock viewport placement marker/hit target, not the semantic
project object.

## Project browser

The shell includes a compact semantic browser next to the icon rail.

It lists:
- project root,
- enclosures,
- selectable mock surfaces,
- component placements,
- component templates,
- semantic features,
- feature groups.

Selecting an item updates the inspector, status hint, viewport label, and mock
highlight.

Hidden component placements stay visible in the browser with a muted visibility
icon so they can be selected and shown again from the inspector.

The project browser and contextual inspector can now collapse into narrow
icon-only side strips. This gives the viewport more room during manual model
inspection without changing selection, commands, undo/redo, saved project JSON,
or geometry requests. The left command rail stays visible while either side
panel is collapsed.

## Local Workplane Overlay

The mock viewport now shows a transient local workplane overlay for selected
top-lid/front-wall surfaces and visible component placements. The overlay is a
subtle grid with snap hints. For surfaces, hints are deterministic center and
quarter points. For component placements, hints come from the selected
component template mounting holes plus the board center.

This is not saved project data and not an advanced sketch plane. It is a mock
interaction affordance that prepares the UI for later viewport picking and
snapping while keeping the editable project semantic.

Snap hints are now selectable, and selected top-lid/front-wall workplanes also
accept clicks inside the workplane area as face-local points. Clicking one
stores a transient active snap target in shell state, highlights the dot or
picked point, and updates the status hint. Starting `Компоненты` from that state
opens the placement dialog with a snap label and seeded X/Y/Z plus mounting
side. Starting `Отверстия` from a surface snap target opens the circular cutout
dialog with the picked face-local X/Y. Starting `Порты` from a supported
front-wall snap target opens the USB-C dialog and stores that face-local point
as semantic placement metadata. Starting `Стекло` or manual `Кнопки` from a
surface snap target stores the same semantic surface placement on the generated
feature/group. Normal selection, undo, redo, and project edits clear the
transient snap target so stale UI state is not saved or replayed.

When an active snap target exists, the inspector shows a compact `Точка
привязки` section with the snap label, seeded project position, mounting side,
a direct `Разместить компонент` action, a direct `Отверстие` action for surface
targets, a direct `USB-C` action for supported front-wall snap targets, and a
direct `Стекло` and `Кнопки` action for surface snap targets, and a clear
action. These actions still open the normal semantic dialogs; confirming them
creates regular semantic project objects, not saved snap references.

The viewport mirrors the same transient state with a translucent component
footprint preview. It uses the first component template's board outline and the
snap-seeded project position, but it is not selectable and is not saved.

The snap inspector also runs the prospective placement through semantic
validation and shows whether the component fits the current enclosure. Only
messages targeted at the prospective placement are shown, so unrelated project
warnings do not confuse the snap preview.

## Project JSON file service

`ProjectFileService` provides basic JSON encode/decode and disk read/write.

`ProjectFileDialogService` provides native open/save file selection through
`file_selector`.

The top toolbar now wires project open/save/export commands:
- open loads `.enclosure.json` into semantic shell state,
- save writes the current semantic project,
- export opens a STEP/STL format chooser, then asks `GeometryService` to
  generate the selected disposable artifact,
- open resets undo/redo history for the loaded file,
- open asks before discarding unsaved semantic edits,
- the status bar reports unsaved changes when the project differs from the
  persisted baseline,
- generated preview data is refreshed after loading,
- exported geometry paths are not stored in project JSON.

## Validation Status

The bottom status bar consumes `GeometryService.validateGeometry(project)`.
The mock backend currently runs first-pass semantic validation before real
geometry exists. Blocking errors are shown as errors; non-blocking semantic
warnings, such as very thin enclosure walls, are shown as warning status with
the first warning message.

When the report contains warnings or errors, the status bar shows a compact
details button. It opens a bottom sheet with issue counts and every current
warning/error message. This keeps the default shell uncluttered while still
making multi-issue validation inspectable before real geometry generation.
Issue rows with semantic targets can be clicked to close the sheet and select
the affected enclosure, surface, component, template, feature, or feature
group. Nested targets such as component keepouts resolve to their semantic
parent instead of preview geometry.

The validator also checks component-sourced projected anchors. Normal generated
USB-C and button anchors should stay clean; anchors outside the usable surface
become blocking validation errors, while missing source component/template data
becomes a warning.

## First Generator Command

The left tool rail now executes the first semantic generator commands:
`enclosure.create`, `component.place`, `port.add_usb_c`, and
`button.create_group`, `glass.create_recess`, `slot.generate`, and
`mount.generate`.

Clicking `Корпус` opens a compact create-enclosure dialog using the same rounded
enclosure parameter schema as the inspector. Confirming the dialog updates the
semantic `ProjectModel`, selects the enclosure, refreshes the mock preview, and
creates one undo history entry.

The create-enclosure dialog now includes guided presets for common first bodies
(`Плата`, `Ручной`, and `Бокс`). Presets only fill the existing semantic
rounded-enclosure parameters: width, depth, height, wall thickness, corner
radius, and lid type. The dialog also shows the current internal usable size and
blocks obviously unusable combinations, such as walls that leave too little
internal space or a corner radius that cannot fit the selected width/depth.
Thin/thick wall and tight screw-lid warnings stay dialog-only guidance; they
are not saved as project state.

Clicking `Компоненты` opens a compact placement dialog when the project has at
least one `ComponentTemplate`. The command is available from workspace,
enclosure, surface, and component contexts. If a snap hint was clicked first,
the dialog shows that snap label and starts from the snap target's coordinates.
The selected component template's board width, height, and thickness are shown
under the template selector. Quick position icons can move the dialog candidate
to the center or near a side of the current enclosure inner space. These
controls only update transient candidate state until placement is confirmed.
The dialog also edits `Поворот Z` with 90 degree rotate icons, so rotation-aware
fit feedback is visible before the semantic placement is committed.
When placement starts from an active snap target, the dialog also offers
`Якорь к точке` choices derived from the selected component template: board
center, mounting holes, and feature centers such as USB-C or switches. Choosing
one recalculates the candidate center so that anchor lands on the snap point.
The selected anchor itself remains transient UI state; only the resulting
semantic placement position and rotation are committed.
The dialog validates its current candidate placement as X/Y/Z/template values
change and shows whether it fits before commit.
While the dialog is open, the shell also keeps a transient candidate footprint
in the viewport. Canceling clears that footprint; confirming replaces it with a
normal semantic placement marker.
The dialog can also switch into a guided viewport-pick mode with
`Выбрать точку`. In that mode the viewport shows a compact placement banner;
selecting a surface and clicking a snap point reopens the same placement dialog
with the clicked point as the active snap target. The guide banner and pending
pick are transient shell state only. They are not saved, sent to the geometry
service, or committed to undo history.
Confirming the dialog appends a semantic `ComponentPlacement`, selects it,
refreshes the mock preview, and creates one undo history entry. If undo removes
the selected placement, selection falls back to the workspace so the inspector
does not point at a stale ID.

Clicking `Порты` is enabled only after selecting a semantic surface such as
`Front wall`. The command opens a compact USB-C dialog, appends a semantic
`usb_c_cutout` feature targeted at the selected surface, selects the new
feature, refreshes the mock preview, and creates one undo history entry. The
mock viewport draws a schematic USB-C marker; clicking it selects the semantic
feature.

If a front-wall snap target is active when `Порты` starts, the new manual
`usb_c_cutout` stores `placement.projectionMode=surface_snap_target`,
`placement.surfacePosition`, and `surfaceAxes=["x","z"]`. The mock marker uses
that saved face-local position, while features without saved placement keep the
older slot-style marker fallback.

Front-wall snap targets convert the workplane-local vertical coordinate into
absolute surface Z before saving `surfacePosition`. This keeps generated
front-wall geometry aligned with the native worker's `x,z` surface coordinates.

`Порты` is also available when a selected component placement's template has a
USB-C feature with `cutout` metadata. In that context the same USB-C dialog is
pre-filled from the component template, targets the first semantic enclosure
surface implied by the connector direction, and preserves source placement,
template, component feature IDs, and projected `surfacePosition` metadata on
the generated `usb_c_cutout`. The editable result is still a normal semantic
feature, not generated geometry.

Clicking `Отверстия` is enabled after selecting a semantic surface. It opens a
compact cutout dialog with `Круглое`, `Прямоугольное`, and `Слот` shape options.
The circular option appends a semantic `circular_cutout` feature with editable
diameter, depth, and face-local X/Y parameters. The rectangular option appends a
semantic `rectangular_cutout` feature with editable width, height, depth, corner
radius, and face-local X/Y parameters. The slot option stores the same semantic
`rectangular_cutout` type with `parameters.preset=slot` and derives the corner
radius as half of the smaller side. Later inspector edits keep that radius
derived, so it stays editable without introducing a new B-Rep/mesh source. If a
surface workplane point was clicked first, the dialog starts from that X/Y. The
mock viewport draws circular or
rounded-rectangular markers and hit-tests them by semantic feature ID. Native
OCCT consumes supported front-wall and top-lid circular and rectangular/slot
cutouts as generated subtraction geometry while keeping the editable source
semantic.

Clicking `Кнопки` is enabled only after selecting a semantic surface such as
`Top lid`. The command opens a compact button group dialog and appends a
semantic `FeatureGroup` with editable layout/count/diameter/spacing data. The
group remains one semantic object rather than becoming several unrelated
button holes. The mock viewport derives schematic markers from that pattern;
clicking one marker selects the whole button group.

If a surface snap target is active when manual `Кнопки` starts, the created
group stores `placement.projectionMode=surface_snap_target`,
`placement.surfacePosition`, and `surfaceAxes`. The button layout remains
editable as one pattern, and mock/backend item positions are offset from the
saved group center instead of flattening the buttons.

`Кнопки` is also available when a selected component placement's template has
switch features. In that context the dialog starts from
`from_component_switches`, stores the switch centers in
`button_group.pattern.switchPositions`, and records source placement/template
IDs. The saved switch positions are projected to the target surface, while each
entry also keeps the original template-local switch center. The result is still
one editable `FeatureGroup`; switching the layout away from
`from_component_switches` makes the group behave like a normal manual pattern.
For supported top-lid targets, native OCCT consumes those saved switch centers
through the regular generated button path, producing disposable holes/rings and
plunger preview geometry while keeping the group semantic.

Clicking `Стекло` is enabled only after selecting a semantic surface. The
command opens a compact glass recess dialog and appends a semantic
`glass_recess` feature with window size, recess depth, ledge width, radius,
insert thickness, and clearance profile data. The mock viewport draws a
schematic recess marker; clicking it selects the semantic feature.

If a surface snap target is active when `Стекло` starts, the feature stores
`placement.projectionMode=surface_snap_target`, `placement.surfacePosition`, and
`surfaceAxes`. The glass dialog preserves that placement when confirmed, and the
mock marker is drawn at the saved point.

Clicking `Крепёж` is enabled only after selecting a component placement whose
template has mounting holes. The command opens a compact mount dialog and
appends a semantic `standoff_mounts` `FeatureGroup` sourced from the template
hole positions. The generated mounts stay editable as one group with standoff
diameter, hole diameter, height, clearance profile, and source placement data.
The mock viewport draws schematic markers for this group; clicking a marker
selects the whole `FeatureGroup` and shows its inspector details.

Right-clicking in the viewport now opens a compact context popover for the
semantic target under the cursor. The shell first resolves the same semantic
hit used by normal selection, then filters quick actions through the existing
command registry and command handlers. Surface snap points can start the same
snap-seeded generators as the inspector shortcuts; for example `Отверстия`
opens the existing cutout dialog with the clicked face-local X/Y values. The
popover is transient UI state only and does not affect saved project JSON,
undo/redo, or geometry requests.

The top toolbar also exposes a compact command palette. It can be opened from
the toolbar or with `Ctrl+K`, filters entries through the same
`CommandRegistry` metadata and shell handlers, and launches the existing
command paths. Workspace context stays limited to workspace actions, while a
selected semantic surface exposes surface generators such as `Отверстия`.
Palette query/focus state is transient UI state only and is not stored in
`ProjectModel`, undo/redo history, project JSON, or geometry requests.

Future rail tools remain visible to show the intended workflow, but they are
disabled until their semantic command behavior is implemented and tested.

Advanced low-level tools are not part of the default rail. The shell has a
transient Advanced Mode toggle at the lower rail edge; when enabled, it reveals
a separate advanced section with `Эскиз`. The command opens a compact dialog
for a target surface and sketch name, then creates an undoable
`advanced_sketch` helper feature. Selecting that sketch shows a compact
inspector section with contour count and a rectangle icon; clicking it stores
a transient click-to-place intent rather than immediately creating geometry.
The next click on the supported sketch workplane stores a typed rectangle
entity at that semantic local position. Rectangle entities expose compact X/Y,
width, height, and radius fields in the same inspector section. When the
selected sketch has a rectangle, the viewport draws a thin helper rectangle
overlay without restoring the old full-surface workplane rectangle. Clicking
inside that helper rectangle focuses the semantic rectangle entity in the
inspector while keeping command scope and viewport/native preview highlighting
on the parent sketch. The focused row has icon-only 1 mm nudge controls and a
delete action, plus width/height +/- 1 mm resize controls; these update
semantic sketch metadata through undo history. If the rectangle leaves the
supported sketch workplane bounds, the inspector shows a semantic warning.
These actions and warnings do not select generated mesh or topology. The switch
itself does not change saved project JSON, undo/redo history, or geometry
requests, and sketch entities do not generate geometry yet.

## Current limitations

- Only the first enclosure parameter bank, first USB-C/glass feature parameter
  banks, first button/mount feature-group parameter banks, first
  create-enclosure command, first component placement command, first USB-C
  cutout command, and first button group/glass recess/mount commands edit
  project state.
- Viewport selection is still mocked and schematic, though direct hit testing
  already returns semantic IDs and local workplane overlays are available for
  supported selections.
- Component placement supports first-pass snap-seeded dialog defaults, but it
  does not yet have drag placement, live collision feedback, or a full
  viewport-confirm workflow. The active snap inspector action is a shortcut into
  the same dialog-based flow, and the footprint preview is schematic with
  first-pass semantic fit feedback only.
- USB-C placement supports first-pass front-wall face-local picking/snapping
  from active snap targets. Other USB-C target surfaces still depend on future
  geometry support. Component-sourced USB-C cutouts also store projected
  surface coordinates. The visible marker is a mock viewport affordance.
- Button group placement supports first-pass face-local picking/snapping for
  manual surface groups. Component-sourced button groups also store projected
  switch centers for mock marker layout and supported native top-lid button
  generation.
- Glass recess placement supports first-pass face-local picking/snapping from
  active surface snap targets. The visible marker is a mock viewport affordance.
- Mount generation currently creates semantic standoff group data only; real
  B-Rep/mesh stand-off geometry is still future geometry-service work. The
  visible markers are mock viewport affordances.
- Validation details can select semantic targets, but issue rows do not yet
  provide fix actions or scroll the project browser to the selected object.
- Undo history is connected only to enclosure parameter edits, first
  component placement parameter edits, first
  USB-C/glass feature parameter edits, first button/mount feature-group
  parameter edits, first enclosure creation, first component placement, first
  USB-C cutout, first button group/glass recess/mount commands, and first
  advanced sketch creation/rectangle entity edits.
