# 11 — Mounting and Retention System

## Purpose

Generate mounts, clips, pockets, rails, clamps, and retention features for components, especially components without screw holes.

## Main command

`Generate Mount`

Context:
- selected component placement,
- selected surface,
- selected slot,
- selected side button,
- selected module.

## Retention strategies

### Pocket mount
Component sits in a pocket.

### Friction fit
Component is held by controlled tight clearance.

### Screw clamp
Small clamp/wall/bridge with screw holds component down.

### Lid-retained
A protrusion or pad on the lid holds component in place.

### Rails / slide-in
Component slides into side rails with end stop.

### Snap retained
Printed snap/latch holds component.

## Safety zones

Mount generator must respect:
- forbidden clamp zones,
- solder/contact zones,
- wire exits,
- access areas,
- moving button areas,
- antenna zones.

## Side button case

User places a prepared button component on side wall and selects mounting generator.

Generated:
- opening,
- optional flush/recessed placement,
- side walls,
- clip/screw clamp,
- contact clearance,
- exterior recess with rounded edges.

## Flush/protruding/recessed modes

- Protruding: actuator sticks out.
- Flush: outer face aligns with wall exterior.
- Recessed: actuator sits below exterior surface with protective recess.

Parameters:
- recess depth,
- border width,
- corner radius,
- clearance,
- exterior chamfer.

## Validation

- Button actuator accessible.
- Contacts not covered.
- Wires have exit space.
- Clamp printable.
- Screw accessible.
- Component can be inserted/removed if intended.
