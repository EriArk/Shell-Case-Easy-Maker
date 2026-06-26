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
