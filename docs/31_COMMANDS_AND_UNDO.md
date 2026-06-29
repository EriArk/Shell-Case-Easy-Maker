# 31 — Commands and Undo

## Purpose

Commands describe user actions as metadata before widgets render them.

The command system keeps UI controls, semantic edits, availability rules, and undo behavior aligned without putting business rules directly inside widgets.

## Command metadata

Each command declares:
- stable ID,
- human label,
- icon token,
- scope,
- availability rules,
- undo behavior.

Command IDs are technical and stable. Labels are human-facing and can later move into localization.

## Command context

Availability is evaluated from context:
- active scope,
- selected semantic object,
- active semantic surface,
- advanced mode,
- undo/redo state.

Do not check raw OCCT topology, mesh IDs, or triangle IDs in command availability.

## Registry

`CommandRegistry.core` is the app-wide starter registry.

Widgets may read labels and icon tokens from commands, but semantic command behavior should stay in services/controllers as the app grows.

## Undo history

Undo is snapshot-based for the first architecture slice:
- `singleTransaction` stores one before/after state change,
- `continuousTransaction` can collapse repeated edits with the same group ID,
- `none` updates state without entering the undo stack.

Continuous grouping is intended for future knob, drag, and encoder workflows.

## First UI wiring

The workspace shell now owns editable project state through
`UndoHistory<ProjectModel>`.

The first wired edits are enclosure inspector parameter changes:
- width,
- depth,
- height,
- wall thickness,
- corner radius,
- lid type.

Each effective parameter submission commits a semantic project snapshot.
Undo/redo restores the project snapshot and refreshes mock preview/validation.
Generated preview data is not stored in the undo stack.

Feature inspector edits use the same semantic snapshot path. The first supported
feature parameter edits are:
- `usb_c_cutout`: width, height, corner radius,
- `glass_recess`: width, height, recess depth, ledge width, corner radius,
  insert thickness.

Submitting a changed value replaces the selected `SemanticFeature` in
`ProjectModel.features`; submitting an unchanged value is ignored by the shared
JSON equality guard.

Feature group inspector edits also use semantic snapshots. The first supported
group parameter edits are:
- `button_group`: layout, count, spacing, diameter, mode,
- `standoff_mounts`: diameter, hole diameter, height, clearance profile.

Submitting a changed group value replaces the selected `FeatureGroup` in
`ProjectModel.featureGroups`. Button group pattern fields are written to
`pattern`, item fields are written to `itemPrototype`, and standoff source
mounting-hole data stays grouped.

Project open/save commands are also wired from the toolbar. They use
`UndoBehavior.none`: saving should not change semantic state, and opening a file
replaces the current project with a fresh undo history for that file.

The first left rail generator command is `enclosure.create`. It opens a compact
parameter dialog powered by `CoreParameterSchemas.roundedEnclosure`, applies the
values to the semantic `Enclosure`, and commits the result as one undoable
project snapshot. Canceling the dialog does not create a history entry.

The second wired rail command is `component.place`. It is available from
workspace, enclosure, surface, and component context when at least one component
template exists. The command opens a placement dialog, creates a semantic
`ComponentPlacement`, and commits it as one undoable project snapshot. When the
shell has a transient active snap target from a clicked workplane hint, the
dialog is seeded from that target's coordinates and mounting side; the snap
target itself is not committed to undo history or saved project JSON.

The inspector may expose a shortcut for the same `component.place` flow when a
snap target is active. This shortcut is UI affordance only: undo history starts
only after the user confirms the placement dialog and a semantic
`ComponentPlacement` is written.

The viewport may also show a transient footprint preview for the active snap
target. This preview is not command state and does not enter undo/redo history.
Its fit feedback is computed from a temporary semantic placement and discarded
after rendering.

The placement dialog uses the same temporary-placement validation while the user
edits X/Y/Z/template values. Dialog validation is feedback only; undo history
starts only when the user confirms and the semantic placement is committed.
The shell also mirrors the dialog candidate into a transient viewport footprint;
that candidate is cleared on cancel/confirm and does not enter undo history.

The first surface-based rail command is `port.add_usb_c`. It is available only
when the active selection is a semantic surface. The command creates a
`usb_c_cutout` `SemanticFeature` targeted at that surface and commits it as one
undoable project snapshot.

The next surface-based rail command is `button.create_group`. It is also
available only when a semantic surface is selected. The command creates a
`button_group` `FeatureGroup` with editable pattern data and commits it as one
undoable project snapshot. Repeated buttons are not flattened into independent
features.

`glass.create_recess` is the first glass/insert command. It is available only
when a semantic surface is selected. The command creates a `glass_recess`
`SemanticFeature` targeted at that surface and commits it as one undoable
project snapshot.

`mount.generate` is the first component-driven command. It is available only
when the selected object is a component placement whose template has mounting
holes. The command creates a `standoff_mounts` `FeatureGroup` sourced from the
template holes and commits it as one undoable project snapshot. The mounts stay
editable as one semantic group instead of becoming unrelated independent
features.

Undo/redo now validates the active selection against the restored project. If
the selected semantic object no longer exists after undo, the shell falls back
to workspace selection instead of keeping a stale object ID.

Rail commands that are contextually available but not implemented yet stay
visible and disabled, instead of running empty callbacks.

## Rules

- Semantic state is the undo source of truth.
- Preview refreshes and generated geometry cache updates should not enter the undo stack.
- Advanced commands must remain unavailable unless advanced mode is enabled.
- UI should show command affordances compactly and contextually.

## Current limitations

- There is still no central command dispatcher; the shell has a small explicit
  action map for the first generator commands.
- Undo history is wired for first enclosure parameter edits, first USB-C/glass
  feature parameter edits, first button/mount feature-group parameter edits,
  and first enclosure creation/component placement/USB-C cutout/button
  group/glass recess/mount group only.
- Selection and active surface context are available from the shell selection
  model, but most editing commands are not wired yet.
