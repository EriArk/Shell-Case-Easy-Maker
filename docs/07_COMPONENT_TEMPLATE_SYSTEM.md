# 07 — Component Template System

## Purpose

Component templates describe internal real-world parts in a way the enclosure generator can understand.

A component template is not just a STEP file or a mesh. It is a semantic mechanical template.

## Examples

- PCB with USB-C and switches.
- Button module.
- Screen module.
- Battery cell.
- Nokia-style removable battery.
- Contact module.
- Speaker.
- Sensor.
- NFC board.
- Encoder.
- Custom hand-made part.

## Required data

### Physical body
- outline,
- thickness/height,
- reference plane,
- optional visual 3D model.

### Mounting
- mounting holes,
- mountable surfaces,
- preferred support zones,
- forbidden clamp zones.

### Functional features
- ports/connectors,
- switches/buttons,
- LEDs,
- sensors,
- screens,
- contacts,
- antennas,
- speakers/mics,
- slots.

### Geometry requests
A component can request:
- wall cutout,
- top/lid cutout,
- standoff,
- boss,
- screw clamp,
- rails,
- keepout,
- button plunger,
- contact access.

## Forbidden zones

Examples:
- solder pads,
- connector pins,
- antenna area,
- moving actuator,
- wire exit,
- sensor view cone,
- optical window,
- speaker sound path.

## Access zones

Features that must remain accessible:
- USB-C opening,
- button press area,
- screen visibility,
- LED visibility,
- SD card insertion,
- battery removal.

## Template creation modes

1. Manual simple editor.
2. Import outline from SVG/DXF.
3. Import KiCad footprint/board later.
4. Import STEP as visual/reference geometry.
5. Downloaded libraries converted into templates later.

## Template library

Templates should be saved independently from projects and reused.

Storage:
```text
user_library/components/
  boards/
  buttons/
  ports/
  batteries/
  sensors/
  screens/
```

## Generated from templates

When placed in an enclosure:
- mounting holes generate standoffs,
- connectors generate case cutouts,
- switches generate holes/buttons,
- keepouts affect supports,
- height affects lid/case clearance.

## Current implementation slice

The starter `ComponentTemplate.buttonBoard()` includes four typed mounting
holes. Selecting its `ComponentPlacement` and running `mount.generate` creates a
semantic `standoff_mounts` `FeatureGroup` from those holes.

The generated group records:
- source placement/template IDs,
- source mounting-hole positions,
- standoff diameter,
- hole diameter,
- height,
- screw label,
- clearance profile.

The editable project still stores this as semantic intent. Generated B-Rep,
preview mesh, and export geometry should be derived later by `GeometryService`
or the OCCT worker.

The mock viewport also derives schematic standoff markers from the same source
positions. Those markers are selectable affordances for the semantic
`FeatureGroup`; they are not saved geometry.

When a component placement is started from a surface snap target, the placement
dialog can use the template's board center, mounting holes, and semantic
feature centers as transient alignment anchors. Choosing an anchor recalculates
the placement center so that anchor lands on the selected snap point. The
project still stores only the resulting semantic `ComponentPlacement`; selected
anchor UI state is not serialized.

When a component placement is selected, the `Порты` generator can also create a
first-pass semantic `usb_c_cutout` from a template USB-C feature's `cutout`
metadata. The generated cutout records source placement/template/feature IDs so
future geometry and propagation tools can trace where it came from.

The `Кнопки` generator can now create a first-pass semantic `button_group` from
template switch features. Switch centers are saved in
`FeatureGroup.pattern.switchPositions`, source placement/template IDs are kept,
and repeated buttons remain one editable group instead of being flattened.
For supported top-lid targets, the native OCCT preview consumes those saved
switch centers through the regular `button_group` generator and produces
disposable holes/rings/plunger preview geometry while leaving the semantic group
editable.

Placed component features now also pass through
`ComponentFeatureSurfaceProjector` when component-sourced ports or button
groups are created. The template remains local component data; projected
`worldPosition`, `surfacePosition`, and `surfaceAxes` are stored on the
generated semantic feature/group so future geometry can regenerate cutouts
without relying on mesh or topology IDs. See
`docs/33_COMPONENT_FEATURE_PROJECTION.md`.

`ProjectSemanticValidator` also performs a first-pass component placement check
against the enclosure inner volume. It treats the component board as a semantic
outline/thickness envelope, accounts for the placement's Z rotation with a
conservative bounding box, and reports an error if the placement no longer fits
inside the enclosure. Template feature `keepout` boxes are checked with the same
rotation-aware envelope as non-blocking warnings so access zones can be surfaced
before real cutout or support generation exists.
