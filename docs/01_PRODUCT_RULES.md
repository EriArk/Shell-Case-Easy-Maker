# 01 — Product Rules

## Rule 1 — Use human tasks, not CAD verbs

Default UI actions should be human tasks:

Good:
- Create enclosure
- Add lid
- Place board
- Add USB-C
- Generate mounts
- Create button group
- Create glass recess
- Add support rib
- Generate slot
- Generate case
- Export insert DXF

Bad in default UI:
- Boolean subtract
- Extrude cut
- Shell
- TopoDS operation
- Loft surface
- Sketch constraint

## Rule 2 — Keep the viewport clean

The model must remain the center of the experience. Panels must be compact, collapsible, and contextual.

## Rule 3 — Semantic objects stay semantic

A button group remains a button group. A glass insert remains an insert. A case remains linked to the device envelope. Do not flatten unless user explicitly detaches/converts.

## Rule 4 — Good defaults first, advanced later

Most controls should start with presets:
- FDM normal
- FDM tight
- Resin precise
- TPU soft tight
- Hard shell clearance

Advanced numeric settings are available but collapsed.

## Rule 5 — Every generator must validate

Each generator must produce warnings:
- wall too thin,
- port does not reach wall,
- button plunger misses switch,
- support intersects keepout,
- case covers exposed face,
- undercut impossible for hard material,
- clearance too tight.

## Rule 6 — Outputs are generated

STL, STEP, DXF, SVG, 3MF are export outputs. They are not the semantic source of truth.

## Rule 7 — Respect printability

The app is not only visual. It must account for:
- wall thickness,
- clearance,
- bridge/overhang risk,
- support accessibility,
- layer direction hints,
- material profiles,
- part splitting.

## Rule 8 — Progressive disclosure

Beginner tools first. Advanced tools hidden.
