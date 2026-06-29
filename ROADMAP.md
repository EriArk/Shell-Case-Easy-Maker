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
- [x] M14 — Button Group Command
- [x] M15 — Glass Recess Command
- [x] M16 — Mount Generation Command
- [x] M17 — Feature Group Viewport Markers
- [x] M18 — Button Group Viewport Markers
- [x] M19 — Surface Feature Viewport Markers
- [x] M20 — Feature Parameter Inspector Editing
- [x] M21 — Feature Group Parameter Inspector Editing
- [x] M22 — Reusable Pattern Layout Engine
- [x] M23 — Reusable Standoff Source Layout
- [x] M24 — First Semantic Validation Warnings
- [x] M25 — Validation Details + Placement Bounds
- [x] M26 — Validation Issue Target Selection

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

---

## M14 — Button Group Command

### Goal
Make the second surface-based generator command create an editable button
pattern group instead of flattening repeated buttons into independent holes.

### Tasks
- [x] Add a semantic project helper for replacing/appending feature groups by
      stable ID.
- [x] Wire `button.create_group` from the left rail only when a surface is
      selected.
- [x] Add a compact button group dialog for layout, count, diameter, spacing,
      and button mode.
- [x] Store the result as a `FeatureGroup` with pattern and item prototype
      data.
- [x] Commit the new group through semantic undo history.
- [x] Improve feature group inspector details.
- [x] Add unit/widget tests for append/replace, inspector details, disabled
      state, create, cancel, and undo behavior.

### Done Criteria
- `Кнопки` stays disabled without an active surface.
- Selecting `Top lid` enables `Кнопки`.
- Confirming the dialog appends a semantic `FeatureGroup` with
  `type: button_group`.
- The group stores layout/count/spacing as editable pattern data.
- Canceling the dialog makes no project change and creates no undo entry.
- Undo removes the new group and leaves selection valid.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid` in the project browser.
- Click `Кнопки` in the left rail.
- Change count to `6` and click `Создать`.
- Confirm `button_group_1` appears in the feature list/inspector.
- Click undo and confirm the new button group disappears.

---

## M15 — Glass Recess Command

### Goal
Make the next surface-based generator command create a semantic glass/insert
recess on the selected enclosure face.

### Tasks
- [x] Wire `glass.create_recess` from the left rail only when a surface is
      selected.
- [x] Add a compact glass recess dialog for width, height, depth, ledge, radius,
      insert thickness, and clearance profile.
- [x] Store the result as a `SemanticFeature` with `type: glass_recess`.
- [x] Commit the new recess through semantic undo history and select it.
- [x] Add a human inspector label for glass recess features.
- [x] Add widget/resolver tests for disabled state, create, cancel, undo, and
      display label.

### Done Criteria
- `Стекло` stays disabled without an active surface.
- Selecting `Top lid` enables `Стекло`.
- Confirming the dialog appends a semantic `glass_recess` feature.
- Canceling the dialog makes no project change and creates no undo entry.
- Undo removes the new recess and leaves selection valid.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid` in the project browser.
- Click `Стекло` in the left rail.
- Change width to `50` and click `Создать`.
- Confirm `glass_recess_1` appears in the feature list/inspector.
- Click undo and confirm the new recess disappears.

---

## M16 — Mount Generation Command

### Goal
Make the first component-driven generator command create editable semantic
standoff mounts from the selected component placement's mounting holes.

### Tasks
- [x] Wire `mount.generate` from the left rail only when a component placement
      with mounting holes is selected.
- [x] Resolve the selected `ComponentPlacement` to its `ComponentTemplate`.
- [x] Add a compact mount dialog for standoff diameter, hole diameter, height,
      and clearance profile.
- [x] Store the result as a `FeatureGroup` with `type: standoff_mounts`.
- [x] Keep source mounting-hole positions and source placement/template IDs in
      editable semantic group data.
- [x] Commit the new group through semantic undo history and select it.
- [x] Add human inspector/browser labels and mount dimensions.
- [x] Add widget/resolver tests for disabled state, create, cancel, undo, and
      display details.

### Done Criteria
- `Крепёж` stays disabled without a selected component placement.
- Selecting `button_board_placement` enables `Крепёж`.
- Confirming the dialog appends a semantic `FeatureGroup` with
  `type: standoff_mounts`.
- The group stores mounting-hole-derived pattern data instead of flattening
  mounts into unrelated independent features.
- Canceling the dialog makes no project change and creates no undo entry.
- Undo removes the new mount group and leaves selection valid.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement` in the project browser.
- Click `Крепёж` in the left rail.
- Change `Стойка` to `6` and click `Создать`.
- Confirm `standoff_mounts_1` appears in the feature list/inspector.
- Confirm the inspector shows diameter `6.0`, hole, height, and count data.
- Click undo and confirm the new mount group disappears.

---

## M17 — Feature Group Viewport Markers

### Goal
Make semantic mount groups visible and selectable in the mock viewport before
real OCCT geometry exists.

### Tasks
- [x] Add a `featureGroup` viewport hit kind.
- [x] Add a typed mock feature-group preview object for standoff mounts.
- [x] Map component mounting-hole positions into board-local viewport marker
      positions.
- [x] Draw standoff mount markers on top of the mock board.
- [x] Hit-test mount markers before the board so clicks select the whole
      `FeatureGroup`.
- [x] Highlight selected `standoff_mounts` groups in the viewport.
- [x] Add unit/widget tests for marker layout, semantic hit testing, and shell
      selection from a viewport click.

### Done Criteria
- Creating `standoff_mounts_1` shows four visible markers on the mock board.
- Clicking one marker selects the `standoff_mounts_1` feature group, not the
  board placement underneath.
- The inspector switches to the mount group details after marker selection.
- No mesh IDs, triangle IDs, or OCCT IDs are used for selection.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`, click `Крепёж`, set `Стойка` to `6`, and
  click `Создать`.
- Confirm four yellow mount markers appear around the mock board.
- Select `main_enclosure`, then click one mount marker in the viewport.
- Confirm the inspector switches back to `Крепёж` / `standoff_mounts_1`.

---

## M18 — Button Group Viewport Markers

### Goal
Make newly created semantic button groups visible and selectable in the mock
viewport through the same feature-group marker path as mounts.

### Tasks
- [x] Extend mock feature-group previews with a button-group marker kind.
- [x] Generate deterministic marker positions from button group `layout`,
      `count`, and `spacing`.
- [x] Support first-pass `diamond`, `row`, and `grid` pattern expansion.
- [x] Map button markers to the selected lid/surface reference frame instead
      of the component board frame used by standoff mounts.
- [x] Draw button-group markers in the viewport.
- [x] Hit-test button-group markers before hard-coded sample features so
      marker clicks select the semantic `FeatureGroup`.
- [x] Add unit/widget tests for button group marker mapping and shell marker
      selection.

### Done Criteria
- Creating `button_group_1` shows visible semantic button markers.
- Clicking a created button-group marker selects `button_group_1`.
- The inspector switches to button group details after marker selection.
- Repeated buttons remain one editable `FeatureGroup`.
- No mesh IDs, triangle IDs, or OCCT IDs are used for selection.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid`, click `Кнопки`, set count to `6`, and click `Создать`.
- Confirm the new button markers appear on the mock lid area.
- Select `main_enclosure`, then click one of the new button markers.
- Confirm the inspector switches back to `Группа кнопок` / `button_group_1`.

---

## M19 — Surface Feature Viewport Markers

### Goal
Make created surface features visible and selectable in the mock viewport before
real generated geometry exists.

### Tasks
- [x] Add typed mock feature previews for `usb_c_cutout` and `glass_recess`.
- [x] Derive feature preview dimensions from semantic feature parameters.
- [x] Draw USB-C markers on the mock front-wall area.
- [x] Draw glass recess markers on the mock lid area.
- [x] Hit-test feature markers before generic surfaces so clicks select the
      semantic `SemanticFeature`.
- [x] Highlight selected semantic feature markers.
- [x] Add unit/widget tests for USB-C/glass marker layout and shell selection
      from viewport clicks.

### Done Criteria
- Creating `usb_c_cutout_2` shows a selectable USB-C marker.
- Creating `glass_recess_1` shows a selectable glass/recess marker.
- Clicking either marker selects the corresponding semantic feature and shows
  its inspector details.
- No mesh IDs, triangle IDs, or OCCT IDs are used for selection.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Front wall`, click `Порты`, set width to `12`, and click `Добавить`.
- Select `main_enclosure`, then click the new USB-C marker.
- Confirm the inspector switches back to `USB-C` / `usb_c_cutout_2`.
- Select `Top lid`, click `Стекло`, set width to `50`, and click `Создать`.
- Select `main_enclosure`, then click the glass marker.
- Confirm the inspector switches back to `Посадка под стекло` /
  `glass_recess_1`.

---

## M20 — Feature Parameter Inspector Editing

### Goal
Let selected semantic surface features expose their first editable parameter
bank in the contextual inspector, using semantic project updates and the
existing undo history.

### Tasks
- [x] Add a feature parameter schema resolver for supported
      `SemanticFeature` types.
- [x] Add inspector number fields for `usb_c_cutout` width, height, and corner
      radius.
- [x] Add inspector number fields for `glass_recess` width, height, recess
      depth, ledge width, corner radius, and insert thickness.
- [x] Commit feature parameter edits through `UndoHistory<ProjectModel>`.
- [x] Keep feature edits semantic only; no generated mesh, B-Rep, or topology
      IDs enter project state.
- [x] Add widget tests for USB-C and glass recess inspector edits plus undo.

### Done Criteria
- Selecting an existing USB-C feature shows numeric parameter controls in the
  inspector.
- Selecting an existing glass recess feature shows numeric parameter controls
  in the inspector.
- Submitting a changed value updates the semantic feature parameters and
  refreshes the mock marker proportions.
- Undo restores the previous parameter value.
- Re-submitting an unchanged value does not create a semantic edit.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select the sample `USB-C` / `front_usb_c` feature.
- Change its width in the inspector, press Enter, and confirm the marker width
  changes slightly.
- Click undo and confirm the width returns to the previous value.
- Create or select a `glass_recess`, change width/depth in the inspector, then
  undo and confirm the old values return.

---

## M21 — Feature Group Parameter Inspector Editing

### Goal
Let selected semantic feature groups expose editable inspector parameter banks
while keeping repeated items as one semantic `FeatureGroup`.

### Tasks
- [x] Add a feature-group parameter schema resolver for supported group types.
- [x] Add inspector controls for `button_group` layout, count, spacing,
      diameter, and mode.
- [x] Add inspector controls for `standoff_mounts` diameter, hole diameter,
      height, and clearance profile.
- [x] Route group parameter edits back into `pattern` or `itemPrototype`
      without flattening generated markers.
- [x] Preserve mount safety by clamping hole diameter below standoff diameter.
- [x] Add widget tests for button-group and standoff inspector edits plus undo.

### Done Criteria
- Selecting a button group shows editable pattern/item controls in the
  inspector.
- Selecting a standoff mount group shows editable mount controls in the
  inspector.
- Submitting a changed value updates the semantic `FeatureGroup` and refreshes
  schematic viewport markers.
- Undo restores the previous group parameter value.
- Repeated buttons/mounts remain one group object.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Create a button group, select one of its viewport markers, and change
  `Кол-во` in the inspector.
- Confirm the marker count changes, then undo and confirm the old count returns.
- Generate `Крепёж`, select one standoff marker, change `Отверстие`, and
  confirm values stay within the standoff diameter.
- Undo the mount edit and confirm the previous value returns.

---

## M22 — Reusable Pattern Layout Engine

### Goal
Move first-pass button-group pattern expansion out of the workspace shell into
a reusable deterministic module that future geometry generation can consume.

### Tasks
- [x] Add a `patterns` module with `PatternLayoutEngine`.
- [x] Add a small viewport-independent `PatternPoint` value type.
- [x] Move `diamond`, `row`, and `grid` button layout expansion out of
      `workspace_shell.dart`.
- [x] Keep mock viewport markers derived from semantic `FeatureGroup` data via
      the new layout engine.
- [x] Add deterministic unit tests for supported layout expansion, fallback,
      and clamping.

### Done Criteria
- Workspace shell no longer owns button pattern expansion math.
- Button group markers still render/select from semantic group data.
- Repeated buttons remain one editable `FeatureGroup`.
- Layout tests cover known point positions.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Create a button group with `Ромб`, then switch/select it and confirm markers
  still appear on the lid.
- Change the group layout/count in the inspector and confirm markers still
  update as before.

---

## M23 — Reusable Standoff Source Layout

### Goal
Move first-pass standoff source mounting-hole expansion out of the workspace
shell and into the reusable pattern/layout module.

### Tasks
- [x] Extend `PatternLayoutEngine` with `standoffMountPositions`.
- [x] Prefer saved semantic `FeatureGroup.pattern.holePositions` when present.
- [x] Fall back to `ComponentTemplate.mountingHoles` when a group references a
      template but has no saved hole positions.
- [x] Keep invalid source positions from crashing preview generation.
- [x] Replace workspace shell hole-position parsing with the reusable helper.
- [x] Add deterministic unit tests for saved and fallback standoff positions.

### Done Criteria
- Workspace shell no longer owns standoff source-hole parsing.
- Standoff markers still render/select from semantic group data.
- Source mounting holes remain semantic group pattern data, not generated mesh
  or topology IDs.
- Layout tests cover saved source positions and template fallback.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Generate `Крепёж` from the sample board.
- Confirm four standoff markers still appear around the mock board.
- Click one standoff marker and confirm the `Крепёж` inspector still opens.

---

## M24 — First Semantic Validation Warnings

### Goal
Add the first project-level semantic validation pass before real OCCT geometry
exists, and surface warnings/errors in the shell status bar.

### Tasks
- [x] Add `ProjectSemanticValidator`.
- [x] Validate enclosure size, wall thickness, and corner radius.
- [x] Validate first-pass USB-C and glass recess dimensions against the main
      enclosure.
- [x] Validate first-pass standoff mount source positions and hole/diameter
      safety.
- [x] Wire `MockGeometryService.validateGeometry` to semantic validation.
- [x] Show warning state in the status bar, not only blocking errors.
- [x] Add unit, geometry-service, and widget coverage.

### Done Criteria
- The default sample project validates cleanly.
- Thin walls produce a visible warning.
- Oversized USB-C/glass recess data produces semantic errors.
- Unsafe standoff hole/diameter data produces a semantic error.
- Validation still does not rely on generated mesh, B-Rep, triangle IDs, or
  OCCT topology.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `main_enclosure`, set `Стенка` below `0.8`, press Enter.
- Confirm the bottom status bar switches to `Предупреждение` and shows the
  thin-wall message.
- Undo and confirm the status returns to the normal ready state.

---

## M25 — Validation Details + Placement Bounds

### Goal
Make validation issues inspectable from the shell status bar and add the first
semantic component placement/keepout bounds checks before real geometry exists.

### Tasks
- [x] Add reusable issue/error/warning accessors to `ValidationReport`.
- [x] Validate missing component templates.
- [x] Validate component board bounds against the enclosure inner volume.
- [x] Validate first-pass component feature keepout bounds.
- [x] Add a compact validation details sheet opened from the status bar.
- [x] Add unit coverage for component placement and keepout validation.
- [x] Add widget coverage for the validation details sheet.

### Done Criteria
- The default sample project still validates cleanly.
- A component outside the enclosure reports a semantic error.
- A missing component template reports a semantic error.
- A component keepout outside the inner enclosure reports a semantic warning.
- The status bar can open a list of all warning/error messages.
- Validation still does not rely on generated mesh, B-Rep, triangle IDs, or
  OCCT topology.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Set `main_enclosure` wall thickness below `0.8` again.
- Click the small checks/details icon in the bottom status bar.
- Confirm the bottom sheet opens with `Проверка проекта` and lists the warning.
- Close the sheet and undo the wall edit.

---

## M26 — Validation Issue Target Selection

### Goal
Make validation issue rows navigate back to their semantic target so warnings
and errors are actionable from the details sheet.

### Tasks
- [x] Add semantic target resolution from validation `targetId` values to
      `SelectionModel`.
- [x] Resolve direct body, component placement, component template, feature,
      and feature group targets.
- [x] Resolve surface-like and nested targets without using preview topology.
- [x] Make validation issue rows selectable when their target can be resolved.
- [x] Close the details sheet and update the inspector/browser selection after
      selecting an issue.
- [x] Add widget coverage for issue-row target selection.

### Done Criteria
- Clicking a validation row for a semantic feature selects that feature.
- Nested keepout-style targets resolve to their parent semantic component.
- Non-targeted project-level issues remain visible but are not selectable.
- The workflow still uses semantic IDs only, not generated mesh, B-Rep,
  triangle IDs, or OCCT topology.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Create or edit a glass recess so it produces a validation warning.
- Open the status-bar validation details sheet.
- Click the `glass_recess_*` issue row.
- Confirm the sheet closes and the glass recess inspector opens.
