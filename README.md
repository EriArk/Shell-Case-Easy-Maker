# Enclosure CAD Codex Documentation Pack

[![Flutter CI](https://github.com/EriArk/Shell-Case-Easy-Maker/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/EriArk/Shell-Case-Easy-Maker/actions/workflows/flutter-ci.yml)

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
- `ROADMAP.md` — working roadmap with safe implementation chunks and manual poke checklists.
- `TASKS.md` — phased implementation plan and task backlog.
- `WORKLOG.md` — append-only worklog template.
- `docs/` — detailed product, architecture, UX, geometry, and subsystem docs.
- `templates/` — reusable templates for worklog entries, tasks, research notes, and feature specs.
- `examples/` — example semantic project JSON and component template JSON.

## Core product statement

A minimal, visual, Flutter-based enclosure design tool powered by OpenCascade. Users design devices by placing semantic components and features, not by manually editing meshes. The app generates exact B-Rep geometry, then exports STL/STEP/DXF/3MF from the semantic project model.

## Absolute rule

The editable source of truth is the semantic project model. Generated mesh/STL/DXF files are disposable outputs.

## Development quick start

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Run the desktop app locally with:

```sh
flutter run -d windows
```

Run the local worker protocol smoke with:

```powershell
Get-Content occt_worker\protocol\preview_request.example.json -Raw | dart run occt_worker\bin\occt_worker.dart
```

Inspect local worker backend capabilities with:

```powershell
dart run occt_worker\bin\occt_worker.dart --capabilities
```

Build the native worker stub with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_occt_worker_stub.ps1
```

Run the native worker stub smoke with:

```powershell
dart run tool/native_worker_stub_smoke.dart
```

This verifies native capabilities, request ID preservation, and the expected
`worker.backend.native_not_implemented` scaffold response.

Check local Windows OCCT readiness with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check_occt_windows_readiness.ps1
```

Preview the repo-local vcpkg setup steps with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/bootstrap_vcpkg_windows.ps1 -PlanOnly
```

Bootstrap a repo-local vcpkg checkout in `external/vcpkg` with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/bootstrap_vcpkg_windows.ps1
```

Restore the OCCT manifest dependency only when a large dependency install is
expected:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/bootstrap_vcpkg_windows.ps1 -InstallOpenCascade
```

Manifest restore output is local-only and ignored at
`occt_worker/native/vcpkg_installed`.

Build the opt-in OCCT native worker after explicit `OpenCASCADE_DIR` /
`CASROOT` readiness is true with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_occt_worker_occt.ps1
```

When using the repo-local manifest install in
`occt_worker/native/vcpkg_installed`, build with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall
```

Run the native OCCT rounded enclosure preview smoke with:

```powershell
dart run tool/native_occt_worker_metrics_smoke.dart --skip-build
```

This verifies the built `occt_worker_native_occt` capabilities and the
deterministic sample bounds, dimensions, surface area, volume, and preview mesh
counts. The command name is kept for compatibility with the previous
metrics-only smoke.

If CMake was previously configured before OCCT readiness became true, run the
first linked manifest build cleanly with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall -Clean
```

Build the latest manual Windows bundle with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1
```

Build the latest manual Windows bundle wired to the bundled native OCCT worker
with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_latest_windows.ps1 -NativeOcct
```

That form copies the native worker bundle to
`releases/latest/windows/occt_worker/native` and builds the app with
`SHELL_CASE_GEOMETRY_BACKEND=native_occt`.

Open the latest local build at:

```text
C:\Users\EriArk\Documents\CaseMaker\releases\latest\windows\shell_case_easy_maker.exe
```

Keep the whole `releases/latest/windows` folder together; the `.exe` needs the adjacent Flutter runtime files and `data/` folder.
