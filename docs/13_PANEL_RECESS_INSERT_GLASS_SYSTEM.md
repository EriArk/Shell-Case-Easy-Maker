# 13 — Panel Recess, Insert, and Glass System

## Terminology

- **Recessed Panel** — an area formed in the enclosure surface.
- **Insert** — a separate part placed into a recess: glass, acrylic, metal, decorative plate, membrane, label.
- **Glass Insert / Screen Glass** — protective screen glass/acrylic.
- **Opening / Window** — the visible/display hole or transparent region.
- **Ledge / Lip / Bezel** — support rim/step for insert.
- **Border / Frame** — visual or structural outline around panel.

Use human UI labels:
- “Посадка под стекло”
- “Утопленная панель”
- “Вставка”
- “Окно экрана”
- “Бортик / полка”

## Use cases

- Protective glass over screen.
- Acrylic faceplate.
- Decorative metal insert.
- Full control panel recess.
- Button island panel.
- GBA-like curved display panel.
- Membrane overlay.

## Creation modes

### Manual glass recess

The first implementation wires `glass.create_recess` to the left rail `Стекло`
command.

When a semantic surface is selected, the command creates a `SemanticFeature`
with:
- `type: glass_recess`,
- `operation: recess`,
- `targetSurface` from the active semantic surface,
- parameters for width, height, recess depth, ledge width, corner radius,
  insert thickness, and clearance profile.

This is still semantic project state only. It does not store generated mesh,
B-Rep, DXF contours, or OCCT topology.

The native OCCT worker can consume a `glass_recess` on
`main_enclosure.front_wall.outer` or `main_enclosure.top_lid.outer` and use the
same semantic feature to cut a shallow outer seat plus an inner through-window
from `ledgeWidth`, leaving a support ledge/bezel around the opening.

The mock viewport derives a schematic selectable recess marker from the same
semantic `glass_recess` parameters. Clicking the marker selects the semantic
feature; it does not select a generated face or mesh primitive.

When a `glass_recess` feature is selected, the contextual inspector currently
supports numeric editing for width, height, recess depth, ledge width, corner
radius, and insert thickness. Each submitted change updates
`SemanticFeature.parameters` and is undoable. Clearance profile editing remains
future inspector polish.

### From feature

Select screen/window/button group and create panel around it.

Parameters:
- margin left/right/top/bottom,
- depth,
- corner radius,
- side curvature,
- border/lip,
- ledge overlap.

### Free panel

Draw region and set panel parameters.

## Protected islands

A recess can have islands:
- raised circles around buttons,
- uncut area around D-pad,
- separate pads,
- labels.

## Rings/bezels

Around holes/buttons:
- ring width,
- ring height,
- radius,
- gap.

## Glass/insert DXF export

Any insert should export a 2D manufacturing contour.

DXF layers:
- `OUTER_CUT`
- `INNER_CUT`
- `ENGRAVE`
- `MARKING`
- `CONSTRUCTION`
- `NOTES`

Parameters:
- material thickness,
- kerf compensation,
- tool diameter,
- dogbone/corner relief for CNC,
- tolerance/clearance,
- corner radii,
- optional part name.

Preserve arcs/curves where possible.

## Validation

- Insert has support ledge.
- Clearance matches material/process.
- Glass does not cover buttons unless intended.
- Visible window aligns with screen.
- DXF contour is closed.
