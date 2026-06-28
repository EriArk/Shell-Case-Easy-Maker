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

Project open/save commands are also wired from the toolbar. They use
`UndoBehavior.none`: saving should not change semantic state, and opening a file
replaces the current project with a fresh undo history for that file.

The first left rail generator command is `enclosure.create`. It opens a compact
parameter dialog powered by `CoreParameterSchemas.roundedEnclosure`, applies the
values to the semantic `Enclosure`, and commits the result as one undoable
project snapshot. Canceling the dialog does not create a history entry.

Rail commands that are contextually available but not implemented yet stay
visible and disabled, instead of running empty callbacks.

## Rules

- Semantic state is the undo source of truth.
- Preview refreshes and generated geometry cache updates should not enter the undo stack.
- Advanced commands must remain unavailable unless advanced mode is enabled.
- UI should show command affordances compactly and contextually.

## Current limitations

- There is still no central command dispatcher; the shell has a small explicit
  action map for the first generator command.
- Undo history is wired for first enclosure parameter edits and first enclosure
  creation only.
- Selection and active surface context are available from the shell selection
  model, but most editing commands are not wired yet.
