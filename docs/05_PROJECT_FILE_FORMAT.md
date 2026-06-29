# 05 — Project File Format

## Goals

- Human-readable enough for debugging.
- Versioned.
- Stable across app updates.
- Semantic, not geometry-output-based.
- Supports migration.

## Suggested structure

```json
{
  "schema": "abyss-enclosure-project",
  "version": 1,
  "units": "mm",
  "projectName": "Device",
  "printerProfile": "fdm_04_normal",
  "bodies": [],
  "componentTemplates": [],
  "componentPlacements": [],
  "features": [],
  "featureGroups": [],
  "constraints": [],
  "exports": [],
  "theme": null
}
```

## Versioning

Every saved file has:
- schema name,
- integer version,
- optional app version,
- migration history optional.

Do not break old projects without migration.

## Units

Default: millimeters.

All dimensions stored explicitly with numeric values in project units. UI can display converted values later.

## IDs

Use stable IDs for semantic objects:
- `main_enclosure`
- `front_usb_c`
- `screen_glass_insert`
- `button_group_abxy`

Avoid exposing raw OCCT IDs or mesh indices.

## Generated output metadata

Project may store export presets, not exported binary data.

Example:
```json
{
  "exports": [
    {
      "id": "screen_glass_dxf",
      "type": "dxf_insert_profile",
      "targetFeatureId": "screen_glass",
      "settings": {
        "kerfCompensation": 0.1,
        "layers": true
      }
    }
  ]
}
```

## Theme

Theme should generally be user preference, not project geometry. Only store screenshot/render theme if needed for presentation export.

## Migration

When schema changes:
- write explicit migration function,
- test migration from previous sample projects,
- preserve semantic intent.

## Current implementation skeleton

The first implementation lives under `lib/project/` and keeps project data semantic:
- `ProjectModel` owns schema/version, units, bodies, component templates, placements, features, feature groups, constraints, and export presets.
- `Enclosure`, `SemanticFeature`, `FeatureGroup`, `ComponentTemplate`, and `ComponentPlacement` are typed model entry points with JSON round-trip tests.
- `ComponentPlacement.visible` is a typed semantic display flag. Missing values
  default to `true` for older project files; hidden placements remain editable
  project objects and are only omitted from the mock viewport placement preview.
- Unknown semantic metadata is preserved when reading and writing fixtures so partially typed subsystem data is not silently dropped.
- `ProjectMigration` is the central entrypoint for schema upgrades and currently supports version 1.

Generated meshes, STL files, preview data, and OCCT topology are still excluded from the editable project model.

## Open/save UI

Project open/save commands use native file dialogs through
`ProjectFileDialogService` and then delegate JSON read/write to
`ProjectFileService`.

Current behavior:
- saved project files use `.enclosure.json` when the user does not provide a
  `.json` suffix,
- opening a project replaces shell state with the loaded semantic model,
- opening a project resets undo/redo history for the new file,
- opening another project while dirty asks before discarding unsaved edits,
- saving or opening updates the clean project baseline,
- the `Компоненты` rail command can append semantic `ComponentPlacement`
  entries from existing component templates,
- the `Порты` rail command can append semantic `usb_c_cutout` features targeted
  at a selected semantic surface,
- the `Кнопки` rail command can append semantic `button_group` feature groups
  with editable pattern and item prototype data,
- the `Стекло` rail command can append semantic `glass_recess` features targeted
  at a selected semantic surface,
- the `Крепёж` rail command can append semantic `standoff_mounts` feature
  groups sourced from a selected component placement's template mounting holes,
- generated previews are refreshed from the loaded semantic model.

Current limitations:
- no separate "Save As" command yet,
- export commands for STL/STEP are still separate future work.
