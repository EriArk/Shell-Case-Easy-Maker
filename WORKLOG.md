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

---

## 2026-06-26 — Repository documentation orientation

### Goal
Study the newly added project documentation and check local/GitHub repository state.

### Read before work
`AGENTS.md`, `README.md`, `TASKS.md`, `MANIFEST.json`, all `docs/*.md`, examples, and templates.

### Changes made
- `TASKS.md`:
  - Added a Phase 0 task to configure the GitHub `origin` remote and push the initial documentation commit.
- `WORKLOG.md`:
  - Added this orientation entry.

### Tests run
- Not run; this was a documentation/repository orientation pass only.

### Validation
- Confirmed documentation pack contains 42 manifest entries.
- Confirmed local repository has no commits yet.
- Confirmed local repository has no configured `origin` remote.
- Confirmed the GitHub repository page is public but currently empty.

### Known issues
- Issue: local Git repository is not connected to `https://github.com/EriArk/Shell-Case-Easy-Maker`.
  - Severity: Medium.
  - Next action: add `origin`, create the first commit, and push.

### Next step
Bootstrap the Flutter desktop project or publish the documentation pack to GitHub first.

### Notes for future Codex sessions
The core product direction is semantic enclosure/device/accessory generation, not generic CAD. Keep Flutter isolated from OCCT internals through `GeometryService`, keep generated B-Rep/meshes as outputs, and add tests for geometry, serialization, validation, and UI state changes.

---

## 2026-06-26 — Flutter bootstrap and semantic shell

### Goal
Publish the initial documentation commit, create the Flutter desktop skeleton, and replace the counter app with a product-aligned shell.

### Read before work
`AGENTS.md`, `TASKS.md`, `docs/00_PROJECT_VISION.md`, `docs/01_PRODUCT_RULES.md`, `docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/05_PROJECT_FILE_FORMAT.md`, and `docs/26_TESTING_AND_QUALITY.md`.

### Changes made
- Git repository:
  - Renamed the initial branch to `main`.
  - Added `origin` as `https://github.com/EriArk/Shell-Case-Easy-Maker.git`.
  - Created and pushed the initial documentation commit.
- Flutter project:
  - Created Windows/Linux/macOS Flutter desktop scaffold with project name `shell_case_easy_maker`.
  - Replaced the default counter app with a viewport-first workspace shell.
- `lib/project/project_model.dart`:
  - Added an initial semantic project model with versioned JSON serialization.
- `lib/geometry/geometry_service.dart`:
  - Added `GeometryService`, selectable semantic surfaces, preview metadata, and a mock backend.
- `lib/commands/app_command.dart`:
  - Added an initial command metadata skeleton.
- `lib/validation/validation_result.dart`:
  - Added validation report/message models.
- `lib/ui/shell/workspace_shell.dart`:
  - Added top toolbar, left icon rail, central mock viewport, right inspector, view cube placeholder, and status bar.
- `test/`:
  - Added widget and project serialization tests.
- `README.md`:
  - Added development quick-start commands.
- `TASKS.md`:
  - Marked completed Phase 0 bootstrap items.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 3 tests.

### Validation
- Geometry checked?
  - Mock geometry service only; no OCCT geometry yet.
- Serialization checked?
  - Yes, `ProjectModel` JSON round-trip test.
- UI checked?
  - Yes, widget test caught and verified the shell after fixing a toolbar overflow.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: GitHub CLI is not installed in this environment.
  - Severity: Low.
  - Next action: continue using `git push`, or install `gh` later if PR automation is needed.
- Issue: Basic CI is still missing.
  - Severity: Medium.
  - Next action: add a Flutter analyze/test GitHub Actions workflow.
- Issue: Geometry is still mocked.
  - Severity: Expected for Phase 0.
  - Next action: research Flutter viewport options or begin deeper semantic model work before OCCT integration.

### Next step
Add basic CI, then continue Phase 1 with stronger typed semantic models, migrations, command registry, and undo/redo transaction design.

### Notes for future Codex sessions
Keep committing and pushing at the end of each meaningful work session. The current app shell intentionally uses semantic surface IDs and a mock `GeometryService`; do not let UI code depend on OCCT topology or generated mesh IDs.

---

## 2026-06-27 — Basic Flutter CI

### Goal
Add a basic GitHub Actions workflow that validates formatting, analysis, and tests on `main`.

### Read before work
`AGENTS.md`, `TASKS.md`, `docs/26_TESTING_AND_QUALITY.md`, `docs/27_RESEARCH_AND_REFERENCES.md`, GitHub Actions checkout documentation, Flutter continuous delivery documentation, and `subosito/flutter-action` documentation.

### Changes made
- `.github/workflows/flutter-ci.yml`:
  - Added `Flutter CI` workflow for pushes and pull requests targeting `main`.
  - Pinned Flutter to `3.44.2` and enabled Flutter/pub caching.
  - Runs dependency install, format check, analyzer, and tests.
- `README.md`:
  - Added CI status badge.
- `docs/27_RESEARCH_AND_REFERENCES.md`:
  - Added research note for Flutter GitHub Actions setup and license compatibility.
- `TASKS.md`:
  - Marked basic CI complete.
- `WORKLOG.md`:
  - Added this worklog entry.

### Tests run
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 3 tests.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; CI validates existing tests only.
- Serialization checked?
  - Covered by `flutter test`.
- UI checked?
  - Covered by widget test in `flutter test`.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: CI does not build desktop packages yet.
  - Severity: Low.
  - Next action: add platform build jobs later during packaging work.

### Next step
Continue Phase 1 by strengthening typed project models and introducing a real command registry/undo design.

### Notes for future Codex sessions
Keep CI lightweight until platform packaging dependencies are intentionally researched and documented.

---

## 2026-06-27 — Roadmap and latest Windows bundle path

### Goal
Create the working roadmap and make the latest Windows build easy to open manually.

### Read before work
`AGENTS.md`, `TASKS.md`, `docs/28_IMPLEMENTATION_PLAN.md`, `README.md`, `.gitignore`, and Windows Flutter CMake configuration.

### Changes made
- `ROADMAP.md`:
  - Added the main 1-2 day chunk roadmap with done criteria, tests, and poke checklists.
- `tools/build_latest_windows.ps1`:
  - Added a Windows release script that builds Flutter, refreshes `releases/latest/windows`, and prints the `.exe` path.
- `.gitignore`:
  - Ignored generated local release bundles under `releases/`.
- `README.md`:
  - Documented `ROADMAP.md`, the build script, and the latest local `.exe` path.
- `TASKS.md`:
  - Linked the roadmap and marked roadmap/latest Windows build tasks complete.
- `WORKLOG.md`:
  - Added this worklog entry.

### Tests run
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 3 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed and created `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed; Git reported expected CRLF normalization for `.gitignore`.

### Validation
- Geometry checked?
  - Not applicable; this chunk only changes roadmap/build access.
- Serialization checked?
  - Covered by existing tests after validation.
- UI checked?
  - Build bundle was created and is ready for manual launch.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: `releases/latest/windows` is local-only and must be regenerated after app changes.
  - Severity: Low.
  - Next action: run `tools/build_latest_windows.ps1` after each meaningful UI/runtime chunk.

### Next step
Continue with M1 Semantic Core from `ROADMAP.md`.

### Notes for future Codex sessions
The latest manual Windows app should be opened from `releases/latest/windows/shell_case_easy_maker.exe`, not by copying only the `.exe` elsewhere.

---

## 2026-06-27 — M1 Semantic Core

### Goal
Split the semantic project model into focused typed modules with versioned JSON parsing and tests.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`, `docs/28_IMPLEMENTATION_PLAN.md`, existing `lib/project/project_model.dart`, existing project tests, and example JSON fixtures.

### Changes made
- `lib/project/`:
  - Split the semantic model into focused files for schema constants, JSON helpers, enclosure, component placement, feature, feature group, component template, migration, and project model.
  - Added typed `ComponentTemplate`/board/hole/feature/zone models.
  - Added `ProjectMigration` as the central schema migration entrypoint.
  - Preserved unknown semantic metadata during JSON round-trips so future subsystem fields and root project metadata are not dropped.
- `test/project_model_test.dart`:
  - Added tests for minimal migration defaults, fixture parsing, component template round-trips, metadata preservation, and newer-version rejection.
- `docs/05_PROJECT_FILE_FORMAT.md`:
  - Documented the current implementation skeleton.
- `ROADMAP.md` and `TASKS.md`:
  - Marked completed M1/Phase 1 semantic model items.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 8 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; no geometry backend changes.
- Serialization checked?
  - Yes, project and component template round-trip tests cover fixtures and defaults.
- UI checked?
  - Widget test still covers shell rendering; latest Windows bundle was regenerated for manual launch.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Many subsystem-specific feature fields are preserved as metadata rather than fully typed.
  - Severity: Low.
  - Next action: type them as each subsystem is implemented.

### Next step
Run final validation, regenerate the latest Windows bundle, then continue with M2 Commands + Undo.

### Notes for future Codex sessions
Keep `ProjectModel` semantic-only. Do not add generated meshes, STL paths as source data, OCCT topology, or triangle IDs to these models.

---

## 2026-06-27 — M2 Commands and Undo

### Goal
Add command metadata, command availability rules, and undo/redo transaction foundations.

### Read before work
`AGENTS.md`, `ROADMAP.md`, existing `lib/commands/app_command.dart`, `lib/ui/shell/workspace_shell.dart`, and command/undo expectations from project docs.

### Changes made
- `lib/commands/`:
  - Added stable command IDs, command registry, command availability rules, and snapshot-based undo history.
  - Added continuous transaction grouping for future knob/drag/encoder edits.
- `lib/ui/shell/workspace_shell.dart`:
  - Connected toolbar and rail labels/icons to command metadata while preserving the existing layout.
- `docs/31_COMMANDS_AND_UNDO.md`:
  - Documented command metadata, context, registry, undo behavior, and current limitations.
- `test/`:
  - Added tests for core command metadata, availability, advanced mode gating, undo/redo, redo clearing, and continuous grouping.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M2 command/undo items complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 16 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; no geometry backend changes.
- Serialization checked?
  - Existing serialization tests still pass.
- UI checked?
  - Widget test still covers shell rendering; latest Windows bundle was regenerated for manual launch.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Commands are metadata-only and do not dispatch semantic edits yet.
  - Severity: Expected for M2.
  - Next action: wire commands into selection/project editing during M3/M2 follow-up.
- Issue: Undo history is not connected to UI state yet.
  - Severity: Expected for M2.
  - Next action: connect it when project editing commands exist.

### Next step
Run final validation, refresh latest Windows bundle, then continue with M3 Usable Shell.

### Notes for future Codex sessions
Keep command availability based on semantic context: selected object ID, active surface ID, advanced mode, and undo/redo state. Do not base command availability on raw mesh or OCCT IDs.

---

## 2026-06-27 — M3 Usable Shell

### Goal
Make the shell useful for manual semantic exploration by adding selection,
contextual inspector updates, a compact project browser, and basic project JSON
file service.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, existing project model files,
`lib/ui/shell/workspace_shell.dart`, command registry files, and current tests.

### Changes made
- `lib/selection/`:
  - Added `SelectionModel` for workspace/object/surface focus.
  - Added `ProjectSelectionResolver` to describe selected semantic state for
    inspector/status UI without putting business rules in widgets.
- `lib/ui/shell/workspace_shell.dart`:
  - Added a compact semantic project browser.
  - Connected selected project, enclosure, surface, component, template, and
    feature to the inspector and status hint.
  - Connected tool rail availability to selection-driven `CommandContext`.
  - Added mock viewport highlights for selected semantic items.
- `lib/project/project_file_service.dart`:
  - Added JSON encode/decode and disk read/write helpers for project files.
- `docs/32_USABLE_SHELL.md`:
  - Documented selection, browser, inspector details, and current limits.
- `docs/31_COMMANDS_AND_UNDO.md`:
  - Updated the limitation note now that selection context exists.
- `test/`:
  - Added tests for selection context, selection resolver, project file service,
    and contextual inspector widget behavior.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M3 usable shell items complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 26 tests.

### Validation
- Geometry checked?
  - Mock viewport only; selected semantic items now show mock highlights.
- Serialization checked?
  - Yes, `ProjectFileService` encode/decode and disk round-trip tests.
- UI checked?
  - Yes, widget tests cover selecting an enclosure and a semantic feature.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Save/load is service-level only and not wired to native file dialogs.
  - Severity: Expected for M3.
  - Next action: add explicit open/save command dispatch after the command
    controller layer exists.
- Issue: Viewport selection is still browser-driven, not direct hit testing.
  - Severity: Expected before M4.
  - Next action: research and implement viewport interaction in M4.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
continue with M4 Viewport MVP research and interaction model.

### Notes for future Codex sessions
Keep selection semantic. Do not introduce triangle IDs, raw OCCT IDs, or mesh
hit-test IDs as editable project state.

---

## 2026-06-27 — M4 Viewport MVP

### Goal
Research Flutter viewport options and add the first interactive mock viewport:
orbit, pan, zoom, fit, semantic hit testing, and ghost preview state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/27_RESEARCH_AND_REFERENCES.md`,
`lib/ui/shell/workspace_shell.dart`, selection files, and current tests.

### Changes made
- `docs/27_RESEARCH_AND_REFERENCES.md`:
  - Added research note for Flutter viewport options, package candidates,
    licensing, and the decision to keep M4 on `CustomPaint`.
- `lib/viewport/viewport_controller.dart`:
  - Added `ViewportController`, `ViewportState`, ghost preview state, shared
    mock layout, and semantic hit testing.
- `lib/ui/shell/workspace_shell.dart`:
  - Added primary-drag orbit, secondary/middle-drag pan, wheel zoom, click
    selection in the viewport, fit via the view cube, camera-aware mock drawing,
    and surface ghost previews.
- `docs/33_VIEWPORT_MVP.md`:
  - Documented the viewport state model, current controls, ghost previews,
    renderer decision, and limits.
- `test/viewport_controller_test.dart`:
  - Added tests for orbit/pan/zoom bounds, fit behavior, ghost preview state,
    and semantic hit-test outputs.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M4 viewport MVP items complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 31 tests.

### Validation
- Geometry checked?
  - Mock viewport only; no generated OCCT geometry yet.
- Serialization checked?
  - Existing project serialization tests still pass.
- UI checked?
  - Widget tests still pass; viewport controller tests cover interaction state.
- Export checked?
  - Not applicable yet.

### Known issues
- Issue: Viewport is still a stylized mock, not generated preview mesh.
  - Severity: Expected for M4.
  - Next action: define preview mesh/worker protocol in M5.
- Issue: Hit testing uses deterministic mock zones.
  - Severity: Expected for M4.
  - Next action: later replace with semantic face/object mappings from
    generated preview data, never raw triangle IDs as editable state.
- Issue: View cube is a compact fit control, not full orientation navigation.
  - Severity: Low.
  - Next action: expand after real viewport behavior stabilizes.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
continue with M5 First Geometry Slice.

### Notes for future Codex sessions
M4 intentionally adds no 3D renderer dependency. Revisit renderer choices after
`GeometryService` has a concrete preview mesh protocol and semantic face mapping.

---

## 2026-06-27 — M5 First Geometry Slice

### Goal
Create the first real geometry boundary: OCCT research, typed request/response
protocol, `occt_worker` skeleton, deterministic mock preview mesh, and rounded
enclosure implementation plan.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
OCCT official overview/build/licensing/modeling/mesh/STEP documentation, and
current geometry/viewport tests.

### Changes made
- `lib/geometry/geometry_protocol.dart`:
  - Added typed JSON request/response models for geometry operations.
  - Added preview mesh, semantic surface mapping, bounds, artifact, and issue
    models.
- `lib/geometry/geometry_service.dart`:
  - Added `buildGeometry(GeometryRequest)` to the service boundary.
  - Kept existing mock preview behavior usable.
  - Added deterministic mock preview mesh response with semantic surface IDs.
- `occt_worker/`:
  - Added worker boundary README.
  - Added preview request/response example JSON files.
- `docs/27_RESEARCH_AND_REFERENCES.md`:
  - Added OCCT first geometry slice research with official source links.
- `docs/34_FIRST_GEOMETRY_SLICE.md`:
  - Documented protocol shape, preview mesh mapping, rounded enclosure plan,
    and current limitations.
- `test/geometry_protocol_test.dart`:
  - Added protocol round-trip tests, semantic mapping checks, deterministic mock
    mesh checks, and unsupported operation behavior.
- `ROADMAP.md` and `TASKS.md`:
  - Marked M5 protocol/skeleton work complete while keeping real OCCT B-Rep,
    worker executable, and export tasks open.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 35 tests.

### Validation
- Geometry checked?
  - Protocol-level and mock mesh only; no native OCCT executable yet.
- Serialization checked?
  - Yes, request/response protocol round-trip tests.
- UI checked?
  - Existing widget tests still pass; mock preview remains usable.
- Export checked?
  - Not implemented yet; mock backend rejects export operations explicitly.

### Known issues
- Issue: No native `occt_worker` executable exists yet.
  - Severity: Expected for M5 protocol slice.
  - Next action: choose Windows OCCT distribution path, then add worker build.
- Issue: Mock preview mesh is a cuboid, not rounded B-Rep output.
  - Severity: Expected.
  - Next action: implement rounded box B-Rep generation behind the worker.
- Issue: STEP/STL export operations are protocol placeholders only.
  - Severity: Expected.
  - Next action: add exporters after B-Rep generation is stable.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
start the first native worker/build slice.

### Notes for future Codex sessions
Keep raw OCCT topology inside the worker. Flutter may receive disposable preview
triangle ranges for rendering, but semantic selection/editing must use semantic
IDs from the protocol.

---

## 2026-06-27 — M6 Parameter Model

### Goal
Add typed parameter schemas with units, ranges, steps, defaults, choices, and
validation before generator UI and geometry commands depend on raw maps.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, existing project JSON helpers, validation
model, and current geometry/selection tests.

### Changes made
- `lib/parameters/parameter_model.dart`:
  - Added parameter kinds for length, angle, count, ratio, boolean, choice, and
    text.
  - Added parameter definitions, ranges, options, schemas, issues, defaults,
    normalization, snap/clamp, and raw input validation.
  - Added `CoreParameterSchemas.roundedEnclosure` for first enclosure generator
    controls.
- `test/parameter_model_test.dart`:
  - Added tests for defaults, range snap/clamp, range/choice validation, JSON
    round-trip, and invalid raw values after default application.
- `docs/35_PARAMETER_MODEL.md`:
  - Documented the parameter model, defaults/validation flow, first schema, and
    current limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M6/parameter model complete.

### Tests run
- `dart format lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 40 tests.

### Validation
- Geometry checked?
  - Not applicable; this chunk does not change generated geometry.
- Serialization checked?
  - Yes, parameter schema JSON round-trip test.
- UI checked?
  - Existing widget tests still pass; no new parameter UI yet.
- Export checked?
  - Not applicable.

### Known issues
- Issue: Parameter model is not wired into inspector widgets yet.
  - Severity: Expected for M6 foundation.
  - Next action: use schemas when implementing generator commands/inspector
    controls.
- Issue: Cross-parameter rules are not implemented.
  - Severity: Expected.
  - Next action: add generator-specific validation for constraints such as
    corner radius fitting within body dimensions.

### Next step
Refresh the latest Windows bundle, run final validation, commit, push, then
continue with generator command wiring or first native worker build slice.

### Notes for future Codex sessions
Keep parameter schemas separate from generated geometry. Use them to feed UI
controls and generator validation, not to replace semantic project models.

---

## 2026-06-27 — M7 Enclosure Parameter Inspector

### Goal
Wire the rounded enclosure parameter schema into the contextual inspector so
the first enclosure can be edited as semantic project data.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`docs/35_PARAMETER_MODEL.md`, current shell widgets, geometry service, viewport
controller, and widget/protocol tests.

### Changes made
- `lib/project/enclosure.dart` and `lib/project/project_model.dart`:
  - Added small immutable update helpers for enclosure/project edits.
- `lib/parameters/enclosure_parameter_adapter.dart`:
  - Added mapping between `Enclosure` fields and
    `CoreParameterSchemas.roundedEnclosure`.
  - Keeps edits semantic and applies schema defaults/snapping.
- `lib/ui/shell/workspace_shell.dart`:
  - Added local editable project state inside the shell.
  - Added compact inspector controls for selected enclosure parameters.
  - Refreshes mock preview and validation after parameter changes.
- `lib/geometry/geometry_service.dart`:
  - Mock preview mesh bounds now use semantic enclosure dimensions from the
    request project.
- `lib/viewport/viewport_controller.dart`:
  - Mock viewport layout can react to enclosure width/depth/corner radius.
- `docs/32_USABLE_SHELL.md` and `docs/35_PARAMETER_MODEL.md`:
  - Documented the first parameter inspector wiring and current limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M7 complete.

### Tests run
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 46 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1`:
  - Passed; refreshed `releases/latest/windows`.

### Validation
- Geometry checked?
  - Mock protocol bounds now follow semantic enclosure dimensions.
- Serialization checked?
  - Existing project serialization tests still pass.
- UI checked?
  - Widget test edits enclosure width through the inspector and observes the
    semantic size row update.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Inspector edits are local only; toolbar save/open is not wired.
  - Severity: Expected.
  - Next action: connect edits to command/undo/save flow.
- Issue: Undo history is not connected to parameter edits yet.
  - Severity: Important before larger editing workflows.
  - Next action: route parameter edits through commands/transactions.
- Issue: Cross-parameter validation is still minimal.
  - Severity: Expected.
  - Next action: add generator validation for wall/radius/body relationships.

### Next step
Commit and push M7, then continue with command/undo wiring for parameter edits
or the first native `occt_worker` executable slice.

### Notes for future Codex sessions
Keep the default enclosure workflow generator-first. The inspector should expose
semantic maker controls, not raw sketch/extrude/boolean operations.

---

## 2026-06-27 — M8 Parameter Undo/Redo

### Goal
Route first enclosure parameter edits through semantic undo/redo so parameter
exploration is reversible.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, current workspace shell, command registry, and
widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced local mutable project field with `UndoHistory<ProjectModel>`.
  - Commits effective enclosure parameter edits as semantic transactions.
  - Enables/disables toolbar undo/redo from real history state.
  - Restores project snapshots and refreshes preview/validation on undo/redo.
  - Added stable toolbar command keys for widget coverage.
- `test/widget_test.dart`:
  - Added coverage for editing enclosure width, undoing it, and redoing it.
- `docs/31_COMMANDS_AND_UNDO.md` and `docs/32_USABLE_SHELL.md`:
  - Documented first undo wiring and current command limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M8 complete.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 47 tests.

### Validation
- Geometry checked?
  - Mock preview/validation refresh after undo/redo.
- Serialization checked?
  - Existing project serialization tests still pass.
- UI checked?
  - Widget test verifies toolbar undo/redo availability and semantic size
    restoration.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: There is still no command dispatcher/controller layer.
  - Severity: Expected.
  - Next action: introduce command execution before wiring more tools.
- Issue: Undo grouping for continuous knobs/sliders is not used by inspector
  fields yet.
  - Severity: Expected.
  - Next action: use continuous transactions for drag/knob controls later.
- Issue: Save/load commands are still not wired to the edited project state.
  - Severity: Important before real project use.
  - Next action: connect file commands after command dispatcher shape is clear.

### Next step
Refresh latest Windows bundle, run final validation, commit, push, then continue
with command execution or save/load wiring.

### Notes for future Codex sessions
Keep undo snapshots semantic. Preview generation and any future OCCT artifacts
must be refreshable outputs, not undo state.

---

## 2026-06-27 — M9 Project Open/Save

### Goal
Wire native desktop open/save dialogs to semantic project JSON so edited
projects can be persisted and reopened.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `ProjectFileService`, command registry, and shell
widget tests.

### Dependency check
- Added `file_selector` `^1.1.0`.
- Checked pub.dev package metadata:
  - publisher: `flutter.dev`,
  - purpose: native file dialogs,
  - supported platforms include Windows,
  - license metadata: `BSD-3-Clause`.
- No plugin source code was copied.

### Changes made
- `lib/project/project_file_dialog_service.dart`:
  - Added `ProjectFileDialogService` seam.
  - Added `FileSelectorProjectFileDialogService` using `file_selector`.
  - Added `.enclosure.json` suffix helper.
- `lib/ui/shell/workspace_shell.dart`:
  - Added open/save toolbar wiring.
  - Save writes current semantic `ProjectModel`.
  - Open loads project JSON, resets undo history, selection, and preview state.
  - Status bar reports file operation state.
- `lib/commands/command_ids.dart` and `lib/commands/command_registry.dart`:
  - Added workspace open/save commands.
- `test/project_file_service_test.dart`, `test/command_registry_test.dart`,
  and `test/widget_test.dart`:
  - Added extension, command metadata, save, and open coverage.
  - Widget tests use fake dialog/file services instead of native dialogs or
    real disk IO.
- `docs/05_PROJECT_FILE_FORMAT.md`, `docs/27_RESEARCH_AND_REFERENCES.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented open/save behavior, dependency decision, and limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M9 complete.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 51 tests.

### Validation
- Geometry checked?
  - Preview refreshes after opening a project.
- Serialization checked?
  - Save/open tests verify semantic project JSON round-trip behavior.
- UI checked?
  - Widget tests verify save and open toolbar commands with fakes.
- Export checked?
  - STL/STEP export remains future work and is separate from project save.

### Known issues
- Issue: No unsaved-changes prompt before opening another project.
  - Severity: Important before real daily use.
  - Next action: add dirty tracking and confirm dialog.
- Issue: No separate "Save As" command yet.
  - Severity: Expected for compact first slice.
  - Next action: add when command/menu structure expands.
- Issue: Dependency license notices are not bundled yet.
  - Severity: Packaging-stage task.
  - Next action: handle in packaging/license chunk.

### Next step
Refresh latest Windows bundle, run final validation, commit, push, then add
dirty-state prompts or continue toward first real generator command.

### Notes for future Codex sessions
Project save/open is not geometry export. Keep editable files semantic; STEP,
STL, DXF, preview meshes, and OCCT artifacts must stay generated outputs.

---

## 2026-06-27 — M10 Unsaved Changes Guard

### Goal
Prevent accidental loss of unsaved semantic edits when opening another project.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/32_USABLE_SHELL.md`, current workspace shell, and widget save/open tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added persisted semantic project fingerprint tracking.
  - Added dirty status in the bottom status bar.
  - Saving updates the clean baseline.
  - Opening a project updates the clean baseline and resets undo history.
  - Opening while dirty shows a confirmation dialog before invoking the file
    picker.
  - Canceling the dirty dialog keeps the current project unchanged.
- `test/widget_test.dart`:
  - Added coverage for dirty open cancel.
  - Added coverage for dirty open confirm/discard.
- `docs/05_PROJECT_FILE_FORMAT.md` and `docs/32_USABLE_SHELL.md`:
  - Updated open/save behavior and limitations.
- `ROADMAP.md` and `TASKS.md`:
  - Added and marked M10 complete.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test/widget_test.dart -r expanded`:
  - Passed, 8 widget tests.
- `flutter test`:
  - Passed, 53 tests.

### Validation
- Geometry checked?
  - Not directly changed; preview refresh still happens on confirmed open.
- Serialization checked?
  - Dirty tracking compares semantic project JSON fingerprints.
- UI checked?
  - Widget tests verify cancel preserves current edits and does not call the
    file dialog; confirm loads the target project and resets undo.
- Export checked?
  - Not changed.

### Known issues
- Issue: Dirty tracking is currently in the shell rather than a document
  controller.
  - Severity: Expected for the current architecture slice.
  - Next action: move document state into a controller when more commands are
    wired.
- Issue: There is no separate "Save As" command yet.
  - Severity: Expected.
  - Next action: add when menu/command surface expands.

### Next step
Run full validation, refresh latest Windows bundle, commit, push, then continue
with either dirty/document controller cleanup or first real generator command.

### Notes for future Codex sessions
Dirty state must remain semantic. Do not include generated preview meshes,
OCCT artifacts, or transient viewport state in the persisted fingerprint.

---

## 2026-06-27 — Save Dialog Stability Fix

### Goal
Fix unstable Windows save dialog behavior where the native save window could
close before the user completed the save flow.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Removed the pre-picker `setState` before native open/save dialogs.
  - Kept the `_fileBusy` re-entry guard, but without rebuilding the toolbar
    while the native picker is opening.
  - Status messages now update after the native picker returns a file path, not
    before the picker opens.
- `test/widget_test.dart`:
  - Added a regression test proving save picker is invoked once, repeat clicks
    are ignored by the guard, and no "saving" status is shown before the picker
    returns.

### Tests run
- `dart format lib/ui/shell/workspace_shell.dart test/widget_test.dart`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test/widget_test.dart -r expanded`:
  - Passed, 9 widget tests.
- `flutter test`:
  - Passed, 54 tests.

### Validation
- UI checked?
  - Automated regression covers the risky pre-picker rebuild path.
- Serialization checked?
  - Existing save test still verifies written semantic project JSON.

### Next step
Run full validation, rebuild latest Windows bundle, commit, and push.

---

## 2026-06-28 — M11 First Generator Command

### Goal
Make the left tool rail execute the first real semantic generator command in a
safe, undoable slice.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/35_PARAMETER_MODEL.md`,
`lib/ui/shell/workspace_shell.dart`, command registry files, parameter adapter,
and current widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added a small command action map for first wired rail commands.
  - Wired `enclosure.create` to a compact create-enclosure dialog.
  - Reused the rounded enclosure parameter schema and adapter for dialog values.
  - Routed created enclosure state through the shared semantic undo pipeline.
  - Disabled rail commands that are not implemented yet.
- `test/widget_test.dart`:
  - Added coverage for create, cancel, undo, and disabled future rail commands.
- `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/35_PARAMETER_MODEL.md`:
  - Documented M11 and the first executable generator command.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 12 widget tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 57 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the created enclosure edit.
- Serialization checked?
  - Existing semantic project serialization and file tests still pass.
- UI checked?
  - Widget tests cover create, cancel, undo, and disabled unwired rail commands.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: There is still no central command dispatcher/controller.
  - Severity: Expected for this slice.
  - Next action: introduce it when more rail commands need shared execution
    behavior.
- Issue: The create-enclosure dialog is first-pass and not a guided wizard yet.
  - Severity: Low.
  - Next action: add presets, richer validation, and clearer generator flow in a
    later enclosure-first chunk.

### Next step
Commit and push M11, then continue with the next safe generator or shell
interaction chunk.

### Notes for future Codex sessions
Keep rail commands honest: visible future tools are okay, but they should stay
disabled until they have semantic behavior, tests, and undo considerations.

---

## 2026-06-28 — M12 Place Component Command

### Goal
Make the second left rail generator command create semantic component
placements from existing component templates.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`lib/project/project_model.dart`, component template/placement models, current
workspace shell, and command/widget tests.

### Changes made
- `lib/project/project_model.dart`:
  - Added `replaceComponentPlacement()` for stable-ID append/replace behavior.
- `lib/commands/command_registry.dart`:
  - Made `component.place` available from workspace and enclosure context.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `component.place` from the left rail when templates exist.
  - Added a compact placement dialog for template, X/Y/Z, mounting side, and
    lock state.
  - Commits new placements through semantic undo history.
  - Coerces selection back to workspace if undo removes the selected semantic
    object.
- `test/command_registry_test.dart`, `test/project_model_test.dart`, and
  `test/widget_test.dart`:
  - Added coverage for command scope, placement append/replace, create, cancel,
    undo, and no-template disabled state.
- `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/05_PROJECT_FILE_FORMAT.md`:
  - Documented M12 and the first component placement command.

### Tests run
- `flutter test test\command_registry_test.dart test\project_model_test.dart test\widget_test.dart`:
  - Passed, 29 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 62 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after placement changes; no generated geometry
    source state is added.
- Serialization checked?
  - Component placement append/replace is covered at model level.
- UI checked?
  - Widget tests cover place, cancel, undo, and no-template disabled state.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Component placement is still numeric-dialog driven, not viewport
  picking/snapping.
  - Severity: Expected for this slice.
  - Next action: add viewport picking and snapping after command flows settle.
- Issue: Component-driven cutouts/mounts are not generated from the placement
  yet.
  - Severity: Expected.
  - Next action: implement component-driven feature generation in a later chunk.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M12.

### Notes for future Codex sessions
Component templates remain semantic mechanical templates. Placements should
later drive holes, mounts, clearances, and keepouts without flattening those
requests into unrelated raw geometry.

---

## 2026-06-28 — M13 USB-C Cutout Command

### Goal
Make the first surface-based rail command create a semantic USB-C cutout on the
selected enclosure face.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`lib/project/feature.dart`, `lib/project/project_model.dart`, current
workspace shell, selection resolver, and widget/model tests.

### Changes made
- `lib/project/project_model.dart`:
  - Added `replaceFeature()` for stable-ID append/replace behavior.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `port.add_usb_c` from the left rail only when a semantic surface is
    selected.
  - Added a compact USB-C dialog for width, height, corner radius, and
    clearance profile.
  - Creates a semantic `usb_c_cutout` feature targeted at the active surface.
  - Commits the new feature through semantic undo history and selects it.
- `test/project_model_test.dart` and `test/widget_test.dart`:
  - Added coverage for feature append/replace, disabled-without-surface,
    create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/05_PROJECT_FILE_FORMAT.md`:
  - Documented M13 and the first surface-based generator command.

### Tests run
- `flutter test test\project_model_test.dart test\widget_test.dart`:
  - Passed, 26 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 65 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the feature edit; no generated geometry is
    stored as editable state.
- Serialization checked?
  - Semantic feature append/replace is covered at model level.
- UI checked?
  - Widget tests cover selected surface enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: USB-C placement is targeted by selected surface only, without
  face-local picking/snapping yet.
  - Severity: Expected for this slice.
  - Next action: add face-local placement controls after viewport picking is
    ready.
- Issue: The cutout is semantic only; no OCCT/B-Rep cut is generated yet.
  - Severity: Expected.
  - Next action: feed semantic features into real geometry generation later.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M13.

### Notes for future Codex sessions
Surface commands should continue to use semantic surface IDs from selection.
Do not couple feature creation to raw triangle IDs or OCCT topology names.

---

## 2026-06-28 — M14 Button Group Command

### Goal
Make the next surface-based rail command create an editable semantic button
pattern group instead of flattening repeated buttons into independent holes.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
`lib/project/feature_group.dart`, `lib/project/project_model.dart`,
`ProjectSelectionResolver`, and current widget/model tests.

### Changes made
- `lib/project/project_model.dart`:
  - Added `replaceFeatureGroup()` for stable-ID append/replace behavior.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `button.create_group` from the left rail only when a semantic surface
    is selected.
  - Added a compact button group dialog for layout, count, diameter, spacing,
    and mode.
  - Creates a semantic `FeatureGroup` with editable pattern and item prototype
    data.
  - Commits the new group through semantic undo history and selects it.
- `lib/selection/project_selection_resolver.dart`:
  - Improved feature group inspector details for layout/count/spacing/diameter.
- `test/project_model_test.dart`, `test/project_selection_resolver_test.dart`,
  and `test/widget_test.dart`:
  - Added coverage for feature group append/replace, inspector details,
    disabled-without-surface, create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
  `docs/32_USABLE_SHELL.md`:
  - Documented M14 and the first editable pattern group command.

### Tests run
- `flutter test test\project_model_test.dart test\project_selection_resolver_test.dart test\widget_test.dart`:
  - Passed, 33 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 69 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the group edit; generated geometry is still a
    future output.
- Serialization checked?
  - Feature group append/replace is covered at model level.
- UI checked?
  - Widget tests cover selected surface enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Button group placement is centered metadata only, without face-local
  picking/snapping.
  - Severity: Expected for this slice.
  - Next action: add face-local placement controls after viewport picking is
    ready.
- Issue: Pattern item positions are not generated or previewed yet.
  - Severity: Expected.
  - Next action: add deterministic pattern expansion tests before geometry
    generation consumes groups.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M14.

### Notes for future Codex sessions
Button groups must remain editable feature groups. Do not flatten them into
unrelated `SemanticFeature` holes unless the user explicitly detaches a pattern.

---

## 2026-06-28 — M15 Glass Recess Command

### Goal
Make the next surface-based rail command create a semantic glass/insert recess
on the selected enclosure face.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
current workspace shell, selection resolver, and widget/resolver tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `glass.create_recess` from the left rail only when a semantic surface
    is selected.
  - Added a compact glass recess dialog for window size, recess depth, ledge
    width, corner radius, insert thickness, and clearance profile.
  - Creates a semantic `glass_recess` feature targeted at the active surface.
  - Commits the new recess through semantic undo history and selects it.
- `lib/selection/project_selection_resolver.dart`:
  - Added a human label for `glass_recess` features.
- `test/project_selection_resolver_test.dart` and `test/widget_test.dart`:
  - Added coverage for the display label, disabled-without-surface state,
    create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M15 and the first glass recess command.

### Tests run
- `flutter test test\project_selection_resolver_test.dart test\widget_test.dart`:
  - Passed, 26 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 72 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the feature edit; generated geometry remains a
    future output.
- Serialization checked?
  - Existing semantic feature serialization path is reused.
- UI checked?
  - Widget tests cover selected surface enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Glass recess placement is selected-surface plus dialog dimensions only,
  without face-local picking/snapping.
  - Severity: Expected for this slice.
  - Next action: add face-local placement controls after viewport picking is
    ready.
- Issue: DXF/glass contour export is not generated yet.
  - Severity: Expected.
  - Next action: feed `glass_recess` features into geometry/export pipeline
    later.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M15.

### Notes for future Codex sessions
Glass/insert recesses are semantic features. Keep DXF contours, B-Rep, and mesh
outputs generated from this semantic source rather than storing them in the
editable project file.

---

## 2026-06-28 — M16 Mount Generation Command

### Goal
Make the first component-driven rail command create editable semantic standoff
mounts from the selected component placement's mounting holes.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
current workspace shell, selection resolver, component template model, and
widget/resolver tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `mount.generate` from the left rail only when a selected
    `ComponentPlacement` resolves to a template with mounting holes.
  - Added a compact mount dialog for standoff diameter, hole diameter, height,
    and clearance profile.
  - Creates a semantic `standoff_mounts` `FeatureGroup` with source
    placement/template IDs and template mounting-hole positions.
  - Commits the new group through semantic undo history and selects it.
  - Added human browser titles/icons for glass recess and standoff mount groups.
- `lib/selection/project_selection_resolver.dart`:
  - Added the human label and inspector details for `standoff_mounts`.
- `test/project_selection_resolver_test.dart` and `test/widget_test.dart`:
  - Added coverage for mount group display, disabled-without-component state,
    create, cancel, and undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M16 and the current boundary between semantic mount groups and
    future generated geometry.

### Tests run
- `flutter test test\widget_test.dart test\project_selection_resolver_test.dart`:
  - Passed, 29 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 75 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock preview refreshes after the feature group edit; real stand-off
    geometry is still future OCCT/GeometryService work.
- Serialization checked?
  - The existing `FeatureGroup` JSON path stores the semantic mount group data.
- UI checked?
  - Widget tests cover component selection enablement, create, cancel, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Mount generation currently creates semantic group data only, without
  generated OCCT/B-Rep stand-off bodies.
  - Severity: Expected for this slice.
  - Next action: feed `standoff_mounts` into geometry worker once the first
    real geometry generator is ready.
- Issue: Mount target surface mapping is coarse and follows current placement
  side values.
  - Severity: Expected.
  - Next action: refine target surfaces when face-local placement/snapping and
    inner lid surfaces are modeled.

### Next step
Start the next safe component-driven geometry slice: either derive preview
positions for `standoff_mounts` or wire the first geometry-worker request for
rounded enclosure/standoff generation.

### Notes for future Codex sessions
Mounts generated from component templates must remain semantic feature groups.
Do not flatten a board's mounting-hole mounts into unrelated holes or mesh
objects unless the user explicitly detaches the group.

---

## 2026-06-28 — M17 Feature Group Viewport Markers

### Goal
Make semantic mount groups visible and selectable in the mock viewport before
real OCCT geometry exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`, viewport controller,
workspace shell, and widget/viewport tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `ViewportHitKind.featureGroup`.
  - Added typed `MockViewportFeatureGroupPreview` data for standoff mount
    markers.
  - Added deterministic mapping from component board-local mounting-hole
    positions to mock viewport marker centers.
  - Hit-tests feature group markers before the board so marker clicks select
    the semantic group instead of the component placement underneath.
- `lib/ui/shell/workspace_shell.dart`:
  - Maps feature group hit results to `SelectionModel.featureGroup`.
  - Builds mock standoff marker data from `standoff_mounts` feature groups,
    using stored `holePositions` or falling back to the source template holes.
  - Draws schematic standoff markers and highlights the selected mount group.
  - Added a stable viewport canvas key for widget-level marker click tests.
- `test/viewport_controller_test.dart` and `test/widget_test.dart`:
  - Added coverage for marker coordinate mapping, semantic feature-group hit
    results, and full shell selection from a viewport marker click.
- `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`, `docs/32_USABLE_SHELL.md`, and
  `docs/33_VIEWPORT_MVP.md`:
  - Documented the M17 mock marker slice and its boundary from generated
    B-Rep/mesh geometry.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 29 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 76 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - The markers are mock viewport affordances derived from semantic group data;
    no generated geometry is created yet.
- Serialization checked?
  - Uses existing `FeatureGroup` data; no schema change.
- UI checked?
  - Widget test creates a mount group, deselects it, clicks a marker, and
    verifies the group inspector returns.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Markers are schematic circles projected onto the mock board, not B-Rep
  standoff bosses.
  - Severity: Expected for this slice.
  - Next action: feed the same `standoff_mounts` source data into the geometry
    worker when real standoff generation starts.
- Issue: Marker placement assumes the current sample board-local coordinate
  model.
  - Severity: Expected.
  - Next action: replace the mock transform with actual preview mesh mappings
    once component visual placement is generated by `GeometryService`.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M17.

### Notes for future Codex sessions
Viewport marker clicks must keep returning semantic IDs. Do not introduce mesh,
triangle, or OCCT topology IDs into default selection state.

---

## 2026-06-28 — M18 Button Group Viewport Markers

### Goal
Make newly created semantic button groups visible and selectable in the mock
viewport through the same feature-group marker path as mounts.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, viewport controller, workspace shell, and
widget/viewport tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportFeatureGroupKind.buttonGroup`.
  - Generalized feature-group preview dimensions from board-only to reference
    width/height so button groups can use the lid/surface frame while mounts
    keep using the board frame.
  - Hit-testing continues to return semantic `featureGroup` IDs before
    underlying board/sample features.
- `lib/ui/shell/workspace_shell.dart`:
  - Generates first-pass button marker positions from `layout`, `count`, and
    `spacing`.
  - Supports deterministic `diamond`, `row`, and `grid` marker expansion.
  - Draws created button-group markers in the mock viewport and highlights
    selected button groups.
- `test/viewport_controller_test.dart` and `test/widget_test.dart`:
  - Added coverage for button marker mapping to the lid frame and full shell
    marker-click selection after creating `button_group_1`.
- `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
  `docs/32_USABLE_SHELL.md`, and `docs/33_VIEWPORT_MVP.md`:
  - Documented M18 and the current boundary between preview marker expansion
    and saved/generated geometry.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 30 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 77 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Markers are derived from semantic pattern data only; no generated B-Rep or
    mesh is created yet.
- Serialization checked?
  - No schema change; generated marker positions are not saved.
- UI checked?
  - Widget test creates a button group, deselects it, clicks a marker, and
    verifies the group inspector returns.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Pattern expansion lives in the mock viewport shell for now.
  - Severity: Expected for this slice.
  - Next action: promote pattern expansion into reusable layout logic before
    geometry generation consumes it.
- Issue: Marker expansion is first-pass for diamond, row, and grid only.
  - Severity: Expected.
  - Next action: add square/circle/arc/path expansion when those pattern types
    are introduced.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M18.

### Notes for future Codex sessions
Button groups must stay editable semantic `FeatureGroup` objects. Viewport
markers are transient affordances and must not become saved per-button project
items unless the user explicitly detaches the pattern.

---

## 2026-06-28 — M19 Surface Feature Viewport Markers

### Goal
Make created surface features visible and selectable in the mock viewport
before real generated geometry exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, viewport controller, workspace shell, and
widget/viewport tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added typed `MockViewportFeaturePreview` data for semantic feature markers.
  - Added `MockViewportFeatureKind.usbC` and `glassRecess`.
  - Added deterministic mock rectangles for USB-C and glass recess markers.
  - Hit-tests feature markers before generic surfaces and returns semantic
    feature IDs.
- `lib/ui/shell/workspace_shell.dart`:
  - Builds mock feature previews from `usb_c_cutout` and `glass_recess`
    `SemanticFeature` parameters.
  - Draws USB-C and glass/recess markers in the mock viewport.
  - Highlights selected feature markers.
- `test/viewport_controller_test.dart` and `test/widget_test.dart`:
  - Added coverage for feature marker layout, semantic hit results, and full
    shell marker-click selection after creating USB-C and glass recess features.
- `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
  `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`, `docs/32_USABLE_SHELL.md`,
  and `docs/33_VIEWPORT_MVP.md`:
  - Documented M19 and the boundary between schematic markers and generated
    geometry.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 31 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 78 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Markers are derived from semantic feature parameters only; no generated
    B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; generated marker rectangles are not saved.
- UI checked?
  - Widget tests create USB-C/glass features, deselect them, click their
    viewport markers, and verify the feature inspectors return.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Feature markers are schematic rectangles, not true generated cuts or
  recesses.
  - Severity: Expected for this slice.
  - Next action: feed `usb_c_cutout` and `glass_recess` into geometry service
    once real preview geometry starts.
- Issue: Multiple features on the same surface are offset schematically.
  - Severity: Expected.
  - Next action: replace slot offsets with face-local placement/snapping data.

### Next step
Run full validation, refresh latest Windows bundle, commit, and push M19.

### Notes for future Codex sessions
Surface feature marker clicks must keep returning semantic feature IDs. Do not
introduce mesh, triangle, or OCCT topology IDs into default selection state.

---

## 2026-06-28 - M20 Feature Parameter Inspector Editing

### Goal
Let selected semantic USB-C and glass recess features expose editable numeric
parameter banks in the contextual inspector, using semantic project updates and
existing undo history.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, workspace shell, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added feature parameter update handling for selected `SemanticFeature`
    objects.
  - Added first-pass inspector parameter schemas for `usb_c_cutout` and
    `glass_recess`.
  - Wired feature parameter submissions into semantic undo snapshots.
  - Kept mock viewport refresh derived from semantic project data.
- `test/widget_test.dart`:
  - Added USB-C feature parameter edit + undo coverage.
  - Added glass recess feature parameter edit + undo coverage.
- `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
  `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M20 and the semantic boundary for feature parameter edits.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 25 targeted widget tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 80 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Feature edits only update semantic parameters; mock markers are rebuilt
    from the project. No generated B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; existing `SemanticFeature.parameters` storage is reused.
- UI checked?
  - Widget tests select USB-C/glass features, submit inspector values, and undo
    the changes.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Feature inspector editing is numeric-only for now.
  - Severity: Expected for this slice.
  - Next action: add compact choice controls for clearance/profile parameters
    when those controls are promoted into shared inspector widgets.
- Issue: Feature placement is still centered/schematic.
  - Severity: Expected.
  - Next action: add face-local placement/snapping before real geometry consumes
    these features.

### Next step
Commit and push M20, then continue with the next safe semantic editing chunk.

### Notes for future Codex sessions
Feature inspector edits must keep replacing semantic `SemanticFeature` data.
Do not make generated viewport rectangles, mesh faces, or OCCT topology IDs the
editable source of truth.

---

## 2026-06-28 - M21 Feature Group Parameter Inspector Editing

### Goal
Let selected semantic button groups and standoff mount groups expose editable
parameter banks in the contextual inspector while keeping repeated items as one
semantic `FeatureGroup`.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, workspace shell,
feature-group model, viewport controller, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added feature-group parameter update handling for selected
    `FeatureGroup` objects.
  - Added first-pass inspector schemas for `button_group` and
    `standoff_mounts`.
  - Routed button group `layout`, `count`, and `spacing` edits to `pattern`.
  - Routed button `diameter`/`mode` and mount item edits to `itemPrototype`.
  - Kept mount hole diameter clamped below standoff diameter.
  - Made choice fields tolerate unknown imported values without crashing.
- `test/widget_test.dart`:
  - Added button group inspector edit + undo coverage.
  - Added standoff mount inspector edit + undo coverage, including hole
    diameter clamping.
- `ROADMAP.md`, `TASKS.md`, `docs/06_FEATURE_SYSTEM.md`,
  `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
  `docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`:
  - Documented M21 and the semantic boundary for grouped repeated items.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 27 targeted widget tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 82 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Group edits only update semantic pattern/item data; mock markers are
    rebuilt from the project. No generated B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; existing `FeatureGroup.pattern` and `itemPrototype`
    storage are reused.
- UI checked?
  - Widget tests select button/mount groups from viewport markers, submit
    inspector values, and undo the changes.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Pattern expansion still lives in the mock viewport shell.
  - Severity: Expected for this slice.
  - Next action: promote pattern expansion into reusable layout logic before
    geometry generation consumes it.
- Issue: Group placement is still centered/schematic.
  - Severity: Expected.
  - Next action: add face-local placement/snapping before real geometry consumes
    these groups.

### Next step
Commit and push M21, then continue with reusable pattern/layout extraction or
the next safe semantic editing chunk.

### Notes for future Codex sessions
Feature group edits must keep repeated items grouped. Do not flatten button
groups or mount patterns into independent semantic features unless the user
explicitly chooses a detach workflow.
