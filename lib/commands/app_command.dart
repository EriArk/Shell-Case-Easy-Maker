class AppCommand {
  const AppCommand({
    required this.id,
    required this.label,
    required this.icon,
    required this.scopes,
    required this.undoBehavior,
    this.availability = const {CommandAvailability.always},
  });

  final String id;
  final String label;
  final String icon;
  final Set<CommandScope> scopes;
  final UndoBehavior undoBehavior;
  final Set<CommandAvailability> availability;

  bool isAvailable(CommandContext context) {
    if (scopes.contains(CommandScope.advanced) && !context.advancedMode) {
      return false;
    }

    if (context.activeScope != null && !scopes.contains(context.activeScope)) {
      return false;
    }

    for (final rule in availability) {
      if (!rule.isSatisfiedBy(context)) {
        return false;
      }
    }

    return true;
  }
}

class CommandContext {
  const CommandContext({
    this.activeScope,
    this.selectedObjectId,
    this.activeSurfaceId,
    this.advancedMode = false,
    this.canUndo = false,
    this.canRedo = false,
  });

  final CommandScope? activeScope;
  final String? selectedObjectId;
  final String? activeSurfaceId;
  final bool advancedMode;
  final bool canUndo;
  final bool canRedo;
}

enum CommandAvailability {
  always,
  selectedObject,
  activeSurface,
  canUndo,
  canRedo;

  bool isSatisfiedBy(CommandContext context) {
    return switch (this) {
      CommandAvailability.always => true,
      CommandAvailability.selectedObject => context.selectedObjectId != null,
      CommandAvailability.activeSurface => context.activeSurfaceId != null,
      CommandAvailability.canUndo => context.canUndo,
      CommandAvailability.canRedo => context.canRedo,
    };
  }
}

enum CommandScope {
  workspace,
  enclosure,
  component,
  feature,
  surface,
  advanced,
}

enum UndoBehavior { none, singleTransaction, continuousTransaction }
