import '../commands/app_command.dart';

enum SelectionKind {
  workspace,
  enclosure,
  surface,
  componentPlacement,
  componentTemplate,
  feature,
  featureGroup,
}

class SelectionModel {
  const SelectionModel.workspace()
    : kind = SelectionKind.workspace,
      id = null,
      parentId = null;

  const SelectionModel.enclosure(this.id)
    : kind = SelectionKind.enclosure,
      parentId = null;

  const SelectionModel.surface({required this.id, required this.parentId})
    : kind = SelectionKind.surface,
      assert(id != null),
      assert(parentId != null);

  const SelectionModel.componentPlacement(this.id)
    : kind = SelectionKind.componentPlacement,
      parentId = null;

  const SelectionModel.componentTemplate(this.id)
    : kind = SelectionKind.componentTemplate,
      parentId = null;

  const SelectionModel.feature(this.id)
    : kind = SelectionKind.feature,
      parentId = null;

  const SelectionModel.featureGroup(this.id)
    : kind = SelectionKind.featureGroup,
      parentId = null;

  final SelectionKind kind;
  final String? id;
  final String? parentId;

  String? get selectedObjectId {
    return switch (kind) {
      SelectionKind.workspace => null,
      SelectionKind.surface => parentId,
      _ => id,
    };
  }

  String? get activeSurfaceId {
    return kind == SelectionKind.surface ? id : null;
  }

  CommandScope get activeScope {
    return switch (kind) {
      SelectionKind.workspace => CommandScope.workspace,
      SelectionKind.enclosure => CommandScope.enclosure,
      SelectionKind.surface => CommandScope.surface,
      SelectionKind.componentPlacement ||
      SelectionKind.componentTemplate => CommandScope.component,
      SelectionKind.feature ||
      SelectionKind.featureGroup => CommandScope.feature,
    };
  }

  CommandContext toCommandContext({
    bool advancedMode = false,
    bool canUndo = false,
    bool canRedo = false,
  }) {
    return CommandContext(
      activeScope: activeScope,
      selectedObjectId: selectedObjectId,
      activeSurfaceId: activeSurfaceId,
      advancedMode: advancedMode,
      canUndo: canUndo,
      canRedo: canRedo,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectionModel &&
        other.kind == kind &&
        other.id == id &&
        other.parentId == parentId;
  }

  @override
  int get hashCode => Object.hash(kind, id, parentId);
}
