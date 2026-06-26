# 16 — Button and Plunger System

## Purpose

Generate holes, caps, plungers, guide walls, U-cut flexible buttons, pseudo-buttons, and button textures.

## Scenarios

### Hole only
Switch already has cap. App creates opening.

### Full button/plunger
App creates external cap and internal stem that presses switch.

### U-cut button
Part of case surface flexes as a button.

### Case pseudo-button
TPU/hard case button cap presses original device button.

## Generated parts

- Cap geometry.
- Stem/plunger.
- Guide walls.
- Anti-wobble features.
- Travel stop.
- Clearance.
- Recess/ring/bezel.
- Tactile top texture.
- Optional labels/markings.

## Parameters

- Cap shape: circle, rectangle, rounded rectangle, oval, custom.
- Cap size.
- Cap height/protrusion.
- Flush/protruding/recessed.
- Stem width/diameter.
- Stem target point.
- Travel.
- Clearance.
- Guide style.
- Top texture.
- Material profile.

## U-cut parameters

- Cut shape.
- Flex arm length.
- Hinge thickness.
- Button island size.
- Travel limit.
- Material warning.

## Validation

- Stem reaches switch center.
- Stem does not collide with board/components.
- Travel is enough.
- Guide clearance is valid.
- Button can be inserted/printed.
- U-cut flex material appropriate.
