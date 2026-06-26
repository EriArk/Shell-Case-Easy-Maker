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
