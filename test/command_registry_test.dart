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

  test('surface commands require an active surface', () {
    final registry = CommandRegistry.core;
    final addUsbC = registry.byId(CommandIds.addUsbC);

    expect(
      addUsbC.isAvailable(
        const CommandContext(activeScope: CommandScope.surface),
      ),
      isFalse,
    );
    expect(
      addUsbC.isAvailable(
        const CommandContext(
          activeScope: CommandScope.surface,
          activeSurfaceId: 'main_enclosure.front_wall.outer',
        ),
      ),
      isTrue,
    );
  });

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
