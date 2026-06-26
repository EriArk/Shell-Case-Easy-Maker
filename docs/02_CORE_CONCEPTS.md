# 02 — Core Concepts

## Project

The saved semantic document. Contains units, settings, bodies, components, placements, features, generators, constraints, exports, and metadata.

## Enclosure

The main printable case/body. Usually has walls, thickness, lid, openings, bosses, inserts, texture, and internal supports.

## Device

A complete designed object: enclosure + internal components + panels + buttons + slots + visible user interface. A device can be used as source geometry for a case/accessory.

## Component Template

A semantic description of an internal object such as a PCB, button, battery, module, sensor, screen, connector, or contact board.

It stores mechanical meaning:
- outline,
- thickness,
- mounting holes,
- ports,
- switches,
- buttons,
- keepouts,
- mountable surfaces,
- forbidden clamp zones,
- access zones,
- contact/solder zones.

## Component Placement

An instance of a component template placed inside an enclosure/device.

## Feature

A semantic operation/object that generates geometry:
- USB-C cutout,
- screw boss,
- button hole,
- glass recess,
- texture patch,
- support rib,
- text label.

## Feature Group / Pattern Feature

A group of related repeated features that remains editable:
- button diamond,
- screw corner set,
- LED row,
- vent grid,
- magnet set,
- rib grid.

## Pattern

The rule used to place items:
- line,
- grid,
- square,
- diamond,
- circle,
- arc,
- path,
- contour/edge offset,
- symmetry/mirror.

## Placement Constraint

Human-friendly relation:
- free,
- centered,
- edge offset,
- between edges,
- symmetric,
- mirrored,
- aligned to component,
- projected from switch centers.

## Surface / Workplane

A semantic surface such as top lid, front wall, left wall, case back, slot cover, or insert face. It exposes a local 2D coordinate system for layout.

## Keepout

A protected volume or area where generated geometry must not intrude.

## Clearance / Fit Profile

Reusable rules for tolerances:
- FDM normal,
- FDM tight,
- sliding fit,
- friction fit,
- TPU tight,
- glass insert clearance.

## Insert

A separate flat or shaped piece that sits in a recess:
- glass,
- acrylic,
- metal panel,
- decorative plate,
- membrane,
- label plate.

## Recessed Panel

The recess/seat in a body surface that holds an insert or visually groups controls.

## Device Envelope

A semantic outer volume of a finished device used to generate cases/accessories. Includes protected/open zones, ports, buttons, screen, slots, vents, etc.

## Advanced Geometry

Low-level CAD shapes created by advanced tools. These should not replace semantic workflow unless user explicitly converts/detaches.
