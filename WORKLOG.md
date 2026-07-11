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

## 2026-07-01 - M111 USB-C snap-seeded placement

### Goal
Make manual front-wall USB-C cutouts start from a clicked face-local workplane
point, while keeping the editable project semantic and not coupling Flutter to
OCCT topology or generated mesh IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/widget_test.dart`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/06_FEATURE_SYSTEM.md`, `docs/26_TESTING_AND_QUALITY.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, and
`docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Reused active front-wall snap targets when launching the USB-C generator.
  - Manual snap-seeded `usb_c_cutout` features now store
    `placement.projectionMode=surface_snap_target`,
    `placement.surfacePosition`, and `surfaceAxes=["x","z"]`.
  - Added an active snap inspector `USB-C` action for supported front-wall snap
    targets.
  - Rounded snap coordinates before serialization so canvas conversion noise
    does not leak into project JSON.
- `lib/viewport/viewport_controller.dart`:
  - Made mock feature preview positions optional.
  - Kept the old USB-C slot marker layout for features without saved placement.
  - Uses saved `surfacePosition` to place selectable USB-C markers when present.
- `test/widget_test.dart`:
  - Added snap-seeded USB-C coverage that creates the cutout, saves JSON, and
    selects the marker at the saved face-local point.
  - Added a front-wall workplane tap helper.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Added M111, marked the USB-C placement polish task complete for supported
    front-wall placement, and documented JSON/command/viewport behavior.

### Tests run
- `flutter test test\widget_test.dart --plain-name "snap-seeded USB-C stores front wall surface position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "snap-seeded circular cutout starts from clicked surface point"`:
  - Passed.
- `flutter test test\viewport_controller_test.dart`:
  - Passed.
- `flutter pub get`:
  - Passed; dependency resolver reported newer incompatible package versions.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after applying `dart format` to the touched Dart files.
- `flutter analyze`:
  - Passed with no issues.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter test --reporter compact`:
  - Passed, 250 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter test --reporter compact`:
  - Passed, 249 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.
- `flutter test --reporter compact`:
  - Passed, 222 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and rebuilt `releases/latest/windows/shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed; Git still reports the existing CRLF normalization warning for
    `ROADMAP.md`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.

### Validation
- Geometry checked?
  - Yes. The native-backed latest build completed; the worker already consumes
    `placement.surfacePosition` for supported front-wall USB-C cutouts.
- Serialization checked?
  - Yes. The new widget test saves the project and asserts
    `surface_snap_target`, `surfacePosition`, and `surfaceAxes`.
- UI checked?
  - Yes. Widget coverage opens the active snap USB-C action and selects the new
    mock marker at the saved point.
- Export checked?
  - Indirectly through full test/build coverage; no export path changed.

### Known issues
- Issue: Native USB-C generation is still front-wall only.
  - Severity: Medium.
  - Next action: Extend the port generator/backend to additional semantic
    surfaces only after the geometry rules for those surfaces are designed.
- Issue: The active snap inspector can need scrolling in small test-sized
  viewports.
  - Severity: Low.
  - Next action: Consider denser snap action layout if this becomes annoying in
    normal windows.

### Next step
Continue with guided component placement workflow with viewport picking, or add
more face-local placement polish for button/glass generators.

### Notes for future Codex sessions
Manual front-wall USB-C placement now has two paths: old features without
`placement.surfacePosition` still use the fallback slot marker, while new
snap-seeded features store exact semantic surface coordinates and render there.

---

## 2026-07-01 - M110 Native switch-sourced button cutouts

### Goal
Verify the full bridge from component switch centers to native top-lid button
geometry, without flattening the editable `button_group` into independent holes
or exposing generated B-Rep/mesh/topology IDs to Flutter.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`test/native_occt_geometry_regression_test.dart`,
`test/support/native_occt_geometry_fixture.dart`,
`lib/geometry/geometry_protocol.dart`, `lib/geometry/geometry_operation_plan.dart`,
`docs/07_COMPONENT_TEMPLATE_SYSTEM.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/16_BUTTON_AND_PLUNGER_SYSTEM.md`, `docs/17_SWITCH_MAPPING_SYSTEM.md`,
`docs/32_USABLE_SHELL.md`, and `docs/33_COMPONENT_FEATURE_PROJECTION.md`.

### Changes made
- `test/support/native_occt_geometry_fixture.dart`:
  - Added `nativeOcctSwitchSourcedButtonProject()`, a deterministic project
    fixture with one component-sourced `button_group`.
  - The group stores four projected switch centers in
    `FeatureGroup.pattern.switchPositions`.
- `test/native_occt_geometry_regression_test.dart`:
  - Added a native OCCT regression test proving the worker consumes the
    switch-sourced group as generated top-lid button cutouts.
  - Verifies four generated lid holes, rings, caps, stems, guide sleeves, and
    travel-stop collars.
  - Verifies the preview maps generated geometry back to the semantic group id
    and does not expose topology or triangle IDs as editable state.
- `ROADMAP.md` and `TASKS.md`:
  - Added M110 and marked first-pass switch-center/top-lid cutout generation
    complete.
- Docs:
  - Updated component projection, switch mapping, component template, enclosure
    generation, button/plunger, and usable shell docs so component-sourced
    button groups are described as native-backed for supported top-lid targets.

### Tests run
- `flutter test test\native_occt_geometry_regression_test.dart --plain-name "native OCCT preview cuts component switch-sourced top lid buttons" --reporter compact`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 221 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and copied the latest bundle to `releases/latest/windows`.
- `git diff --check`:
  - Passed; PowerShell reported only the existing CRLF normalization warning for
    `ROADMAP.md`.

### Validation
- Geometry checked?
  - Native regression checks generated-lid button group metrics and semantic
    surface mapping for `component_switch_buttons`.
- Serialization checked?
  - The fixture stores switch centers as semantic `FeatureGroup` pattern data;
    no generated geometry is serialized.
- UI checked?
  - Existing widget coverage for component button command still runs in the full
    suite.
- Export checked?
  - Latest Windows build completed with the native OCCT worker bundled.

### Known issues
- Issue: Component-sourced button generation is still first-pass top-lid/front
  wall circular button geometry.
  - Severity: Medium.
  - Next action: Add richer placement/orientation controls before supporting
    more button shapes or side-wall switch workflows.
- Issue: The visual interaction for button placement is still dialog/selection
  based rather than direct drag handles on the native preview.
  - Severity: Medium.
  - Next action: Improve face-local picking/snapping and semantic handles.

### Next step
Continue with face-local cutout placement polish, or start a small access
cutout preset slice now that generic slots and switch-sourced buttons are
stable.

### Notes for future Codex sessions
`FeatureGroup.pattern.switchPositions` is now part of a tested native-backed
path for supported top-lid buttons. Keep it semantic and grouped; do not expand
it into independent editable hole features.

---

## 2026-07-01 - M109 Slot inspector semantics

### Goal
Keep slot presets stable after inspector edits: a slot should remain a
pill-shaped semantic `rectangular_cutout`, with its corner radius derived from
current length/width rather than edited independently.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/05_PROJECT_FILE_FORMAT.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, and `docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added feature-aware parameter schema selection for semantic feature
    inspector editors.
  - Added a dedicated `Слот` schema for `rectangular_cutout` features with
    `parameters.preset=slot`.
  - Removed direct slot `cornerRadius` editing from the inspector parameter
    bank.
  - Recomputes slot `cornerRadius` as `min(width, height) / 2` after inspector
    edits.
  - Clamps generic rectangular cutout `cornerRadius` after inspector edits so
    size changes cannot leave an invalid rounded rectangle.
  - Reused one `_roundedRectangleMaxCornerRadius` helper for dialog creation and
    inspector updates.
- `test/widget_test.dart`:
  - Added widget coverage for slot inspector edit/save/undo behavior.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/06_FEATURE_SYSTEM.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
  `docs/32_USABLE_SHELL.md`:
  - Recorded M109 and documented live slot radius semantics.

### Tests run
- `flutter test test\widget_test.dart --plain-name "slot inspector keeps derived corner radius after edits" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "slot cutout preset creates pill-shaped semantic rectangle" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 220 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and copied the latest bundle to `releases/latest/windows`.
- `git diff --check`:
  - Passed; PowerShell reported only the existing CRLF normalization warning for
    `ROADMAP.md`.

### Validation
- Geometry checked?
  - No new native geometry operation was added; slot output still flows through
    the native `rectangular_cutout` path.
- Serialization checked?
  - Widget coverage saves the edited slot and verifies `preset=slot`,
    width/height, and derived `cornerRadius`.
- UI checked?
  - Widget coverage verifies the slot inspector exists, hides the radius field,
    supports edits, and restores shape semantics through undo.
- Export checked?
  - Latest Windows build completed with the native OCCT worker bundled.

### Known issues
- Issue: Slot placement still uses numeric face-local X/Y editing.
  - Severity: Medium.
  - Next action: Improve direct face picking/snapping for generic cutouts as one
    shared placement slice.
- Issue: Slot is still a pill-style rounded rectangle, not a separate
  edge-bound semicircle/finger notch generator.
  - Severity: Low.
  - Next action: Add richer access cutout presets as separate semantic presets
    when placement semantics are ready.

### Next step
Continue with face-local cutout placement polish or richer access cutout
presets on top of the now-stable slot semantics.

### Notes for future Codex sessions
Do not expose slot `cornerRadius` as an ordinary editable field unless the user
explicitly converts the slot back to a generic rounded rectangle. The live
`preset=slot` invariant is: `cornerRadius == min(width, height) / 2`.

---

## 2026-07-01 - M108 Slot cutout preset

### Goal
Expose a first-pass `Слот` option in the surface `Отверстия` workflow while
keeping the editable project semantic and reusing the native-backed
`rectangular_cutout` path.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`,
`lib/selection/project_selection_resolver.dart`,
`test/widget_test.dart`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/06_FEATURE_SYSTEM.md`, and `docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Слот` as a third cutout dialog shape.
  - Defaults the slot preset to a 24 x 8 mm pill-like opening.
  - Builds slots as semantic `rectangular_cutout` features with
    `parameters.preset=slot`.
  - Derives slot corner radius from `min(width, height) / 2`.
  - Clamps normal rectangular corner radius at creation time so the dialog does
    not create an impossible rounded rectangle.
  - Labels slot features as `Слот` in the browser and undo command label.
- `lib/selection/project_selection_resolver.dart`:
  - Shows selected slot features as `Слот` in the selection details/status.
- `test/widget_test.dart`:
  - Added create/select/save/undo coverage for the slot preset and verifies the
    saved semantic JSON values.
- `ROADMAP.md`, `TASKS.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
  `docs/06_FEATURE_SYSTEM.md`, and `docs/32_USABLE_SHELL.md`:
  - Recorded M108 and documented slot-as-rectangular-cutout semantics.

### Tests run
- `flutter test test\widget_test.dart --plain-name "slot cutout preset creates pill-shaped semantic rectangle" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 219 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and copied the latest bundle to `releases/latest/windows`.
- `git diff --check`:
  - Passed; PowerShell reported only the existing CRLF normalization warning for
    `ROADMAP.md`.

### Validation
- Geometry checked?
  - Reused existing native `rectangular_cutout` generation path; latest Windows
    bundle includes the native OCCT worker.
- Serialization checked?
  - Widget coverage saves the project and verifies `preset=slot`, width, height,
    position, and derived corner radius.
- UI checked?
  - Widget coverage verifies the dialog shape option, derived radius control,
    browser/selection label, marker selection, and undo.
- Export checked?
  - Latest Windows build completed; no new export-specific behavior was added.

### Known issues
- Issue: Slot placement still uses the current first-pass X/Y numeric workflow.
  - Severity: Medium.
  - Next action: Improve face-local picking/snapping for rectangular and slot
    cutouts together.
- Issue: The command id remains `slot.generate` even though the rail label is
  now the broader `Отверстия` command.
  - Severity: Low.
  - Next action: Consider an internal command id rename only if a migration-safe
    command namespace cleanup is already happening.

### Next step
Continue with richer access cutout variants or placement polish for generic
cutouts.

### Notes for future Codex sessions
`Слот` is intentionally not a new feature type. Keep it as a semantic preset on
`rectangular_cutout` unless there is a real data-model reason to split it.

---

## 2026-07-01 - M107 Native rectangular cutout geometry

### Goal
Make semantic `rectangular_cutout` features generate native OCCT
rounded-rectangular cut geometry on supported front-wall and generated top-lid
surfaces without exposing Boolean tools, B-Rep, mesh, or OCCT topology IDs as
editable project state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`,
`test/native_occt_geometry_regression_test.dart`,
`test/support/native_occt_geometry_fixture.dart`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/06_FEATURE_SYSTEM.md`, `docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/31_COMMANDS_AND_UNDO.md`, and `docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `RectangularCutoutRequest` parsing for `rectangular_cutout` feature
    intents.
  - Validates target surface, width, height, depth, corner radius, and
    face-local placement for front-wall and top-lid targets.
  - Builds rounded rectangular OCCT box cut tools and subtracts them from the
    body shell or generated top lid plate.
  - Maps generated cut faces back to the original semantic feature ids.
  - Reports body and generated-lid rectangular cutout metrics.
- `test/support/native_occt_geometry_fixture.dart` and
  `test/native_occt_geometry_regression_test.dart`:
  - Added a native regression project with one front-wall and one top-lid
    rectangular cutout.
  - Checks known vertex/triangle counts, bounds, dimensions, surface area,
    volume, surface mappings, and rectangular cut metrics.
- Docs/tasks:
  - Added M107 to `ROADMAP.md`.
  - Marked native rectangular cutout geometry complete in `TASKS.md`.
  - Updated geometry/project/feature/command docs and added an OCCT research
    note.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe`.
- Manual native worker JSON smoke with front/top `rectangular_cutout` intents:
  - Passed; response status `ok`, 4510 vertices, 4940 triangles, 10 surface
    mappings.
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`:
  - Passed; 2 tests.
- `flutter pub get`:
  - Passed; dependency notices only.
- `dart format test\native_occt_geometry_regression_test.dart test\support\native_occt_geometry_fixture.dart`:
  - Applied formatting to the new test.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 73 files checked, 0 changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; 218 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Yes. Native OCCT regression covers deterministic rectangular cut metrics,
    bounds, dimensions, area, volume, and semantic preview mappings.
- Serialization checked?
  - Existing semantic feature request serialization remains unchanged; the
    native worker now consumes the existing `rectangular_cutout` intent.
- UI checked?
  - Existing rectangular cutout widget coverage still runs in the full suite.
    Manual poke is now meaningful in the latest native build.
- Export checked?
  - Latest native Windows bundle was rebuilt. STEP/STL export paths use the same
    generated preview assembly and remain covered by existing tests.

### Known issues
- Issue: Rectangular cutouts still use numeric X/Y edits and first-pass preview
  face mapping rather than direct native face handles.
  - Severity: Low.
  - Next action: Add richer surface-projected handles/picking after placement UX
    settles.
- Issue: Only the generic rounded-rectangle shape is generated.
  - Severity: Low.
  - Next action: Add semantic slot/access variants such as oval, finger notch,
    countersink, and panel opening presets later.

### Next step
Commit and push M107, then continue with a placement/handle or richer access
cutout slice.

### Notes for future Codex sessions
Keep rectangular cutouts semantic. The native worker should remain a generator
that consumes feature intents and returns disposable preview/export data; do
not expose OCCT topology or Boolean operations in the default UX.

---

## 2026-07-01 - M106 Semantic rounded rectangular cutout

### Goal
Extend the `Отверстия` semantic generator from circular holes to the first
generic rounded-rectangular cutout/slot without making generated geometry
editable or coupling Flutter to OCCT internals.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`lib/geometry/geometry_operation_plan.dart`,
`lib/validation/project_semantic_validator.dart`,
`lib/selection/project_selection_resolver.dart`, `test/widget_test.dart`,
`test/viewport_controller_test.dart`, `test/geometry_protocol_test.dart`,
`test/project_semantic_validator_test.dart`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/05_PROJECT_FILE_FORMAT.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, and `docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced the circle-only cutout dialog with one `Отверстие` dialog that
    offers `Круглое` and `Прямоугольное` shape options.
  - Added `rectangular_cutout` defaults with width, height, depth, corner
    radius, clearance profile, and face-local X/Y.
  - Added inspector parameter schema, title, icon, mock marker, and semantic
    commit path for rectangular cutouts.
- `lib/viewport/viewport_controller.dart`:
  - Added a `rectangularCutout` marker kind and layout/hit-test support.
- `lib/geometry/geometry_operation_plan.dart`:
  - Maps `rectangular_cutout` to `cutout.rectangular`.
- `lib/validation/project_semantic_validator.dart`:
  - Validates supported surfaces, positive dimensions, radius bounds, size, and
    face-local placement for rectangular cutouts.
- `lib/selection/project_selection_resolver.dart`:
  - Added human labels for circular and rectangular cutout selections.
- Tests:
  - Added planner, validator, viewport, and widget coverage.
  - Re-ran the existing circular cutout widget test to confirm the default path
    still works.
- Docs/tasks:
  - Added M106 to `ROADMAP.md`, marked the semantic rectangular cutout task
    complete, and added native rectangular subtraction as a follow-up task.

### Tests run
- `flutter test test\geometry_protocol_test.dart --plain-name "operation planner creates deterministic backend operations" --reporter compact`:
  - Passed.
- `flutter test test\project_semantic_validator_test.dart --plain-name "oversized rectangular cutout reports semantic errors" --reporter compact`:
  - Passed.
- `flutter test test\viewport_controller_test.dart --plain-name "mock hit tester returns semantic feature marker ids" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "rectangular cutout rail command commits through undo history" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "circular cutout rail command commits through undo history" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; dependency notices only.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 73 files checked, 0 changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; 217 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Semantic operation planning and mock viewport markers are covered. Native
    OCCT rectangular subtraction is explicitly left for the next geometry slice.
- Serialization checked?
  - No schema migration was needed; `rectangular_cutout` is a normal
    `SemanticFeature` with parameter maps.
- UI checked?
  - Widget coverage verifies create/select/inspect/undo for rectangular cutouts
    and confirms the existing circular workflow remains intact.
- Export checked?
  - Export code was not changed; latest native Windows bundle was rebuilt.

### Known issues
- Issue: `rectangular_cutout` is not yet consumed by the native OCCT worker.
  - Severity: Medium.
  - Next action: Add native rounded-rectangular B-Rep subtraction for supported
    front-wall/top-lid targets.
- Issue: The `Отверстия` dialog uses a simple shape dropdown, not a richer
  hole/slot preset gallery.
  - Severity: Low.
  - Next action: Revisit once more cutout variants exist.

### Next step
Commit and push M106, then implement native rounded-rectangular cutout geometry.

### Notes for future Codex sessions
Keep `rectangular_cutout` semantic. Native code should consume width, height,
depth, corner radius, and face-local X/Y as disposable generator input and must
not expose Boolean/sketch operations or OCCT topology IDs in default UI.

---

## 2026-07-01 - M105 Snap-seeded circular cutout placement

### Goal
Let selected surface workplane clicks seed generic circular cutout X/Y so the
first hole workflow starts from a picked face-local point instead of manual
coordinate guessing.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/widget_test.dart`, `test/viewport_controller_test.dart`,
`docs/06_FEATURE_SYSTEM.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added workplane canvas-to-local conversion.
  - Maps arbitrary clicks inside selected top-lid/front-wall workplanes to
    transient `snapPoint` hits with face-local coordinates.
  - Leaves component-placement workplanes on explicit snap hints only.
- `lib/ui/shell/workspace_shell.dart`:
  - Seeds the circular cutout dialog from an active surface snap target.
  - Adds an inspector `Отверстие` action beside the active snap target.
  - Keeps confirmed holes as normal semantic `circular_cutout` parameters and
    clears transient snap state after commit.
- Tests:
  - Added viewport coverage for arbitrary surface workplane hit coordinates.
  - Added widget coverage for snap-seeded circular cutout creation and marker
    selection at the seeded position.
- Docs/tasks:
  - Added M105 to `ROADMAP.md`.
  - Updated `TASKS.md`, shell/command/viewport/feature docs, and geometry notes.

### Tests run
- `flutter test test\viewport_controller_test.dart --plain-name "mock hit tester maps surface workplane clicks to local positions" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "snap-seeded circular cutout starts from clicked surface point" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; dependency notices only.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 73 files checked, 0 changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; 215 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for markdown files.

### Validation
- Geometry checked?
  - This slice does not change OCCT generation. It feeds semantic X/Y into the
    already native-backed `circular_cutout` path.
- Serialization checked?
  - No schema change; the confirmed result remains a normal semantic feature
    with editable parameters.
- UI checked?
  - Widget coverage verifies click target, seeded dialog fields, semantic
    commit, snap clearing, and marker hit-test selection.
- Export checked?
  - Export code unchanged; latest native Windows bundle was rebuilt so existing
    native export paths use the same semantic cutout.

### Known issues
- Issue: This is still workplane-assisted picking, not final projected native
  face picking from OCCT surface topology.
  - Severity: Medium.
  - Next action: Add richer native face handles/picking once preview surface
    projection is ready.
- Issue: Generic rectangular rounded cutouts are still not implemented.
  - Severity: Medium.
  - Next action: Add a semantic rectangular cutout command and then native
    subtraction slice.

### Next step
Commit and push M105, then continue with either generic rounded-rectangle
cutouts or richer face/feature picking polish.

### Notes for future Codex sessions
Do not serialize active snap targets. They are only launch context for semantic
commands; the saved project source of truth remains `SemanticFeature`
parameters and normal semantic IDs.

---

## 2026-07-01 - M104 Native circular cutout geometry

### Goal
Make semantic `circular_cutout` features generate real native OCCT subtraction
geometry for supported front-wall and generated top-lid targets while keeping
the editable project semantic and keeping Flutter behind `GeometryService`.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/05_PROJECT_FILE_FORMAT.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/README.md`, `occt_worker/native/src/occt_main.cpp`,
`lib/geometry/geometry_protocol.dart`,
`lib/validation/project_semantic_validator.dart`,
`test/support/native_occt_geometry_fixture.dart`,
`test/native_occt_geometry_regression_test.dart`,
`test/native_occt_step_export_test.dart`,
`test/native_occt_stl_export_test.dart`,
`test/occt_native_target_scaffold_test.dart`,
`test/project_semantic_validator_test.dart`, and
`tool/native_occt_worker_metrics_smoke.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `CircularCutoutRequest` parsing from `circular_cutout` feature
    intents.
  - Reads `diameter`, `depth`, face-local `positionX`/`positionY`, and optional
    `placement.surfacePosition`.
  - Validates supported front-wall/top-lid targets and surface fit.
  - Builds cylinder cut tools with `BRepPrimAPI_MakeCylinder`.
  - Cuts front-wall holes from the body shell and top-lid holes from the
    generated lid plate with `BRepAlgoAPI_Cut`.
  - Maps generated cut faces back to semantic feature ids.
  - Emits `nativeCircularCutoutCount` and
    `nativeGeneratedLidCircularCutoutCount`.
- `lib/validation/project_semantic_validator.dart`:
  - Added semantic validation for circular cutout target, dimensions, and
    face-local placement.
- Tests/tools:
  - Added front/top circular cutouts to the native OCCT regression fixture and
    metrics smoke project.
  - Updated deterministic mesh counts, area, volume, mapping counts, and
    native metrics.
  - Added validator coverage for oversized circular cutouts.
- Docs/tasks:
  - Marked native circular geometry complete in `TASKS.md`.
  - Added M104 to `ROADMAP.md`.
  - Updated OCCT, feature, shell, project-file, command/undo, README, and
    research docs.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe`.
- `flutter test test\project_semantic_validator_test.dart --plain-name "oversized circular cutout reports semantic errors" --reporter compact`:
  - Passed.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; preview mesh now has 13550 vertices, 13776 triangles, 16 surface
    mappings, `nativeCircularCutoutCount=1`, and
    `nativeGeneratedLidCircularCutoutCount=1`.
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`:
  - Passed.
- `flutter test test\native_occt_step_export_test.dart --reporter compact`:
  - Passed.
- `flutter test test\native_occt_stl_export_test.dart --reporter compact`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed; 72 files checked, 0 changed.
- `flutter test test\project_semantic_validator_test.dart --reporter compact`:
  - Passed; 16 tests.
- `flutter test test\geometry_protocol_test.dart --plain-name "operation planner creates deterministic backend operations" --reporter compact`:
  - Passed.
- `flutter test test\occt_native_target_scaffold_test.dart test\native_occt_geometry_regression_test.dart test\native_occt_step_export_test.dart test\native_occt_stl_export_test.dart --reporter compact`:
  - Passed; 8 tests.
- `flutter pub get`:
  - Passed; dependency notices only.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; 213 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for markdown/README files.

### Validation
- Geometry checked?
  - Native OCCT body and generated-lid circular cuts are covered by smoke,
    regression, STEP export, STL export, and the full Flutter test suite.
- Serialization checked?
  - `circular_cutout` remains normal semantic project data; no generated
    cylinders, meshes, B-Rep, triangle ids, or topology ids are stored.
- UI checked?
  - Existing M103 widget coverage still passes; this slice changes native output
    behind the same semantic command.
- Export checked?
  - STEP and STL native export tests passed with the updated B-Rep.

### Known issues
- Issue: Circular cutout placement is still typed X/Y, not seeded directly from
  a face click.
  - Severity: Medium.
  - Next action: Use workplane hit/snap data to seed cutout placement.
- Issue: Generic hole variants such as countersink, counterbore, threaded
  insert, and slot are not modeled yet.
  - Severity: Medium.
  - Next action: Add semantic variants without exposing raw Boolean/sketch
    operations in the default UI.

### Next step
Commit and push M104, then continue with direct face click-to-place or richer
hole variants.

### Notes for future Codex sessions
The native worker now interprets manual `positionX`/`positionY` as face-local
center coordinates. For front-wall manual features, Y is converted to Z around
the enclosure center; `placement.surfacePosition` remains an absolute surface
coordinate override for projected/future click-seeded features.

---

## 2026-07-01 - M103 Semantic circular cutout command

### Goal
Add the first generic circular cutout as editable semantic project state,
available from the surface tool rail and visible in inspector/mock viewport,
without adding editable mesh, STL, generated B-Rep, or native topology IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/app/app_strings.dart`,
`lib/commands/command_registry.dart`,
`lib/geometry/geometry_operation_plan.dart`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/command_registry_test.dart`, `test/geometry_protocol_test.dart`,
`test/viewport_controller_test.dart`, `test/widget_test.dart`,
`docs/05_PROJECT_FILE_FORMAT.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, and `docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/app/app_strings.dart`:
  - Updated the stale rail label from slots to `Отверстия`.
- `lib/commands/command_registry.dart`:
  - Reframed `slot.generate` as the first `Отверстия` surface command.
  - Kept it contextual: available only from an active semantic surface.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `slot.generate` to a new circular cutout dialog.
  - Added semantic `circular_cutout` defaults with diameter, depth, X/Y, and
    clearance profile.
  - Added circular cutout inspector schema and feature title/icon labels.
  - Added mock viewport marker generation for circular cutouts.
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportFeatureKind.circularCutout`.
  - Added circular feature layout, hit-test participation, and face-local
    position support.
- `lib/geometry/geometry_operation_plan.dart`:
  - Mapped `circular_cutout` to `cutout.circular`.
- Tests:
  - Added command availability coverage.
  - Extended operation planner and viewport marker/hit-test coverage.
  - Added widget coverage for create/cancel/undo and semantic marker selection.
- Docs/tasks:
  - Marked generic circular cutout complete at the semantic UI level.
  - Added M103 to `ROADMAP.md`.
  - Documented that native OCCT subtraction remains a follow-up geometry slice.

### Tests run
- `dart format lib\commands\command_registry.dart lib\geometry\geometry_operation_plan.dart lib\viewport\viewport_controller.dart lib\ui\shell\workspace_shell.dart test\command_registry_test.dart test\geometry_protocol_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed; formatted `lib\viewport\viewport_controller.dart`.
- `flutter test test\command_registry_test.dart --plain-name "slot command creates holes only from active surface context" --reporter compact`:
  - Passed.
- `flutter test test\geometry_protocol_test.dart --plain-name "operation planner creates deterministic backend operations" --reporter compact`:
  - Passed.
- `flutter test test\viewport_controller_test.dart --plain-name "mock hit tester returns semantic feature marker ids" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "circular cutout rail command commits through undo history" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "circular cutout rail command can be cancelled" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "unimplemented rail commands are visible but disabled" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; dependency notices only.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 73 files checked, 0 changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; 212 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for `ROADMAP.md` and
    `docs/34_FIRST_GEOMETRY_SLICE.md`.

### Validation
- Geometry checked?
  - Operation planner emits `cutout.circular`; full tests passed. Native OCCT
    subtraction is intentionally left for the next geometry slice.
- Serialization checked?
  - The feature is stored as normal `SemanticFeature` data; no schema migration
    was required, and full project-file/widget coverage stayed green.
- UI checked?
  - Targeted widget tests cover create, cancel, undo, inspector selection, and
    marker hit-test flow.
- Export checked?
  - Export flows were not changed in this slice; full suite and latest Windows
    bundle build still passed.

### Known issues
- Issue: `circular_cutout` is not yet consumed by the native OCCT worker.
  - Severity: Medium.
  - Next action: Add native circular cutout subtraction against supported
    semantic surfaces.
- Issue: The first position fields are manual X/Y values instead of direct
  click-to-place on a face.
  - Severity: Medium.
  - Next action: Reuse workplane snap/hit data to seed face-local placement.

### Next step
Commit and push M103, then start M104 native circular cutout geometry.

### Notes for future Codex sessions
Keep generic holes semantic. Do not store generated cylinders, meshes, or OCCT
topology in `ProjectModel`; native geometry should consume `cutout.circular`
through `GeometryFeatureIntent`.

---

## 2026-07-01 - M102 Toolbar STEP/STL export format choice

### Goal
Expose STL from the existing toolbar export command while keeping STEP/STL as
generated output artifacts outside project JSON, undo/redo, and editable
semantic state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/project/project_file_dialog_service.dart`,
`lib/ui/shell/workspace_shell.dart`, `test/project_file_service_test.dart`,
`test/widget_test.dart`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/25_EXPORT_PIPELINE.md`, `docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/project/project_file_dialog_service.dart`:
  - Added `ProjectExportFormat` for STEP/STL file dialog filters, confirm
    labels, artifact types, and default extensions.
  - Replaced the STEP-only export picker with `pickExportFile`.
  - Added shared export extension handling plus the STL helper.
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced direct toolbar STEP export with a compact STEP/STL chooser.
  - Constrained the chooser width so desktop export stays a compact command
    surface instead of a full-width band.
  - Routed STEP to `GeometryRequest.exportStep` and STL to
    `GeometryRequest.exportStl`.
  - Kept export paths outside project save, dirty baseline, and undo history.
- Tests:
  - Expanded export extension helper coverage for `.stl`.
  - Added widget coverage for toolbar STL export.
  - Updated STEP export and picker-guard tests to pass through the chooser.
  - Added chooser-cancel coverage before the native file picker opens.
- Docs/tasks:
  - Marked user-facing STL export complete in `TASKS.md`.
  - Added M102 to `ROADMAP.md`.
  - Updated export, project-file, commands/undo, shell, geometry-slice, and
    research follow-up docs.

### Tests run
- `dart format lib\project\project_file_dialog_service.dart lib\ui\shell\workspace_shell.dart test\project_file_service_test.dart test\widget_test.dart`:
  - Passed; 0 changed.
- `flutter test test\project_file_service_test.dart --plain-name "export dialog helper preserves or adds export extensions" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "export command writes STEP artifact through geometry service" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "export command writes STL artifact through geometry service" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "export picker opens without pre-picker status rebuild" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "export format chooser can be cancelled before file picker" --reporter compact`:
  - First run failed because `WidgetTester.pageBack()` expects a Cupertino back
    button; test was corrected to dismiss the bottom sheet via barrier tap.
  - Passed after correction.
- `flutter pub get`:
  - Passed; package solver reported only newer incompatible package notices.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 73 files checked, 0 changed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed; 209 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- After chooser width polish, `dart format --output=none --set-exit-if-changed lib test tool occt_worker`, `flutter analyze`, `flutter test --reporter compact`, and `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed again; full suite remained at 209 tests and the latest Windows
    bundle was refreshed again.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for docs.

### Validation
- Geometry checked?
  - Targeted fake-service widget paths checked STEP/STL request routing; the
    full suite includes existing native STEP/STL artifact tests.
- Serialization checked?
  - No project schema changes; export paths remain outside project JSON.
- UI checked?
  - Targeted widget tests and full test suite cover chooser, cancel, STEP, STL,
    and picker guard.
- Export checked?
  - Toolbar paths send `export_step` and `export_stl` with explicit output
    paths and format-specific file extensions; latest Windows bundle was
    refreshed.

### Known issues
- Issue: Export still writes the whole generated assembly.
  - Severity: Medium.
  - Next action: Add part/body selection after the whole-assembly path settles.
- Issue: STL export still has one backend quality profile.
  - Severity: Medium.
  - Next action: Add quality presets after manual STL checks.

### Next step
Commit and push M102, then manually poke STEP/STL export from the latest exe.

### Notes for future Codex sessions
Keep export format choice as UI/output flow only. Do not write chosen file paths
or exported mesh/STEP data into `ProjectModel` without an explicit export
history design.

---

## 2026-07-01 - M101 Native STL export slice

### Goal
Add the first native OCCT STL artifact export behind the worker protocol,
without adding editable STL, mesh, B-Rep, or topology IDs to the project model.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/geometry/geometry_protocol.dart`, `test/geometry_protocol_test.dart`,
`test/occt_native_target_scaffold_test.dart`,
`test/support/native_occt_geometry_fixture.dart`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/StlAPI_Writer.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/StlAPI.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepMesh_IncrementalMesh.hxx`,
`occt_worker/README.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/05_PROJECT_FILE_FORMAT.md`, `docs/25_EXPORT_PIPELINE.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/geometry/geometry_protocol.dart`:
  - Added `GeometryRequest.exportStl`, which carries semantic project JSON,
    derived feature intents, and explicit `options.outputPath`.
- `occt_worker/native/src/occt_main.cpp`:
  - Added `export_stl` support to native OCCT capabilities and request parsing.
  - Requires non-empty `options.outputPath` for STL export.
  - Meshes the same generated semantic B-Rep assembly with deterministic
    first-pass STL deflection values.
  - Writes binary STL through `StlAPI_Writer`.
  - Returns an `stl` `GeometryArtifact` plus export metrics and keeps
    `editableGeneratedGeometry=false`.
- Tests:
  - Added protocol coverage for `GeometryRequest.exportStl`.
  - Added native STL export coverage that writes a temporary `.stl` file and
    validates binary STL header/count/byte-size layout.
  - Extended native source-contract coverage for the STL path.
- Docs/tasks:
  - Marked STL export done at the worker MVP level in `TASKS.md`.
  - Added M101 to `ROADMAP.md`.
  - Updated OCCT/export/project-file/commands docs and added an STL export
    research note.

### Tests run
- `dart format lib\geometry\geometry_protocol.dart test\geometry_protocol_test.dart test\native_occt_stl_export_test.dart test\occt_native_target_scaffold_test.dart`:
  - Passed; 0 changed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt the native OCCT worker and deployed `TKDESTL.dll`.
- `flutter test test\geometry_protocol_test.dart --plain-name "STL export request carries output path and semantic feature intents" --reporter compact`:
  - Passed.
- `flutter test test\occt_native_target_scaffold_test.dart --plain-name "OCCT target source emits deterministic rounded enclosure preview mesh" --reporter compact`:
  - Passed.
- `flutter test test\native_occt_stl_export_test.dart --reporter compact`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; native capabilities include `preview_mesh`, `export_step`, and
    `export_stl`.
- `flutter pub get`:
  - Passed; package solver reported only newer incompatible package notices.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 73 files checked, 0 changed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed; 207 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for docs.

### Validation
- Geometry checked?
  - Native worker rebuild, metrics smoke test, targeted STL export test, full
    Flutter test suite, and latest Windows bundle build passed.
- Serialization checked?
  - `GeometryRequest.exportStl` round-trip coverage passed.
- UI checked?
  - No new app UI is exposed in this backend slice.
- Export checked?
  - Native STL artifact test writes and validates a temporary binary STL file;
    latest Windows bundle was refreshed.

### Known issues
- Issue: Toolbar export is still STEP-only.
  - Severity: Medium.
  - Next action: Add a user-facing format choice for STEP/STL.
- Issue: STL export uses one first-pass binary quality profile.
  - Severity: Medium.
  - Next action: Add export quality presets after manual file checks.

### Next step
Commit and push M101, then start the user-facing STEP/STL export format choice.

### Notes for future Codex sessions
Keep STL output as an artifact only. Do not write STL paths, triangle IDs, or
generated meshes into `ProjectModel` unless a future explicit export-history
feature is designed.

---

## 2026-07-01 - M100 Toolbar STEP export

### Goal
Expose the first STEP export path through the toolbar while keeping exported
geometry as an output artifact, not editable project state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/project/project_file_dialog_service.dart`,
`lib/ui/shell/workspace_shell.dart`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_protocol.dart`, `test/widget_test.dart`,
`test/project_file_service_test.dart`, `docs/25_EXPORT_PIPELINE.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/project/project_file_dialog_service.dart`:
  - Added a dedicated STEP export save-location picker.
  - Added `.step/.stp` extension preservation via `ensureStepFileExtension`.
- `lib/ui/shell/workspace_shell.dart`:
  - Wired the toolbar export command to `GeometryRequest.exportStep`.
  - Kept export outside project save, undo/redo history, and dirty-state
    persistence.
  - Reused the file busy guard so repeated clicks while the picker is open do
    not launch multiple dialogs.
- Tests:
  - Added STEP extension helper coverage.
  - Added widget coverage for successful toolbar STEP export.
  - Added widget coverage for the export picker double-click guard.
- Docs/tasks:
  - Added M100 to `ROADMAP.md`.
  - Marked first-pass toolbar STEP export complete in `TASKS.md`.
  - Updated export, commands/undo, usable-shell, and first-geometry docs.

### Tests run
- `flutter test test\project_file_service_test.dart --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "export command writes STEP artifact through geometry service" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "export picker opens without pre-picker status rebuild" --reporter compact`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 72 files checked, 0 changed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - First full run found a status-bar priority regression: the open-cancel
    dirty-state message was hidden by a file status message.
- `flutter test test\widget_test.dart --plain-name "open command can be cancelled when project has unsaved changes" --reporter compact`:
  - Passed after restoring the previous status-bar priority.
- `flutter test test\widget_test.dart --plain-name "export command writes STEP artifact through geometry service" --reporter compact`:
  - Passed after the status-bar fix.
- `flutter test --reporter compact`:
  - Passed; 205 tests.
- `flutter pub get`:
  - Passed; Flutter reported only newer package versions outside current
    dependency constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt `releases/latest/windows` with the native OCCT worker
    bundled.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` remains ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for existing text files.

### Validation
- Geometry checked?
  - Native STEP artifact generation remains covered by the full test suite, and
    latest Windows build passed.
- Serialization checked?
  - STEP export request remains covered by protocol tests from M99; this slice
    verifies the toolbar sends `options.outputPath`.
- UI checked?
  - Targeted widget export flows and the full widget suite passed.
- Export checked?
  - Toolbar export path is covered with a fake geometry backend; native STEP
    artifact generation remains covered by `native_occt_step_export_test`.

### Known issues
- Issue: Toolbar export is STEP-only.
  - Severity: Medium.
  - Next action: Add native STL artifact path and a user-facing format choice.
- Issue: Export still writes the whole generated assembly.
  - Severity: Medium.
  - Next action: Add part/body selection after the artifact formats settle.

### Next step
Commit, push, and ask for a manual STEP export poke.

### Notes for future Codex sessions
Keep project save and geometry export separate. Export paths are output-only and
must not be written into saved project JSON unless a future explicit export
history feature is designed.

---

## 2026-07-01 - M99 Native STEP export slice

### Goal
Add the first native OCCT STEP artifact export behind the worker protocol,
without adding editable B-Rep, STEP paths, or topology IDs to the project
model.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/geometry/geometry_protocol.dart`, `test/geometry_protocol_test.dart`,
`test/occt_native_target_scaffold_test.dart`,
`test/support/native_occt_geometry_fixture.dart`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/README.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/25_EXPORT_PIPELINE.md`, `docs/27_RESEARCH_AND_REFERENCES.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `lib/geometry/geometry_protocol.dart`:
  - Added `GeometryRequest.exportStep`, which carries semantic project JSON,
    derived feature intents, and explicit `options.outputPath`.
- `occt_worker/native/src/occt_main.cpp`:
  - Added `export_step` support to the native OCCT worker capabilities and
    request parser.
  - Requires non-empty `options.outputPath` for STEP export.
  - Uses `STEPControl_Writer` with `STEPControl_AsIs` on the same generated
    semantic B-Rep assembly used by preview.
  - Redirects OCCT STEP writer stdout during transfer/write so worker stdout
    stays valid protocol JSON.
  - Returns a `step` `GeometryArtifact` plus export metrics and keeps
    `editableGeneratedGeometry=false`.
- Tests:
  - Added protocol coverage for `GeometryRequest.exportStep`.
  - Added native STEP export coverage that writes a temporary `.step` file and
    verifies it is an `ISO-10303-21` payload.
  - Extended native source-contract coverage for the STEP path.
- Docs/tasks:
  - Marked STEP export done at the worker MVP level in `TASKS.md`.
  - Added M99 to `ROADMAP.md`.
  - Updated OCCT/export docs and added a STEP export research note.

### Tests run
- `dart format lib\geometry\geometry_protocol.dart test\geometry_protocol_test.dart test\native_occt_step_export_test.dart test\occt_native_target_scaffold_test.dart`:
  - Passed; formatted `test\geometry_protocol_test.dart`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt the native OCCT worker and deployed STEP dependencies.
- `flutter test test\geometry_protocol_test.dart --plain-name "STEP export request carries output path and semantic feature intents" --reporter compact`:
  - Passed.
- `flutter test test\occt_native_target_scaffold_test.dart --plain-name "OCCT target source emits deterministic rounded enclosure preview mesh" --reporter compact`:
  - Passed.
- `flutter test test\native_occt_step_export_test.dart --reporter compact`:
  - First run failed because OCCT STEP writer statistics were printed to stdout
    before the JSON response, making the worker response invalid JSON.
- `flutter test test\native_occt_step_export_test.dart --reporter compact`:
  - Passed after suppressing OCCT transfer/write stdout.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; native preview metrics stayed deterministic while capabilities now
    include `preview_mesh` and `export_step`.
- `flutter pub get`:
  - Passed; Flutter reported only newer package versions outside current
    dependency constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 72 files checked, 0 changed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed; 202 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt `releases/latest/windows` with the native OCCT worker
    bundled.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` remains ignored.
- `git diff --check`:
  - Passed with CRLF normalization warnings only for existing text files.

### Validation
- Geometry checked?
  - Native worker rebuild, targeted STEP export test, native metrics smoke, and
    full Flutter suite passed.
- Serialization checked?
  - `GeometryRequest.exportStep` round-trip coverage passed.
- UI checked?
  - Full widget test suite passed. No manual UI poke is useful yet because STEP
    export is worker/test-level only in this slice.
- Export checked?
  - Native STEP artifact test writes and validates a temporary STEP file, and
    latest Windows bundle was rebuilt.

### Known issues
- Issue: STEP export is worker/test-level only; no app UI command is exposed
  yet.
  - Severity: Medium.
  - Next action: Add user-facing export/save workflow in a later chunk.
- Issue: STL export is still pending.
  - Severity: Medium.
  - Next action: Add native STL artifact path after STEP settles.

### Next step
Commit and push M99, then continue with a user-facing export workflow or the
next artifact path.

### Notes for future Codex sessions
Keep worker stdout reserved for JSON. If OCCT import/export APIs write status
text to stdout, wrap those calls in a temporary redirect before returning a
protocol response.

---

## 2026-07-01 - M98 Native OCCT geometry regression test

### Goal
Add a normal Flutter test path for the native OCCT known-dimensions sample so
geometry regressions are caught before export work.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/geometry_worker_runtime_test.dart`,
`test/occt_native_target_scaffold_test.dart`,
`lib/geometry/geometry_service.dart`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`occt_worker/README.md`, and `docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `test/support/native_occt_geometry_fixture.dart`:
  - Added the reusable native OCCT regression sample project, expected
    deterministic bounds, dimensions, mesh counts, mapped triangle count, and
    semantic mapping ids.
  - Added small helpers for the built native worker path, process client,
    mapped triangle counting, range validation, and metrics reading.
- `test/native_occt_geometry_regression_test.dart`:
  - Added an integration-style Flutter test that launches the built native
    OCCT worker when available.
  - Checks native capabilities, preview response status, non-editable generated
    geometry, bounds, dimensions, surface area, volume, mesh counts, mapped
    ranges, semantic ids, and absence of topology/triangle ids in metrics.
  - Skips when the opt-in native worker executable is not built locally, so a
    clean non-OCCT machine can still run the default suite.
- Docs/tasks:
  - Marked the known-dimensions OCCT test task complete in `TASKS.md`.
  - Added M98 to `ROADMAP.md`.
  - Documented the regression test command in `occt_worker/README.md` and
    `docs/34_FIRST_GEOMETRY_SLICE.md`.

### Tests run
- `dart format test\support\native_occt_geometry_fixture.dart test\native_occt_geometry_regression_test.dart`:
  - Passed; formatted the new test file.
- `flutter test test\native_occt_geometry_regression_test.dart --reporter compact`:
  - Passed; the test ran against the local built native OCCT worker and did not
    skip.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; `71` files checked, `0` changed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `13258` vertices, `13480` triangles, `14` mappings,
    `20072` mapped triangles, bounds `[-60, -36.65, 0]` to `[60, 35, 31.73]`,
    surface area `56309.554412`, and volume `53366.434601`.
- `flutter pub get`:
  - Passed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; `200` tests, including the new native OCCT regression test.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` remains ignored.
- `git diff --check`:
  - Passed with only CRLF-to-LF normalization warnings for markdown files.

### Validation
- Geometry checked?
  - Targeted native OCCT regression test passed against the local executable.
- Serialization checked?
  - No project/protocol schema changed.
- UI checked?
  - Full widget/unit suite passed and latest Windows bundle rebuilt.
- Export checked?
  - Not changed.

### Known issues
- Issue: The test requires a previously built native OCCT executable to run
  locally; otherwise it is skipped.
  - Severity: Low.
  - Next action: Keep using the smoke/build scripts before native geometry
    chunks, and consider CI native-worker builds later.

### Next step
Continue toward the first export slice after M98 is committed and pushed.

### Notes for future Codex sessions
Keep native geometry regression expectations in sync with the smoke tool when
intentional geometry changes alter deterministic counts or metrics. The test
must remain semantic-output focused and must not depend on raw OCCT topology or
stable triangle ids.

---

## 2026-07-01 - M97 Native top lid planar plate

### Goal
Make the generated top lid preview plate read as a flat lid with rounded
outside corners instead of a pillow-like fully filleted thin box.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`test/occt_native_target_scaffold_test.dart`, and
`tool/native_occt_worker_metrics_smoke.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `BuildRoundedBoxVerticalEdgeShape`, which uses OCCT fillets only on
    vertical box edges.
  - Switched generated top lid plate construction to that helper so top and
    bottom faces remain planar.
  - Kept the main enclosure body and existing feature tools on the previous
    rounded-box path.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for the new generated lid plate helper.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native preview counts, area, and volume after the
    lid plate became flatter.
- Docs/tasks:
  - Added M97 to `ROADMAP.md`, marked the task in `TASKS.md`, added an OCCT
    research note, and updated geometry docs.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe`.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - First run failed only because deterministic counts/metrics still referenced
    the previous fully filleted lid plate.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed after updating expectations; reports `13258` vertices, `13480`
    triangles, `14` mappings, `20072` mapped triangles,
    `nativeGeneratedLidFitPreviewGap=0.08`, bounds `[-60, -36.65, 0]` to
    `[60, 35, 31.73]`, surface area `56309.554412`, and volume
    `53366.434601`.
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; `69` files checked, `0` changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test test\occt_native_target_scaffold_test.dart --plain-name "OCCT target source emits deterministic rounded enclosure preview mesh" --reporter compact`:
  - Passed.
- `flutter test --reporter compact`:
  - Passed; `199` tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git status --short --ignored releases`:
  - Passed; `releases/` remains ignored.
- `git diff --check`:
  - Passed with only CRLF-to-LF normalization warnings for markdown files.

### Validation
- Geometry checked?
  - Native OCCT worker rebuilt and native smoke passed.
- Serialization checked?
  - No project/protocol serialization changed.
- UI checked?
  - Full widget/unit suite passed, including preview selection tests; latest
    Windows bundle rebuilt for manual UI check.
- Export checked?
  - Not changed.

### Known issues
- Issue: The generated lid is still a preview member, not a full editable
  lid/body assembly.
  - Severity: Medium.
  - Next action: Add explicit lid/body assembly semantics later.

### Next step
Manually check the latest Windows bundle: orbit around the top lid and confirm
that the lid reads flatter while the body remains rounded.

### Notes for future Codex sessions
Use vertical-edge rounding for thin generated plates when the user needs a flat
part with rounded plan-view corners. Do not make generated lid solids editable
or store OCCT topology IDs in `ProjectModel`.

---

## 2026-07-01 - M96 Native top lid near-flush fit preview

### Goal
Make the generated top lid preview sit closer to the body so it reads as a
near-flush fit instead of a detached plate, without introducing editable lid
assembly state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`, and
`tool/native_occt_worker_metrics_smoke.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Tightened `GeneratedTopLidFitPreviewGap` from the old `0.2-0.35 mm`
    inspection band to a near-flush `0.06-0.12 mm` band.
  - The sample enclosure now reports a `0.08 mm` generated lid fit-preview gap.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic expectations for the new sample gap and preview
    bounds/dimensions.
- Docs/tasks:
  - Added M96 to `ROADMAP.md`, marked the fit-preview tightening task in
    `TASKS.md`, added a research note, and updated first-geometry/current OCCT
    docs.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1`:
  - Reported that manifest OCCT install requires `-AllowVcpkgInstall`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe`.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - First run failed only because expected Z bounds still referenced the old
    gap.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed after updating expectations; reports `nativeGeneratedLidFitPreviewGap=0.08`,
    `13882` vertices, `14384` triangles, `14` mappings, `21240` mapped
    triangles, bounds `[-60, -36.65, 0]` to `[60, 35, 31.73]`, surface area
    `56020.328695`, and volume `53230.754103`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 69 files checked, 0 changed.
- `flutter pub get`:
  - Passed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; all tests passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; latest Windows bundle rebuilt at
    `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; only existing markdown line-ending warnings were reported.

### Validation
- Geometry checked?
  - Native OCCT worker rebuilt and native smoke passed.
- Serialization checked?
  - No project/protocol serialization changed.
- UI checked?
  - Analyzer and full Flutter suite passed.
- Export checked?
  - Latest Windows bundle was rebuilt; export flows were not changed.

### Known issues
- Issue: The generated lid is still a generated preview member, not a real
  editable lid/body assembly.
  - Severity: Medium.
  - Next action: Add explicit lid/body assembly semantics in a later chunk.

### Next step
Manually check that the generated top lid now sits much closer to the body.

### Notes for future Codex sessions
Keep `nativeGeneratedLidFitPreviewGap` generated-output metadata. Do not store
lid assembly state, generated lid B-Rep, OCCT topology IDs, or triangle IDs in
`ProjectModel`.

---

## 2026-07-01 - M95 Native preview mesh de-noise

### Goal
Reduce the visible triangle-wire noise in the current native preview while
keeping generated mesh data display-only and preserving semantic selection.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/33_VIEWPORT_MVP.md`, `lib/ui/shell/workspace_shell.dart`, and
`lib/viewport/viewport_controller.dart`.

### Changes made
- `lib/viewport/preview_mesh_edges.dart`:
  - Added a small helper that derives boundary edges from preview mesh
    triangles.
  - Keeps internal shared triangle edges out of the rendered contour.
- `lib/ui/shell/workspace_shell.dart`:
  - Uses preview mesh boundary edges instead of stroking every unselected
    triangle.
  - Draws selected semantic-range boundary edges instead of selected internal
    triangle wire.
  - Softened preview triangle shade contrast to reduce the debug-mesh look.
- `test/preview_mesh_edges_test.dart`:
  - Added unit coverage for shared-edge removal, selected-range contours, and
    invalid triangle/index handling.
- Docs/tasks:
  - Added M95 to `ROADMAP.md`, marked the related task items in `TASKS.md`, and
    updated viewport docs to describe boundary-edge rendering.

### Tests run
- `dart format lib\viewport\preview_mesh_edges.dart lib\ui\shell\workspace_shell.dart test\preview_mesh_edges_test.dart`:
  - Passed; formatted the new helper and test.
- `flutter test test\preview_mesh_edges_test.dart --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "native preview mesh click selects mapped semantic feature" --reporter compact`:
  - Passed.
- Initial parallel targeted Flutter test attempt:
  - Reported a Flutter startup-lock/ephemeral cleanup conflict; rerun
    sequentially and passed.
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 69 files checked, 0 changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed; all tests passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; latest Windows bundle rebuilt at
    `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; only the existing `ROADMAP.md` line-ending warning was reported.

### Validation
- Geometry checked?
  - Not changed; this is viewport rendering only.
- Serialization checked?
  - No project/protocol serialization changed.
- UI checked?
  - Boundary-edge helper unit tests, native preview widget tests, analyzer, and
    full suite passed.
- Export checked?
  - Latest Windows bundle was rebuilt; export flows were not changed.

### Known issues
- Issue: The native preview still uses the interim `CustomPaint` mesh renderer,
  so some faceted shading remains.
  - Severity: Medium.
  - Next action: Later move to a proper depth-aware 3D viewport/material path.
- Issue: The generated top lid is still a fit-preview/exploded plate, not final
  flush mating geometry.
  - Severity: Medium.
  - Next action: Keep for a later geometry chunk focused on lid fit/seat.

### Next step
Manually check that the native body no longer reads like a triangle debug mesh
while mapped selection highlights still work, then continue with the later lid
fit/seat geometry chunk.

### Notes for future Codex sessions
Do not reintroduce raw triangle-wire display as the default native preview.
Triangle IDs remain transient preview details; selection should stay semantic.

---

## 2026-06-30 - M94 Native mesh semantic picking

### Goal
Remove the confusing passive 2D surface workplane during native model
inspection and make direct clicks on the generated preview mesh select mapped
semantic parts.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/33_VIEWPORT_MVP.md`, `lib/ui/shell/workspace_shell.dart`,
`lib/viewport/viewport_controller.dart`, and `test/widget_test.dart`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added first-pass native preview mesh hit-testing before old mock hit zones.
  - Keeps explicit snap-point hits ahead of mesh picking so snap workflows still
    work.
  - Reuses the same preview projection math for painting and mesh hit-testing.
  - Converts a hit preview triangle range immediately back to a semantic id and
    then discards the triangle index.
  - Feeds native preview mesh mapping labels into the selection resolver so
    mapped surface picks can show human labels when the worker provides them.
  - Hides passive native surface workplanes instead of drawing a 2D rectangle
    over the generated model.
- `test/widget_test.dart`:
  - Added coverage that clicking a mapped preview mesh triangle selects the
    mapped semantic feature and enables mesh highlighting.
  - Updated native workplane expectations to track hidden/focused states.
- Docs/tasks:
  - Added M94 to `ROADMAP.md`, marked native mesh picking in `TASKS.md`, and
    updated viewport docs to explain semantic mesh picking versus raw triangle
    editing.

### Tests run
- `dart format lib\ui\shell\workspace_shell.dart test\widget_test.dart`:
  - Passed; formatted `lib/ui/shell/workspace_shell.dart`.
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 67 files checked, 0 changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test test\widget_test.dart --plain-name "native preview mesh click selects mapped semantic feature" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "native preview softens surface workplane overlay" --reporter compact`:
  - Passed.
- `flutter test --reporter compact`:
  - Passed; all tests passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; latest Windows bundle rebuilt at
    `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; only the existing `ROADMAP.md` line-ending warning was reported.

### Validation
- Geometry checked?
  - Not changed; picking consumes existing preview mesh mappings.
- Serialization checked?
  - No project/protocol serialization changed.
- UI checked?
  - Targeted widget tests and full suite passed.
- Export checked?
  - Latest Windows bundle was rebuilt; export flows were not changed.

### Known issues
- Issue: Mesh picking is first-pass and depends on available
  `PreviewSurfaceMapping` ranges. Unmapped generated triangles still fall back
  to old mock hit zones or workspace selection.
  - Severity: Medium.
  - Next action: Expand native worker mappings and consider a true 3D renderer
    when preview complexity grows.

### Next step
Manually check that clicking visible mapped model details selects semantic parts
without the old passive 2D workplane covering the model, then expand native
worker mappings for more individual generated surfaces.

### Notes for future Codex sessions
Do not store triangle IDs, OCCT face IDs, or generated mesh IDs in
`ProjectModel`. Native mesh picking should only be a display-time route back to
semantic ids.

---

## 2026-06-30 - M93 Native surface workplane softening

### Goal
Respond to the latest `Top lid` screenshot by reducing the dominance of the
surface workplane/grid/snap overlay in native preview mode while preserving
selection highlighting and placement-oriented focused workplanes.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/33_VIEWPORT_MVP.md`, `lib/ui/shell/workspace_shell.dart`, and
`test/widget_test.dart`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added native workplane muted/focused sentinels for widget coverage.
  - Makes native surface workplanes passive unless an active snap target is
    selected.
  - Keeps component-placement workplanes focused in native preview mode.
  - Removes the passive native surface workplane grid, lowers outline/fill
    strength, and shrinks/dims passive snap points.
- `test/widget_test.dart`:
  - Added coverage for `Top lid` using the muted native workplane state and
    component placement using the focused native workplane state.
- Docs/tasks:
  - Added M93 to `ROADMAP.md`, marked the task in `TASKS.md`, and documented
    passive/focused workplanes in `docs/33_VIEWPORT_MVP.md`.

### Tests run
- `dart format lib\ui\shell\workspace_shell.dart test\widget_test.dart`:
  - Passed, no changes required.
- `flutter test test\widget_test.dart --plain-name "native preview softens surface workplane overlay" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed, 0 changes.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 195 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Not changed; this is viewport rendering style only.
- Serialization checked?
  - No project or protocol data changed.
- UI checked?
  - Targeted widget tests and full widget suite passed.
- Export checked?
  - Not touched.

### Known issues
- Issue: The native preview still uses a `CustomPaint` mesh projection and mock
  workplane rectangles rather than a true 3D face-projected workplane.
  - Severity: Medium.
  - Next action: Revisit after the semantic geometry MVP or when moving to a
    real 3D renderer.

### Next step
Run full validation, refresh the latest Windows bundle, then continue with
geometry/readability work based on manual inspection.

### Notes for future Codex sessions
Surface selection should help inspection first. In native mesh mode, keep
surface workplanes passive unless the user starts an explicit placement/snap
workflow.

---

## 2026-06-30 - M92 Native viewport de-clutter

### Goal
Respond to the latest screenshot by making native preview inspection less noisy:
the generated body should read as the main layer, while schematic semantic
overlays stay muted until the user selects them.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/33_VIEWPORT_MVP.md`, `lib/ui/shell/workspace_shell.dart`, and
`test/widget_test.dart`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added native overlay mute/focus sentinels for widget coverage.
  - Reduced default preview-mesh triangle stroke alpha/width to cut down
    screenshot-visible internal triangle noise.
  - Dimmed component placement, USB-C, glass recess, button group, and standoff
    schematic annotations when a native preview mesh is active and the
    corresponding semantic object is not selected.
  - Keeps selected semantic feature/group/component annotations stronger so the
    user can still inspect and poke them.
- `test/widget_test.dart`:
  - Added coverage proving native overlays start muted and switch to focused
    after selecting `USB-C`.
- Docs/tasks:
  - Added M92 to `ROADMAP.md`, marked the viewport polish in `TASKS.md`, and
    documented the muted/focused native annotation behavior in
    `docs/33_VIEWPORT_MVP.md`.

### Tests run
- `dart format lib\ui\shell\workspace_shell.dart test\widget_test.dart`:
  - Passed; formatted `lib/ui/shell/workspace_shell.dart`.
- `flutter test test\widget_test.dart --plain-name "viewport exposes geometry preview mesh from service" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "native preview keeps semantic overlays muted until selected" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed, 0 changes.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 194 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Not changed; this slice only changes viewport rendering style.
- Serialization checked?
  - No project model or protocol fields changed.
- UI checked?
  - Targeted widget tests and full widget suite passed.
- Export checked?
  - Not touched.

### Known issues
- Issue: The viewport is still a `CustomPaint` preview renderer without a real
  depth buffer, so very large meshes can still show painter-order artifacts.
  - Severity: Medium.
  - Next action: Consider a real 3D renderer or a stronger native preview
    simplification pass after the semantic geometry MVP is further along.

### Next step
Run full validation, rebuild the latest Windows bundle, then continue with the
next safe geometry or viewport readability slice after manual inspection.

### Notes for future Codex sessions
Do not hide semantic affordances permanently. In native mesh mode they should be
quiet by default and become readable when their semantic item is selected.

---

## 2026-06-30 - M91 Native plunger guide/stop preview

### Goal
Generate first-pass native guide sleeve and travel-stop preview geometry for
plunger-style semantic button groups, using the M90 travel/clearance values.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/16_BUTTON_AND_PLUNGER_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`lib/validation/project_semantic_validator.dart`,
`test/project_semantic_validator_test.dart`,
`test/occt_native_target_scaffold_test.dart`, and
`tool/native_occt_worker_metrics_smoke.dart`.

Official OCCT references checked before the geometry change:
`BRepPrimAPI_MakeCylinder`, `BRepAlgoAPI_Cut`, `BRep_Builder`, and the
Modeling Algorithms overview.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses `travel`, `switchClearance`, and `guideClearance` into native
    button item requests.
  - Adds annular guide-sleeve preview geometry and short travel-stop collar
    preview geometry for front-wall and generated top-lid plunger buttons.
  - Adds validation for impossible guide/travel combinations before generating
    the native shapes.
  - Emits native guide/stop metrics for front and generated top-lid buttons.
- `lib/validation/project_semantic_validator.dart`:
  - Adds a semantic guide-wall fit check using the native guide wall thickness.
- Tests:
  - Adds scaffold/smoke assertions for new request fields, helper names, and
    native guide/stop metric names.
  - Updates native smoke deterministic mesh, area, volume, and guide/stop count
    expectations.
- Docs/tasks:
  - Marks M91 complete in `ROADMAP.md` and `TASKS.md`.
  - Updates button/plunger, enclosure generation, OCCT architecture, geometry
    slice, and research notes.

### Tests run
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - First run reformatted `tool/native_occt_worker_metrics_smoke.dart`; rerun
    passed with 0 changes.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 193 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe`.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; preview mesh reports 13882 vertices, 14384 triangles, 14 mappings,
    20758 mapped triangles, front guide/stop counts 2/2, generated top-lid
    guide/stop counts 4/4, surface area 56020.328695, and volume 53230.754103.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; only line-ending warnings for existing text files.

### Validation
- Geometry checked?
  - Native OCCT worker build and metrics smoke passed with deterministic
    guide/stop geometry counts.
- Serialization checked?
  - Full test suite passed; the new values still flow through semantic
    `button_group.itemPrototype` and worker request data rather than editable
    generated solids.
- UI checked?
  - Existing widget suite passed; no new visible controls were added in this
    slice.
- Export checked?
  - Not touched.

### Known issues
- Issue: Guide sleeves and travel stops are first-pass preview solids without
  chamfers, material-aware tolerances, anti-wobble variants, or switch-contact
  collision checks.
  - Severity: Medium.
  - Next action: Add printable mechanical polish and richer validation after
    manual inspection confirms the basic generated detail is readable.

### Next step
Inspect the latest app manually, then continue toward printable button
mechanics: chamfers/fillets, anti-wobble variants, or switch-contact checks.

### Notes for future Codex sessions
Guide sleeves and travel stops are generated output owned by the native worker.
Do not expose them as separate editable solids, and do not make Flutter depend
on OCCT topology or generated triangle IDs.

---

## 2026-06-30 - M90 Semantic plunger travel controls

### Goal
Add first-pass semantic travel and clearance controls for plunger-style button
groups before generating real guide walls or travel stops.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/16_BUTTON_AND_PLUNGER_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`lib/ui/shell/workspace_shell.dart`,
`lib/validation/project_semantic_validator.dart`,
`lib/geometry/geometry_protocol.dart`, and related button-group tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `travel`, `switchClearance`, and `guideClearance` defaults for manual
    and component-sourced `button_group` creation.
  - Added dialog and selected-group inspector controls for `Ход`,
    `Зазор до свитча`, and `Зазор направл.`.
  - Normalizes the new values into `FeatureGroup.itemPrototype` so the group
    remains one editable semantic object.
- `lib/validation/project_semantic_validator.dart`:
  - Added plunger-only validation for travel depth, switch clearance, and guide
    clearance fit.
  - Keeps `mode: cutout` groups quiet for plunger-specific warnings.
- `lib/selection/project_selection_resolver.dart` and
  `lib/project/project_model.dart`:
  - Surface the new properties in inspector details and initial project data.
- Protocol fixtures, sample project, and smoke inputs:
  - Added the new semantic fields to geometry requests and operation-plan
    fixtures.
- Tests and docs:
  - Added semantic validator coverage, protocol assertions, resolver assertions,
    and widget coverage for inspector/dialog defaults and undo.
  - Updated roadmap, task tracker, button/plunger docs, pattern docs, enclosure
    generation docs, command/undo docs, and research notes.

### Tests run
- `flutter test test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\project_semantic_validator_test.dart --reporter compact`:
  - Passed, 33 tests.
- `flutter test test\widget_test.dart --plain-name "selected button group inspector edits pattern through undo" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed, no formatting changes required.
- `flutter analyze`:
  - Passed, no issues found.
- `flutter test --reporter compact`:
  - Passed, 193 tests.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; native preview emitted mesh and button cap/stem metrics.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt latest Windows bundle.

### Validation
- Geometry checked?
  - Protocol fixtures and native smoke passed; no new OCCT shape operation was
    added in this slice.
- Serialization checked?
  - New fields round-trip through request fixtures and operation plans.
- UI checked?
  - Widget tests cover dialog defaults, inspector editing, and undo.
- Export checked?
  - Not touched.

### Known issues
- Issue: Guide walls, travel stops, anti-wobble geometry, and richer
  switch-contact/collision checks are still future work.
  - Severity: Medium.
  - Next action: Add the next printable plunger mechanics slice after this
    semantic validation base.

### Next step
Start the next button/plunger mechanics slice: guide-wall/travel-stop planning
or a first constrained printable plunger geometry step.

### Notes for future Codex sessions
The new parameters are semantic project data in `FeatureGroup.itemPrototype`.
Do not flatten them into generated solids or make the OCCT worker own product
semantics; geometry should consume these values through existing feature-group
intents.

---

## 2026-06-30 - M89 Viewport navigation presets

### Goal
Make manual viewport inspection faster by adding standard camera presets
without saving camera state into the semantic project or coupling selection to
generated mesh data.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/22_UI_NAVIGATION_LAYOUT.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/viewport/viewport_controller.dart`,
`lib/ui/shell/workspace_shell.dart`,
`test/viewport_controller_test.dart`, and `test/widget_test.dart`.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added typed `ViewportViewPreset` values for ISO, top, front, left, and
    right.
  - Added preset yaw/pitch metadata, active-preset detection, and a controller
    method that resets pan/zoom while preserving semantic selection and ghost
    overlays.
  - Shows the active preset label in `ViewportState.viewLabel`.
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced the single ISO/fit square with compact TOP, FRT, RGT, LFT, ISO,
    and fit controls.
  - Kept the controls as fixed-size transient viewport UI, not saved project
    data.
- Tests:
  - Added controller coverage for preset state and overlay preservation.
  - Added widget coverage for clicking presets and fit.
- Docs/tasks/roadmap:
  - Added M89 to `ROADMAP.md`.
  - Marked `Navigation presets foundation` complete in `TASKS.md`.
  - Updated viewport and navigation docs.

### Tests run
- `flutter test test\viewport_controller_test.dart --reporter compact`:
  - Passed, 14 tests.
- `flutter test test\widget_test.dart --plain-name "viewport preset controls switch standard camera views" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed, 67 files checked with no changes.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 190 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry generation not changed; no OCCT rebuild was needed.
- Serialization checked indirectly through the full test suite; camera presets
  remain transient and are not written to project JSON.
- UI checked with widget coverage and full shell tests.
- Export not checked; STEP/STL export is still future work.

### Known issues
- Issue: Presets are instant jumps, not animated camera transitions, and there
  are no back/bottom views yet.
  - Severity: Low.
  - Next action: Add back/bottom or animated transitions later if manual
    inspection needs them.

### Next step
Use the new presets to inspect button/lid geometry quickly, then continue with
the next semantic plunger/guide/travel validation slice.

### Notes for future Codex sessions
Keep camera presets in `ViewportState` only. They must not enter undo history,
project JSON, geometry requests, or generated mesh selection.

---

## 2026-06-30 - M88 Native viewport readability pass

### Goal
Make the center native preview easier to read by treating the generated mesh as
the main model layer and the old mock workplanes/markers as lightweight
semantic annotations.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/33_VIEWPORT_MVP.md`, `lib/ui/shell/workspace_shell.dart`,
`test/widget_test.dart`, and the user's latest screenshot/comment about the
center viewport looking confusing.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added a native semantic overlay sentinel when a `PreviewMesh` is active.
  - Suppresses duplicate mock selection outlines when a selected surface,
    feature, or feature group already has mapped preview-mesh ranges.
  - Softens selected native surface tint and draws one screen-space halo around
    mapped selected ranges instead of a heavy per-triangle cyan block.
  - Uses the secondary accent for mapped feature and feature-group highlights
    so button groups read apart from lid/body selection.
  - Fades workplanes, component placements, feature markers, and group markers
    into annotation-style overlays while preserving semantic hit targets.
- `test/widget_test.dart`:
  - Added coverage for the native semantic overlay mode sentinel.
- Docs/tasks/roadmap:
  - Added M88 to `ROADMAP.md`.
  - Added the completed native preview readability task to `TASKS.md`.
  - Updated `docs/33_VIEWPORT_MVP.md` to describe native mesh annotation mode.

### Tests run
- `flutter test test\widget_test.dart --plain-name "viewport exposes geometry preview mesh from service" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "selected surface highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "selected feature group highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed, 67 files checked with no changes.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 188 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked indirectly through existing native preview/service tests;
  this slice did not change OCCT generation.
- Serialization checked indirectly through the full test suite; no project
  schema changed.
- UI checked with targeted viewport widget tests and the full widget suite.
- Export not checked; STEP/STL export is still future work.

### Known issues
- Issue: The native preview is still a simple faceted painter, not a full 3D
  viewport with real depth-aware semantic labels or mesh picking.
  - Severity: Medium.
  - Next action: Continue toward richer viewport rendering/selection after the
    current semantic geometry slices stabilize.

### Next step
Poke the latest app by selecting `Top lid`, then `Группа кнопок` /
`abxy_buttons`, and confirm the model is less visually noisy while the buttons
remain selectable.

### Notes for future Codex sessions
Keep native viewport overlays as semantic annotations. Do not use generated
triangles or OCCT topology as editable selection state; the current highlight
still flows through semantic ids and `GeometryService` preview ranges only.

---

## 2026-06-30 - M87 Native button cap/stem preview

### Goal
Generate first-pass plunger-style button cap and stem preview geometry from
semantic `button_group.itemPrototype` data, while keeping the editable project
as one semantic group instead of generated CAD solids.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/16_BUTTON_AND_PLUNGER_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`lib/ui/shell/workspace_shell.dart`,
`lib/selection/project_selection_resolver.dart`,
`lib/validation/project_semantic_validator.dart`,
`test/widget_test.dart`,
`test/geometry_protocol_test.dart`,
`test/project_semantic_validator_test.dart`,
`test/occt_native_target_scaffold_test.dart`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`occt_worker/native/src/occt_main.cpp`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added semantic `capDiameter`, `capHeight`, `stemDiameter`, and
    `stemDepth` defaults to manual and component-sourced button groups.
  - Added inspector and creation-dialog controls for cap/stem sizing.
  - Normalizes cap/stem values through the same undoable feature-group
    parameter path as button diameter and ring controls.
- `occt_worker/native/src/occt_main.cpp`:
  - Parses and validates cap/stem values from button group item parameters.
  - Builds front-wall and generated top-lid cap/stem preview compounds with
    OCCT cylinders when `mode` is `plunger`.
  - Maps cap/stem preview faces back to the original semantic button group ids.
  - Emits cap/stem metrics for front-wall and generated top-lid buttons.
- Tests/fixtures/samples:
  - Regenerated geometry protocol fixtures.
  - Added cap/stem fields to the sample project, protocol tests, widget tests,
    selection summary tests, semantic validator tests, native source-contract
    tests, and native smoke project.
- Docs/tasks/roadmap:
  - Added M87 to `ROADMAP.md`.
  - Updated button/plunger, pattern, enclosure generation, first geometry slice,
    research/reference notes, and task tracker.

### Tests run
- `dart run tool\generate_geometry_protocol_fixtures.dart`:
  - Passed; protocol fixtures updated.
- `flutter test test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 23 tests.
- `flutter test test\widget_test.dart --plain-name "selected button group inspector edits pattern through undo" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group" --reporter compact`:
  - Passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports 11254 vertices, 11816 triangles, 14 mappings,
    16478 mapped triangles, `nativeButtonCapCount=2`,
    `nativeButtonStemCount=2`, `nativeGeneratedLidButtonCapCount=4`, and
    `nativeGeneratedLidButtonStemCount=4`.
- `flutter test test\project_semantic_validator_test.dart --reporter compact`:
  - Passed, 12 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting `tool\native_occt_worker_metrics_smoke.dart`.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 188 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked with native OCCT build and deterministic smoke metrics.
- Serialization/protocol checked with regenerated fixtures and protocol tests.
- UI checked with widget coverage for inspector edit/undo and component-sourced
  button group creation.
- Export not checked; STEP/STL export is still future work.

### Known issues
- Issue: Cap/stem geometry is first-pass preview only and has no guide walls,
  travel stop, anti-wobble clearance, switch-contact validation, chamfers, or
  textures yet.
  - Severity: Medium.
  - Next action: Add real plunger mechanics and validation after the cap/stem
    preview is visually accepted.

### Next step
Poke the latest app around front and top-lid button groups, then continue with
guide/travel validation or another semantic generator slice.

### Notes for future Codex sessions
Cap/stem preview solids are intentionally separate compound members, not fused
into the body or generated lid. Keep them mapped to the parent
`button_group` id and keep generated OCCT solids out of editable project state.

---

## 2026-06-30 - M86 Semantic button ring controls

### Goal
Make first-pass button ring/bezel width and protrusion editable semantic
`button_group` parameters, while keeping generated rings as disposable native
B-Rep output.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/16_BUTTON_AND_PLUNGER_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`lib/ui/shell/workspace_shell.dart`,
`lib/geometry/geometry_protocol.dart`,
`lib/validation/project_semantic_validator.dart`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`, and related tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `ringWidth` and `ringProtrusion` defaults to manual and
    component-sourced button groups.
  - Added contextual inspector controls for ring width and protrusion.
  - Added ring width/protrusion fields to the button group creation dialog.
  - Preserved `0.45` style values in number formatting without changing
    integer field display.
- `occt_worker/native/src/occt_main.cpp`:
  - Parses `ringWidth` and `ringProtrusion` from button group item
    parameters.
  - Validates the outer ring diameter against the target surface.
  - Uses semantic ring width/protrusion in native ring generation and preview
    classification.
- Protocol/sample/test files:
  - Regenerated geometry protocol fixtures.
  - Added ring values to the sample project and native smoke project.
  - Added coverage for protocol propagation, operation plans, widget editing,
    selection summaries, and native source contract.
- Docs/tasks/roadmap:
  - Recorded M86 and marked first-pass editable ring/bezel controls complete.

### Tests run
- `dart run tool\generate_geometry_protocol_fixtures.dart`:
  - Passed; updated protocol fixtures.
- `dart format lib\ui\shell\workspace_shell.dart lib\selection\project_selection_resolver.dart lib\validation\project_semantic_validator.dart test\geometry_protocol_test.dart test\occt_native_target_scaffold_test.dart test\widget_test.dart test\project_selection_resolver_test.dart tool\native_occt_worker_metrics_smoke.dart tool\generate_geometry_protocol_fixtures.dart`:
  - Passed.
- `flutter test test\geometry_protocol_test.dart test\project_selection_resolver_test.dart test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 23 tests.
- `flutter test test\widget_test.dart --plain-name "selected button group inspector edits pattern through undo" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group" --reporter compact`:
  - Passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; default sample still reports 9502 vertices, 10136 triangles,
    `nativeButtonRingCount=2`, and
    `nativeGeneratedLidButtonRingCount=4`.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed a CRLF/LF normalization warning for `ROADMAP.md`
    only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic geometry and ring metrics with
    semantic ring defaults.
- Serialization checked?
  - Yes. Protocol fixture tests, project JSON save tests, and full tests
    passed.
- UI checked?
  - Yes. Widget tests cover inspector editing, undo, and component-sourced
    button group creation with ring defaults.
- Export checked?
  - No. STEP/STL export is still future work.

### Known issues
- Issue:
  - Ring controls are first-pass numeric parameters only; no shape/chamfer or
    texture style controls yet.
  - Severity: Low.
  - Next action: Continue toward button cap/plunger semantics before adding
    richer ring styling.

### Next step
Start the first safe cap/plunger planning or skeleton slice: cap/plunger
semantic fields, validation, and native generation boundaries before making
real moving-button geometry.

### Notes for future Codex sessions
`ringWidth` and `ringProtrusion` live in `FeatureGroup.itemPrototype` and are
copied into every button item intent. Native defaults still match the M85
geometry so existing projects without these fields remain compatible.

---

## 2026-06-30 - M85 Native button rings

### Goal
Generate first-pass native button rings/bezels around semantic front-wall and
top-lid button holes while keeping `button_group` as the editable source of
truth.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/16_BUTTON_AND_PLUNGER_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added shared button-ring sizing helpers.
  - Builds annular front-wall button rings and generated top-lid button rings
    from OCCT cylinders.
  - Fuses rings after their matching button holes are cut.
  - Maps ring faces back to the same semantic button group ids as the holes.
  - Emits `nativeButtonRingCount` and
    `nativeGeneratedLidButtonRingCount`.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 9502 vertices, 10136
    triangles, 14 mappings, 16684 mapped triangles, bounds
    `[-60, -35.45, 0]` through `[60, 35, 30.8]`, surface area
    `54964.596483`, and volume `52901.661268`.
  - Added assertions and summary output for front and top-lid button-ring
    metrics.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for ring builders, classifiers, helpers,
    and response metrics.
- Docs/tasks/roadmap:
  - Recorded M85, OCCT ring-generation notes, current native metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeButtonRingCount=2`,
    `nativeGeneratedLidButtonRingCount=4`, 14 preview mappings, and 16684
    mapped triangles.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, ring metrics,
    semantic preview mappings, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; rings are generated from semantic
    `button_group` data and are not stored as editable solids.
- UI checked?
  - Latest Windows bundle was rebuilt for manual inspection.
- Export checked?
  - No. STEP/STL export is still future work.

### Known issues
- Issue:
  - Ring width/protrusion are generator constants, not editable UX parameters.
  - Severity: Low for the current slice.
  - Next action: Add ring/bezel style parameters after button cap/plunger
    semantics are clearer.

### Next step
Continue toward the next button/plunger slice: either generated cap/plunger
planning or ring style controls, depending on what manual inspection shows.

### Notes for future Codex sessions
Button-ring counts are separate from `nativeFeatureCutCount` because rings are
positive generated geometry rather than additional cut operations.

---

## 2026-06-30 - M84 Native front glass ledge window

### Goal
Use semantic `ledgeWidth` for front-wall glass recesses so the generated front
wall has a shallow outer seat plus an inner through-window, leaving a support
ledge without splitting the editable feature.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepFilletAPI_MakeFillet.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Adds `BuildGlassWindowTool` for front-wall glass recesses.
  - Cuts a shallow front-wall glass seat first, then cuts a rounded inner
    through-window from `width - ledgeWidth * 2` and
    `height - ledgeWidth * 2`.
  - Keeps front glass window preview faces mapped to the original semantic
    feature id, such as `front_glass_recess`.
  - Emits `nativeGlassWindowCount` and
    `nativeGlassWindowFilletedEdgeCount`.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 7750 vertices, 8408
    triangles, 14 mappings, 12218 mapped triangles, surface area
    `54840.754901`, and volume `52827.356314`.
  - Added assertions and summary output for front glass-window metrics.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for the front-wall glass window tool and
    response metrics.
- Docs/tasks/roadmap:
  - Recorded M84, OCCT box/fillet/cut research, current native metrics, and
    the manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeFeatureCutCount=9`,
    `nativeGlassRecessCount=1`, `nativeGlassRecessFilletedEdgeCount=8`,
    `nativeGlassWindowCount=1`, `nativeGlassWindowFilletedEdgeCount=8`, 14
    preview mappings, and `front_glass_recess`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, front glass window
    metrics, preview mappings, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; the front ledge/window remains generated from
    one semantic `glass_recess` feature.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL/DXF export remains planned.

### Known issues
- Issue: Protected islands inside glass recesses are not generated yet.
  - Severity: Expected next feature.
  - Next action: Add island semantics for buttons/screen areas before DXF
    export.
- Issue: Glass/acrylic contour export is still not available.
  - Severity: Planned export work.
  - Next action: Add DXF contour generation from the same semantic recess
    parameters.

### Next step
Commit and push M84, then continue toward protected islands inside recesses or
button cap/plunger generation.

### Notes for future Codex sessions
Keep front and top-lid glass windows tied to the same semantic `glass_recess`.
Do not expose generated windows as separate editable solids or raw
topology/triangle targets.

---

## 2026-06-30 - M83 Native top lid glass ledge window

### Goal
Use semantic `ledgeWidth` for top-lid glass recesses so the generated lid has
a shallow outer seat plus an inner through-window, leaving a support ledge
without splitting the editable feature.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepFilletAPI_MakeFillet.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Validates native `glass_recess.ledge_width` so it leaves a positive inner
    window.
  - Adds `BuildGeneratedTopLidGlassWindowTool`.
  - Cuts the shallow top-lid glass recess first, then cuts a rounded inner
    through-window from `width - ledgeWidth * 2` and
    `height - ledgeWidth * 2`.
  - Emits `nativeGeneratedLidGlassWindowCount` and
    `nativeGeneratedLidGlassWindowFilletedEdgeCount`.
  - Keeps preview mapping keyed by the original semantic feature id, such as
    `top_lid_glass_recess`.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 7574 vertices, 8244
    triangles, 14 mappings, 12054 mapped triangles, surface area
    `55079.184105`, and volume `52974.141690`.
  - Added assertions and summary output for generated-lid glass-window metrics.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for the generated top-lid glass window tool
    and response metrics.
- Docs/tasks/roadmap:
  - Recorded M83, OCCT box/fillet/cut research, current native metrics, and
    the manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidFeatureCutCount=6`,
    `nativeGeneratedLidGlassRecessCount=1`,
    `nativeGeneratedLidGlassRecessFilletedEdgeCount=8`,
    `nativeGeneratedLidGlassWindowCount=1`,
    `nativeGeneratedLidGlassWindowFilletedEdgeCount=8`, 14 preview mappings,
    and `top_lid_glass_recess`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, generated glass
    window metrics, preview mappings, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; the ledge/window remains generated from one
    semantic `glass_recess` feature.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL/DXF export remains planned.

### Known issues
- Issue: The ledge/window slice applies to generated top-lid glass recesses;
  front-wall glass recesses are still shallow recesses only.
  - Severity: Expected scoped slice.
  - Next action: Add front-wall/window semantics only after panel opening rules
    are explicit.
- Issue: Protected islands inside glass recesses are not generated yet.
  - Severity: Expected next feature.
  - Next action: Add island semantics for buttons/screen areas before DXF
    export.

### Next step
Commit and push M83, then continue toward protected islands inside recesses or
button cap/plunger generation.

### Notes for future Codex sessions
Keep the generated glass window tied to the same semantic `glass_recess`.
Do not expose the generated inner window as a separate editable solid or raw
topology/triangle target.

---

## 2026-06-30 - M82 Native top lid glass recess

### Goal
Generate a first shallow rounded glass/insert recess in the generated
`top_screw_lid` preview lid when a semantic `glass_recess` targets
`main_enclosure.top_lid.outer`, while keeping the editable project semantic.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepFilletAPI_MakeFillet.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses `glass_recess` intents targeting both front wall and top lid.
  - Keeps front-wall recesses in the body feature-cut path.
  - Routes top-lid recesses through the generated lid plate path.
  - Cuts shallow rounded rectangular recess tools into the generated lid plate.
  - Emits generated-lid glass-recess metrics.
  - Maps top-lid recess faces by semantic feature id, such as
    `top_lid_glass_recess`.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Added a `top_lid_glass_recess` semantic feature to the native smoke
    project.
  - Updated deterministic native expectations to 7398 vertices, 8080
    triangles, 14 mappings, 11604 mapped triangles, surface area
    `55361.470831`, and volume `53224.939925`.
  - Added assertions and summary output for generated-lid glass-recess metrics.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for top-lid glass recess parsing, cut tool,
    classifier, metrics, smoke expectations, and semantic preview mapping.
- Docs/tasks/roadmap:
  - Recorded M82, OCCT box/fillet/cut research, current native metrics, and
    the manual poke checklist.

### Tests run
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format test\occt_native_target_scaffold_test.dart`:
  - Passed; formatted the updated scaffold test.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed after formatting.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidFeatureCutCount=5`,
    `nativeGeneratedLidGlassRecessCount=1`,
    `nativeGeneratedLidGlassRecessFilletedEdgeCount=8`,
    `nativeGeneratedLidButtonGroupCount=1`,
    `nativeGeneratedLidButtonCutoutCount=4`, 14 preview mappings, and
    `top_lid_glass_recess`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, top-lid glass
    recess metrics, preview mappings, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; the recess remains a semantic feature and
    generated B-Rep/topology is not saved as editable project state.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL/DXF export remains planned.

### Known issues
- Issue: Top-lid glass recesses are shallow generated recess cuts only; no
  protected islands, glass/acrylic contour export, or retaining lip semantics
  are generated yet.
  - Severity: Expected first native slice.
  - Next action: Add insert/glass semantics and DXF/acrylic contour generation
    after the lid/body split is more explicit.
- Issue: The lid is still a generated fit-preview member, not a real editable
  assembly component.
  - Severity: Expected current architecture boundary.
  - Next action: Add real lid/body assembly semantics before exposing generated
    lid parts as independently inspectable objects.

### Next step
Commit and push M82, then continue toward protected recess/insert semantics or
button cap/plunger geometry.

### Notes for future Codex sessions
Keep top-lid glass recesses routed by semantic `targetSurface`. Do not flatten
the recess into editable generated lid solids, raw OCCT topology IDs, or
preview triangle IDs.

---

## 2026-06-30 - M81 Native top lid button cutouts

### Goal
Generate first native circular button holes through the generated
`top_screw_lid` preview lid when a semantic `button_group` targets
`main_enclosure.top_lid.outer`, while keeping the group as one editable
semantic object.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses `button_group` intents targeting both front wall and top lid.
  - Keeps front-wall button holes in the body feature-cut path.
  - Routes top-lid button holes through the generated lid plate path.
  - Cuts vertical cylinder tools through the generated lid plate.
  - Emits generated-lid feature/button metrics.
  - Maps top-lid button hole faces by the semantic group id, such as
    `top_lid_buttons`.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Added a `top_lid_buttons` semantic `FeatureGroup` to the native smoke
    project.
  - Updated deterministic native expectations to 7222 vertices, 7920
    triangles, 13 mappings, 11166 mapped triangles, surface area
    `55325.131008`, and volume `53366.879754`.
  - Added assertions and summary output for generated-lid button metrics.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for top-lid button parsing, cut tool,
    classifier, metrics, smoke expectations, and semantic preview mapping.
- Docs/tasks/roadmap:
  - Recorded M81, OCCT cylinder-cut research, current native metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidFeatureCutCount=4`,
    `nativeGeneratedLidButtonGroupCount=1`,
    `nativeGeneratedLidButtonCutoutCount=4`, 13 preview mappings, and
    `top_lid_buttons`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, top-lid button
    metrics, preview mappings, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; top-lid button holes are derived from a
    semantic group and are not saved as generated B-Rep or per-hole geometry.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: Top-lid button holes are simple through-holes only; no cap, plunger,
  travel stop, or guide geometry is generated yet.
  - Severity: Expected first native slice.
  - Next action: Add button cap/plunger generation after hole placement is
    stable.
- Issue: Top-lid glass recess support is still pending.
  - Severity: Expected next-slice limitation.
  - Next action: Add generated lid glass recess once lid recess depth/ledge
    rules are explicit.

### Next step
Commit and push M81, then continue toward top-lid glass recesses or button
cap/plunger semantics.

### Notes for future Codex sessions
Keep top-lid buttons routed by semantic `targetSurface`. Do not flatten the
group into per-hole editable objects or persist generated lid B-Rep, OCCT
topology IDs, or preview triangle IDs.

---

## 2026-06-30 - M80 Native top lid fit preview

### Goal
Move the generated `top_screw_lid` from a high exploded preview into a clearer
fit-preview position so the locating lip visually enters the body-side seat
while keeping the result disposable generated geometry.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added deterministic helpers for generated lid lip height and fit-preview
    gap.
  - Decoupled lip height from the previous exploded preview gap.
  - Positions the generated top lid with a sample fit-preview gap of `0.35 mm`.
  - Emits `nativeGeneratedLidFitPreviewGap`.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated native preview bounds to `[-60, -35, 0]` through
    `[60, 35, 30.35]`.
  - Added assertion and summary output for
    `nativeGeneratedLidFitPreviewGap == 0.35`.
  - Updated deterministic dimensions, mapped triangle summary, and volume
    expectation.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for the fit-preview helpers and metric.
- Docs/tasks/roadmap:
  - Recorded M80, current metrics, generated-output boundary, and manual poke
    checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports 6638 vertices, 7328 triangles, 12 preview mappings,
    9694 mapped triangles, `nativeGeneratedLidFitPreviewGap=0.35`, bounds
    `[-60, -35, 0]` to `[60, 35, 30.35]`, surface area `55400.529232`, and
    volume `53593.074428`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Initially reported one unformatted file after smoke edits; after
    `dart format tool\native_occt_worker_metrics_smoke.dart`, passed with 0
    files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, fit-preview gap,
    bounds, dimensions, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; lid positioning is generated preview output
    and is not saved into `ProjectModel`.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: The generated lid is still a preview compound member, not an editable
  separable assembly part.
  - Severity: Expected architecture boundary.
  - Next action: Add explicit lid/body assembly semantics before true closed
    lid state or part-level selection.
- Issue: Top-lid features are still not targeted to the generated lid.
  - Severity: Expected next-slice limitation.
  - Next action: Add lid/body targeting before cutting top-lid buttons or glass
    recesses.

### Next step
Commit and push M80, then continue toward explicit lid/body targeting or
top-lid feature support.

### Notes for future Codex sessions
`nativeGeneratedLidFitPreviewGap` is a generated-output metric. Do not persist
fit-preview positioning, generated lid B-Rep, OCCT topology IDs, or triangle
IDs in the editable project model.

---

## 2026-06-30 - M79 Native top lid body seat

### Goal
Cut the first native body-side locating seat/groove around the top opening so
the generated `top_screw_lid` locating lip has matching body detail while
remaining generated output.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `GeneratedLidSeatRequest` derived from semantic lid data, wall
    thickness, locating lip width, clearance, and lip height.
  - Cuts four shallow rectangular seat tools around the top inner wall band
    after normal feature cuts and before preview assembly.
  - Validates the body after each seat cut with `BRepCheck_Analyzer`.
  - Emits `nativeGeneratedLidSeatCount`.
  - Maps `main_enclosure.generated_top_lid_seat` as disposable preview output.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 6638 vertices, 7328
    triangles, 12 mappings, 8088 mapped triangles, surface area
    `55400.529232`, and volume `53593.074426`.
  - Added assertions and summary output for `nativeGeneratedLidSeatCount == 1`
    and `main_enclosure.generated_top_lid_seat`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for the lid seat request, cut tools,
    application function, face-range classifier, metric, and smoke contract.
- Docs/tasks/roadmap:
  - Recorded M79, OCCT box-cut research, current native metrics, and the manual
    poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidSeatCount=1`, 12 preview mappings, and
    `main_enclosure.generated_top_lid_seat`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed; returned `True`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, generated body lid
    seat count, preview assembly bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; the body seat is derived from semantic lid
    data and is not saved as editable generated geometry.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: The preview lid still floats above the body; the seat/lip relationship
  is visible but not a fully positioned separable assembly.
  - Severity: Expected geometry-slice limitation.
  - Next action: Lower/position the generated lid or add a true lid/body split
    when fit rules are explicit.
- Issue: Seat edges are first-pass box-cut geometry without final printable
  chamfers/fillets.
  - Severity: Expected geometry polish gap.
  - Next action: Add lid-specific edge treatment after the lip/seat workflow is
    stable.

### Next step
Commit and push M79, then continue toward clearer lid/body fit positioning or
top-lid feature targeting.

### Notes for future Codex sessions
Keep `main_enclosure.generated_top_lid_seat` as disposable preview metadata.
Do not persist generated seat B-Rep, OCCT topology IDs, triangle IDs, or
editable groove solids in the semantic project model.

---

## 2026-06-30 - M78 Native top lid locating lip

### Goal
Add the first native underside locating lip to the generated `top_screw_lid`
preview plate so the lid starts to express mating geometry without adding
editable generated solids.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Fuse.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added generated top lid locating-lip parameters derived from enclosure wall
    thickness, preview gap, and fit clearance.
  - Builds a rounded rectangular ring under the generated top lid plate by
    cutting an inner rounded tool from an outer rounded lip body.
  - Fuses the lip into the generated lid plate before screw clearance holes are
    cut.
  - Emits `nativeGeneratedLidLipCount` and maps
    `main_enclosure.generated_top_lid_locating_lip` as disposable preview
    output.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 6536 vertices, 7292
    triangles, 11 mappings, 7464 mapped triangles, surface area
    `55923.058137`, and volume `53855.327909`.
  - Added assertion for `nativeGeneratedLidLipCount == 1`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for the locating lip builder, metric, smoke
    expectation, and semantic preview mapping.
- Docs/tasks/roadmap:
  - Recorded M78, OCCT ring cut/fuse research, current native metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidLipCount=1`,
    11 preview mappings, and
    `main_enclosure.generated_top_lid_locating_lip`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, generated lid lip
    count, preview assembly bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; lip geometry is derived from semantic lid data
    and is not saved as editable project geometry.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: The locating lip is preview-generated only; the body still does not
  have a real matching groove/seat.
  - Severity: Expected first-slice mating limitation.
  - Next action: Add body-side seat/groove or lower the lid into a true mating
    split once fit clearance rules are explicit.
- Issue: Lip edges are basic rounded-box output, not final printable
  chamfer/fillet treatment.
  - Severity: Expected geometry polish gap.
  - Next action: Add lid-specific fillets/chamfers after the mating workflow is
    stable.

### Next step
Commit and push M78.

### Notes for future Codex sessions
Keep `main_enclosure.generated_top_lid_locating_lip` as disposable preview
metadata. Do not persist generated lip B-Rep, OCCT topology IDs, or triangle
IDs in the semantic project model.

---

## 2026-06-30 - M77 Native top lid screw holes

### Goal
Cut first native screw clearance holes through the generated `top_screw_lid`
preview plate, aligned to generated screw bosses, without adding editable
per-hole solids or exposing raw OCCT topology.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `generated_top_lid_screw_holes` semantic preview id.
  - Cuts four generated screw clearance holes through the top lid preview plate
    using vertical cylinder tools aligned to the generated lid screw bosses.
  - Emits `nativeGeneratedLidScrewHoleCount`.
  - Maps `main_enclosure.generated_top_lid_screw_holes` as disposable preview
    output.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 5606 vertices, 6166
    triangles, 10 mappings, 5102 mapped triangles, surface area
    `55084.250536`, and volume `53265.079307`.
  - Added assertion for `nativeGeneratedLidScrewHoleCount == 4`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for lid screw hole tool generation, metrics,
    surface mapping, and smoke expectations.
- Docs/tasks/roadmap:
  - Recorded M77, OCCT cylinder-cut research, current native metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidScrewHoleCount=4`,
    10 preview mappings, and
    `main_enclosure.generated_top_lid_screw_holes`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, generated lid screw
    hole count, preview assembly bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; holes are derived from semantic lid/boss data
    and are not saved as editable geometry.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: Lid holes are simple through-clearance holes without countersinks,
  screw-head recesses, or user-facing screw-size profiles.
  - Severity: Expected first-slice limit.
  - Next action: Add screw profile parameters after lid/boss workflow is more
    explicit.
- Issue: The lid plate is still preview-separated above the body, not a real
  mating lid with lips/grooves.
  - Severity: Expected architecture gap.
  - Next action: Add real mating lid/body split geometry.

### Next step
Commit and push M77.

### Notes for future Codex sessions
Keep generated top lid screw holes derived from semantic `Enclosure.lid` and
boss positions. Do not persist generated hole solids, OCCT topology IDs, or
triangle IDs in the project model.

---

## 2026-06-30 - M76 Native top lid plate preview

### Goal
Add the first separate native preview lid plate for semantic
`top_screw_lid` enclosures while keeping generated B-Rep out of editable
project state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRep_Builder.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/TopoDS_Compound.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/TopoDS_Builder.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `GeneratedLidPlateRequest` derived from semantic
    `Enclosure.lid.type == top_screw_lid`.
  - Builds a rounded generated top lid preview plate above the top-open body.
  - Assembles body plus lid plate with `BRep_Builder` and `TopoDS_Compound`
    after feature cuts.
  - Emits `nativeGeneratedLidPlateCount` and maps
    `main_enclosure.generated_top_lid` as disposable preview output.
  - Keeps body wall mappings from being polluted by generated lid side faces.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic expectations to 5022 vertices, 5574 triangles,
    9 mappings, 3782 mapped triangles, bounds `[60, 35, 32]`, surface area
    `55068.165581`, and volume `53329.419133`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for generated lid plate requests, compound
    assembly, metric emission, and smoke expectations.
- Docs/tasks/roadmap:
  - Recorded M76, OCCT compound research, current native metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeGeneratedLidPlateCount=1`,
    9 preview mappings, and `main_enclosure.generated_top_lid`.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format tool\native_occt_worker_metrics_smoke.dart`:
  - Formatted one Dart file.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting; 0 files changed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed; Git printed CRLF/LF normalization warnings for existing markdown
    line endings only.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, preview assembly
    bounds, generated lid metric, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; generated lid plate is derived from semantic
    lid metadata and not saved as generated geometry.
- UI checked?
  - Not manually in this session. Latest exe was rebuilt for user poke testing.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: The top lid plate is a preview assembly member, not a real mating lid
  with screw holes, lip/groove, or clearance rules.
  - Severity: Expected first-slice limit.
  - Next action: Turn the preview plate into a real lid/body split.
- Issue: The preview lid uses simple rounded-box generation.
  - Severity: Expected visual/geometry simplification.
  - Next action: Add lid-specific edge treatment and screw-hole alignment after
    split mechanics are explicit.

### Next step
Commit and push M76.

### Notes for future Codex sessions
Keep `main_enclosure.generated_top_lid` as disposable preview metadata. Do not
save generated lid plate B-Rep, OCCT topology IDs, or triangle IDs into the
semantic project model.

---

## 2026-06-30 - M75 Native top screw lid bosses

### Goal
Generate first native screw bosses for semantic `top_screw_lid` enclosures
without adding editable solids or exposing low-level CAD operations.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/10_ENCLOSURE_AUTO_GENERATION.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`lib/project/enclosure.dart`, `occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Fuse.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses `Enclosure.lid.type` from the semantic project request.
  - Generates four default screw-boss positions for `top_screw_lid` enclosures
    from inner enclosure dimensions.
  - Builds cylindrical bosses with pilot holes and fuses them into the native
    shell before feature cutouts and mount groups.
  - Emits `nativeLidScrewBossCount`, `nativeLidScrewPilotCount`, and a
    disposable `main_enclosure.lid_screw_bosses` preview mapping.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic native expectations to 4222 vertices, 4514
    triangles, 8 mappings, 2820 mapped triangles, surface area `37838.594851`,
    and volume `36692.568707`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract coverage for lid screw boss parsing, generation,
    metrics, preview mapping, and smoke expectations.
- Docs/tasks/roadmap:
  - Recorded M75, OCCT screw-boss research, current smoke metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeLidScrewBossCount=4`,
    `nativeLidScrewPilotCount=4`, and
    `main_enclosure.lid_screw_bosses` preview mapping.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies deterministic mesh counts, lid boss metrics,
    bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; lid bosses are generated from existing
    semantic lid metadata, not saved generated geometry.
- UI checked?
  - No separate UI test was needed; this slice adds generated native enclosure
    detail from existing lid state.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: Screw bosses are generated defaults, not user-parameterized yet.
  - Severity: Expected first-slice limit.
  - Next action: Add user-facing boss parameters after lid/body workflow is
    richer.
- Issue: The body is still a top-open shell, not a separable lid/body assembly.
  - Severity: Expected architecture gap.
  - Next action: Add a real lid/body split as a later native geometry slice.

### Next step
Commit and push M75.

### Notes for future Codex sessions
Keep lid screw bosses generated from semantic `Enclosure.lid` metadata. Do not
save per-boss editable solids, OCCT topology IDs, or preview triangle IDs into
the project model.

---

## 2026-06-30 - M74 Native bottom standoff mounts

### Goal
Consume bottom-inside `standoff_mounts` feature-group intents in native OCCT and
generate simple cylindrical screw standoffs while keeping the mount set one
editable semantic object.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`lib/geometry/geometry_protocol.dart`, `lib/patterns/pattern_layout.dart`,
`lib/validation/project_semantic_validator.dart`,
`lib/ui/shell/workspace_shell.dart`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Fuse.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/occt_native_target_scaffold_test.dart`, and `test/widget_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added native parsing for bottom-inside `standoff_mounts` feature-group
    intents and derived mounting-hole item positions.
  - Builds generated cylindrical boss shapes with central blind holes.
  - Fuses standoff bosses into the top-open enclosure shell with
    `BRepAlgoAPI_Fuse`.
  - Emits native standoff metrics and one disposable preview mapping keyed by
    the standoff group id.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Adds a sample `standoff_mounts_1` group from the button-board mounting
    holes.
  - Updated deterministic native expectations to 3054 vertices, 3362
    triangles, 7 mappings, 1956 mapped triangles, surface area `35121.745524`,
    and volume `33568.192004`.
- `test/occt_native_target_scaffold_test.dart` and `test/widget_test.dart`:
  - Added source-contract coverage for standoff parsing/generation/metrics and
    widget coverage for selected standoff group preview highlighting.
- Docs/tasks/roadmap:
  - Recorded M74, OCCT fuse/standoff research, current smoke metrics, and the
    manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeStandoffGroupCount=1`,
    `nativeStandoffMountCount=4`, and `standoff_mounts_1` preview mapping.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter test test\widget_test.dart --plain-name "selected standoff group highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 187 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed with CRLF normalization warnings for existing text files.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies shape validity, deterministic mesh counts,
    standoff metrics, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; standoffs remain semantic feature groups, not
    saved generated geometry.
- UI checked?
  - Yes. Widget coverage verifies selecting a standoff group can activate the
    mapped preview highlight.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: Native standoff mounts are bottom-inside only in this slice.
  - Severity: Expected scope limit.
  - Next action: Add mount variants after richer target-surface/body-lid
    mapping.
- Issue: Standoff bases are simple cylinders without fillets/chamfers.
  - Severity: Polish/future printability improvement.
  - Next action: Add base fillets/chamfers after the first boss path is stable.

### Next step
Continue toward lid/body split, standoff polish, or export.

### Notes for future Codex sessions
Keep standoff bosses generated from the semantic group. Do not save per-boss
editable solids, OCCT topology IDs, or preview triangle IDs into the project
model.

---

## 2026-06-30 - M73 Native front button group cutouts

### Goal
Consume front-wall `button_group` feature-group intents in native OCCT and
generate circular button cutouts while keeping the group one editable semantic
object.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`lib/geometry/geometry_protocol.dart`, `lib/patterns/pattern_layout.dart`,
`lib/ui/shell/workspace_shell.dart`,
`occt_worker/native/src/occt_main.cpp`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`,
`occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/gp_Ax2.hxx`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/occt_native_target_scaffold_test.dart`, and `test/widget_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added native parsing for front-wall `button_group` feature intents and
    derived item positions.
  - Builds cylindrical cut tools with `BRepPrimAPI_MakeCylinder` and subtracts
    one generated cut per button item.
  - Tracks semantic group support separately from physical cut operations with
    `nativeButtonGroupCount` and `nativeButtonCutoutCount`.
  - Emits one disposable preview mapping keyed by the group id, such as
    `front_buttons`.
- `lib/ui/shell/workspace_shell.dart`:
  - Allows selected `FeatureGroup` objects to use preview mesh triangle ranges
    for display-only highlighting.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Adds a sample front-wall button group with two circular button cutouts.
  - Updated deterministic native expectations to 1886 vertices, 2210
    triangles, 6 mappings, 1092 mapped triangles, surface area `34759.83405`,
    and volume `33314.853997`.
- `test/occt_native_target_scaffold_test.dart` and `test/widget_test.dart`:
  - Added source-contract coverage for the button-group native slice and a
    widget test for selected feature-group preview range highlighting.
- Docs/tasks/roadmap:
  - Recorded M73, the OCCT cylinder research note, current smoke metrics, and
    the manual poke checklist.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; reports `nativeButtonGroupCount=1`,
    `nativeButtonCutoutCount=2`, and `front_buttons` preview mapping.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter test test\widget_test.dart --plain-name "selected feature group highlights mapped preview mesh range" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 186 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed with CRLF normalization warnings for existing text files.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies shape validity, deterministic mesh counts,
    button-group metrics, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; button groups remain semantic feature groups,
    not saved generated geometry.
- UI checked?
  - Yes. Widget coverage verifies selecting a feature group can activate the
    mapped preview highlight.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: Native button cutouts are front-wall only in this slice.
  - Severity: Expected scope limit.
  - Next action: Add top-lid button support after generated lid/body split.

### Next step
Continue toward the next native generation slice: standoff/mount geometry,
screw-boss/lid-body split, or richer generated face mapping.

### Notes for future Codex sessions
Keep button holes generated from the semantic group. Do not save per-hole
editable objects, OCCT topology IDs, or preview triangle IDs into the project
model.

---

## 2026-06-30 - M72 Native front glass recess slice

### Goal
Consume a first `glass_recess` semantic feature intent on the front wall and
generate a shallow rounded recess in native OCCT B-Rep.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_operation_plan.dart`,
`lib/project/project_model.dart`, `lib/ui/shell/workspace_shell.dart`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added `GlassRecessRequest` parsing for `glass_recess` feature intents.
  - Supports front-wall recesses with width, height, recess depth, ledge width,
    corner radius, and optional `placement.surfacePosition`.
  - Builds a shallow rounded rectangular recess tool and subtracts it with
    `BRepAlgoAPI_Cut`.
  - Validates cut results with `BRepCheck_Analyzer`.
  - Emits native glass-recess metrics and `front_glass_recess` preview ranges.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Uses a smoke project with a sample front-wall glass recess.
  - Updated deterministic counts to 1594 vertices, 1914 triangles, 5 mappings,
    796 mapped triangles, surface area `34797.533162`, and volume
    `33427.951321`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract checks for glass recess parsing, native generation,
    metrics, and smoke expectations.
- Docs/tasks/roadmap:
  - Recorded M72 and clarified that this slice supports front-wall shallow
    recesses only; top-lid glass recess waits for real lid/body geometry.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports one USB-C cut, one front glass recess, and one
    ignored unsupported button intent.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 185 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed with CRLF normalization warnings for existing text files.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies shape validity, deterministic mesh counts,
    native glass metrics, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; glass recesses remain semantic feature
    intents, not saved generated geometry.
- UI checked?
  - Yes. Existing UI tests passed and the latest native app bundle was rebuilt.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: Native glass recess support is front-wall only in this slice.
  - Severity: Expected scope limit.
  - Next action: Add top-lid recess support after generated lid/body split.

### Next step
Continue with the next native feature-generation slice, likely semantic button
cutouts or early lid/body geometry needed for top-lid recesses.

### Notes for future Codex sessions
Do not treat `front_glass_recess` preview ranges as editable topology. They are
display-only output from the native worker.

---

## 2026-06-30 - M71 Native USB-C feature range highlight

### Goal
Expose the generated USB-C cutout as a disposable native preview range and let
the viewport highlight `front_usb_c` when the semantic feature is selected.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Split body surface classification from generated feature range
    classification.
  - Added a USB-C cutout face-range classifier that maps faces inside the
    opening while leaving the full front wall mapped to
    `main_enclosure.front_wall.outer`.
  - Emits `front_usb_c` as an additional disposable preview surface mapping.
- `lib/ui/shell/workspace_shell.dart`:
  - Allows selected semantic features to use preview mesh triangle ranges for
    display-only highlighting.
- `test/widget_test.dart`:
  - Added fake preview mesh coverage and a widget test for selected feature
    highlight activation.
- `tool/native_occt_worker_metrics_smoke.dart` and
  `test/occt_native_target_scaffold_test.dart`:
  - Updated the native contract to expect 4 preview mappings: top, front,
    bottom, and `front_usb_c`.
- Docs/tasks/roadmap:
  - Recorded M71 and clarified that feature preview ranges are disposable
    geometry output, not editable project state.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports 1418 vertices, 1754 triangles, 4 mappings, and 636
    mapped triangles.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter test test\widget_test.dart --plain-name "selected feature highlights mapped preview mesh range" --reporter compact`:
  - Passed after rerunning without a parallel Flutter startup lock.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting `lib/ui/shell/workspace_shell.dart`.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 185 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed with CRLF normalization warnings for existing text files.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies the USB-C cut remains valid and now emits the
    additional `front_usb_c` range.
- Serialization checked?
  - Yes. Full test suite passed; preview ranges remain generated response data,
    not editable project state.
- UI checked?
  - Yes. Widget coverage verifies selected feature range highlighting.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue: The USB-C preview range is still face-range based, not exact edge-loop
  highlighting.
  - Severity: Low for this slice.
  - Next action: Improve mapping precision alongside richer generated feature
    geometry and real viewport picking.

### Next step
Continue to the next native feature-generation slice: likely button-group or
glass-recess B-Rep generation, still through semantic feature intents.

### Notes for future Codex sessions
`front_usb_c` preview ranges are display-only. Do not use them for semantic
editing, saved project references, or native topology coupling.

---

## 2026-06-29 - M70 Native USB-C cutout slice

### Goal
Consume the first native `usb_c_cutout` feature intent and subtract a rounded
front-wall USB-C opening from the generated OCCT shell.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/33_COMPONENT_FEATURE_PROJECTION.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `occt_worker/README.md`,
`occt_worker/protocol/preview_request.example.json`,
`lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_operation_plan.dart`,
`lib/validation/project_semantic_validator.dart`,
`occt_worker/native/src/occt_main.cpp`, and
`tool/native_occt_worker_metrics_smoke.dart`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses top-level `featureIntents` and supports first-pass negative
    `usb_c_cutout` intents on `main_enclosure.front_wall.outer`.
  - Reads width, height, corner radius, and optional
    `placement.surfacePosition`.
  - Builds a rounded rectangular cut tool and subtracts it from the generated
    shell using `BRepAlgoAPI_Cut`.
  - Validates the cut result with `BRepCheck_Analyzer`.
  - Emits feature-cut metrics for total intents, applied native cuts, ignored
    unsupported intents, USB-C cuts, and USB-C cut-tool filleted edges.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic sample expectations to 1418 vertices, 1754
    triangles, 3 surface mappings, 538 mapped triangles, surface area
    `34732.966792`, and volume `33664.517631`.
  - Verifies `featureIntentCount=2`, `nativeFeatureCutCount=1`,
    `nativeIgnoredFeatureIntentCount=1`, `nativeUsbCCutoutCount=1`, and
    `nativeUsbCCutoutFilletedEdgeCount=8`.
- `test/occt_native_target_scaffold_test.dart`:
  - Added source-contract checks for USB-C intent parsing, cut generation, and
    native feature-cut metrics.
- Docs/tasks/roadmap:
  - Marked side-wall port cutouts as implemented for the first USB-C slice.
  - Added M70 roadmap details and poke checklist.
  - Updated architecture/geometry/worker docs so USB-C is no longer described
    as future-only planning data.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed after fixing an MSVC `/WX` shadowing warning.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports one native USB-C cut and one ignored button intent.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 184 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies the USB-C cut, deterministic mesh counts,
    feature-cut metrics, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Full test suite passed; feature intents remain request-scoped and are
    not editable project state.
- UI checked?
  - Automated widget coverage passed; latest native OCCT bundle was rebuilt for
    manual launch.
- Export checked?
  - No. STEP/STL export remains planned.

### Known issues
- Issue:
  - Only front-wall USB-C cutouts are generated natively. Button groups, glass
    recesses, standoffs, and other feature intents are still ignored by native
    geometry.
  - Severity: Medium for MVP geometry.
  - Next action: Implement the next native feature slice, likely button-group
    top/lid cutouts or standoff/mount geometry.
- Issue:
  - Manual `front_usb_c` features without `surfacePosition` use a first-pass
    default front-wall position near the board/port area.
  - Severity: Low; semantic placement polish remains a later UI task.
  - Next action: Add face-local placement/picking so manual USB-C features store
    explicit surface coordinates.

### Next step
Continue native feature generation with either button-group top cutouts or real
standoff geometry from component mounting-hole intents.

### Notes for future Codex sessions
Do not expose the USB-C cut tool or Boolean operation as default UX. It is a
generator-owned implementation detail behind `GeometryService`. Keep generated
B-Rep, OCCT topology IDs, and preview triangle IDs out of project JSON.

---

## 2026-06-29 - M69 Native shell/cavity slice

### Goal
Turn the native rounded enclosure preview from a closed solid block into the
first validated top-open shell/cavity generated from semantic wall thickness.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`, and official OCCT references for
`BRepOffsetAPI_MakeThickSolid` and `BRepAlgoAPI_Cut`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added a rounded cavity cut tool generated from semantic `wallThickness`.
  - Cuts the rounded outer body with `BRepAlgoAPI_Cut` to create a top-open
    shell/cavity.
  - Validates the resulting shell with `BRepCheck_Analyzer`.
  - Emits shell metrics: `shellCavityApplied`, `shellCavityValid`,
    `shellCavityToolCount`, and `shellOpening`.
  - Maps `main_enclosure.top_lid.outer` to the visible top rim because the
    original top face is now removed by the cavity generator.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated deterministic expectations to 1198 vertices, 1550 triangles, 3
    surface mappings, 494 mapped triangles, bounds ending at Z `27.464102`,
    surface area `34761.268581`, and volume `33756.044084`.
- `test/occt_native_target_scaffold_test.dart`:
  - Updated the source-contract checks for the shell preview generator and
    native cavity metrics.
- Docs/tasks/roadmap:
  - Marked shell/cavity generation complete.
  - Recorded the OCCT shell/cavity research decision.
  - Documented current shell metrics, top-rim mapping, and the next geometry
    tasks.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports `shellCavityValid: true`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with constraints.
- `flutter analyze`:
  - Passed; no issues found.
- `flutter test --reporter compact`:
  - Passed, 184 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `git diff --check`:
  - Passed with existing line-ending warnings for touched Markdown files.

### Validation
- Geometry checked?
  - Yes. Native smoke verifies a real top-open shell/cavity, valid OCCT shape
    check, deterministic mesh counts, bounds, surface area, and volume.
- Serialization checked?
  - Yes. Existing full test suite passed; editable project remains semantic
    JSON only.
- UI checked?
  - Automated widget coverage passed; latest native OCCT bundle was rebuilt for
    manual launch.
- Export checked?
  - No. STEP/STL export is still not implemented.

### Known issues
- Issue:
  - The first native shell uses the top rim as the `top_lid.outer` highlight
    target until the real lid/body split exists.
  - Severity: Low for current preview; expected transitional behavior.
  - Next action: Add explicit lid/body geometry and richer semantic face
    mapping after feature cutouts start landing.
- Issue:
  - Feature intents still do not cut the native B-Rep.
  - Severity: Medium for MVP geometry.
  - Next action: Start the first native feature cutout slice, likely USB-C.

### Next step
Implement the first feature-intent cut against the native shell, probably the
USB-C front cutout, with deterministic native smoke metrics.

### Notes for future Codex sessions
Do not switch Flutter to mesh/topology picking. Native preview triangle ranges
remain disposable highlight metadata only. The generated shell is valid and
local-only; no B-Rep, STL, OCCT topology ID, or release artifact should be
committed.

---

## 2026-06-29 - M68 Preview surface range highlight

### Goal
Use disposable preview surface ranges from `PreviewMesh.surfaces` to highlight
the selected semantic surface in the generated viewport mesh without adding
mesh picking or editable triangle IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`, and
`docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Resolves selected semantic surface IDs to preview mesh triangle ranges.
  - Tints/strokes selected mapped triangles during preview mesh painting.
  - Adds a hidden widget-test marker when a mapped preview surface highlight is
    active.
  - Keeps existing semantic hit testing, workplane overlays, and snap behavior
    unchanged.
- `test/widget_test.dart`:
  - Adds preview mesh surface mapping data to the fake geometry service.
  - Covers selected surface highlight activation while preserving the workplane
    overlay.
- Docs/tasks/roadmap:
  - Recorded M68 and clarified that preview ranges are used for display-only
    highlight, not mesh picking.

### Tests run
- `flutter test test\widget_test.dart --reporter compact`:
  - Passed, 46 widget tests.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 184 tests.
- `git diff --check`:
  - Passed; Git repeated an existing CRLF normalization warning for
    `ROADMAP.md`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt latest Windows app with native OCCT backend.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `preview_mesh_smoke` and first-pass semantic
    surface ranges.

### Validation
- Geometry checked?
  - No worker geometry changed in this slice; release worker capabilities were
    verified.
- Serialization checked?
  - Existing geometry protocol tests still cover surface mapping parsing.
- UI checked?
  - Widget coverage proves a selected semantic surface activates preview mesh
    range highlighting when a matching mapping exists.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Surface selection still uses existing semantic mock hit zones/browser,
  not generated mesh picking.
  - Severity: Expected.
  - Next action: Add explicit generated mesh picking only after stable semantic
    face mapping is stronger.
- Issue: Only mapped central planar ranges can be highlighted; curved fillets
  remain unhighlighted.
  - Severity: Expected.
  - Next action: Expand native semantic face mapping in a future geometry slice.

### Next step
Manual poke the latest build by selecting `Top lid` and checking that the
native preview mesh shows the mapped surface highlight while the workplane
overlay still appears.

### Notes for future Codex sessions
Preview surface ranges are display-only. Do not save triangle ranges into
`ProjectModel` and do not treat them as stable topology.

---

## 2026-06-29 - M67 Native preview surface ranges

### Goal
Add the first native semantic preview surface mappings so generated preview mesh
responses can identify top/front/bottom face ranges without making triangle
indices editable project IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/occt_native_target_scaffold_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/33_VIEWPORT_MVP.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`, `occt_worker/README.md`, and
`README.md`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Added preview surface mapping/range data structures.
  - Classified central planar top, front, and bottom face blocks from generated
    B-Rep bounds.
  - Emitted `PreviewSurfaceMapping` JSON with disposable triangle ranges.
  - Added mapping count and mapped triangle count metrics.
  - Updated native capabilities notes to mention first-pass semantic surface
    ranges.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Validates 3 semantic surface mappings for top lid, front wall, and bottom
    inside.
  - Validates positive triangle ranges within the emitted preview mesh.
  - Checks mapping metrics against parsed preview mesh ranges.
- Docs/tasks/roadmap:
  - Recorded M67 and clarified that only central planar face ranges are mapped;
    curved fillets remain unmapped.

### Tests run
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt native OCCT worker.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; sample reports 800 vertices, 1060 triangles, 3 surface mappings,
    and 6 mapped triangles.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 183 tests.
- `git diff --check`:
  - Passed; Git repeated existing CRLF normalization warnings for touched docs.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt latest Windows app and copied the rebuilt native worker.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `status=preview_mesh_smoke`, OCCT `8.0.0`,
    and notes first-pass semantic surface ranges.

### Validation
- Geometry checked?
  - Native worker smoke validates bounds, mesh counts, semantic surface IDs,
    triangle ranges, and mapping metrics.
- Serialization checked?
  - `PreviewMesh` protocol parsing of surface mappings remains covered by
    existing protocol tests; native smoke now exercises the native JSON path.
- UI checked?
  - Full widget suite passed. No new visible UI behavior is expected from this
    backend-only mapping slice.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Only central planar face blocks are mapped; curved fillets and richer
  side/back/left/right semantics are not mapped yet.
  - Severity: Expected.
  - Next action: Expand mapping after shell/cavity and face semantics are more
    explicit.
- Issue: Viewport still does not use preview surface ranges for picking or
  highlight.
  - Severity: Expected.
  - Next action: Add a separate UI selection/highlight slice after the backend
    contract is stable.

### Next step
Use the first-pass surface ranges in a later viewport highlight or semantic
face selection slice, or continue toward shell/cavity generation.

### Notes for future Codex sessions
`previewMesh.surfaces` is preview metadata only. Triangle ranges are disposable
and must not become saved project IDs or editable topology.

---

## 2026-06-29 - M66 Native preview mesh viewport

### Goal
Render the disposable `PreviewMesh` returned by the active geometry backend in
the Flutter viewport while keeping editing and picking semantic-first.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/geometry/geometry_service.dart`, `lib/geometry/geometry_protocol.dart`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/geometry_worker_service_test.dart`, `test/widget_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`, and
`README.md`.

### Changes made
- `lib/geometry/geometry_service.dart`:
  - Added optional `GeometryPreview.previewMesh`.
  - Passed worker/mock `GeometryResponse.previewMesh` through the app-facing
    preview DTO.
- `lib/ui/shell/workspace_shell.dart`:
  - Passed `previewMesh` into the viewport painter.
  - Added a faceted preview mesh painter path with bounds fallback, simple
    camera projection, depth sorting, and triangle shading.
  - Kept semantic overlays and hit testing separate from generated triangles.
  - Added a widget-test marker for active geometry preview mesh rendering.
- Tests:
  - Added worker service assertions that `preview.previewMesh` is preserved.
  - Added widget coverage proving a service-provided preview mesh activates the
    viewport mesh path.
- Docs/tasks/roadmap:
  - Recorded M66 and clarified that preview mesh rendering is display-only, not
    editable project state.

### Tests run
- `flutter test test\geometry_worker_service_test.dart test\widget_test.dart --reporter compact`:
  - Passed.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 183 tests.
- `git diff --check`:
  - Passed; Git repeated existing CRLF normalization warnings for touched docs.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; rebuilt latest Windows app with native OCCT backend.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `status=preview_mesh_smoke` and OCCT
    `8.0.0`.

### Validation
- Geometry checked?
  - The release-bundled worker can report native preview mesh capability.
- Serialization checked?
  - Existing protocol tests still pass, and worker service tests now prove the
    preview mesh survives the service adapter.
- UI checked?
  - Widget coverage confirms the viewport consumes a service-provided preview
    mesh. Manual poke is meaningful in the latest native build.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Viewport picking still uses deterministic semantic mock zones rather
  than generated triangle picking.
  - Severity: Expected for this slice.
  - Next action: Add stable semantic face mapping before any mesh/surface
    picking work.
- Issue: The mesh renderer is a CPU `CustomPaint` path.
  - Severity: Acceptable for the current 800-vertex / 1060-triangle native
    sample.
  - Next action: Revisit renderer options once larger generated meshes exist.

### Next step
Manual poke the latest native build, then continue toward either semantic face
mapping or the next real geometry generation slice.

### Notes for future Codex sessions
The viewport can now draw `GeometryPreview.previewMesh`, but generated vertices
and triangle indices remain display-only and must not become editable state.

---

## 2026-06-29 - M65 Native OCCT app backend wiring

### Goal
Make the Flutter app able to select the native OCCT worker as a bundled
developer backend without hard-coding project-local absolute paths.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/geometry/geometry_backend.dart`, `lib/geometry/geometry_service.dart`,
`lib/ui/shell/workspace_shell.dart`, `tools/build_latest_windows.ps1`,
`test/geometry_backend_test.dart`, `test/geometry_worker_service_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`README.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_backend.dart`:
  - Added `GeometryBackendKind.nativeOcct` with wire value `native_occt`.
  - Resolves the bundled native worker beside the app executable at
    `occt_worker/native/occt_worker_native_occt.exe`.
  - Falls back to `MockGeometryService` when the bundled worker is missing.
  - Keeps explicit executable overrides available for development.
- `tools/build_latest_windows.ps1`:
  - Added explicit `-NativeOcct` and `-SkipNativeOcctBuild` switches.
  - Builds Flutter with `SHELL_CASE_GEOMETRY_BACKEND=native_occt` when
    requested.
  - Copies the native worker release bundle under
    `releases/latest/windows/occt_worker/native`.
- Tests:
  - Added backend resolution coverage for `native_occt`.
  - Added build-script safety coverage for native worker bundling.
- Docs/tasks/roadmap:
  - Recorded the `native_occt` backend preset and explicit latest build flow.

### Tests run
- `flutter test test\geometry_backend_test.dart test\build_latest_windows_script_test.dart --reporter compact`:
  - Passed, 8 tests after fixing a Dart raw-string expectation.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed; built latest Windows app with the native OCCT backend define and
    copied the worker bundle.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `Test-Path releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe`:
  - Passed.
- `releases\latest\windows\occt_worker\native\occt_worker_native_occt.exe --capabilities`:
  - Passed; copied worker reports `status=preview_mesh_smoke` and OCCT
    `8.0.0`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 182 tests.

### Validation
- Geometry checked?
  - The copied native worker can run from the latest release folder and report
    capabilities. The app still needs a future rendering slice to draw native
    mesh vertices in the viewport.
- Serialization checked?
  - Backend setting parsing and process-client boundary remain covered by the
    existing geometry tests.
- UI checked?
  - Full widget suite passed. Manual poke is now meaningful: open the latest exe
    and confirm the viewport label reports `occt_worker_native_occt`.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The viewport painter still draws the schematic mock body even when the
  backend is native OCCT.
  - Severity: Expected.
  - Next action: Add a viewport rendering path that consumes `PreviewMesh`
    vertices/triangles.
- Issue: Semantic surface mapping for native preview mesh is still pending.
  - Severity: Expected.
  - Next action: Add stable semantic face mapping later without exposing OCCT
    topology IDs.

### Next step
Commit and push M65, then continue toward rendering native preview mesh
vertices in the Flutter viewport.

### Notes for future Codex sessions
The default `tools\build_latest_windows.ps1` path stays mock. Use
`tools\build_latest_windows.ps1 -NativeOcct` when the latest manual exe should
launch against the bundled native worker. Do not commit `releases/`, `build/`,
`external/`, `occt_worker/native/vcpkg_installed/`, or copied OCCT DLLs.

## 2026-06-29 - M64 First native preview mesh

### Goal
Emit the first disposable native OCCT preview mesh from the generated rounded
enclosure B-Rep while keeping editable project state semantic-only.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`,
`tool/native_occt_worker_metrics_smoke.dart`,
`test/occt_native_target_scaffold_test.dart`, `lib/geometry/geometry_protocol.dart`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`, `occt_worker/README.md`, and local
OCCT headers for `BRepMesh_IncrementalMesh`, `BRep_Tool::Triangulation`,
`Poly_Triangulation`, and `Poly_Triangle`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Meshes the generated rounded enclosure B-Rep with
    `BRepMesh_IncrementalMesh`.
  - Extracts face triangulations through `BRep_Tool::Triangulation`.
  - Emits `previewMesh` vertices, triangle indices, bounds, and mesh metadata.
  - Updates capability status to `preview_mesh_smoke`.
  - Keeps semantic surface mapping empty with explicit pending metadata instead
    of exposing unstable OCCT face IDs.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Updated the existing smoke to verify preview mesh output plus deterministic
    metrics.
  - Checks 800 vertices, 1060 triangles, bounds, dimensions, area, volume,
    request ID preservation, and non-editable generated geometry flags.
- `test/occt_native_target_scaffold_test.dart`:
  - Updated source-contract expectations for OCCT meshing APIs and preview mesh
    response metadata.
- Docs/tasks/roadmap:
  - Recorded M64, marked OCCT preview mesh generation complete, and left
    shell/cavity, semantic face mapping, STEP, and STL open.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe` and deployed `TKMesh.dll`
    beside the worker.
- `dart format tool\native_occt_worker_metrics_smoke.dart test\occt_native_target_scaffold_test.dart`:
  - Passed; formatted 2 files.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; capabilities report `preview_mesh_smoke`, response status is `ok`,
    and sample preview mesh reports 800 vertices and 1060 triangles.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 178 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Yes. The native worker builds rounded enclosure B-Rep, meshes it, and emits
    deterministic disposable preview mesh data.
- Serialization checked?
  - Native request/response JSON is exercised through
    `GeometryWorkerProcessClient`; Dart parses `PreviewMesh`.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    default UI behavior changed; the app still uses mock geometry unless a
    worker backend is explicitly configured.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Preview mesh has no semantic surface mappings yet.
  - Severity: Expected.
  - Next action: Add stable semantic face mapping without exposing OCCT topology
    IDs.
- Issue: Shell/cavity, feature cutouts, STEP, and STL remain unimplemented in
  the native target.
  - Severity: Expected.
  - Next action: Continue in safe geometry slices.

### Next step
Commit and push M64, then continue toward semantic surface mapping or
shell/cavity.

### Notes for future Codex sessions
The smoke command name remains `native_occt_worker_metrics_smoke.dart` for
compatibility, but it now validates preview mesh output too. Do not commit
`external/`, `occt_worker/native/vcpkg_installed/`, `build/`, `releases/`, or
OCCT DLLs.

## 2026-06-29 - M63 First native rounded enclosure metrics

### Goal
Replace the native OCCT link-smoke response with the first deterministic
rounded enclosure generation slice while keeping generated B-Rep internal to
the worker.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`occt_worker/native/src/occt_main.cpp`, `occt_worker/protocol/preview_request.example.json`,
`tool/native_worker_stub_smoke.dart`, `lib/project/project_model.dart`,
`lib/geometry/geometry_service.dart`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
and `occt_worker/README.md`.

### Changes made
- `occt_worker/native/src/occt_main.cpp`:
  - Parses the first semantic `rounded_box` enclosure from the worker request.
  - Validates dimensions, wall thickness, and corner radius.
  - Builds a centered OCCT box, applies fillets to enclosure edges, and computes
    bounds, dimensions, surface area, and volume.
  - Returns `occt.rounded_enclosure.metrics.v1` metrics for `preview_mesh`
    requests with `previewMeshEmitted=false`.
  - Keeps OCCT topology, generated B-Rep, preview mesh vertices, STL, and
    triangle IDs out of the response.
- `tool/native_occt_worker_metrics_smoke.dart`:
  - Added a process-client smoke for the OCCT target.
  - Verifies capabilities, request ID preservation, sample bounds, dimensions,
    surface area, volume, and non-editable generated geometry flags.
- `test/occt_native_target_scaffold_test.dart`:
  - Updated source-contract expectations from link smoke to metrics smoke.
  - Added smoke-tool contract coverage.
- Docs/tasks/roadmap:
  - Recorded M63 and marked the first rounded box B-Rep task complete while
    leaving shell/cavity, preview mesh, STEP, and STL open.

### Tests run
- `dart format tool\native_occt_worker_metrics_smoke.dart test\occt_native_target_scaffold_test.dart`:
  - Passed; formatted 2 files.
- `flutter test test\occt_native_target_scaffold_test.dart --reporter compact`:
  - Passed, 5 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; rebuilt `occt_worker_native_occt.exe` and reused already-installed
    OCCT packages.
- `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build`:
  - Passed; capabilities report `metrics_smoke`, response status is `ok`, and
    sample metrics match expected dimensions, area, and volume.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 178 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Yes. The native worker builds the first rounded enclosure B-Rep internally
    and computes deterministic metrics. It does not emit preview mesh yet.
- Serialization checked?
  - Native request/response JSON is exercised through
    `GeometryWorkerProcessClient`.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed; the app still uses the mock preview by
    default.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native OCCT still returns metrics only, not a preview mesh.
  - Severity: Expected.
  - Next action: Add deterministic preview mesh emission from the generated
    B-Rep.
- Issue: Shell/cavity, feature cutouts, STEP, and STL remain unimplemented in
  the native target.
  - Severity: Expected.
  - Next action: Continue in safe geometry slices after the metrics contract is
    stable.

### Next step
Commit and push M63, then continue toward native preview mesh emission.

### Notes for future Codex sessions
Use `dart run tool\native_occt_worker_metrics_smoke.dart --skip-build` after
`tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall` to verify the native
metrics contract. Do not commit `external/`,
`occt_worker/native/vcpkg_installed/`, `build/`, `releases/`, or OCCT DLLs.

## 2026-06-29 - M62 Local OCCT restore and link smoke

### Goal
Restore OCCT locally through the explicit repo-local vcpkg path, make readiness
true, and prove the opt-in native OCCT worker can link and run.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`, `.gitignore`, `README.md`,
`tools/bootstrap_vcpkg_windows.ps1`, `tools/check_occt_windows_readiness.ps1`,
`tools/build_occt_worker_occt.ps1`, `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `occt_worker/README.md`,
`test/occt_windows_readiness_test.dart`, and
`test/occt_native_target_scaffold_test.dart`.

### Changes made
- Local dependency output:
  - Cloned and bootstrapped repo-local vcpkg under ignored `external/vcpkg`.
  - Restored `opencascade[core,freetype]` `8.0.0#1`.
  - Manifest-mode packages landed under ignored
    `occt_worker/native/vcpkg_installed`.
- `.gitignore`:
  - Ignored `occt_worker/native/vcpkg_installed/`.
- `tools/check_occt_windows_readiness.ps1`:
  - Detects repo-local manifest install output.
  - Reports `manifestInstalledRoot`.
  - Fixed Windows PowerShell empty-list binding in `Add-ConfigCandidate`.
- `tools/build_occt_worker_occt.ps1`:
  - Gives a clean `EXIT:2` guidance when OCCT is ready from
    `vcpkg_installed` but `-AllowVcpkgInstall` is omitted.
  - Keeps manifest dependency resolution explicit for the manifest install
    path.
- Docs/tasks/roadmap:
  - Recorded M62 and documented the installed local OCCT path and linked build
    command.
- Tests:
  - Updated script-contract tests for `vcpkg_installed`,
    `manifestInstalledRoot`, and manifest build guidance.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade`:
  - Restored all requested packages successfully in about 1.5 hours.
  - The command then hit a readiness-script bug that was fixed in this chunk.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`:
  - Passed after the fix; reports `ready=true` and finds
    `occt_worker/native/vcpkg_installed/x64-windows/share/opencascade/OpenCASCADEConfig.cmake`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1`:
  - Returned expected `EXIT:2` with guidance to add `-AllowVcpkgInstall` for
    manifest-installed OCCT.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall -Clean`:
  - Passed; built
    `build\occt_worker_native_occt\Release\occt_worker_native_occt.exe` and
    deployed required OCCT DLLs beside it.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Passed; repeat build is quick and reports packages already installed.
- `build\occt_worker_native_occt\Release\occt_worker_native_occt.exe --capabilities`:
  - Passed; reports `status=linked_smoke` and `occtVersion=8.0.0`.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | build\occt_worker_native_occt\Release\occt_worker_native_occt.exe`:
  - Returned expected `worker.backend.occt_link_smoke_only`, preserved request
    ID, and reports `linkSmokeShapeNull=false`.
- `dart format lib test tool occt_worker`:
  - Passed, no files changed.
- `flutter test test\occt_windows_readiness_test.dart test\occt_native_target_scaffold_test.dart test\vcpkg_bootstrap_script_test.dart`:
  - Passed, 8 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1 -RequireOcct`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 177 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.

### Validation
- Geometry checked?
  - Native OCCT link smoke only. The worker creates a smoke shape internally and
    reports `linkSmokeShapeNull=false`, but no semantic B-Rep generation,
    preview mesh, STL workflow, or editable generated geometry was added.
- Serialization checked?
  - Readiness JSON, capabilities JSON, and native request/response JSON were
    exercised. Full protocol tests passed.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `occt_worker_native_occt` still returns
  `worker.backend.occt_link_smoke_only` for geometry requests.
  - Severity: Expected.
  - Next action: Replace the link smoke with the first deterministic rounded
    enclosure B-Rep/metrics response.
- Issue: Manifest-installed OCCT requires `-AllowVcpkgInstall` for linked
  native builds so CMake can resolve transitive vcpkg dependencies.
  - Severity: Expected.
  - Next action: Keep using `tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`
    for the repo-local manifest path.

### Next step
Implement the first deterministic OCCT rounded enclosure generation slice behind
the native worker protocol, starting with metrics or a minimal preview response
that remains disposable output and does not expose OCCT topology IDs to Flutter.

### Notes for future Codex sessions
OCCT is now locally ready on this machine. Do not commit `external/`,
`occt_worker/native/vcpkg_installed/`, `build/`, release output, or copied OCCT
DLLs. Use `-AllowVcpkgInstall` for the manifest-installed OCCT path.

## 2026-06-29 - M61 Repo-local vcpkg bootstrap helper

### Goal
Make the Windows OCCT dependency setup reproducible from the repository while
keeping vcpkg sources, installed packages, OCCT binaries, build output, and
release bundles out of Git.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`, `.gitignore`, `README.md`,
`tools/check_occt_windows_readiness.ps1`, `tools/build_occt_worker_occt.ps1`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `occt_worker/README.md`, and
`test/occt_windows_readiness_test.dart`.

### Changes made
- `.gitignore`:
  - Ignored `external/` so repo-local vcpkg output cannot be committed
    accidentally.
- `tools/bootstrap_vcpkg_windows.ps1`:
  - Added a repo-local vcpkg helper with `-PlanOnly`,
    `-InstallOpenCascade`, and `-SetUserEnvironment`.
  - Keeps `opencascade` manifest restore explicit instead of automatic.
- `tools/check_occt_windows_readiness.ps1`:
  - Added auto-detection for `external/vcpkg` when `VCPKG_ROOT` is not set.
  - Reports `rootSource` so readiness output explains where vcpkg came from.
- Tests:
  - Added bootstrap helper safety coverage.
  - Extended readiness script coverage for repo-local vcpkg detection.
- Docs/tasks/roadmap:
  - Recorded the M61 chunk and documented the new helper commands.

### Tests run
- `dart format lib test tool occt_worker`:
  - Formatted `test\vcpkg_bootstrap_script_test.dart`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly`:
  - Passed; printed `shell_case.occt.vcpkg_bootstrap` JSON without cloning or
    installing anything.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`:
  - Passed; readiness remains `false` because no local vcpkg/OCCT install
    exists yet, and now recommends the bootstrap helper.
- `flutter test test\occt_windows_readiness_test.dart test\vcpkg_bootstrap_script_test.dart`:
  - Passed, 4 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 177 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly -InstallOpenCascade`:
  - Passed; printed the large-install plan without restoring dependencies.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.

### Validation
- Geometry checked?
  - Dependency setup only. No generated B-Rep, preview mesh, STL workflow, or
    editable geometry state was added.
- Serialization checked?
  - Bootstrap `-PlanOnly` and readiness JSON contracts were exercised; full
    worker protocol tests passed in the full suite.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: OCCT readiness is still false on this machine.
  - Severity: Expected.
  - Next action: Run `tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade`
    when the long dependency restore is acceptable.
- Issue: The OCCT target remains link-smoke only.
  - Severity: Expected.
  - Next action: After readiness is true, build the OCCT target and add the
    first deterministic rounded enclosure generation response.

### Next step
Run the explicit repo-local vcpkg/OCCT restore, then use
`tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall` to validate the linked
worker before implementing real rounded enclosure B-Rep generation.

### Notes for future Codex sessions
The helper intentionally does not restore `opencascade` unless
`-InstallOpenCascade` is provided. Keep `external/` ignored and do not commit
dependency trees or native binaries.

## 2026-06-29 - M60 OCCT vcpkg manifest restore path

### Goal
Add an explicit opt-in vcpkg manifest restore path for the OCCT-linked native
worker target without making normal Flutter builds or default native checks
install packages silently.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `tools/build_occt_worker_occt.ps1`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`occt_worker/README.md`, and `test/occt_native_target_scaffold_test.dart`.

### Changes made
- `occt_worker/native/vcpkg.json`:
  - Added a minimal manifest that declares only the `opencascade` dependency.
- `tools/build_occt_worker_occt.ps1`:
  - Added `-AllowVcpkgInstall`.
  - Keeps the default path readiness-only when OCCT is missing.
  - Enables CMake vcpkg manifest mode only when the flag is present and the
    vcpkg toolchain is discoverable.
- `test/occt_native_target_scaffold_test.dart`:
  - Added manifest parsing coverage and script safety checks for the new flag.
- Docs/tasks/roadmap:
  - Documented the manifest restore path and marked the M60 task complete.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall`:
  - Returned expected `EXIT:2` because this machine still has no configured
    `VCPKG_ROOT`, vcpkg toolchain, or local OCCT config.
- `flutter test test\occt_native_target_scaffold_test.dart`:
  - Passed, 4 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 175 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.

### Validation
- Geometry checked?
  - Dependency plumbing only. No editable generated B-Rep, mesh, STL workflow,
    or product semantics were added to the worker.
- Serialization checked?
  - `vcpkg.json` is parsed by the scaffold test; existing worker protocol tests
    passed in the full suite.
- UI checked?
  - Full widget suite passed and the latest Windows bundle was rebuilt. No
    user-facing UI changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `-AllowVcpkgInstall` cannot proceed until vcpkg is configured locally.
  - Severity: Expected.
  - Next action: Set `VCPKG_ROOT` or provide an explicit OCCT install before
    building the OCCT-linked worker.
- Issue: The OCCT target remains a link/readiness scaffold.
  - Severity: Expected.
  - Next action: After dependency readiness is true, add the first deterministic
    rounded enclosure B-Rep generation slice behind the worker protocol.

### Next step
Configure vcpkg/OCCT locally or add an explicit bootstrap helper, then run
`tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall` and continue toward the
first real rounded enclosure generation response.

### Notes for future Codex sessions
Keep manifest restore opt-in. Do not run a large vcpkg restore from the normal
Flutter build path, and do not commit generated vcpkg trees, OCCT binaries,
worker build output, or `releases/`.

## 2026-06-29 - M59 Opt-in OCCT native target scaffold

### Goal
Add the separate OCCT-linked native worker scaffold without making the default
stub build or normal Flutter app build depend on OCCT.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `occt_worker/native/CMakeLists.txt`,
`docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `occt_worker/native/CMakeLists.txt`:
  - Renamed the native project to `shell_case_occt_worker_native`.
  - Added `SHELL_CASE_ENABLE_OCCT`.
  - Kept `occt_worker_native_stub` as the default no-OCCT target.
  - Added opt-in `occt_worker_native_occt` target behind the OCCT option.
- `occt_worker/native/src/occt_main.cpp`:
  - Added OCCT link-smoke source that references `BRepPrimAPI_MakeBox`.
  - Emits capability JSON with `status=linked_smoke`.
  - Returns `worker.backend.occt_link_smoke_only` until semantic B-Rep
    generation is implemented.
- `tools/build_occt_worker_occt.ps1`:
  - Added opt-in build script for the OCCT-linked target.
  - Requires readiness through `tools/check_occt_windows_readiness.ps1`.
  - Does not install vcpkg/OCCT or touch release output.
- `test/occt_native_target_scaffold_test.dart`:
  - Added tests for CMake opt-in wiring, OCCT source contract, and build script
    safety.
- Docs/tasks/roadmap:
  - Recorded M59 and documented the OCCT target build command.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`:
  - Passed; default native stub still builds without OCCT.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1`:
  - Returned expected `EXIT:2` with readiness JSON because local OCCT readiness
    is still false.
- `flutter test test\native_worker_scaffold_test.dart test\occt_native_target_scaffold_test.dart`:
  - Passed, 8 tests.
- `dart format lib test tool occt_worker`:
  - Applied formatting to `test\occt_native_target_scaffold_test.dart`.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting was applied.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; native stub still reports expected not-implemented response and
    preserves request ID.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 174 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Link-smoke scaffold only. No semantic B-Rep generation, preview mesh output,
    STL workflow, or editable generated geometry was introduced.
- Serialization checked?
  - Capability/response contracts are textual in the OCCT source and covered by
    scaffold tests. Existing native stub process smoke still parses through the
    Dart process client.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `occt_worker_native_occt` cannot be built locally until OCCT readiness
  is true.
  - Severity: Expected.
  - Next action: Install/configure vcpkg or set `OpenCASCADE_DIR` / `CASROOT`,
    then rerun `tools\build_occt_worker_occt.ps1`.
- Issue: OCCT target is a link smoke only.
  - Severity: Expected.
  - Next action: After OCCT readiness is true, add deterministic rounded
    enclosure generation behind the same worker protocol.

### Next step
Make OCCT readiness true locally, then build `occt_worker_native_occt` and
replace `worker.backend.occt_link_smoke_only` with the first deterministic
rounded enclosure geometry response.

### Notes for future Codex sessions
Do not wire `occt_worker_native_occt` into normal Flutter builds. Keep it
opt-in behind `SHELL_CASE_ENABLE_OCCT` until native packaging and license
notices are ready.

## 2026-06-29 - M58 OCCT Windows dependency readiness

### Goal
Lock the first Windows OCCT dependency path and add a read-only readiness check
before adding an OCCT-linked native worker target.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `README.md`,
`docs/27_RESEARCH_AND_REFERENCES.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`:
  - Added the Windows OCCT dependency decision note.
  - Records official OCCT build/licensing findings, vcpkg package status, local
    environment snapshot, and the opt-in target strategy.
- `tools/check_occt_windows_readiness.ps1`:
  - Added read-only JSON readiness checker for CMake, vcpkg, `VCPKG_ROOT`,
    `OpenCASCADE_DIR`, `CASROOT`, and common `OpenCASCADEConfig.cmake` paths.
  - Exits `0` by default and exits `2` only when `-RequireOcct` is used and no
    OCCT package config is found.
- `test/occt_windows_readiness_test.dart`:
  - Added tests that keep the checker read-only and keep the dependency note
    explicit about the worker boundary.
- Docs/tasks/roadmap:
  - Added M58, linked the readiness command from README and worker/OCCT docs,
    and appended the research decision to `docs/27_RESEARCH_AND_REFERENCES.md`.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`:
  - Passed with `ready=false`; CMake was found, vcpkg/OCCT package config were
    not found on this machine.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1 -RequireOcct`:
  - Returned expected exit code `2` with the same readiness JSON.
- `flutter test test\occt_windows_readiness_test.dart`:
  - Passed, 2 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format lib test tool occt_worker`:
  - Applied formatting to `test\occt_windows_readiness_test.dart`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting was applied.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; native stub still reports expected not-implemented response and
    preserves request ID.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 171 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Dependency/readiness planning only. No OCCT B-Rep generation, mesh output,
    STL workflow, or editable generated geometry was introduced.
- Serialization checked?
  - Readiness checker emits structured JSON; focused tests cover the contract
    textually and the command was run locally.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Local machine is not ready for OCCT linking yet.
  - Severity: Expected.
  - Next action: Install/configure vcpkg or set `OpenCASCADE_DIR` / `CASROOT`,
    then rerun `tools\check_occt_windows_readiness.ps1 -RequireOcct`.

### Next step
After readiness is true, add a separate opt-in OCCT-linked native target while
keeping `occt_worker_native_stub` buildable without OCCT.

### Notes for future Codex sessions
Do not make normal Flutter builds depend on OCCT. The first OCCT-linked worker
target should be separate from the stub and should only be enabled when
`OpenCASCADEConfig.cmake` is discoverable.

## 2026-06-29 - M57 Native worker request envelope

### Goal
Make the native worker stub read and validate the top-level worker request
envelope before returning scaffold responses.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `README.md`,
`occt_worker/native/src/main.cpp`, `tool/native_worker_stub_smoke.dart`,
`test/native_worker_scaffold_test.dart`, `occt_worker/README.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`, and
`docs/34_FIRST_GEOMETRY_SLICE.md`.

### Changes made
- `occt_worker/native/src/main.cpp`:
  - Replaced stdin discard behavior with a small native request-envelope
    reader.
  - Preserves `requestId` in native scaffold responses.
  - Validates top-level `schema` and planned `operation` values.
  - Returns typed `worker.request.*` issues for empty payloads, non-object
    payloads, invalid schema, and invalid operation.
  - Adds `requestedOperation` response metrics when the operation is available.
- `tool/native_worker_stub_smoke.dart`:
  - Now fails if the native response does not preserve the smoke request ID.
  - Prints `requestId` and `requestIdPreserved` in the JSON summary.
- `test/native_worker_scaffold_test.dart`:
  - Updated scaffold coverage for envelope validation, request issue codes, and
    request ID preservation smoke coverage.
- Docs/tasks/roadmap:
  - Recorded M57 and documented the native envelope validation behavior.

### Tests run
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`:
  - Passed; rebuilt
    `C:\Users\EriArk\Documents\CaseMaker\build\occt_worker_native\Release\occt_worker_native_stub.exe`.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; `requestIdPreserved=true` and expected
    `worker.backend.native_not_implemented`.
- Native stub invalid payload smokes:
  - Empty payload returned `worker.request.empty`.
  - Non-object payload returned `worker.request.invalid_json`.
  - Invalid schema preserved `requestId=bad_schema` and returned
    `worker.request.invalid_schema`.
  - Invalid operation preserved `requestId=bad_op` and returned
    `worker.request.invalid_operation`.
- `dart format lib test tool occt_worker`:
  - Applied formatting to `test\native_worker_scaffold_test.dart`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed after formatting was applied.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test\native_worker_scaffold_test.dart`:
  - Passed, 5 tests.
- `dart run tool\native_worker_stub_smoke.dart`:
  - Passed; rebuilt the native stub and verified request ID preservation.
- `flutter test --reporter compact`:
  - Passed, 169 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Protocol boundary only. No OCCT B-Rep, mesh generation, STL workflow, or
    editable generated geometry was introduced.
- Serialization checked?
  - Yes. Native responses are protocol-shaped JSON and the Dart process client
    parsed the smoke response successfully.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native worker still uses a minimal envelope reader instead of a full
  native JSON library.
  - Severity: Acceptable for the scaffold.
  - Next action: Decide the native JSON dependency together with OCCT packaging
    before parsing the full semantic project payload.
- Issue: Native worker still returns the expected not-implemented response for
  valid geometry requests.
  - Severity: Expected for the current scaffold.
  - Next action: Start the first real OCCT-backed rounded enclosure generation
    slice after dependency/build research is recorded.

### Next step
Research and lock the Windows OCCT/native dependency path, then add the first
native geometry slice behind the same worker protocol.

### Notes for future Codex sessions
`dart run tool\native_worker_stub_smoke.dart` now checks capability query,
request ID preservation, and the expected native scaffold issue. Native invalid
request responses use `worker.request.*` codes and should stay typed.

## 2026-06-29 - M56 Native worker stub smoke tool

### Goal
Add one developer smoke command that builds the native worker stub, queries
capabilities through the Dart process client, sends a preview request, and
verifies the expected `native_not_implemented` response.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `README.md`,
`occt_worker/README.md`, `docs/03_ARCHITECTURE_OVERVIEW.md`,
`docs/04_GEOMETRY_ENGINE_OCCT.md`, `docs/34_FIRST_GEOMETRY_SLICE.md`,
`lib/geometry/geometry_service.dart`, and `test/native_worker_scaffold_test.dart`.

### Changes made
- `tool/native_worker_stub_smoke.dart`:
  - Added a smoke command for the native stub build and process-client path.
  - Supports `--skip-build` and `--configuration Debug|Release`.
  - Prints a compact JSON summary with executable path, capability status, and
    request smoke result.
  - Exits nonzero if capabilities fail or the expected native stub response is
    missing.
- `test/native_worker_scaffold_test.dart`:
  - Added coverage that keeps the smoke tool wired to the native build script,
    `GeometryWorkerProcessClient`, capability query, preview request, and
    expected native stub issue code.
- Docs/tasks/roadmap:
  - Documented M56, added the smoke command to developer docs, and kept
    `TASKS.md` aligned with the roadmap.

### Tests run
- `flutter test test\native_worker_scaffold_test.dart`:
  - Passed, 5 tests.
- `dart run tool\native_worker_stub_smoke.dart --skip-build`:
  - Passed; found the Release native stub, queried capabilities, and received
    expected `worker.backend.native_not_implemented`.
- `dart run tool\native_worker_stub_smoke.dart`:
  - Passed; rebuilt the native stub before running the same smoke path.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 169 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Native stub path only. No OCCT B-Rep generation is implemented in this
    chunk, and no editable mesh/STL state was introduced.
- Serialization checked?
  - Yes. The smoke command sends a semantic `ProjectModel.initial()` preview
    request through the worker process contract.
- UI checked?
  - Full widget suite passes and the latest Windows bundle was rebuilt. No
    user-facing UI behavior changed in this chunk.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native worker still returns the expected not-implemented response for
  geometry requests.
  - Severity: Expected for the current scaffold.
  - Next action: Start replacing the stub response with the first real OCCT
    rounded enclosure generation path once the native dependency/build decision
    is locked.

### Next step
Begin the first native geometry implementation slice: keep the semantic request
contract stable, add the minimum native protocol parsing needed by the worker,
and generate a deterministic rounded enclosure shape or a narrower preparatory
slice if OCCT packaging needs one more bridge.

### Notes for future Codex sessions
The fast smoke command is `dart run tool\native_worker_stub_smoke.dart`. It is
safe to use before the full app build because it only touches
`build/occt_worker_native` and expects the native stub to report
`worker.backend.native_not_implemented`.

## 2026-06-29 - M55 Native worker build scaffold

### Goal
Add a separately buildable native worker executable scaffold without linking
OCCT yet or pretending native B-Rep generation is implemented.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `occt_worker/README.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, `windows/CMakeLists.txt`,
`windows/runner/CMakeLists.txt`, `.gitignore`, and
`tools/build_latest_windows.ps1`.

### Changes made
- `occt_worker/native/CMakeLists.txt`:
  - Added standalone `occt_worker_native_stub` CMake target.
  - Uses C++17 and compiler warnings as errors.
  - Does not add OCCT includes or dependencies yet.
- `occt_worker/native/src/main.cpp`:
  - Added native executable scaffold.
  - Emits `shell_case.geometry.worker.capabilities` for `--capabilities`.
  - Returns structured `worker.backend.native_not_implemented` response for
    geometry requests.
  - Keeps generated/native details out of editable project semantics.
- `tools/build_occt_worker_stub.ps1`:
  - Added safe build script for `build/occt_worker_native`.
  - Includes child-path checks before optional clean/removal.
- `test/native_worker_scaffold_test.dart`:
  - Added tests for CMake target shape, capability JSON, not-implemented
    response JSON, and build-script output confinement.
- Docs/tasks/roadmap:
  - Recorded M55 and documented the native stub build command.

### Tests run
- `flutter test test\native_worker_scaffold_test.dart`:
  - Passed, 4 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_stub.ps1`:
  - Passed; built
    `C:\Users\EriArk\Documents\CaseMaker\build\occt_worker_native\Release\occt_worker_native_stub.exe`.
- `build\occt_worker_native\Release\occt_worker_native_stub.exe --capabilities`:
  - Passed; returned `shell_case.geometry.worker.capabilities`,
    `activeBackend=native`, `nativeStatus=stub`.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | build\occt_worker_native\Release\occt_worker_native_stub.exe`:
  - Returned expected exit code `2`, `backend=occt_worker_native_stub`, and
    `worker.backend.native_not_implemented`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 168 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Native executable scaffold only. No OCCT B-Rep, STL, editable mesh, or
    topology IDs were introduced.
- Serialization checked?
  - Yes. Tests parse native stub capability/response JSON from the C++ source,
    and executable smoke commands returned valid JSON.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Native worker stub does not parse request JSON or preserve request IDs.
  - Severity: Expected scaffold limitation.
  - Next action: replace stub response path with a real native protocol handler
    once JSON dependency/build policy is chosen.
- Issue: OCCT is not linked yet.
  - Severity: Expected.
  - Next action: add OCCT dependency/build policy and first rounded enclosure
    B-Rep generation.

### Next step
Commit and push M55, then continue toward native protocol handling or the first
OCCT-backed rounded enclosure generation slice.

### Notes for future Codex sessions
The native stub build is intentionally separate from Flutter. Keep native worker
artifacts under `build/occt_worker_native` until packaging policy is decided.

---

## 2026-06-29 - M54 Worker capability process client

### Goal
Let Dart callers query worker capability metadata through the same process
adapter used for geometry requests, with typed parsing and normalized failures.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_worker_runtime.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`test/geometry_worker_runtime_test.dart`,
`test/geometry_worker_process_client_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_capabilities.dart`:
  - Added standalone capability model/parsers.
  - Moved capability JSON shape out of worker runtime.
  - Added typed backend capability parsing for supported/planned operations.
- `lib/geometry/geometry_worker_runtime.dart`:
  - Uses the shared capability model.
- `lib/geometry/geometry_worker_process_client.dart`:
  - Added `GeometryWorkerProcessCommand.copyWith`.
  - Added `GeometryWorkerCapabilitiesResult`.
  - Added `queryCapabilities()`.
  - Appends `--capabilities` without duplicating it.
  - Normalizes launch failures, timeouts, invalid capability JSON, and non-zero
    capability exits into typed issues.
- `lib/geometry/geometry_service.dart`:
  - Exports worker capability types through the geometry boundary.
- `test/geometry_worker_process_client_test.dart`:
  - Added capability query success and failure coverage.
- Docs/tasks/roadmap:
  - Recorded M54 and documented process-client capability querying.

### Tests run
- `flutter test test\geometry_worker_process_client_test.dart`:
  - Passed, 10 tests.
- `flutter test test\geometry_worker_runtime_test.dart`:
  - Passed, 8 tests.
- `dart run occt_worker\bin\occt_worker.dart --capabilities`:
  - Passed; emitted `shell_case.geometry.worker.capabilities`,
    `activeBackend=mock`, `mockStatus=available`, `nativeStatus=stub`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 164 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Process metadata only; no generated B-Rep, STL, editable mesh, or OCCT
    topology was introduced.
- Serialization checked?
  - Yes. Capability JSON parses into typed Dart models and process-client tests
    cover malformed responses.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Capability querying is not yet used by `GeometryBackendSettings` or
  the UI.
  - Severity: Low.
  - Next action: use it when native backend launch policy or user-visible
    backend diagnostics are added.
- Issue: Native backend is still a stub.
  - Severity: Expected.
  - Next action: continue toward the first native worker scaffold or rounded
    enclosure B-Rep slice.

### Next step
Commit and push M54, then continue toward native worker scaffold/build or first
OCCT-backed enclosure generation.

### Notes for future Codex sessions
Use `GeometryWorkerProcessClient.queryCapabilities()` before assuming a worker
command can handle native geometry. The query result is runtime metadata only
and must not become editable project data.

---

## 2026-06-29 - M53 Worker capability contract

### Goal
Let the local worker report backend readiness and supported/planned operations
without requiring a geometry request payload.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_worker_runtime.dart`,
`test/geometry_worker_runtime_test.dart`, `README.md`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_runtime.dart`:
  - Added `GeometryWorkerCapabilities`.
  - Added `GeometryWorkerBackendCapability`.
  - Added `--capabilities` runtime parsing.
  - Capability JSON reports protocol schema/version, active/default backend,
    semantic-project source of truth, and non-editable generated geometry.
  - Capability JSON marks `mock` as available for `preview_mesh`.
  - Capability JSON marks `native` as a stub with planned preview/export/validate
    operations and `worker.backend.native_not_implemented`.
- `test/geometry_worker_runtime_test.dart`:
  - Added unit coverage for capability metadata.
  - Added process coverage for
    `dart run occt_worker\bin\occt_worker.dart --capabilities`.
- Docs/tasks/roadmap:
  - Recorded M53 and documented the capability command in README, worker docs,
    and geometry architecture notes.

### Tests run
- `flutter test test\geometry_worker_runtime_test.dart`:
  - Passed, 8 tests.
- `dart run occt_worker\bin\occt_worker.dart --capabilities`:
  - Passed; emitted `shell_case.geometry.worker.capabilities` JSON with
    `mock` available and `native` stub.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 159 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Metadata contract only. No native OCCT geometry was generated.
- Serialization checked?
  - Yes. Capability JSON is generated deterministically and parsed in tests.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; capability JSON marks export as planned for native.

### Known issues
- Issue: Native backend remains a stub.
  - Severity: Expected.
  - Next action: continue toward native worker scaffold/build and first rounded
    enclosure B-Rep slice.
- Issue: Capability JSON is not consumed by the Flutter UI yet.
  - Severity: Low.
  - Next action: use it when worker backend selection becomes user-visible or
    when native backend launch policy is finalized.

### Next step
Commit and push M53, then continue toward the first native worker scaffold or
OCCT-backed rounded enclosure generation slice.

### Notes for future Codex sessions
Use `dart run occt_worker\bin\occt_worker.dart --capabilities` to inspect the
current worker readiness contract before changing worker launch or native
backend behavior.

---

## 2026-06-29 - M52 Local occt_worker CLI

### Goal
Create the canonical local worker command under `occt_worker/` so process
tests, smoke commands, and future worker integration target the real boundary
path instead of a temporary tool script.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_worker_protocol.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`lib/geometry/geometry_service.dart`, `tool/mock_geometry_worker.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_runtime.dart`:
  - Added `GeometryWorkerRuntime`.
  - Added backend mode parsing with `mock` default and explicit `native` stub.
  - Added stdin/stdout runner shared by worker entrypoints.
  - Returns structured JSON and exit code `2` for protocol/config/backend
    errors.
- `occt_worker/bin/occt_worker.dart`:
  - Added the canonical local worker CLI.
  - Reads geometry request JSON from stdin and emits geometry response JSON.
- `tool/mock_geometry_worker.dart`:
  - Kept as a compatibility alias over the shared local worker runtime.
- `tool/mock_geometry_worker_client_smoke.dart` and
  `tool/mock_worker_geometry_service_smoke.dart`:
  - Updated process commands to use `occt_worker/bin/occt_worker.dart`.
- `test/geometry_worker_runtime_test.dart`:
  - Added coverage for default mock runtime behavior, backend argument parsing,
    invalid payload responses, native not-implemented responses, invalid CLI
    argument JSON, and real process-client execution of the canonical CLI.
- Docs/tasks/roadmap:
  - Recorded M52, canonical worker commands, native stub behavior, and current
    limitations.

### Tests run
- `flutter test test\geometry_worker_runtime_test.dart`:
  - Passed, 6 tests.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart`:
  - Passed; returned `status=ok`, `backend=mock`, `featureIntents=4`, and
    `operationCount=10`.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart --backend=native`:
  - Returned expected exit code `2`, `backend=occt_worker_stub`, and
    `worker.backend.native_not_implemented`.
- `dart run tool\mock_geometry_worker_client_smoke.dart`:
  - Passed through the canonical CLI.
- `dart run tool\mock_worker_geometry_service_smoke.dart`:
  - Passed through the canonical CLI with `responseStatus=ok`.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 157 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Worker CLI/protocol boundary only. The default backend is still mock
    geometry; native mode explicitly reports not implemented.
- Serialization checked?
  - Yes. CLI and process-client tests round-trip request/response JSON.
- UI checked?
  - Full widget suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `--backend=native` is a stub and does not call OCCT yet.
  - Severity: Expected.
  - Next action: add the first native worker build/scaffold or OCCT-backed
    geometry slice after checking build/distribution details.
- Issue: Local worker CLI is Dart-only.
  - Severity: Acceptable bridge.
  - Next action: keep this protocol path stable while replacing the backend
    implementation behind it.

### Next step
Commit and push M52, then continue toward the first native worker scaffold or
rounded enclosure generation slice.

### Notes for future Codex sessions
Use `dart run occt_worker\bin\occt_worker.dart` as the canonical worker smoke.
Keep `tool/mock_geometry_worker.dart` only for compatibility unless old docs or
scripts still depend on it.

---

## 2026-06-29 - M51 Generated geometry protocol fixtures

### Goal
Make `occt_worker/protocol` example request/response JSON reproducible from
typed Dart models and the mock backend, instead of maintaining large protocol
fixtures by hand.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/geometry/geometry_service.dart`, `lib/project/project_model.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `tool/generate_geometry_protocol_fixtures.dart`:
  - Added a generator for the worker preview request and response examples.
  - Builds the fixture from `ProjectModel.initial()` plus projected button and
    standoff feature groups.
  - Uses `MockGeometryService` to produce the response fixture.
- `occt_worker/protocol/preview_request.example.json`:
  - Regenerated with four semantic `featureIntents`: `front_usb_c`,
    `abxy_buttons`, `projected_buttons`, and `standoff_mounts_1`.
  - Includes expanded projected button and standoff group items.
- `occt_worker/protocol/preview_response.example.json`:
  - Regenerated from the mock backend.
  - Includes operation-plan metrics with `operationCount=10`.
- `test/geometry_protocol_fixture_test.dart`:
  - Added fixture coverage for expected feature intents, group item counts,
    response metrics, and mock rebuild parity.
- Docs/tasks/roadmap:
  - Recorded M51 fixture regeneration command, current mock-backend limitation,
    and backend-only poke checklist.

### Tests run
- `dart run tool\generate_geometry_protocol_fixtures.dart`:
  - Passed; reported `featureIntents=4` and `operationCount=10`.
- `flutter test test\geometry_protocol_fixture_test.dart`:
  - Passed, 3 tests.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart`:
  - Passed; returned `status=ok`, `backend=mock`, `featureIntents=4`,
    `operationCount=10`, and 10 operation-plan entries.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 151 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Protocol/fixture path only. The response is mock backend output with a
    deterministic preview mesh and operation plan, not native OCCT B-Rep.
- Serialization checked?
  - Yes. Fixture request/response are decoded back into typed geometry models,
    and the request rebuilds through `MockGeometryService`.
- UI checked?
  - Full widget test suite passes; latest Windows bundle rebuilt.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The generated response fixture is still mock output, not native OCCT
  geometry.
  - Severity: Expected.
  - Next action: continue toward the first native `occt_worker` executable.
- Issue: The fixture project is a curated protocol sample, not a user-facing
  project template.
  - Severity: Acceptable.
  - Next action: keep fixture scenarios small and deterministic as worker
    coverage grows.

### Next step
Commit and push M51, then continue with the next safe worker/geometry chunk.

### Notes for future Codex sessions
Regenerate fixtures with `dart run tool\generate_geometry_protocol_fixtures.dart`
after changing feature intent serialization, operation planning, or mock
geometry response metrics.

---

## 2026-06-29 - M50 Geometry backend selection

### Goal
Add an explicit developer/runtime backend selector so the app can choose mock
or worker-backed geometry through one factory while keeping mock as the normal
default.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/app/case_maker_app.dart`,
`lib/main.dart`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_backend.dart`:
  - Added `GeometryBackendKind`.
  - Added `GeometryBackendSettings`.
  - Added `createGeometryService(settings)`.
  - Added `createGeometryServiceFromEnvironment()` using compile-time
    `--dart-define` values.
  - Added pipe-separated worker argument parsing for developer runs.
  - Falls back to mock when worker backend is requested without an executable.
- `lib/app/case_maker_app.dart`:
  - Uses the backend factory by default.
  - Keeps optional `geometryService` injection for tests and explicit callers.
- `test/geometry_backend_test.dart`:
  - Covers default mock selection, explicit worker selection, safe fallback,
    and argument parsing.
- Docs/tasks/roadmap:
  - Recorded M50 behavior, safe default, and the developer `--dart-define`
    switch.

### Tests run
- `flutter test test\geometry_backend_test.dart`:
  - Passed, 4 tests.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 148 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed; Git reported markdown line-ending normalization warnings only.

### Validation
- Geometry checked?
  - Backend selection only; no generated B-Rep, STL, editable mesh, or OCCT
    topology is introduced.
- Serialization checked?
  - Not affected.
- UI checked?
  - Full widget suite passes; normal app builds still instantiate mock geometry.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Worker backend selection still targets a mock worker unless a real
  worker executable is configured.
  - Severity: Expected.
  - Next action: add the first native `occt_worker` executable slice.
- Issue: Worker arguments are pipe-separated, which is simple but not a full
  shell parser.
  - Severity: Acceptable developer-only limitation.
  - Next action: replace with config-file or JSON args if worker launch needs
    complex quoting.

### Next step
Commit and push M50, then continue toward the native `occt_worker` executable
or a richer generated-geometry fixture.

### Notes for future Codex sessions
Keep backend selection behind `GeometryService`. Do not make widgets branch on
backend kind, process command, or native worker details.

---

## 2026-06-29 - M49 Worker GeometryService adapter

### Goal
Add an app-facing `GeometryService` adapter over the worker process client
without switching the default Flutter shell away from the stable mock backend.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_worker_process_client.dart`,
`test/geometry_worker_process_client_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_service.dart`:
  - Added reusable `defaultSelectableSurfaces(project)`.
  - Updated `MockGeometryService` to use the shared semantic surface catalog.
  - Added `WorkerGeometryService`.
  - Routes `buildGeometry` through `GeometryWorkerProcessClient`.
  - Routes `generatePreview` through a preview-mesh worker request and reports
    backend/status/preview/intent/operation stats.
  - Keeps validation local through `ProjectSemanticValidator`.
- `test/geometry_worker_service_test.dart`:
  - Added coverage for build routing, preview stats, worker error stats, and
    local semantic validation.
- `tool/mock_worker_geometry_service_smoke.dart`:
  - Added a developer smoke command for the full
    `WorkerGeometryService -> process client -> mock worker` path.
- Docs/tasks/roadmap:
  - Recorded M49 behavior, current limitations, smoke command, and poke
    checklist.

### Tests run
- `flutter test test\geometry_worker_service_test.dart`:
  - Passed, 4 tests.
- `dart run tool\mock_worker_geometry_service_smoke.dart`:
  - Passed; `exit=0`, `backend=mock`, `responseStatus=ok`,
    `featureIntents=2`, `operationCount=2`, `surfaceCount=3`.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 144 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Adapter path only; it still uses mock geometry in smoke tests and does not
    introduce generated B-Rep, editable mesh, STL, or OCCT topology.
- Serialization checked?
  - Worker service tests verify preview requests carry feature intents through
    process payloads.
- UI checked?
  - Full widget suite passes; the default app shell still uses
    `MockGeometryService`.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `WorkerGeometryService` is not the default runtime backend.
  - Severity: Expected.
  - Next action: add a deliberate developer/backend switch only when useful.
- Issue: `WorkerGeometryService` uses semantic/local validation and selectable
  surface IDs until native worker validation/surface mapping exists.
  - Severity: Expected.
  - Next action: replace only the generated-geometry side first, keeping stable
    semantic IDs at the UI boundary.

### Next step
Commit and push M49, then continue toward either a deliberate backend switch or
the first native `occt_worker` executable slice.

### Notes for future Codex sessions
`WorkerGeometryService` is the intended app-facing bridge for native geometry.
Do not make widgets call process clients directly; keep all backend switching
behind `GeometryService`.

---

## 2026-06-29 - M48 Worker process client

### Goal
Add a process-boundary client for geometry requests so a future native
`occt_worker` can be launched through stdin/stdout without coupling Flutter to
OCCT internals.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_protocol.dart`, `lib/geometry/geometry_worker_protocol.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_process_client.dart`:
  - Added `GeometryWorkerProcessCommand`.
  - Added `GeometryWorkerProcessClient.buildGeometry`.
  - Added the default `Process.start` runner that writes request JSON to stdin
    and captures stdout/stderr.
  - Preserves structured worker error responses from non-zero worker exits.
  - Normalizes launch failures, timeouts, invalid response JSON, and non-zero
    clean responses into `GeometryResponse` errors.
- `tool/mock_geometry_worker_client_smoke.dart`:
  - Added a developer smoke command that launches `tool/mock_geometry_worker.dart`
    as a child process and prints the geometry response.
- `test/geometry_worker_process_client_test.dart`:
  - Added fake-runner coverage for request payloads, worker error preservation,
    invalid response JSON, non-zero exits, and timeouts.
- Docs/tasks/roadmap:
  - Recorded M48 behavior, smoke command, limitations, and poke checklist.

### Tests run
- `flutter test test\geometry_worker_process_client_test.dart`:
  - Passed, 5 tests.
- `dart run tool\mock_geometry_worker_client_smoke.dart`:
  - Passed; `exit=0`, `status=ok`, `backend=mock`, `featureIntents=2`,
    `operationCount=2`.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 140 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Process adapter only; no generated B-Rep, STL, editable mesh, or OCCT
    topology is introduced.
- Serialization checked?
  - Tests verify request JSON crosses the process client with feature intents.
- UI checked?
  - Full widget suite passes; the default app shell still uses the in-process
    mock service.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The process client is not yet wired into the default Flutter runtime.
  - Severity: Expected.
  - Next action: add an explicit backend switch only when a real worker or
    intentional developer mode needs it.
- Issue: `tool/mock_geometry_worker_client_smoke.dart` still uses mock geometry.
  - Severity: Expected.
  - Next action: replace the command target with native `occt_worker` once it
    exists.

### Next step
Commit and push M48, then continue toward a worker-backed `GeometryService`
adapter or the first native `occt_worker` executable slice.

### Notes for future Codex sessions
Keep worker failures as `GeometryResponse` issues. Native stderr, exit codes,
and process command details are diagnostics only; they must not become editable
project semantics or UI selection IDs.

---

## 2026-06-29 - M47 Mock worker protocol harness

### Goal
Exercise the worker JSON boundary through a local stdin/stdout harness before
the native OCCT executable exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_service.dart`,
`lib/geometry/geometry_protocol.dart`, `test/geometry_protocol_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/34_FIRST_GEOMETRY_SLICE.md`, and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_worker_protocol.dart`:
  - Added `GeometryWorkerProtocolHandler`.
  - Converts request JSON to response JSON.
  - Reports structured errors for invalid JSON, invalid top-level shape, and
    missing `project` payloads.
  - Uses a `buildGeometry` callback so the handler is backend-agnostic.
- `tool/mock_geometry_worker.dart`:
  - Added a Dart stdin/stdout smoke harness backed by `MockGeometryService`.
  - Returns exit code `2` when the geometry response contains errors.
- `lib/project/project_model.dart`:
  - Stopped exporting the Flutter/file-selector-backed dialog service so
    geometry/worker code can import the semantic model in a pure Dart CLI.
- `lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`, and
  `test/project_file_service_test.dart`:
  - Added explicit imports for `project_file_dialog_service.dart` where the
    desktop dialog helper is actually used.
- Docs/tasks/roadmap:
  - Recorded M47 behavior, smoke command, and the fact that the real native
    `occt_worker` executable is still future work.

### Tests run
- `flutter test test\geometry_protocol_test.dart`:
  - Passed, 12 tests.
- `Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run tool\mock_geometry_worker.dart`:
  - Passed; `exit=0`, `status=ok`, `backend=mock`.
- `'{not json' | dart run tool\mock_geometry_worker.dart`:
  - Passed; `exit=2`, `status=error`, code
    `worker.request.invalid_json`.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 135 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Protocol harness only; no generated B-Rep, STL, editable mesh, or OCCT
    topology is introduced.
- Serialization checked?
  - Geometry protocol tests cover worker JSON handling and invalid request
    responses.
- UI checked?
  - Full widget suite passes; no user-facing UI behavior changed.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: `tool/mock_geometry_worker.dart` is a Dart mock harness, not a native
  OCCT worker.
  - Severity: Expected.
  - Next action: implement the real native worker after the OCCT build path is
    ready.
- Issue: The sample protocol fixture does not yet include feature intents, so
  its mock `operationCount` is `0`.
  - Severity: Low.
  - Next action: add a richer protocol fixture when worker operation tests need
    request-time cutout/mount tasks.

### Next step
Commit and push M47, then continue toward the real worker adapter/native
`occt_worker` slice or a larger UI workflow chunk.

### Notes for future Codex sessions
Keep semantic model exports pure Dart. UI-only desktop services such as file
dialogs should be imported explicitly by UI/tests, not exported through
`project_model.dart`, because worker tooling needs to run with plain `dart run`.

---

## 2026-06-29 - M46 Geometry operation plan

### Goal
Convert geometry feature intents into deterministic backend operation tasks
without adding real OCCT/B-Rep generation yet.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_service.dart`, `test/geometry_protocol_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/33_COMPONENT_FEATURE_PROJECTION.md`,
and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_operation_plan.dart`:
  - Added `GeometryBuildOperation`.
  - Added `GeometryOperationPlanner.fromRequest`.
  - Maps semantic feature intents to backend operation kinds such as
    `cutout.usb_c` and `recess.glass`.
  - Maps button group items to `cutout.button` operations.
  - Maps standoff mount items to `mount.standoff` operations.
- `lib/geometry/geometry_service.dart`:
  - Exports the operation-plan API.
  - Mock backend reports `operationCount` and `operationPlan` metrics.
- `test/geometry_protocol_test.dart`:
  - Added deterministic operation-plan coverage.
  - Extended mock backend metrics coverage.
- Docs/tasks/roadmap:
  - Recorded M46 behavior and worker boundary expectations.

### Tests run
- `flutter test test\geometry_protocol_test.dart`:
  - Passed, 9 tests.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 132 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Operation planning only; no generated B-Rep, mesh, STL, or OCCT topology is
    stored.
- Serialization checked?
  - Geometry protocol tests cover request intents and operation-plan metrics.
- UI checked?
  - Full widget suite passes; no UI behavior changes are expected.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Operation plan is mock/backend planning data only.
  - Severity: Expected.
  - Next action: use these operations in a worker/adapter when real geometry
    generation begins.
- Issue: Operation kinds are first-pass labels, not final OCCT algorithm
  selection.
  - Severity: Expected.
  - Next action: refine operation kinds when implementing real cut/add/recess
    B-Rep steps.

### Next step
Commit and push M46, then continue toward worker/adapter consumption or the
next UI workflow slice.

### Notes for future Codex sessions
Operation plans are disposable backend task lists. Keep editable project state
semantic and grouped; do not persist operation-plan items as independent user
features.

---

## 2026-06-29 - M45 Geometry feature intent protocol

### Goal
Carry semantic feature and feature-group generation intent through
`GeometryRequest` so the future OCCT worker can consume prepared backend input
without depending on Flutter UI state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `lib/geometry/geometry_protocol.dart`,
`lib/geometry/geometry_service.dart`, `test/geometry_protocol_test.dart`,
`docs/03_ARCHITECTURE_OVERVIEW.md`, `docs/04_GEOMETRY_ENGINE_OCCT.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/33_COMPONENT_FEATURE_PROJECTION.md`,
and `occt_worker/README.md`.

### Changes made
- `lib/geometry/geometry_protocol.dart`:
  - Added `GeometryFeatureIntent` and `GeometryFeatureItemIntent`.
  - `GeometryRequest.previewMesh(project)` now includes semantic feature
    intents derived from `ProjectModel.features` and
    `ProjectModel.featureGroups`.
  - Feature-group intents preserve pattern/itemPrototype/placement/source data.
  - Button group and standoff mount intents include derived item positions for
    backend consumption.
- `lib/geometry/geometry_service.dart`:
  - Mock backend reports received feature-intent count in metrics.
- `test/geometry_protocol_test.dart`:
  - Added request round-trip coverage for semantic feature intents.
  - Added button group item expansion coverage.
  - Added standoff mount template-hole fallback expansion coverage.
- Docs/tasks/roadmap:
  - Recorded M45 protocol behavior and worker boundary expectations.

### Tests run
- `flutter test test\geometry_protocol_test.dart`:
  - Passed, 8 tests.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 131 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Protocol payload only; no real B-Rep/mesh generation was added.
- Serialization checked?
  - Geometry request JSON round-trip covers feature intents and group items.
- UI checked?
  - Full widget suite passes; no UI behavior changes are expected.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Feature intents are consumed only by the mock backend metrics for now.
  - Severity: Expected first-pass limitation.
  - Next action: teach the real worker/adapter to generate cutout and mount
    operations from these intents.
- Issue: Group item expansion is request-time derived data.
  - Severity: Intentional.
  - Next action: keep editable project semantics as groups and avoid persisting
    derived geometry items into project JSON.

### Next step
Commit and push M45, then continue toward geometry-service consumption of these
feature intents or the next UI/placement workflow chunk.

### Notes for future Codex sessions
`featureIntents` are disposable backend request data. They must not become the
editable source of truth and must not include OCCT topology IDs or preview mesh
triangle IDs.

---

## 2026-06-29 - M44 Projected anchor validation

### Goal
Make projected component anchors participate in semantic validation before real
geometry generation consumes them.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`,
`lib/validation/project_semantic_validator.dart`,
`test/project_semantic_validator_test.dart`,
`docs/33_COMPONENT_FEATURE_PROJECTION.md`, and validation/status docs.

### Changes made
- `lib/validation/project_semantic_validator.dart`:
  - Validates projected USB-C `surfacePosition` against target surface bounds.
  - Validates component-sourced button group switch positions against target
    surface bounds.
  - Warns when projected feature/group source placement/template/feature
    references are missing.
  - Warns when projected `surfaceAxes` are missing or mismatch the target
    surface.
- `test/project_semantic_validator_test.dart`:
  - Added outside-surface USB-C validation coverage.
  - Added outside-lid button group validation coverage.
  - Added missing-source projected feature warning coverage.
- Docs/tasks/roadmap:
  - Added M44 to `ROADMAP.md`.
  - Marked projected anchor validation done in `TASKS.md`.
  - Updated projection, testing, and shell validation docs.

### Tests run
- `flutter test test\project_semantic_validator_test.dart`:
  - Passed, 11 tests.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 129 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic validation only; no B-Rep, mesh, STL, or topology IDs are stored.
- Serialization checked?
  - Existing project JSON tests and projected metadata tests still pass.
- UI checked?
  - Full widget suite passes; validation status continues to consume semantic
    validator results.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Surface-bound validation uses the first enclosure body's inner extents.
  - Severity: Expected first-pass limitation.
  - Next action: make target enclosure explicit before multi-body generation.
- Issue: Validation checks bounds and source references, not physical
  reachability/travel/clearance yet.
  - Severity: Expected.
  - Next action: add reachability checks before real cutouts/plungers.

### Next step
Commit and push M44, then continue toward either projected-anchor-driven
geometry requests or richer component-driven cutout/button generation.

### Notes for future Codex sessions
Projected-anchor validation should stay semantic. Do not validate by reading
preview pixels, mesh triangles, or OCCT face IDs.

---

## 2026-06-29 - M43 Projected component feature anchors

### Goal
Add a semantic projection layer that turns placed component feature anchors into
world and target-surface coordinates for component-driven ports and buttons.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/10_ENCLOSURE_AUTO_GENERATION.md`, `docs/17_SWITCH_MAPPING_SYSTEM.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
`docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/component_features/component_feature_projection.dart`:
  - Added `ComponentFeatureSurfaceProjector` and `ComponentFeatureProjection`.
  - Applies component placement `rotationZ` and emits component-local, rotated,
    world, and surface positions.
  - Maps `front/back` to `x,z`, `left/right` to `y,z`, and `top/bottom` to
    `x,y` target surface coordinates.
- `lib/ui/shell/workspace_shell.dart`:
  - Uses the projector for component-sourced USB-C and switch button group
    commands.
  - Stores projected USB-C anchor metadata in `SemanticFeature.placement`.
  - Stores projected switch positions in
    `FeatureGroup.pattern.switchPositions`.
- Tests:
  - Added unit coverage for connector/switch projection and unsupported
    directions.
  - Extended widget-save coverage for projected USB-C and switch metadata.
- Docs/tasks/roadmap:
  - Added `docs/33_COMPONENT_FEATURE_PROJECTION.md`.
  - Recorded the M43 chunk and marked projected component feature anchors done.

### Tests run
- `flutter test test\component_feature_projection_test.dart`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component USB-C rail command creates sourced cutout"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 126 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Projection metadata only; no B-Rep, mesh, STL, or OCCT topology is stored.
- Serialization checked?
  - Widget tests save the project and verify projected anchor metadata in JSON.
- UI checked?
  - Existing component-sourced USB-C and button commands still open/confirm via
    widget tests.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Projection targets the first enclosure body.
  - Severity: Expected first-pass limitation.
  - Next action: add explicit target enclosure selection before multi-body
    generation.
- Issue: Projection records positions but does not yet perform reachability or
  boundary validation on the target face.
  - Severity: Expected.
  - Next action: add face-local validation before real cutouts/plungers.

### Next step
Commit and push M43, then continue toward validation/geometry consumption of
projected anchors.

### Notes for future Codex sessions
Projected anchor metadata is a semantic bridge only. Do not replace it with
mesh coordinates or OCCT topology IDs; future geometry should consume these
semantic coordinates through `GeometryService`.

---

## 2026-06-29 - M42 Component switch button group

### Goal
Let a selected semantic component placement create one editable button group from
its switch centers, while keeping the old surface-selected manual button group
flow intact.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, `docs/17_SWITCH_MAPPING_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, and the existing
command/widget/pattern tests.

### Changes made
- `lib/commands/command_registry.dart`:
  - Allows `button.create_group` from surface and component contexts.
- `lib/ui/shell/workspace_shell.dart`:
  - Keeps the manual surface-selected button group command.
  - Enables the button group command for selected component placements with
    switch features.
  - Creates a semantic `button_group` with source placement/template IDs and
    saved switch-center positions.
  - Preserves source pattern, placement, overrides, and metadata when the dialog
    confirms.
- `lib/patterns/pattern_layout.dart`:
  - Uses saved `switchPositions` for `from_component_switches` groups.
  - Keeps generated row/grid/diamond fallback layouts available after manual
    detach/edit.
- Tests:
  - Added command availability, pattern layout, detach, and widget-save coverage
    for component-sourced button groups.
- Docs/tasks/roadmap:
  - Recorded M42 behavior, limitations, tests, and poke checklist.

### Tests run
- `flutter test test\pattern_layout_test.dart --plain-name "button group positions prefer saved semantic switch centers"`:
  - Passed.
- `flutter test test\command_registry_test.dart --plain-name "button group command works from surface and component context"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component button command creates switch-sourced group"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "button group rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "button group rail command can be cancelled"`:
  - Passed.
- `flutter test test\pattern_layout_test.dart --plain-name "button group layout can detach from saved switch centers"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 123 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic pattern generation only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Widget test saves the project and verifies group source IDs plus switch
    positions in JSON.
- UI checked?
  - Widget tests cover old surface flow, cancel flow, and new selected-component
    flow.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The generated group stores template switch centers, but not yet
  projected face-local component coordinates.
  - Severity: Expected first-pass limitation.
  - Next action: add projected placement metadata before real geometry cuts.
- Issue: This creates a semantic editable button group; it does not yet cut real
  generated geometry.
  - Severity: Expected.
  - Next action: connect semantic feature groups to geometry service/OCCT worker
    later.

### Next step
Commit and push M42, then continue with the next component-to-semantic feature
slice or projected component feature placement data.

### Notes for future Codex sessions
Component-driven buttons must remain one editable `FeatureGroup`; do not flatten
switches into unrelated individual holes unless the user explicitly detaches the
group later.

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

---

## 2026-06-28 - M22 Reusable Pattern Layout Engine

### Goal
Move first-pass button-group pattern expansion out of the workspace shell into
a reusable deterministic module that future geometry generation can consume.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/33_VIEWPORT_MVP.md`, workspace shell, viewport controller, and widget/
viewport tests.

### Changes made
- `lib/patterns/pattern_layout.dart`:
  - Added viewport-independent `PatternPoint`.
  - Added `PatternLayoutEngine` for `button_group` local point expansion.
  - Supports first-pass `diamond`, `row`, and `grid` layouts with deterministic
    clamping/fallback behavior.
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced local button pattern math with `PatternLayoutEngine`.
  - Kept mock viewport marker conversion as UI-only `Offset` mapping.
- `test/pattern_layout_test.dart`:
  - Added deterministic unit coverage for diamond, grid, fallback/clamping, and
    reading semantic `FeatureGroup.pattern` data.
- `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`, and
  `docs/33_VIEWPORT_MVP.md`:
  - Documented M22 and the boundary between semantic pattern expansion and
    viewport marker rendering.

### Tests run
- `flutter test test\pattern_layout_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 39 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 86 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Layout expansion is deterministic local semantic data only; no generated
    B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; generated pattern points are not saved.
- UI checked?
  - Widget/viewport tests confirm existing marker selection behavior still
    passes through the mock viewport.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The reusable layout engine covers button `diamond`, `row`, and `grid`
  only.
  - Severity: Expected for this slice.
  - Next action: add square/circle/arc/path expansion when those semantic
    pattern types are introduced.
- Issue: Standoff hole positions are still read by the shell from source
  mounting-hole data.
  - Severity: Expected.
  - Next action: move source-anchor expansion into a reusable component-driven
    layout helper when geometry generation starts consuming standoff groups.

### Next step
Commit and push M22, then continue toward reusable source-anchor layout or the
next safe semantic geometry-prep slice.

### Notes for future Codex sessions
Pattern expansion should remain reusable and deterministic. Do not reintroduce
layout math into widgets or painters when adding geometry generation.

---

## 2026-06-28 - M23 Reusable Standoff Source Layout

### Goal
Move first-pass standoff source mounting-hole expansion out of the workspace
shell and into the reusable pattern/layout module.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
`docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/patterns/pattern_layout.dart`, workspace shell, viewport controller, and
widget/viewport/pattern tests.

### Changes made
- `lib/patterns/pattern_layout.dart`:
  - Added `PatternLayoutEngine.standoffMountPositions`.
  - Resolves saved semantic `FeatureGroup.pattern.holePositions`.
  - Falls back to `ComponentTemplate.mountingHoles` when saved source positions
    are absent.
  - Skips malformed saved positions instead of crashing preview generation.
- `lib/ui/shell/workspace_shell.dart`:
  - Replaced local standoff source-hole parsing with `PatternLayoutEngine`.
  - Kept mock viewport conversion as UI-only `Offset` mapping.
- `test/pattern_layout_test.dart`:
  - Added deterministic coverage for saved standoff source positions and
    component-template fallback positions.
- `ROADMAP.md`, `TASKS.md`, `docs/09_PATTERN_AND_LAYOUT_SYSTEM.md`,
  `docs/11_MOUNTING_AND_RETENTION_SYSTEM.md`, and `docs/33_VIEWPORT_MVP.md`:
  - Documented M23 and the boundary between semantic source-anchor expansion
    and viewport marker rendering.

### Tests run
- `flutter test test\pattern_layout_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 41 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages still have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 88 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed `releases/latest/windows/shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Standoff source expansion is deterministic local semantic data only; no
    generated B-Rep or mesh is created yet.
- Serialization checked?
  - No schema change; generated pattern points are not saved.
- UI checked?
  - Widget/viewport tests confirm existing standoff marker selection behavior
    still passes through the mock viewport.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Source-anchor expansion only covers component mounting holes.
  - Severity: Expected for this slice.
  - Next action: add source anchors for ports, switches, and keepouts when
    component-driven cutout generation begins.
- Issue: The mock viewport still owns screen-space marker placement.
  - Severity: Expected.
  - Next action: keep only semantic/local layout in reusable modules and move
    real geometry projection into the geometry service when OCCT preview starts.

### Next step
Commit and push M23, then continue toward the next safe semantic geometry-prep
slice.

### Notes for future Codex sessions
Standoff mount positions should keep coming from semantic group/template data.
Do not use generated mesh, triangle, or OCCT topology IDs for source anchors.

---

## 2026-06-28 - M24 First Semantic Validation Warnings

### Goal
Add the first project-level semantic validation pass before real OCCT geometry
exists, and surface warnings/errors in the shell status bar.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, validation model, geometry service,
workspace shell status bar, project semantic models, and geometry/widget tests.

### Changes made
- `lib/validation/project_semantic_validator.dart`:
  - Added first-pass semantic project validation.
  - Validates enclosure dimensions, thin walls, excessive wall thickness, and
    large corner radius.
  - Validates USB-C and glass recess dimensions/radii against the main
    enclosure.
  - Validates standoff mount source positions and hole/diameter safety.
- `lib/validation/validation_result.dart`:
  - Added warning detection and primary issue selection.
- `lib/geometry/geometry_service.dart`:
  - Wired mock `validateGeometry` to semantic validation instead of a static
    info-only placeholder.
- `lib/ui/shell/workspace_shell.dart`:
  - Added visible warning status-bar state with the first warning message.
- Tests:
  - Added semantic validator unit coverage.
  - Added geometry-service validation coverage.
  - Added widget coverage for visible warning status.
- Docs/tasks/roadmap:
  - Documented M24 and the pre-geometry validation boundary.

### Tests run
- `flutter test test\project_semantic_validator_test.dart test\geometry_protocol_test.dart test\widget_test.dart`:
  - Passed, 38 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 94 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Validation is semantic/pre-geometry only; no generated B-Rep or mesh is
    created.
- Serialization checked?
  - No schema change; validation messages are derived and not saved.
- UI checked?
  - Widget test confirms a thin-wall warning appears in the bottom status bar.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Semantic validation only checks the first-pass enclosure, USB-C, glass
  recess, and standoff mount constraints.
  - Severity: Expected for this slice.
  - Next action: add placement/keepout/face-local validation as those workflows
    become semantic.
- Issue: Status bar shows only the first warning/error.
  - Severity: Expected.
  - Next action: add a validation popover/panel when multiple messages become
    common.

### Next step
Commit and push M24, then continue toward the next safe validation/geometry
preparation slice.

### Notes for future Codex sessions
Validation must remain semantic before geometry generation. Do not use preview
triangle IDs, mesh IDs, or OCCT topology as validation targets in the default
workflow.

---

## 2026-06-29 - M25 Validation Details + Placement Bounds

### Goal
Make validation issues inspectable from the shell status bar and add first-pass
semantic component placement/keepout bounds checks before real OCCT geometry
exists.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `ProjectSemanticValidator`,
`ValidationReport`, component template/placement models, workspace shell status
bar, and validator/widget tests.

### Changes made
- `lib/validation/validation_result.dart`:
  - Added reusable `issues`, `errors`, `warnings`, and `hasIssues` accessors.
  - Kept `primaryIssue` error-first, then warning-first.
- `lib/validation/project_semantic_validator.dart`:
  - Validates missing component templates.
  - Validates placed component board outline/thickness against enclosure inner
    volume.
  - Validates component feature `keepout` boxes as non-blocking warnings.
- `lib/ui/shell/workspace_shell.dart`:
  - Added a compact status-bar details button when validation has issues.
  - Added a bottom sheet listing issue counts and all current warning/error
    messages.
- Tests:
  - Added unit coverage for placement-outside, missing-template, and keepout
    warnings.
  - Added widget coverage for opening the validation details sheet.
- Docs/tasks/roadmap:
  - Documented M25, first-pass placement/keepout validation, and the issue
    details UI.

### Tests run
- `flutter test test\project_semantic_validator_test.dart test\widget_test.dart`:
  - Passed, 36 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 98 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Validation is still semantic/pre-geometry only; no generated B-Rep or mesh
    is created.
- Serialization checked?
  - No schema change; validation messages remain derived state and are not
    saved.
- UI checked?
  - Widget test confirms the status-bar details button opens a list of all
    current warning/error messages.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Component bounds treat board outlines and keepouts as axis-aligned
  rectangles; placement rotation is not considered yet.
  - Severity: Expected for this pre-geometry slice.
  - Next action: add face-local placement and rotated bounds when placement
    workflow becomes viewport-driven.
- Issue: Validation details show target IDs but do not yet focus/select the
  affected object.
  - Severity: Expected.
  - Next action: wire issue rows to semantic selection after issue targets are
    normalized.

### Next step
Commit and push M25, then continue toward the next safe geometry-service or
viewport-prep slice.

### Notes for future Codex sessions
Keep validation issue targets semantic. Do not point issue rows at preview
triangles, generated mesh IDs, or OCCT topology.

---

## 2026-06-29 - M26 Validation Issue Target Selection

### Goal
Make validation issue rows navigate back to their semantic target so warnings
and errors are actionable from the details sheet.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `SelectionModel`,
`ProjectSelectionResolver`, `ValidationReport`, workspace shell status/details
UI, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added semantic validation-target resolution from `targetId` to
    `SelectionModel`.
  - Resolves direct enclosure, component placement, component template, feature,
    and feature group targets.
  - Resolves nested targets such as `button_board_placement.usb_c` to their
    semantic parent.
  - Keeps surface-like targets semantic by mapping body-prefixed IDs to surface
    selection.
  - Made validation issue rows selectable when a semantic target can be
    resolved.
  - Selecting a row closes the details sheet and updates the main shell
    selection.
- Tests:
  - Added widget coverage that clicks a validation issue row and verifies the
    target feature inspector opens.
- Docs/tasks/roadmap:
  - Documented M26 and the semantic target-selection behavior.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 30 widget tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 99 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; this is semantic UI navigation only.
- Serialization checked?
  - No schema change.
- UI checked?
  - Widget test confirms issue row selection closes the sheet and opens the
    target feature inspector.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Validation issue rows select semantic targets but do not yet provide
  one-click fix actions.
  - Severity: Expected.
  - Next action: add guided fixes after more validation rules stabilize.
- Issue: Nested component feature targets resolve to the parent placement, not
  to a per-feature component sub-selection.
  - Severity: Expected for the current selection model.
  - Next action: add component sub-feature selection when the component editor
    exists.

### Next step
Commit and push M26, then continue toward the next safe geometry-service or
viewport-prep slice.

### Notes for future Codex sessions
Validation navigation must remain semantic. Do not route issue rows through
preview triangle IDs, generated mesh IDs, or OCCT topology names.

---

## 2026-06-29 - M27 Component Placement Inspector Editing

### Goal
Make selected component placements directly editable from the contextual
inspector so validation errors can be corrected without reopening the placement
dialog.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `ComponentPlacement`,
`ProjectModel.replaceComponentPlacement`, parameter model helpers, workspace
shell inspector/editor code, and widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added a compact placement parameter schema for X/Y/Z, mounting side, and
    locked state.
  - Added a component placement editor to the contextual inspector.
  - Added a reusable boolean parameter field for the locked flag.
  - Added semantic placement update helpers that preserve stable placement IDs,
    template IDs, rotation, and metadata.
  - Routed placement inspector edits through `UndoHistory<ProjectModel>` and
    existing preview/validation refresh.
- Tests:
  - Added widget coverage for selecting a component placement, editing X,
    surfacing a validation error, and undoing the edit.
- Docs/tasks/roadmap:
  - Documented M27 and the placement editor workflow.

### Tests run
- `flutter test test\widget_test.dart`:
  - Passed, 31 widget tests.
- `flutter pub get`:
  - Passed; 4 packages have newer incompatible versions.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 100 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; placement editing is semantic UI/state work.
- Serialization checked?
  - No schema change; edited placements remain standard `ComponentPlacement`
    JSON fields.
- UI checked?
  - Widget test confirms placement edit, validation refresh, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Placement editor still uses typed values instead of viewport picking,
  snapping, or face-local handles.
  - Severity: Expected.
  - Next action: add viewport-driven placement after local workplane/snapping
    foundations are ready.
- Issue: Placement rotation is still read-only in this slice.
  - Severity: Expected.
  - Next action: add rotation controls once rotated bounds are validated.
- Issue: Locked placement state is stored but not yet enforced by all editing
  pathways.
  - Severity: Expected.
  - Next action: define lock semantics before adding viewport placement tools.

### Next step
Commit and push M27, then continue toward the next safe viewport-prep or
geometry-service slice.

### Notes for future Codex sessions
Component placement edits must keep semantic placement IDs stable. Do not use
preview mesh positions or OCCT topology as editable placement state.

---

## 2026-06-29 - M28 Component Placement Rotation + Lock Guard

### Goal
Add Z rotation editing for component placements, make first-pass placement
validation account for that rotation, and make the locked state block placement
edits.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, component placement inspector/editor
code, `ProjectSemanticValidator`, component placement model, and validator/widget
tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Поворот Z` to the component placement inspector.
  - Added rotation update helpers that preserve stable placement IDs and typed
    semantic placement fields.
  - Added disabled-state support to shared number and choice parameter
    controls.
  - Disabled position/rotation/side controls while a placement is locked.
  - Kept the locked checkbox active so a locked placement can be unlocked.
  - Ignored non-lock placement parameter edits in shell state when the placement
    is locked.
- `lib/validation/project_semantic_validator.dart`:
  - Added rotation-aware board and keepout envelope checks for first-pass
    semantic component placement validation.
- Tests:
  - Added unit coverage for rotation-aware component placement bounds.
  - Extended widget coverage for Z rotation edit/undo.
  - Added widget coverage for locked placement fields and unlock behavior.
- Docs/tasks/roadmap:
  - Documented M28, rotation-aware validation, and first-pass lock behavior.

### Tests run
- `flutter test test\project_semantic_validator_test.dart test\widget_test.dart`:
  - Passed, 40 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 102 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Validation is still semantic/pre-geometry only; no generated B-Rep or mesh
    is created.
- Serialization checked?
  - No schema change; edited rotation/lock remain standard
    `ComponentPlacement` JSON fields.
- UI checked?
  - Widget tests confirm Z rotation edit/undo and locked-field behavior.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Rotation-aware validation uses conservative 2D bounding boxes, not
  exact geometry.
  - Severity: Expected.
  - Next action: replace with geometry-service validation when OCCT preview
    generation exists.
- Issue: Only Z rotation is editable.
  - Severity: Expected for board-like component placement.
  - Next action: add richer orientation controls if component workflows need
    non-planar placement.
- Issue: Locking blocks inspector edits but there are no viewport placement
  handles to lock yet.
  - Severity: Expected.
  - Next action: reuse lock state when viewport-driven placement is introduced.

### Next step
Commit and push M28, then continue toward the next safe viewport or geometry
service slice.

### Notes for future Codex sessions
Keep placement rotation and lock semantics in the semantic `ComponentPlacement`.
Do not infer editable placement state from preview mesh transforms or OCCT
topology.

---

## 2026-06-29 - M29 Component Placement Visibility

### Goal
Add a semantic visibility toggle for component placements so a placement can be
hidden from the mock viewport without deleting it from the editable project.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, component placement model, workspace
shell inspector/browser/viewport code, `ViewportController`, and related
model/viewport/widget tests.

### Changes made
- `lib/project/component_placement.dart`:
  - Added typed `visible` state with default `true`.
  - Kept older project JSON compatible by defaulting missing `visible` to
    `true`.
  - Preserved unknown placement metadata while excluding the typed `visible`
    field from metadata.
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Показывать` to the component placement inspector.
  - Preserved visibility through placement position, rotation, side, and lock
    edits.
  - Allowed visibility changes even while a placement is locked.
  - Marked hidden placements in the project browser with a visibility-off icon.
  - Built mock component placement previews from semantic placements and
    component template board outlines.
  - Omitted hidden placements from mock viewport drawing and hit-testing.
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportComponentPlacementPreview`.
  - Routed component placement hit-testing through supplied semantic placement
    previews instead of only one hard-coded board ID.
- `lib/selection/project_selection_resolver.dart`:
  - Added placement visibility to selection details.
- Tests:
  - Added placement visibility serialization coverage.
  - Added mock viewport hit-test coverage for omitted component previews.
  - Added widget coverage for visibility toggle, hidden hit target, and undo.
- Docs/tasks/roadmap:
  - Documented M29, component placement visibility, semantic viewport previews,
    and test expectations.

### Tests run
- `flutter test test\project_model_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Passed, 53 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 105 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Mock viewport drawing/hit-testing only; no generated B-Rep or mesh is
    created.
- Serialization checked?
  - Unit tests cover default `visible: true` for older JSON and hidden placement
    round-trip.
- UI checked?
  - Widget test confirms hide/show state, viewport hit omission, and undo.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Hidden component placement hides only the mock board placement marker;
  generated feature groups such as standoffs are still separate semantic objects.
  - Severity: Expected.
  - Next action: decide later whether component-driven generated objects need
    their own visibility/group isolation controls.
- Issue: Component placement preview is still a schematic rectangle.
  - Severity: Expected.
  - Next action: replace with geometry-service preview data when OCCT generated
    board/reference geometry exists.

### Next step
Commit and push M29, then continue toward the next safe viewport or placement
workflow slice.

### Notes for future Codex sessions
Keep `ComponentPlacement.visible` as semantic display state. Do not infer hidden
or visible placement state from preview mesh presence.

---

## 2026-06-29 - M30 Local Workplane Overlay + Snap Hints

### Goal
Add a transient local workplane overlay and first snap hints for selected
surfaces/component placements, preparing the mock viewport for later
viewport-driven placement edits.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `ViewportController`,
`workspace_shell.dart` viewport painter/wiring, and viewport/widget tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `MockViewportWorkplaneKind` and `MockViewportWorkplaneOverlay`.
  - Added deterministic workplane rectangle and snap-point mapping helpers.
  - Extracted `frontWallRect` into `MockViewportLayout` so hit-testing and
    overlays share the same mock layout source.
- `lib/ui/shell/workspace_shell.dart`:
  - Builds active workplane overlays from the current semantic selection.
  - Shows surface overlays for `Top lid` and `Front wall`.
  - Shows component-placement overlays for visible placements.
  - Uses component template mounting holes plus board center as first snap
    hints.
  - Draws a subtle workplane grid and snap dots without changing
    `ProjectModel`.
  - Removes the placement overlay when the placement is hidden.
- Tests:
  - Added viewport layout coverage for surface snap mapping.
  - Added viewport layout coverage for rotated component placement snap hints.
  - Added widget coverage for surface/placement selection overlay wiring and
    hidden placement overlay removal.
- Docs/tasks/roadmap:
  - Documented M30, workplane overlay behavior, snap hints, and test
    expectations.

### Tests run
- `flutter test test\viewport_controller_test.dart test\widget_test.dart`:
  - Failed once due to a stale test expectation that compared the new semantic
    placement workplane center with the old hard-coded mock board rect.
  - Passed after correcting the expectation, 45 targeted tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 108 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.

### Validation
- Geometry checked?
  - Mock viewport layout only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; overlay state is transient UI state and is not saved.
- UI checked?
  - Widget tests confirm overlay wiring for surface/placement selection and
    removal when a placement is hidden.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Snap hints are visual only and do not yet drive placement edits.
  - Severity: Expected.
  - Next action: use these snap points when adding viewport-driven placement
    workflows.
- Issue: Workplanes are still mock 2.5D rectangles, not OCCT face-local planes.
  - Severity: Expected.
  - Next action: map generated geometry faces back to semantic surfaces through
    `GeometryService` later.

### Next step
Commit and push M30, then continue toward viewport-driven placement or snapping
workflow edits.

### Notes for future Codex sessions
Keep workplane overlays transient. They may guide semantic edits later, but
should not become saved sketch geometry or generated topology references.

---

## 2026-06-29 - M31 Snap Picking Seeds Component Placement

### Goal
Turn mock viewport snap hints into selectable transient placement seeds without
saving snap UI state into the semantic project model.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/viewport/viewport_controller.dart`, `lib/ui/shell/workspace_shell.dart`,
and existing command/viewport/widget tests.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added `ViewportHitKind.snapPoint` and snap hit metadata.
  - Added active workplane hit-testing.
  - Kept visible semantic objects above overlapping snap hints, while snap
    hints still win over bare surface hits.
- `lib/ui/shell/workspace_shell.dart`:
  - Added transient active snap target state.
  - Selects and highlights clicked snap hints.
  - Seeds the component placement dialog from active snap target X/Y/Z and
    mounting side.
  - Shows a snap label in the placement dialog.
  - Clears stale snap targets on normal selection, semantic edits, undo, and
    redo.
- `lib/commands/command_registry.dart`:
  - Allows `component.place` from surface context for snap-driven placement
    flow.
- Tests:
  - Added command availability coverage for surface-context component
    placement.
  - Added viewport coverage for snap-point hits and snap/object hit priority.
  - Added widget coverage for selecting a surface snap point and opening a
    seeded placement dialog.
- Docs/tasks/roadmap:
  - Recorded M31 behavior, test expectations, and the manual poke checklist.

### Tests run
- `flutter test test\command_registry_test.dart test\viewport_controller_test.dart test\widget_test.dart`:
  - Failed once while tightening the widget test and revealed that overlapping
    center snap hints could block selecting a restored visible placement.
  - Passed after adjusting hit-test priority.
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component placement visibility toggle hides viewport hit target"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 111 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport hit-testing only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; active snap target state is transient and not saved.
- UI checked?
  - Widget tests confirm snap picking seeds the placement dialog and visible
    component placement remains selectable over overlapping snap hints.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Snap-seeded placement still opens a dialog rather than supporting
  drag-to-place or click-to-confirm directly in the viewport.
  - Severity: Expected.
  - Next action: add the next guided placement slice with live preview and
    confirm/cancel controls.
- Issue: Snap points are still mock local workplane points, not OCCT face-local
  coordinates.
  - Severity: Expected.
  - Next action: replace mock mapping through `GeometryService` when generated
    geometry picking exists.

### Next step
Commit and push M31, then continue toward guided component placement workflow
or component anchor/connector mapping.

### Notes for future Codex sessions
Snap target state belongs to the shell only. Keep the saved project semantic:
component placements store normal position/rotation/mounting side data, not
snap indices or viewport hit IDs.

---

## 2026-06-29 - M32 Active Snap Inspector Action

### Goal
Make the currently selected snap hint visible and actionable from the contextual
inspector, while keeping snap selection as transient UI state.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/ui/shell/workspace_shell.dart`, and snap/widget tests from M31.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added an active snap target inspector section.
  - Shows snap label, seeded project position, and human mounting side.
  - Adds a direct `Разместить компонент` action that opens the existing
    snap-seeded placement dialog.
  - Adds a clear action that removes only transient snap UI state.
- `test/widget_test.dart`:
  - Added coverage for opening placement from the active snap inspector action.
  - Added coverage for clearing the active snap target from the inspector.
  - Added a helper for deterministic top-lid snap tapping in widget tests.
- Docs/tasks/roadmap:
  - Recorded M32 behavior, task status, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target can be cleared from inspector"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 113 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport interaction only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; active snap target state is transient and not saved.
- UI checked?
  - Widget tests confirm the inspector action opens the seeded placement dialog
    and clear removes the snap section.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The inspector action still enters a dialog-based placement flow, not a
  direct viewport confirm/cancel workflow.
  - Severity: Expected.
  - Next action: add live preview/confirm placement as a later guided-placement
    slice.
- Issue: Active snap positions are still mock workplane positions.
  - Severity: Expected.
  - Next action: move to geometry-service face-local picking when real preview
    geometry exists.

### Next step
Commit and push M32, then continue toward guided viewport placement or semantic
component anchors.

### Notes for future Codex sessions
The active snap inspector should remain a context affordance, not saved model
state. Confirmed placements should continue to store normal
`ComponentPlacement` values.

---

## 2026-06-29 - M33 Snap Placement Footprint Preview

### Goal
Show a transient viewport footprint for the component that would be placed from
the active snap target.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/ui/shell/workspace_shell.dart`, and snap/widget tests from M31-M32.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Builds a mock active snap placement preview from the first component
    template and active snap target.
  - Draws a translucent component footprint at the snap-seeded position.
  - Keeps the footprint out of hit testing and out of `ProjectModel`.
  - Removes the footprint when the active snap target is cleared.
- `test/widget_test.dart`:
  - Extended snap widget coverage to assert the footprint preview appears after
    snap selection and disappears after clearing.
- Docs/tasks/roadmap:
  - Recorded M33 behavior, done criteria, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target can be cleared from inspector"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 113 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport drawing only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; footprint preview is transient and not saved.
- UI checked?
  - Widget tests confirm preview presence and clearing behavior.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The footprint is a schematic rectangle from the component template
  board outline, not generated board geometry.
  - Severity: Expected.
  - Next action: replace with geometry-service preview once real board/component
    preview data exists.
- Issue: The footprint does not yet show collision or clearance feedback.
  - Severity: Expected.
  - Next action: add validation-aware placement preview in a later guided
    placement slice.

### Next step
Commit and push M33, then continue toward full guided component placement or
semantic component anchors.

### Notes for future Codex sessions
Keep active snap footprint previews transient. They should guide the next
semantic action but never become editable saved placement data by themselves.

---

## 2026-06-29 - M34 Snap Placement Fit Feedback

### Goal
Show semantic fit feedback for snap-seeded component placement previews before
the user commits a new placement.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/validation/project_semantic_validator.dart`, `lib/ui/shell/workspace_shell.dart`,
and snap/widget tests from M31-M33.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Builds a temporary prospective `ComponentPlacement` from the active snap
    target.
  - Runs that placement through `ProjectSemanticValidator` without saving it.
  - Filters preview validation to messages targeted at the temporary placement.
  - Shows a compact fit/status row in the active snap inspector panel.
  - Tints the transient viewport footprint by validation severity.
- `test/widget_test.dart`:
  - Added coverage for the normal snap placement fit state.
  - Added coverage for an oversized component template that would fail before
    placement is committed.
- Docs/tasks/roadmap:
  - Recorded M34 behavior, limitations, test expectations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target can be cleared from inspector"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap placement check reports oversized footprint"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Initially reported `test/widget_test.dart` needed formatting; passed after
    formatting.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 114 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport drawing and semantic bounds validation only; no generated
    B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; prospective placement and fit status are transient and not
    saved.
- UI checked?
  - Widget tests confirm normal fit feedback and oversized preview warning.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Fit feedback uses coarse semantic placement bounds, not real generated
  geometry/collision.
  - Severity: Expected.
  - Next action: replace or augment with geometry-service collision/clearance
    checks when real preview geometry exists.
- Issue: Only the first component template is previewed from active snap state.
  - Severity: Expected.
  - Next action: connect template selection to live preview in a later placement
    flow slice.

### Next step
Commit and push M34, then continue toward guided component placement or
component anchor mapping.

### Notes for future Codex sessions
Use temporary semantic objects for preview validation. Do not store preview IDs,
snap indices, or validation state in `ProjectModel`.

---

## 2026-06-29 - M35 Placement Dialog Live Fit Check

### Goal
Show semantic fit feedback inside the component placement dialog while the user
edits candidate placement values.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `lib/ui/shell/workspace_shell.dart`, and placement
widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Passes the current semantic project into `_PlaceComponentDialog`.
  - Builds the current dialog candidate as a temporary `ComponentPlacement`.
  - Reuses prospective placement validation for dialog X/Y/Z/template values.
  - Shows a compact fit/status row in the dialog.
  - Keeps dialog validation as feedback only; commit still happens only after
    `Разместить`.
- `test/widget_test.dart`:
  - Added coverage that the dialog starts with a valid fit message.
  - Added coverage that editing X outside the enclosure reports a semantic
    placement error before commit.
- Docs/tasks/roadmap:
  - Recorded M35 behavior, done criteria, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 115 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic bounds validation only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; dialog candidate validation is transient and not saved.
- UI checked?
  - Widget tests confirm valid and invalid candidate dialog states.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Dialog fit feedback still uses coarse semantic bounds, not real
  generated geometry/collision.
  - Severity: Expected.
  - Next action: add geometry-service clearance checks when generated preview
    geometry exists.
- Issue: The dialog does not yet update the viewport footprint live while fields
  are edited.
  - Severity: Expected.
  - Next action: connect dialog edits to a live viewport placement session if we
    move beyond modal placement.

### Next step
Commit and push M35, then continue toward guided component placement or
component anchor mapping.

### Notes for future Codex sessions
Keep validation feedback transient until the user confirms a semantic placement.
Temporary candidate objects are fine for validation, but should not be persisted.

---

## 2026-06-29 - M36 Placement Dialog Viewport Candidate

### Goal
Mirror the component placement dialog candidate into the viewport while the
dialog is open, then clear that transient preview on cancel or confirm.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/31_COMMANDS_AND_UNDO.md`,
`docs/32_USABLE_SHELL.md`, `docs/33_VIEWPORT_MVP.md`,
`lib/ui/shell/workspace_shell.dart`, and placement widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added shell-level transient `ComponentPlacement?` candidate state for the
    placement dialog.
  - Seeds the candidate before the dialog opens.
  - Updates the candidate when dialog template/X/Y/Z/side/lock values change.
  - Reuses the existing candidate footprint painter path for dialog previews.
  - Clears candidate state on cancel and confirm before any semantic commit.
- `test/widget_test.dart`:
  - Added coverage that candidate footprint appears while the dialog is open.
  - Added coverage that the footprint clears on confirm.
  - Added coverage that the footprint clears on cancel without committing a
    component.
- Docs/tasks/roadmap:
  - Recorded M36 behavior, transient-state rules, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component rail command can be cancelled"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 115 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport drawing only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; dialog candidate state is transient and not saved.
- UI checked?
  - Widget tests confirm candidate preview appears and clears on cancel/confirm.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The modal dialog can visually cover part of the viewport footprint.
  - Severity: Expected.
  - Next action: move toward a non-modal guided placement flow when the
    viewport interaction model is ready.
- Issue: The candidate preview remains schematic and not collision-aware beyond
  semantic fit checks.
  - Severity: Expected.
  - Next action: connect to geometry-service clearance/collision checks later.

### Next step
Commit and push M36, then continue toward guided component placement or
component anchor mapping.

### Notes for future Codex sessions
`_placementDialogCandidate` is UI-only state. Do not serialize it, include it in
undo history, or let it become a real placement unless the dialog returns a
confirmed `ComponentPlacement`.

---

## 2026-06-29 - M37 Placement Template Size Summary

### Goal
Show selected component template board dimensions in the placement dialog so
candidate fit feedback is easier to interpret.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`lib/ui/shell/workspace_shell.dart`, and placement dialog widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Resolves the currently selected component template in the placement dialog.
  - Adds a compact board summary under the template selector.
  - Shows board width, height, and thickness.
  - Shows a missing-template fallback if the selected ID cannot be resolved.
- `test/widget_test.dart`:
  - Added coverage for the sample board dimension summary in the placement
    dialog.
- Docs/tasks/roadmap:
  - Recorded M37 behavior, done criteria, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 115 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Not applicable; this is read-only semantic template UI.
- Serialization checked?
  - Not applicable; no project data changed.
- UI checked?
  - Widget test confirms the dimension summary is rendered.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The dialog still has only one sample component template in the default
  project.
  - Severity: Expected.
  - Next action: add template editing/loading before broader template selection
    polish matters.
- Issue: The summary is textual only; no board-specific mini preview yet.
  - Severity: Low.
  - Next action: use the viewport footprint as the primary visual preview for
    now.

### Next step
Commit and push M37, then continue toward guided placement or component anchor
mapping.

### Notes for future Codex sessions
Template summaries are read-only UI hints. Keep editable component template
work as a separate subsystem with its own tests/docs when it begins.

---

## 2026-06-29 - M38 Placement Quick Presets

### Goal
Make component placement faster by adding quick position controls to the
placement dialog while keeping the workflow semantic and undo-safe.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`docs/26_TESTING_AND_QUALITY.md`, `lib/ui/shell/workspace_shell.dart`, and
placement dialog widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added compact quick position icon controls to the component placement
    dialog.
  - Derives center/side offsets from the selected template board footprint and
    current enclosure inner dimensions.
  - Updates the transient dialog candidate, viewport candidate footprint, and
    semantic fit check when a preset is clicked.
  - Converted dialog number fields from `initialValue` to controller-backed
    fields so programmatic candidate updates are shown immediately.
- `test/widget_test.dart`:
  - Added coverage for quick preset candidate updates and confirmed semantic
    placement creation.
- Docs/tasks/roadmap:
  - Recorded M38 behavior, done criteria, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog quick presets update candidate position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 116 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport candidate only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Not applicable; quick preset state is transient and only confirmed
    placement enters semantic project JSON.
- UI checked?
  - Widget test confirms a quick preset updates the dialog field, keeps the
    candidate preview alive, and commits a normal `ComponentPlacement`.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Quick presets are center/side shortcuts, not direct drag placement.
  - Severity: Expected.
  - Next action: continue toward guided viewport placement.
- Issue: Presets use board footprint and enclosure inner dimensions; deeper
  component keepout/collision polish remains semantic validation feedback.
  - Severity: Expected.
  - Next action: improve component anchors and geometry-service checks later.

### Next step
Commit and push M38, then continue toward guided component placement with
viewport picking or component anchor mapping.

### Notes for future Codex sessions
Quick preset controls must stay transient UI affordances. Do not serialize
them or create undo entries until the dialog returns a confirmed
`ComponentPlacement`.

---

## 2026-06-29 - M39 Placement Dialog Rotation

### Goal
Let component placement rotation be chosen before commit so the dialog
candidate, viewport preview, and semantic fit check match the final placement
orientation.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/32_USABLE_SHELL.md`,
`docs/26_TESTING_AND_QUALITY.md`, `lib/ui/shell/workspace_shell.dart`,
`lib/viewport/viewport_controller.dart`, and placement dialog widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Поворот Z` state to the component placement dialog.
  - Added compact rotate-left/rotate-right 90 degree icon controls.
  - Feeds dialog rotation into the transient `ComponentPlacement` candidate.
  - Reuses existing rotation-aware semantic validation and mock viewport
    preview drawing.
  - Preserves the normal semantic commit path: rotation is saved only when the
    dialog returns a confirmed placement.
- `test/widget_test.dart`:
  - Added coverage proving a placement that fails at X=36 becomes valid after
    a 90 degree rotation and commits with `rotationZ = 90`.
- Docs/tasks/roadmap:
  - Recorded M39 behavior, done criteria, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "place component dialog rotation updates candidate fit and commit"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog quick presets update candidate position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog validates current candidate placement"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 117 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport candidate only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Rotation is already part of semantic `ComponentPlacement`; no schema change
    was needed.
- UI checked?
  - Widget test confirms rotation changes fit feedback and committed inspector
    state.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: Rotation controls are still dialog-based, not direct viewport drag or
  handle editing.
  - Severity: Expected.
  - Next action: continue toward guided viewport placement.
- Issue: Fit feedback remains semantic envelope validation, not full collision
  or generated geometry validation.
  - Severity: Expected.
  - Next action: improve geometry-service checks after worker progress.

### Next step
Commit and push M39, then continue toward guided component placement with
viewport picking or component anchor mapping.

### Notes for future Codex sessions
Dialog rotation is transient until confirmation. Keep preview/candidate state
out of undo history and project JSON unless the dialog commits a real
`ComponentPlacement`.

---

## 2026-06-29 - M40 Snap Anchor Placement

### Goal
Let snap-seeded component placement align a chosen semantic component anchor,
such as a mounting hole, USB-C connector, or switch center, to the selected
surface snap point before commit.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/32_USABLE_SHELL.md`, `docs/26_TESTING_AND_QUALITY.md`,
`lib/ui/shell/workspace_shell.dart`, and snap/placement widget tests.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Passes the active snap target into the component placement dialog.
  - Builds transient anchor choices from the selected template center,
    mounting holes, and semantic component features.
  - Adds a compact `Якорь к точке` selector when placement starts from a snap.
  - Recalculates candidate X/Y so the selected anchor lands on the snap point.
  - Keeps anchor-lock active across rotation until the user manually changes
    X/Y or uses a quick position preset.
  - Normalizes tiny floating-point values when formatting dialog/inspector
    numbers so near-zero values render as `0`.
- `test/widget_test.dart`:
  - Added coverage for USB-C anchor alignment from a top-lid snap point and
    rotation-aware re-alignment.
- Docs/tasks/roadmap:
  - Recorded M40 behavior, done criteria, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "snap-seeded placement dialog can align a component anchor"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "surface snap point seeds component placement dialog"`:
  - Passed after rerunning sequentially.
- `flutter test test\widget_test.dart --plain-name "active snap target inspector action opens placement dialog"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "place component dialog rotation updates candidate fit and commit"`:
  - Passed after rerunning sequentially.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 118 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Mock viewport candidate only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Selected anchor state is transient and not serialized. The project stores
    only the resulting semantic `ComponentPlacement` position and rotation.
- UI checked?
  - Widget test confirms anchor selection updates candidate coordinates and
    stays aligned through rotation.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The anchor selector exists only inside the dialog; direct viewport
  anchor picking is still future work.
  - Severity: Expected.
  - Next action: continue toward a guided viewport placement workflow.
- Issue: Running multiple targeted `flutter test` commands in parallel on
  Windows can collide on `build/test_cache`.
  - Severity: Tooling nuisance.
  - Next action: run Flutter tests sequentially unless using the single
    built-in `flutter test` runner.

### Next step
Commit and push M40, then continue toward guided component placement with more
viewport-driven confirmation or projected connector/switch workflows.

### Notes for future Codex sessions
Anchor selection is a placement aid, not project data. Do not serialize
selected anchor IDs unless the product explicitly grows editable placement
constraints later.

---

## 2026-06-29 - M41 Component USB-C Cutout Propagation

### Goal
Start component-driven enclosure generation by creating a semantic USB-C cutout
from a selected component placement's template connector metadata.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `docs/07_COMPONENT_TEMPLATE_SYSTEM.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`,
`lib/commands/command_registry.dart`, `lib/ui/shell/workspace_shell.dart`, and
USB-C command widget tests.

### Changes made
- `lib/commands/command_registry.dart`:
  - Allows `port.add_usb_c` from surface and component scopes.
- `lib/ui/shell/workspace_shell.dart`:
  - Keeps existing surface-selected manual USB-C creation.
  - Enables `Порты` from a selected component placement only when its template
    has a USB-C feature with `cutout` metadata and a resolvable target surface.
  - Builds the initial `usb_c_cutout` dimensions/profile from component
    feature metadata.
  - Resolves the first target semantic surface from the component feature
    direction.
  - Preserves source placement/template/feature IDs plus component feature
    position/direction on the generated semantic feature.
  - Keeps `source`, `placement`, and metadata when the USB-C dialog confirms.
- `test/command_registry_test.dart`:
  - Updated command availability coverage for surface and component contexts.
- `test/widget_test.dart`:
  - Added coverage for component-driven USB-C creation and saved JSON source
    metadata.
- Docs/tasks/roadmap:
  - Recorded M41 behavior, limitations, tests, and poke checklist.

### Tests run
- `flutter test test\command_registry_test.dart --plain-name "USB-C command works from surface and component context"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "component USB-C rail command creates sourced cutout"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "add USB-C rail command commits through undo history"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "add USB-C rail command can be cancelled"`:
  - Passed.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test`:
  - Passed, 119 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git diff --check`:
  - Passed.

### Validation
- Geometry checked?
  - Semantic feature generation only; no generated B-Rep or mesh is created.
- Serialization checked?
  - Widget test saves the project and verifies generated cutout source metadata.
- UI checked?
  - Widget tests cover both the old surface-selected USB-C path and the new
    component-selected path.
- Export checked?
  - Not implemented yet; unchanged.

### Known issues
- Issue: The generated cutout uses the connector direction for the target
  surface but does not yet store face-local connector coordinates.
  - Severity: Expected first-pass limitation.
  - Next action: add face-local projected placement metadata before real
    geometry generation.
- Issue: This creates a semantic `usb_c_cutout`; it does not yet cut real
  generated geometry.
  - Severity: Expected.
  - Next action: connect semantic features to geometry service/OCCT worker
    later.

### Next step
Commit and push M41, then continue toward projected connector coordinates or
component-driven switch/button cutout propagation.

### Notes for future Codex sessions
Component-driven port creation should remain semantic and traceable. Do not
flatten it into generated mesh or OCCT topology; source IDs are the bridge for
future regeneration/update behavior.

---

## 2026-07-01 - M112 Snap-Seeded Glass and Button Placement

### Goal
Extend the active face-local snap target workflow from USB-C/cutouts to manual
glass recesses and button groups, while keeping project data semantic and
independent from generated mesh or OCCT topology IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`lib/geometry/geometry_protocol.dart`,
`lib/validation/project_semantic_validator.dart`, `test/widget_test.dart`,
`test/geometry_protocol_test.dart`, `test/project_semantic_validator_test.dart`,
and docs for project format, feature system, commands, viewport, usable shell,
and testing.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added active snap actions for glass recesses and manual button groups.
  - Saves `placement.projectionMode=surface_snap_target`,
    `placement.surfacePosition`, and surface axes for snap-seeded glass/button
    creation.
  - Preserves placement/source metadata when the glass dialog confirms.
  - Moves mock glass and button markers to the saved face-local position.
- `lib/viewport/viewport_controller.dart`:
  - Allows mock button group previews to carry a semantic surface offset.
  - Uses saved glass/button surface positions for selectable mock markers.
- `lib/geometry/geometry_protocol.dart`:
  - Offsets manual button group operation items by saved
    `placement.surfacePosition`.
- `lib/validation/project_semantic_validator.dart`:
  - Validates snap-seeded glass recess anchors and manual button group button
    centers against supported enclosure surfaces.
- Tests:
  - Added protocol, validator, and widget coverage for snap-seeded glass and
    manual button placement.
- Docs/tasks/roadmap:
  - Recorded M112 behavior, tests, current limitations, and poke checklist.

### Tests run
- `flutter test test\geometry_protocol_test.dart --plain-name "manual button group items include saved surface position offset"`:
  - Passed.
- `flutter test test\project_semantic_validator_test.dart --plain-name "snap-seeded glass recess anchor outside surface reports an error"`:
  - Passed.
- `flutter test test\project_semantic_validator_test.dart --plain-name "manual button group surface anchor outside lid reports an error"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "snap-seeded USB-C stores front wall surface position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "snap-seeded glass recess stores top lid surface position"`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "snap-seeded button group stores top lid surface position"`:
  - Passed.
- `flutter test test\geometry_protocol_test.dart test\project_semantic_validator_test.dart test\viewport_controller_test.dart`:
  - Passed, 49 tests.
- `flutter test test\widget_test.dart --plain-name "snap-seeded"`:
  - Passed, 5 tests.
- `flutter pub get`:
  - Passed; 4 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 227 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - Protocol tests confirm manual button group operation positions include the
    semantic snap offset. Generated B-Rep cutting is not changed in this slice.
- Serialization checked?
  - Widget tests save semantic project JSON and verify glass/button
    `surface_snap_target` placement metadata.
- UI checked?
  - Widget tests confirm active snap panel actions create/select markers from
    the clicked top-lid point.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL export behavior unchanged.

### Known issues
- Issue: Glass and button snap placement currently uses semantic 2D/overlay
  markers, not direct picking of generated OCCT faces.
  - Severity: Expected first-pass limitation.
  - Next action: move toward true generated-geometry picking/mapping when the
    viewport supports robust semantic face hits.
- Issue: Manual button group geometry protocol positions are now offset, but
  native generated button cuts still need broader deterministic regression
  coverage before they become a user-facing guarantee.
  - Severity: Expected.
  - Next action: add native geometry tests around manual group placement before
    tightening export behavior.

### Next step
Commit and push M112, then continue toward stronger generated-geometry mapping
and user-facing placement feedback.

### Notes for future Codex sessions
Snap-seeded glass/buttons should remain semantic `surface_snap_target`
placements. Do not couple them to triangle IDs or generated mesh hit IDs; use
stable semantic surface IDs and face-local coordinates.

---

## 2026-07-10 - M113 Native-Mapped Overlay De-Clutter

### Goal
Reduce visible 2D schematic markers in native preview mode by hiding feature
and feature-group overlay duplicates when generated OCCT preview ranges already
represent the same semantic IDs.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/widget_test.dart`, `test/viewport_controller_test.dart`,
`docs/26_TESTING_AND_QUALITY.md`, and `docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Reuses computed feature/group preview lists in the viewport build.
  - Detects native OCCT preview mappings by semantic ID without exposing mesh
    or triangle IDs to project state.
  - Suppresses schematic feature and feature-group markers in annotation mode
    when the same semantic object already has a native preview range.
  - Keeps fallback markers visible for unmapped semantic objects.
  - Adds test-visible keys for hidden mapped feature/group overlays.
- `test/widget_test.dart`:
  - Added a native-style preview mesh fixture with feature and feature-group
    semantic ranges.
  - Verifies mapped schematic overlays are hidden while mesh-range selection
    highlighting still works.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Recorded M113 behavior, current limitations, tests, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "native preview hides mapped schematic feature overlays" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "native preview" --reporter compact`:
  - Passed.
- `flutter test test\viewport_controller_test.dart --reporter compact`:
  - Passed, 15 tests.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 228 tests.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - Native preview mappings are consumed only as display-only ranges. No
    generated mesh/B-Rep/topology IDs are stored in the editable project.
- Serialization checked?
  - No project serialization changes in this slice.
- UI checked?
  - Widget tests verify mapped schematic overlays are hidden and native
    selection highlight remains active.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL export behavior unchanged.

### Known issues
- Issue: Objects without native semantic preview ranges still need schematic
  overlay markers.
  - Severity: Expected fallback behavior.
  - Next action: continue adding generated semantic ranges as native geometry
    coverage expands.
- Issue: Component placement previews are still 2D semantic rectangles.
  - Severity: Expected.
  - Next action: generate or import component reference geometry later.

### Next step
Commit and push M113, then continue toward stronger native geometry mapping and
less schematic UI in the viewport.

### Notes for future Codex sessions
The overlay de-clutter logic must stay semantic-ID based. Do not replace it
with triangle IDs or OCCT topology IDs in UI state or saved project files.

---

## 2026-07-10 - M114 Native Active Snap Point De-Clutter

### Goal
Make native preview less noisy after the user clicks a surface snap target by
showing a compact point/crosshair instead of the full translucent 2D workplane
rectangle and grid.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`test/viewport_controller_test.dart`, `docs/26_TESTING_AND_QUALITY.md`, and
`docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added a native point-only workplane overlay state for active top-lid and
    front-wall snap targets.
  - Draws a compact active snap point/crosshair in native preview mode.
  - Keeps full component-placement workplanes because the board rectangle is
    still useful for placement.
  - Leaves hit-testing, active snap data, and saved semantic project data
    unchanged.
- `test/widget_test.dart`:
  - Added coverage that native surface snap state shows point-only overlay and
    does not re-enable the full focused workplane rectangle.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Recorded M114 behavior, tests, limitations, and poke checklist.

### Tests run
- `flutter test test\widget_test.dart --plain-name "native preview shows active surface snap as point only" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "native preview" --reporter compact`:
  - Passed.
- `flutter test test\viewport_controller_test.dart --reporter compact`:
  - Passed, 15 tests.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 229 tests.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry generation changes in this slice. Native preview mesh remains
    display-only, and active snap still uses semantic workplane IDs plus
    face-local coordinates.
- Serialization checked?
  - No project serialization changes.
- UI checked?
  - Widget tests verify point-only native active snap state and existing native
    preview behavior.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL export behavior unchanged.

### Known issues
- Issue: The active snap point is still a screen-space UI affordance, not a
  projected OCCT face marker.
  - Severity: Expected.
  - Next action: continue toward real generated-face picking and projection.
- Issue: Component placement previews still need a fuller generated/reference
  geometry representation later.
  - Severity: Expected.
  - Next action: revisit after the component template/editor workflow matures.

### Next step
Commit and push M114, then continue removing schematic viewport pieces as
native semantic coverage becomes strong enough.

### Notes for future Codex sessions
Point-only active snap must remain transient UI state. Do not store it in
`ProjectModel`, and do not replace face-local semantic coordinates with raw
preview triangle IDs.

---

## M115 - Collapsible Workspace Side Panels

### Goal
Give the viewport more inspection room by letting the project browser and
contextual inspector collapse into narrow icon strips without touching semantic
project state, geometry, undo/redo, or save/load.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/26_TESTING_AND_QUALITY.md`, and `docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added transient shell state for collapsed project browser and inspector.
  - Added icon-only collapsed strips with restore buttons.
  - Added compact collapse controls to the project browser and inspector.
  - Kept the command rail visible and left selection, commands, project data,
    undo/redo, and geometry requests unchanged.
  - Moved the project-browser collapse control into the browser header after
    full tests caught that a separate extra row pushed feature rows under the
    test viewport status bar.
- `test/widget_test.dart`:
  - Added coverage that both side panels collapse and expand again.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Recorded the M115 behavior, test surface, and manual poke checklist.

### Tests run
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test test\widget_test.dart --plain-name "workspace side panels can collapse and expand" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "workspace shell" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "viewport" --reporter compact`:
  - Passed.
- First `flutter test --reporter compact`:
  - Failed after the new project-browser collapse row pushed feature rows too
    low in the widget-test viewport.
  - Fixed by placing the collapse control in the browser header.
- Targeted regression checks after the layout fix:
  - `native preview keeps semantic overlays muted until selected`: Passed.
  - `native preview hides mapped schematic feature overlays`: Passed.
  - `selected feature highlights mapped preview mesh range`: Passed.
  - `selecting a feature updates contextual inspector`: Passed.
  - `selected USB-C feature inspector edits parameters through undo`: Passed.
- Final `flutter test --reporter compact`:
  - Passed, 230 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry changes. Collapse state is shell-only and never leaves UI
    layout.
- Serialization checked?
  - No project serialization changes.
- UI checked?
  - Widget tests verify collapse/expand controls, and full widget coverage
    verifies existing selection, inspector, native preview, and command flows.
- Export checked?
  - Latest Windows bundle rebuilt; export behavior unchanged.

### Known issues
- Issue: Collapsed state is not persisted between app launches.
  - Severity: Expected.
  - Next action: keep it transient until user preferences exist.
- Issue: The viewport still uses the current native preview and hit-target
  model from earlier chunks.
  - Severity: Expected.
  - Next action: continue toward generated-face picking and richer viewport
    interaction.

### Next step
Commit and push M115, then continue with the next safe interaction/viewport
chunk from the roadmap.

### Notes for future Codex sessions
Panel collapse is workspace UI state only. Do not store it in `ProjectModel`,
do not add undo transactions for it, and keep command rail access available
while panels are collapsed.

---

## M116 - Viewport Context Popover Foundation

### Goal
Add the first viewport right-click context popover so semantic surfaces and
snap points can launch relevant generator commands without forcing the user
back to the left rail.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/26_TESTING_AND_QUALITY.md`, and `docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added secondary-click handling to `_ViewportArea`.
  - Reused existing mock/native semantic hit testing for context targets.
  - Added a compact `showMenu` popover filtered through `CommandRegistry` and
    the existing shell command handlers.
  - Selecting a snap point before opening the menu preserves the same active
    snap target data used by inspector shortcuts.
  - Menu commands launch existing dialogs; no new project model, undo, save,
    or geometry protocol state was introduced.
- `test/widget_test.dart`:
  - Added coverage for surface quick actions in the viewport context menu.
  - Added coverage that `Отверстия` from a top-lid snap point opens the cutout
    dialog with the clicked X/Y values.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Recorded M116 behavior, tests, limitations, and poke checklist.
  - Marked `Context popover foundation` and `Right-click quick popovers` done.

### Tests run
- `flutter test test\widget_test.dart --plain-name "viewport context menu" --reporter compact`:
  - Passed, 2 tests.
- `flutter test test\widget_test.dart --plain-name "workspace shell" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "viewport" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 232 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Passed.
- `git status --short --ignored releases`:
  - Passed; `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry generation changes. The popover uses existing semantic hit
    results and command flows.
- Serialization checked?
  - No project serialization changes.
- UI checked?
  - Widget tests verify quick-action visibility and snap-seeded command launch.
  - Full widget coverage verifies existing left-click selection, dialogs, and
    command flows still pass.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL export behavior unchanged.

### Known issues
- Issue: The popover currently uses Flutter's standard popup menu and does not
  yet have a custom compact visual style.
  - Severity: Expected.
  - Next action: polish after command palette/context UI conventions settle.
- Issue: Context actions still depend on the current semantic hit-testing
  layer.
  - Severity: Expected.
  - Next action: continue toward generated-face picking and richer native
    selection.

### Next step
Commit and push M116, then continue with another safe interaction or workflow
chunk from the roadmap.

### Notes for future Codex sessions
Viewport context popovers are transient UI affordances. Keep them filtered
through `CommandRegistry` and existing command handlers; do not create a second
command execution path or store popover state in `ProjectModel`.

---

## M117 - Command Palette Foundation

### Goal
Add a compact command palette for discovering and launching existing semantic
commands from the toolbar or keyboard, without adding a second command system or
saving palette state into the project.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/commands/command_ids.dart`, `lib/commands/command_registry.dart`,
`lib/ui/shell/workspace_shell.dart`, `test/command_registry_test.dart`,
`test/widget_test.dart`, `docs/26_TESTING_AND_QUALITY.md`, and
`docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/commands/command_ids.dart` and `lib/commands/command_registry.dart`:
  - Added `workspace.command_palette` as a global, no-undo UI command.
- `lib/ui/shell/workspace_shell.dart`:
  - Added a top-toolbar command palette button.
  - Added `Ctrl+K` shell focus handling.
  - Added a searchable palette dialog filtered through `CommandRegistry`,
    current selection context, undo/file state, and existing shell handlers.
  - Routed selected palette commands into the same command handlers used by the
    rail, toolbar, inspector shortcuts, and viewport context popover.
  - Kept palette query/focus state transient and outside project JSON,
    undo/redo, and geometry requests.
- `test/command_registry_test.dart` and `test/widget_test.dart`:
  - Added registry coverage for the palette command.
  - Added widget coverage for toolbar opening, `Ctrl+K`, context filtering, and
    launching a surface command from the palette.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Added M117, marked command palette foundation complete, and documented the
    transient UI/testing expectations.

### Tests run
- `flutter test test\widget_test.dart --plain-name "command palette" --reporter compact`:
  - Passed, 2 tests.
- `flutter test test\command_registry_test.dart --reporter compact`:
  - Passed, 9 tests.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 235 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry changes. The palette only opens existing command flows.
- Serialization checked?
  - No project serialization changes. Palette state is not saved.
- UI checked?
  - Yes. Widget tests verify toolbar access, keyboard access, filtering, and
    launching a surface command.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged.

### Known issues
- Issue: The palette uses a first-pass compact dialog style.
  - Severity: Expected.
  - Next action: Polish command grouping/recents later when there are more
    production commands.
- Issue: Command labels are still hard-coded while localization is future work.
  - Severity: Low.
  - Next action: Move command/UI text into a localization layer when the app
    gets full language support.

### Next step
Commit and push M117, then continue with the next safe workflow/interaction
chunk.

### Notes for future Codex sessions
The command palette must stay a transient launcher over `CommandRegistry` and
existing shell handlers. Do not store query text, focus state, or palette-only
selection in `ProjectModel`, and do not add a parallel command execution path.

---

## M118 - Guided enclosure presets and validation

### Goal
Make the first enclosure creation dialog more useful for a maker by adding
guided size presets and live validation, while keeping the editable project as
the same semantic rounded-enclosure parameter set.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/26_TESTING_AND_QUALITY.md`, and `docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added `Плата`, `Ручной`, and `Бокс` guided presets to the create-enclosure
    dialog.
  - Presets apply existing semantic parameters: width, depth, height, wall
    thickness, corner radius, and lid type.
  - Added a live internal usable-size summary.
  - Added dialog-level errors for unusable internal cavity and impossible
    corner radius.
  - Added first-pass warnings for very thin/thick walls and tight screw-lid
    bodies.
  - Kept create/cancel/undo behavior on the existing command path.
- `test/widget_test.dart`:
  - Added coverage that a guided preset updates fields and commits a normal
    semantic enclosure edit.
  - Added coverage that invalid wall/width combinations disable `Создать`, and
    that applying a valid preset clears the blocking error.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Added M118, marked guided enclosure wizard presets/validation complete, and
    documented the transient dialog guidance.

### Tests run
- `flutter test test\widget_test.dart --plain-name "create enclosure" --reporter compact`:
  - Passed, 4 tests.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 237 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry generator changes. The dialog still commits normal semantic
    rounded-enclosure values consumed by existing preview/export paths.
- Serialization checked?
  - No project JSON schema changes. Presets and validation messages are
    dialog-only UI state.
- UI checked?
  - Yes. Widget tests verify preset application, commit behavior, blocking
    validation, and recovery via preset.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged.

### Known issues
- Issue: Presets are currently hard-coded in the dialog.
  - Severity: Expected.
  - Next action: Move them into a reusable preset catalog if more enclosure
    families are added.
- Issue: Dialog validation is first-pass guidance, not a full printability
  solver.
  - Severity: Expected.
  - Next action: Reuse/project these checks into semantic validation when
    enclosure wizard workflows become richer.

### Next step
Commit and push M118, then continue with the next safe enclosure or workflow
chunk.

### Notes for future Codex sessions
Enclosure presets must remain semantic parameter fill-ins. Do not introduce a
new editable generated geometry type or save preset IDs into `ProjectModel`
unless a real user-facing preset history/settings feature is designed.

---

## M119 - Guided component placement pick mode

### Goal
Add a first guided component placement flow: start placement, choose a viewport
snap point, then continue in the existing placement dialog with that point
already applied.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/32_USABLE_SHELL.md`, and
`docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added transient `_componentPlacementGuideActive` shell state.
  - Added `Выбрать точку` to the placement dialog.
  - Added a compact viewport guide banner with cancel action.
  - Reused existing semantic snap hit testing and active snap target data.
  - When guide mode is active, clicking a snap point clears the guide and
    reopens the normal placement dialog with the snap hint and seeded X/Y.
  - Kept guide state out of `ProjectModel`, undo/redo, save/load, and geometry
    requests.
- `test/widget_test.dart`:
  - Added coverage for guided viewport pick mode reopening the placement dialog
    from a top-lid snap point.
  - Rechecked existing direct placement flows.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Added M119, marked guided component placement workflow complete, and
    documented the transient viewport pick behavior.

### Tests run
- `flutter test test\widget_test.dart --plain-name "component placement" --reporter compact`:
  - Passed, 5 tests.
- `flutter test test\widget_test.dart --plain-name "place component" --reporter compact`:
  - Passed, 6 tests.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 238 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry generator changes. The flow reuses existing semantic snap target
    data and normal placement dialog commit.
- Serialization checked?
  - No project JSON changes. Pending guide state is not saved.
- UI checked?
  - Yes. Widget tests verify the guide banner, snap pick, dialog reopening, and
    existing direct placement flows.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged.

### Known issues
- Issue: Guide mode still depends on currently visible semantic workplanes.
  - Severity: Expected.
  - Next action: Add richer surface discovery or hover affordances after native
    face picking matures.
- Issue: The guide banner is first-pass visual polish.
  - Severity: Low.
  - Next action: Polish with the broader interaction styling pass.

### Next step
Commit and push M119, then continue with another safe component/template or
interaction chunk.

### Notes for future Codex sessions
Guided component placement should remain a transient launcher over existing
semantic snap targets and `_PlaceComponentDialog`. Do not store pending guide
mode, viewport hit data, or generated mesh identifiers in `ProjectModel`.

---

## M120 - Advanced mode switch

### Goal
Add the first Advanced Mode switch while keeping low-level CAD tools hidden
from the default maker workflow.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/30_ADVANCED_CAD_MODE.md`, and
`docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added transient `_advancedMode` shell state.
  - Passed Advanced Mode into command contexts for rail, palette, and viewport
    context filtering.
  - Added a lower left-rail Advanced Mode toggle.
  - Revealed the `advanced.sketch` placeholder only while Advanced Mode is on.
  - Kept the placeholder disabled because the basic sketch workflow is not
    implemented yet.
  - Tightened rail icon button sizing so the extra advanced section does not
    overflow the test/default shell height.
  - Kept Advanced Mode state out of `ProjectModel`, undo/redo, save/load, and
    geometry requests.
- `test/widget_test.dart`:
  - Added coverage that the advanced sketch tool is hidden by default, appears
    only after enabling Advanced Mode, remains disabled, and hides again.
- `ROADMAP.md`, `TASKS.md`, and docs:
  - Added M120, marked the Advanced Mode switch complete, and documented the
    transient/default-hidden behavior.

### Tests run
- `flutter test test\command_registry_test.dart --plain-name "advanced commands" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced mode switch" --reporter compact`:
  - Passed after tightening rail button sizing.
- `flutter test test\widget_test.dart --plain-name "unimplemented rail" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "native preview hides mapped schematic feature overlays" --reporter compact`:
  - Passed after removing the extra rail `Scrollable`.
- `flutter test test\widget_test.dart --plain-name "selecting a feature updates contextual inspector" --reporter compact`:
  - Passed after removing the extra rail `Scrollable`.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 239 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - No geometry generator changes. Advanced Mode only changes transient command
    visibility.
- Serialization checked?
  - No project JSON schema changes. Advanced Mode is not saved.
- UI checked?
  - Yes. Widget tests cover hidden/visible/disabled advanced tools and the
    rail no longer overflows at the default test height.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged.

### Known issues
- Issue: `Эскиз` is only a disabled placeholder.
  - Severity: Expected.
  - Next action: Implement the basic sketch tool only after its semantic model,
    validation, undo, and geometry boundaries are designed.
- Issue: Advanced Mode is session-transient.
  - Severity: Expected.
  - Next action: Add user preferences later if keeping the mode enabled between
    launches becomes useful.

### Next step
Commit and push M120, then continue with the next safe chunk toward the basic
advanced sketch foundation or another semantic generator workflow.

### Notes for future Codex sessions
Advanced Mode must remain an escape hatch. Do not move sketch/extrude/boolean
into the default generator rail, and do not make advanced placeholders
executable until they have semantic state, undo/redo, validation, and geometry
service boundaries.

---

## M121 - Basic sketch foundation

### Goal
Make the first Advanced Mode sketch command create a safe semantic helper
feature without turning the default workflow into low-level CAD.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/project/feature.dart`,
`lib/geometry/geometry_operation_plan.dart`,
`lib/selection/project_selection_resolver.dart`,
`test/widget_test.dart`, `test/project_model_test.dart`,
`test/geometry_protocol_test.dart`, `docs/26_TESTING_AND_QUALITY.md`,
`docs/30_ADVANCED_CAD_MODE.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
`docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Wired `advanced.sketch` to a real command only when `_advancedMode` is on.
  - Added `_AdvancedSketchDialog` with target surface and sketch name fields.
  - Created `advanced_sketch` as a `SemanticFeature` with `operation=helper`,
    `source.type=advanced_mode`, surface workplane placement, and empty
    `entities`.
  - Selected the created sketch and committed it through the existing semantic
    undo history.
  - Included advanced commands in the command palette only while Advanced Mode
    is enabled.
  - Added browser labels/icons for `advanced_sketch`.
- `lib/selection/project_selection_resolver.dart`:
  - Added human-readable sketch titles from the saved feature name.
- `lib/geometry/geometry_operation_plan.dart`:
  - Mapped `advanced_sketch` to `helper.advanced_sketch`.
- Tests:
  - Added widget coverage for palette visibility, sketch creation, save JSON,
    and undo.
  - Added project-model round-trip coverage.
  - Added operation-planner coverage that sketches remain helper operations.
- Docs/tasks/roadmap:
  - Added M121, split the Phase 16 sketch work into foundation vs drawing, and
    documented the helper-only behavior.

### Tests run
- `flutter test test\geometry_protocol_test.dart --plain-name "advanced sketches" --reporter compact`:
  - Passed.
- `flutter test test\project_model_test.dart --plain-name "advanced sketch" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "command palette" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 242 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - Yes at the protocol boundary. `advanced_sketch` becomes
    `helper.advanced_sketch` and does not request cut/extrude/mesh/B-Rep
    generation.
- Serialization checked?
  - Yes. The helper feature round-trips through `ProjectModel` JSON and is
    verified through a widget save test.
- UI checked?
  - Yes. Widget tests cover Advanced Mode gating, command palette visibility,
    dialog creation, browser selection, save, and undo.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because sketches
    are helper features with empty entities.

### Known issues
- Issue: The sketch has no drawable entities yet.
  - Severity: Expected.
  - Next action: Add a typed line/rectangle/circle entity schema and editing
    flow before any geometry generation.
- Issue: Helper sketches are not drawn in the viewport.
  - Severity: Expected.
  - Next action: Add a surface workplane sketch overlay only after entity
    selection/edit semantics are defined.

### Next step
Commit and push M121, then continue with a safe first sketch-entity slice or a
different semantic generator workflow.

### Notes for future Codex sessions
Keep `advanced_sketch` semantic and helper-only until sketch entities,
constraints, validation, undo grouping, and geometry-service conversion are
designed. Do not use generated mesh/B-Rep or OCCT topology as editable sketch
state.

---

## M122 - Sketch rectangle entity slice

### Goal
Add the first typed Advanced Sketch entity in a safe semantic-only way.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/project/project_model.dart`,
`lib/project/json_helpers.dart`, `test/widget_test.dart`,
`test/project_model_test.dart`, `docs/05_PROJECT_FILE_FORMAT.md`,
`docs/06_FEATURE_SYSTEM.md`, `docs/26_TESTING_AND_QUALITY.md`,
`docs/30_ADVANCED_CAD_MODE.md`, `docs/31_COMMANDS_AND_UNDO.md`, and
`docs/32_USABLE_SHELL.md`.

### Changes made
- `lib/project/advanced_sketch.dart`:
  - Added `advancedSketchFeatureType`, `SketchEntity`, entity read/write
    helpers, and the default rectangle entity.
  - Added deterministic entity id generation for sketch-local ids such as
    `rect_1`.
- `lib/project/project_model.dart`:
  - Exported the advanced sketch model helpers through the project model barrel.
- `lib/ui/shell/workspace_shell.dart`:
  - Added an undoable selected-sketch action for adding a rectangle entity.
  - Added a compact inspector sketch section with contour count, rectangle
    action, and entity rows.
  - Kept advanced sketch creation using the typed helper constant and entity
    helper.
- Tests:
  - Extended project-model round-trip coverage to include `rect_1`.
  - Extended the Advanced Sketch widget flow to create, save, and undo the
    rectangle entity.
- Docs/tasks/roadmap:
  - Added M122, marked the rectangle entity foundation complete, and documented
    the helper-only boundary.

### Tests run
- `flutter test test\project_model_test.dart --plain-name "advanced sketch" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 247 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.
- `flutter analyze`:
  - Passed with no issues.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter test --reporter compact`:
  - Passed, 242 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - Yes by boundary. The rectangle is stored as sketch metadata only; no
    B-Rep, mesh, cut, extrusion, or topology ids are generated.
- Serialization checked?
  - Yes. `SketchEntity` round-trips through project JSON and is verified by the
    widget save test.
- UI checked?
  - Yes. The inspector action adds `rect_1`, save preserves it, undo removes it,
    and the created sketch can still be undone separately.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because advanced
    sketch entities are helper data only.

### Known issues
- Issue: The rectangle is not drawn as a real editable sketch overlay yet.
  - Severity: Expected.
  - Next action: Add viewport sketch drawing/selection after entity editing
    semantics are stable.
- Issue: The rectangle has fixed default dimensions only.
  - Severity: Expected.
  - Next action: Add inspector parameter editing and validation for sketch
    entities before geometry conversion.

### Next step
Commit and push M122, then continue with sketch entity editing or viewport
overlay selection.

### Notes for future Codex sessions
Keep `SketchEntity` as semantic project data. Do not make sketch entities depend
on mesh triangles, generated B-Rep ids, or OCCT topology ids. Geometry conversion
should go through `GeometryService` only after validation and undo semantics are
designed.

---

## M123 - Sketch rectangle parameter editing

### Goal
Make the first Advanced Sketch rectangle entity editable through typed semantic
parameters while keeping it helper-only.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/project/advanced_sketch.dart`, `lib/parameters/parameter_model.dart`,
`lib/ui/shell/workspace_shell.dart`, `test/widget_test.dart`,
`docs/05_PROJECT_FILE_FORMAT.md`, `docs/06_FEATURE_SYSTEM.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/30_ADVANCED_CAD_MODE.md`,
`docs/31_COMMANDS_AND_UNDO.md`, `docs/32_USABLE_SHELL.md`, and
`docs/35_PARAMETER_MODEL.md`.

### Changes made
- `lib/project/advanced_sketch.dart`:
  - Added `advancedSketchWithUpdatedEntity` for stable replacement of one
    sketch entity by id.
- `lib/parameters/sketch_entity_parameter_adapter.dart`:
  - Added schema-backed rectangle parameters: center X/Y, width, height, and
    corner radius.
  - Added semantic update/apply helpers.
  - Normalized numeric precision for stable JSON.
  - Clamped corner radius to half of the smaller side.
- `lib/ui/shell/workspace_shell.dart`:
  - Added an undoable sketch entity parameter update path.
  - Expanded the selected sketch inspector to show editable rectangle fields.
- Tests:
  - Added adapter coverage for defaults, semantic updates, radius clamping, and
    stable entity replacement.
  - Extended the Advanced Sketch widget test to edit width, save it, and undo
    the parameter edit separately from entity creation.
- Docs/tasks/roadmap:
  - Added M123 and documented the current rectangle parameter editing boundary.

### Tests run
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 246 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - Yes by boundary. Rectangle parameter edits remain metadata on a helper
    sketch and do not request B-Rep, mesh, cut, extrusion, or topology output.
- Serialization checked?
  - Yes. Widget save coverage verifies edited rectangle width persists in
    semantic project JSON.
- UI checked?
  - Yes. The selected sketch inspector shows rectangle fields, updates the row
    label, and undo reverts the parameter edit separately.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because sketch
    entities still do not generate geometry.

### Known issues
- Issue: Rectangle edits are visible in the inspector only, not drawn on the
  viewport workplane yet.
  - Severity: Expected.
  - Next action: Add a helper-only sketch overlay that reads `SketchEntity`
    values without using generated mesh/B-Rep state.
- Issue: There is no direct entity selection inside the viewport.
  - Severity: Expected.
  - Next action: Add semantic sketch overlay hit targets after drawing exists.

### Next step
Commit and push M123, then continue with a helper-only sketch overlay or entity
selection/editing affordances.

### Notes for future Codex sessions
Keep rectangle parameters schema-backed and semantic. Do not convert sketch
entity ids into OCCT topology ids or mesh triangle ids. Viewport drawing should
read `SketchEntity` values as a temporary semantic overlay until the geometry
conversion path is designed.

---

## M124 - Sketch rectangle helper overlay

### Goal
Make selected Advanced Sketch rectangles visible in the viewport as helper-only
semantic overlays without restoring the old large passive workplane ghost.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/ui/shell/workspace_shell.dart`, `lib/viewport/viewport_controller.dart`,
`test/widget_test.dart`, `docs/06_FEATURE_SYSTEM.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/30_ADVANCED_CAD_MODE.md`,
`docs/32_USABLE_SHELL.md`, and `docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/ui/shell/workspace_shell.dart`:
  - Added selected-sketch rectangle preview data derived from `SketchEntity`
    values.
  - Reused supported surface workplane local-to-canvas mapping for top-lid and
    front-wall sketch overlays.
  - Added `_paintSketchRectangles` to draw only rectangle contour and center
    marker.
  - Kept the normal large workplane overlay off for selected sketches.
  - Added `advanced-sketch-overlay-active` sentinel for widget coverage.
- Tests:
  - Extended the Advanced Sketch widget test to verify the helper overlay
    appears after adding `rect_1`, remains through parameter undo, and
    disappears when the rectangle entity is undone.
  - Verified `mock-workplane-overlay-active` stays absent for the selected
    sketch.
- Docs/tasks/roadmap:
  - Added M124 and documented the helper-only viewport boundary.

### Tests run
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`:
  - Passed.
- `flutter pub get`:
  - Passed; 5 packages have newer versions incompatible with dependency
    constraints.
- `dart format --output=none --set-exit-if-changed lib test tool occt_worker`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.
- `flutter test --reporter compact`:
  - Passed, 246 tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_latest_windows.ps1 -NativeOcct -SkipNativeOcctBuild`:
  - Passed and refreshed
    `C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe`.
- `Test-Path releases\latest\windows\shell_case_easy_maker.exe`:
  - Returned `True`.
- `git status --short --ignored releases`:
  - Confirmed `releases/` is ignored.
- `git diff --check`:
  - Passed with only the existing ROADMAP CRLF warning.

### Validation
- Geometry checked?
  - Yes by boundary. The overlay reads semantic `SketchEntity` values only and
    does not request B-Rep, mesh, cuts, extrusions, or topology ids.
- Serialization checked?
  - No schema change. Existing rectangle entity save/load coverage remains the
    source for overlay data.
- UI checked?
  - Yes. Widget coverage verifies overlay visibility and confirms the large
    workplane overlay does not reappear for selected sketches.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because sketch
    overlays are display-only.

### Known issues
- Issue: The rectangle overlay is not directly selectable in the viewport yet.
  - Severity: Expected.
  - Next action: Add semantic overlay hit targets that resolve to sketch entity
    ids without storing mesh or topology ids.
- Issue: The overlay supports only mock top-lid/front-wall surface mappings.
  - Severity: Expected.
  - Next action: Expand surface mapping when more semantic surfaces gain stable
    local coordinate systems.

### Next step
Commit and push M124, then continue with sketch overlay hit testing or direct
entity selection affordances.

### Notes for future Codex sessions
Keep sketch overlays display-only until entity selection and geometry
conversion are designed. Do not couple overlay rectangles to preview mesh
triangles, B-Rep faces, or OCCT topology ids.

---

## M125 - Sketch rectangle overlay hit target

### Goal
Make the selected Advanced Sketch rectangle overlay clickable as a semantic
parent sketch target without turning rectangle entities into mesh, B-Rep, or
topology selections.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/viewport/viewport_controller.dart`, `lib/ui/shell/workspace_shell.dart`,
`test/viewport_controller_test.dart`, `test/widget_test.dart`,
`docs/06_FEATURE_SYSTEM.md`, `docs/26_TESTING_AND_QUALITY.md`,
`docs/30_ADVANCED_CAD_MODE.md`, `docs/32_USABLE_SHELL.md`, and
`docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/viewport/viewport_controller.dart`:
  - Added public `MockViewportSketchRectanglePreview` with shared canvas layout
    and hit-test helpers.
  - Added sketch rectangle overlay hit testing to `MockViewportHitTester`.
  - Prioritized selected sketch rectangle hits before normal feature/group
    markers so clicks on the helper do not fall through to objects underneath.
- `lib/ui/shell/workspace_shell.dart`:
  - Reused the shared sketch rectangle preview model for painting.
  - Passed selected sketch rectangle previews into viewport hit testing.
  - Kept hits resolving to the parent `advanced_sketch` feature id.
- Tests:
  - Added controller coverage for rectangle overlay hit results.
  - Extended the Advanced Sketch widget test to click the visible helper
    rectangle and verify the sketch inspector remains selected.
- Docs/tasks/roadmap:
  - Added M125 and documented the no-sub-entity/no-topology boundary.

### Tests run
- `flutter test test\viewport_controller_test.dart --plain-name "parent sketch feature" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`:
  - Passed.

### Validation
- Geometry checked?
  - Yes by boundary. The overlay hit result returns a stable semantic feature
    id and does not use mesh triangles, B-Rep faces, or OCCT topology ids.
- Serialization checked?
  - No schema change. The selected rectangle still comes from existing
    `SketchEntity` metadata.
- UI checked?
  - Yes. Widget coverage clicks the visible helper overlay and confirms the
    selected sketch inspector stays active.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because sketch
    overlays still do not generate geometry.

### Known issues
- Issue: Rectangle sub-entity selection/edit handles are still not implemented.
  - Severity: Expected.
  - Next action: Design sketch entity editing affordances after the parent
    overlay hit path is stable.
- Issue: The overlay still supports only mock top-lid/front-wall surface
  mappings.
  - Severity: Expected.
  - Next action: Expand supported surfaces when stable semantic local
    coordinate systems are added.

### Next step
Run full validation, rebuild latest Windows bundle, commit, push, then continue
with the next safe Advanced Sketch interaction slice.

### Notes for future Codex sessions
Keep sketch overlay hit testing semantic and parent-feature based until
sub-entity editing is explicitly designed. Do not introduce mesh triangle ids,
generated B-Rep ids, or OCCT topology handles into editable project state.

---

## M126 - Sketch rectangle entity focus

### Goal
Let selected sketch rectangle overlays focus the semantic rectangle entity in
the inspector while keeping command context, viewport highlighting, and
geometry boundaries scoped to the parent `advanced_sketch`.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/selection/selection_model.dart`,
`lib/selection/project_selection_resolver.dart`,
`lib/viewport/viewport_controller.dart`,
`lib/ui/shell/workspace_shell.dart`, `test/selection_model_test.dart`,
`test/project_selection_resolver_test.dart`, `test/viewport_controller_test.dart`,
`test/widget_test.dart`, `docs/06_FEATURE_SYSTEM.md`,
`docs/26_TESTING_AND_QUALITY.md`, `docs/30_ADVANCED_CAD_MODE.md`,
`docs/32_USABLE_SHELL.md`, and `docs/33_VIEWPORT_MVP.md`.

### Changes made
- `lib/selection/selection_model.dart`:
  - Added `SelectionKind.sketchEntity`.
  - Kept `selectedObjectId`, command scope, and viewport semantic highlight
    scoped to the parent sketch feature.
- `lib/selection/project_selection_resolver.dart`:
  - Added right-panel details for focused sketch entities.
- `lib/viewport/viewport_controller.dart`:
  - Added semantic child id support to viewport hits.
  - Rectangle overlay hits now carry parent sketch id plus rectangle entity id.
- `lib/ui/shell/workspace_shell.dart`:
  - Converted sketch rectangle hits into `SelectionModel.sketchEntity`.
  - Selected new rectangles immediately after creation.
  - Kept selected rectangle overlays visible with a stronger visual focus.
  - Highlighted focused entity rows in the inspector.
  - Falls back to parent sketch selection if undo removes the focused entity.
  - Kept native preview and semantic overlay highlighting parent-scoped.
- Tests:
  - Added selection-model and resolver coverage for sketch entity focus.
  - Extended viewport and widget tests for child hit ids, selected entity
    sentinel, parameter edits, and undo fallback.
- Docs/tasks/roadmap:
  - Added M126 and documented the semantic entity focus boundary.

### Tests run
- `flutter test test\selection_model_test.dart test\project_selection_resolver_test.dart --reporter compact`:
  - Passed.
- `flutter test test\viewport_controller_test.dart --plain-name "parent sketch feature" --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`:
  - Passed after updating the expectation for multiple visible `rect_1` labels.
- `flutter analyze`:
  - Passed with no issues.

### Validation
- Geometry checked?
  - Yes by boundary. Sketch entity focus is semantic UI state and does not use
    generated mesh triangles, B-Rep faces, or OCCT topology ids.
- Serialization checked?
  - No project schema change. Focus is not saved; the rectangle entity remains
    existing semantic sketch metadata.
- UI checked?
  - Yes. Widget coverage verifies focused `rect_1`, overlay click focus,
    parameter edit preservation, and undo fallback.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because sketch
    entity focus is UI/selection state only.

### Known issues
- Issue: Focused rectangle entities still do not have drag handles or direct
  viewport resizing.
  - Severity: Expected.
  - Next action: Add a safe keyboard/nudge or handle-planning slice before
    geometry conversion.
- Issue: The overlay still supports only mock top-lid/front-wall surface
  mappings.
  - Severity: Expected.
  - Next action: Expand supported surfaces when stable semantic local
    coordinate systems are added.

### Next step
Run full validation, rebuild latest Windows bundle, commit, push, then continue
with a safe sketch drawing/editing interaction slice.

### Notes for future Codex sessions
Keep `SelectionKind.sketchEntity` parent-scoped. Do not pass sketch entity ids
to native preview range selection, generated geometry ids, or OCCT topology
handles.

---

## M127 - Sketch rectangle entity actions

### Goal
Add safe semantic edit actions for focused sketch rectangles: 1 mm nudge
controls and delete, without adding viewport drag handles or geometry
conversion.

### Read before work
`AGENTS.md`, `ROADMAP.md`, `TASKS.md`, `WORKLOG.md`,
`lib/project/advanced_sketch.dart`, `lib/ui/shell/workspace_shell.dart`,
`test/sketch_entity_parameter_adapter_test.dart`, `test/widget_test.dart`,
`docs/06_FEATURE_SYSTEM.md`, `docs/26_TESTING_AND_QUALITY.md`,
`docs/30_ADVANCED_CAD_MODE.md`, `docs/32_USABLE_SHELL.md`,
`docs/33_VIEWPORT_MVP.md`, and `docs/35_PARAMETER_MODEL.md`.

### Changes made
- `lib/project/advanced_sketch.dart`:
  - Added `advancedSketchWithoutEntity` to remove sketch entities by stable id.
- `lib/ui/shell/workspace_shell.dart`:
  - Added selected rectangle icon actions for left/right/up/down 1 mm nudges.
  - Added selected rectangle delete action.
  - Applies nudges through `SketchEntityParameterAdapter.applyValues`.
  - Commits nudge/delete through undo history.
  - Keeps nudged rectangles selected as `SelectionKind.sketchEntity`.
  - Returns selection to the parent sketch after delete.
- Tests:
  - Added unit coverage for stable entity removal.
  - Extended the Advanced Sketch widget flow to verify nudge persistence,
    nudge undo, delete, undo delete, and rectangle creation undo.
- Docs/tasks/roadmap:
  - Added M127 and documented the semantic nudge/delete boundary.

### Tests run
- `flutter test test\sketch_entity_parameter_adapter_test.dart --reporter compact`:
  - Passed.
- `flutter test test\widget_test.dart --plain-name "advanced sketch command" --reporter compact`:
  - Passed.
- `flutter analyze`:
  - Passed with no issues.

### Validation
- Geometry checked?
  - Yes by boundary. Nudge/delete only rewrite semantic sketch entity data and
    do not generate B-Rep, mesh, cuts, or topology ids.
- Serialization checked?
  - Yes. Widget save coverage verifies nudged center coordinates persist as
    semantic project JSON.
- UI checked?
  - Yes. Widget coverage clicks nudge/delete controls and exercises undo.
- Export checked?
  - Latest Windows bundle rebuilt; STEP/STL behavior unchanged because sketch
    nudge/delete actions are semantic UI edits only.

### Known issues
- Issue: There are still no viewport drag handles or direct resize handles.
  - Severity: Expected.
  - Next action: Design safe handle affordances or continue with constrained
    sketch editing controls.
- Issue: The overlay still supports only mock top-lid/front-wall surface
  mappings.
  - Severity: Expected.
  - Next action: Expand supported surfaces when stable semantic local
    coordinate systems are added.

### Next step
Run full validation, rebuild latest Windows bundle, commit, push, then continue
with the next safe sketch drawing/editing slice.

### Notes for future Codex sessions
Keep inspector nudge/delete actions semantic and undoable. Do not convert
sketch entity ids into generated geometry ids or topology references.
