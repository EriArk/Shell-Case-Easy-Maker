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
dialog with the picked face-local X/Y. Normal selection, undo, redo, and
project edits clear the transient snap target so stale UI state is not saved or
replayed.

When an active snap target exists, the inspector shows a compact `Точка
привязки` section with the snap label, seeded project position, mounting side,
a direct `Разместить компонент` action, a direct `Отверстие` action for surface
targets, and a clear action. These actions still open the normal semantic
dialogs; confirming them creates regular semantic project objects, not saved
snap references.

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

`Кнопки` is also available when a selected component placement's template has
switch features. In that context the dialog starts from
`from_component_switches`, stores the switch centers in
`button_group.pattern.switchPositions`, and records source placement/template
IDs. The saved switch positions are projected to the target surface, while each
entry also keeps the original template-local switch center. The result is still
one editable `FeatureGroup`; switching the layout away from
`from_component_switches` makes the group behave like a normal manual pattern.

Clicking `Стекло` is enabled only after selecting a semantic surface. The
command opens a compact glass recess dialog and appends a semantic
`glass_recess` feature with window size, recess depth, ledge width, radius,
insert thickness, and clearance profile data. The mock viewport draws a
schematic recess marker; clicking it selects the semantic feature.

Clicking `Крепёж` is enabled only after selecting a component placement whose
template has mounting holes. The command opens a compact mount dialog and
appends a semantic `standoff_mounts` `FeatureGroup` sourced from the template
hole positions. The generated mounts stay editable as one group with standoff
diameter, hole diameter, height, clearance profile, and source placement data.
The mock viewport draws schematic markers for this group; clicking a marker
selects the whole `FeatureGroup` and shows its inspector details.

Future rail tools remain visible to show the intended workflow, but they are
disabled until their semantic command behavior is implemented and tested.

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
- USB-C placement still uses dialog values and target surface selection rather
  than face-local picking/snapping. Component-sourced USB-C cutouts do store
  first-pass projected surface coordinates for future geometry. The visible
  marker is a mock viewport affordance.
- Button group placement still uses centered dialog defaults rather than
  face-local picking/snapping. Component-sourced button groups do store
  projected switch centers for future geometry and mock marker layout.
- Glass recess placement still uses selected surface and dialog dimensions
  rather than face-local picking/snapping. The visible marker is a mock
  viewport affordance.
- Mount generation currently creates semantic standoff group data only; real
  B-Rep/mesh stand-off geometry is still future geometry-service work. The
  visible markers are mock viewport affordances.
- Validation details can select semantic targets, but issue rows do not yet
  provide fix actions or scroll the project browser to the selected object.
- Undo history is connected only to enclosure parameter edits, first
  component placement parameter edits, first
  USB-C/glass feature parameter edits, first button/mount feature-group
  parameter edits, first enclosure creation, first component placement, first
  USB-C cutout, and first button group/glass recess/mount commands.
