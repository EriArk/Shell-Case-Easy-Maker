# 32 - Usable Shell

## Purpose

The usable shell connects the semantic project model to compact UI context.

The shell is still a mock geometry experience, but selection, inspector text,
command availability, and project browsing are now driven by semantic IDs rather
than widget-only state or generated mesh data.

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
`EnclosureParameterAdapter`. The mock viewport and mock geometry protocol then
refresh from the updated project. The editable source remains semantic
enclosure data, not generated mesh or preview triangles.

Effective parameter edits are committed to `UndoHistory<ProjectModel>`. The top
toolbar enables undo/redo when semantic snapshots are available, then refreshes
the inspector and mock preview after restoring a snapshot.

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

## Project JSON file service

`ProjectFileService` provides basic JSON encode/decode and disk read/write.

`ProjectFileDialogService` provides native open/save file selection through
`file_selector`.

The top toolbar now wires project open/save commands:
- open loads `.enclosure.json` into semantic shell state,
- save writes the current semantic project,
- open resets undo/redo history for the loaded file,
- open asks before discarding unsaved semantic edits,
- the status bar reports unsaved changes when the project differs from the
  persisted baseline,
- generated preview data is refreshed after loading.

## First Generator Command

The left tool rail now executes the first semantic generator commands:
`enclosure.create`, `component.place`, `port.add_usb_c`, and
`button.create_group`, `glass.create_recess`, and `mount.generate`.

Clicking `Корпус` opens a compact create-enclosure dialog using the same rounded
enclosure parameter schema as the inspector. Confirming the dialog updates the
semantic `ProjectModel`, selects the enclosure, refreshes the mock preview, and
creates one undo history entry.

Clicking `Компоненты` opens a compact placement dialog when the project has at
least one `ComponentTemplate`. Confirming the dialog appends a semantic
`ComponentPlacement`, selects it, refreshes the mock preview, and creates one
undo history entry. If undo removes the selected placement, selection falls back
to the workspace so the inspector does not point at a stale ID.

Clicking `Порты` is enabled only after selecting a semantic surface such as
`Front wall`. The command opens a compact USB-C dialog, appends a semantic
`usb_c_cutout` feature targeted at the selected surface, selects the new
feature, refreshes the mock preview, and creates one undo history entry.

Clicking `Кнопки` is enabled only after selecting a semantic surface such as
`Top lid`. The command opens a compact button group dialog and appends a
semantic `FeatureGroup` with editable layout/count/diameter/spacing data. The
group remains one semantic object rather than becoming several unrelated
button holes.

Clicking `Стекло` is enabled only after selecting a semantic surface. The
command opens a compact glass recess dialog and appends a semantic
`glass_recess` feature with window size, recess depth, ledge width, radius,
insert thickness, and clearance profile data.

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

- Only the first enclosure parameter bank, first create-enclosure command,
  first component placement command, first USB-C cutout command, and first
  button group/glass recess/mount commands edit project state.
- Viewport selection is still mocked and schematic, though direct hit testing
  already returns semantic IDs.
- Component placement still uses typed dialog values rather than viewport
  picking or snapping.
- USB-C placement still uses dialog values and target surface selection rather
  than face-local picking/snapping.
- Button group placement still uses centered dialog defaults rather than
  face-local picking/snapping or generated item previews.
- Glass recess placement still uses selected surface and dialog dimensions
  rather than face-local picking/snapping.
- Mount generation currently creates semantic standoff group data only; real
  B-Rep/mesh stand-off geometry is still future geometry-service work. The
  visible markers are mock viewport affordances.
- Undo history is connected only to enclosure parameter edits, first enclosure
  creation, first component placement, first USB-C cutout, and first button
  group/glass recess/mount commands.
