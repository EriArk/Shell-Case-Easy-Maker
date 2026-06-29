# 09 — Pattern and Layout System

## Purpose

Enclosure design needs repeated elements. Users should not manually place every hole.

The pattern system creates editable feature groups.

## Pattern users

- Button groups.
- LEDs.
- Vent holes/slots.
- Screw holes.
- Magnets.
- Rubber feet.
- Text labels.
- Texture motifs.
- Support ribs.
- Case bumpers.

## Pattern types

- Line.
- Grid.
- Square.
- Diamond/rhombus.
- Circle.
- Arc.
- Custom path/curve.
- Edge/contour offset.
- Mirrored/symmetric.
- Equal spacing between selected edges.

## Core parameters

- Count.
- Spacing.
- Radius.
- Start angle.
- End angle.
- Group rotation.
- Per-item rotation.
- Edge offset.
- Path offset.
- Alignment.
- Distribution.
- Snap rules.
- Local offsets.

## Item rotation modes

- Fixed.
- Tangent to path.
- Radial outward.
- Toward center.
- Custom angle.
- Follow surface normal.

## Placement modes

- Free.
- Centered on face.
- Centered between edges.
- Edge offset.
- Symmetric.
- Mirrored from another group.
- Follow curve.
- Follow contour.
- Projected from component anchors/switch centers.

## Button group example

```json
{
  "id": "button_group_1",
  "type": "button_group",
  "targetSurface": "main_enclosure.top_lid.outer",
  "pattern": {
    "layout": "diamond",
    "count": 4,
    "spacing": 14
  },
  "itemPrototype": {
    "type": "button",
    "shape": "circle",
    "diameter": 8,
    "mode": "plunger"
  },
  "placement": {
    "anchor": "center"
  }
}
```

## Current implementation

The first wired pattern command is `button.create_group`.

When a semantic surface is selected, the `Кнопки` rail button opens a compact
dialog and creates a `FeatureGroup` with:
- `type: button_group`,
- editable `pattern` data for layout, count, and spacing,
- editable `itemPrototype` data for circular button diameter and mode,
- centered placement metadata.

The group is committed as one undoable semantic object. It is not flattened
into independent button holes.

The mock viewport now derives schematic markers from the same group data:
- `diamond`,
- `row`,
- `grid`.

`PatternLayoutEngine` in `lib/patterns/pattern_layout.dart` owns this first
deterministic expansion. The workspace shell only converts returned local
pattern points into viewport marker offsets.

The same engine also owns first-pass `standoff_mounts` source expansion:
saved `FeatureGroup.pattern.holePositions` are preferred, and
`ComponentTemplate.mountingHoles` are used as a fallback when saved positions
are absent.

This is first-pass semantic expansion only. Generated marker positions are not
stored back into the project file, and the editable source remains the
`FeatureGroup` pattern plus item prototype. Future geometry generation should
consume the same layout engine rather than reimplementing pattern math inside
widgets or OCCT adapters.

When a `button_group` is selected, the contextual inspector currently supports
editing layout, count, spacing, button diameter, and button mode. Layout/count/
spacing are written back to `FeatureGroup.pattern`; diameter/mode are written
back to `FeatureGroup.itemPrototype`. The group remains one semantic object,
and undo restores the previous pattern/item data.

## Per-item overrides

Allow advanced overrides without losing group identity:

```json
{
  "overrides": {
    "item_2": {
      "offset": [1.0, 0.0],
      "rotation": 5
    }
  }
}
```

## UI controls

Pattern group inspector sections:
- Pattern.
- Item.
- Placement.
- Alignment/constraints.
- Clearance.
- Advanced.

Use compact knobs and icons.

## Tests

Current tests cover deterministic `diamond`, `row` fallback, `grid`, clamping,
reading button positions from semantic `FeatureGroup.pattern` data, and
standoff source positions from saved group data or component templates.
