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
