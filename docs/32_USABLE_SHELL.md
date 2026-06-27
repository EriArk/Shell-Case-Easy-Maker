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

## Current limitations

- Only the first enclosure parameter bank edits project state.
- Viewport selection is still mocked and schematic, though direct hit testing
  already returns semantic IDs.
- Undo history is connected only to first enclosure parameter edits.
