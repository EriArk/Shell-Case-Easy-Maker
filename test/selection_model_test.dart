import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/commands/app_command.dart';
import 'package:shell_case_easy_maker/selection/selection_model.dart';

void main() {
  test('workspace selection maps to workspace command context', () {
    const selection = SelectionModel.workspace();
    final context = selection.toCommandContext();

    expect(selection.selectedObjectId, isNull);
    expect(selection.activeSurfaceId, isNull);
    expect(context.activeScope, CommandScope.workspace);
  });

  test('surface selection exposes active surface and parent object', () {
    const selection = SelectionModel.surface(
      id: 'main_enclosure.top_lid.outer',
      parentId: 'main_enclosure',
    );
    final context = selection.toCommandContext();

    expect(selection.selectedObjectId, 'main_enclosure');
    expect(selection.activeSurfaceId, 'main_enclosure.top_lid.outer');
    expect(context.activeScope, CommandScope.surface);
    expect(context.activeSurfaceId, 'main_enclosure.top_lid.outer');
  });

  test('component selection enables selected object commands', () {
    const selection = SelectionModel.componentPlacement(
      'button_board_placement',
    );
    final context = selection.toCommandContext(canUndo: true);

    expect(context.activeScope, CommandScope.component);
    expect(context.selectedObjectId, 'button_board_placement');
    expect(context.canUndo, isTrue);
  });
}
