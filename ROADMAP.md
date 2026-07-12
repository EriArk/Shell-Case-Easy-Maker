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
- [x] M27 — Component Placement Inspector Editing
- [x] M28 — Component Placement Rotation + Lock Guard
- [x] M29 — Component Placement Visibility
- [x] M30 — Local Workplane Overlay + Snap Hints
- [x] M31 — Snap Picking Seeds Component Placement
- [x] M32 — Active Snap Inspector Action
- [x] M33 — Snap Placement Footprint Preview
- [x] M34 — Snap Placement Fit Feedback
- [x] M35 — Placement Dialog Live Fit Check
- [x] M36 — Placement Dialog Viewport Candidate
- [x] M37 — Placement Template Size Summary
- [x] M38 — Placement Quick Presets
- [x] M39 — Placement Dialog Rotation
- [x] M40 — Snap Anchor Placement
- [x] M41 — Component USB-C Cutout Propagation
- [x] M42 — Component Switch Button Group
- [x] M43 - Projected Component Feature Anchors
- [x] M44 - Projected Anchor Validation
- [x] M45 - Geometry Feature Intent Protocol
- [x] M46 - Geometry Operation Plan
- [x] M47 - Mock Worker Protocol Harness
- [x] M48 - Worker Process Client
- [x] M49 - Worker GeometryService Adapter
- [x] M50 - Geometry Backend Selection
- [x] M51 - Generated Geometry Protocol Fixtures
- [x] M52 - Local occt_worker CLI
- [x] M53 - Worker Capability Contract
- [x] M54 - Worker Capability Process Client
- [x] M55 - Native Worker Build Scaffold
- [x] M56 - Native Worker Stub Smoke Tool
- [x] M57 - Native Worker Request Envelope
- [x] M58 - OCCT Windows Dependency Readiness
- [x] M59 - Opt-in OCCT Native Target Scaffold
- [x] M60 - OCCT vcpkg Manifest Restore Path
- [x] M61 - Repo-local vcpkg Bootstrap Helper
- [x] M62 - Local OCCT Restore + Link Smoke
- [x] M63 - First Native Rounded Enclosure Metrics
- [x] M64 - First Native Preview Mesh
- [x] M65 - Native OCCT App Backend Wiring
- [x] M66 - Native Preview Mesh Viewport
- [x] M67 - Native Preview Surface Ranges
- [x] M68 - Preview Surface Range Highlight
- [x] M69 - Native Shell/Cavity Slice
- [x] M70 - Native USB-C Cutout Slice
- [x] M71 - Native USB-C Feature Range Highlight
- [x] M72 - Native Front Glass Recess Slice
- [x] M73 - Native Front Button Group Cutouts
- [x] M74 - Native Bottom Standoff Mounts
- [x] M75 - Native Top Screw Lid Bosses
- [x] M76 - Native Top Lid Plate Preview
- [x] M77 - Native Top Lid Screw Holes
- [x] M78 - Native Top Lid Locating Lip
- [x] M79 - Native Top Lid Body Seat
- [x] M80 - Native Top Lid Fit Preview
- [x] M81 - Native Top Lid Button Cutouts
- [x] M82 - Native Top Lid Glass Recess
- [x] M83 - Native Top Lid Glass Ledge Window
- [x] M84 - Native Front Glass Ledge Window
- [x] M85 - Native Button Rings
- [x] M86 - Semantic Button Ring Controls
- [x] M87 - Native Button Cap/Stem Preview
- [x] M88 - Native Viewport Readability Pass
- [x] M89 - Viewport Navigation Presets
- [x] M90 - Semantic Plunger Travel Controls
- [x] M91 - Native Plunger Guide/Stop Preview
- [x] M92 - Native Viewport De-Clutter
- [x] M93 - Native Surface Workplane Softening
- [x] M94 - Native Mesh Semantic Picking
- [x] M95 - Native Preview Mesh De-Noise
- [x] M96 - Native Top Lid Near-Flush Fit Preview
- [x] M97 - Native Top Lid Planar Plate
- [x] M98 - Native OCCT Geometry Regression Test
- [x] M99 - Native STEP Export Slice
- [x] M100 - Toolbar STEP Export
- [x] M101 - Native STL Export Slice
- [x] M102 - Toolbar STEP/STL Export Format Choice
- [x] M103 - Semantic Circular Cutout Command
- [x] M104 - Native Circular Cutout Geometry
- [x] M105 - Snap-Seeded Circular Cutout Placement
- [x] M106 - Semantic Rounded Rectangular Cutout
- [x] M107 - Native Rectangular Cutout Geometry
- [x] M108 - Slot Cutout Preset
- [x] M109 - Slot Inspector Semantics
- [x] M110 - Native Switch-Sourced Button Cutouts
- [x] M111 - USB-C Snap-Seeded Placement
- [x] M112 - Snap-Seeded Glass and Button Placement
- [x] M113 - Native-Mapped Overlay De-Clutter
- [x] M114 - Native Active Snap Point De-Clutter
- [x] M115 - Collapsible Workspace Side Panels
- [x] M116 - Viewport Context Popover Foundation
- [x] M117 - Command Palette Foundation
- [x] M118 - Guided Enclosure Presets + Validation
- [x] M119 - Guided Component Placement Pick Mode
- [x] M120 - Advanced Mode Switch
- [x] M121 - Basic Sketch Foundation
- [x] M122 - Sketch Rectangle Entity Slice
- [x] M123 - Sketch Rectangle Parameter Editing
- [x] M124 - Sketch Rectangle Helper Overlay
- [x] M125 - Sketch Rectangle Overlay Hit Target
- [x] M126 - Sketch Rectangle Entity Focus
- [x] M127 - Sketch Rectangle Entity Actions
- [x] M128 - Sketch Rectangle Bounds Warning
- [x] M129 - Sketch Rectangle Click Placement
- [x] M130 - Sketch Rectangle Resize Buttons
- [x] M131 - Sketch Rectangle Move-To-Click
- [x] M132 - Sketch Rectangle Duplicate
- [x] M133 - Sketch Rectangle Keyboard Editing
- [x] M134 - Sketch Rectangle Keyboard Commands
- [x] M135 - Sketch Rectangle Workplane Quick Actions
- [x] M136 - Sketch Rectangle Semantic Rotation
- [x] M137 - Sketch Rectangle Shape Quick Actions
- [x] M138 - Sketch Circle Entity Foundation
- [x] M139 - Sketch Entity Profile Intent
- [x] M140 - Sketch Profile Operation Plan
- [x] M141 - Native Sketch Profile Cut Slice
- [x] M142 - Native Rotated Sketch Rectangle Cut
- [x] M143 - Native Sketch Add Protrusion Slice
- [x] M144 - Sketch Profile Depth Controls
- [x] M145 - Native Sketch Entity Picking
- [x] M146 - Sketch Entity Viewport Drag Move
- [x] M147 - Sketch Entity Live Drag Preview
- [x] M148 - Sketch Circle Drag Parity

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

---

## M27 — Component Placement Inspector Editing

### Goal
Make selected component placements directly editable from the contextual
inspector so validation errors found from M25/M26 can be corrected without
reopening the placement dialog.

### Tasks
- [x] Add a compact placement parameter schema for X/Y/Z, mounting side, and
      locked state.
- [x] Add a component placement editor to the contextual inspector.
- [x] Commit placement edits through semantic undo history.
- [x] Refresh mock preview and semantic validation after placement edits.
- [x] Add widget coverage for placement position edit, validation error, and
      undo.

### Done Criteria
- Selecting `button_board_placement` shows editable placement controls.
- Editing X/Y/Z updates the semantic `ComponentPlacement`.
- Moving a placement outside the enclosure updates validation status.
- Undo restores the previous semantic placement and clears the validation issue.
- The editable project remains semantic JSON only; no generated mesh, B-Rep, or
  topology is stored.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`.
- Change `X` to `80` and press Enter.
- Confirm the bottom status bar reports the component outside the enclosure.
- Click undo and confirm `X` returns to `0` and the error disappears.

---

## M28 — Component Placement Rotation + Lock Guard

### Goal
Make component placement editing more consistent by adding Z rotation editing,
using rotation-aware semantic bounds checks, and enforcing locked placement
state in the inspector/state path.

### Tasks
- [x] Add `Поворот Z` to the component placement inspector.
- [x] Commit rotation edits through semantic undo history.
- [x] Disable placement position/rotation/side controls while a placement is
      locked.
- [x] Keep the locked checkbox editable so the user can unlock the placement.
- [x] Ignore non-lock placement edits in shell state when a placement is locked.
- [x] Account for Z rotation in component board bounds validation.
- [x] Account for Z rotation in first-pass component keepout bounds validation.
- [x] Add unit/widget coverage for rotation-aware validation and locked editor
      behavior.

### Done Criteria
- A selected component placement can edit Z rotation from the inspector.
- Rotating a placement changes semantic validation bounds.
- Locked placements show disabled placement fields and a short locked hint.
- Unlocking a placement re-enables placement fields.
- Validation still uses semantic IDs and rough envelopes only, not generated
  mesh, B-Rep, triangle IDs, or OCCT topology.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`.
- Change `Поворот Z` to `90` and confirm undo restores it to `0`.
- Toggle `Зафиксировать`.
- Confirm X/Y/Z/Поворот/Посадка controls are disabled while locked, then unlock
  and confirm they work again.

---

## M29 — Component Placement Visibility

### Goal
Let component placements be hidden from the mock viewport while staying as
editable semantic project objects.

### Tasks
- [x] Add typed `visible` state to `ComponentPlacement` with default `true` for
      older project JSON.
- [x] Add a `Показывать` checkbox to the component placement inspector.
- [x] Preserve visibility through placement position, rotation, side, and lock
      edits.
- [x] Show hidden placements in the project browser with a visibility-off icon.
- [x] Generate mock viewport component placement previews from semantic
      placements/templates instead of always hit-testing one hard-coded board.
- [x] Omit hidden placements from mock viewport drawing and hit-testing.
- [x] Add serialization, viewport hit-test, and widget undo coverage.

### Done Criteria
- Older project files without `visible` load placements as visible.
- Toggling `Показывать` updates the semantic `ComponentPlacement` and is
  undoable.
- Hidden placements remain selectable from the browser/inspector.
- Hidden placements are not selected by clicking their former mock viewport
  location.
- No generated mesh, B-Rep, triangle ID, or OCCT topology becomes editable
  state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`.
- Turn off `Показывать`.
- Select `main_enclosure`, then click the board area in the viewport and
  confirm the component placement is not selected from the hidden marker.
- Select `button_board_placement` from the browser and turn `Показывать` back
  on.
- Click the board area again and confirm the placement inspector opens.

---

## M30 — Local Workplane Overlay + Snap Hints

### Goal
Show the active local workplane and first snap hints for selected surfaces and
component placements before adding viewport-driven placement edits.

### Tasks
- [x] Add a `MockViewportWorkplaneOverlay` preview value for active workplanes.
- [x] Add deterministic layout helpers for workplane rectangles and snap point
      mapping.
- [x] Extract the mock front-wall rect into `MockViewportLayout` so hit testing
      and overlays share one layout source.
- [x] Draw a compact translucent workplane grid in the mock viewport.
- [x] Draw snap hints on selected top-lid/front-wall surfaces.
- [x] Draw component placement snap hints from the selected template mounting
      holes.
- [x] Keep the overlay transient UI state only; do not save it into
      `ProjectModel`.
- [x] Add viewport layout and widget wiring coverage.

### Done Criteria
- Selecting `Top lid` shows a local workplane overlay and snap hints on the lid.
- Selecting `Front wall` shows a local workplane overlay and snap hints on the
  front wall.
- Selecting visible `button_board_placement` shows board-local snap hints.
- Hiding the placement removes its workplane overlay.
- No generated mesh, B-Rep, triangle ID, or OCCT topology becomes editable
  state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid` and confirm a subtle grid/snap overlay appears on the lid.
- Select `Front wall` and confirm the overlay moves to the front wall.
- Select `button_board_placement` and confirm snap dots appear on the board.
- Turn off `Показывать` for the placement and confirm the board overlay
  disappears.

---

## M31 — Snap Picking Seeds Component Placement

### Goal
Make viewport snap hints selectable and use the selected snap point as the
starting point for semantic component placement.

### Tasks
- [x] Add `snapPoint` hit results with workplane kind, snap index, and local
      position.
- [x] Pass the active local workplane overlay into mock viewport hit testing.
- [x] Store the clicked snap target as transient shell UI state, not project
      data.
- [x] Highlight the active snap hint in the viewport.
- [x] Seed the `component.place` dialog from the active snap target's X/Y/Z and
      mounting side.
- [x] Enable `component.place` from surface context so surface snap picking can
      flow directly into placement.
- [x] Keep visible semantic objects above overlapping snap hints in hit-test
      priority.
- [x] Add command, viewport, and widget coverage.

### Done Criteria
- Clicking a snap hint selects/highlights that hint without saving snap UI state
  into `ProjectModel`.
- Opening `Компоненты` after picking a top-lid snap hint shows the snap label
  and pre-fills placement coordinates from that point.
- A visible component placement remains selectable even when it overlaps a
  surface snap hint.
- Undo/redo and normal selection clear stale snap targets.
- No mesh, B-Rep, triangle ID, or OCCT topology becomes editable state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid`.
- Click a snap dot away from the center.
- Click `Компоненты`.
- Confirm the dialog shows `Точка: ...` and pre-fills X/Y from the clicked dot.
- Confirm `Разместить` creates the new component at that seeded position.
- Click an existing visible board area and confirm the component inspector still
  wins over an overlapping surface snap hint.

---

## M32 — Active Snap Inspector Action

### Goal
Make the selected snap point obvious and actionable from the contextual
inspector, not only from the left tool rail.

### Tasks
- [x] Add a compact active snap section to the inspector.
- [x] Show snap label, seeded project position, and human mounting side.
- [x] Add a direct `Разместить компонент` inspector action.
- [x] Add a clear action that removes only transient snap UI state.
- [x] Keep component placement confirmation inside the existing semantic dialog.
- [x] Add widget coverage for inspector action and clearing behavior.

### Done Criteria
- Clicking a snap hint shows an inspector section for that snap target.
- The inspector action opens the same snap-seeded component placement dialog as
  the rail command.
- Clearing the snap target removes highlight/inspector state without changing
  `ProjectModel`.
- No mesh, B-Rep, triangle ID, or OCCT topology becomes editable state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid`.
- Click a snap dot away from the center.
- Confirm the right inspector shows `Точка привязки`, position, and mounting
  side.
- Click `Разместить компонент` in the inspector and confirm the placement dialog
  opens with the same snap hint.
- Cancel, click the clear icon in the inspector, and confirm the snap section
  disappears.

---

## M33 — Snap Placement Footprint Preview

### Goal
Show a transient component footprint in the viewport after selecting a snap
point, before the user confirms placement.

### Tasks
- [x] Derive a mock placement preview from the active snap target and first
      component template.
- [x] Draw the preview as a translucent footprint in the viewport.
- [x] Keep the preview transient and omit it from viewport hit targets.
- [x] Remove the preview when the active snap target is cleared or selection
      changes.
- [x] Add widget coverage for preview presence and clearing behavior.

### Done Criteria
- Clicking a snap hint shows both the active snap inspector section and a
  component footprint preview.
- Clearing the snap target removes the footprint preview.
- The footprint does not create or save a `ComponentPlacement`.
- Existing visible semantic placements remain the only component placement hit
  targets.
- No mesh, B-Rep, triangle ID, or OCCT topology becomes editable state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid`.
- Click a snap dot away from the center.
- Confirm a translucent component footprint appears around that snap position.
- Click the clear icon in the inspector and confirm the footprint disappears.
- Click the same snap dot, use `Разместить компонент`, confirm the dialog, and
  check the committed component becomes the normal solid board marker.

---

## M34 — Snap Placement Fit Feedback

### Goal
Validate the snap-seeded placement preview before confirmation and show whether
the future component fits in the current enclosure.

### Tasks
- [x] Build a prospective `ComponentPlacement` from the active snap target.
- [x] Run the prospective placement through `ProjectSemanticValidator` without
      saving it.
- [x] Filter validation messages to only the prospective placement target.
- [x] Show a compact fit/status row in the active snap inspector panel.
- [x] Tint the transient footprint preview by validation severity.
- [x] Add widget coverage for the normal fit state and an oversized footprint
      error.

### Done Criteria
- Selecting a valid snap target reports that the board fits.
- A prospective component that would leave the enclosure reports the same
  semantic placement error as a committed component.
- Existing unrelated project validation messages do not pollute the snap
  preview status.
- The preview status does not enter undo/redo history and is not saved.
- No mesh, B-Rep, triangle ID, or OCCT topology becomes editable state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid`.
- Click a snap dot.
- Confirm the snap panel says the board fits the current enclosure.
- After later adding/editing a very large component template, confirm this same
  panel warns before committing placement.

---

## M35 — Placement Dialog Live Fit Check

### Goal
Show semantic fit feedback inside the component placement dialog while the user
edits template/position fields.

### Tasks
- [x] Pass the current semantic project into the placement dialog.
- [x] Build the current dialog candidate as a temporary `ComponentPlacement`.
- [x] Reuse prospective placement validation for dialog values.
- [x] Show a compact fit/status row in the dialog.
- [x] Update the status as X/Y/Z/template values change.
- [x] Add widget coverage for valid and invalid dialog candidate states.

### Done Criteria
- Opening `Компоненты` shows whether the current candidate fits.
- Editing X/Y/Z to an invalid value shows the semantic placement error before
  commit.
- The dialog still writes a normal `ComponentPlacement` only after confirm.
- Preview validation state does not enter undo/redo history or project JSON.
- No mesh, B-Rep, triangle ID, or OCCT topology becomes editable state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click `Компоненты`.
- Confirm the dialog says the board fits.
- Change X to `200`.
- Confirm the dialog reports that the component leaves the enclosure before you
  press `Разместить`.
- Cancel and confirm no new component was created.

---

## M36 — Placement Dialog Viewport Candidate

### Goal
Keep a transient viewport footprint in sync with the component placement dialog
candidate while the dialog is open.

### Tasks
- [x] Add shell-level transient candidate placement state for the placement
      dialog.
- [x] Seed the candidate before opening the dialog.
- [x] Update the candidate when dialog template/X/Y/Z/side/lock values change.
- [x] Draw the dialog candidate footprint in the viewport.
- [x] Clear the candidate on dialog cancel and confirm.
- [x] Add widget coverage for confirm and cancel cleanup.

### Done Criteria
- Opening `Компоненты` shows a transient candidate footprint in the viewport.
- Editing dialog values updates the candidate state used by the viewport.
- Canceling the dialog removes the footprint and does not commit a component.
- Confirming the dialog removes the transient footprint and commits a normal
  semantic `ComponentPlacement`.
- No preview candidate state enters undo/redo history or project JSON.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click `Компоненты`.
- Confirm a translucent candidate footprint appears behind the dialog.
- Change X/Y and confirm the dialog validation updates.
- Click `Отмена` and confirm the footprint disappears.
- Repeat, click `Разместить`, and confirm the transient footprint becomes a
  normal solid component marker.

---

## M37 — Placement Template Size Summary

### Goal
Make the component placement dialog show the selected template board footprint
dimensions so candidate fit feedback is easier to understand.

### Tasks
- [x] Resolve the selected component template inside the placement dialog.
- [x] Show board width, height, and thickness under the template selector.
- [x] Show a clear missing-template fallback.
- [x] Keep the summary read-only and outside project/undo state.
- [x] Add widget coverage for the sample board size summary.

### Done Criteria
- Opening `Компоненты` shows the selected board dimensions.
- The summary updates with the selected template state.
- Placement commit behavior is unchanged.
- No generated mesh, B-Rep, triangle ID, or OCCT topology becomes editable
  state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click `Компоненты`.
- Confirm the dialog shows the board dimensions under `Шаблон`.
- Confirm fit feedback still updates when changing X/Y/Z.

---

## M38 — Placement Quick Presets

### Goal
Make the component placement dialog faster to use by adding safe quick position
presets that update the transient candidate, viewport footprint, and fit check.

### Tasks
- [x] Add compact quick-position controls to the placement dialog.
- [x] Derive center/side offsets from the current enclosure inner space and
      selected board footprint.
- [x] Keep quick presets transient until the placement dialog is confirmed.
- [x] Update dialog number fields when values are changed by UI controls.
- [x] Add widget coverage for quick preset candidate updates and commit.

### Done Criteria
- Opening `Компоненты` shows quick position icons near the X/Y/Z fields.
- Clicking a preset updates the dialog coordinates immediately.
- The transient viewport candidate and semantic fit check stay in sync.
- Confirming the dialog commits a normal semantic `ComponentPlacement`.
- Quick preset state does not enter undo/redo history or project JSON.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click `Компоненты`.
- Click the right-arrow quick position icon and confirm X changes to `26`.
- Confirm the translucent candidate footprint moves.
- Click `Разместить` and confirm the new placement inspector shows
  `26 x 0 x 4 mm`.

---

## M39 — Placement Dialog Rotation

### Goal
Let component placement rotation be chosen before commit so the dialog
candidate, viewport footprint, and semantic fit check all reflect the final
placement orientation.

### Tasks
- [x] Add `Поворот Z` editing to the component placement dialog.
- [x] Add compact rotate-left/rotate-right 90 degree controls.
- [x] Feed dialog rotation into the transient candidate placement.
- [x] Reuse rotation-aware semantic validation for the dialog fit check.
- [x] Commit the confirmed rotation into the normal semantic
      `ComponentPlacement`.
- [x] Add widget coverage for rotation changing fit feedback and committed
      inspector state.

### Done Criteria
- Opening `Компоненты` shows a rotation control in the dialog.
- Rotating the candidate updates the transient viewport footprint.
- A placement that only fits after rotation reports the corrected fit state
  before commit.
- Confirming the dialog creates a semantic placement with the chosen
  `rotationZ`.
- No generated mesh, B-Rep, triangle ID, or OCCT topology becomes editable
  state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Click `Компоненты`.
- Set X to `36` and confirm the dialog reports the component leaves the
  enclosure.
- Click the rotate-right icon and confirm `Поворот Z` becomes `90` and the
  warning clears.
- Click `Разместить` and confirm the new placement inspector keeps
  `Поворот Z = 90`.

---

## M40 — Snap Anchor Placement

### Goal
Let a snap-seeded component placement align a chosen component anchor, such as
a mounting hole, connector, or switch center, to the selected surface snap
point before commit.

### Tasks
- [x] Pass the active snap target into the component placement dialog.
- [x] Build anchor choices from the selected component template center,
      mounting holes, and semantic features.
- [x] Add a compact `Якорь к точке` selector when placement starts from a snap.
- [x] Recalculate the candidate center so the selected anchor lands on the snap
      target.
- [x] Keep the selected anchor transient and save only the resulting semantic
      `ComponentPlacement`.
- [x] Add widget coverage for USB-C anchor alignment and rotation-aware
      re-alignment.

### Done Criteria
- Opening `Компоненты` from an active snap target shows anchor choices.
- Selecting a component anchor updates X/Y immediately.
- Rotating the candidate while anchor-locked keeps the chosen anchor on the
  snap target.
- Confirming the dialog commits a normal semantic placement position/rotation.
- No selected anchor state, generated mesh, B-Rep, triangle ID, or OCCT
  topology becomes editable project state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `Top lid`, click a snap dot, then open `Компоненты`.
- In `Якорь к точке`, choose `USB-C usb_c`.
- Confirm X/Y update so the USB-C anchor is aligned to the snap point.
- Click rotate-right and confirm the candidate keeps that anchor aligned.
- Click `Разместить` and confirm the committed placement uses the new
  position/rotation.

---

## M41 — Component USB-C Cutout Propagation

### Goal
Start component-driven enclosure generation by creating a semantic USB-C cutout
from a selected placed component's connector template data.

### Tasks
- [x] Allow the `Порты` command to run from selected component placement
      context when the template exposes a USB-C feature with cutout metadata.
- [x] Keep the existing surface-based manual USB-C command behavior.
- [x] Build the generated `usb_c_cutout` dimensions from component feature
      `metadata.cutout`.
- [x] Resolve the first target surface from the component feature direction.
- [x] Preserve source placement/template/feature metadata on the generated
      semantic cutout.
- [x] Add command and widget coverage, including saved project source data.

### Done Criteria
- Selecting `button_board_placement` enables `Порты`.
- Confirming the USB-C dialog creates a normal semantic `usb_c_cutout`.
- The new feature records its component placement/template/feature source.
- Surface-selected manual USB-C creation still works.
- No generated mesh, B-Rep, triangle ID, or OCCT topology becomes editable
  project state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`.
- Click `Порты`.
- Confirm the USB-C dialog opens with the template dimensions.
- Click `Добавить`.
- Confirm `usb_c_cutout_2` appears and can be selected/edited like a normal
  USB-C feature.

---

## M42 — Component Switch Button Group

### Goal
Start switch-to-button propagation by creating one editable semantic
`button_group` from a selected placed component's switch centers.

### Tasks
- [x] Allow the `Кнопки` command to run from selected component placement
      context when the template exposes switch features.
- [x] Keep the existing surface-based manual button group command behavior.
- [x] Build `button_group.pattern.switchPositions` from component switch
      centers.
- [x] Prefer saved switch positions in the pattern layout engine when
      `layout == from_component_switches`.
- [x] Preserve switch source data through the button group dialog confirmation.
- [x] Add command, pattern, and widget coverage, including saved project data.

### Done Criteria
- Selecting `button_board_placement` enables `Кнопки`.
- Confirming the dialog creates one semantic `FeatureGroup`, not independent
  button holes.
- The group records source placement/template IDs and switch center positions.
- The pattern can still be manually changed away from component switch centers.
- No generated mesh, B-Rep, triangle ID, or OCCT topology becomes editable
  project state.

### Tests
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`.
- Click `Кнопки`.
- Confirm the dialog opens with count `4`.
- Click `Создать`.
- Confirm `button_group_1` appears and remains one editable group.

---

## M43 - Projected Component Feature Anchors

### Goal
Add a small semantic projection layer that turns placed component feature
coordinates into world and target-surface coordinates for component-driven
cutouts and button groups.

### Tasks
- [x] Add `ComponentFeatureSurfaceProjector` outside the Flutter UI shell.
- [x] Apply placement `rotationZ` to component feature centers.
- [x] Project `front/back` features to surface `x,z` coordinates.
- [x] Project `left/right` features to surface `y,z` coordinates.
- [x] Project `top/bottom` features to surface `x,y` coordinates.
- [x] Store projected anchor metadata on component-sourced USB-C cutouts.
- [x] Store projected switch positions in component-sourced button groups.
- [x] Add unit and widget coverage for projection and saved JSON metadata.
- [x] Document the projection schema in
      `docs/33_COMPONENT_FEATURE_PROJECTION.md`.

### Done Criteria
- Component feature projection is testable without Flutter widgets or OCCT.
- USB-C cutouts keep source IDs plus `worldPosition`, `surfacePosition`, and
  `surfaceAxes`.
- Button groups use projected switch positions as their saved pattern
  positions.
- The editable project still stores semantic features/groups, not mesh,
  generated B-Rep, or topology IDs.

### Tests
- `flutter test test\component_feature_projection_test.dart`
- `flutter test test\widget_test.dart --plain-name "component USB-C rail command creates sourced cutout"`
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group"`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Select `button_board_placement`.
- Click `Порты`, create the USB-C cutout, then save the project.
- Confirm the saved JSON for the new cutout contains `surfacePosition`.
- Select `button_board_placement` again.
- Click `Кнопки`, create the button group, then save the project.
- Confirm the group still appears as one editable group and its saved
  `switchPositions` include projected positions.

---

## M44 - Projected Anchor Validation

### Goal
Make projected component anchors useful to the semantic validator before real
geometry generation consumes them.

### Tasks
- [x] Validate component-sourced USB-C projected `surfacePosition` against the
      target surface bounds.
- [x] Validate component-sourced button group switch positions against the lid
      or target surface bounds.
- [x] Warn when projected feature source placement/template/feature references
      are missing.
- [x] Warn when projected button group source placement/template references are
      missing.
- [x] Warn when projected axes are missing or do not match the target surface.
- [x] Add unit tests for outside-surface and missing-source cases.

### Done Criteria
- Projected anchors outside the usable enclosure surface produce validation
  errors.
- Orphaned projected anchors produce non-blocking validation warnings.
- Existing valid sample projects remain clean.
- The validator still works only from semantic project data, not mesh, B-Rep,
  or topology IDs.

### Tests
- `flutter test test\project_semantic_validator_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app.
- Create component-sourced `Порты` and `Кнопки` from `button_board_placement`.
- Confirm the bottom validation status stays clean for the normal generated
  anchors.
- Optional manual check: edit saved JSON so a projected `surfacePosition` is far
  outside the enclosure, reopen it, and confirm validation reports an issue.

---

## M45 - Geometry Feature Intent Protocol

### Goal
Pass semantic feature and feature-group generation intent through
`GeometryRequest` so the future OCCT worker can consume prepared cutout/button
mount data without reading UI state or mesh topology.

### Tasks
- [x] Add `GeometryFeatureIntent` to the geometry protocol.
- [x] Add `GeometryFeatureItemIntent` for derived repeated group items.
- [x] Include semantic features in `GeometryRequest.previewMesh(project)`.
- [x] Include feature groups with pattern/itemPrototype/placement/source data.
- [x] Expand button group item positions through `PatternLayoutEngine`.
- [x] Expand standoff mount item positions from saved holes or component
      template mounting holes.
- [x] Keep the editable project model unchanged; feature intents are request
      payload data only.
- [x] Add protocol tests for feature intent round-trip and group item expansion.

### Done Criteria
- Preview mesh requests include feature intents for current semantic features
  and feature groups.
- Repeated feature groups remain semantic groups in `ProjectModel`; only the
  request contains derived items for the geometry backend.
- Request JSON contains no OCCT topology IDs, triangle IDs, generated mesh, or
  editable B-Rep data.
- Mock backend can report the received feature-intent count in metrics.

### Tests
- `flutter test test\geometry_protocol_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a backend protocol change.
- Launch latest Windows app and confirm the default project still opens with a
  clean mock preview and validation status.

---

## M46 - Geometry Operation Plan

### Goal
Convert geometry feature intents into a deterministic backend operation plan
that the future worker can consume before real B-Rep generation exists.

### Tasks
- [x] Add `GeometryBuildOperation` as a typed operation-plan item.
- [x] Add `GeometryOperationPlanner.fromRequest`.
- [x] Map semantic features such as USB-C cutouts and glass recesses to backend
      operation kinds.
- [x] Map button group items to negative button-cut operations.
- [x] Map standoff mount items to positive standoff operations.
- [x] Keep operation plan data request/response scoped, not editable project
      state.
- [x] Expose mock backend operation-count and operation-plan metrics.
- [x] Add tests for deterministic operation ordering and group item operation
      generation.

### Done Criteria
- Feature intents can be converted to backend operation tasks without reading
  Flutter UI state.
- Button/standoff groups remain semantic groups in `ProjectModel`.
- Operation plan JSON contains semantic IDs and target surfaces, not OCCT
  topology IDs or preview triangle IDs.
- Mock backend reports operation-plan metrics for preview requests.

### Tests
- `flutter test test\geometry_protocol_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a backend planning change.
- Launch latest Windows app and confirm the default project still opens with a
  clean mock preview and validation status.

---

## M47 - Mock Worker Protocol Harness

### Goal
Add a local JSON worker-protocol harness so the future native OCCT worker
boundary can be exercised from stdin/stdout before real OCCT generation exists.

### Tasks
- [x] Add `GeometryWorkerProtocolHandler` for request JSON to response JSON.
- [x] Keep the handler backend-agnostic through a `buildGeometry` callback.
- [x] Add structured errors for invalid JSON, invalid top-level shape, and
      missing project payloads.
- [x] Add `tool/mock_geometry_worker.dart` as a Dart stdin/stdout smoke
      harness backed by `MockGeometryService`.
- [x] Add protocol tests for successful worker handling and invalid requests.
- [x] Document the mock worker command and current native-worker limitation.

### Done Criteria
- A geometry request JSON file can be piped into the mock worker harness.
- The harness returns `shell_case.geometry.response` JSON and non-zero exit
  code on error responses.
- Flutter still depends on `GeometryService`; no OCCT types, topology IDs,
  generated B-Rep, STL, or editable mesh state are introduced.
- The real native `occt_worker` executable remains a future task.

### Tests
- `flutter test test\geometry_protocol_test.dart`
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a backend protocol harness.
- Optional developer poke: run the mock worker command above and confirm status
  is `ok`, backend is `mock`, and preview mesh counts are present.
- Launch latest Windows app and confirm the default project still opens with a
  clean mock preview and validation status.

---

## M48 - Worker Process Client

### Goal
Add a testable process client that can run a worker executable, send request
JSON over stdin, parse response JSON from stdout, and normalize process-level
failures before the real native `occt_worker` exists.

### Tasks
- [x] Add `GeometryWorkerProcessCommand` for executable, args, environment,
      working directory, and shell settings.
- [x] Add `GeometryWorkerProcessClient.buildGeometry`.
- [x] Add the default `Process.start` runner that writes stdin and captures
      stdout/stderr.
- [x] Preserve structured worker error responses even when the worker exits
      non-zero.
- [x] Normalize invalid worker JSON, non-zero clean responses, process
      failures, and timeouts into `GeometryResponse` errors.
- [x] Add `tool/mock_geometry_worker_client_smoke.dart` to exercise the client
      against the mock worker process.
- [x] Add unit tests with a fake process runner.

### Done Criteria
- A geometry request can cross a real process boundary and return a normal
  `GeometryResponse`.
- Worker process failures produce response issues instead of crashing callers.
- Request payloads still contain semantic project data and feature intents, not
  editable mesh/B-Rep/topology IDs.
- The normal Flutter app still uses the in-process mock service until a real
  worker integration switch is intentionally added.

### Tests
- `flutter test test\geometry_worker_process_client_test.dart`
- `dart run tool\mock_geometry_worker_client_smoke.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a backend worker-process
  adapter.
- Optional developer poke: run `dart run tool\mock_geometry_worker_client_smoke.dart`
  and confirm status is `ok`, backend is `mock`, `featureIntents` is `2`, and
  `operationCount` is `2`.
- Launch latest Windows app and confirm the default project still opens with a
  clean mock preview and validation status.

---

## M49 - Worker GeometryService Adapter

### Goal
Add a `GeometryService` implementation that uses the worker process client for
preview/build requests while keeping semantic validation and UI selection
metadata local and testable.

### Tasks
- [x] Add `WorkerGeometryService`.
- [x] Route `buildGeometry` through `GeometryWorkerProcessClient`.
- [x] Route `generatePreview` through a worker preview-mesh request.
- [x] Keep semantic selectable surfaces local and reusable by mock and worker
      services.
- [x] Keep semantic validation local through `ProjectSemanticValidator`.
- [x] Add `tool/mock_worker_geometry_service_smoke.dart` for the full adapter
      path against the mock worker process.
- [x] Add unit tests for build routing, preview stats, worker error stats, and
      local validation.

### Done Criteria
- The app has a concrete worker-backed `GeometryService` adapter.
- The default app shell still uses `MockGeometryService`; no user-facing runtime
  switch is enabled accidentally.
- Worker preview requests include semantic project data and feature intents.
- Process diagnostics stay response/preview metadata and do not become editable
  project state.

### Tests
- `flutter test test\geometry_worker_service_test.dart`
- `dart run tool\mock_worker_geometry_service_smoke.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; the default app still uses the
  in-process mock backend.
- Optional developer poke: run `dart run tool\mock_worker_geometry_service_smoke.dart`
  and confirm backend is `mock`, response status is `ok`, `featureIntents` is
  `2`, `operationCount` is `2`, and `surfaceCount` is `3`.
- Launch latest Windows app and confirm the default project still opens with a
  clean mock preview and validation status.

---

## M50 - Geometry Backend Selection

### Goal
Add a deliberate developer/runtime geometry backend selector so the app can
instantiate either the stable mock backend or the worker-backed service without
making the worker the default.

### Tasks
- [x] Add `GeometryBackendKind`.
- [x] Add `GeometryBackendSettings`.
- [x] Add `createGeometryService(settings)`.
- [x] Add `createGeometryServiceFromEnvironment()` for compile-time
      `--dart-define` values.
- [x] Wire `CaseMakerApp` to use the backend factory by default.
- [x] Keep `CaseMakerApp(geometryService: ...)` injection available for tests
      and explicit callers.
- [x] Add tests for default mock selection, explicit worker selection, worker
      fallback without executable, and pipe-separated worker arguments.

### Done Criteria
- A normal app run/build still uses `MockGeometryService`.
- Worker backend is only selected when explicitly configured.
- Missing worker executable falls back to mock instead of breaking app startup.
- Backend selection still returns a `GeometryService`; widgets do not know
  about process clients or native worker details.

### Tests
- `flutter test test\geometry_backend_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.
- Optional developer poke later:
  `flutter run -d windows --dart-define=SHELL_CASE_GEOMETRY_BACKEND=worker --dart-define=SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE=dart "--dart-define=SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS=run|occt_worker/bin/occt_worker.dart"`

---

## M51 - Generated Geometry Protocol Fixtures

### Goal
Keep worker protocol example files generated from typed semantic project models
and the mock backend so future worker changes have realistic request/response
fixtures.

### Tasks
- [x] Add `tool/generate_geometry_protocol_fixtures.dart`.
- [x] Generate the preview request fixture from a typed semantic project with
      USB-C, source button-group, projected button-group, and standoff feature
      intents.
- [x] Generate the preview response fixture from `MockGeometryService`.
- [x] Include expanded button group and standoff mount items in the request
      fixture.
- [x] Include operation-plan metrics in the response fixture.
- [x] Add fixture tests for feature intents, group item expansion, response
      metrics, and mock rebuild parity.

### Done Criteria
- `occt_worker/protocol/preview_request.example.json` includes semantic
  `featureIntents`.
- `occt_worker/protocol/preview_response.example.json` includes mock backend
  metrics with an `operationPlan`.
- The fixture project stores semantic groups and templates, not editable mesh,
  B-Rep, STL, OCCT topology IDs, or preview triangle IDs.
- The mock worker smoke command returns `featureIntents=4` and
  `operationCount=10` for the generated fixture.

### Tests
- `dart run tool\generate_geometry_protocol_fixtures.dart`
- `flutter test test\geometry_protocol_fixture_test.dart`
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a backend fixture and
  protocol reproducibility change.
- Optional developer poke: regenerate the fixtures and run the mock worker
  smoke command above.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M52 - Local occt_worker CLI

### Goal
Create the canonical local worker command under `occt_worker/` so worker
process tests and developer runs target the future worker boundary instead of a
temporary tool script.

### Tasks
- [x] Add `GeometryWorkerRuntime` for stdin/stdout worker execution.
- [x] Add backend mode parsing with `mock` default and explicit `native` stub.
- [x] Add `occt_worker/bin/occt_worker.dart` as the canonical local CLI.
- [x] Keep `tool/mock_geometry_worker.dart` as a compatibility alias.
- [x] Update worker process smoke scripts to call the canonical CLI.
- [x] Add tests for runtime parsing, mock responses, invalid payloads, native
      not-implemented responses, CLI argument errors, and real process-client
      execution.

### Done Criteria
- `dart run occt_worker\bin\occt_worker.dart` reads a geometry request from
  stdin and emits `shell_case.geometry.response` JSON.
- The default CLI backend uses the mock geometry service until native OCCT is
  implemented.
- `--backend=native` returns a structured not-implemented response instead of a
  fake success.
- The worker process client can run the canonical CLI successfully.
- No editable mesh, STL, B-Rep, OCCT topology IDs, or native process details
  enter the project model.

### Tests
- `flutter test test\geometry_worker_runtime_test.dart`
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart`
- `dart run tool\mock_geometry_worker_client_smoke.dart`
- `dart run tool\mock_worker_geometry_service_smoke.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a worker CLI/process
  boundary change.
- Optional developer poke: pipe the generated fixture into
  `dart run occt_worker\bin\occt_worker.dart` and confirm `backend` is `mock`.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M53 - Worker Capability Contract

### Goal
Make the local worker able to report backend readiness and supported operations
without requiring a geometry request payload.

### Tasks
- [x] Add `GeometryWorkerCapabilities`.
- [x] Add `GeometryWorkerBackendCapability`.
- [x] Add `--capabilities` parsing to the worker runtime.
- [x] Report mock backend as available for `preview_mesh`.
- [x] Report native backend as a stub with planned preview/export/validate
      operations.
- [x] Keep source-of-truth metadata explicit: semantic project is editable,
      generated geometry is not.
- [x] Add unit and process tests for capability JSON.
- [x] Document the capability command.

### Done Criteria
- `dart run occt_worker\bin\occt_worker.dart --capabilities` exits with code
  `0` and emits `shell_case.geometry.worker.capabilities` JSON.
- Capability JSON includes protocol schema/version metadata.
- Capability JSON identifies `mock` as available and `native` as stub.
- Capability JSON does not expose OCCT topology IDs or imply generated geometry
  is editable.

### Tests
- `flutter test test\geometry_worker_runtime_test.dart`
- `dart run occt_worker\bin\occt_worker.dart --capabilities`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a worker metadata
  contract change.
- Optional developer poke: run
  `dart run occt_worker\bin\occt_worker.dart --capabilities` and confirm
  `mock` is `available`, `native` is `stub`.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M54 - Worker Capability Process Client

### Goal
Let Dart callers query worker capability metadata through the same process
adapter used for geometry requests, with typed parsing and normalized failures.

### Tasks
- [x] Move worker capability data types into
      `geometry_worker_capabilities.dart`.
- [x] Add JSON parsing for `GeometryWorkerCapabilities`.
- [x] Add JSON parsing for `GeometryWorkerBackendCapability`.
- [x] Export capability types from the geometry service boundary.
- [x] Add `GeometryWorkerProcessClient.queryCapabilities()`.
- [x] Append `--capabilities` to the configured command without duplicating it.
- [x] Normalize capability launch failures, timeouts, invalid JSON, and non-zero
      exits into typed issues.
- [x] Add process-client tests for success and failure modes.

### Done Criteria
- A configured `GeometryWorkerProcessClient` can fetch typed capability
  metadata from a worker command.
- Capability query failures do not crash the caller.
- Geometry request/response behavior remains unchanged.
- Capability metadata remains process/runtime metadata, not editable project
  data.

### Tests
- `flutter test test\geometry_worker_process_client_test.dart`
- `flutter test test\geometry_worker_runtime_test.dart`
- `dart run occt_worker\bin\occt_worker.dart --capabilities`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a process-client metadata
  change.
- Optional developer poke: run
  `dart run occt_worker\bin\occt_worker.dart --capabilities`.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M55 - Native Worker Build Scaffold

### Goal
Add a separately buildable native worker executable scaffold that preserves the
worker protocol boundary without linking OCCT or pretending native geometry is
implemented.

### Tasks
- [x] Add `occt_worker/native/CMakeLists.txt`.
- [x] Add `occt_worker/native/src/main.cpp`.
- [x] Add `occt_worker_native_stub` CMake executable target.
- [x] Add `tools/build_occt_worker_stub.ps1`.
- [x] Keep native scaffold separate from the Flutter Windows runner.
- [x] Make native stub emit worker capability JSON.
- [x] Make native stub return structured `worker.backend.native_not_implemented`
      response for geometry requests.
- [x] Add scaffold tests for CMake target, JSON contracts, and build script
      output confinement.

### Done Criteria
- Native stub builds into `build/occt_worker_native`.
- `occt_worker_native_stub.exe --capabilities` emits
  `shell_case.geometry.worker.capabilities`.
- Piping a geometry request into `occt_worker_native_stub.exe` returns a
  structured not-implemented geometry response.
- Scaffold does not add OCCT includes/dependencies yet.
- Scaffold does not store generated mesh, B-Rep, STL, or OCCT topology IDs in
  the editable project model.

### Tests
- `flutter test test\native_worker_scaffold_test.dart`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`
- `build\occt_worker_native\Release\occt_worker_native_stub.exe --capabilities`
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | build\occt_worker_native\Release\occt_worker_native_stub.exe`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a native worker scaffold.
- Optional developer poke: run
  `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`
  and then run the printed `--capabilities` command.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M56 - Native Worker Stub Smoke Tool

### Goal
Add a single developer smoke command that builds the native worker stub, queries
capabilities through the Dart process client, and verifies the expected
not-implemented geometry response.

### Tasks
- [x] Add `tool/native_worker_stub_smoke.dart`.
- [x] Run `tools/build_occt_worker_stub.ps1` from the smoke tool.
- [x] Locate the native stub executable under `build/occt_worker_native`.
- [x] Query capabilities with `GeometryWorkerProcessClient.queryCapabilities()`.
- [x] Send a preview request through `GeometryWorkerProcessClient.buildGeometry()`.
- [x] Treat `worker.backend.native_not_implemented` as the expected scaffold
      response.
- [x] Add scaffold-test coverage for the smoke tool path.

### Done Criteria
- `dart run tool\native_worker_stub_smoke.dart` builds and verifies the native
  stub.
- Smoke output includes executable path, capability status, and request result.
- The tool exits non-zero if capabilities fail or the not-implemented response
  is missing.
- No release artifacts or build outputs are committed.

### Tests
- `flutter test test\native_worker_scaffold_test.dart`
- `dart run tool\native_worker_stub_smoke.dart`
- `dart run tool\native_worker_stub_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a developer worker smoke.
- Optional developer poke: run `dart run tool\native_worker_stub_smoke.dart`.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M57 - Native Worker Request Envelope

### Goal
Make the native worker stub read and validate the top-level worker request
envelope before returning the scaffold not-implemented response.

### Tasks
- [x] Replace stdin discard behavior with request envelope reading.
- [x] Preserve `requestId` in native error responses.
- [x] Validate top-level `schema` before treating payloads as geometry
      requests.
- [x] Validate top-level `operation` against planned worker operations.
- [x] Return structured request errors for empty payload, non-object payload,
      invalid schema, and invalid operation.
- [x] Include `requestedOperation` in native response metrics when available.
- [x] Make native smoke fail if request IDs are not preserved.
- [x] Update scaffold tests and docs.

### Done Criteria
- Valid preview requests return `worker.backend.native_not_implemented` with
  the same `requestId` that was sent.
- Invalid native request envelopes return typed `worker.request.*` issue codes.
- The native stub still does not link OCCT or generate B-Rep.
- No generated build or release artifacts are committed.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`
- `dart run tool\native_worker_stub_smoke.dart --skip-build`
- Native stub empty payload smoke
- Native stub invalid schema smoke
- Native stub invalid operation smoke
- `flutter test test\native_worker_scaffold_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a native protocol hardening
  change.
- Optional developer poke: run `dart run tool\native_worker_stub_smoke.dart` and
  confirm `requestIdPreserved` is `true`.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M58 - OCCT Windows Dependency Readiness

### Goal
Lock the first Windows OCCT dependency path and add a read-only readiness check
before adding an OCCT-linked native target.

### Tasks
- [x] Research current official OCCT build/licensing guidance.
- [x] Check current vcpkg package status for `opencascade`.
- [x] Add `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`.
- [x] Append the dependency decision to `docs/27_RESEARCH_AND_REFERENCES.md`.
- [x] Add `tools/check_occt_windows_readiness.ps1`.
- [x] Make the checker report JSON without installing or deleting anything.
- [x] Add tests that keep the checker read-only and the worker boundary
      documented.
- [x] Update README, OCCT docs, tasks, and worklog.

### Done Criteria
- The next native OCCT slice has an explicit dependency decision.
- The readiness checker reports whether `OpenCASCADEConfig.cmake` is
  discoverable through `OpenCASCADE_DIR`, `CASROOT`, or vcpkg-style paths.
- Normal Flutter builds and `occt_worker_native_stub` remain independent of
  OCCT.
- No OCCT source, binary dependency, build output, or release artifact is
  committed.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1 -RequireOcct`
- `flutter test test\occt_windows_readiness_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is dependency planning and
  tooling.
- Optional developer poke: run the readiness command and confirm `ready` is
  currently `false` until vcpkg/OCCT is configured.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M59 - Opt-in OCCT Native Target Scaffold

### Goal
Add the separate OCCT-linked native target scaffold while keeping the existing
native stub buildable without OCCT.

### Tasks
- [x] Add `SHELL_CASE_ENABLE_OCCT` CMake option.
- [x] Keep `occt_worker_native_stub` as the default no-OCCT target.
- [x] Add opt-in `occt_worker_native_occt` target.
- [x] Link the opt-in target through `OpenCASCADEConfig.cmake`.
- [x] Add `occt_worker/native/src/occt_main.cpp` as an OCCT link smoke.
- [x] Add `tools/build_occt_worker_occt.ps1`.
- [x] Make the OCCT build script require readiness without installing packages.
- [x] Add tests for the target scaffold, source contract, and build script.
- [x] Update README, worker docs, OCCT docs, tasks, and worklog.

### Done Criteria
- `tools/build_occt_worker_stub.ps1` still builds without OCCT installed.
- `tools/build_occt_worker_occt.ps1` exits cleanly when readiness is false.
- The OCCT target is not part of normal Flutter builds.
- The OCCT target is a link smoke only and does not expose topology IDs,
  generated B-Rep, or preview mesh as editable project state.
- No OCCT source, binary dependency, build output, or release artifact is
  committed.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1`
- `flutter test test\native_worker_scaffold_test.dart test\occt_native_target_scaffold_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is a native build scaffold.
- Optional developer poke: run `tools\build_occt_worker_occt.ps1` and confirm it
  exits with readiness guidance until OCCT is configured.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M60 - OCCT vcpkg Manifest Restore Path

### Goal
Add an explicit vcpkg manifest path for the OCCT target without making package
installation automatic during normal builds.

### Tasks
- [x] Add `occt_worker/native/vcpkg.json`.
- [x] Declare only the `opencascade` dependency.
- [x] Add `-AllowVcpkgInstall` to `tools/build_occt_worker_occt.ps1`.
- [x] Keep the default OCCT build script path read-only when readiness is false.
- [x] Allow vcpkg manifest mode only when `VCPKG_ROOT`/toolchain is configured
      and the explicit flag is provided.
- [x] Add tests for the manifest and script safety.
- [x] Update README, OCCT docs, worker docs, tasks, and worklog.

### Done Criteria
- Normal Flutter builds remain independent of OCCT.
- `tools/build_occt_worker_occt.ps1` still exits with readiness guidance by
  default when OCCT is missing.
- `-AllowVcpkgInstall` is the only path that lets vcpkg restore the manifest.
- No vcpkg install tree, OCCT source, OCCT binaries, build output, or release
  artifact is committed.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\occt_native_target_scaffold_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is dependency plumbing.
- Optional developer poke: after installing/configuring vcpkg, run
  `tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`.
- Launch latest Windows app normally and confirm the default project still opens
  with the mock preview and clean validation status.

---

## M61 - Repo-local vcpkg Bootstrap Helper

### Goal
Make the OCCT dependency setup reproducible on this Windows workstation without
committing vcpkg sources, OCCT binaries, or generated install output.

### Tasks
- [x] Add `tools/bootstrap_vcpkg_windows.ps1`.
- [x] Keep the default helper flow free of `opencascade` package restore unless
      `-InstallOpenCascade` is provided.
- [x] Add `-PlanOnly` so the setup can be inspected without changing files.
- [x] Ignore `external/` for repo-local dependency tool output.
- [x] Teach `tools/check_occt_windows_readiness.ps1` to detect
      `external/vcpkg` when `VCPKG_ROOT` is not set.
- [x] Add tests for helper safety and readiness auto-detection contract.
- [x] Update README, OCCT docs, worker docs, tasks, and worklog.

### Done Criteria
- The helper can print a JSON setup plan without cloning or installing.
- Repo-local vcpkg output stays ignored by Git.
- OpenCASCADE restore remains an explicit large-dependency action.
- Normal Flutter builds and native stub builds remain independent of OCCT.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`
- `flutter test test\occt_windows_readiness_test.dart test\vcpkg_bootstrap_script_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is local dependency setup.
- Optional developer poke when a long dependency install is acceptable:
  `tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade`.

---

## M62 - Local OCCT Restore + Link Smoke

### Goal
Make OCCT locally ready on this workstation and prove the opt-in native target
can link and run against the restored package.

### Tasks
- [x] Run repo-local vcpkg bootstrap with explicit `-InstallOpenCascade`.
- [x] Keep generated dependency output ignored by Git.
- [x] Update readiness detection for manifest-mode `vcpkg_installed` output.
- [x] Fix readiness empty-candidate handling on Windows PowerShell.
- [x] Build `occt_worker_native_occt` with `-AllowVcpkgInstall -Clean`.
- [x] Run native OCCT capabilities smoke.
- [x] Run native OCCT request smoke and confirm request ID preservation.
- [x] Update README, OCCT docs, tasks, and worklog.

### Done Criteria
- `tools\check_occt_windows_readiness.ps1` reports `ready: true`.
- `OpenCASCADEConfig.cmake` is found under
  `occt_worker/native/vcpkg_installed/x64-windows`.
- `build/occt_worker_native_occt/Release/occt_worker_native_occt.exe` exists.
- Capabilities report `status=linked_smoke` and `occtVersion=8.0.0`.
- Native request smoke returns `worker.backend.occt_link_smoke_only` with
  `linkSmokeShapeNull=false`.
- No vcpkg source tree, installed dependency tree, OCCT DLLs, or build output is
  committed.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall -Clean`
- `build\occt_worker_native_occt\Release\occt_worker_native_occt.exe --capabilities`
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | build\occt_worker_native_occt\Release\occt_worker_native_occt.exe`
- `flutter test test\occt_windows_readiness_test.dart test\occt_native_target_scaffold_test.dart test\vcpkg_bootstrap_script_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test`
- `tools/build_latest_windows.ps1`

### Poke Checklist
- No meaningful manual UI poke for this chunk; it is native dependency
  readiness.
- Optional developer poke: run
  `build\occt_worker_native_occt\Release\occt_worker_native_occt.exe --capabilities`
  and confirm it reports OCCT `8.0.0`.

---

## M63 - First Native Rounded Enclosure Metrics

### Goal
Replace the OCCT link-smoke response with the first deterministic native
rounded enclosure generation slice while keeping generated B-Rep internal to the
worker.

### Tasks
- [x] Parse the first semantic enclosure body from `shell_case.geometry.request`.
- [x] Validate rounded-box dimensions, wall thickness, and corner radius.
- [x] Build the rounded enclosure B-Rep with OCCT box and fillet APIs.
- [x] Compute deterministic bounds, dimensions, surface area, and volume.
- [x] Return metrics-only `preview_mesh` responses without preview vertices.
- [x] Keep OCCT topology IDs, triangle IDs, B-Rep, STL, and generated mesh out
      of editable Flutter state.
- [x] Add `tool/native_occt_worker_metrics_smoke.dart`.
- [x] Update source-contract tests and documentation.

### Done Criteria
- `occt_worker_native_occt --capabilities` reports `status=metrics_smoke`.
- A sample `preview_mesh` request returns `status=ok`,
  `generator=occt.rounded_enclosure.metrics.v1`, and request ID preservation.
- The sample metrics report bounds `[-60, -35, 0]` to `[60, 35, 28]`,
  dimensions `[120, 70, 28]`, surface area `25924.813728`, and volume
  `232291.58617`.
- The response explicitly reports `previewMeshEmitted=false` and
  `editableGeneratedGeometry=false`.
- No generated dependency, worker build, release bundle, OCCT DLL, or mesh
  artifact is committed.

### Tests
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`
- `git diff --check`

### Poke Checklist
- No meaningful manual UI poke for this chunk; the app still shows the mock
  viewport.
- Optional developer poke: run
  `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build` and
  confirm the command exits successfully.

---

## M64 - First Native Preview Mesh

### Goal
Emit the first disposable native OCCT preview mesh from the generated rounded
enclosure B-Rep while keeping the editable project semantic-only.

### Tasks
- [x] Mesh the generated rounded enclosure B-Rep with
      `BRepMesh_IncrementalMesh`.
- [x] Extract face triangulations through `BRep_Tool::Triangulation`.
- [x] Return `PreviewMesh` vertices, triangle indices, bounds, and mesh metadata
      through the existing geometry protocol.
- [x] Keep semantic surface mapping empty until a stable semantic face-mapping
      slice exists.
- [x] Record deterministic sample mesh counts in the native OCCT smoke.
- [x] Update capability status to `preview_mesh_smoke`.
- [x] Update docs, roadmap, tasks, worklog, and source-contract tests.

### Done Criteria
- `occt_worker_native_occt --capabilities` reports
  `status=preview_mesh_smoke`.
- A sample `preview_mesh` request returns `status=ok`,
  `generator=occt.rounded_enclosure.preview_mesh.v1`, and request ID
  preservation.
- The sample response includes `previewMesh` with 800 vertices and 1060
  triangles, bounds `[-60, -35, 0]` to `[60, 35, 28]`, and dimensions
  `[120, 70, 28]`.
- The response explicitly reports `editableGeneratedGeometry=false`.
- The response does not expose OCCT topology IDs, generated B-Rep, STL, or
  triangle IDs as stable editable references.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`
- `git diff --check`

### Poke Checklist
- No meaningful manual UI poke yet; the normal app still defaults to the mock
  viewport.
- Optional developer poke: run
  `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build` and
  confirm `previewSmoke.ok` is `true`, with 800 vertices and 1060 triangles.

---

## M65 - Native OCCT App Backend Wiring

### Goal
Make the Flutter app able to select the local native OCCT worker as a bundled
developer backend without hard-coding project-local absolute paths.

### Tasks
- [x] Add `GeometryBackendKind.nativeOcct` with wire value `native_occt`.
- [x] Resolve bundled worker path relative to the app executable:
      `occt_worker/native/occt_worker_native_occt.exe`.
- [x] Fall back to mock geometry when the bundled native worker is missing.
- [x] Allow explicit worker executable overrides for development.
- [x] Add `tools/build_latest_windows.ps1 -NativeOcct`.
- [x] Copy the full native worker release bundle beside the latest Windows app.
- [x] Keep the default latest build on mock unless `-NativeOcct` is explicit.
- [x] Add tests for backend resolution and build-script safety.

### Done Criteria
- `SHELL_CASE_GEOMETRY_BACKEND=native_occt` can create a
  `WorkerGeometryService` when the bundled worker exists.
- Missing bundled native worker falls back to `MockGeometryService`.
- `tools\build_latest_windows.ps1 -NativeOcct` builds the app and copies
  `occt_worker_native_occt.exe` plus adjacent DLLs under
  `releases/latest/windows/occt_worker/native`.
- The copied worker runs `--capabilities` from the release folder.
- No native build output, release bundle, vcpkg tree, or OCCT DLL is committed.

### Tests
- `flutter test test\geometry_backend_test.dart test\build_latest_windows_script_test.dart --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label shows `occt_worker_native_occt` instead of `mock`.
- The drawn center model is still the existing schematic viewport until the next
  rendering slice consumes native mesh vertices.

---

## M66 - Native Preview Mesh Viewport

### Goal
Render the disposable `PreviewMesh` returned by `GeometryService` in the Flutter
viewport while keeping selection and editing tied to semantic project objects.

### Tasks
- [x] Carry `PreviewMesh` through `GeometryPreview`.
- [x] Feed preview mesh data from both mock and worker-backed geometry services.
- [x] Add a viewport painter path for faceted preview mesh rendering.
- [x] Keep semantic hit testing on existing stable semantic IDs, not triangle
      IDs or OCCT topology.
- [x] Add worker service and widget coverage for the mesh handoff.
- [x] Update docs, roadmap, tasks, and worklog.

### Done Criteria
- Worker-backed previews expose `preview.previewMesh` to the shell.
- The viewport draws a mesh body when preview vertices and triangles are
  present.
- Existing component, feature, feature-group, workplane, snap, and selection
  overlays still render above the body preview.
- The app does not expose generated mesh, B-Rep, triangle IDs, or OCCT topology
  as editable state.

### Tests
- `flutter test test\geometry_worker_service_test.dart test\widget_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label shows `occt_worker_native_occt`.
- Confirm the center body is now a faceted/rounded native preview mesh rather
  than only the old flat schematic mock body.
- Orbit, pan, and zoom the viewport.
- Click semantic items/surfaces and confirm the inspector still changes as
  before; this chunk does not add triangle picking.

---

## M67 - Native Preview Surface Ranges

### Goal
Return the first semantic preview surface mappings from the native OCCT worker
without making generated triangle indices stable editable IDs.

### Tasks
- [x] Add native preview surface mapping/range data structures.
- [x] Classify planar top, front, and bottom face blocks from generated B-Rep
      bounds.
- [x] Emit `PreviewSurfaceMapping` JSON with disposable triangle ranges.
- [x] Add metrics for mapping count and mapped triangle count.
- [x] Update the native smoke tool to validate semantic IDs and range bounds.
- [x] Update docs, roadmap, tasks, and worklog.

### Done Criteria
- Native `previewMesh.surfaces` includes:
  - `main_enclosure.top_lid.outer`,
  - `main_enclosure.front_wall.outer`,
  - `main_enclosure.bottom_inside`.
- Each mapping has positive `triangleRanges` within the emitted preview mesh
  triangle count.
- The sample smoke reports 3 surface mappings and 6 mapped triangles.
- Curved fillet faces remain unmapped until a more expressive semantic face
  mapping slice exists.
- The response still does not expose OCCT topology IDs or stable editable
  triangle IDs.

### Tests
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- No new manual UI poke for this chunk; the mappings are a backend contract for
  a later selection/highlight slice.
- Optional developer poke: run
  `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build` and
  confirm `previewSurfaceMappings: 3` and `previewMappedTriangles: 6`.

---

## M68 - Preview Surface Range Highlight

### Goal
Use disposable `PreviewSurfaceMapping` ranges to visually highlight the selected
semantic surface in the generated preview mesh, without adding mesh picking.

### Tasks
- [x] Resolve selected semantic surface IDs to preview mesh triangle ranges.
- [x] Tint/stroke selected mapped triangles in the viewport mesh painter.
- [x] Add a widget-test marker for active preview surface highlighting.
- [x] Keep existing semantic hit testing and workplane overlays unchanged.
- [x] Update docs, roadmap, tasks, and worklog.

### Done Criteria
- Selecting a semantic surface can activate mapped mesh-surface highlighting
  when `previewMesh.surfaces` contains that semantic ID.
- Invalid or out-of-range preview triangle ranges are ignored safely.
- Surface selection still comes from existing semantic UI/hit zones, not from
  clicking generated mesh triangles.
- The highlight is display-only and does not store triangle IDs in the project.

### Tests
- `flutter test test\widget_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Select `Top lid` from the browser or viewport.
- Confirm the generated mesh body shows a subtle cyan highlight on the mapped
  top-lid range while the existing workplane overlay still appears.
- Click/selection behavior should feel the same as before; this chunk does not
  add triangle picking.

---

## M69 - Native Shell/Cavity Slice

### Goal
Turn the native rounded enclosure preview from a solid block into the first
validated top-open shell/cavity generated from semantic wall thickness.

### Tasks
- [x] Add native shell/cavity generation after the rounded outer B-Rep.
- [x] Build a rounded internal cavity tool from `wallThickness`.
- [x] Cut the top-open body with OCCT Boolean subtraction.
- [x] Validate the resulting shell/cavity with `BRepCheck_Analyzer`.
- [x] Keep Flutter output limited to preview mesh data, semantic ranges, and
      metrics.
- [x] Map `main_enclosure.top_lid.outer` to the visible top rim until the real
      lid/body split exists.
- [x] Update native smoke expectations, docs, tasks, and worklog.

### Done Criteria
- Native worker metrics report `shellCavityApplied: true`,
  `shellCavityValid: true`, `shellCavityToolCount: 1`, and
  `shellOpening: top`.
- Sample native smoke reports 1198 vertices, 1550 triangles, 3 surface
  mappings, and 494 mapped triangles.
- Sample volume drops to `33756.044084`, proving the body is no longer a solid
  block.
- Generated B-Rep, topology IDs, and preview triangle IDs stay out of editable
  project JSON.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Confirm the generated body now reads as an open shell/tray rather than a
  closed solid block.
- Select `Top lid` and confirm the cyan highlight follows the visible top rim.
- Orbit and zoom; the shell should stay faceted but stable, with no old flat
  schematic body replacing it.

---

## M70 - Native USB-C Cutout Slice

### Goal
Consume the first `usb_c_cutout` feature intent in the native OCCT worker and
subtract a rounded front-wall port opening from the generated shell.

### Tasks
- [x] Parse `featureIntents` in the native worker without changing editable
      project JSON.
- [x] Support first-pass `usb_c_cutout` intents targeting
      `main_enclosure.front_wall.outer`.
- [x] Read width, height, corner radius, and optional
      `placement.surfacePosition`.
- [x] Build a rounded rectangular cut tool and subtract it from the shell.
- [x] Report native feature-cut metrics and ignored unsupported intent count.
- [x] Update native smoke expectations, docs, roadmap, tasks, and worklog.

### Done Criteria
- Native smoke reports `featureIntentCount: 2`, `nativeFeatureCutCount: 1`,
  `nativeIgnoredFeatureIntentCount: 1`, and `nativeUsbCCutoutCount: 1`.
- Sample preview reports 1418 vertices, 1754 triangles, 3 surface mappings, and
  538 mapped triangles.
- Sample volume drops to `33664.517631`, proving the USB-C cutout removed body
  material.
- Unsupported button intent remains ignored for this slice rather than being
  flattened or partially generated.
- Generated B-Rep, topology IDs, and preview triangle IDs stay out of editable
  project JSON.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Orbit to the front wall and confirm a small USB-C opening is visible.
- Select `USB-C` / `front_usb_c` and confirm the inspector still edits the
  semantic feature; this chunk does not add mesh picking.
- Select `Top lid` and confirm the top-rim highlight still works.

---

## M71 - Native USB-C Feature Range Highlight

### Goal
Expose a disposable native preview range for the generated `front_usb_c`
opening and let the Flutter viewport highlight it when the semantic feature is
selected.

### Tasks
- [x] Keep body surface range classification separate from feature range
      classification.
- [x] Add a native USB-C cutout face-range classifier that avoids mapping the
      whole front wall to the feature.
- [x] Emit `front_usb_c` as an additional preview mesh surface mapping.
- [x] Let selected semantic features use preview mesh ranges in the viewport.
- [x] Add widget coverage for selected feature range highlighting.
- [x] Update native smoke, scaffold tests, docs, tasks, and worklog.

### Done Criteria
- Native smoke reports 1418 vertices, 1754 triangles, 4 preview surface
  mappings, and 636 mapped triangles.
- Surface mappings include `main_enclosure.top_lid.outer`,
  `main_enclosure.front_wall.outer`, `main_enclosure.bottom_inside`, and
  `front_usb_c`.
- Selecting `front_usb_c` can activate the preview mesh highlight without using
  persistent triangle IDs or OCCT topology IDs.
- Editable project JSON remains semantic; preview ranges are disposable output
  only.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected feature highlights mapped preview mesh range" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Select `USB-C` / `front_usb_c` and confirm a cyan highlight appears around
  the generated USB-C opening.
- Select `Front wall` and confirm the front wall still has its own selection.
- Select `Top lid` and confirm the top-rim highlight still works.

---

## M72 - Native Front Glass Recess Slice

### Goal
Consume a first `glass_recess` feature intent on the front wall and generate a
shallow rounded recess in native OCCT B-Rep while keeping editable project state
semantic.

### Tasks
- [x] Add a typed native `GlassRecessRequest`.
- [x] Parse `glass_recess` intents with width, height, recess depth, ledge
      width, corner radius, and optional `placement.surfacePosition`.
- [x] Support front-wall recesses only for this slice; unsupported targets stay
      ignored.
- [x] Build a shallow rounded rectangular recess tool and subtract it from the
      shell without cutting through the wall.
- [x] Emit native glass-recess metrics and a disposable `front_glass_recess`
      preview range.
- [x] Update smoke tests, docs, tasks, roadmap, and worklog.

### Done Criteria
- Native smoke reports 1594 vertices, 1914 triangles, 5 preview surface
  mappings, and 796 mapped triangles.
- Native smoke reports `featureIntentCount: 3`, `nativeFeatureCutCount: 2`,
  `nativeIgnoredFeatureIntentCount: 1`, `nativeUsbCCutoutCount: 1`, and
  `nativeGlassRecessCount: 1`.
- Surface mappings include `front_usb_c` and `front_glass_recess`.
- The glass recess is a shallow front-wall generated feature, not an editable
  mesh/topology object.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Select `Front wall`, create `Посадка под стекло`, set a modest size such as
  width `24`, height `10`, depth around `1`, and confirm.
- Confirm a shallow rounded recess appears on the front wall; if needed, orbit
  a little because it is intentionally not a through-window yet.
- Select the created `glass_recess_*` feature and confirm its semantic
  inspector still edits parameters.

---

## M73 - Native Front Button Group Cutouts

### Goal
Consume front-wall `button_group` feature-group intents in the native OCCT
worker and generate circular button cutouts while keeping the group one
editable semantic object.

### Tasks
- [x] Record OCCT cylinder-tool research before implementation.
- [x] Add native `ButtonGroupCutoutRequest` and item parsing for derived group
      items.
- [x] Support `button_group` intents targeting
      `main_enclosure.front_wall.outer` only in this slice.
- [x] Build cylindrical cut tools with `BRepPrimAPI_MakeCylinder` and subtract
      one tool per derived button item.
- [x] Count supported semantic button groups separately from physical cut
      operations.
- [x] Emit one disposable preview range keyed by the group semantic ID.
- [x] Allow selected `FeatureGroup` objects to use preview surface ranges for
      highlighting.
- [x] Update smoke tests, source-contract tests, widget coverage, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 1886 vertices, 2210 triangles, 6 preview surface
  mappings, and 1092 mapped triangles.
- Native smoke reports `featureIntentCount: 4`, `nativeFeatureCutCount: 4`,
  `nativeIgnoredFeatureIntentCount: 1`, `nativeButtonGroupCount: 1`, and
  `nativeButtonCutoutCount: 2`.
- Surface mappings include `front_buttons` as one semantic group mapping, not
  per-button editable objects.
- Generated B-Rep, topology IDs, and preview triangle IDs stay out of editable
  project JSON.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected feature group highlights mapped preview mesh range" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Select `Front wall`, click the button-group tool, create a small row group
  such as count `2`, spacing `14`, and diameter `8`.
- Orbit to the front wall and confirm the new group creates round button
  cutouts in addition to the USB-C opening.
- Select the created front-wall button group and confirm the inspector still
  edits the group as one object.
- Select the button group and confirm its generated holes highlight together.
- Top-lid button holes are intentionally still pending until the lid/body split
  exists.

---

## M74 - Native Bottom Standoff Mounts

### Goal
Consume `standoff_mounts` feature-group intents targeting the bottom inside
surface and generate simple cylindrical screw standoffs in native OCCT B-Rep
while keeping the mount set one editable semantic group.

### Tasks
- [x] Record OCCT fuse/standoff research before implementation.
- [x] Add native `StandoffMountGroupRequest` and item parsing for derived
      mounting-hole positions.
- [x] Support `standoff_mounts` intents targeting
      `main_enclosure.bottom_inside` only in this slice.
- [x] Build cylindrical boss geometry with a central blind hole per item.
- [x] Fuse generated bosses into the top-open enclosure shell.
- [x] Track standoff group/item metrics separately from other feature
      operations.
- [x] Emit one disposable preview range keyed by the standoff group semantic
      ID.
- [x] Add smoke, source-contract, and widget coverage for standoff mappings.
- [x] Update docs, tasks, roadmap, and worklog.

### Done Criteria
- Native smoke reports 3054 vertices, 3362 triangles, 7 preview surface
  mappings, and 1956 mapped triangles.
- Native smoke reports `featureIntentCount: 5`, `nativeFeatureCutCount: 8`,
  `nativeIgnoredFeatureIntentCount: 1`, `nativeStandoffGroupCount: 1`, and
  `nativeStandoffMountCount: 4`.
- Surface mappings include `standoff_mounts_1` as one semantic group mapping,
  not per-standoff editable objects.
- Generated B-Rep, topology IDs, and preview triangle IDs stay out of editable
  project JSON.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected standoff group highlights mapped preview mesh range" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Select `button_board_placement`, click the mount tool, keep/default or set
  standoff diameter `5`, hole `2.2`, height `4`, then confirm.
- Orbit toward the inside bottom and confirm four cylindrical standoffs appear
  around the board footprint.
- Select the created `standoff_mounts_1` group and confirm the inspector still
  edits the group as one object.
- Confirm the generated standoffs highlight together when the group is
  selected.

---

## M75 - Native Top Screw Lid Bosses

### Goal
Generate first native screw bosses for enclosures whose semantic lid spec is
`top_screw_lid`, without adding editable solids or exposing CAD operations.

### Tasks
- [x] Record OCCT screw-boss generation research before implementation.
- [x] Parse `Enclosure.lid.type` in the native worker request.
- [x] Derive four safe default screw-boss positions from inner enclosure
      dimensions.
- [x] Build cylindrical bosses with central pilot holes.
- [x] Fuse generated bosses into the top-open shell before feature cutouts and
      mount groups.
- [x] Emit native lid screw boss metrics and a disposable generated preview
      range.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 4222 vertices, 4514 triangles, 8 preview surface
  mappings, and 2820 mapped triangles.
- Native smoke reports `nativeLidScrewBossCount: 4` and
  `nativeLidScrewPilotCount: 4`.
- Surface mappings include `main_enclosure.lid_screw_bosses` as generated
  semantic preview output.
- Generated B-Rep, topology IDs, and preview triangle IDs stay out of editable
  project JSON.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Orbit into the enclosure corners and confirm four taller screw bosses appear
  for the sample `top_screw_lid` body.
- Create `Крепёж` from `button_board_placement` and confirm the board
  standoffs still appear separately from the lid screw bosses.
- Select/edit the enclosure lid type in the inspector if needed; generated
  bosses are tied to the semantic lid spec, not separate editable objects.

---

## M76 - Native Top Lid Plate Preview

### Goal
Generate the first separate native preview lid plate for `top_screw_lid`
enclosures, without changing editable project JSON or pretending the full
lid/body mechanical split is complete.

### Tasks
- [x] Record OCCT compound/lid-preview research before implementation.
- [x] Add generated top lid plate request data derived from semantic
      `Enclosure.lid`.
- [x] Build a rounded preview lid plate above the body.
- [x] Assemble body plus lid plate as an OCCT compound for preview meshing and
      metrics.
- [x] Emit `nativeGeneratedLidPlateCount`.
- [x] Map `main_enclosure.generated_top_lid` as disposable preview output while
      keeping `main_enclosure.top_lid.outer` semantic highlighting.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 5022 vertices, 5574 triangles, 9 preview surface
  mappings, and 3782 mapped triangles.
- Native smoke reports `nativeGeneratedLidPlateCount: 1`.
- Native preview bounds are `[-60, -35, 0]` to `[60, 35, 32]`.
- Surface mappings include `main_enclosure.generated_top_lid`.
- Generated lid plate data remains disposable B-Rep output, not editable
  project state.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Confirm the viewport label still shows `occt_worker_native_occt`.
- Orbit above the enclosure and confirm a separate rounded lid plate floats
  above the open body.
- Select the enclosure/top lid area and confirm highlight still appears on lid
  preview ranges.
- Confirm existing USB-C, glass, button, standoff, and screw-boss highlights
  still work.

---

## M77 - Native Top Lid Screw Holes

### Goal
Cut first-pass screw clearance holes through the generated `top_screw_lid`
preview plate, aligned to the generated lid screw bosses, without adding
editable per-hole solids or raw topology state.

### Tasks
- [x] Record OCCT cylinder-cut research for generated lid screw holes.
- [x] Derive top lid screw clearance holes from generated lid screw boss
      positions.
- [x] Cut the holes through the generated top lid plate before adding it to the
      preview assembly compound.
- [x] Emit `nativeGeneratedLidScrewHoleCount`.
- [x] Map `main_enclosure.generated_top_lid_screw_holes` as disposable preview
      output.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 5606 vertices, 6166 triangles, 10 preview surface
  mappings, and 5102 mapped triangles.
- Native smoke reports `nativeGeneratedLidPlateCount: 1` and
  `nativeGeneratedLidScrewHoleCount: 4`.
- Surface mappings include `main_enclosure.generated_top_lid_screw_holes`.
- Generated screw holes remain derived B-Rep output, not editable project
  state.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit above the floating top lid plate and confirm four screw holes are cut
  through it.
- Confirm the holes line up over the four body screw bosses.
- Select the top lid/holes area and confirm highlight still behaves as preview
  range selection, not as editable hole objects.

---

## M78 - Native Top Lid Locating Lip

### Goal
Add a first-pass underside locating lip to the generated `top_screw_lid`
preview plate so the lid starts to express mating geometry while remaining
generated, disposable B-Rep output.

### Tasks
- [x] Record OCCT ring cut/fuse research for the generated lid locating lip.
- [x] Derive lip size from enclosure wall thickness, inner opening, and a
      small clearance.
- [x] Build a rounded rectangular ring under the generated top lid plate.
- [x] Fuse the lip into the generated lid before screw clearance holes are cut.
- [x] Emit `nativeGeneratedLidLipCount`.
- [x] Map `main_enclosure.generated_top_lid_locating_lip` as disposable
      preview output.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 6536 vertices, 7292 triangles, 11 preview surface
  mappings, and 7464 mapped triangles.
- Native smoke reports `nativeGeneratedLidPlateCount: 1`,
  `nativeGeneratedLidLipCount: 1`, and
  `nativeGeneratedLidScrewHoleCount: 4`.
- Surface mappings include `main_enclosure.generated_top_lid_locating_lip`.
- Generated lip remains derived B-Rep output, not editable project state.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit under/around the floating top lid and confirm a thin inner locating lip
  is visible below the lid plate.
- Confirm the screw holes still pass through the lid and align with the four
  body screw bosses.
- Confirm the lip is preview-generated detail, not a separate editable object
  in the inspector.

---

## M79 - Native Top Lid Body Seat

### Goal
Cut the first body-side locating seat/groove into the top-open enclosure so the
generated lid lip has a matching generated body detail while the editable
project remains semantic.

### Tasks
- [x] Record OCCT box-cut research for the body-side lid seat.
- [x] Derive a generated lid-seat request from `Enclosure.lid` and wall
      thickness.
- [x] Cut four shallow inner-wall seat tools around the top opening before the
      preview assembly is built.
- [x] Validate the generated body after each seat cut.
- [x] Emit `nativeGeneratedLidSeatCount`.
- [x] Map `main_enclosure.generated_top_lid_seat` as disposable preview output.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 6638 vertices, 7328 triangles, 12 preview surface
  mappings, and 8088 mapped triangles.
- Native smoke reports `nativeGeneratedLidSeatCount: 1`,
  `nativeGeneratedLidPlateCount: 1`, `nativeGeneratedLidLipCount: 1`, and
  `nativeGeneratedLidScrewHoleCount: 4`.
- Surface mappings include `main_enclosure.generated_top_lid_seat`.
- The seat remains derived generated B-Rep output, not an editable groove or
  raw OCCT topology object.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit around the top opening of the body and confirm a shallow inner step is
  visible around the rim.
- Orbit under/around the floating lid and confirm its locating lip still
  aligns visually with that body-side seat.
- Confirm screw holes still pass through the lid and align over the four body
  screw bosses.
- Confirm the body seat is generated preview detail, not a separate editable
  object in the inspector.

---

## M80 - Native Top Lid Fit Preview

### Goal
Move the generated top lid from a high exploded preview into a clearer
fit-preview position: the lid is still slightly open for inspection, but the
locating lip now visually enters the body-side seat.

### Tasks
- [x] Decouple generated lid lip height from the old exploded preview gap.
- [x] Add a small generated lid fit-preview gap derived from wall thickness.
- [x] Emit `nativeGeneratedLidFitPreviewGap`.
- [x] Update native smoke bounds/dimensions and source-contract tests.
- [x] Update docs, tasks, roadmap, and worklog.

### Done Criteria
- Native smoke reports the same topology counts as M79: 6638 vertices, 7328
  triangles, and 12 preview surface mappings.
- Native smoke reports `nativeGeneratedLidFitPreviewGap: 0.35`.
- Native preview assembly bounds are `[-60, -35, 0]` to `[60, 35, 30.35]`.
- The generated lid remains disposable preview B-Rep output, not editable
  assembly state.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit above and slightly beside the enclosure.
- Confirm the lid is no longer floating high above the body; it should sit just
  above the top rim with a small visible gap.
- Orbit around the top opening and confirm the lid lip reads as entering the
  body-side seat.
- Confirm screw holes still align over the four body screw bosses.

---

## M81 - Native Top Lid Button Cutouts

### Goal
Generate first native circular button cutouts through the generated
`top_screw_lid` preview lid when a semantic `button_group` targets
`main_enclosure.top_lid.outer`, while keeping the group editable as one
semantic object.

### Tasks
- [x] Record OCCT cylinder-cut research for generated top-lid button holes.
- [x] Parse `button_group` intents targeting `main_enclosure.top_lid.outer`.
- [x] Validate top-lid button positions against the lid safe inner area.
- [x] Cut vertical cylindrical button holes through the generated lid plate.
- [x] Keep front-wall button cutouts on the body path and top-lid button
      cutouts on the generated lid path.
- [x] Emit generated-lid button metrics and preview surface mapping.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 7222 vertices, 7920 triangles, 13 preview surface
  mappings, and 11166 mapped triangles.
- Native smoke reports `nativeGeneratedLidFeatureCutCount: 4`,
  `nativeGeneratedLidButtonGroupCount: 1`, and
  `nativeGeneratedLidButtonCutoutCount: 4`.
- Surface mappings include `top_lid_buttons`.
- The editable project still stores one semantic button group, not generated
  lid hole solids or per-hole topology.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit above the lid and confirm four round button holes are cut through the
  generated top lid.
- Confirm the lid still sits close to the body with the small fit-preview gap.
- Confirm screw holes still align over the four body screw bosses.
- Select/create a top-lid button group and confirm it remains one editable
  semantic group in the inspector.

---

## M82 - Native Top Lid Glass Recess

### Goal
Generate a first shallow rounded glass/insert recess in the generated
`top_screw_lid` preview lid when a semantic `glass_recess` targets
`main_enclosure.top_lid.outer`, while keeping the feature as semantic project
data.

### Tasks
- [x] Record OCCT box-cut/fillet/cut research for generated top-lid recesses.
- [x] Parse `glass_recess` intents for both front wall and top lid target
      surfaces.
- [x] Validate top-lid recess size, depth, corner radius, and face-local
      position against the generated lid safe area.
- [x] Cut a shallow rounded rectangular recess from the generated lid plate
      without cutting through the lid.
- [x] Keep front-wall glass recesses on the body path and top-lid glass
      recesses on the generated lid path.
- [x] Emit generated-lid glass-recess metrics and preview surface mapping.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 7398 vertices, 8080 triangles, 14 preview surface
  mappings, and 11604 mapped triangles.
- Native smoke reports `nativeGeneratedLidFeatureCutCount: 5`,
  `nativeGeneratedLidGlassRecessCount: 1`,
  `nativeGeneratedLidGlassRecessFilletedEdgeCount: 8`,
  `nativeGeneratedLidButtonGroupCount: 1`, and
  `nativeGeneratedLidButtonCutoutCount: 4`.
- Surface mappings include `top_lid_glass_recess` and `top_lid_buttons`.
- The editable project still stores semantic `glass_recess` and
  `button_group` data, not generated lid recess solids or raw topology IDs.

### Tests
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit above the lid and confirm a shallow rounded rectangular recess appears
  on the generated top lid.
- Confirm the four round top-lid button holes are still cut through the lid.
- Confirm the lid still sits close to the body with the small fit-preview gap.
- Confirm screw holes still align over the four body screw bosses.

---

## M83 - Native Top Lid Glass Ledge Window

### Goal
Make `ledgeWidth` produce real generated geometry for top-lid glass recesses:
the generated lid now has a shallow outer glass seat plus an inner through
window, leaving a support ledge/bezel around the opening.

### Tasks
- [x] Reuse OCCT box/fillet/cut research for the generated inner window.
- [x] Validate native `ledgeWidth` so it leaves a positive inner window.
- [x] Cut a rounded inner window through the generated lid plate after the
      shallow recess cut.
- [x] Keep the ledge/window generated from one semantic `glass_recess`
      feature, not separate editable solids.
- [x] Emit generated-lid glass-window metrics.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 7574 vertices, 8244 triangles, 14 preview surface
  mappings, and 12054 mapped triangles.
- Native smoke reports `nativeGeneratedLidFeatureCutCount: 6`,
  `nativeGeneratedLidGlassRecessCount: 1`,
  `nativeGeneratedLidGlassRecessFilletedEdgeCount: 8`,
  `nativeGeneratedLidGlassWindowCount: 1`, and
  `nativeGeneratedLidGlassWindowFilletedEdgeCount: 8`.
- Surface mappings still include `top_lid_glass_recess` for the semantic
  glass feature.
- The editable project still stores one semantic `glass_recess`, not a
  generated pocket object plus generated window object.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit above the lid and confirm the glass feature now reads as a recessed
  frame with an inner opening, not just a flat shallow pocket.
- Confirm the support ledge remains around the window.
- Confirm the four round top-lid button holes and screw holes are still
  present and aligned.

---

## M84 - Native Front Glass Ledge Window

### Goal
Make front-wall `glass_recess` features use `ledgeWidth` the same way as the
generated top lid: a shallow outer seat plus an inner through-window, still
stored as one semantic glass recess.

### Tasks
- [x] Reuse OCCT box/fillet/cut research for the front-wall inner window.
- [x] Cut a rounded inner window through the front wall after the shallow
      front glass recess cut.
- [x] Keep front-wall glass window preview faces mapped to the original
      semantic feature id.
- [x] Emit native front glass-window metrics.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 7750 vertices, 8408 triangles, 14 preview surface
  mappings, and 12218 mapped triangles.
- Native smoke reports `nativeFeatureCutCount: 9`,
  `nativeGlassRecessCount: 1`, `nativeGlassRecessFilletedEdgeCount: 8`,
  `nativeGlassWindowCount: 1`, and
  `nativeGlassWindowFilletedEdgeCount: 8`.
- Surface mappings still include `front_glass_recess` for the semantic glass
  feature.
- The editable project still stores one semantic `glass_recess`, not a
  separate generated window object.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit to the front wall and confirm the glass feature now has an inner
  opening with a support ledge/frame around it.
- Confirm the front USB-C cutout and front button holes still read separately.
- Confirm the top-lid glass window and top-lid button holes still remain.

---

## M85 - Native Button Rings

### Goal
Generate first-pass raised rings/bezels around semantic button holes on the
front wall and generated top lid, without adding editable per-ring CAD objects
or flattening `button_group` semantics.

### Tasks
- [x] Add shared native button-ring sizing helpers.
- [x] Build front-wall rings as annular OCCT cylinder shapes around existing
      front button cutouts.
- [x] Build generated top-lid rings as annular OCCT cylinder shapes around
      existing top-lid button cutouts.
- [x] Fuse generated rings after their matching holes are cut.
- [x] Keep ring faces mapped to the original semantic button group ids.
- [x] Emit native ring metrics for front-wall and generated top-lid buttons.
- [x] Update native smoke expectations, source-contract tests, docs, tasks,
      roadmap, and worklog.

### Done Criteria
- Native smoke reports 9502 vertices, 10136 triangles, 14 preview surface
  mappings, and 16684 mapped triangles.
- Native smoke reports bounds `[-60, -35.45, 0]` to `[60, 35, 30.8]`,
  surface area `54964.596483`, and volume `52901.661268`.
- Native smoke reports `nativeButtonRingCount: 2` and
  `nativeGeneratedLidButtonRingCount: 4`.
- Button holes and generated button rings remain mapped to `front_buttons` and
  `top_lid_buttons`.
- The editable project still stores semantic `button_group` data, not
  generated ring solids.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit to the front wall and confirm the two front button holes now have
  small raised rings around them.
- Orbit above the generated lid and confirm the four top-lid button holes now
  have matching raised rings.
- Select/poke the front and top button groups and confirm the holes/rings read
  as one semantic group rather than separate CAD objects.
- Confirm the front and top glass ledge windows still remain visible.

---

## M86 - Semantic Button Ring Controls

### Goal
Expose first-pass button ring/bezel sizing as semantic `button_group`
parameters instead of fixed native constants, while keeping rings generated
from `itemPrototype` rather than editable CAD solids.

### Tasks
- [x] Add `ringWidth` and `ringProtrusion` defaults to manual and
      component-sourced button groups.
- [x] Add contextual inspector controls for ring width and protrusion.
- [x] Add ring width/protrusion fields to the button group creation dialog.
- [x] Preserve ring parameters through geometry protocol feature intents and
      operation plans.
- [x] Parse and validate ring parameters in the native OCCT worker.
- [x] Use semantic ring parameters in native ring generation and preview
      classification.
- [x] Update protocol fixtures, sample project, tests, docs, roadmap, and
      worklog.

### Done Criteria
- Selecting a button group shows editable `ringWidth` and `ringProtrusion`
  controls.
- Creating a component-sourced button group writes `ringWidth: 1.2` and
  `ringProtrusion: 0.45` into `FeatureGroup.itemPrototype`.
- `GeometryFeatureIntent.items[*].parameters` carries the ring values.
- Native smoke still reports 9502 vertices, 10136 triangles, 14 preview surface
  mappings, and 16684 mapped triangles for the default sample.
- Native smoke still reports `nativeButtonRingCount: 2` and
  `nativeGeneratedLidButtonRingCount: 4`.

### Tests
- `dart run tool\generate_geometry_protocol_fixtures.dart`
- `dart format lib\ui\shell\workspace_shell.dart lib\selection\project_selection_resolver.dart lib\validation\project_semantic_validator.dart test\geometry_protocol_test.dart test\occt_native_target_scaffold_test.dart test\widget_test.dart test\project_selection_resolver_test.dart tool\native_occt_worker_metrics_smoke.dart tool\generate_geometry_protocol_fixtures.dart`
- `flutter test test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected button group inspector edits pattern through undo" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group" --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Select an existing or newly created button group.
- In the inspector, change `Ободок` and `Выступ`; confirm undo returns the
  previous values.
- Rebuild/refresh preview if needed and confirm larger values make button
  rings visibly wider/taller while the group remains one semantic object.
- Create a component-sourced button group and confirm its defaults are
  `Ободок 1.2` and `Выступ 0.45`.

---

## M87 - Native Button Cap/Stem Preview

### Goal
Generate first-pass native preview geometry for semantic plunger-style
button caps and stems from `button_group.itemPrototype`, without converting
the group into editable CAD solids.

### Tasks
- [x] Add semantic cap/stem defaults to manual and component-sourced button
      groups.
- [x] Add contextual inspector and creation-dialog controls for cap diameter,
      cap height, stem diameter, and stem depth.
- [x] Preserve cap/stem values through geometry feature intents and operation
      plans.
- [x] Parse and validate cap/stem values in the native OCCT worker.
- [x] Generate separate disposable cap/stem preview solids for front-wall and
      generated top-lid button groups when `mode` is `plunger`.
- [x] Keep cap/stem preview faces mapped to the original semantic button
      group ids.
- [x] Update protocol fixtures, native smoke expectations, docs, tests,
      roadmap, and worklog.

### Done Criteria
- Selecting a button group shows editable cap/stem controls.
- Creating a component-sourced button group writes `capDiameter`,
  `capHeight`, `stemDiameter`, and `stemDepth` into `FeatureGroup.itemPrototype`.
- Native smoke reports 11254 vertices, 11816 triangles, 14 preview surface
  mappings, and 16478 mapped triangles.
- Native smoke reports `nativeButtonCapCount: 2`,
  `nativeButtonStemCount: 2`, `nativeGeneratedLidButtonCapCount: 4`, and
  `nativeGeneratedLidButtonStemCount: 4`.
- The editable project still stores one semantic `button_group`, not
  generated button cap or stem solids.

### Tests
- `dart run tool\generate_geometry_protocol_fixtures.dart`
- `dart format lib\ui\shell\workspace_shell.dart lib\selection\project_selection_resolver.dart lib\validation\project_semantic_validator.dart test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\project_semantic_validator_test.dart test\occt_native_target_scaffold_test.dart test\widget_test.dart tool\generate_geometry_protocol_fixtures.dart tool\native_occt_worker_metrics_smoke.dart`
- `flutter test test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\project_semantic_validator_test.dart test\occt_native_target_scaffold_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected button group inspector edits pattern through undo" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group" --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit to the front wall and confirm the two front buttons now show small
  raised caps/stems inside the existing rings.
- Orbit above the generated lid and confirm four top-lid buttons now show
  matching cap/stem previews.
- Select a button group and change `Колпачок`, `Высота кнопки`, `Ножка`, or
  `Глубина ножки`; confirm undo returns the previous values.
- Switch a button group to `Только отверстия` and confirm cap/stem preview
  generation is disabled after the preview refresh.

---

## M88 - Native Viewport Readability Pass

### Goal
Make the native preview mesh read as the primary model layer while keeping
semantic markers, workplanes, and selection feedback useful as lightweight
annotations instead of a heavy 2D mock drawing over the generated geometry.

### Tasks
- [x] Add a native semantic annotation mode when a `PreviewMesh` is available.
- [x] Reduce duplicate mock selection outlines when the selected semantic id
      already has mapped preview-mesh triangle ranges.
- [x] Soften native surface selection tint and add a single screen-space halo
      around selected mapped ranges.
- [x] Use the secondary accent for mapped feature and feature-group ranges so
      button groups read separately from selected lid/body surfaces.
- [x] Fade workplane, component, feature, and feature-group markers in native
      mesh mode while keeping them selectable semantic affordances.
- [x] Add widget coverage that native preview mesh mode enables the semantic
      overlay sentinel.
- [x] Update viewport docs, tasks, roadmap, and worklog.

### Done Criteria
- Native preview mesh remains display-only; no generated mesh, B-Rep,
  triangle id, or OCCT topology becomes editable state.
- Selection still flows through semantic ids and existing preview surface
  ranges from `GeometryService`.
- A selected surface with mapped preview ranges no longer gets an extra heavy
  mock surface outline on top of the native mesh.
- Feature and feature-group mapped ranges use a warmer highlight/halo so
  button caps, stems, rings, and other semantic details are easier to read.
- Mock workplane and semantic markers remain visible but behave like annotation
  handles over the native preview instead of the main model layer.

### Tests
- `flutter test test\widget_test.dart --plain-name "viewport exposes geometry preview mesh from service" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected feature group highlights mapped preview mesh range" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Select `Top lid` and confirm the center model reads less like a solid cyan
  2D mock overlay; it should show a softer mesh tint plus a single halo.
- Select `Группа кнопок` / `abxy_buttons` and confirm button-related selection
  reads with a warmer accent over the generated lid/body preview.
- Orbit, pan, and zoom; confirm semantic handles remain useful without hiding
  the native preview mesh.

---

## M89 - Viewport Navigation Presets

### Goal
Make manual inspection faster by adding compact standard camera presets to the
viewport while keeping camera state transient and separate from editable
project data.

### Tasks
- [x] Add typed viewport view presets for ISO, top, front, left, and right.
- [x] Add a controller method that applies a preset, resets pan/zoom, and keeps
      current semantic selection/ghost overlays intact.
- [x] Replace the single ISO fit square with compact preset buttons plus a fit
      icon button.
- [x] Surface the active preset in the viewport label.
- [x] Add controller and widget tests for standard view switching.
- [x] Update navigation/viewport docs, tasks, roadmap, and worklog.

### Done Criteria
- Presets change only transient `ViewportState`; they do not write to
  `ProjectModel`, undo history, geometry requests, or saved project JSON.
- Viewport selection and ghost previews survive preset switching.
- The top-right viewport controls expose TOP, FRT, RGT, LFT, ISO, and fit.
- The viewport label reports the active preset when yaw/pitch match it.
- No mesh, B-Rep, triangle id, or OCCT topology is used for view switching.

### Tests
- `flutter test test\viewport_controller_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "viewport preset controls switch standard camera views" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Click TOP, FRT, RGT, LFT, and ISO in the top-right viewport controls.
- Confirm the viewport label changes to the clicked preset and the model recenters.
- Select `Top lid` or `Группа кнопок` and switch presets; confirm selection
  and semantic overlays stay active.

---

## M90 - Semantic Plunger Travel Controls

### Goal
Make button plunger motion safer to iterate by storing travel and clearance as
semantic `button_group.itemPrototype` data, exposing the values in the
contextual UI, and validating obvious impossible plunger setups before real
guide-wall/travel-stop geometry is generated.

### Tasks
- [x] Add default `travel`, `switchClearance`, and `guideClearance` values to
      manual and component-sourced button groups.
- [x] Expose `Ход`, `Зазор до свитча`, and `Зазор направл.` controls in the
      button-group dialog and selected-group inspector.
- [x] Serialize the new semantic fields through geometry protocol requests and
      operation plans without turning them into editable generated solids.
- [x] Add semantic validation for plunger travel depth and guide clearance.
- [x] Keep `mode: cutout` button groups quiet for plunger-only validation.
- [x] Update docs, tasks, roadmap, worklog, sample project, and fixtures.

### Done Criteria
- `button_group` remains one editable semantic group; generated caps/stems stay
  disposable preview geometry.
- New parameters live in `FeatureGroup.itemPrototype` and round-trip through
  geometry request fixtures.
- Undo restores edited travel/clearance values from the inspector.
- Plunger validation catches over-deep travel and guide clearance wider than
  the button opening.
- No OCCT worker semantics, raw topology IDs, or editable mesh/STL workflow are
  exposed to Flutter.

### Tests
- `flutter test test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\project_semantic_validator_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected button group inspector edits pattern through undo" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Select `Группа кнопок` / `abxy_buttons` in the left feature list.
- Confirm the inspector shows `Ход`, `Зазор до свитча`, and `Зазор направл.`.
- Edit `Ход`, press Enter, then click undo and confirm it returns.
- From the board placement, create a component-sourced button group and confirm
  the dialog also shows the same travel/clearance defaults.

---

## M91 - Native Plunger Guide/Stop Preview

### Goal
Generate first-pass native preview geometry for plunger guide sleeves and
travel-stop collars from semantic button-group travel/clearance values, while
keeping editable project state semantic and generator-first.

### Tasks
- [x] Review official OCCT cylinder, Boolean cut, and compound-builder docs
      before adding the generated guide/stop geometry.
- [x] Parse `travel`, `switchClearance`, and `guideClearance` in the native
      button-group item request.
- [x] Add annular guide sleeve generation for front-wall and generated top-lid
      plunger buttons.
- [x] Add first-pass travel-stop collar preview geometry for the same plunger
      buttons.
- [x] Add native metrics for front and generated top-lid guide/stop counts.
- [x] Add semantic validation for guide-wall fit against the button opening.
- [x] Update native smoke expectations, docs, tasks, roadmap, and worklog.

### Done Criteria
- `button_group` remains one editable semantic group; guide sleeves and travel
  stops are disposable generated preview geometry.
- Native smoke reports `nativeButtonGuideCount: 2`,
  `nativeButtonTravelStopCount: 2`,
  `nativeGeneratedLidButtonGuideCount: 4`, and
  `nativeGeneratedLidButtonTravelStopCount: 4` for the sample project.
- Semantic validation catches guide-wall setups that cannot fit inside the
  button opening.
- Flutter still talks through `GeometryService`/worker protocol and receives
  preview mesh/metrics only, not OCCT topology or editable B-Rep.

### Tests
- `dart format lib\validation\project_semantic_validator.dart test\project_semantic_validator_test.dart tool\native_occt_worker_metrics_smoke.dart test\occt_native_target_scaffold_test.dart`
- `flutter test test\project_semantic_validator_test.dart test\occt_native_target_scaffold_test.dart --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Select `abxy_buttons` or another plunger-style button group.
- Orbit/zoom around the front buttons and top-lid buttons; each plunger preview
  should now have a small extra sleeve/collar shape around the cap/stem area.
- Edit `Ход`, `Зазор до свитча`, or `Зазор направл.` and confirm undo still
  restores the previous semantic value.
- Treat the center model as a first-pass mechanical preview, not polished CAD:
  the important check is that the added guide/stop detail is visible and remains
  tied to one semantic button group.

---

## M92 - Native Viewport De-Clutter

### Goal
Make the native preview easier to inspect after manual screenshot review by
reducing always-on schematic overlays and triangle-wire noise while preserving
semantic selection and hit targets.

### Tasks
- [x] Analyze the latest screenshot for readability issues.
- [x] Add native overlay mute/focus state sentinels for widget coverage.
- [x] Dim component, feature, and feature-group mock annotations when the native
      preview mesh is visible and no matching semantic detail is selected.
- [x] Keep selected semantic details more visible when the user selects a
      feature, feature group, or component placement.
- [x] Reduce default preview-mesh triangle stroke alpha/width so the generated
      model is less visually noisy.
- [x] Update viewport docs, task tracker, roadmap, and worklog.

### Done Criteria
- Project/workspace selection shows the native model as the primary visual
  layer instead of large opaque schematic feature panels.
- Selecting a feature or feature group still brings that semantic annotation
  forward for manual inspection.
- Preview mesh remains display-only; hit testing and editing still use semantic
  IDs, not triangle IDs or OCCT topology.
- Existing preview mesh highlight tests continue to pass.

### Tests
- `flutter test test\widget_test.dart --plain-name "viewport exposes geometry preview mesh from service" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "native preview keeps semantic overlays muted until selected" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- With the project selected, confirm the big center glass/feature rectangle and
  board footprint no longer dominate the native body.
- Select `USB-C`, `Группа кнопок`, and the board placement; each selected
  semantic item should still become visible enough to inspect.
- Orbit/pan/zoom and confirm the body has fewer distracting internal triangle
  lines than in the screenshot.

---

## M93 - Native Surface Workplane Softening

### Goal
Make selected surface inspection calmer in native preview mode by turning the
large surface workplane/grid/snap overlay into a passive hint unless the user is
actively working with a snap target or component placement.

### Tasks
- [x] Analyze the latest `Top lid` screenshot after M92.
- [x] Add native workplane muted/focused state sentinels for widget coverage.
- [x] Keep selected native surface mesh highlighting active.
- [x] Reduce passive surface workplane fill, outline, grid, snap point radius,
      and snap point stroke strength in native preview mode.
- [x] Keep component-placement workplanes and active snap targets focused.
- [x] Update viewport docs, task tracker, roadmap, and worklog.

### Done Criteria
- Selecting `Top lid` in native preview mode no longer draws a dominant cyan
  workplane rectangle/grid over the generated model.
- The selected surface can still highlight mapped preview mesh ranges.
- Selecting a component placement still shows a focused workplane.
- No project model, geometry protocol, mesh picking, or OCCT topology behavior
  changes.

### Tests
- `flutter test test\widget_test.dart --plain-name "native preview softens surface workplane overlay" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Select `Top lid`; the big workplane rectangle/snap grid should be much less
  dominant than in the screenshot.
- Select `Custom Button Board` / `button_board_placement`; its workplane should
  still be visible enough for placement work.
- Click a snap point and confirm the active snap/placement preview still becomes
  noticeable.

---

## M94 - Native Mesh Semantic Picking

### Goal
Remove the confusing passive 2D surface workplane from normal native preview
inspection and make direct clicks on the generated preview mesh select mapped
semantic parts.

### Tasks
- [x] Explain why the old 2D overlay existed and why native parts were not
      selectable yet.
- [x] Make snap points keep priority, then run native preview mesh hit-testing,
      then fall back to old mock hit zones.
- [x] Project preview mesh vertices with the same math used by the painter.
- [x] Hit-test disposable preview triangle ranges and map the hit back to a
      semantic surface, feature, feature group, component placement, or
      enclosure.
- [x] Hide passive native surface workplanes unless a snap/placement workflow is
      active.
- [x] Add widget coverage for native mesh click selection.
- [x] Update viewport docs, task tracker, roadmap, and worklog.

### Done Criteria
- Clicking a mapped native preview triangle selects the semantic object behind
  that mapped range.
- Triangle IDs remain transient preview implementation details and are not saved
  into `ProjectModel`.
- Snap points still have priority when the user clicks an explicit snap target.
- Passive `Top lid` selection no longer draws the large 2D workplane overlay
  over the generated mesh.

### Tests
- `flutter test test\widget_test.dart --plain-name "native preview mesh click selects mapped semantic feature" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "native preview softens surface workplane overlay" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Click directly on visible native model areas: lid/body/detail ranges should
  select their mapped semantic item when a mapping exists.
- Select `Top lid`; the old large 2D workplane rectangle should not sit on top
  of the model during passive inspection.
- Click explicit snap points only when you want the snap workflow; those should
  still work.

---

## M95 - Native Preview Mesh De-Noise

### Goal
Reduce visible triangulation noise in the current `CustomPaint` native preview
without changing semantic project data, OCCT B-Rep generation, or preview mesh
protocols.

### Tasks
- [x] Add a small tested helper that derives boundary edges from preview mesh
      triangles.
- [x] Stop drawing every unselected internal triangle edge in the viewport.
- [x] Draw only mesh boundary edges and selected semantic-range boundary edges.
- [x] Slightly soften per-triangle shading contrast.
- [x] Keep selected mapped surface/feature highlights and native mesh picking
      intact.
- [x] Update viewport docs, task tracker, roadmap, and worklog.

### Done Criteria
- A two-triangle quad can hide its shared internal diagonal while preserving
  its outer boundary.
- Selected semantic ranges get a contour without reintroducing internal mesh
  wire noise.
- No project model, geometry protocol, OCCT worker, or editable geometry state
  changes.
- Existing native mesh highlight and picking widget tests still pass.

### Tests
- `flutter test test\preview_mesh_edges_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "native preview mesh click selects mapped semantic feature" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit the native model and confirm the body looks less like a triangle mesh
  debug view.
- Select `Top lid`, `USB-C`, and a button group; selected mapped ranges should
  still highlight clearly.
- Some faceting will remain because this is still the interim `CustomPaint`
  renderer, not a final shaded 3D viewport.

---

## M96 - Native Top Lid Near-Flush Fit Preview

### Goal
Tighten the generated top lid fit-preview position so the sample lid reads as
near-flush instead of visibly detached, while keeping the generated lid
disposable and not adding editable assembly state.

### Tasks
- [x] Revisit the generated top lid fit-preview gap formula.
- [x] Reduce the sample gap from `0.35 mm` to `0.08 mm` while keeping a tiny
      non-zero inspection separation.
- [x] Rebuild the native OCCT worker and update deterministic smoke
      expectations for bounds/dimensions.
- [x] Record the near-flush fit decision in the OCCT research note.
- [x] Update first-geometry docs, task tracker, roadmap, and worklog.

### Done Criteria
- Native smoke reports `nativeGeneratedLidFitPreviewGap=0.08`.
- Native smoke preview bounds are `[-60, -36.65, 0]` to `[60, 35, 31.73]`.
- Preview mesh topology counts remain deterministic.
- No semantic project model, protocol schema, editable assembly state, or raw
  topology IDs are introduced.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit around the top edge; the generated lid should sit much closer to the
  body than before.
- Check that the lid is still visibly a separate generated preview member, not
  a new editable assembly object.
- Select mapped lid/feature ranges and confirm highlighting still works.

---

## M97 - Native Top Lid Planar Plate

### Goal
Make the generated top lid plate read like a flat lid instead of a pillow-like
fully filleted thin box, while preserving rounded outside corners and keeping
generated geometry disposable.

### Tasks
- [x] Add a native OCCT helper that fillets only vertical box edges.
- [x] Route generated top lid plate construction through that helper.
- [x] Keep the main rounded enclosure body on the existing all-edge rounded box
      path.
- [x] Rebuild the native OCCT worker and update deterministic smoke
      expectations.
- [x] Record the decision in the OCCT research note and update docs/tasks.

### Done Criteria
- The generated top lid plate keeps planar top and bottom faces.
- The generated top lid still has rounded outside corners in plan view.
- Native smoke passes with deterministic counts and metrics.
- No semantic project model, protocol schema, editable assembly state, or raw
  topology IDs are introduced.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\occt_native_target_scaffold_test.dart --plain-name "OCCT target source emits deterministic rounded enclosure preview mesh" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- Orbit above the lid; the generated top lid should look flatter and less like
  a rounded pillow.
- Confirm the body itself is still rounded.
- Select mapped lid/feature ranges and confirm highlighting still works.

---

## M98 - Native OCCT Geometry Regression Test

### Goal
Turn the native OCCT known-dimensions smoke coverage into a normal Flutter
test path so sample geometry regressions are caught before STEP/STL work.

### Tasks
- [x] Add a reusable native OCCT regression fixture for the current semantic
      sample project, expected bounds, dimensions, mesh counts, and mapping ids.
- [x] Add a Flutter test that launches the built native OCCT worker when it is
      available locally.
- [x] Keep the test skippable on machines where the opt-in native worker has
      not been built.
- [x] Mark the known-dimensions test task complete and document the command.

### Done Criteria
- The test verifies native capabilities, preview status, bounds, dimensions,
  surface area, volume, mesh counts, mapped triangle ranges, and semantic
  mapping ids.
- The test verifies generated geometry remains non-editable and does not expose
  raw topology or triangle IDs.
- Clean CI without a local OCCT build can skip the integration test instead of
  failing due to a missing executable.
- The native smoke tool remains available as a CLI contract check.

### Tests
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- No new manual UI poke is needed for this chunk.
- Keep using the latest Windows build for visual checks after geometry changes:
  `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

---

## M99 - Native STEP Export Slice

### Goal
Add the first native OCCT `export_step` operation behind the worker boundary so
the generated B-Rep can produce a STEP artifact without becoming editable
project state.

### Tasks
- [x] Add `GeometryRequest.exportStep` with explicit `outputPath`.
- [x] Teach the native OCCT worker to accept `export_step` requests and require
      `options.outputPath`.
- [x] Export the same semantic generated preview assembly through
      `STEPControl_Writer`.
- [x] Suppress OCCT transfer/write stdout so worker stdout remains valid JSON.
- [x] Return a `GeometryArtifact` for the generated STEP file.
- [x] Add native STEP export coverage and update docs/tasks/worklog.

### Done Criteria
- The native OCCT worker capabilities list `export_step` as supported.
- A semantic sample request writes a real `.step` file containing an
  `ISO-10303-21` STEP payload.
- The response returns artifact metadata, export metrics, and
  `editableGeneratedGeometry=false`.
- The response does not include preview mesh data, raw OCCT topology IDs, or
  stable triangle IDs.
- Mock geometry still rejects export operations until mock export behavior is
  deliberately added.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\geometry_protocol_test.dart --plain-name "STEP export request carries output path and semantic feature intents" --reporter compact`
- `flutter test test\occt_native_target_scaffold_test.dart --plain-name "OCCT target source emits deterministic rounded enclosure preview mesh" --reporter compact`
- `flutter test test\native_occt_step_export_test.dart --reporter compact`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- No new app UI is exposed in this chunk.
- The generated STEP path is currently verified by test; manual export UI comes
  in a later chunk.

---

## M100 - Toolbar STEP Export

### Goal
Expose the first STEP export path through the app toolbar while keeping export
as an output artifact, not editable project state.

### Tasks
- [x] Add a dedicated STEP save-location picker that does not reuse project
      JSON save.
- [x] Wire the toolbar export command to `GeometryRequest.exportStep`.
- [x] Keep export outside undo/redo, project dirty state, and saved project
      JSON.
- [x] Add widget coverage for successful export and double-click/picker guard.
- [x] Update docs, tasks, worklog, latest build, commit, and push.

### Done Criteria
- The toolbar export icon is enabled when file operations are idle.
- Clicking export opens a STEP save dialog with `.step/.stp` handling.
- The shell sends `export_step` to `GeometryService` with the selected
  `options.outputPath`.
- Export success reports the generated artifact in the status bar.
- Export does not save a project file, mark the project clean, or create an
  undo entry.
- A second click while the picker is open does not launch another picker.

### Tests
- `flutter test test\project_file_service_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "export command writes STEP artifact through geometry service" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "export picker opens without pre-picker status rebuild" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Click the top toolbar export/download icon.
- Choose a file name with no extension and confirm.
- Confirm a `.step` file is created and the bottom status says STEP was
  exported.
- Try clicking export twice quickly; only one save dialog should appear.

---

## M101 - Native STL Export Slice

### Goal
Add the first native OCCT `export_stl` artifact path behind the worker boundary
so the generated B-Rep can produce a binary STL without making STL editable
project state.

### Tasks
- [x] Add `GeometryRequest.exportStl` with explicit `outputPath`.
- [x] Teach the native OCCT worker to accept `export_stl` requests and require
      `options.outputPath`.
- [x] Mesh the generated preview assembly deterministically before STL write.
- [x] Export binary STL through `StlAPI_Writer`.
- [x] Return a `GeometryArtifact` for the generated STL file.
- [x] Add native STL export coverage and update docs/tasks/worklog.

### Done Criteria
- The native OCCT worker capabilities list `export_stl` as supported.
- A semantic sample request writes a real binary `.stl` file.
- The test validates the STL header, triangle count, and expected byte size.
- The response returns artifact metadata, export metrics, and
  `editableGeneratedGeometry=false`.
- The response does not include preview mesh data, raw OCCT topology IDs, or
  stable triangle IDs.
- The app toolbar remains STEP-only until a user-facing format chooser is added.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\geometry_protocol_test.dart --plain-name "STL export request carries output path and semantic feature intents" --reporter compact`
- `flutter test test\occt_native_target_scaffold_test.dart --plain-name "OCCT target source emits deterministic rounded enclosure preview mesh" --reporter compact`
- `flutter test test\native_occt_stl_export_test.dart --reporter compact`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- No new app UI is exposed in this chunk.
- Native STL is verified by test. Manual STL export becomes useful after the
  next UI format-choice chunk.

---

## M102 - Toolbar STEP/STL Export Format Choice

### Goal
Expose STL export through the existing toolbar export command while keeping
STEP/STL files as output artifacts outside saved project JSON and undo/redo.

### Tasks
- [x] Add a small export format chooser for STEP/STL from the toolbar export
      icon.
- [x] Generalize export file dialogs to use `ProjectExportFormat`.
- [x] Add `.stl` extension handling alongside `.step/.stp`.
- [x] Route STEP to `GeometryRequest.exportStep` and STL to
      `GeometryRequest.exportStl`.
- [x] Keep export outside project save, dirty baseline, undo/redo, and
      semantic project JSON.
- [x] Add widget coverage for STEP, STL, picker guard, and chooser cancel.

### Done Criteria
- Clicking the toolbar export icon opens a compact STEP/STL chooser.
- Choosing STEP opens a STEP save dialog and sends `export_step`.
- Choosing STL opens an STL save dialog and sends `export_stl`.
- Missing extensions are filled as `.step` or `.stl`.
- Canceling the chooser does not open a native save dialog.
- Export success reports the chosen format in the status bar.
- Export does not save a project file, mark the project clean, or create an
  undo entry.

### Tests
- `flutter test test\project_file_service_test.dart --plain-name "export dialog helper preserves or adds export extensions" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "export command writes STEP artifact through geometry service" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "export command writes STL artifact through geometry service" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "export picker opens without pre-picker status rebuild" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "export format chooser can be cancelled before file picker" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Click the top toolbar export/download icon.
- Choose `STL`, save with a name that has no extension, and confirm a `.stl`
  file is created.
- Repeat with `STEP` and confirm a `.step` file is created.
- Cancel the format chooser once; no native save dialog should open.

---

## M103 - Semantic Circular Cutout Command

### Goal
Add the first generic circular cutout command as editable semantic project
state, visible in the shell, inspector, operation planner, and mock viewport,
without introducing editable mesh/STL/B-Rep data.

### Tasks
- [x] Reuse the `slot.generate` rail action as an `Отверстия` surface command.
- [x] Add a compact circular cutout dialog with diameter, depth, X/Y, and
      clearance profile.
- [x] Store the result as a `SemanticFeature` with `type=circular_cutout`.
- [x] Add inspector parameter schema for diameter, depth, and face-local X/Y.
- [x] Add mock viewport preview and hit-test support for circular cutouts.
- [x] Teach the operation planner to emit `cutout.circular` operations.
- [x] Add command, planner, viewport, and widget coverage.
- [x] Update docs/tasks/worklog.

### Done Criteria
- The `Отверстия` rail command is disabled until a semantic surface is
  selected.
- Choosing it from a surface opens the circular cutout dialog.
- Confirming creates `circular_cutout_1`, selects it, refreshes preview, and
  creates one undo entry.
- Canceling does not create a feature or undo entry.
- The inspector can edit circular cutout parameters.
- The mock viewport marker is selectable by semantic ID.
- Geometry request planning preserves the feature as `cutout.circular`.
- Native OCCT does not yet subtract this feature; that is a separate M104
  geometry slice.

### Tests
- `flutter test test\command_registry_test.dart --plain-name "slot command creates holes only from active surface context" --reporter compact`
- `flutter test test\geometry_protocol_test.dart --plain-name "operation planner creates deterministic backend operations" --reporter compact`
- `flutter test test\viewport_controller_test.dart --plain-name "mock hit tester returns semantic feature marker ids" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "circular cutout rail command commits through undo history" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "circular cutout rail command can be cancelled" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "unimplemented rail commands are visible but disabled" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click `Отверстия`.
- Create a circular cutout with a visible diameter such as `14`.
- Select the new marker in the viewport and confirm the inspector shows
  diameter/depth/X/Y.
- Press undo and confirm the cutout disappears.

---

## M104 - Native Circular Cutout Geometry

### Goal
Make semantic `circular_cutout` features generate real native OCCT subtraction
geometry for supported front-wall and generated top-lid targets, while keeping
the editable project semantic and keeping Flutter behind `GeometryService`.

### Tasks
- [x] Research the official OCCT cylinder/cut APIs before implementation.
- [x] Parse `circular_cutout` feature intents in the native OCCT worker.
- [x] Validate diameter, depth, target surface, and face-local position.
- [x] Build front-wall cylinder cut tools with `BRepPrimAPI_MakeCylinder`.
- [x] Build generated top-lid cylinder cut tools with `BRepPrimAPI_MakeCylinder`.
- [x] Subtract both with `BRepAlgoAPI_Cut` and validate the resulting shape.
- [x] Add semantic preview surface mappings for circular cutout faces.
- [x] Add deterministic native metrics for body and generated-lid circular
      cutouts.
- [x] Add semantic validator coverage for oversized circular cutouts.
- [x] Update native smoke/regression/export expectations.
- [x] Update docs/tasks/worklog.

### Done Criteria
- `circular_cutout` with `targetSurface=main_enclosure.front_wall.outer` cuts
  the generated body B-Rep.
- `circular_cutout` with `targetSurface=main_enclosure.top_lid.outer` cuts the
  generated top lid plate B-Rep.
- Depth behaves as a blind cut when shallower than the target thickness and as
  a through cut when depth reaches/exceeds target thickness.
- Preview surface mappings include `front_round_hole` and `top_lid_round_hole`
  in the native regression fixture.
- Metrics include `nativeCircularCutoutCount` and
  `nativeGeneratedLidCircularCutoutCount`.
- STEP/STL export use the same updated B-Rep output.
- No editable mesh, STL, B-Rep, triangle ID, or raw OCCT topology ID is stored
  in the project model or exposed to Flutter.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\project_semantic_validator_test.dart --plain-name "oversized circular cutout reports semantic errors" --reporter compact`
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`
- `flutter test test\native_occt_step_export_test.dart --reporter compact`
- `flutter test test\native_occt_stl_export_test.dart --reporter compact`

### Poke Checklist
- Open the latest exe with native OCCT backend.
- Select `Top lid`, click `Отверстия`, and create a circular cutout with a
  visible diameter such as `14`.
- Confirm the native 3D lid now has an actual round opening, not only a 2D
  overlay marker.
- Select the cutout marker/range and confirm the inspector still edits the
  semantic `circular_cutout`.
- Export STL or STEP and confirm the exported artifact includes the cutout.

---

## M105 - Snap-Seeded Circular Cutout Placement

### Goal
Let a selected surface workplane click seed the first generic circular cutout
position, so the user can click where the hole should start instead of typing
X/Y from scratch.

### Tasks
- [x] Map arbitrary clicks inside selected top-lid/front-wall workplanes to
      face-local positions.
- [x] Keep component-placement workplanes on explicit snap hints only.
- [x] Seed the circular cutout dialog from the active surface snap target.
- [x] Add a compact `Отверстие` action to the active snap inspector section.
- [x] Keep the result as normal semantic `circular_cutout` parameters.
- [x] Add viewport and widget coverage for snap-seeded placement.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Clicking inside a selected top-lid/front-wall workplane creates a transient
  active snap target with local X/Y.
- Starting `Отверстия` from that target opens the dialog with seeded X/Y.
- Confirming creates one undoable semantic `circular_cutout`.
- The mock marker appears at the seeded position and remains selectable by
  semantic feature ID.
- No editable mesh/STL/B-Rep, raw OCCT topology ID, or triangle ID is stored.

### Tests
- `flutter test test\viewport_controller_test.dart --plain-name "mock hit tester maps surface workplane clicks to local positions" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "snap-seeded circular cutout starts from clicked surface point" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click a point inside the highlighted workplane, away from the center board
  marker.
- In the inspector, click `Отверстие`.
- Confirm the dialog starts with that point's X/Y.
- Create the cutout and confirm the marker appears there.
- Orbit/export if desired; native OCCT still generates the actual circular
  cutout from the semantic X/Y.

---

## M106 - Semantic Rounded Rectangular Cutout

### Goal
Extend the `Отверстия` generator from circular holes to the first generic
rounded-rectangular slot/cutout, while keeping the editable project semantic
and leaving native OCCT subtraction for a separate geometry slice.

### Tasks
- [x] Add `rectangular_cutout` semantic defaults with width, height, depth,
      corner radius, clearance profile, and face-local X/Y.
- [x] Add a compact shape selector to the existing `Отверстия` dialog.
- [x] Add inspector parameter editing for rectangular cutouts.
- [x] Add mock viewport marker drawing and hit-testing for rectangular cutouts.
- [x] Map operation planning to `cutout.rectangular`.
- [x] Add semantic validation for supported target surfaces, dimensions,
      radius, and placement bounds.
- [x] Add targeted planner, validator, viewport, and widget tests.
- [x] Update docs/tasks/worklog.

### Done Criteria
- `Отверстия` still defaults to the circular workflow.
- Choosing `Прямоугольное` creates `rectangular_cutout_1`.
- The feature stores only semantic parameters, not generated mesh/B-Rep.
- The inspector edits width, height, depth, radius, X, and Y.
- Mock marker hit-testing selects the semantic feature ID.
- Operation planner emits `cutout.rectangular`.
- Native OCCT does not yet subtract `rectangular_cutout`; that remains M107.

### Tests
- `flutter test test\geometry_protocol_test.dart --plain-name "operation planner creates deterministic backend operations" --reporter compact`
- `flutter test test\project_semantic_validator_test.dart --plain-name "oversized rectangular cutout reports semantic errors" --reporter compact`
- `flutter test test\viewport_controller_test.dart --plain-name "mock hit tester returns semantic feature marker ids" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "rectangular cutout rail command commits through undo history" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "circular cutout rail command commits through undo history" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click `Отверстия`.
- Change `Форма` to `Прямоугольное`.
- Set a visible size such as width `24`, height `12`, radius `2`, and create.
- Confirm the new rectangular marker appears, can be selected, and the
  inspector exposes width/height/depth/radius/X/Y.
- Expect native 3D subtraction to come in the next geometry slice; this chunk
  is the semantic/editing layer.

---

## M107 - Native Rectangular Cutout Geometry

### Goal
Make semantic `rectangular_cutout` features generate native OCCT
rounded-rectangular subtraction on the supported front-wall and generated
top-lid surfaces, while keeping the editable project semantic.

### Tasks
- [x] Add native `RectangularCutoutRequest` parsing from geometry feature
      intents.
- [x] Validate supported target surfaces, positive width/height/depth, corner
      radius, and face-local placement bounds in the native worker.
- [x] Build front-wall rounded rectangular cut tools and subtract them from the
      shell with `BRepAlgoAPI_Cut`.
- [x] Build generated-top-lid rounded rectangular cut tools and subtract them
      from the generated lid plate.
- [x] Map generated cut faces back to the original semantic feature ids.
- [x] Add native metrics for body and generated-lid rectangular cutouts.
- [x] Add native regression coverage with known counts, bounds, area, volume,
      and semantic mappings.
- [x] Update docs/tasks/worklog.

### Done Criteria
- `rectangular_cutout` remains a normal semantic feature; no mesh/B-Rep/STL or
  OCCT topology is saved as editable state.
- Native front-wall rectangular cutouts reduce the generated body shell.
- Native top-lid rectangular cutouts reduce the generated lid preview plate.
- Preview mesh mappings include the original semantic ids such as
  `front_rect_slot` and `top_rect_slot`.
- Metrics report `nativeRectangularCutoutCount` and
  `nativeGeneratedLidRectangularCutoutCount`.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click `Отверстия`.
- Change `Форма` to `Прямоугольное`.
- Create a visible rectangular cutout, for example width `24`, height `12`,
  radius `2`.
- Confirm the native preview model shows a rounded rectangular cut, not only a
  2D marker.
- Orbit the view and select the cutout/feature from the browser to confirm the
  inspector still edits the semantic feature.

---

## M108 - Slot Cutout Preset

### Goal
Make the surface `Отверстия` workflow expose a first-pass slot preset while
keeping the editable project semantic and backed by the existing native
`rectangular_cutout` generator.

### Tasks
- [x] Add `Слот` as a third cutout dialog shape.
- [x] Store the confirmed slot as `type=rectangular_cutout` with
      `parameters.preset=slot`.
- [x] Auto-derive slot corner radius as half of the smaller width/height.
- [x] Keep the normal rectangular path editable and clamp its radius to a valid
      maximum at creation time.
- [x] Label slot features as `Слот` in the project browser and selection
      details without adding a new editable geometry type.
- [x] Add widget coverage for create/select/save/undo of the slot preset.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Selecting `Top lid` and clicking `Отверстия` offers `Круглое`,
  `Прямоугольное`, and `Слот`.
- Choosing `Слот` defaults to a pill-like 24 x 8 mm opening.
- Confirming a slot creates a normal semantic `rectangular_cutout` feature with
  `preset=slot` and `cornerRadius = min(width, height) / 2`.
- The native OCCT path can consume the slot through the existing
  `rectangular_cutout` operation; no mesh, B-Rep, or OCCT topology is saved in
  the project.

### Tests
- `flutter test test\widget_test.dart --plain-name "slot cutout preset creates pill-shaped semantic rectangle" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click `Отверстия`.
- Change `Форма` to `Слот`.
- Confirm the fields switch to `Длина`, `Ширина`, `Глубина`, and derived
  `Радиус`.
- Create a slot such as 32 x 8 mm.
- Confirm the browser/right inspector calls it `Слот`, while the id remains
  `rectangular_cutout_1`.
- Orbit the model and confirm the native preview has a pill-shaped cutout.

---

## M109 - Slot Inspector Semantics

### Goal
Keep slot presets semantically stable after inspector edits, so a slot remains a
pill-shaped `rectangular_cutout` instead of drifting into a generic rounded
rectangle.

### Tasks
- [x] Add a feature-aware parameter schema path for selected semantic features.
- [x] Give `parameters.preset=slot` cutouts a `Слот` inspector schema with
      length/width/depth/X/Y only.
- [x] Hide direct corner-radius editing for slot presets.
- [x] Recompute slot `cornerRadius` from `min(width, height) / 2` after
      inspector edits.
- [x] Clamp normal rectangular cutout corner radius after inspector edits so it
      stays inside valid rounded-rectangle bounds.
- [x] Add widget coverage for slot inspector edit/save/undo behavior.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Slot features still save as `type=rectangular_cutout` with
  `parameters.preset=slot`.
- Editing slot length or width in the inspector automatically updates
  `cornerRadius`.
- Slot inspector no longer exposes `cornerRadius` as a user-editable field.
- Generic rectangular cutouts remain editable and cannot keep an impossible
  radius after size changes.

### Tests
- `flutter test test\widget_test.dart --plain-name "slot inspector keeps derived corner radius after edits" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "slot cutout preset creates pill-shaped semantic rectangle" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Create a `Слот` from `Top lid` or select an existing one.
- In the right inspector, confirm the editor title is `Слот`.
- Confirm there is no editable `Радиус` field in that parameter bank.
- Change `Длина` and `Ширина`.
- Save/reopen later if desired; the slot should stay pill-shaped in the native
  preview.

---

## M110 - Native Switch-Sourced Button Cutouts

### Goal
Verify and document the full pipeline from component switch centers to generated
native top-lid button cutouts, while keeping the editable project as one
semantic `button_group`.

### Tasks
- [x] Add a native OCCT regression fixture with a component-sourced
      `button_group` using `pattern.switchPositions`.
- [x] Verify the native worker consumes those switch positions as top-lid
      button holes, rings, caps, stems, guides, and travel stops.
- [x] Assert the preview maps generated faces back to the semantic group id,
      not to raw mesh or topology ids.
- [x] Keep the operation as generated B-Rep output behind `GeometryService`;
      no generated holes are stored as editable project state.
- [x] Update docs/tasks/worklog.

### Done Criteria
- `component_switch_buttons` remains one `FeatureGroup` with
  `layout=from_component_switches`.
- The native preview reports one generated-lid button group and four generated
  top-lid button cutouts from saved switch centers.
- The same native metrics report four rings, caps, stems, guide sleeves, and
  travel stops for the plunger-style group.
- Native output contains no `topologyId` or `triangleId` editable state.

### Tests
- `flutter test test\native_occt_geometry_regression_test.dart --plain-name "native OCCT preview cuts component switch-sourced top lid buttons" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Custom Button Board` / `button_board_placement`.
- Click `Кнопки` and create the component-sourced group.
- Confirm `button_group_1` appears and can still be selected as one group.
- In native preview, the lid should show generated button holes/rings aligned
  to the board switches.

---

## M111 - USB-C Snap-Seeded Placement

### Goal
Let manual front-wall USB-C cutouts start from the clicked face-local workplane
point, while keeping the editable project semantic and leaving generated OCCT
geometry behind `GeometryService`.

### Tasks
- [x] Reuse active front-wall snap targets when launching `Порты`.
- [x] Store manual snap-seeded USB-C placement as
      `placement.surfacePosition` plus `projectionMode=surface_snap_target`.
- [x] Add a compact `USB-C` action to the active snap inspector section for
      supported front-wall snap targets.
- [x] Make mock USB-C feature markers use saved `surfacePosition` when present,
      with the old slot marker layout as fallback.
- [x] Round snap coordinates before serialization so canvas conversion noise
      does not leak into project JSON.
- [x] Add widget coverage for snap-seeded USB-C creation, saved JSON, and
      marker hit-test selection.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Clicking a front-wall workplane point and starting `Порты` creates a normal
  semantic `usb_c_cutout`.
- Saved JSON for that feature includes `placement.surfacePosition` and
  `surfaceAxes=["x","z"]`.
- The active snap target is transient and clears after commit.
- The mock USB-C marker is selectable at the saved face-local point.
- Existing component-sourced USB-C and generic cutout snap workflows still pass.

### Tests
- `flutter test test\widget_test.dart --plain-name "snap-seeded USB-C stores front wall surface position"`
- `flutter test test\widget_test.dart --plain-name "snap-seeded circular cutout starts from clicked surface point"`
- `flutter test test\viewport_controller_test.dart`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Front wall`.
- Click a free point on the front-wall workplane, away from the existing USB-C
  marker.
- In the snap section, click `USB-C`, confirm the dialog, and select the new
  `usb_c_cutout_2`.
- The new marker should appear near the clicked front-wall point and be
  selectable there.
- Save/reopen later if desired; the cutout should keep its saved face-local
  position.

---

## M112 - Snap-Seeded Glass and Button Placement

### Goal
Extend active surface snap targets from holes/USB-C into manual `Стекло` and
`Кнопки`, so the common surface generators can start from a clicked face-local
point without adding low-level CAD controls.

### Tasks
- [x] Reuse active top-lid/front-wall snap targets when launching `Стекло`.
- [x] Reuse active top-lid/front-wall snap targets when launching manual
      `Кнопки`.
- [x] Preserve `placement.surfacePosition`, `surfaceAxes`, and
      `projectionMode=surface_snap_target` through the glass dialog.
- [x] Store manual button group center placement as semantic group placement.
- [x] Move mock glass markers and button-group markers to saved surface
      positions.
- [x] Offset button-group `GeometryFeatureIntent.items` by saved
      `surfacePosition` so backend generation sees the same semantic placement.
- [x] Convert front-wall snap local Y to absolute surface Z for saved
      `surfacePosition`.
- [x] Add validation for snap-seeded glass anchors and manual button group
      surface fit.
- [x] Add widget, geometry protocol, and semantic validator coverage.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Starting `Стекло` from an active snap target creates a normal semantic
  `glass_recess` with saved surface placement.
- Starting `Кнопки` from an active snap target creates one editable
  `button_group` with saved surface placement.
- The active snap target remains transient UI state and clears after commit.
- Mock markers are selectable at the saved surface positions.
- Geometry feature intents for manual button groups include the saved placement
  offset.
- Out-of-surface snap placements report semantic validation errors.

### Tests
- `flutter test test\widget_test.dart --plain-name "snap-seeded glass recess stores top lid surface position"`
- `flutter test test\widget_test.dart --plain-name "snap-seeded button group stores top lid surface position"`
- `flutter test test\widget_test.dart --plain-name "snap-seeded USB-C stores front wall surface position"`
- `flutter test test\geometry_protocol_test.dart --plain-name "manual button group items include saved surface position offset"`
- `flutter test test\project_semantic_validator_test.dart --plain-name "snap-seeded glass recess anchor outside surface reports an error"`
- `flutter test test\project_semantic_validator_test.dart --plain-name "manual button group surface anchor outside lid reports an error"`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click a free point on the top-lid workplane, away from the board.
- In the snap section, click `Стекло`, confirm, and verify the new glass marker
  appears at that point.
- Click another free point, click `Кнопки`, confirm, and verify the whole
  button pattern appears around that point and remains one selectable group.
- Optional: select `Front wall`, click near the middle height, and create
  `USB-C`; it should now save/use absolute Z rather than treating the center as
  z=0.

---

## M113 - Native-Mapped Overlay De-Clutter

### Goal
Reduce the visible 2D schematic overlays in native preview mode by hiding
feature and feature-group markers that already have generated semantic preview
ranges, while keeping semantic fallback markers for unmapped objects.

### Tasks
- [x] Detect display-only native preview mappings for feature and feature-group
      semantic IDs.
- [x] Hide mapped schematic feature markers when native OCCT preview ranges are
      available.
- [x] Hide mapped schematic feature-group markers when native OCCT preview
      ranges are available.
- [x] Keep unmapped semantic markers as fallback affordances for selection and
      development.
- [x] Keep selected native ranges highlighted through the existing generated
      mesh highlight path.
- [x] Add widget coverage for hidden mapped schematic overlays.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Native preview mode no longer draws duplicate 2D feature/group markers for
  semantic IDs that have mapped generated mesh ranges.
- The editable project still stores only semantic features/groups, not mesh
  IDs or topology IDs.
- Selection highlight still uses generated semantic preview ranges when
  available.
- Unmapped semantic objects still use schematic markers as a fallback.

### Tests
- `flutter test test\widget_test.dart --plain-name "native preview hides mapped schematic feature overlays" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "native preview" --reporter compact`
- `flutter test test\viewport_controller_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- In the normal project view, the generated body should be visually calmer:
  mapped feature/group 2D markers should not sit as strong duplicate shapes on
  top of generated geometry.
- Select `USB-C`, `Top lid`, or a generated button group from the browser.
- Confirm the native mesh highlight still appears for the selected generated
  semantic part.
- Create a new snap-seeded glass/button item if desired; items without native
  generated mapping may still show schematic fallback markers until their
  geometry mapping is implemented.

---

## M114 - Native Active Snap Point De-Clutter

### Goal
Reduce the remaining large 2D surface workplane ghost in native preview mode:
when a user has already clicked an active top-lid/front-wall snap target, show
only a compact point/crosshair instead of the whole translucent workplane
rectangle and grid.

### Tasks
- [x] Add a native point-only workplane overlay state for active surface snap
      targets.
- [x] Keep full component-placement workplanes because the board rectangle is
      still useful for placement.
- [x] Draw a compact active snap point/crosshair in native preview mode.
- [x] Keep hit-testing and semantic snap data unchanged.
- [x] Add widget coverage for native point-only active surface snap state.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Selecting a surface in native preview still hides the passive workplane.
- Clicking a top-lid/front-wall snap target in native preview no longer brings
  back the full 2D workplane rectangle.
- The active snap target panel and snap-seeded actions still work.
- Component placement workplanes still use the full rectangle where it is a
  useful placement affordance.

### Tests
- `flutter test test\widget_test.dart --plain-name "native preview shows active surface snap as point only" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "native preview" --reporter compact`
- `flutter test test\viewport_controller_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Click a point on the lid.
- Confirm the active snap panel appears, but the viewport shows only a compact
  point/crosshair instead of a huge translucent lid rectangle.
- Use `Стекло`, `Кнопки`, or `Отверстие` from that active point and confirm the
  action still works.

---

## M115 - Collapsible Workspace Side Panels

### Goal
Give the viewport more room during manual inspection by letting the project
browser and contextual inspector collapse to narrow icon strips without changing
semantic project state.

### Tasks
- [x] Add transient shell state for project browser and inspector collapse.
- [x] Add compact icon controls for collapsing expanded panels.
- [x] Add narrow icon strips for restoring collapsed panels.
- [x] Keep the left command rail visible in both states.
- [x] Keep collapse state out of `ProjectModel`, undo/redo, save/load, and
      geometry requests.
- [x] Add widget coverage for collapse/expand controls.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Project browser can collapse and expand from the shell.
- Contextual inspector can collapse and expand from the shell.
- Collapsed panels still leave an obvious icon affordance to restore them.
- Existing selection, command, and viewport behavior stays unchanged.

### Tests
- `flutter test test\widget_test.dart --plain-name "workspace side panels can collapse and expand" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "workspace shell" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "viewport" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Click the small collapse icon at the top of the project browser.
- Confirm the browser becomes a narrow icon strip and the viewport gets more
  horizontal space.
- Restore the project browser from the strip.
- Collapse and restore the right inspector the same way.
- Select a model part before/after collapsing and confirm selection still works.

---

## M116 - Viewport Context Popover Foundation

### Goal
Add the first right-click context popover in the viewport so a user can pick a
semantic surface/snap point and launch relevant generator commands without
moving back to the left rail.

### Tasks
- [x] Add secondary-click handling to the viewport pointer flow.
- [x] Reuse existing semantic hit-testing for context menu targets.
- [x] Select the clicked semantic target before showing quick actions.
- [x] Show only command actions that are valid for the selected context.
- [x] Launch existing command dialogs from the popover instead of adding a new
      command path.
- [x] Keep popover state out of `ProjectModel`, undo/redo, save/load, and
      geometry requests.
- [x] Add widget coverage for available actions and snap-seeded command launch.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Right-clicking a supported viewport surface/snap point opens a compact
  action menu.
- The menu is context-filtered through the existing command registry and shell
  command handlers.
- Choosing `Отверстия` from a snap point opens the existing cutout dialog with
  the clicked face-local coordinates prefilled.
- Normal left-click selection, orbit, pan, and zoom behavior stay unchanged.

### Tests
- `flutter test test\widget_test.dart --plain-name "viewport context menu" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "workspace shell" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "viewport" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select `Top lid`.
- Right-click one of the lid snap points.
- Confirm a compact action menu appears near the cursor.
- Choose `Отверстия`.
- Confirm the cutout dialog opens and the X/Y fields match the clicked point.
- Cancel the dialog and confirm normal left-click selection/orbit behavior still
  feels the same.

---

## M117 - Command Palette Foundation

### Goal
Add a compact command palette so common semantic commands can be found from the
keyboard or toolbar while still using the existing command registry and command
handlers.

### Tasks
- [x] Add `workspace.command_palette` metadata to the core command registry.
- [x] Add a toolbar affordance for opening the palette.
- [x] Add `Ctrl+K` keyboard access for the shell.
- [x] Filter palette entries by the current semantic selection, undo state, file
      busy state, and available shell handlers.
- [x] Let palette entries launch existing command paths instead of creating a
      second execution system.
- [x] Keep palette/search state out of `ProjectModel`, undo/redo, save/load, and
      geometry requests.
- [x] Add widget and command-registry coverage.
- [x] Update docs/tasks/worklog.

### Done Criteria
- The toolbar opens a searchable command palette.
- `Ctrl+K` opens the same palette when the shell has focus.
- Workspace selection shows only workspace-available commands.
- Surface selection exposes surface commands such as `Отверстия`.
- Choosing a command launches the same existing dialogs/actions used by the
  rail, toolbar, inspector shortcuts, and viewport context popover.
- No project JSON, semantic geometry request, or generated preview data changes
  are introduced by opening/filtering the palette.

### Tests
- `flutter test test\widget_test.dart --plain-name "command palette" --reporter compact`
- `flutter test test\command_registry_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Click the command-palette icon in the top toolbar.
- Confirm the palette opens and shows workspace commands.
- Type `slot` while the project root is selected and confirm no surface-only
  slot command is shown.
- Select `Top lid`, open the palette again, type `slot`, and choose
  `Отверстия`.
- Confirm the cutout dialog opens, then cancel it.
- Press `Ctrl+K` and confirm the same palette opens again.

---

## M118 - Guided Enclosure Presets + Validation

### Goal
Make the first enclosure creation dialog more maker-friendly by adding guided
size presets and live printability/fit checks while keeping the saved project
as the same semantic rounded-enclosure parameters.

### Tasks
- [x] Add compact guided presets to `Создать корпус`.
- [x] Apply presets through existing enclosure parameter values instead of a new
      project schema.
- [x] Show a live internal-size summary for the current dimensions.
- [x] Block creation when wall thickness leaves too little internal space.
- [x] Block creation when corner radius is impossible for the selected width and
      depth.
- [x] Show first-pass warnings for very thin/thick walls and tight screw-lid
      bodies.
- [x] Keep create/cancel/undo behavior unchanged.
- [x] Add widget coverage for preset application and validation blocking.
- [x] Update docs/tasks/worklog.

### Done Criteria
- The create-enclosure dialog offers guided presets for common first bodies.
- Choosing a preset updates width/depth/height/wall/radius/lid controls.
- Confirming a preset still commits one normal semantic enclosure edit.
- Invalid combinations disable `Создать` and explain the problem in the dialog.
- No new project JSON fields, geometry protocol fields, or editable generated
  geometry are introduced.

### Tests
- `flutter test test\widget_test.dart --plain-name "create enclosure" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Click `Корпус` in the left rail.
- Click the `Плата`, `Ручной`, and `Бокс` presets and confirm the numeric fields
  and `Внутри:` summary update.
- Pick `Ручной`, click `Создать`, and confirm the project shows
  `160 x 84 x 34 mm`.
- Undo once and confirm the sample body returns to `120 x 70 x 28 mm`.
- Open `Корпус` again, set `Ширина` to `20` and `Стенка` to `8`, and confirm
  `Создать` is disabled with a red validation message.

---

## M119 - Guided Component Placement Pick Mode

### Goal
Let the user start component placement, choose a point in the viewport, and then
continue in the existing placement dialog with the clicked snap point already
applied.

### Tasks
- [x] Add a transient component-placement guide mode.
- [x] Add a `Выбрать точку` action to the placement dialog.
- [x] Show a compact viewport banner while the guide mode is active.
- [x] Keep guide state out of `ProjectModel`, undo/redo, save/load, and geometry
      requests.
- [x] Reuse existing semantic snap hit testing and active snap target data.
- [x] Open the normal placement dialog after a viewport snap point is selected.
- [x] Preserve the existing direct `Компоненты` placement dialog flow.
- [x] Add widget coverage for guided viewport picking and legacy placement flows.
- [x] Update docs/tasks/worklog.

### Done Criteria
- `Компоненты` still opens the normal placement dialog.
- The placement dialog can switch into viewport-pick mode.
- The viewport shows a cancellable guide banner in that mode.
- Selecting a surface and clicking a snap point opens the normal placement
  dialog with the clicked X/Y and snap hint.
- Confirm/cancel/undo behavior remains on the existing semantic placement path.
- No generated mesh, B-Rep, topology, or triangle IDs are stored in project
  state.

### Tests
- `flutter test test\widget_test.dart --plain-name "component placement" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "place component" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Click `Компоненты`.
- In the placement dialog, click `Выбрать точку`.
- Confirm the viewport shows a small `Размещение компонента` banner.
- Select `Top lid` if its snap points are not already visible.
- Click one of the lid snap points.
- Confirm the placement dialog reopens with a `Точка:` hint and X/Y matching the
  clicked point.
- Cancel the dialog and confirm the guide banner disappears.

---

## M120 - Advanced Mode Switch

### Goal
Add the first explicit Advanced Mode switch while keeping low-level CAD tools
out of the default maker workflow.

### Tasks
- [x] Add transient shell state for Advanced Mode.
- [x] Keep the left rail semantic by default.
- [x] Add a separate lower rail toggle for Advanced Mode.
- [x] Reveal the first advanced `advanced.sketch` placeholder only when
      Advanced Mode is enabled.
- [x] Keep the placeholder disabled until the basic sketch tool is implemented.
- [x] Keep Advanced Mode state out of `ProjectModel`, undo/redo, save/load, and
      geometry requests.
- [x] Prevent rail overflow at shorter window heights.
- [x] Add widget coverage for the switch and hidden/visible advanced tool.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Default UI still shows semantic generator tools first.
- `advanced.sketch` is absent until Advanced Mode is enabled.
- Enabling Advanced Mode reveals the separate advanced tool placeholder without
  making an unimplemented command clickable.
- Disabling Advanced Mode hides advanced tools again.
- No project JSON, geometry protocol, generated mesh, B-Rep, topology, or
  triangle ID changes are introduced.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced mode switch" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "unimplemented rail" --reporter compact`
- `flutter test test\command_registry_test.dart --plain-name "advanced commands" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Confirm the default left rail does not show `Эскиз`.
- Click the Advanced Mode icon at the lower part of the left rail.
- Confirm `Эскиз` appears in a separate advanced section but is disabled.
- Click the Advanced Mode icon again and confirm `Эскиз` disappears.

---

## M121 - Basic Sketch Foundation

### Goal
Make the first Advanced Mode sketch command create a safe semantic helper
object without introducing freeform CAD geometry into the default workflow.

### Tasks
- [x] Wire `advanced.sketch` to a real shell command only when Advanced Mode is
      enabled.
- [x] Add a compact sketch dialog for target surface and sketch name.
- [x] Store the result as a semantic `advanced_sketch` `SemanticFeature`.
- [x] Keep sketch geometry empty for now with `entities=[]` and
      `operation=helper`.
- [x] Select the created sketch and make it visible in the project browser and
      inspector.
- [x] Keep creation undoable and save/load-safe.
- [x] Keep geometry planning explicit with `helper.advanced_sketch`.
- [x] Add model, operation-plan, command-palette, and widget coverage.
- [x] Update docs/tasks/worklog.

### Done Criteria
- `Эскиз` is hidden until Advanced Mode is enabled.
- In Advanced Mode, `Эскиз` opens a dialog instead of being a disabled
  placeholder.
- Creating a sketch adds one semantic helper feature targeted at a surface.
- The helper sketch does not create generated B-Rep, mesh, cut, extrusion, or
  editable topology.
- Undo removes the created sketch and save/load preserves it when not undone.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "command palette" --reporter compact`
- `flutter test test\geometry_protocol_test.dart --plain-name "advanced sketches" --reporter compact`
- `flutter test test\project_model_test.dart --plain-name "advanced sketch" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode from the lower left rail.
- Click `Эскиз`.
- Pick or keep a surface, enter a sketch name, and click `Создать`.
- Confirm the new sketch appears under `Фичи` and is selected in the inspector.
- Click undo and confirm the sketch disappears.

---

## M122 - Sketch Rectangle Entity Slice

### Goal
Give Advanced Sketch its first typed editable entity while keeping it semantic,
helper-only, and out of the default beginner workflow.

### Tasks
- [x] Add a typed `SketchEntity` model and helpers for `advanced_sketch`
      feature metadata.
- [x] Add a default rectangle sketch entity with deterministic dimensions.
- [x] Add an inspector-only rectangle action for selected advanced sketches.
- [x] Keep rectangle creation undoable and save/load-safe.
- [x] Keep sketch entities out of generated B-Rep, mesh, cut, extrusion, and
      topology selection.
- [x] Add model and widget coverage.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Selecting an advanced sketch shows a compact sketch section in the inspector.
- Clicking the rectangle icon adds `rect_1` to the sketch `entities` list.
- Saved project JSON preserves the rectangle entity and `entityCount`.
- Undo once removes the rectangle while keeping the sketch; undo again removes
  the sketch if it was just created.
- Geometry planning still treats the sketch as `helper.advanced_sketch`.

### Tests
- `flutter test test\project_model_test.dart --plain-name "advanced sketch" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode from the lower left rail.
- Create an `Эскиз` on a surface.
- Select that sketch under `Фичи`.
- Click the square/rectangle icon in the inspector sketch section.
- Confirm the inspector shows one contour, `rect_1`, and `20 x 12`.
- Undo once and confirm `rect_1` disappears while the sketch remains.

---

## M123 - Sketch Rectangle Parameter Editing

### Goal
Make the first Advanced Sketch rectangle entity editable through typed semantic
parameters without turning sketch entities into generated geometry.

### Tasks
- [x] Add `SketchEntityParameterAdapter` for rectangle center, size, and corner
      radius values.
- [x] Normalize rectangle numbers into stable JSON values.
- [x] Clamp rectangle corner radius to half of the smaller side.
- [x] Add inspector fields for selected sketch rectangle entities.
- [x] Keep each rectangle parameter edit undoable and save/load-safe.
- [x] Keep rectangle parameters helper-only, with no B-Rep, mesh, cut,
      extrusion, or topology output.
- [x] Add adapter and widget coverage.
- [x] Update docs/tasks/worklog.

### Done Criteria
- After adding `rect_1`, the inspector exposes X, Y, width, height, and radius
  fields.
- Editing width updates the semantic entity row and saved project JSON.
- Undo once reverts the rectangle parameter edit while keeping `rect_1`.
- Undo again can remove the rectangle entity as before.
- Geometry planning still treats the parent sketch as `helper.advanced_sketch`.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add a rectangle from the selected sketch inspector.
- Change `Ширина` from `20` to another value, for example `32.5`.
- Confirm the row changes from `20 x 12` to `32.5 x 12`.
- Save, reopen later if desired, and confirm the edited value remains.
- Undo once and confirm the rectangle returns to `20 x 12`.

---

## M124 - Sketch Rectangle Helper Overlay

### Goal
Make selected Advanced Sketch rectangles visible in the viewport as helper-only
semantic overlays without reintroducing the old large passive 2D workplane.

### Tasks
- [x] Build selected `advanced_sketch` rectangle overlay previews from
      `SketchEntity` values.
- [x] Reuse the existing surface workplane local-to-canvas mapping for
      top-lid/front-wall sketches.
- [x] Draw only the rectangle contour/center marker, not a full surface
      workplane.
- [x] Keep the overlay display-only: no mesh, B-Rep, cuts, extrusions, topology
      IDs, or viewport entity hit-testing.
- [x] Add widget coverage that the sketch overlay appears after `rect_1` and
      disappears when the entity is undone.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Selecting a sketch with a rectangle shows `advanced-sketch-overlay-active`.
- The normal `mock-workplane-overlay-active` sentinel remains absent for the
  selected sketch, so the big workplane rectangle does not come back.
- Editing rectangle width updates the same semantic overlay source data.
- Undoing the rectangle removes the overlay while keeping the sketch feature.
- Geometry planning still treats the parent sketch as `helper.advanced_sketch`.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add a rectangle from the selected sketch inspector.
- Confirm a thin helper rectangle appears in the viewport.
- Confirm the old full workplane rectangle is not covering the model.
- Change `Ширина` and confirm the helper rectangle changes size.
- Undo until `rect_1` disappears and confirm the helper overlay disappears too.

---

## M125 - Sketch Rectangle Overlay Hit Target

### Goal
Make the visible selected-sketch rectangle overlay clickable as a semantic
parent sketch target, without introducing mesh, topology, or sub-entity
selection.

### Tasks
- [x] Move sketch rectangle preview layout/hit math into the viewport layer so
      painting and hit testing share one model.
- [x] Add rectangle overlay hit testing before normal feature/group markers so
      clicks on the helper do not fall through to underlying USB-C, surface, or
      placement targets.
- [x] Return the parent `advanced_sketch` feature id from overlay hits.
- [x] Keep rectangle entity ids internal to the sketch metadata for now; do not
      expose them as selectable viewport entities.
- [x] Extend controller/widget coverage for the overlay hit target.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Clicking inside the selected rectangle helper overlay keeps the selected
  `advanced_sketch` in the inspector.
- The hit result resolves to `ViewportHitKind.feature` with the parent sketch
  semantic id.
- The overlay still does not create preview mesh, B-Rep, cuts, extrusions,
  topology ids, or editable sketch sub-selection.
- Editing rectangle parameters continues to update the same semantic source
  data.

### Tests
- `flutter test test\viewport_controller_test.dart --plain-name "parent sketch feature" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз` on `Front wall` or `Top lid`.
- Add a rectangle from the selected sketch inspector.
- Click inside the thin helper rectangle in the viewport.
- Confirm the right inspector stays on the sketch instead of jumping to the
  USB-C, body, or surface below it.
- Change width/height and confirm the same overlay still responds to clicks.

---

## M126 - Sketch Rectangle Entity Focus

### Goal
Make clicks on selected sketch rectangle overlays focus the semantic rectangle
entity in the inspector while keeping commands, viewport highlighting, and
geometry boundaries scoped to the parent `advanced_sketch`.

### Tasks
- [x] Add `SelectionKind.sketchEntity` with parent feature scoping.
- [x] Keep command context and viewport semantic highlight on the parent sketch
      id instead of the rectangle id.
- [x] Resolve sketch rectangle overlay hits to a semantic child id.
- [x] Show selected rectangle details in the inspector and highlight its row.
- [x] Keep selected rectangle overlays visible and visually focused.
- [x] Fall back to the parent sketch when undo removes the focused entity.
- [x] Add unit/widget coverage and update docs/tasks/worklog.

### Done Criteria
- Adding a rectangle selects/focuses `rect_1` in the sketch inspector.
- Clicking the visible helper rectangle focuses the same semantic rectangle
  entity.
- Command context `selectedObjectId` remains the parent `advanced_sketch`.
- Viewport/native preview selection uses the parent sketch semantic id, not
  `rect_1`.
- Undoing the rectangle removes entity focus and falls back to the parent
  sketch.
- No mesh, B-Rep, OCCT topology, or generated triangle ids enter editable
  selection state.

### Tests
- `flutter test test\selection_model_test.dart test\project_selection_resolver_test.dart --reporter compact`
- `flutter test test\viewport_controller_test.dart --plain-name "parent sketch feature" --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз` on `Front wall` or `Top lid`.
- Add a rectangle and confirm the inspector title/row points at `rect_1`.
- Click the helper rectangle in the viewport and confirm the same `rect_1`
  row stays highlighted.
- Edit width/height and confirm the rectangle remains selected.
- Undo rectangle creation and confirm the inspector falls back to the parent
  sketch.

---

## M127 - Sketch Rectangle Entity Actions

### Goal
Add safe semantic edit actions for the focused sketch rectangle: 1 mm nudge
controls and delete, without viewport drag handles or geometry conversion.

### Tasks
- [x] Add a project helper to remove a `SketchEntity` by stable id.
- [x] Add selected-rectangle inspector action buttons for left/right/up/down
      nudges.
- [x] Add a selected-rectangle delete action.
- [x] Apply nudges through `SketchEntityParameterAdapter` so center coordinates
      stay normalized.
- [x] Commit nudge/delete through undo history.
- [x] Keep nudge selection on the rectangle entity and delete selection on the
      parent sketch.
- [x] Extend unit/widget coverage and update docs/tasks/worklog.

### Done Criteria
- A focused rectangle row shows icon-only nudge and delete actions.
- Nudge right/up updates saved rectangle `center` by `[1.0, 1.0]`.
- Each nudge is undoable as a separate semantic edit.
- Delete removes the rectangle entity, hides the helper overlay, and returns
  selection to the parent `advanced_sketch`.
- Undo after delete restores the rectangle entity without saving focus state.
- No mesh, B-Rep, OCCT topology, or generated triangle ids are used.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add a rectangle.
- Click the right/up arrow buttons and confirm the helper rectangle moves.
- Press undo twice and confirm the rectangle moves back.
- Click the delete icon and confirm `rect_1` disappears and the parent sketch
  remains selected.
- Press undo and confirm `rect_1` returns.

---

## M128 - Sketch Rectangle Bounds Warning

### Goal
Warn when a semantic sketch rectangle extends outside its supported surface
workplane, without blocking edits or using generated geometry.

### Tasks
- [x] Add workplane-bounds validation to `SketchEntityParameterAdapter`.
- [x] Pass supported top-lid/front-wall workplane dimensions into the selected
      sketch entity inspector.
- [x] Show bounds warnings beside existing sketch parameter issues.
- [x] Render parameter warnings with warning color instead of error color.
- [x] Add unit/widget coverage and update docs/tasks/worklog.

### Done Criteria
- Rectangles inside the surface workplane have no bounds issue.
- Rectangles extending beyond the surface report a warning issue.
- The warning appears in the selected rectangle inspector.
- Undoing the out-of-bounds edit removes the warning.
- The warning is semantic-only and does not query mesh, B-Rep, OCCT topology,
  or generated triangle ids.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз` on `Front wall` or `Top lid`.
- Add a rectangle.
- Set `X` far enough toward the edge that the rectangle sticks out.
- Confirm the inspector warns that the contour leaves the surface.
- Undo the edit and confirm the warning disappears.

---

## M129 - Sketch Rectangle Click Placement

### Goal
Start the first safe sketch drawing/editing interaction: rectangle creation from
a viewport workplane click, while keeping the result semantic and undoable.

### Tasks
- [x] Add a transient selected-sketch rectangle placement intent.
- [x] Make the rectangle inspector action toggle click-to-place mode.
- [x] Show a compact viewport cancel banner while placement is active.
- [x] Use the owning sketch surface workplane as the placement hit target.
- [x] Create the rectangle at the clicked semantic local position.
- [x] Focus the new rectangle entity and clear the placement intent.
- [x] Add widget coverage and update docs/tasks/worklog.

### Done Criteria
- Pressing the rectangle action on a selected sketch does not immediately create
  a rectangle; it starts a visible placement mode.
- Cancel clears the placement mode without changing project JSON.
- Clicking the supported top-lid/front-wall sketch workplane creates `rect_N`
  with `center` from the clicked local workplane coordinate.
- The created rectangle is selected as a semantic sketch entity and remains
  undoable/saveable.
- Placement hit testing does not depend on generated mesh, B-Rep, OCCT topology,
  or triangle ids.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз` on `Front wall` or `Top lid`.
- Click the rectangle icon in the sketch inspector.
- Confirm a small viewport banner appears and no `rect_1` is created yet.
- Cancel from the banner and confirm nothing was added.
- Click the rectangle icon again, then click inside the highlighted workplane.
- Confirm `rect_1` appears, is selected, and can still be nudged/edited/undone.

---

## M130 - Sketch Rectangle Resize Buttons

### Goal
Add constrained rectangle size editing without viewport drag handles: compact
semantic width/height +/- 1 mm controls for the focused rectangle.

### Tasks
- [x] Add a semantic resize edit path for focused rectangle entities.
- [x] Reuse `SketchEntityParameterAdapter` normalization for width/height edits.
- [x] Add compact width/height +/- 1 mm buttons in the selected rectangle row.
- [x] Keep resize edits undoable and scoped to the selected sketch entity.
- [x] Extend widget coverage and update docs/tasks/worklog.

### Done Criteria
- The focused rectangle exposes width and height +/- 1 mm controls.
- Width increase changes the size label from `20 x 12` to `21 x 12`.
- Height decrease changes the size label from `21 x 12` to `21 x 11`.
- Undo restores the previous rectangle dimensions one resize edit at a time.
- Resize edits update only semantic `SketchEntity` parameters and do not query
  mesh, B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add/place a rectangle and select `rect_1`.
- Use the width `+` control and confirm the rectangle becomes wider.
- Use the height `-` control and confirm the rectangle becomes shorter.
- Press undo twice and confirm the dimensions restore step by step.

---

## M131 - Sketch Rectangle Move-To-Click

### Goal
Add a direct but safe viewport edit for focused sketch rectangles: a compact
inspector action that moves the selected rectangle center to the next click on
its supported sketch workplane.

### Tasks
- [x] Reuse the transient sketch rectangle placement intent for move mode.
- [x] Add a selected-rectangle move-to-click inspector action with active
      highlighting.
- [x] Update rectangle center through `SketchEntityParameterAdapter`.
- [x] Commit the move as an undoable semantic project edit.
- [x] Extend widget coverage and update docs/tasks/worklog.

### Done Criteria
- The focused rectangle exposes a move-to-click action.
- Pressing it enters a viewport pick mode and shows the existing cancel banner.
- The next click on the owning sketch workplane updates the rectangle center.
- Saving after the move stores the new semantic `center` values.
- Undo restores the previous rectangle center.
- Move edits update only semantic `SketchEntity` parameters and do not query
  mesh, B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add/place a rectangle and select `rect_1`.
- Press the target/crosshair move action in the selected rectangle row.
- Click another point on the same sketch workplane and confirm the rectangle
  jumps there.
- Press undo and confirm the rectangle returns to the previous center.

---

## M132 - Sketch Rectangle Duplicate

### Goal
Make repeated helper contours practical without flattening them into generated
geometry: duplicate a focused sketch rectangle as a new semantic `SketchEntity`
with a safe offset and immediate focus.

### Tasks
- [x] Add schema-backed rectangle duplication through
      `SketchEntityParameterAdapter`.
- [x] Preserve rectangle size/radius while assigning a new stable `rect_N` id.
- [x] Offset the duplicate center so it is visible and editable immediately.
- [x] Add a compact selected-rectangle duplicate action.
- [x] Commit duplication through undo history and select the new rectangle.
- [x] Extend adapter/widget coverage and update docs/tasks/worklog.

### Done Criteria
- The focused rectangle exposes a duplicate action.
- Pressing it creates `rect_2` when `rect_1` is selected.
- The duplicate keeps width, height, and corner radius, with center offset by
  `+6, -6` mm from the source rectangle.
- Saving after duplication stores both semantic entities.
- Undo removes only the duplicate and leaves the source rectangle.
- Duplication updates only semantic `SketchEntity` data and does not query mesh,
  B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add/place a rectangle and select `rect_1`.
- Press the duplicate action in the selected rectangle row.
- Confirm `rect_2` appears slightly offset and becomes selected.
- Press undo and confirm only `rect_2` disappears.

---

## M133 - Sketch Rectangle Keyboard Editing

### Goal
Make focused sketch rectangles easier to adjust without adding fragile drag
handles yet: arrow keys nudge the selected rectangle, and Shift+arrow changes
its size, all through semantic undoable edits.

### Tasks
- [x] Route workspace key handling through a dedicated handler.
- [x] Keep Ctrl+K command palette behavior intact.
- [x] Ignore rectangle keyboard editing while a text field is focused.
- [x] Add arrow-key 1 mm nudge for selected sketch rectangle entities.
- [x] Add Shift+arrow 1 mm width/height resize for selected sketch rectangle
      entities.
- [x] Return focus to the workspace after selection, edit, undo, and redo so
      keyboard editing is predictable.
- [x] Extend widget coverage and update docs/tasks/worklog.

### Done Criteria
- With a sketch rectangle selected, Arrow Right then Arrow Up moves its semantic
  center to `[1.0, 1.0]`.
- Shift+Arrow Right increases width by 1 mm.
- Shift+Arrow Down decreases height by 1 mm.
- Saving after keyboard edits stores the changed semantic center/size.
- Undo restores each keyboard edit one step at a time.
- Keyboard edits update only semantic `SketchEntity` parameters and do not
  query mesh, B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create an `Эскиз`.
- Add/place a rectangle and select it.
- Press Arrow Right and Arrow Up; confirm the rectangle shifts by small steps.
- Hold Shift and press Arrow Right / Arrow Down; confirm width/height changes.
- Press undo repeatedly and confirm each keyboard edit rolls back separately.

---

## M134 - Sketch Rectangle Keyboard Commands

### Goal
Make common selected-rectangle operations reachable from the keyboard without
adding fragile viewport drag state: Escape cancels active placement/move,
Ctrl+D duplicates the selected rectangle, and Delete/Backspace removes it.

### Tasks
- [x] Add Escape cancellation for active sketch rectangle placement/move mode.
- [x] Return focus to the workspace when entering/canceling sketch placement
      intents.
- [x] Add Ctrl+D duplicate for selected sketch rectangle entities.
- [x] Add Delete/Backspace removal for selected sketch rectangle entities.
- [x] Keep shortcut commands ignored while a text field is focused.
- [x] Extend widget coverage and update docs/tasks/worklog.

### Done Criteria
- Escape clears active rectangle placement mode without creating `rect_1`.
- Ctrl+D on selected `rect_1` creates and selects `rect_2`.
- Delete removes the selected rectangle through undoable semantic history.
- Undo restores shortcut delete/duplicate changes one command at a time.
- Shortcuts update only semantic `SketchEntity` data and do not query mesh,
  B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Start rectangle placement and press Escape; confirm the placement banner
  disappears and no rectangle is created.
- Select a rectangle and press Ctrl+D; confirm the duplicate appears selected.
- Press Delete; confirm the selected rectangle is removed.
- Press undo twice and confirm delete/duplicate roll back step by step.

---

## M135 - Sketch Rectangle Workplane Quick Actions

### Goal
Add safe workplane-aware quick actions for focused sketch rectangles: center the
rectangle on its sketch workplane or fit it to the supported workplane bounds,
without introducing generated-geometry edit state.

### Tasks
- [x] Add semantic center-on-workplane edit for selected rectangles.
- [x] Add semantic fit-to-workplane edit using the selected sketch surface
      workplane size.
- [x] Keep both edits undoable and scoped to the selected sketch entity.
- [x] Add compact selected-rectangle workplane action row.
- [x] Extend widget coverage and update docs/tasks/worklog.

### Done Criteria
- The focused rectangle exposes workplane center and fit actions.
- Fit on a front-wall sketch stores center `[0.0, 0.0]`, width `120.0`, and
  height `28.0` for the sample enclosure.
- Centering after a nudge stores center `[0.0, 0.0]` while preserving
  width/height.
- Undo restores each quick action one semantic edit at a time.
- Quick actions update only semantic `SketchEntity` parameters and do not query
  mesh, B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Select a rectangle on a front-wall or top-lid sketch.
- Use the fit-to-workplane action and confirm the contour fills that workplane.
- Undo and confirm the previous size returns.
- Nudge the contour off center, then use center-on-workplane.
- Confirm it returns to the workplane center without changing size.

---

## M136 - Sketch Rectangle Semantic Rotation

### Goal
Let focused Advanced Sketch rectangles rotate as semantic helper contours:
the inspector writes a `rotation` parameter, the helper overlay and click target
use that angle, and bounds warnings account for rotated corners.

### Tasks
- [x] Add `rotation` to the rectangle sketch parameter schema and default
      rectangle entity.
- [x] Persist rotation in `SketchEntity.parameters` through normalized schema
      edits, duplication, save/load, and undo/redo.
- [x] Add compact selected-rectangle rotation quick actions.
- [x] Draw sketch helper rectangles with the stored angle.
- [x] Make sketch helper hit testing respect rotated bounds.
- [x] Make workplane-bounds validation check rotated rectangle corners.
- [x] Extend unit/widget coverage and update docs/tasks/worklog.

### Done Criteria
- A selected sketch rectangle exposes a `Поворот` field and +/- rotation
  actions.
- Pressing rotation + stores `rotation: 15.0` in project JSON and undo restores
  it to `0.0`.
- The helper overlay rotates visually while remaining a semantic
  `SketchEntity`, not a mesh/B-Rep sub-object.
- Clicking outside the rotated contour does not focus that rectangle even if
  the point is inside its unrotated axis-aligned box.
- Workplane bounds warnings use rotated rectangle corners.
- Rotation updates only semantic `SketchEntity` parameters and do not query
  mesh, B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart`
- `flutter test test\viewport_controller_test.dart`
- `flutter test test\project_model_test.dart`
- `flutter test test\widget_test.dart --name "advanced sketch command creates semantic helper feature"`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an `Эскиз`.
- Add a rectangle or select an existing `rect_1`.
- Press the selected rectangle rotation + button and confirm the helper contour
  visibly turns.
- Try clicking just outside the rotated contour; it should not focus the
  rectangle unless the click lands on the visible rotated helper shape.
- Save, reopen later if desired, and confirm the rotation remains.
- Press undo and confirm the contour returns to its previous angle.

---

## M137 - Sketch Rectangle Shape Quick Actions

### Goal
Make selected Advanced Sketch rectangles faster to shape without raw CAD
operations: add semantic corner-radius quick actions and a reset action for
rotation while keeping every edit schema-backed and undoable.

### Tasks
- [x] Add selected-rectangle radius +/- quick actions.
- [x] Add selected-rectangle radius reset action.
- [x] Add selected-rectangle rotation reset action.
- [x] Reuse the existing schema-backed parameter update path for radius/reset
      actions.
- [x] Extend unit/widget coverage and update docs/tasks/worklog.

### Done Criteria
- A selected rectangle exposes radius +/- and radius reset controls.
- Pressing radius + stores `cornerRadius: 1.0` in project JSON.
- Pressing radius reset stores `cornerRadius: 0.0`.
- Pressing rotation reset stores `rotation: 0.0` after a non-zero rotation.
- Undo restores radius and rotation reset actions one semantic edit at a time.
- Shape quick actions update only semantic `SketchEntity` parameters and do
  not query mesh, B-Rep, OCCT topology, or generated triangle ids.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart`
- `flutter test test\widget_test.dart --name "advanced sketch command creates semantic helper feature"`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an `Эскиз`.
- Add or select a rectangle.
- Use `Радиус +` and confirm the helper corners round visually.
- Use radius reset and confirm the helper returns to square corners.
- Rotate the helper, then use rotation reset and confirm it returns to 0°.
- Press undo a few times and confirm each shape edit rolls back separately.

---

## M138 - Sketch Circle Entity Foundation

### Goal
Add the first second-shape Advanced Sketch entity: a semantic circle helper that
can be placed, edited, selected in the viewport, saved, duplicated, nudged, and
validated without becoming generated geometry or mesh/topology state.

### Tasks
- [x] Add `circle` `SketchEntity` defaults with center and diameter.
- [x] Add a schema-backed circle parameter adapter.
- [x] Add circle workplane-bounds validation.
- [x] Add a circle add action in the Advanced Sketch inspector.
- [x] Reuse click-to-place and move-to-click for circle entities.
- [x] Add circle helper overlay rendering and hit testing.
- [x] Reuse generic semantic nudge/duplicate/delete/center/fit paths.
- [x] Extend unit/widget/viewport/selection coverage and update docs/tasks/worklog.

### Done Criteria
- A selected sketch exposes both rectangle and circle add actions.
- Clicking the circle action and then the workplane creates `circle_1`.
- `circle_1` stores semantic center and `diameter`.
- The circle helper overlay is visible and clickable as a semantic sketch
  entity focus target.
- The inspector can edit diameter and save it to project JSON.
- Undo can remove the circle edits without touching generated geometry.
- Circle validation warns when the circle extends outside the supported
  workplane.
- Circle edits do not query mesh, B-Rep, OCCT topology, or generated triangle
  ids.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart`
- `flutter test test\project_model_test.dart`
- `flutter test test\project_selection_resolver_test.dart`
- `flutter test test\viewport_controller_test.dart`
- `flutter test test\widget_test.dart --name "advanced sketch command creates semantic helper feature"`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an `Эскиз`.
- Click the circle icon in the sketch inspector, then click the sketch
  workplane.
- Confirm `circle_1` appears, is selected, and shows a `Диаметр` field.
- Use `Диаметр +` and confirm the circle grows.
- Click the circle overlay in the viewport and confirm it focuses `circle_1`.
- Press undo and confirm the circle diameter/addition rolls back cleanly.

---

## M139 - Sketch Entity Profile Intent

### Goal
Add semantic profile intent to Advanced Sketch entities as a safe bridge toward
future cut/extrude operations: each helper contour can be marked as reference,
cut, or add while still remaining helper-only project data.

### Tasks
- [x] Add normalized `profileIntent` helpers for `SketchEntity` metadata.
- [x] Add undoable inspector controls for reference/cut/add intent.
- [x] Preserve profile intent through save/load and duplication.
- [x] Show profile intent in selection details.
- [x] Tint helper overlays by profile intent without changing hit testing.
- [x] Extend unit/widget/viewport/selection coverage and update docs/tasks/worklog.

### Done Criteria
- Missing or unknown profile intent reads as `reference`.
- Changing a selected contour to `cut` stores
  `metadata.profileIntent = "cut"` in project JSON.
- Undo restores the previous intent without changing contour dimensions or
  generated geometry.
- Duplicate keeps the source contour's intent.
- Viewport helper overlays can display distinct intent colors while still
  resolving clicks to semantic sketch entity ids.
- `advanced_sketch.operation` remains `helper`; no B-Rep, mesh, boolean,
  extrusion, or topology id is created.

### Tests
- `flutter test test\sketch_entity_parameter_adapter_test.dart test\project_model_test.dart test\project_selection_resolver_test.dart --reporter compact`
- `flutter test test\viewport_controller_test.dart --reporter compact`
- `flutter test test\widget_test.dart --name "advanced sketch command creates semantic helper feature" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode, create/select an `Эскиз`, and select `rect_1` or
  `circle_1`.
- In the selected contour row, click the cut/add/reference intent icons.
- Confirm the helper contour tint changes and the inspector still selects the
  same contour.
- Save the project if desired and confirm Undo returns the previous intent.
- Confirm no new 3D cut/extrude is generated yet; this is still semantic setup.

---

## M140 - Sketch Profile Operation Plan

### Goal
Expose Advanced Sketch `cut`/`add` contour intent to the geometry operation
planner as deterministic request-scoped backend operations, while keeping the
editable project and preview geometry helper-only.

### Tasks
- [x] Keep parent `advanced_sketch` operation as `helper.advanced_sketch`.
- [x] Parse sketch entities from feature-intent metadata.
- [x] Ignore `reference` contours in generated profile operations.
- [x] Emit `sketch.profile.cut` with `operation=negative`.
- [x] Emit `sketch.profile.add` with `operation=positive`.
- [x] Include semantic shape parameters, parent sketch id, entity id, target
      surface, placement, and source metadata.
- [x] Cover planner and mock response metrics with tests.
- [x] Update docs/tasks/worklog.

### Done Criteria
- A sketch with only reference contours still plans as one helper operation.
- A sketch with one cut rectangle and one add circle plans as three operations:
  parent helper, `sketch.profile.cut`, and `sketch.profile.add`.
- Profile operations preserve rectangle/circle parameters and source
  `sketchEntityId`.
- Mock `GeometryResponse.metrics.operationPlan` exposes the same deterministic
  operations.
- No B-Rep, mesh, boolean, extrusion, or OCCT topology id is created.

### Tests
- `flutter test test\geometry_protocol_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- No new manual UI poke is required for this backend-contract chunk.
- Optional: open the latest exe and verify Advanced Sketch intent buttons still
  behave as in M139.
- Confirm no new 3D cut/extrude appears yet; this chunk only prepares the
  operation plan for future geometry.

---

## M141 - Native Sketch Profile Cut Slice

### Goal
Let the native OCCT preview consume the first Advanced Sketch `cut` contours as
real generated cutouts, while keeping the editable project semantic and keeping
unsupported sketch operations future-only.

### Tasks
- [x] Parse `advanced_sketch.entities` inside the native worker request parser.
- [x] Convert `profileIntent=cut` circle entities to native circular cutout
      requests.
- [x] Convert `profileIntent=cut` axis-aligned rectangle entities to native
      rectangular cutout requests.
- [x] Keep reference contours, `profileIntent=add`, unsupported entity types,
      and rotated rectangles out of native B-Rep for this slice.
- [x] Reuse existing top-lid/front-wall fit validation and generated cutout
      tool paths.
- [x] Map preview ranges back to stable sketch entity ids.
- [x] Cover the behavior with a native OCCT regression test.
- [x] Update docs/tasks/worklog/research notes.

### Done Criteria
- A top-lid Advanced Sketch with one cut circle and one cut rectangle produces
  generated lid cutouts in the native preview.
- The preview mesh exposes semantic surface ids such as
  `advanced_sketch_1.lid_round_cut` and `advanced_sketch_1.lid_rect_cut`.
- A same-sketch `profileIntent=add` entity does not generate native geometry
  yet.
- No raw OCCT topology id, face id, or triangle id is saved or exposed as
  editable project state.
- Existing semantic cutout tests still pass.

### Tests
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an `Эскиз` on the top lid.
- Add a circle or rectangle contour, set its intent to cut, and wait for the
  native preview to refresh.
- Confirm the contour cuts the generated lid preview.
- Set another contour to add and confirm it still behaves as future intent
  only.
- Avoid rotated rectangle cut expectations for now; that is a later slice.

---

## M142 - Native Rotated Sketch Rectangle Cut

### Goal
Let native OCCT preview consume rotated Advanced Sketch rectangle cuts without
changing the editable project source of truth or exposing raw topology ids.

### Tasks
- [x] Parse sketch rectangle `rotation` into native rectangular cutout requests.
- [x] Validate rotated rectangle corners against supported top-lid/front-wall
      workplane bounds.
- [x] Rotate generated rectangular cut tools around the target surface normal.
- [x] Keep preview range mapping semantic and stable for rotated sketch entity
      ids.
- [x] Cover the behavior with a native OCCT regression fixture/test.
- [x] Update docs/tasks/worklog/research notes.

### Done Criteria
- A top-lid Advanced Sketch rotated rectangle with `profileIntent=cut`
  generates a native preview cutout.
- The preview mesh exposes `advanced_sketch_1.lid_rotated_rect_cut`.
- `profileIntent=add` remains future-operation data and does not generate
  native geometry.
- No raw OCCT topology id, face id, or triangle id is saved or exposed as
  editable project state.

### Tests
- `dart format test\support\native_occt_geometry_fixture.dart test\native_occt_geometry_regression_test.dart`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an Advanced Sketch on the top lid.
- Add/select a rectangle, set its intent to cut, then rotate it with the
  rectangle controls.
- Confirm the native preview cut follows the rectangle angle instead of
  remaining axis-aligned.
- Set a contour to add and confirm it still stays future-only for now.

---

## M143 - Native Sketch Add Protrusion Slice

### Goal
Let native OCCT preview consume first-pass Advanced Sketch `add` contours as
simple positive protrusions while keeping the editable project semantic.

### Tasks
- [x] Add a native `SketchAddRequest` separate from cutout request types.
- [x] Parse `profileIntent=add` circle and rectangle sketch entities.
- [x] Validate add contours against supported front-wall/top-lid workplane
      bounds.
- [x] Generate circular and rectangular protrusion B-Rep with a small surface
      overlap for reliable fuse.
- [x] Fuse front-wall adds into the body and top-lid adds into the generated
      lid plate.
- [x] Map preview ranges back to stable sketch entity ids.
- [x] Cover add behavior with a native OCCT regression test.
- [x] Update docs/tasks/worklog/research notes.

### Done Criteria
- A top-lid Advanced Sketch circle with `profileIntent=add` generates a native
  positive protrusion.
- The preview mesh exposes `advanced_sketch_1.lid_circle_add`.
- `cut` circles/rectangles, including rotated rectangles, still generate
  native cutouts.
- No raw OCCT topology id, face id, triangle id, B-Rep, or mesh is saved as
  editable project state.

### Tests
- `dart format test\support\native_occt_geometry_fixture.dart test\native_occt_geometry_regression_test.dart`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an Advanced Sketch on the top lid.
- Add/select a circle or rectangle and set its intent to add.
- Confirm the native preview shows a small raised protrusion for that contour.
- Switch the same contour between reference/cut/add and confirm the native
  preview updates between helper-only, cutout, and protrusion behavior.

---

## M144 - Sketch Profile Depth Controls

### Goal
Make Advanced Sketch cut/add depth a first-class semantic parameter in the UI
and operation plan without exposing raw extrude/boolean CAD controls.

### Tasks
- [x] Add schema-backed `depth` to rectangle and circle sketch entities.
- [x] Keep depth explicit so reference contours do not gain it during unrelated
      nudge/resize edits.
- [x] Add compact cut depth / add height inspector controls for selected
      cut/add contours.
- [x] Pass explicit depth through `sketch.profile.cut/add` operation planning.
- [x] Cover adapter, operation-plan, widget, and native fixture behavior.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Reference sketch entities still edit center/size/rotation without silently
  saving depth.
- Selecting `profileIntent=cut` exposes a depth control that saves
  `SketchEntity.parameters.depth`.
- Selecting `profileIntent=add` exposes a height control using the native add
  protrusion default.
- Operation plans include `depth` when a semantic sketch entity has it.
- Editable project state remains semantic `SketchEntity` data only.

### Tests
- `dart format lib\parameters\sketch_entity_parameter_adapter.dart lib\geometry\geometry_operation_plan.dart lib\ui\shell\workspace_shell.dart test\sketch_entity_parameter_adapter_test.dart test\geometry_protocol_test.dart test\widget_test.dart test\support\native_occt_geometry_fixture.dart`
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`
- `flutter test test\geometry_protocol_test.dart --plain-name "operation planner emits sketch profile operations as future intent" --reporter compact`
- `flutter test test\widget_test.dart --name "advanced sketch command creates semantic helper feature" --reporter compact`
- `flutter test test\native_occt_geometry_regression_test.dart --plain-name "native OCCT preview cuts and adds advanced sketch profile contours" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an Advanced Sketch on the top lid.
- Add/select a rectangle or circle and leave it as reference; confirm no depth
  row is shown for the selected contour.
- Switch it to `Вырез`; confirm the `Глубина` row appears, +/- changes the
  cut depth, and Save keeps the value after reopening.
- Switch it to `Выступ`; confirm the row becomes `Высота` and the native
  preview protrusion updates after changing it.

---

## M145 - Native Sketch Entity Picking

### Goal
Let native preview mesh ranges for Advanced Sketch profile contours focus the
semantic `SketchEntity` they came from, instead of selecting only the parent
sketch or ignoring the generated part.

### Tasks
- [x] Recognize stable native preview semantic ids shaped as
      `{sketchFeatureId}.{sketchEntityId}`.
- [x] Convert those ids into `SelectionModel.sketchEntity`.
- [x] Highlight the child native preview range when a sketch entity is
      selected.
- [x] Show depth/height in sketch entity selection details when present.
- [x] Cover resolver and widget native-click behavior.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Clicking a native preview mesh range mapped to `advanced_sketch_1.circle_1`
  selects `circle_1` under parent `advanced_sketch_1`.
- The inspector focuses the selected sketch entity and shows its semantic
  values.
- The selected native child range gets the generated mesh highlight.
- No raw OCCT topology id, face id, triangle id, B-Rep, or mesh becomes
  editable project state.

### Tests
- `dart format lib\ui\shell\workspace_shell.dart lib\selection\project_selection_resolver.dart test\project_selection_resolver_test.dart test\widget_test.dart`
- `flutter test test\project_selection_resolver_test.dart --reporter compact`
- `flutter test test\widget_test.dart --name "native preview mesh click selects mapped sketch entity" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and create/select an Advanced Sketch on the top lid.
- Add a circle or rectangle, switch it to `Вырез` or `Выступ`, and wait for
  native preview to update.
- Click the generated cut/protrusion part in the 3D preview.
- Confirm the inspector focuses that exact contour and the mesh highlight
  lands on the generated part.

---

## M146 - Sketch Entity Viewport Drag Move

### Goal
Let a focused Advanced Sketch contour move directly in the viewport while
committing only its semantic workplane center through undoable project edits.

### Tasks
- [x] Detect primary-button drag starts only on the currently focused
      `SketchEntity` helper contour.
- [x] Convert the drag release back to the owning sketch workplane local
      coordinate system.
- [x] Commit the move through the existing semantic
      `_moveAdvancedSketchEntity` path.
- [x] Keep normal orbit/pan behavior when no selected contour drag is active.
- [x] Cover save and undo behavior with a widget test.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Dragging inside the selected helper rectangle updates
  `SketchEntity.parameters.center`.
- The saved project JSON contains the new center and no generated mesh,
  B-Rep, triangle id, or topology id.
- Undo restores the previous center.
- Primary drag on non-focused viewport regions still orbits normally.

### Tests
- `flutter test test\widget_test.dart --name "selected sketch entity drags on workplane semantically" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an Advanced Sketch.
- Select a rectangle or circle helper contour so its row is focused.
- Drag the selected helper contour inside the viewport.
- Save, undo, and confirm the contour returns to its previous position.

---

## M147 - Sketch Entity Live Drag Preview

### Goal
Make selected Advanced Sketch contour dragging feel direct by previewing the
moving helper contour during mouse drag while still committing only one
semantic center edit on release.

### Tasks
- [x] Track a transient selected-sketch-entity drag preview in viewport state.
- [x] Override only the matching helper rectangle/circle preview center while
      dragging.
- [x] Show a grabbing cursor and a test marker while the transient preview is
      active.
- [x] Clear preview state on pointer up and cancel.
- [x] Keep save/undo behavior on the existing semantic move path.
- [x] Cover transient preview activation/removal with a widget test.
- [x] Update docs/tasks/worklog.

### Done Criteria
- Dragging the focused helper contour shows a transient moved contour before
  release.
- Releasing commits the final workplane center through
  `SketchEntity.parameters.center`.
- Canceling or clicking without drag leaves no stale drag state.
- No generated mesh, B-Rep, triangle id, or topology id becomes editable state.

### Tests
- `flutter test test\widget_test.dart --name "selected sketch entity drags on workplane semantically" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an Advanced Sketch.
- Focus a rectangle or circle helper contour.
- Drag it and confirm the helper contour follows the cursor during the drag.
- Release, save if desired, then undo and confirm the contour returns.

---

## M148 - Sketch Circle Drag Parity

### Goal
Lock in circle helper contour dragging as the same semantic, live-preview,
save/load-safe interaction as rectangle dragging before expanding sketch
editing further.

### Tasks
- [x] Add focused circle helper drag coverage.
- [x] Verify circle drag uses the transient live preview marker.
- [x] Verify release commits `SketchEntity.parameters.center`.
- [x] Verify undo restores the previous circle center.
- [x] Update tasks/worklog.

### Done Criteria
- Rectangle and circle helper contours both have widget coverage for direct
  viewport drag.
- Circle drag preview state is transient and disappears after release.
- Saved project JSON contains only semantic sketch entity center data.
- No generated mesh, B-Rep, triangle id, or topology id becomes editable state.

### Tests
- `flutter test test\widget_test.dart --name "sketch entity drags on workplane semantically" --reporter compact`
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`
- `flutter analyze`
- `flutter test --reporter compact`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`
- `git diff --check`

### Poke Checklist
- Open the latest exe.
- Enable Advanced Mode and select/create an Advanced Sketch.
- Add or select a circle helper contour.
- Drag it and confirm it follows the cursor during drag.
- Release, save if desired, then undo and confirm the circle returns.
