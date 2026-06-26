# 14 — Surface Texture System

## Purpose

Add parametric functional/decorative surface textures with alignment across surfaces and controlled transitions.

## Texture types

- Dots.
- Lines.
- Diagonal lines.
- Grid.
- Micro-dots.
- Grip texture.
- Knurl-like.
- Hex/honeycomb.
- Triangles.
- Leather-like.
- Matte micro pattern.
- Button-top tactile patterns.

## Parameters

- Scale.
- Depth/height.
- Step.
- Density.
- Angle.
- Offset.
- Edge margin.
- Randomness.
- Raised vs engraved.
- Boundary transition.

## Application modes

- Per-face.
- Continuous across selected adjacent faces.
- Wrapped region.
- Local patch.

## Boundary transitions

When texture ends or meets another texture:
- Clean cutoff.
- Fade out.
- Border groove.
- Border ridge.
- Step transition.
- Chamfer boundary.
- Soft frame transition.
- Functional transition band.

## Autostitching

If multiple adjacent surfaces are selected, texture should align across them where practical.

For complex curved/faceted surfaces, use semantic surface mapping, not raw triangle UV as source of truth.

## Functional vs decorative

Separate:
- surface texture,
- marking/annotation,
- button tactile texture.

## Validation

- Texture depth does not weaken wall excessively.
- Texture does not invade protected zones.
- Texture does not cross forbidden functional openings unless allowed.
- Very dense textures warn about print time/quality.
