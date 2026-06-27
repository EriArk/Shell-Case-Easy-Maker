import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/commands/app_command.dart';
import 'package:shell_case_easy_maker/commands/undo_history.dart';

void main() {
  test('single transactions undo and redo semantic state snapshots', () {
    final history = UndoHistory<int>(0);

    history.commit(id: 'set.width', label: 'Set width', nextState: 120);
    history.commit(id: 'set.height', label: 'Set height', nextState: 70);

    expect(history.current, 70);
    expect(history.canUndo, isTrue);
    expect(history.canRedo, isFalse);
    expect(history.undoDepth, 2);

    expect(history.undo(), 120);
    expect(history.undo(), 0);
    expect(history.canUndo, isFalse);
    expect(history.canRedo, isTrue);
    expect(history.redoDepth, 2);

    expect(history.redo(), 120);
    expect(history.redo(), 70);
  });

  test('none behavior changes state without entering undo stack', () {
    final history = UndoHistory<String>('draft');

    history.commit(
      id: 'preview.refresh',
      label: 'Refresh preview',
      nextState: 'preview',
      behavior: UndoBehavior.none,
    );

    expect(history.current, 'preview');
    expect(history.canUndo, isFalse);
    expect(history.undoDepth, 0);
  });

  test(
    'continuous transactions collapse repeated edits into one undo step',
    () {
      final history = UndoHistory<double>(8);

      history.commit(
        id: 'button.diameter',
        label: 'Button diameter',
        nextState: 8.5,
        behavior: UndoBehavior.continuousTransaction,
        continuousGroupId: 'button.diameter',
      );
      history.commit(
        id: 'button.diameter',
        label: 'Button diameter',
        nextState: 9,
        behavior: UndoBehavior.continuousTransaction,
        continuousGroupId: 'button.diameter',
      );
      history.commit(
        id: 'button.diameter',
        label: 'Button diameter',
        nextState: 9.5,
        behavior: UndoBehavior.continuousTransaction,
        continuousGroupId: 'button.diameter',
      );

      expect(history.current, 9.5);
      expect(history.undoDepth, 1);
      expect(history.undo(), 8);
      expect(history.redo(), 9.5);
    },
  );

  test('new commits clear redo history', () {
    final history = UndoHistory<int>(0);

    history.commit(id: 'a', label: 'A', nextState: 1);
    history.commit(id: 'b', label: 'B', nextState: 2);
    history.undo();
    history.commit(id: 'c', label: 'C', nextState: 3);

    expect(history.current, 3);
    expect(history.canRedo, isFalse);
  });
}
