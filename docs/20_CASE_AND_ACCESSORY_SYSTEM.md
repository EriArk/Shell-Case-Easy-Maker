# 20 — Case and Accessory System

## Purpose

Generate cases, grips, bumpers, protective shells, docks, stands, covers, and external modules around an already-designed device.

## Workflow

1. Select device/body.
2. Create Case/Grip/Accessory.
3. Choose type/material.
4. Mark covered/open sides.
5. App generates base accessory from device envelope.
6. User adds grips, bumpers, stands, hinges, slots, modules.

## Case types

- TPU soft skin.
- Hard shell.
- Hybrid case.
- Bumper frame.
- Grip case.
- Rugged protective case.
- Flip/hinged cover.
- Dock/cradle.
- Add-on module shell.

## Device envelope

Generated from semantic device model:
- outer body,
- screen/glass zones,
- buttons,
- ports,
- speakers/mics,
- slots,
- vents,
- screw access,
- protected/no-cover zones.

## Open side rules

User can specify:
- front panel open,
- screen open,
- buttons open or pseudo-buttons,
- ports open,
- slot access open,
- sensor window open.

Case may wrap around edge with configurable lip.

## Automatic propagation

- Ports → cutouts/tunnels.
- Buttons → holes or pseudo-buttons.
- Screen → window/lip/frame.
- Speakers/mics → grilles/openings.
- Slots → access cutouts.
- Charging connector → cutout or dock feature.

## Materials

### TPU
- flexible lip,
- tight fit,
- pseudo-buttons,
- friction.

### Hard shell
- clearance,
- split shell,
- screws/clips/magnets,
- avoid impossible undercuts.

### Hybrid
- multi-part,
- hard back + soft bumper,
- separate exports.

## Add-ons

- Grips.
- Impact bumpers.
- Corner protectors.
- Feet.
- Kickstands.
- Hinges.
- Keyboard module.
- Stylus slot.
- Charging dock connector.
- Strap/lanyard loops.
- Clips/brackets.

## Validation

- Device can enter case.
- Hard case assembly possible.
- TPU stretch is plausible.
- Buttons still work.
- Ports accessible.
- Case does not cover no-case side.
