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

The service does not show native dialogs yet. A future command/controller layer
should connect it to explicit open/save commands after dependency and UX choices
are made.

## Current limitations

- Browser selection does not edit project state yet.
- Save/load is service-level only; no file picker or toolbar command is wired.
- Viewport selection is still mocked through the browser, not direct hit testing.
- Undo history is not connected because there are no editing commands yet.
