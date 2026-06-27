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
