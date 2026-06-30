# 10 — Enclosure Auto Generation

## Purpose

The enclosure should understand placed internal components and generate mechanical structures around them.

## From component to case

Placed component data can create:

- standoffs from mounting holes,
- port cutouts from connectors,
- button holes/plungers from switches,
- keepout warnings,
- supports/ribs to board plane,
- lid height requirements,
- access openings.

## Standoffs

For each mounting hole:
- choose screw type,
- choose boss/standoff style,
- generate height to board underside,
- add hole,
- add heat insert option,
- add ribs if needed,
- avoid keepouts.

The native OCCT worker now generates the first bottom-inside
`standoff_mounts` bosses from semantic mounting-hole groups. For enclosures
with `lid.type: top_screw_lid`, it also generates four default lid screw bosses
and a separate top lid preview plate with matching screw clearance holes and an
underside locating lip from the enclosure lid spec. The body also gets a
matching shallow generated lid seat around the top opening. These are generated
B-Rep output; the editable project still stores semantic groups and lid
metadata rather than generated solids, per-boss bodies, per-hole editable
features, editable lip geometry, or editable groove geometry.

## Port cutouts

For a side-facing connector:
1. Determine connector direction.
2. Find target wall.
3. Check connector reaches wall or should be recessed.
4. Project cutout to surface.
5. Add clearance.
6. Add exterior chamfer/recess if requested.
7. Add internal keepout tunnel.

If connector does not reach a wall, warn.

The current implementation stores a first-pass semantic projection for
component-sourced USB-C cutouts. `ComponentFeatureSurfaceProjector` records the
source component feature position, rotated offset, world position, target
surface position, and surface axes in the generated `SemanticFeature.placement`
map. See `docs/33_COMPONENT_FEATURE_PROJECTION.md`.

## Buttons/switches

For upward switches:
- project switch centers to lid/top surface,
- generate hole or plunger,
- check height/travel,
- warn if switch cannot be reached.

Component-sourced button groups use the same projector. Saved
`FeatureGroup.pattern.switchPositions[*].position` values are target-surface
positions, while `componentFeaturePosition` keeps the original template-local
switch center.

## Supports/ribs

After placing a board:
- board plane remains known even if board hidden.
- user draws a line on internal plane.
- app generates rib/block to board underside.
- user draws rectangle.
- app generates structural rib grid.

## Keepout rules

Do not generate supports or clamps through:
- solder pads,
- tall components,
- antenna zones,
- connector tunnels,
- wire exits.

## User controls

Generate automatically but allow:
- suppress individual generated mount/cutout,
- change style,
- change clearance,
- lock generated result,
- convert to manual feature.
