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
