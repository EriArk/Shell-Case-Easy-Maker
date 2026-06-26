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
