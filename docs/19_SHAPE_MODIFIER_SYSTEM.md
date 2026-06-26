# 19 — Shape Modifier System

## Purpose

Allow non-rectangular, ergonomic, and beautiful enclosure forms without turning the app into a sculpting tool.

## Rule

Shape modification must be controlled, parametric, and enclosure-oriented.

Do not create a free vertex sculpting workflow as the default.

## Smooth modifiers

- Bulge.
- Dent.
- Bend.
- Taper.
- Pillow.
- Grip swell.
- Thumb groove.
- Palm arch.
- Side swell.

## Smooth modifier parameters

- Center point.
- Height/depth.
- Radius of influence.
- Falloff profile.
- Direction.
- Symmetry.
- Protected zones.
- Preserve wall thickness.
- Affect outer skin only / inner+outer.

## Faceted modifiers

- Crease network.
- Ridge lines.
- Valley lines.
- Raised regions.
- Lowered regions.
- Faceted presets.

MVP: faceted panel on one selected face.

## Faceted rules

- Surface must remain connected.
- No self-intersections.
- Adjacent facets must meet.
- Boundary constraints respected.
- Thickness preserved or rebuilt.
- Protected zones preserved.

## Protected zones

Modifiers must avoid:
- port areas,
- lid mating surfaces,
- screen/glass seat,
- screw bosses,
- slots,
- component keepouts,
- button guide geometry.

## Aesthetic presets

- Organic: palm hump, thumb groove, soft side swell.
- Industrial: hard bevel, armored panel, wedge.
- Futuristic: diagonal ridge, faceted top, split plane.
- Low-poly: gemstone-like, angular grip.

## Validation

- Shape does not invade components.
- Lid still fits.
- Wall thickness acceptable.
- Ports/buttons remain functional.
