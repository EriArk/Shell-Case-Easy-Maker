

<!-- FILE: README.md -->


# Enclosure CAD Codex Documentation Pack

This repository documentation describes a Flutter + OpenCascade desktop application for fast, visual, beginner-friendly design of 3D-printable enclosures, component-driven cases, inserts, slots, grips, and accessories.

The product is **not** a generic CAD clone. It is a semantic, parametric enclosure constructor with a precise B-Rep backend.

## Read order for Codex

1. `AGENTS.md`
2. `TASKS.md`
3. `docs/00_PROJECT_VISION.md`
4. `docs/01_PRODUCT_RULES.md`
5. `docs/02_CORE_CONCEPTS.md`
6. `docs/03_ARCHITECTURE_OVERVIEW.md`
7. `docs/04_GEOMETRY_ENGINE_OCCT.md`
8. `docs/26_TESTING_AND_QUALITY.md`
9. Then read the subsystem document related to the task.

## Top-level files

- `AGENTS.md` — mandatory rules for Codex/agents.
- `TASKS.md` — phased implementation plan and task backlog.
- `WORKLOG.md` — append-only worklog template.
- `docs/` — detailed product, architecture, UX, geometry, and subsystem docs.
- `templates/` — reusable templates for worklog entries, tasks, research notes, and feature specs.
- `examples/` — example semantic project JSON and component template JSON.

## Core product statement

A minimal, visual, Flutter-based enclosure design tool powered by OpenCascade. Users design devices by placing semantic components and features, not by manually editing meshes. The app generates exact B-Rep geometry, then exports STL/STEP/DXF/3MF from the semantic project model.

## Absolute rule

The editable source of truth is the semantic project model. Generated mesh/STL/DXF files are disposable outputs.



<!-- FILE: AGENTS.md -->


# AGENTS.md — Mandatory Codex Rules

Read this file before making any code change.

## Product identity

This app is a **visual enclosure/device/accessory constructor**, not a generic CAD application.

The target user is a maker or beginner who wants to create printable enclosures, panels, cases, grips, slots, inserts, and component mounts without learning traditional CAD workflows.

Do not turn the product into:
- a FreeCAD clone,
- a Dune3D fork,
- a Blender-style mesh editor,
- a general parametric CAD system as the default UX,
- a UI full of exposed booleans/extrusions/sketch constraints.

Low-level CAD operations may exist only in `Advanced Mode`, hidden from the default workflow.

## Core architecture rules

1. **Semantic model first**
   - The project stores semantic objects: enclosures, components, cutouts, button groups, slots, inserts, textures, cases, etc.
   - Do not store the editable project as STL, mesh, or generated B-Rep.

2. **B-Rep-first geometry**
   - OpenCascade / OCCT is the primary geometry kernel.
   - Generated B-Rep is the source for STEP, STL mesh preview, STL export, and DXF extraction.
   - Mesh output is never the editable source of truth.

3. **Flutter UI must not depend on OCCT internals**
   - Flutter talks to a `GeometryService`.
   - `GeometryService` talks to an `occt_worker` or adapter.
   - Keep the geometry backend replaceable and testable.

4. **Generator-first UX**
   - Default tools are semantic generators: create enclosure, place component, add USB-C, generate mount, create glass recess, generate button group, create slot, generate case.
   - Low-level tools like Sketch, Extrude, Boolean, Shell, Fillet are not default UI actions.

5. **Context-first UI**
   - Tools and parameters must adapt to selected object, face, feature, component, or workspace.
   - Avoid permanent clutter and huge text buttons.
   - Prefer icon-first rails, compact inspectors, popovers, value knobs, and short hints.

6. **Feature groups must stay editable**
   - Repeated features must be stored as patterns/groups, not flattened into independent holes unless explicitly detached.
   - Example: a 4-button diamond is a `ButtonGroup` with a `diamond` layout, not four unrelated circles.

7. **Components are semantic mechanical templates**
   - A component is not only a 3D model.
   - It can request holes, mounts, supports, keepouts, clearances, buttons, contact modules, access zones, etc.

8. **Tests are required**
   - New logic must include relevant tests.
   - Geometry generators must have deterministic tests with known dimensions and validation outputs.
   - UI logic/state serialization must have unit tests.
   - Do not skip tests because geometry is “visual.”

9. **Research before complex implementation**
   - For OCCT operations, Flutter 3D viewport, STEP/STL/DXF export, KiCad imports, and controller APIs, inspect official docs and high-quality open-source examples first.
   - Record findings in `docs/27_RESEARCH_AND_REFERENCES.md` or a task-specific research note.
   - Do not blindly copy AGPL/GPL code into the project. Learn concepts, implement cleanly.

10. **Keep work traceable**
   - Update `WORKLOG.md` after each meaningful work session.
   - Update `TASKS.md` when completing, splitting, or discovering tasks.
   - Update docs when architecture changes.
   - Do not silently change core product direction.

## Coding standards

- Prefer small, testable modules.
- Prefer typed models and explicit schemas.
- Avoid “god classes.”
- Avoid hard-coded UI strings where localization may be needed.
- Do not mix UI state, semantic project model, and generated geometry.
- Do not put business rules only in widgets.
- Do not let the OCCT worker own product semantics; it should consume semantic geometry requests and return generated geometry/results.

## Documentation rules

When adding a subsystem:
1. Add/update a subsystem doc in `docs/`.
2. Add schema examples if relevant.
3. Add task items in `TASKS.md`.
4. Add tests.
5. Add or update worklog entry.

## User-facing language

The app can be localized later. Use simple human labels in default UX:
- “Посадка под стекло” instead of “Panel recess boolean operation”
- “Добавить USB-C” instead of “Create subtractive rounded rectangle prism”
- “Сгенерировать крепёж” instead of “Add retention structure”

Technical internal names can be English.

## Forbidden shortcuts

Do not:
- implement editable STL workflow as the core,
- expose raw OCCT object IDs to Flutter UI,
- couple face selection to fragile triangle IDs,
- flatten semantic features too early,
- create a giant global toolbar,
- skip undo/redo considerations,
- implement a feature without validation,
- add a dependency without checking license and maintenance status,
- copy code from AGPL/GPL projects into a non-compatible codebase.



<!-- FILE: TASKS.md -->


# TASKS.md — Implementation Roadmap

This is the living task backlog. Keep it updated.

## Phase 0 — Project bootstrap

- [ ] Create Flutter desktop project.
- [ ] Create repository structure.
- [ ] Add linting/formatting.
- [ ] Add test framework.
- [ ] Add basic CI.
- [ ] Create docs folder and copy this documentation pack.
- [ ] Add `WORKLOG.md` update discipline.
- [ ] Create initial command system skeleton.
- [ ] Create initial semantic project model skeleton.
- [ ] Create initial geometry service interface.
- [ ] Create mock geometry backend for UI development.

## Phase 1 — Architecture skeleton

- [ ] Implement `ProjectModel` with versioned JSON serialization.
- [ ] Implement `Feature` base model.
- [ ] Implement `FeatureGroup` base model.
- [ ] Implement `ComponentTemplate` base model.
- [ ] Implement `Enclosure` model.
- [ ] Implement `SelectionModel`.
- [ ] Implement undo/redo transaction system.
- [ ] Implement command registry.
- [ ] Implement parameter model with units, ranges, steps, defaults.
- [ ] Implement validation result model.

## Phase 2 — Flutter UI shell

- [ ] Viewport-first layout.
- [ ] Left icon rail.
- [ ] Right contextual inspector.
- [ ] Bottom compact hint/status panel.
- [ ] Top minimal toolbar.
- [ ] Collapsible/sliding panels.
- [ ] Theme system foundation.
- [ ] Context popover foundation.
- [ ] Command palette foundation.
- [ ] Navigation presets foundation.

## Phase 3 — Viewport MVP

- [ ] Research Flutter 3D rendering options.
- [ ] Implement orbit/pan/zoom.
- [ ] Implement view cube / orientation gizmo.
- [ ] Implement selection highlight.
- [ ] Implement ghost preview.
- [ ] Implement local workplane overlay.
- [ ] Implement grid overlay.
- [ ] Implement basic snapping visual hints.
- [ ] Implement focus/fit view.

## Phase 4 — OCCT worker MVP

- [ ] Research OCCT build/distribution for Linux/Windows/macOS.
- [ ] Create `occt_worker` CLI or local service.
- [ ] Define JSON protocol for geometry requests.
- [ ] Generate rounded box B-Rep.
- [ ] Generate shell/cavity for box.
- [ ] Generate preview mesh.
- [ ] Export STEP.
- [ ] Export STL.
- [ ] Return validation/warnings.
- [ ] Add geometry tests for known dimensions.

## Phase 5 — Enclosure-first MVP

- [ ] Create basic enclosure wizard.
- [ ] Box dimensions, wall thickness, corner radius.
- [ ] Lid type: none / top / bottom / screw lid.
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



<!-- FILE: WORKLOG.md -->


# WORKLOG.md

Append one entry per meaningful work session. Do not delete older entries.

## Entry template

```md
## YYYY-MM-DD — Short title

### Goal
What was attempted.

### Read before work
Docs/files reviewed before editing.

### Changes made
- File/path:
  - What changed.
  - Why.

### Tests run
- Command:
  - Result.

### Validation
- Geometry checked?
- Serialization checked?
- UI checked?
- Export checked?

### Known issues
- Issue:
  - Severity:
  - Next action:

### Next step
What should happen next.

### Notes for future Codex sessions
Anything important that would otherwise be forgotten.
```

---

## 2026-06-27 — Documentation pack created

### Goal
Create initial documentation package for Codex based on product discussion.

### Changes made
- Added AGENTS.md, TASKS.md, WORKLOG.md.
- Added detailed subsystem docs under `docs/`.
- Added templates and examples.

### Next step
Import docs into repository and start Phase 0 / Phase 1 tasks.



<!-- FILE: docs/00_PROJECT_VISION.md -->


# 00 — Project Vision

## One sentence

A minimal, visual, Flutter desktop app for designing precise 3D-printable enclosures, devices, inserts, slots, grips, cases, and accessories around semantic internal components, powered by OpenCascade.

## What the app is

The app is a maker-focused enclosure constructor. It should help users build useful, attractive, printable mechanical parts without learning traditional CAD workflows.

The app should feel like:
- “place a board and generate the case around it,”
- “choose the screen opening and create a glass recess,”
- “draw a line and get a support rib,”
- “pick a button group pattern and tweak spacing with a knob,”
- “select the finished device and generate a TPU case.”

## What the app is not

The app is not:
- a generic CAD clone,
- a mesh sculpting tool,
- a Dune3D/FreeCAD/Blender fork,
- a program where beginners must know sketches, booleans, shell operations, or B-Rep terminology.

Advanced CAD tools can exist later, but default product identity is generator-first.

## Main workflows

### 1. Enclosure-first

For quick simple boxes:
1. Create enclosure.
2. Set dimensions, wall thickness, corner radius.
3. Choose lid type.
4. Add simple holes, bosses, ports, vents.
5. Export STL/STEP.

### 2. Component-first

The core differentiator:
1. Create or import internal component templates.
2. Define board outline, holes, switches, ports, buttons, keepouts, contact areas.
3. Place component inside enclosure.
4. Automatically generate mounts, cutouts, supports, button holes, port openings, and warnings.
5. Refine case visually.

### 3. Accessory/case-first from finished device

After device design:
1. Select device/body.
2. Create TPU/hard/hybrid case, bumper, grip, dock, stand, or module.
3. Select covered/open sides.
4. Auto-propagate button/port/screen cutouts and pseudo-buttons.
5. Add grips, bumpers, stands, hinges, slots, stylus holders, etc.

## Product personality

- Minimal.
- Visual.
- Icon-first.
- Parameter-knob-friendly.
- Friendly for beginners.
- Powerful enough for makers.
- Futuristic is acceptable if it stays clean and readable.

## Long-term promise

The app should become a specialized mechanical workflow for electronics and maker devices:
- board to enclosure,
- enclosure to accessory,
- accessory to export,
- all through semantic templates and reusable generators.



<!-- FILE: docs/01_PRODUCT_RULES.md -->


# 01 — Product Rules

## Rule 1 — Use human tasks, not CAD verbs

Default UI actions should be human tasks:

Good:
- Create enclosure
- Add lid
- Place board
- Add USB-C
- Generate mounts
- Create button group
- Create glass recess
- Add support rib
- Generate slot
- Generate case
- Export insert DXF

Bad in default UI:
- Boolean subtract
- Extrude cut
- Shell
- TopoDS operation
- Loft surface
- Sketch constraint

## Rule 2 — Keep the viewport clean

The model must remain the center of the experience. Panels must be compact, collapsible, and contextual.

## Rule 3 — Semantic objects stay semantic

A button group remains a button group. A glass insert remains an insert. A case remains linked to the device envelope. Do not flatten unless user explicitly detaches/converts.

## Rule 4 — Good defaults first, advanced later

Most controls should start with presets:
- FDM normal
- FDM tight
- Resin precise
- TPU soft tight
- Hard shell clearance

Advanced numeric settings are available but collapsed.

## Rule 5 — Every generator must validate

Each generator must produce warnings:
- wall too thin,
- port does not reach wall,
- button plunger misses switch,
- support intersects keepout,
- case covers exposed face,
- undercut impossible for hard material,
- clearance too tight.

## Rule 6 — Outputs are generated

STL, STEP, DXF, SVG, 3MF are export outputs. They are not the semantic source of truth.

## Rule 7 — Respect printability

The app is not only visual. It must account for:
- wall thickness,
- clearance,
- bridge/overhang risk,
- support accessibility,
- layer direction hints,
- material profiles,
- part splitting.

## Rule 8 — Progressive disclosure

Beginner tools first. Advanced tools hidden.



<!-- FILE: docs/02_CORE_CONCEPTS.md -->


# 02 — Core Concepts

## Project

The saved semantic document. Contains units, settings, bodies, components, placements, features, generators, constraints, exports, and metadata.

## Enclosure

The main printable case/body. Usually has walls, thickness, lid, openings, bosses, inserts, texture, and internal supports.

## Device

A complete designed object: enclosure + internal components + panels + buttons + slots + visible user interface. A device can be used as source geometry for a case/accessory.

## Component Template

A semantic description of an internal object such as a PCB, button, battery, module, sensor, screen, connector, or contact board.

It stores mechanical meaning:
- outline,
- thickness,
- mounting holes,
- ports,
- switches,
- buttons,
- keepouts,
- mountable surfaces,
- forbidden clamp zones,
- access zones,
- contact/solder zones.

## Component Placement

An instance of a component template placed inside an enclosure/device.

## Feature

A semantic operation/object that generates geometry:
- USB-C cutout,
- screw boss,
- button hole,
- glass recess,
- texture patch,
- support rib,
- text label.

## Feature Group / Pattern Feature

A group of related repeated features that remains editable:
- button diamond,
- screw corner set,
- LED row,
- vent grid,
- magnet set,
- rib grid.

## Pattern

The rule used to place items:
- line,
- grid,
- square,
- diamond,
- circle,
- arc,
- path,
- contour/edge offset,
- symmetry/mirror.

## Placement Constraint

Human-friendly relation:
- free,
- centered,
- edge offset,
- between edges,
- symmetric,
- mirrored,
- aligned to component,
- projected from switch centers.

## Surface / Workplane

A semantic surface such as top lid, front wall, left wall, case back, slot cover, or insert face. It exposes a local 2D coordinate system for layout.

## Keepout

A protected volume or area where generated geometry must not intrude.

## Clearance / Fit Profile

Reusable rules for tolerances:
- FDM normal,
- FDM tight,
- sliding fit,
- friction fit,
- TPU tight,
- glass insert clearance.

## Insert

A separate flat or shaped piece that sits in a recess:
- glass,
- acrylic,
- metal panel,
- decorative plate,
- membrane,
- label plate.

## Recessed Panel

The recess/seat in a body surface that holds an insert or visually groups controls.

## Device Envelope

A semantic outer volume of a finished device used to generate cases/accessories. Includes protected/open zones, ports, buttons, screen, slots, vents, etc.

## Advanced Geometry

Low-level CAD shapes created by advanced tools. These should not replace semantic workflow unless user explicitly converts/detaches.



<!-- FILE: docs/03_ARCHITECTURE_OVERVIEW.md -->


# 03 — Architecture Overview

## Target stack

```text
Flutter UI
  ↓
Dart state / command / semantic project model
  ↓
GeometryService API
  ↓
OCCT worker process or backend adapter
  ↓
OpenCascade B-Rep generation
  ↓
Preview mesh / STEP / STL / DXF / 3MF
```

## Why this architecture

Flutter provides a clean, animated, minimal desktop UI. OpenCascade provides precise B-Rep geometry, fillets, chamfers, booleans, STEP, and reliable CAD-grade operations.

The semantic project model prevents the app from becoming a fragile mesh editor.

## Main modules

```text
lib/
  app/
  ui/
  viewport/
  project/
  features/
  components/
  patterns/
  geometry/
  export/
  validation/
  commands/
  input/
  themes/

native/
  occt_worker/

docs/
tests/
```

## Flutter side responsibilities

- App shell.
- Panels and inspectors.
- Viewport display.
- Selection.
- Command system.
- Project model editing.
- Serialization.
- Undo/redo.
- Parameter knobs and input mapping.
- Validation display.
- Sending geometry requests.

Flutter must not implement precise B-Rep operations.

## OCCT worker responsibilities

- Consume semantic geometry requests.
- Generate B-Rep bodies.
- Perform controlled booleans.
- Generate fillets/chamfers where requested by semantic generators.
- Tessellate preview mesh.
- Export STEP/STL.
- Extract 2D profiles for DXF export.
- Return warnings/errors.

The worker should not own user-facing UX decisions.

## GeometryService

A stable interface:

```text
generatePreview(project)
generateFeaturePreview(project, featureId)
validateGeometry(project)
exportSTEP(project, target)
exportSTL(project, target)
exportDXF(project, exportSpec)
getSelectableSurfaces(project)
```

## Worker process vs FFI

Start with a separate worker process:
- easier debugging,
- backend can crash without killing UI,
- testable independently,
- easier to replace later.

Direct FFI can be considered later.

## Undo/redo

Semantic edits create undo transactions. Continuous edits, knob drags, and repeated encoder steps should be grouped into one transaction after inactivity/release.

## Validation flow

Semantic validation happens before geometry:
- missing targets,
- impossible constraints,
- clearances,
- keepout conflicts.

Geometry validation happens after generation:
- failed boolean,
- invalid body,
- self-intersection risk,
- export failure.



<!-- FILE: docs/04_GEOMETRY_ENGINE_OCCT.md -->


# 04 — Geometry Engine: OpenCascade / OCCT

## Decision

OpenCascade is the primary geometry kernel. The app is B-Rep-first, not mesh-first.

## Why OCCT

The app needs:
- accurate enclosures,
- light rounding,
- proper fillets/chamfers,
- precise holes,
- STEP export,
- STL generated from exact geometry,
- controlled booleans,
- CAD-grade surfaces.

Mesh-first libraries are useful later for limited tasks, but not as the core.

## Worker architecture

`occt_worker` should be a standalone native executable or service.

Inputs:
- semantic project JSON,
- export request,
- feature preview request,
- validation request.

Outputs:
- preview mesh path/buffer,
- STEP/STL/DXF path,
- selectable surfaces metadata,
- warnings,
- errors,
- geometry stats.

## Critical rule

Do not expose raw OCCT topology as the product model. OCCT topology can change after boolean/fillet operations. Product semantics must remain stable.

## Surface IDs

Use semantic surface IDs:
- `enclosure.top_lid.outer`
- `enclosure.front_wall.outer`
- `slot.battery.cover.outer`
- `case.back.outer`

Do not store selected triangle IDs as permanent model references.

## Fillet/chamfer policy

Avoid a universal “fillet all edges” workflow in MVP.

Instead, each semantic generator should build controlled geometry:
- rounded box generator,
- rounded rectangular cutout,
- chamfered screw boss,
- rounded glass recess,
- smooth button cap,
- rib with filleted base.

This reduces unpredictable OCCT edge cases.

## Boolean policy

Use controlled boolean operations:
- base solid minus inner cavity,
- cutout prisms,
- boss unions,
- slot cavities,
- insert recesses.

Batch operations where possible. Keep feature order deterministic.

## Preview mesh

Preview mesh is generated from B-Rep with adjustable quality:
- fast preview during drag,
- high-quality preview after edit,
- export quality for STL.

## Geometry validation examples

- Body is valid solid.
- Minimum wall thickness.
- Cutout does not remove entire wall.
- Fillet radius fits local geometry.
- Component keepout not violated.
- Slot insertion direction is clear.
- Hard case does not contain impossible undercut unless split.

## Research tasks

Before implementing:
- Review OCCT shape creation.
- Review OCCT boolean operations.
- Review OCCT fillet/chamfer APIs.
- Review STEP export.
- Review STL mesh generation/tessellation.
- Review DXF generation strategy, either direct library or extracted curves written by own exporter.



<!-- FILE: docs/05_PROJECT_FILE_FORMAT.md -->


# 05 — Project File Format

## Goals

- Human-readable enough for debugging.
- Versioned.
- Stable across app updates.
- Semantic, not geometry-output-based.
- Supports migration.

## Suggested structure

```json
{
  "schema": "abyss-enclosure-project",
  "version": 1,
  "units": "mm",
  "projectName": "Device",
  "printerProfile": "fdm_04_normal",
  "bodies": [],
  "componentTemplates": [],
  "componentPlacements": [],
  "features": [],
  "featureGroups": [],
  "constraints": [],
  "exports": [],
  "theme": null
}
```

## Versioning

Every saved file has:
- schema name,
- integer version,
- optional app version,
- migration history optional.

Do not break old projects without migration.

## Units

Default: millimeters.

All dimensions stored explicitly with numeric values in project units. UI can display converted values later.

## IDs

Use stable IDs for semantic objects:
- `main_enclosure`
- `front_usb_c`
- `screen_glass_insert`
- `button_group_abxy`

Avoid exposing raw OCCT IDs or mesh indices.

## Generated output metadata

Project may store export presets, not exported binary data.

Example:
```json
{
  "exports": [
    {
      "id": "screen_glass_dxf",
      "type": "dxf_insert_profile",
      "targetFeatureId": "screen_glass",
      "settings": {
        "kerfCompensation": 0.1,
        "layers": true
      }
    }
  ]
}
```

## Theme

Theme should generally be user preference, not project geometry. Only store screenshot/render theme if needed for presentation export.

## Migration

When schema changes:
- write explicit migration function,
- test migration from previous sample projects,
- preserve semantic intent.



<!-- FILE: docs/06_FEATURE_SYSTEM.md -->


# 06 — Feature System

## Feature types

A feature is a semantic object that generates or affects geometry.

Operation categories:

```text
positive   — adds material
negative   — removes material
composite  — adds and removes
helper     — visible guide/keepout/reference, not exported as solid
modifier   — changes shape/style of another body/surface
exportable — produces manufacturing profile or part
```

## Base feature fields

```json
{
  "id": "usb_c_front",
  "type": "usb_c_cutout",
  "targetSurface": "main_enclosure.front.outer",
  "placement": {},
  "parameters": {},
  "operation": "negative",
  "validation": {}
}
```

## Feature lifecycle

1. Create semantic feature.
2. Show ghost preview.
3. User positions/configures.
4. Validate semantic constraints.
5. Generate geometry.
6. Validate geometry.
7. Commit undo transaction.

## Feature groups

Repeated elements must be grouped:
- button group,
- screw pattern,
- vent pattern,
- LED row,
- magnet set,
- support rib grid.

Groups store:
- item prototype,
- pattern,
- placement,
- overrides.

## Detach behavior

User can detach:
- one item from group,
- entire group into independent features,
- generated geometry into advanced editable body.

Detachment must be explicit and warn that parametric group behavior may be lost.

## Validation rules

Each feature should declare validation:
- required target surface,
- min/max dimensions,
- clearance profile,
- keepout interactions,
- wall thickness impact,
- printability warnings.

## UI rule

The inspector should show human controls, not internal fields.



<!-- FILE: docs/07_COMPONENT_TEMPLATE_SYSTEM.md -->


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



<!-- FILE: docs/08_COMPONENT_EDITOR_UX.md -->


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



<!-- FILE: docs/09_PATTERN_AND_LAYOUT_SYSTEM.md -->


# 09 — Pattern and Layout System

## Purpose

Enclosure design needs repeated elements. Users should not manually place every hole.

The pattern system creates editable feature groups.

## Pattern users

- Button groups.
- LEDs.
- Vent holes/slots.
- Screw holes.
- Magnets.
- Rubber feet.
- Text labels.
- Texture motifs.
- Support ribs.
- Case bumpers.

## Pattern types

- Line.
- Grid.
- Square.
- Diamond/rhombus.
- Circle.
- Arc.
- Custom path/curve.
- Edge/contour offset.
- Mirrored/symmetric.
- Equal spacing between selected edges.

## Core parameters

- Count.
- Spacing.
- Radius.
- Start angle.
- End angle.
- Group rotation.
- Per-item rotation.
- Edge offset.
- Path offset.
- Alignment.
- Distribution.
- Snap rules.
- Local offsets.

## Item rotation modes

- Fixed.
- Tangent to path.
- Radial outward.
- Toward center.
- Custom angle.
- Follow surface normal.

## Placement modes

- Free.
- Centered on face.
- Centered between edges.
- Edge offset.
- Symmetric.
- Mirrored from another group.
- Follow curve.
- Follow contour.
- Projected from component anchors/switch centers.

## Button group example

```json
{
  "type": "button_group",
  "pattern": {
    "type": "diamond",
    "count": 4,
    "spacingX": 14,
    "spacingY": 14,
    "itemRotation": "fixed"
  },
  "placement": {
    "mode": "centered",
    "targetSurface": "top_lid",
    "rotation": 0
  }
}
```

## Per-item overrides

Allow advanced overrides without losing group identity:

```json
{
  "overrides": {
    "item_2": {
      "offset": [1.0, 0.0],
      "rotation": 5
    }
  }
}
```

## UI controls

Pattern group inspector sections:
- Pattern.
- Item.
- Placement.
- Alignment/constraints.
- Clearance.
- Advanced.

Use compact knobs and icons.

## Tests

Test generated item positions for each pattern type.



<!-- FILE: docs/10_ENCLOSURE_AUTO_GENERATION.md -->


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

## Buttons/switches

For upward switches:
- project switch centers to lid/top surface,
- generate hole or plunger,
- check height/travel,
- warn if switch cannot be reached.

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



<!-- FILE: docs/11_MOUNTING_AND_RETENTION_SYSTEM.md -->


# 11 — Mounting and Retention System

## Purpose

Generate mounts, clips, pockets, rails, clamps, and retention features for components, especially components without screw holes.

## Main command

`Generate Mount`

Context:
- selected component placement,
- selected surface,
- selected slot,
- selected side button,
- selected module.

## Retention strategies

### Pocket mount
Component sits in a pocket.

### Friction fit
Component is held by controlled tight clearance.

### Screw clamp
Small clamp/wall/bridge with screw holds component down.

### Lid-retained
A protrusion or pad on the lid holds component in place.

### Rails / slide-in
Component slides into side rails with end stop.

### Snap retained
Printed snap/latch holds component.

## Safety zones

Mount generator must respect:
- forbidden clamp zones,
- solder/contact zones,
- wire exits,
- access areas,
- moving button areas,
- antenna zones.

## Side button case

User places a prepared button component on side wall and selects mounting generator.

Generated:
- opening,
- optional flush/recessed placement,
- side walls,
- clip/screw clamp,
- contact clearance,
- exterior recess with rounded edges.

## Flush/protruding/recessed modes

- Protruding: actuator sticks out.
- Flush: outer face aligns with wall exterior.
- Recessed: actuator sits below exterior surface with protective recess.

Parameters:
- recess depth,
- border width,
- corner radius,
- clearance,
- exterior chamfer.

## Validation

- Button actuator accessible.
- Contacts not covered.
- Wires have exit space.
- Clamp printable.
- Screw accessible.
- Component can be inserted/removed if intended.



<!-- FILE: docs/12_SLOT_AND_BAY_SYSTEM.md -->


# 12 — Slot and Bay System

## Purpose

Generate externally accessible slots, bays, battery compartments, cartridge holders, card slots, service compartments, and removable module pockets.

## Creation modes

### From component

Place battery/module/card template, then `Generate Slot`.

The app creates:
- cavity,
- insertion opening,
- guides,
- stops,
- clearance,
- access cutouts,
- retention,
- optional cover,
- optional contact module mount.

### Free slot

Draw approximate rectangle/contour, set:
- width,
- height,
- depth,
- radius,
- insertion direction,
- access side,
- retention type.

## Slot parameters

- Shape.
- Size.
- Depth.
- Corner radius.
- Clearance.
- Insertion direction.
- Open side.
- Rails/guides.
- End stops.
- Insertion chamfers.
- Retention.
- Access cutout.
- Cover type.

## Retention options

- None.
- Friction.
- Lid-retained.
- Printed spring.
- Latch.
- Spring + latch.
- Sliding cover.
- TPU cover.

## Printed springs

Keep simple and template-based:
- leaf spring,
- side flexible tab,
- push-out spring.

Warn about material:
- PLA poor for long-term flex,
- PETG/nylon/TPU better.

## Covers

Cover generator types:
- screw cover,
- hinge + latch cover,
- TPU friction plug,
- slider cover,
- snap cover.

## Access cutouts

- Semicircle.
- Oval.
- Side finger notch.
- Nail notch.
- Push-through window.
- Beveled thumb cut.

## Contact module integration

A contact module can be attached to the slot. It generates:
- holes,
- mount,
- keepout,
- alignment with inserted object contacts,
- wire/channel clearance.

## Validation

- Insert can enter.
- Insert can be removed.
- Retention does not block insertion.
- Contacts align.
- Cover does not collide.
- Hard plastic undercuts are handled.



<!-- FILE: docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md -->


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



<!-- FILE: docs/14_SURFACE_TEXTURE_SYSTEM.md -->


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



<!-- FILE: docs/15_CLEARANCE_AND_FIT_RULES.md -->


# 15 — Clearance and Fit Rules

## Purpose

Clearances are system-level concepts, not random offsets.

## Fit profiles

Examples:
- `fdm_tight`
- `fdm_normal`
- `fdm_loose`
- `resin_precise`
- `sliding_fit`
- `friction_fit`
- `tpu_soft_tight`
- `hard_shell_clearance`
- `glass_insert_clearance`

## Interaction types

- Pass-through hole.
- Button in hole.
- Sliding part.
- Friction fit.
- Snap fit.
- Lid lip.
- Glass insert.
- PCB standoff.
- Screw clearance.
- Heat insert hole.
- TPU stretch lip.
- Hard case shell.

## Profile fields

```json
{
  "id": "fdm_normal",
  "linearClearance": 0.3,
  "slidingClearance": 0.4,
  "holeExtraDiameter": 0.25,
  "glassEdgeClearance": 0.2,
  "buttonClearance": 0.35
}
```

## UI

Show simple presets first:
- Tight
- Normal
- Loose

Advanced:
- numeric overrides,
- per-feature overrides,
- material/process profile.

## Validation

Warn when:
- clearance too small for process,
- fit too loose for retention,
- TPU profile used on hard case,
- glass insert lacks adhesive/ledge area,
- moving button lacks enough gap.



<!-- FILE: docs/16_BUTTON_AND_PLUNGER_SYSTEM.md -->


# 16 — Button and Plunger System

## Purpose

Generate holes, caps, plungers, guide walls, U-cut flexible buttons, pseudo-buttons, and button textures.

## Scenarios

### Hole only
Switch already has cap. App creates opening.

### Full button/plunger
App creates external cap and internal stem that presses switch.

### U-cut button
Part of case surface flexes as a button.

### Case pseudo-button
TPU/hard case button cap presses original device button.

## Generated parts

- Cap geometry.
- Stem/plunger.
- Guide walls.
- Anti-wobble features.
- Travel stop.
- Clearance.
- Recess/ring/bezel.
- Tactile top texture.
- Optional labels/markings.

## Parameters

- Cap shape: circle, rectangle, rounded rectangle, oval, custom.
- Cap size.
- Cap height/protrusion.
- Flush/protruding/recessed.
- Stem width/diameter.
- Stem target point.
- Travel.
- Clearance.
- Guide style.
- Top texture.
- Material profile.

## U-cut parameters

- Cut shape.
- Flex arm length.
- Hinge thickness.
- Button island size.
- Travel limit.
- Material warning.

## Validation

- Stem reaches switch center.
- Stem does not collide with board/components.
- Travel is enough.
- Guide clearance is valid.
- Button can be inserted/printed.
- U-cut flex material appropriate.



<!-- FILE: docs/17_SWITCH_MAPPING_SYSTEM.md -->


# 17 — Switch Mapping System

## Purpose

Use switch centers from internal component templates to generate external controls.

## Workflow

1. Place board/component.
2. App projects switch centers to surface/lid.
3. User sees center markers.
4. User chooses:
   - generate holes,
   - generate full buttons/plungers,
   - create button group/pattern,
   - use as snap anchors.

## Projection

Switch center has:
- source component,
- local position,
- direction,
- actuation height,
- target surface,
- projected point,
- normal direction.

## Tools

- Show switch centers.
- Hide switch centers.
- Generate holes.
- Generate plungers.
- Convert to button group.
- Align button pattern to switch centers.
- Adjust cap pattern independently while stems target switches.

## Validation

- Projection reaches target surface.
- Surface normal compatible.
- Board/switch height known.
- Stem target clear.
- Switch travel/clearance valid.



<!-- FILE: docs/18_MARKING_AND_ANNOTATION_SYSTEM.md -->


# 18 — Marking and Annotation System

## Purpose

Add text, icons, ticks, scales, labels, and tactile markings.

## Types

### Text
- Raised.
- Engraved.
- On path.
- On arc.
- Aligned to feature.
- Around knob/encoder.

### Ticks/scales
- Encoder ticks.
- Potentiometer scale.
- Toggle switch positions.
- Slider scale.
- Numbered marks.

### Icons
- Power.
- Plus/minus.
- Arrows.
- Play/pause.
- USB.
- Bluetooth.
- Custom SVG later.

### Tactile markings
- Dots.
- Ridges.
- Button texture.
- Directional grooves.
- Raised nub.

## Parameters

- Text content.
- Font choice.
- Size.
- Depth/height.
- Spacing.
- Alignment.
- Curve/arc radius.
- Tick count.
- Long/short tick pattern.
- Engrave/raise.
- Clearance from functional features.

## DXF export

Markings on inserts/panels can export to `ENGRAVE` or `MARKING` layers.

## Validation

- Text remains printable/engraveable.
- Marks do not overlap holes unless intended.
- Marking depth does not weaken thin walls.



<!-- FILE: docs/19_SHAPE_MODIFIER_SYSTEM.md -->


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



<!-- FILE: docs/20_CASE_AND_ACCESSORY_SYSTEM.md -->


# 20 — Case and Accessory System

## Purpose

Generate cases, grips, bumpers, protective shells, docks, stands, covers, and external modules around an already-designed device.

## Workflow

1. Select device/body.
2. Create Case/Grip/Accessory.
3. Choose type/material.
4. Mark covered/open sides.
5. App generates base accessory from device envelope.
6. User adds grips, bumpers, stands, hinges, slots, modules.

## Case types

- TPU soft skin.
- Hard shell.
- Hybrid case.
- Bumper frame.
- Grip case.
- Rugged protective case.
- Flip/hinged cover.
- Dock/cradle.
- Add-on module shell.

## Device envelope

Generated from semantic device model:
- outer body,
- screen/glass zones,
- buttons,
- ports,
- speakers/mics,
- slots,
- vents,
- screw access,
- protected/no-cover zones.

## Open side rules

User can specify:
- front panel open,
- screen open,
- buttons open or pseudo-buttons,
- ports open,
- slot access open,
- sensor window open.

Case may wrap around edge with configurable lip.

## Automatic propagation

- Ports → cutouts/tunnels.
- Buttons → holes or pseudo-buttons.
- Screen → window/lip/frame.
- Speakers/mics → grilles/openings.
- Slots → access cutouts.
- Charging connector → cutout or dock feature.

## Materials

### TPU
- flexible lip,
- tight fit,
- pseudo-buttons,
- friction.

### Hard shell
- clearance,
- split shell,
- screws/clips/magnets,
- avoid impossible undercuts.

### Hybrid
- multi-part,
- hard back + soft bumper,
- separate exports.

## Add-ons

- Grips.
- Impact bumpers.
- Corner protectors.
- Feet.
- Kickstands.
- Hinges.
- Keyboard module.
- Stylus slot.
- Charging dock connector.
- Strap/lanyard loops.
- Clips/brackets.

## Validation

- Device can enter case.
- Hard case assembly possible.
- TPU stretch is plausible.
- Buttons still work.
- Ports accessible.
- Case does not cover no-case side.



<!-- FILE: docs/21_GRID_SNAP_SYMMETRY.md -->


# 21 — Grid, Snap, and Symmetry

## Grid

Each active face/workplane can have a grid:
- spacing,
- subdivisions,
- origin,
- rotation,
- visibility,
- snap strength.

## Snap targets

- Grid.
- Face centerlines.
- Edges.
- Corners.
- Feature centers.
- Component anchors.
- Switch centers.
- Mounting holes.
- Port centers.
- Slot edges.
- Keepout boundaries.
- Construction lines/curves.
- Symmetry axes.
- Other pattern items.
- Equal spacing guides.

## Snap modes

- Snap to grid.
- Snap to components.
- Snap to features.
- Snap to center.
- Snap to edge.
- Snap to equal spacing.
- Snap to tangent/path.
- Snap to projected switch centers.

## Visual hints

Snapping should show:
- target point,
- guide line,
- distance,
- centerline,
- equal spacing marker,
- projected anchor.

## Symmetry

Symmetry can be global or tool-local.

Symmetry sources:
- body center plane,
- face centerline,
- selected line,
- custom plane,
- another feature/group.

Modes:
- live mirrored creation,
- linked mirrored feature,
- independent mirrored copy,
- mirror pattern group,
- mirror component placement,
- mirror case/grip feature.

## Semantic storage

Symmetry should be stored as semantic relation, not flattened copy, unless user detaches.

## UI

- Symmetry toggle.
- Axis/plane visible in viewport.
- Quick popover for symmetry options.
- Warnings when target is impossible.



<!-- FILE: docs/22_UI_NAVIGATION_LAYOUT.md -->


# 22 — UI Navigation and Layout

## UI identity

Viewport-first, icon-first, context-first.

The user dislikes large text blocks, huge text buttons, clutter, and too much information on screen.

## Main layout

```text
Top compact toolbar
Left icon rail
Center 3D viewport
Right contextual inspector
Bottom compact hints/status
```

## Always visible

- Viewport/model.
- Compact top bar.
- Left icon rail.
- View cube/orientation gizmo.

## Visible when needed

- Right inspector.
- Hints/warnings.
- Object tree.
- Export panel.
- Advanced tools.

## Left icon rail categories

- Enclosure.
- Components.
- Ports.
- Buttons.
- Mounts.
- Slots.
- Glass/inserts.
- Textures.
- Markings.
- Cases/grips.
- Supports.
- Advanced.

## Right inspector

Changes by selection:
- enclosure settings,
- component settings,
- feature settings,
- pattern settings,
- texture settings,
- case settings,
- parameter banks.

Simple settings first. Advanced collapsed.

## Bottom hints

Short, contextual:
- “Выберите грань для размещения кнопок.”
- “USB-C не доходит до стенки.”
- “4 стойки созданы по отверстиям платы.”

No long documentation in workspace.

## Camera controls

Default suggestion:
- Left click: select / drag object.
- Right drag or middle drag: orbit.
- Wheel: zoom.
- Shift + right/middle drag: pan.
- F: focus selection.
- Home: fit whole model.
- Double click: select/focus.
- View cube for standard views.

Add navigation presets:
- app default,
- Blender-like,
- Fusion-like,
- FreeCAD-like,
- touchpad-friendly.

## View cube

Required:
- top,
- front,
- left,
- right,
- back,
- bottom,
- isometric,
- home/fit.

## Animations

Allowed:
- sliding panels,
- hover previews,
- ghost generation preview,
- snap highlight,
- subtle futuristic motion.

Never sacrifice speed/clarity for animation.



<!-- FILE: docs/23_PARAMETER_KNOBS_INPUT_MAPPING.md -->


# 23 — Parameter Knobs and Input Mapping

## Purpose

Parameter editing should feel fast, tactile, and minimal.

The main editing method should often be a compact knob/value control, not giant sliders or text fields.

## Parameter knob behavior

- Hover/select parameter.
- Mouse wheel changes value.
- Drag rotates/scrubs.
- Small numeric popup appears.
- Click numeric value to type exact value.
- Shift = fine step.
- Ctrl/Alt = coarse/snap step.
- Double click = reset default.
- Right click = quick settings.

## Step system

Each numeric parameter defines:
- normal step,
- fine step,
- coarse step,
- min/max,
- unit,
- precision,
- snap values if any.

Examples:
- length: normal 0.1/0.25 mm, fine 0.05 mm, coarse 1 mm.
- angle: normal 1°, fine 0.1°, coarse 15°.
- count: step 1.
- percent: normal 1%, fine 0.1%, coarse 5–10%.

Steps are configurable globally, per parameter type, per tool, and per controller profile.

## Keyboard-emulated controllers

MIDI is not priority now.

Most custom controllers emulate keyboard keys and mouse clicks. Support this first.

Core commands:
- `activeParameterIncrease`
- `activeParameterDecrease`
- `nextParameter`
- `previousParameter`
- `selectSlotTop`
- `selectSlotLeft`
- `selectSlotBottom`
- `selectSlotRight`
- `nextBank`
- `previousBank`
- `selectBank1...N`
- `fineMode`
- `coarseMode`
- `resetParameter`
- `openNumericInputForActiveParameter`

## Focused parameter

User selects active parameter; physical encoder changes it.

A small HUD shows:
- parameter name,
- icon,
- value,
- unit,
- step mode.

## Parameter banks and diamond slots

A compact 4-slot diamond can represent current active parameters:

```text
        Top
Left          Right
       Bottom
```

Keyboard mapping:
- W selects top.
- A selects left.
- S selects bottom.
- D selects right.
- Shift switches temporary bank.
- Ctrl switches alternate bank.
- Number keys choose banks directly.

## Example context banks

Button group bank:
- spacing,
- diameter,
- recess depth,
- rotation.

Recess bank:
- depth,
- margin,
- corner radius,
- side curvature.

Texture bank:
- scale,
- depth,
- angle,
- fade width.

Grip bank:
- height,
- radius,
- softness,
- symmetry.

## Hardware

Support later through the same command system:
- Stream Deck,
- QMK/VIA keyboard/encoder pads,
- custom HID/serial controllers,
- MIDI later.

## Undo grouping

Continuous knob/encoder changes should become one undo transaction after inactivity/release.

## Conflict handling

When typing in text/numeric fields, global shortcut capture should pause unless controller mode explicitly captures it.



<!-- FILE: docs/24_CONTEXT_POPOVERS_THEMES.md -->


# 24 — Context Popovers and Visual Themes

## Context popovers

Right-click / long press / parameter menu opens compact popovers for local quick settings.

Popovers are not replacements for the inspector. They prevent clutter.

## Parameter popover

- Assign/reassign keyboard/controller.
- Set normal/fine/coarse step.
- Reset to default.
- Pin to slot/bank.
- Snap settings.
- Unit/precision.

## Button/group popover

- Pattern preset.
- Symmetry.
- Detach item.
- Generate plunger.
- Hole only / cap / full button.
- Clearance quick settings.

## Face/workplane popover

- Add contextual feature.
- Set active workplane.
- Grid settings.
- Snap settings.
- Symmetry plane.
- Apply texture.
- Create recess.
- Add marking.

## Component popover

- Generate mounts.
- Generate cutouts.
- Show/hide.
- Lock placement.
- Show switch centers.
- Show anchors/keepouts.
- Edit component template.

## Generated feature popover

- Enable/suppress.
- Duplicate.
- Mirror.
- Pattern.
- Convert to advanced geometry.
- Export related DXF/part if applicable.

## Visual themes

Theme is user preference, not project geometry.

Suggested themes:
- Minimal Dark.
- Minimal Light.
- Futuristic Dark.
- Workshop.
- High Contrast.

Theme affects:
- UI colors,
- accent color,
- highlights,
- ghost preview,
- warning badges,
- grid,
- viewport background,
- surface shading.

## Style rules

- Minimal.
- Clean.
- Subtle glow/highlight allowed.
- Thin icons.
- Compact labels.
- Avoid game-like clutter.



<!-- FILE: docs/25_EXPORT_PIPELINE.md -->


# 25 — Export Pipeline

## Export types

MVP:
- STL.
- STEP.
- Project JSON.

Important:
- DXF for glass/inserts/panels/covers.

Later:
- 3MF.
- SVG.
- exploded assembly / BOM.
- screenshots/renders.

## Source of export

Exports are generated from semantic model through geometry backend.

Do not use exported STL as source for future editing.

## STL

Generated from B-Rep tessellation.

Options:
- preview quality,
- print quality,
- high quality,
- unit metadata via sidecar if needed.

## STEP

Export B-Rep model for CAD interoperability.

Options:
- entire device,
- individual parts,
- selected body,
- case/accessory part.

## DXF

Use for:
- glass insert contour,
- acrylic panel,
- metal faceplate,
- slot cover,
- labels,
- laser/CNC cutting.

Layers:
- `OUTER_CUT`
- `INNER_CUT`
- `ENGRAVE`
- `MARKING`
- `CONSTRUCTION`
- `NOTES`

DXF settings:
- kerf compensation,
- tool diameter,
- dogbone/corner relief,
- tolerance,
- closed contours,
- preserve arcs where possible,
- optional reference marks.

## 3MF later

Useful for:
- multi-part export,
- colors/materials,
- units,
- print profiles.

## Export validation

Before export:
- body validity,
- closed solids,
- minimum thickness,
- insert profiles closed,
- no missing generated geometry,
- no suppressed required features.

## File naming

Use predictable names:
- `project_body_main.step`
- `project_enclosure_base.stl`
- `project_lid.stl`
- `project_screen_glass.dxf`
- `project_case_tpu.stl`



<!-- FILE: docs/26_TESTING_AND_QUALITY.md -->


# 26 — Testing and Quality

## Testing philosophy

If it changes geometry, serialization, validation, or UI state, test it.

## Test categories

### Unit tests

- Project model serialization.
- Feature parameter validation.
- Pattern positions.
- Clearance profile calculations.
- Command system.
- Undo/redo grouping.
- Input mapping.
- Step system.
- Theme selection.

### Geometry tests

For each generator:
- create known input,
- run geometry backend,
- assert dimensions,
- assert output validity,
- assert warnings/errors,
- export test if relevant.

Use deterministic test fixtures.

### Golden/snapshot tests

- Semantic JSON before/after migration.
- Generated pattern item positions.
- DXF layer contents.
- Validation outputs.

### UI tests

- Inspector changes with selection.
- Context popovers show correct actions.
- Parameter knob updates model.
- Keyboard-emulated controller commands change active parameter.
- Panels collapse/expand.

### Integration tests

- Component template → placed component → generated enclosure.
- Board with switches → generated button plungers.
- Screen window → glass recess → DXF export.
- Device → TPU case → propagated cutouts.
- Slot → cover → access cutout.

## CI expectations

- Format check.
- Static analysis.
- Unit tests.
- Worker tests if environment supports.
- Basic export tests.

## Geometry failure policy

Geometry operations may fail. The app must:
- return clear error,
- not crash UI,
- keep semantic model safe,
- allow user to adjust parameters.

## Performance checks

Test:
- many cutouts,
- vent grids,
- texture patches,
- large pattern groups,
- repeated knob edits,
- worker regeneration latency.

## Worklog

Every implemented feature must record:
- what was changed,
- tests run,
- known issues.



<!-- FILE: docs/27_RESEARCH_AND_REFERENCES.md -->


# 27 — Research and References

Use this file to record research done by Codex/developers before implementation.

## Research requirements

Research before implementing:
- OCCT operations.
- Flutter 3D viewport/rendering.
- STEP/STL/DXF export.
- KiCad footprint/board import.
- Input mapping and Stream Deck/custom controllers.
- Licensing of libraries.
- Existing open-source UX references.

## License caution

Do not copy AGPL/GPL code into incompatible project code.

Ideas and algorithms can be studied. Implementation must be original unless license-compatible.

Be careful with:
- slicer infill code,
- KiCad libraries,
- external model libraries,
- controller SDKs.

## Potential reference areas

### CAD kernels / geometry
- OpenCascade documentation and examples.
- FreeCAD source as conceptual reference, respecting license.
- build123d/CadQuery as conceptual high-level API references.

### ECAD/MCAD
- KiCad file formats.
- KiCad StepUp workflow concepts.
- KiCad 3D model libraries.

### UI
- Fusion/Onshape for viewport conventions.
- Blender/FreeCAD for navigation preset references.
- Modern 3D editor UI patterns.

### Slicers
- PrusaSlicer/Cura/Slic3r only as conceptual references for patterns.
- Do not copy AGPL code unless project licensing intentionally allows it.

### Hardware input
- QMK/VIA keyboard/encoder mapping concepts.
- Stream Deck command concepts.
- HID/serial keyboard-emulated workflows.

## Research note format

Use `templates/RESEARCH_NOTE_TEMPLATE.md`.



<!-- FILE: docs/28_IMPLEMENTATION_PLAN.md -->


# 28 — Implementation Plan

## Strategy

Build the product in vertical slices. Do not implement every subsystem before seeing a working enclosure flow.

## First vertical slice

Goal: create a simple precise rounded enclosure with a component board and generated standoffs/cutouts.

Includes:
- semantic project model,
- Flutter shell,
- mock viewport or simple viewer,
- OCCT worker generating rounded box,
- component template with mounting holes and USB-C,
- auto standoffs,
- USB-C cutout,
- export STL/STEP.

## Second vertical slice

Goal: switch centers to button holes/plungers.

Includes:
- switch mapping,
- projected markers,
- button group pattern,
- simple plunger/hole generation,
- validation.

## Third vertical slice

Goal: glass insert and DXF export.

Includes:
- screen window,
- glass recess,
- ledge,
- insert contour generation,
- DXF layers.

## Fourth vertical slice

Goal: input/parameter polish.

Includes:
- parameter knobs,
- focused parameter,
- keyboard-emulated controller steps,
- right-click popovers,
- undo grouping.

## Fifth vertical slice

Goal: case/accessory generation.

Includes:
- device envelope,
- TPU case,
- open front,
- propagated cutouts,
- pseudo-buttons.

## Avoid big-bang development

Do not build:
- entire advanced CAD mode first,
- massive UI before geometry works,
- all texture/shape systems before basic enclosure is solid,
- import system before manual templates work.

## MVP definition

A useful MVP can:
1. Create simple precise enclosure.
2. Create/import manual component template.
3. Place board.
4. Generate standoffs.
5. Generate port cutout.
6. Generate button holes or simple plungers.
7. Export STL/STEP.
8. Export DXF for a simple glass/acrylic insert.
9. Save/load project.
10. Validate common mistakes.



<!-- FILE: docs/29_CODING_STANDARDS.md -->


# 29 — Coding Standards

## General

- Prefer clarity over cleverness.
- Keep modules small.
- Use explicit typed models.
- Write tests.
- Keep UI, model, geometry, and export concerns separate.

## Dart/Flutter

- Use immutable state where practical.
- Keep widgets thin.
- Put business rules in services/models, not widget build methods.
- Avoid hard-coded strings in core widgets.
- Avoid direct file/network/native calls in widgets.
- Use providers/controllers consistently.

## Native/OCCT

- Keep geometry functions deterministic.
- Wrap OCCT errors and return structured errors.
- Do not throw raw backend exceptions across protocol boundary.
- Keep geometry request/response schema stable.
- Add fixtures for generated bodies.

## JSON schemas

- Include version.
- Include units.
- Use stable IDs.
- Avoid storing generated geometry.
- Write migrations.

## Commands

Every command should declare:
- ID,
- label,
- icon,
- context availability,
- input bindings,
- undo behavior,
- parameter effects.

## Parameters

Every numeric parameter should declare:
- unit,
- default,
- min/max,
- normal/fine/coarse step,
- precision,
- validation.

## Dependencies

Before adding dependency:
- check license,
- check maintenance,
- check platform support,
- document why needed.

## Error handling

Errors should be visible and actionable:
- what failed,
- why likely failed,
- what user can change.

## Performance

- Debounce geometry regeneration during drags.
- Use low-quality preview during continuous edits.
- Generate high-quality geometry after edit commit.
- Keep UI responsive while worker runs.

## Accessibility basics

- Keyboard navigable.
- High contrast theme.
- Tooltips.
- Do not rely only on color for warnings.



<!-- FILE: docs/30_ADVANCED_CAD_MODE.md -->


# 30 — Advanced CAD Mode

## Purpose

Provide escape hatches for professional users and edge cases without harming beginner UX.

## Default state

Advanced mode is hidden/collapsed.

## Tools later

- Sketch.
- Extrude.
- Cut.
- Revolve.
- Sweep.
- Loft.
- Boolean.
- Fillet.
- Chamfer.
- Split body.
- Offset face/surface where safe.

## Rules

- Advanced geometry should not be required for core workflows.
- Converting semantic feature to advanced geometry must warn that generator behavior may be lost.
- Advanced operations must still be tracked in project model if possible.
- Maintain undo/redo.
- Maintain validation.
- Keep advanced UI separate from beginner tool rail.

## Use cases

- Manual small fix.
- Custom bracket.
- Custom decorative cut.
- Edge-case connector.
- Custom accessory detail.
