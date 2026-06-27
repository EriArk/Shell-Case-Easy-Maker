import 'app_command.dart';

class UndoHistory<T> {
  UndoHistory(T initialState) : _current = initialState;

  T _current;
  final List<UndoTransaction<T>> _undoStack = [];
  final List<UndoTransaction<T>> _redoStack = [];

  T get current => _current;

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  int get undoDepth => _undoStack.length;

  int get redoDepth => _redoStack.length;

  void commit({
    required String id,
    required String label,
    required T nextState,
    UndoBehavior behavior = UndoBehavior.singleTransaction,
    String? continuousGroupId,
  }) {
    if (behavior == UndoBehavior.none) {
      _current = nextState;
      _redoStack.clear();
      return;
    }

    if (behavior == UndoBehavior.continuousTransaction &&
        continuousGroupId != null &&
        _undoStack.isNotEmpty &&
        _undoStack.last.continuousGroupId == continuousGroupId) {
      final previous = _undoStack.removeLast();
      _undoStack.add(previous.copyWith(after: nextState));
      _current = nextState;
      _redoStack.clear();
      return;
    }

    _undoStack.add(
      UndoTransaction<T>(
        id: id,
        label: label,
        before: _current,
        after: nextState,
        behavior: behavior,
        continuousGroupId: continuousGroupId,
      ),
    );
    _current = nextState;
    _redoStack.clear();
  }

  T undo() {
    if (_undoStack.isEmpty) {
      return _current;
    }

    final transaction = _undoStack.removeLast();
    _redoStack.add(transaction);
    _current = transaction.before;
    return _current;
  }

  T redo() {
    if (_redoStack.isEmpty) {
      return _current;
    }

    final transaction = _redoStack.removeLast();
    _undoStack.add(transaction);
    _current = transaction.after;
    return _current;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

class UndoTransaction<T> {
  const UndoTransaction({
    required this.id,
    required this.label,
    required this.before,
    required this.after,
    required this.behavior,
    this.continuousGroupId,
  });

  final String id;
  final String label;
  final T before;
  final T after;
  final UndoBehavior behavior;
  final String? continuousGroupId;

  UndoTransaction<T> copyWith({T? after}) {
    return UndoTransaction<T>(
      id: id,
      label: label,
      before: before,
      after: after ?? this.after,
      behavior: behavior,
      continuousGroupId: continuousGroupId,
    );
  }
}
