# TASKS.md — Implementation Roadmap

This is the living task backlog. Keep it updated.

For implementation order, safe chunk boundaries, and manual poke checklists, use `ROADMAP.md`.

## Phase 0 — Project bootstrap

- [x] Create `ROADMAP.md` with safe implementation chunks.
- [x] Add latest Windows release build script.
- [x] Create Flutter desktop project.
- [x] Create repository structure.
- [x] Configure GitHub `origin` remote and push initial documentation commit.
- [x] Add linting/formatting.
- [x] Add test framework.
- [x] Add basic CI.
- [x] Create docs folder and copy this documentation pack.
- [x] Add `WORKLOG.md` update discipline.
- [x] Create initial command system skeleton.
- [x] Create initial semantic project model skeleton.
- [x] Create initial geometry service interface.
- [x] Create mock geometry backend for UI development.

## Phase 1 — Architecture skeleton

- [x] Implement `ProjectModel` with versioned JSON serialization.
- [x] Implement `Feature` base model.
- [x] Implement `FeatureGroup` base model.
- [x] Implement `ComponentTemplate` base model.
- [x] Implement `Enclosure` model.
- [x] Implement `SelectionModel`.
- [x] Implement undo/redo transaction system.
- [x] Implement command registry.
- [x] Implement project JSON file service.
- [x] Implement parameter model with units, ranges, steps, defaults.
- [x] Implement validation result model.

## Phase 2 — Flutter UI shell

- [x] Viewport-first layout.
- [x] Left icon rail.
- [x] Right contextual inspector.
- [x] Bottom compact hint/status panel.
- [x] Top minimal toolbar.
- [ ] Collapsible/sliding panels.
- [x] Theme system foundation.
- [ ] Context popover foundation.
- [ ] Command palette foundation.
- [ ] Navigation presets foundation.
- [x] Compact semantic project browser.
- [x] Enclosure parameter controls in contextual inspector.

## Phase 3 — Viewport MVP

- [x] Research Flutter 3D rendering options.
- [x] Implement orbit/pan/zoom.
- [x] Implement view cube / orientation gizmo.
- [x] Implement selection highlight.
- [x] Implement ghost preview.
- [ ] Implement local workplane overlay.
- [x] Implement grid overlay.
- [ ] Implement basic snapping visual hints.
- [x] Implement focus/fit view.

## Phase 4 — OCCT worker MVP

- [x] Research OCCT build/distribution for Linux/Windows/macOS.
- [x] Add `occt_worker` protocol skeleton.
- [ ] Create `occt_worker` CLI or local service.
- [x] Define JSON protocol for geometry requests.
- [ ] Generate rounded box B-Rep.
- [ ] Generate shell/cavity for box.
- [x] Generate mock preview mesh through protocol.
- [ ] Generate OCCT preview mesh.
- [ ] Export STEP.
- [ ] Export STL.
- [x] Define response issues/warnings model.
- [x] Add protocol tests for known mock dimensions.
- [ ] Add OCCT geometry tests for known dimensions.

## Phase 5 — Enclosure-first MVP

- [ ] Create basic enclosure wizard.
- [x] First-pass box dimensions, wall thickness, corner radius.
- [ ] Lid type: none / top / bottom / screw lid.
- [x] First-pass lid type: none / top screw lid.
- [ ] Add simple screw bosses.
- [ ] Add generic circular cutout.
- [ ] Add generic rectangular rounded cutout.
- [ ] Add USB-C cutout.
- [ ] Export STL/STEP.
- [ ] Validate wall thickness and cutout placement.

## Phase 6 — Component template MVP

- [ ] Component template editor with 2.5D board view.
- [ ] Board outline polygon/rounded rectangle.
- [ ] Board thickness and reference plane.
- [ ] Mounting holes.
- [ ] USB-C / generic port semantic element.
- [ ] Button/switch semantic element.
- [ ] Keepout zones.
- [ ] Save/load component templates.
- [ ] Place component inside enclosure.
- [ ] Project switch centers and connector anchors to enclosure surfaces.

## Phase 7 — Component-driven enclosure generation

- [ ] Generate standoffs from board mounting holes.
- [ ] Generate side wall cutouts from ports.
- [ ] Generate top/lid cutouts from switches/buttons.
- [ ] Generate keepout warnings.
- [ ] Generate support ribs from drawn line.
- [ ] Generate rectangular structural rib grid.
- [ ] Add component placement locking and visibility toggles.

## Phase 8 — Pattern/layout system

- [ ] Implement `PatternFeature`.
- [ ] Line pattern.
- [ ] Grid pattern.
- [ ] Diamond/rhombus button pattern.
- [ ] Square pattern.
- [ ] Circle/arc pattern.
- [ ] Path/curve pattern.
- [ ] Edge-offset pattern.
- [ ] Pattern inspector.
- [ ] Per-item override model.
- [ ] Pattern detachment.
- [ ] Pattern tests.

## Phase 9 — Mounting and retention

- [ ] Define mountable surfaces and forbidden zones in component templates.
- [ ] Generate pocket mount.
- [ ] Generate friction-fit mount.
- [ ] Generate side walls.
- [ ] Generate screw clamp.
- [ ] Generate lid-retained mount.
- [ ] Generate rails.
- [ ] Flush/recessed side button placement.
- [ ] Contact/solder zone avoidance.

## Phase 10 — Slots, bays, batteries

- [ ] Slot from component.
- [ ] Free slot from drawn rectangle/contour.
- [ ] Access cutouts: semicircle/oval/finger/nail.
- [ ] Rails and end stops.
- [ ] Optional printed leaf spring.
- [ ] Optional latch.
- [ ] Slot cover generator: screws / hinge+latch / TPU friction / slider.
- [ ] Contact module placement for battery/module slots.
- [ ] DXF export for slot covers later.

## Phase 11 — Glass, inserts, panel recesses

- [ ] Recess from screen/window feature.
- [ ] Free recessed panel.
- [ ] Insert/glass definition.
- [ ] Ledge/lip/bezel generation.
- [ ] Protected islands inside recess.
- [ ] Rings around buttons.
- [ ] Curved sides / GBA-like panel shapes.
- [ ] DXF export of glass/acrylic/insert contour.
- [ ] DXF layers and kerf/tool compensation.

## Phase 12 — Buttons/plungers and switch mapping

- [ ] Switch center overlay.
- [ ] Generate holes from switch centers.
- [ ] Generate full button cap/plunger from switch centers.
- [ ] U-cut button generator.
- [ ] Plunger stem generator.
- [ ] Guide walls.
- [ ] Travel stop.
- [ ] Button cap texture.
- [ ] Pattern generation from switch groups.

## Phase 13 — Shape and aesthetics

- [ ] Smooth modifiers: bulge, dent, bend, taper.
- [ ] Ergonomic grip swell.
- [ ] Protected zones for deformations.
- [ ] Faceted panel system MVP on one face.
- [ ] Crease/ridge/valley lines.
- [ ] Faceted presets.
- [ ] Surface texture system.
- [ ] Texture boundary transitions.
- [ ] Markings: text, labels, ticks, scales, icons.

## Phase 14 — Case, grip, accessory generator

- [ ] Device envelope extraction.
- [ ] Mark open/no-case sides.
- [ ] TPU soft case generation.
- [ ] Hard shell case generation.
- [ ] Hybrid case metadata.
- [ ] Bumper frame.
- [ ] Grip case.
- [ ] Pseudo-button generation for case.
- [ ] Port cutout propagation.
- [ ] Case add-ons: grips, bumpers, feet, stand, stylus slot.
- [ ] Kickstand / hinge tools.

## Phase 15 — Interaction polish

- [ ] Parameter knobs.
- [ ] Focused parameter workflow.
- [ ] Parameter banks and diamond slots.
- [ ] Keyboard-emulated controller support.
- [ ] Step configuration.
- [ ] Right-click quick popovers.
- [ ] Snap/grid settings.
- [ ] Symmetry tools.
- [ ] Visual themes.

## Phase 16 — Advanced mode

- [ ] Advanced mode switch.
- [ ] Basic sketch tool.
- [ ] Extrude/cut.
- [ ] Boolean.
- [ ] Fillet/chamfer where safe.
- [ ] Convert generated feature to advanced editable geometry.
- [ ] Clear warnings when leaving semantic workflow.

## Phase 17 — Packaging

- [ ] Linux AppImage/Flatpak/deb.
- [ ] Windows installer.
- [ ] macOS app later.
- [ ] Bundle OCCT worker.
- [ ] Bundle license files.
- [ ] Add crash/error reporting logs.
- [ ] Add sample projects and component templates.

## Permanent backlog

- [ ] KiCad footprint import research.
- [ ] KiCad board import research.
- [ ] STEP import for component reference.
- [ ] SVG/DXF import for outlines.
- [ ] Stream Deck integration.
- [ ] HID/serial custom controller protocol.
- [ ] MIDI integration later, not priority.
- [ ] Cloud/community component library later.
