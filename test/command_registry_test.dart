import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/commands/app_command.dart';
import 'package:shell_case_easy_maker/commands/command_ids.dart';
import 'package:shell_case_easy_maker/commands/command_registry.dart';

void main() {
  test('core registry exposes stable command metadata', () {
    final registry = CommandRegistry.core;
    final command = registry.byId(CommandIds.createEnclosure);

    expect(command.id, CommandIds.createEnclosure);
    expect(command.label, 'Корпус');
    expect(command.undoBehavior, UndoBehavior.singleTransaction);
  });

  test('undo and redo availability follows context state', () {
    final registry = CommandRegistry.core;
    final undo = registry.byId(CommandIds.undo);
    final redo = registry.byId(CommandIds.redo);

    expect(undo.isAvailable(const CommandContext()), isFalse);
    expect(redo.isAvailable(const CommandContext()), isFalse);
    expect(undo.isAvailable(const CommandContext(canUndo: true)), isTrue);
    expect(redo.isAvailable(const CommandContext(canRedo: true)), isTrue);
  });

  test('open and save project commands stay workspace scoped', () {
    final registry = CommandRegistry.core;
    final open = registry.byId(CommandIds.openProject);
    final save = registry.byId(CommandIds.saveProject);

    expect(open.scopes, {CommandScope.workspace});
    expect(save.scopes, {CommandScope.workspace});
    expect(open.undoBehavior, UndoBehavior.none);
    expect(save.undoBehavior, UndoBehavior.none);
  });

  test('command palette command is global UI affordance without undo', () {
    final registry = CommandRegistry.core;
    final palette = registry.byId(CommandIds.commandPalette);

    expect(palette.label, 'Команды');
    expect(palette.undoBehavior, UndoBehavior.none);
    expect(
      palette.isAvailable(
        const CommandContext(activeScope: CommandScope.workspace),
      ),
      isTrue,
    );
    expect(
      palette.isAvailable(
        const CommandContext(activeScope: CommandScope.surface),
      ),
      isTrue,
    );
    expect(
      palette.isAvailable(
        const CommandContext(activeScope: CommandScope.component),
      ),
      isTrue,
    );
  });

  test('USB-C command works from surface and component context', () {
    final registry = CommandRegistry.core;
    final addUsbC = registry.byId(CommandIds.addUsbC);

    expect(
      addUsbC.isAvailable(
        const CommandContext(activeScope: CommandScope.workspace),
      ),
      isFalse,
    );
    expect(
      addUsbC.isAvailable(
        const CommandContext(
          activeScope: CommandScope.surface,
          selectedObjectId: 'main_enclosure',
          activeSurfaceId: 'main_enclosure.front_wall.outer',
        ),
      ),
      isTrue,
    );
    expect(
      addUsbC.isAvailable(
        const CommandContext(
          activeScope: CommandScope.component,
          selectedObjectId: 'button_board_placement',
        ),
      ),
      isTrue,
    );
  });

  test('button group command works from surface and component context', () {
    final registry = CommandRegistry.core;
    final createButtons = registry.byId(CommandIds.createButtonGroup);

    expect(
      createButtons.isAvailable(
        const CommandContext(activeScope: CommandScope.workspace),
      ),
      isFalse,
    );
    expect(
      createButtons.isAvailable(
        const CommandContext(
          activeScope: CommandScope.surface,
          selectedObjectId: 'main_enclosure',
          activeSurfaceId: 'main_enclosure.top_lid.outer',
        ),
      ),
      isTrue,
    );
    expect(
      createButtons.isAvailable(
        const CommandContext(
          activeScope: CommandScope.component,
          selectedObjectId: 'button_board_placement',
        ),
      ),
      isTrue,
    );
  });

  test('slot command creates holes only from active surface context', () {
    final registry = CommandRegistry.core;
    final generateSlot = registry.byId(CommandIds.generateSlot);

    expect(generateSlot.label, 'Отверстия');
    expect(
      generateSlot.isAvailable(
        const CommandContext(activeScope: CommandScope.workspace),
      ),
      isFalse,
    );
    expect(
      generateSlot.isAvailable(
        const CommandContext(
          activeScope: CommandScope.surface,
          selectedObjectId: 'main_enclosure.top_lid.outer',
          activeSurfaceId: 'main_enclosure.top_lid.outer',
        ),
      ),
      isTrue,
    );
  });

  test(
    'place component command works from workspace, enclosure, and surface context',
    () {
      final registry = CommandRegistry.core;
      final placeComponent = registry.byId(CommandIds.placeComponent);

      expect(
        placeComponent.isAvailable(
          const CommandContext(activeScope: CommandScope.workspace),
        ),
        isTrue,
      );
      expect(
        placeComponent.isAvailable(
          const CommandContext(activeScope: CommandScope.enclosure),
        ),
        isTrue,
      );
      expect(
        placeComponent.isAvailable(
          const CommandContext(activeScope: CommandScope.surface),
        ),
        isTrue,
      );
    },
  );

  test('advanced commands are hidden until advanced mode is enabled', () {
    final registry = CommandRegistry.core;
    final sketch = registry.byId(CommandIds.advancedSketch);

    expect(
      sketch.isAvailable(
        const CommandContext(activeScope: CommandScope.advanced),
      ),
      isFalse,
    );
    expect(
      sketch.isAvailable(
        const CommandContext(
          activeScope: CommandScope.advanced,
          advancedMode: true,
        ),
      ),
      isTrue,
    );
  });
}
