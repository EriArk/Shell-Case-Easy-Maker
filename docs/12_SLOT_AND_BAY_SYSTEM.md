# 12 — Slot and Bay System

## Purpose

Generate externally accessible slots, bays, battery compartments, cartridge holders, card slots, service compartments, and removable module pockets.

## Creation modes

### From component

Place battery/module/card template, then `Generate Slot`.

The app creates:
- cavity,
- insertion opening,
- guides,
- stops,
- clearance,
- access cutouts,
- retention,
- optional cover,
- optional contact module mount.

### Free slot

Draw approximate rectangle/contour, set:
- width,
- height,
- depth,
- radius,
- insertion direction,
- access side,
- retention type.

## Slot parameters

- Shape.
- Size.
- Depth.
- Corner radius.
- Clearance.
- Insertion direction.
- Open side.
- Rails/guides.
- End stops.
- Insertion chamfers.
- Retention.
- Access cutout.
- Cover type.

## Retention options

- None.
- Friction.
- Lid-retained.
- Printed spring.
- Latch.
- Spring + latch.
- Sliding cover.
- TPU cover.

## Printed springs

Keep simple and template-based:
- leaf spring,
- side flexible tab,
- push-out spring.

Warn about material:
- PLA poor for long-term flex,
- PETG/nylon/TPU better.

## Covers

Cover generator types:
- screw cover,
- hinge + latch cover,
- TPU friction plug,
- slider cover,
- snap cover.

## Access cutouts

- Semicircle.
- Oval.
- Side finger notch.
- Nail notch.
- Push-through window.
- Beveled thumb cut.

## Contact module integration

A contact module can be attached to the slot. It generates:
- holes,
- mount,
- keepout,
- alignment with inserted object contacts,
- wire/channel clearance.

## Validation

- Insert can enter.
- Insert can be removed.
- Retention does not block insertion.
- Contacts align.
- Cover does not collide.
- Hard plastic undercuts are handled.
