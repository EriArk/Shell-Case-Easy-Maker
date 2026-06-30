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
- [x] Wire undo/redo to first enclosure parameter edits.
- [x] Implement command registry.
- [x] Implement project JSON file service.
- [x] Wire project JSON open/save commands.
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
- [x] Navigation presets foundation.
- [x] Compact semantic project browser.
- [x] Enclosure parameter controls in contextual inspector.
- [x] Toolbar undo/redo for inspector parameter edits.
- [x] Toolbar open/save for project JSON files.
- [x] Unsaved changes prompt before opening another project.
- [x] First-pass validation details sheet.
- [x] Validation issue rows select semantic targets.
- [x] Active snap target inspector action.
- [x] First executable left rail generator command.
- [x] First executable component placement command.
- [x] Component placement dialog live semantic fit check.
- [x] Component placement dialog transient viewport candidate.
- [x] Component placement dialog selected template size summary.
- [x] Component placement dialog quick position presets.
- [x] Component placement dialog rotation editing.
- [x] Component placement dialog snap anchor selection.
- [x] First-pass component-driven USB-C cutout command.
- [x] First-pass component-driven button group command.
- [x] First-pass component placement inspector editing.
- [x] First-pass component placement rotation editing.
- [x] First-pass component placement lock guard.
- [x] First executable surface-based USB-C command.
- [x] First executable surface-based button group command.
- [x] First executable surface-based glass recess command.
- [x] First executable component-driven mount command.
- [x] First-pass semantic feature parameter inspector editing.
- [x] First-pass semantic feature group parameter inspector editing.

## Phase 3 — Viewport MVP

- [x] Research Flutter 3D rendering options.
- [x] Implement orbit/pan/zoom.
- [x] Implement view cube / orientation gizmo.
- [x] Implement selection highlight.
- [x] Implement ghost preview.
- [x] Implement semantic feature group viewport markers.
- [x] Implement semantic button group viewport markers.
- [x] Implement semantic surface feature viewport markers.
- [x] Implement semantic component placement viewport previews.
- [x] Implement local workplane overlay.
- [x] Implement grid overlay.
- [x] Implement basic snapping visual hints.
- [x] Implement first-pass clickable snap hints.
- [x] Implement transient snap placement footprint preview.
- [x] Implement semantic fit feedback for snap placement previews.
- [x] Implement focus/fit view.
- [x] Render disposable geometry preview mesh when a backend provides one.
- [x] Highlight selected semantic surface ranges on generated preview mesh.
- [x] Highlight selected semantic feature ranges on generated preview mesh.
- [x] Add native preview overlay de-clutter pass.

## Phase 4 — OCCT worker MVP

- [x] Research OCCT build/distribution for Linux/Windows/macOS.
- [x] Add `occt_worker` protocol skeleton.
- [x] Add first-pass mock worker protocol CLI harness.
- [x] Add first-pass worker process client.
- [x] Add first-pass worker-backed `GeometryService` adapter.
- [x] Add developer geometry backend selection switch.
- [x] Add generated protocol fixtures with feature intents and operation plan.
- [x] Create `occt_worker` CLI or local service.
- [x] Add worker capability contract for backend readiness and supported operations.
- [x] Add Dart-side worker capability query client.
- [x] Add native worker executable build scaffold.
- [x] Add native worker stub smoke command.
- [x] Validate native worker request envelope and preserve request IDs.
- [x] Add OCCT Windows dependency readiness note and checker.
- [x] Add opt-in OCCT native target scaffold.
- [x] Add vcpkg manifest restore path for OCCT target.
- [x] Add repo-local vcpkg bootstrap helper.
- [x] Restore repo-local OCCT package and build linked smoke target.
- [x] Define JSON protocol for geometry requests.
- [x] Add feature/group geometry intents to preview requests.
- [x] Add deterministic geometry operation plan from feature intents.
- [x] Generate rounded box B-Rep.
- [x] Generate shell/cavity for box.
- [x] Generate mock preview mesh through protocol.
- [x] Generate OCCT preview mesh.
- [x] Emit first native semantic preview surface ranges.
- [x] Emit first native USB-C feature preview ranges.
- [x] Generate first native front-wall glass recess.
- [x] Generate first native front-wall button group cutouts.
- [x] Generate first native bottom standoff mounts.
- [x] Generate first native top screw lid bosses.
- [x] Generate first native top lid preview plate.
- [x] Generate first native top lid screw clearance holes.
- [x] Generate first native top lid locating lip.
- [x] Generate first native top lid body seat/groove.
- [x] Position first native top lid in fit-preview state.
- [x] Generate first native top lid button group cutouts.
- [x] Generate first native button rings/bezels.
- [x] Generate first native button cap/stem previews.
- [x] Add first-pass semantic plunger travel/clearance controls.
- [x] Generate first native plunger guide/travel-stop previews.
- [x] Generate first native top lid glass recess.
- [ ] Export STEP.
- [ ] Export STL.
- [x] Define response issues/warnings model.
- [x] Add protocol tests for known mock dimensions.
- [x] Add native OCCT metrics smoke for known rounded-box dimensions.
- [x] Add native OCCT preview mesh smoke for known rounded-box dimensions.
- [x] Add native OCCT app backend preset.
- [x] Bundle native OCCT worker into explicit latest Windows builds.
- [x] Feed native worker preview mesh into the Flutter viewport.
- [x] Add native preview readability/semantic annotation pass.
- [x] First-pass semantic validation warnings/errors.
- [x] First-pass component placement and keepout semantic validation.
- [x] Rotation-aware component placement bounds validation.
- [x] First-pass projected component anchor validation.
- [ ] Add OCCT geometry tests for known dimensions.

## Phase 5 — Enclosure-first MVP

- [x] First-pass create enclosure command/dialog.
- [ ] Guided enclosure wizard presets and validation polish.
- [x] First-pass box dimensions, wall thickness, corner radius.
- [ ] Lid type: none / top / bottom / screw lid.
- [x] First-pass lid type: none / top screw lid.
- [x] Add simple screw bosses.
- [x] Add first-pass generated top lid plate preview.
- [x] Add first-pass generated top lid screw holes.
- [x] Add first-pass generated top lid locating lip.
- [x] Add first-pass generated top lid body seat/groove.
- [x] Add first-pass generated top lid fit-preview positioning.
- [x] Add first-pass generated top lid button cutouts.
- [x] Add first-pass generated top lid glass recess.
- [ ] Add generic circular cutout.
- [ ] Add generic rectangular rounded cutout.
- [x] First-pass USB-C cutout command.
- [x] First-pass USB-C viewport marker.
- [x] First-pass USB-C inspector parameter editing.
- [ ] USB-C placement polish with face-local picking/snapping.
- [ ] Export STL/STEP.
- [x] First-pass wall thickness and cutout size validation.

## Phase 6 — Component template MVP

- [ ] Component template editor with 2.5D board view.
- [ ] Board outline polygon/rounded rectangle.
- [ ] Board thickness and reference plane.
- [ ] Mounting holes.
- [ ] USB-C / generic port semantic element.
- [ ] Button/switch semantic element.
- [ ] Keepout zones.
- [ ] Save/load component templates.
- [x] First-pass place component inside enclosure.
- [x] First-pass component placement bounds validation.
- [x] First-pass edit component placement from inspector.
- [x] First-pass component placement rotation and lock behavior.
- [x] First-pass component placement visibility behavior.
- [x] First-pass snap-seeded component placement from viewport picking.
- [x] First-pass active snap target placement action.
- [x] First-pass transient component footprint preview from snap target.
- [x] First-pass snap placement fit feedback.
- [x] First-pass placement dialog fit feedback.
- [x] First-pass placement dialog viewport candidate preview.
- [x] First-pass placement dialog quick position presets.
- [x] First-pass placement dialog rotation editing.
- [x] First-pass snap anchor selection for component placement.
- [ ] Guided component placement workflow with viewport picking.
- [x] Project switch centers and connector anchors to enclosure surfaces.

## Phase 7 — Component-driven enclosure generation

- [x] First-pass semantic standoff group from board mounting holes.
- [x] First-pass standoff marker preview from board mounting holes.
- [x] Reusable standoff source-anchor layout helper.
- [x] Generate real standoff geometry from board mounting holes.
- [x] Generate side wall cutouts from ports.
- [x] First-pass semantic USB-C cutout from component connector metadata.
- [x] First-pass projected component feature anchors.
- [x] First-pass projected component feature anchor validation.
- [x] Feed semantic feature/group intents into geometry requests.
- [x] Build request-time operation plan from feature/group intents.
- [ ] Generate top/lid cutouts from switches/buttons.
- [x] First-pass native top-lid button group cutouts.
- [x] First-pass semantic button group from component switch centers.
- [x] First-pass keepout warnings.
- [ ] Generate support ribs from drawn line.
- [ ] Generate rectangular structural rib grid.
- [x] First-pass component placement locking.
- [x] Component placement visibility toggles.

## Phase 8 — Pattern/layout system

- [x] First-pass editable `FeatureGroup` command.
- [x] First-pass generated pattern item preview/positions.
- [x] First-pass pattern/group inspector parameter editing.
- [x] Promote pattern expansion out of mock viewport into reusable layout logic.
- [x] First-pass generated standoff marker positions.
- [x] Promote standoff source-anchor expansion out of mock viewport.
- [ ] Line pattern.
- [ ] Grid pattern.
- [x] First-pass diamond/rhombus button pattern data.
- [x] First-pass diamond/row/grid marker expansion.
- [ ] Square pattern.
- [ ] Circle/arc pattern.
- [ ] Path/curve pattern.
- [ ] Edge-offset pattern.
- [ ] Pattern inspector.
- [ ] Per-item override model.
- [ ] Pattern detachment.
- [x] Pattern tests.

## Phase 9 — Mounting and retention

- [ ] Define mountable surfaces and forbidden zones in component templates.
- [x] First-pass semantic screw standoff command from component mounting holes.
- [x] First-pass visual standoff markers in mock viewport.
- [x] First-pass standoff inspector parameter editing.
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

- [x] First-pass manual glass recess command.
- [x] First-pass glass recess viewport marker.
- [x] First-pass glass recess inspector parameter editing.
- [x] First-pass native top-lid glass recess.
- [x] First-pass native top-lid glass ledge/window.
- [x] First-pass native front-wall glass ledge/window.
- [x] First-pass native rings around button holes.
- [ ] Recess from screen/window feature.
- [ ] Free recessed panel.
- [ ] Insert/glass definition.
- [ ] Ledge/lip/bezel generation.
- [ ] Protected islands inside recess.
- [x] First-pass editable ring/bezel style controls.
- [ ] Curved sides / GBA-like panel shapes.
- [ ] DXF export of glass/acrylic/insert contour.
- [ ] DXF layers and kerf/tool compensation.

## Phase 12 — Buttons/plungers and switch mapping

- [ ] Switch center overlay.
- [ ] Generate holes from switch centers.
- [x] First-pass native top-lid button holes from semantic button groups.
- [x] First-pass native button rings from semantic button groups.
- [x] First-pass button ring width/protrusion inspector controls.
- [x] First-pass native button cap/stem previews.
- [x] First-pass semantic plunger travel/clearance controls.
- [x] First-pass plunger travel/guide validation.
- [x] First-pass native guide sleeve/travel-stop preview geometry.
- [x] First-pass semantic button group from switch centers.
- [ ] Generate full button cap/plunger from switch centers.
- [ ] U-cut button generator.
- [ ] Plunger stem generator.
- [ ] Guide walls.
- [ ] Travel stop.
- [ ] Button cap texture.
- [x] First-pass manual button group generator.
- [x] First-pass manual button group viewport markers.
- [x] First-pass manual button group inspector parameter editing.
- [ ] Pattern generation from switch groups.
- [x] First-pass pattern source from component switch groups.

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
- [x] First-pass project USB-C connector to semantic cutout propagation.
- [ ] Case add-ons: grips, bumpers, feet, stand, stylus slot.
- [ ] Kickstand / hinge tools.

## Phase 15 — Interaction polish

- [ ] Parameter knobs.
- [ ] Focused parameter workflow.
- [ ] Parameter banks and diamond slots.
- [x] Native preview overlay mute/focus states.
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
