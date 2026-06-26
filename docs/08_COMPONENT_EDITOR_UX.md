# 08 — Component Editor UX

## UX identity

The component editor is a simple 2.5D mechanical template editor, not a full PCB editor.

It should feel like placing semantic stickers on a board outline.

## Workflow

1. Create component.
2. Draw/import outline.
3. Set thickness/reference plane.
4. Add holes.
5. Add ports/connectors.
6. Add buttons/switches.
7. Add keepouts and forbidden zones.
8. Add mountable zones.
9. Save to library.

## Main view

Top-down board view with optional side/height preview.

## Left tool rail

- Board outline
- Mounting hole
- USB-C
- Generic connector
- Button/switch
- LED
- Screen
- Sensor
- Contact module
- Keepout zone
- Forbidden clamp zone
- Mountable zone
- Wire exit

## Inspector examples

### USB-C

- Position.
- Side/direction.
- Protrusion.
- Cutout size.
- Clearance profile.
- Keepout tunnel.

### Switch

- Position.
- Direction.
- Actuation height.
- Recommended button mode.
- Cap installed? yes/no.

### Mounting hole

- Diameter.
- Screw type.
- Boss/standoff recommendation.
- Keepout around hole.

## Visual aids

- Board outline.
- Grid.
- Snap to center/holes/features.
- Origin marker.
- Direction arrows.
- Height markers.
- Keepout visualization.
- Solder/contact forbidden zones.

## Output

A `.component.json` semantic template.
