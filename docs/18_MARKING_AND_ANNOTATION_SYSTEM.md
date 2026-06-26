# 18 — Marking and Annotation System

## Purpose

Add text, icons, ticks, scales, labels, and tactile markings.

## Types

### Text
- Raised.
- Engraved.
- On path.
- On arc.
- Aligned to feature.
- Around knob/encoder.

### Ticks/scales
- Encoder ticks.
- Potentiometer scale.
- Toggle switch positions.
- Slider scale.
- Numbered marks.

### Icons
- Power.
- Plus/minus.
- Arrows.
- Play/pause.
- USB.
- Bluetooth.
- Custom SVG later.

### Tactile markings
- Dots.
- Ridges.
- Button texture.
- Directional grooves.
- Raised nub.

## Parameters

- Text content.
- Font choice.
- Size.
- Depth/height.
- Spacing.
- Alignment.
- Curve/arc radius.
- Tick count.
- Long/short tick pattern.
- Engrave/raise.
- Clearance from functional features.

## DXF export

Markings on inserts/panels can export to `ENGRAVE` or `MARKING` layers.

## Validation

- Text remains printable/engraveable.
- Marks do not overlap holes unless intended.
- Marking depth does not weaken thin walls.
