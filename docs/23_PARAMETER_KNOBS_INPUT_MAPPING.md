# 23 — Parameter Knobs and Input Mapping

## Purpose

Parameter editing should feel fast, tactile, and minimal.

The main editing method should often be a compact knob/value control, not giant sliders or text fields.

## Parameter knob behavior

- Hover/select parameter.
- Mouse wheel changes value.
- Drag rotates/scrubs.
- Small numeric popup appears.
- Click numeric value to type exact value.
- Shift = fine step.
- Ctrl/Alt = coarse/snap step.
- Double click = reset default.
- Right click = quick settings.

## Step system

Each numeric parameter defines:
- normal step,
- fine step,
- coarse step,
- min/max,
- unit,
- precision,
- snap values if any.

Examples:
- length: normal 0.1/0.25 mm, fine 0.05 mm, coarse 1 mm.
- angle: normal 1°, fine 0.1°, coarse 15°.
- count: step 1.
- percent: normal 1%, fine 0.1%, coarse 5–10%.

Steps are configurable globally, per parameter type, per tool, and per controller profile.

## Keyboard-emulated controllers

MIDI is not priority now.

Most custom controllers emulate keyboard keys and mouse clicks. Support this first.

Core commands:
- `activeParameterIncrease`
- `activeParameterDecrease`
- `nextParameter`
- `previousParameter`
- `selectSlotTop`
- `selectSlotLeft`
- `selectSlotBottom`
- `selectSlotRight`
- `nextBank`
- `previousBank`
- `selectBank1...N`
- `fineMode`
- `coarseMode`
- `resetParameter`
- `openNumericInputForActiveParameter`

## Focused parameter

User selects active parameter; physical encoder changes it.

A small HUD shows:
- parameter name,
- icon,
- value,
- unit,
- step mode.

## Parameter banks and diamond slots

A compact 4-slot diamond can represent current active parameters:

```text
        Top
Left          Right
       Bottom
```

Keyboard mapping:
- W selects top.
- A selects left.
- S selects bottom.
- D selects right.
- Shift switches temporary bank.
- Ctrl switches alternate bank.
- Number keys choose banks directly.

## Example context banks

Button group bank:
- spacing,
- diameter,
- recess depth,
- rotation.

Recess bank:
- depth,
- margin,
- corner radius,
- side curvature.

Texture bank:
- scale,
- depth,
- angle,
- fade width.

Grip bank:
- height,
- radius,
- softness,
- symmetry.

## Hardware

Support later through the same command system:
- Stream Deck,
- QMK/VIA keyboard/encoder pads,
- custom HID/serial controllers,
- MIDI later.

## Undo grouping

Continuous knob/encoder changes should become one undo transaction after inactivity/release.

## Conflict handling

When typing in text/numeric fields, global shortcut capture should pause unless controller mode explicitly captures it.
