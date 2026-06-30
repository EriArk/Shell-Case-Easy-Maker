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

## Current native slice

The native OCCT worker now generates first-pass circular button openings and
small raised rings/bezels from semantic `button_group` data. It also generates
first-pass plunger-style preview caps and stems for groups whose
`itemPrototype.mode` is `plunger`. Front-wall groups produce a through-hole
cut, a fused annular ring on the outside face, and separate disposable cap/stem
preview solids with first-pass guide sleeves and travel-stop collars. Top-lid
groups do the same against the generated lid preview plate.

The editable project still stores one `button_group`; ring, cap, and stem
solids are disposable generated geometry, and preview faces for holes/rings
and cap/stem/guide/stop parts map back to the same semantic group ids such as
`front_buttons` and `top_lid_buttons`. First-pass style controls are semantic
`itemPrototype` values: `ringWidth`, `ringProtrusion`, `capDiameter`,
`capHeight`, `stemDiameter`, `stemDepth`, `travel`, `switchClearance`, and
`guideClearance`. The Flutter semantic validator now checks that plunger travel
plus switch clearance fits the stem depth and that guide clearance is not too
tight, too loose, or wider than the cap opening, including the first native
guide-wall thickness. Rich anti-wobble features, tactile top textures, chamfers,
material-specific fit rules, and richer cap shapes remain future work.

## Parameters

- Cap shape: circle, rectangle, rounded rectangle, oval, custom.
- Cap size.
- Cap height/protrusion.
- Ring/bezel width.
- Ring/bezel protrusion.
- Flush/protruding/recessed.
- Stem width/diameter.
- Stem target point.
- Travel.
- Switch clearance.
- Guide clearance.
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
- Travel plus switch clearance fits stem depth.
- Guide clearance is printable and fits inside the cap opening.
- Button can be inserted/printed.
- U-cut flex material appropriate.
