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
- [x] M9 — Project Open/Save
- [x] M10 — Unsaved Changes Guard
- [x] M11 — First Generator Command
- [x] M12 — Place Component Command
- [x] M13 — USB-C Cutout Command

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

---

## M9 — Project Open/Save

### Goal
Make edited semantic projects persistable through native desktop open/save file
dialogs.

### Tasks
- [x] Check native file dialog dependency license and maintenance source.
- [x] Add `file_selector` for desktop open/save dialogs.
- [x] Add a small project file dialog service seam for tests and UI.
- [x] Add toolbar open/save project commands.
- [x] Save the current semantic `ProjectModel` to `.enclosure.json`.
- [x] Open `.enclosure.json` into shell state and reset undo history.
- [x] Add unit/widget tests for extension handling, save, and open.

### Done Criteria
- File commands read/write project JSON, not generated geometry.
- Dialog code is isolated from JSON encoding/decoding.
- Widget tests use fakes instead of opening native dialogs.
- Opening a project resets undo history for the loaded file.

### Tests
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `main_enclosure`, change width, and press Enter.
- Click save in the top toolbar and choose a `.enclosure.json` file.
- Change width again without saving.
- Click open and choose the saved file.
- Confirm the saved width returns and undo is reset for the opened file.

---

## M10 — Unsaved Changes Guard

### Goal
Prevent accidental loss of unsaved semantic edits when opening another project.

### Tasks
- [x] Track a persisted project fingerprint in the workspace shell.
- [x] Show dirty status when current semantic project differs from persisted
      state.
- [x] Prompt before opening another project while dirty.
- [x] Cancel open without invoking the native file picker when the user backs
      out.
- [x] Allow confirmed open to discard current edits and load the selected file.
- [x] Add widget tests for dirty cancel and dirty confirm flows.

### Done Criteria
- Dirty tracking compares semantic project JSON, not preview or geometry data.
- Saving updates the clean baseline.
- Opening a file updates the clean baseline and resets undo history.
- Canceling the dirty prompt preserves the current project and does not call
  the file dialog.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Change an enclosure parameter without saving.
- Click open and press cancel in the warning dialog.
- Confirm the current edited value remains.
- Click open again, confirm, pick another project, and confirm it loads.

---

## M11 — First Generator Command

### Goal
Make the left tool rail execute the first semantic generator command while
keeping unwired future tools visible but disabled.

### Tasks
- [x] Add a small command action map in the workspace shell.
- [x] Wire `enclosure.create` from the left rail.
- [x] Add a create-enclosure dialog powered by the rounded enclosure parameter
      schema.
- [x] Commit created/updated enclosure state through the semantic undo history.
- [x] Disable rail commands that are available by context but not implemented
      yet.
- [x] Add widget tests for create, cancel, undo, and disabled future commands.

### Done Criteria
- Clicking the left `Корпус` tool opens a parameter dialog.
- Confirming the dialog updates the semantic `ProjectModel`.
- Canceling the dialog makes no project change and creates no undo entry.
- Undo restores the previous enclosure dimensions.
- Unimplemented rail commands do not run empty no-op callbacks.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click the left `Корпус` button.
- Change width to a visibly different value and click `Создать`.
- Confirm the inspector shows the new enclosure size.
- Click undo and confirm the original size returns.
- Click another left rail icon and confirm nothing unexpected opens.

---

## M12 — Place Component Command

### Goal
Make the second left rail generator command create semantic component
placements from existing component templates.

### Tasks
- [x] Add a semantic project helper for replacing/appending component
      placements by stable ID.
- [x] Wire `component.place` from the left rail when component templates exist.
- [x] Make the command available from workspace and enclosure context.
- [x] Add a compact placement dialog with template, X/Y/Z, mounting side, and
      lock controls.
- [x] Commit new placement state through the semantic undo history.
- [x] Coerce selection back to workspace if undo removes the selected object.
- [x] Add unit/widget tests for append/replace, create, cancel, undo, and
      no-template disabled state.

### Done Criteria
- Clicking `Компоненты` opens a placement dialog when templates exist.
- Confirming the dialog appends a semantic `ComponentPlacement`.
- The new placement appears in the project browser and inspector.
- Canceling the dialog makes no project change and creates no undo entry.
- Undo removes the new placement and leaves selection valid.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click `Компоненты` in the left rail.
- Change X to a visible value such as `24` and click `Разместить`.
- Confirm a new component placement appears in the browser.
- Confirm the inspector shows position `24 x 0 x 4 mm`.
- Click undo and confirm the new placement disappears.

---

## M13 — USB-C Cutout Command

### Goal
Make the first surface-based generator command add a semantic USB-C cutout to
the selected enclosure face.

### Tasks
- [x] Add a semantic project helper for replacing/appending features by stable
      ID.
- [x] Wire `port.add_usb_c` from the left rail only when a surface is selected.
- [x] Add a compact USB-C dialog for width, height, corner radius, and
      clearance profile.
- [x] Commit the new `usb_c_cutout` feature through the semantic undo history.
- [x] Select the created feature and keep undo selection valid.
- [x] Add unit/widget tests for append/replace, disabled-without-surface,
      create, cancel, and undo behavior.

### Done Criteria
- `Порты` stays disabled without an active surface.
- Selecting `Front wall` enables `Порты`.
- Confirming the dialog appends a semantic `SemanticFeature` with
  `type: usb_c_cutout`.
- Canceling the dialog makes no project change and creates no undo entry.
- Undo removes the new feature and leaves selection valid.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Front wall` in the project browser.
- Click `Порты` in the left rail.
- Change width to `12` and click `Добавить`.
- Confirm `usb_c_cutout_2` appears in the feature list/inspector.
- Click undo and confirm the new USB-C feature disappears.
