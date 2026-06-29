# 35 - OCCT Windows Dependency Plan

## Question

What is the safest Windows development path for connecting the native worker to
OpenCascade without turning generated geometry into editable project state or
making normal Flutter builds depend on a heavy native CAD stack too early?

## Sources checked

- OpenCascade official documentation:
  [Build OCCT](https://dev.opencascade.org/doc/overview/html/build_upgrade__building_occt.html)
- OpenCascade official licensing page:
  [Licensing](https://dev.opencascade.org/resources/licensing)
- vcpkg package page:
  [opencascade](https://vcpkg.io/en/package/opencascade.html)
- OpenCascade forum:
  [OCCT VCPKG Extended Package Support Now Available](https://dev.opencascade.org/content/occt-vcpkg-extended-package-support-now-available)

## Findings

- OCCT's current official build flow is CMake-based and requires a C++17
  compiler. On Windows, the official docs list Visual Studio 2019 or later, with
  Visual Studio 2022 preferred.
- The official OCCT build docs call vcpkg the fastest path to a working OCCT
  build for dependency provisioning. The same docs also keep manual third-party
  setup available for teams that need it.
- The public vcpkg package page lists `opencascade` as available, currently
  `8.0.0#1`, and exposes `vcpkg install opencascade` /
  `vcpkg add port opencascade` as the normal install paths.
- The vcpkg package page marks the package license as `LGPL-2.1-only`. The
  official OCCT licensing page says OCCT 6.7.0 and later use LGPL 2.1 with the
  Open CASCADE additional exception.
- Forum discussion around OCCT's vcpkg support says some developer tooling such
  as DRAWEXE may still need a manual CMake build path. The app does not need
  DRAWEXE for the first worker slice, so the package path remains a good first
  development route.

## Local environment snapshot

On this machine during M58:

- `cmake`: available.
- `vcpkg`: not found on `PATH`.
- `VCPKG_ROOT`: not set.
- `OpenCASCADE_DIR`: not set.
- `CASROOT`: not set.
- `OpenCASCADEConfig.cmake`: not found by the project readiness check.

This means native OCCT linking is not locally ready yet, but the existing
native stub build remains valid and should keep working.

Update from M62:

- Repo-local vcpkg was cloned and bootstrapped under ignored `external/vcpkg`.
- The explicit manifest restore installed `opencascade[core,freetype]`
  `8.0.0#1`.
- Manifest-mode packages are available under ignored
  `occt_worker/native/vcpkg_installed/x64-windows`.
- `tools/check_occt_windows_readiness.ps1` now reports `ready: true` and finds
  `OpenCASCADEConfig.cmake` in that manifest install tree.
- `occt_worker_native_occt` builds and reports `status=linked_smoke` with
  `occtVersion=8.0.0`.

Update from M63:

- `occt_worker_native_occt` now reports `status=metrics_smoke`.
- The target parses the first semantic rounded enclosure, builds the rounded
  box B-Rep internally with OCCT, and returns deterministic metrics only.
- The sample metrics smoke reports bounds `[-60, -35, 0]` to `[60, 35, 28]`,
  dimensions `[120, 70, 28]`, surface area `25924.813728`, and volume
  `232291.58617`.
- Preview mesh vertices, generated B-Rep, STEP/STL artifacts, raw OCCT topology
  IDs, and triangle IDs are still not returned to Flutter.

Update from M64:

- `occt_worker_native_occt` now reports `status=preview_mesh_smoke`.
- The target meshes the generated rounded enclosure B-Rep with
  `BRepMesh_IncrementalMesh`.
- The sample smoke emits 800 preview vertices and 1060 preview triangles with
  the same deterministic bounds and metrics.

Update from M67:

- The native preview mesh now includes first-pass semantic surface ranges for
  top lid, front wall, and bottom inside.
- The sample smoke reports 3 surface mappings and 6 mapped central planar
  triangles.
- Preview mesh output and triangle ranges remain disposable and not editable
  project state.

## License / compatibility notes

- Do not copy OCCT source into this repository.
- Do not copy GPL/AGPL project code while studying how other applications wire
  OCCT.
- The preferred MVP distribution shape is dynamic linking/bundling with license
  notices, not making OCCT source part of the editable app model.
- Before shipping an OCCT-backed binary, add third-party license notices and
  document which OCCT DLLs are bundled with the worker/app package.

## Decision

Use vcpkg as the first Windows developer acquisition path for OCCT, but keep it
outside normal Flutter builds:

1. Keep `occt_worker_native_stub` as the no-OCCT target.
2. Keep `occt_worker_native_occt` as a separate opt-in OCCT-linked native
   target.
3. Configure that target with a package config discovered through one of:
   - `OpenCASCADE_DIR`,
   - `CASROOT`,
   - `$env:VCPKG_ROOT\installed\x64-windows\share\...\OpenCASCADEConfig.cmake`.
4. Use `occt_worker/native/vcpkg.json` only when vcpkg manifest restore is
   explicitly allowed.
5. Keep Flutter talking only to `GeometryService` / process-client protocol.
6. Keep generated B-Rep and preview mesh disposable worker output.

## Readiness command

Check local Windows readiness with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1
```

The command is read-only. It prints `shell_case.occt.windows_readiness` JSON and
exits `0` by default even when OCCT is missing.

The readiness checker also looks for a repo-local vcpkg checkout at
`external/vcpkg`. This lets a developer keep the dependency toolchain local to
the project without setting a global `VCPKG_ROOT`.

Require OCCT when a future build step needs it:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1 -RequireOcct
```

That form exits `2` when no `OpenCASCADEConfig.cmake` is found.

## Repo-local vcpkg bootstrap helper

Preview the local setup steps without cloning or installing anything:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -PlanOnly
```

Bootstrap a repo-local vcpkg checkout:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1
```

This creates/uses `external/vcpkg`, bootstraps `vcpkg.exe`, and leaves
`opencascade` uninstalled unless the explicit install flag is provided:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\bootstrap_vcpkg_windows.ps1 -InstallOpenCascade
```

`external/` and `occt_worker/native/vcpkg_installed/` are ignored by Git. Do not
commit vcpkg sources, installed packages, OCCT binaries, or generated worker
build output.

## Future native target shape

The first OCCT-linked target is separate from the stub:

```text
occt_worker_native_stub  -> no OCCT, always buildable
occt_worker_native_occt  -> opt-in, requires OpenCASCADEConfig.cmake
```

`occt_worker_native_occt` is enabled with `SHELL_CASE_ENABLE_OCCT=ON` and is
built through the default script when OCCT is provided by explicit
`OpenCASCADE_DIR` / `CASROOT`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1
```

When using the repo-local vcpkg manifest install, keep manifest dependency
resolution explicit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall
```

This uses `occt_worker/native/vcpkg.json`, which currently depends only on
`opencascade`.

If a previous configure used different manifest-mode settings, clean the native
build directory once:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall -Clean
```

The current OCCT target is a preview mesh smoke. It references OCCT box, fillet,
meshing, triangulation, bounding-box, surface-property, and volume-property
APIs. For the sample rounded enclosure it returns deterministic metrics, a
disposable preview mesh, and first-pass semantic surface ranges while keeping
generated B-Rep internal to the worker. STEP/STL export should stay out of this
slice unless required by a later exact test.

## Follow-up tasks

- Install/configure vcpkg locally or set `OpenCASCADE_DIR` / `CASROOT`.
- Use `tools\bootstrap_vcpkg_windows.ps1 -PlanOnly` to inspect the local vcpkg
  setup before cloning or installing anything.
- Use `-AllowVcpkgInstall` only when a large vcpkg manifest restore is expected.
- Add shell/cavity generation after the metrics contract remains stable.
- Expand semantic surface mapping beyond the first central planar face ranges.
- Add third-party license notice packaging before distributing OCCT DLLs.
