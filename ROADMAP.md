# ROADMAP.md

This is the working roadmap for safe 1-2 day implementation chunks.

Each chunk should end with:
- local validation,
- updated `releases/latest/windows` bundle when the app changed,
- updated `WORKLOG.md`,
- commit and push to `origin/main`.

Manual Windows build to open:

```text
C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe
```

The release folder is local-only and ignored by Git. Keep the whole folder together; the `.exe` needs the adjacent Flutter runtime files and `data/` folder.

## Chunk Status

- [x] R0 — Roadmap + Latest EXE
- [x] M1 — Semantic Core
- [x] M2 — Commands + Undo
- [x] M3 — Usable Shell
- [x] M4 — Viewport MVP
- [x] M5 — First Geometry Slice
- [x] M6 — Parameter Model
- [x] M7 — Enclosure Parameter Inspector
- [x] M8 — Parameter Undo/Redo

---

## R0 — Roadmap + Latest EXE

### Goal
Make project progress inspectable and make the latest Windows app easy to launch by hand.

### Tasks
- [x] Create `ROADMAP.md`.
- [x] Add `tools/build_latest_windows.ps1`.
- [x] Ignore generated local releases.
- [x] Document latest Windows app path.
- [x] Record the workflow in `WORKLOG.md`.

### Done Criteria
- `ROADMAP.md` defines the next safe chunks.
- `tools/build_latest_windows.ps1` creates `releases/latest/windows`.
- `releases/latest/windows/shell_case_easy_maker.exe` exists after the script runs.
- Generated release files do not appear in Git status.

### Tests
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`
- `git diff --check`

### Poke Checklist
- Open `releases/latest/windows/shell_case_easy_maker.exe`.
- Confirm the app launches without a console-only failure.
- Confirm the shell shows the top toolbar, left icon rail, viewport, inspector, and bottom status bar.

---

## M1 — Semantic Core

### Goal
Make the editable project model typed, versioned, and ready for feature/component generators.

### Tasks
- [x] Split semantic model into focused files for project, enclosure, features, feature groups, component templates, and placements.
- [x] Add stable IDs and schema/version handling.
- [x] Add typed JSON serialization/deserialization for all M1 models.
- [x] Add project migration entrypoint, even if only version 1 exists.
- [x] Add unit tests for round-trips and malformed/minimal JSON defaults.

### Done Criteria
- The app still starts with the sample semantic project.
- Models do not store generated mesh, STL, or OCCT topology as editable state.
- Serialization tests cover the default sample project and at least one component template.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1` if runtime behavior changed

### Poke Checklist
- Launch latest Windows app.
- Confirm the inspector still shows enclosure dimensions and feature/component counts.

---

## M2 — Commands + Undo

### Goal
Create the command and undo foundations needed for safe semantic editing.

### Tasks
- [x] Implement a command registry with stable command IDs, labels, icons, scopes, and availability checks.
- [x] Add command context for active selection, active surface, and advanced mode.
- [x] Add undo/redo transaction model.
- [x] Add continuous transaction grouping skeleton for future knob/drag edits.
- [x] Add tests for availability and undo/redo behavior.

### Done Criteria
- Commands are metadata-driven, not hard-coded only in widgets.
- Advanced commands are hidden unless advanced mode is enabled.
- Undo/redo tests prove semantic state can move backward and forward.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`

### Poke Checklist
- Launch latest Windows app.
- Confirm toolbar buttons remain visible and do not overflow at the default window size.

---

## M3 — Usable Shell

### Goal
Make the current shell useful enough for manual exploration of semantic project state.

### Tasks
- [x] Add selection model.
- [x] Connect selected object/surface to the contextual inspector.
- [x] Add basic project JSON save/load service.
- [x] Add object summary/tree or compact project browser.
- [x] Add widget tests for inspector context changes.

### Done Criteria
- Selecting semantic objects changes inspector content.
- Save/load preserves the semantic project model.
- UI stays viewport-first and avoids large permanent text panels.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click/select available semantic items.
- Confirm inspector and status hint update clearly.

---

## M4 — Viewport MVP

### Goal
Research and implement the first interactive viewport behavior without coupling Flutter to OCCT internals.

### Tasks
- [x] Research Flutter desktop viewport options and record findings.
- [x] Choose the first viewer approach for mock/preview geometry.
- [x] Add orbit/pan/zoom interaction model.
- [x] Add selection highlight and ghost preview state.
- [x] Add tests for viewport controller state where practical.

### Done Criteria
- Viewport interaction is separated from geometry generation.
- Selection uses semantic surface/object IDs, not triangle IDs.
- Research note records license and maintenance considerations.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Try orbit/pan/zoom.
- Confirm the viewport remains readable and controls do not overlap.

---

## M5 — First Geometry Slice

### Goal
Start the path toward real generated geometry with a worker protocol and rounded enclosure plan.

### Tasks
- [x] Research OCCT build/distribution and record findings.
- [x] Define initial `GeometryService` request/response protocol.
- [x] Add `occt_worker` directory skeleton.
- [x] Add deterministic rounded enclosure generation plan and validation expectations.
- [x] Keep mock backend usable while worker is incomplete.

### Done Criteria
- Flutter still depends on `GeometryService`, not OCCT types.
- Worker protocol consumes semantic requests and returns generated results/warnings.
- No editable project data is stored as generated mesh/B-Rep.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- Worker tests if an executable/test harness exists

### Poke Checklist
- Launch latest Windows app.
- Confirm mock preview still works while worker integration is incomplete.

---

## M6 — Parameter Model

### Goal
Create reusable typed parameter schemas before generator UIs and geometry
commands start consuming raw maps of numbers.

### Tasks
- [x] Add parameter kinds, definitions, ranges, options, and issues.
- [x] Add defaults and normalization rules.
- [x] Add range/choice/type validation.
- [x] Add the first rounded enclosure parameter schema.
- [x] Add unit tests for defaults, snapping, validation, and JSON round-trips.

### Done Criteria
- Generator parameters can declare units, ranges, steps, defaults, and choices.
- Validation reports bad raw values before geometry generation.
- The model stays UI-neutral and does not store generated geometry.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Confirm existing shell, browser, and mock viewport still behave normally.
- No new parameter UI is expected in this chunk.

---

## M7 — Enclosure Parameter Inspector

### Goal
Wire the rounded enclosure parameter schema into the contextual inspector so
the first semantic body can be edited without exposing low-level CAD actions.

### Tasks
- [x] Add copy/update helpers for semantic enclosure/project state.
- [x] Add an adapter between `Enclosure` fields and the rounded enclosure
      parameter schema.
- [x] Add compact inspector controls for width, depth, height, wall thickness,
      corner radius, and lid type.
- [x] Refresh mock preview/validation futures when parameters change.
- [x] Make mock geometry preview bounds use semantic enclosure dimensions.
- [x] Add model, protocol, and widget tests for parameter edits.

### Done Criteria
- Editing enclosure parameters changes the semantic `ProjectModel`, not
  generated mesh state.
- Flutter still depends on `GeometryService` and semantic IDs, not OCCT
  internals.
- Mock viewport proportions and mock geometry bounds react to changed enclosure
  dimensions.
- No advanced CAD operations are exposed in the default workflow.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `main_enclosure` in the project browser.
- Change width/depth/height/wall/radius in the inspector and press Enter.
- Confirm the size row updates and the center mockup changes proportions.
- Change lid type between no lid and top screw lid.

---

## M8 — Parameter Undo/Redo

### Goal
Route first enclosure parameter edits through the existing semantic undo stack
so manual parameter exploration is reversible.

### Tasks
- [x] Make `UndoHistory<ProjectModel>` own the editable shell project state.
- [x] Commit enclosure parameter edits as semantic undo transactions.
- [x] Enable toolbar undo/redo according to real history state.
- [x] Restore project state and refresh mock preview/validation on undo/redo.
- [x] Add widget coverage for edit, undo, and redo.

### Done Criteria
- Undo/redo changes semantic `ProjectModel` snapshots, not preview-only state.
- Empty/no-op parameter submissions do not create undo entries.
- Toolbar command availability reflects `canUndo` and `canRedo`.
- Mock viewport and inspector refresh after undo/redo.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `main_enclosure`.
- Change width to a clearly different value and press Enter.
- Click undo in the top toolbar and confirm the size returns.
- Click redo and confirm the edited size returns.
