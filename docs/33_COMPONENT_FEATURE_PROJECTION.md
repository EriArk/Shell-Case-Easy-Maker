# 33 - Component Feature Projection

## Purpose

Component-driven enclosure generation needs a stable bridge between component
template coordinates and enclosure surface coordinates.

`ComponentFeatureSurfaceProjector` is that bridge. It projects semantic
component anchors such as connector centers and switch centers from a placed
component into:

- rotated component-local offset,
- world position in project millimeters,
- 2D position on the target enclosure surface,
- surface axes used by that 2D position.

This is still semantic metadata. It is not generated B-Rep, mesh, STL, or an
OCCT topology reference.

## Scope

Current first-pass support:

- `front` / `back` connector directions map to wall `x,z` coordinates,
- `left` / `right` connector directions map to wall `y,z` coordinates,
- `top` / `bottom` switch directions map to lid/bottom `x,y` coordinates,
- placement `rotationZ` is applied before the surface position is stored.

The projection uses the first enclosure body as the target body for now. Future
multi-body projects should make the target enclosure explicit.

## Validation

`ProjectSemanticValidator` performs first-pass checks on projected anchors:

- projected USB-C centers must fit within the target surface bounds,
- projected switch centers in component-sourced button groups must fit within
  the target surface bounds,
- missing source placement/template/feature references produce non-blocking
  warnings,
- missing or mismatched `surfaceAxes` produce non-blocking warnings.

These checks still use only semantic project data. They do not require preview
mesh, generated B-Rep, or OCCT topology IDs.

## Geometry Request Handoff

Projected anchors are copied into `GeometryRequest.featureIntents` when a
preview mesh request is built. For component-sourced USB-C cutouts, the
projected anchor stays in the feature intent placement data. For
component-sourced button groups, expanded request items use projected
`switchPositions` while the editable `ProjectModel` still stores one semantic
`FeatureGroup`.

The request payload is disposable backend input. The project file remains the
semantic source of truth.

## USB-C Cutout Metadata

When a component-sourced USB-C cutout is created, `SemanticFeature.placement`
keeps both source placement data and projected anchor data:

```json
{
  "componentPosition": [0.0, 0.0, 4.0],
  "componentRotation": [0.0, 0.0, 0.0],
  "projectionMode": "component_feature_surface_projection",
  "componentFeaturePosition": [0.0, -16.0, 0.0],
  "rotatedOffset": [0.0, -16.0, 0.0],
  "worldPosition": [0.0, -16.0, 4.0],
  "surfacePosition": [0.0, 4.0],
  "surfaceAxes": ["x", "z"],
  "componentFeatureDirection": "front"
}
```

The editable feature remains a normal semantic `usb_c_cutout`.

## Switch Button Group Metadata

When a component-sourced button group is created, each
`FeatureGroup.pattern.switchPositions` entry stores the projected position as
`position` so the pattern layout engine can preview it directly on the target
surface:

```json
{
  "id": "sw_a",
  "position": [7.0, 0.0],
  "componentFeaturePosition": [7.0, 0.0, 0.0],
  "rotatedOffset": [7.0, 0.0, 0.0],
  "worldPosition": [7.0, 0.0, 4.0],
  "surfaceAxes": ["x", "y"],
  "direction": "top"
}
```

The group remains one editable `button_group`. Changing the layout away from
`from_component_switches` detaches the visual layout from saved switch centers
without flattening the semantic group.

## Future Work

- Add explicit target enclosure selection for multi-body projects.
- Add reachability warnings and richer face-local orientation validation.
- Store projected cutout orientation when side-wall rotations become more
  detailed.
- Generate real cutouts and plungers from projected anchors in the OCCT worker.
