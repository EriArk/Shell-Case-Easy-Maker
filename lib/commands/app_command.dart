class AppCommand {
  const AppCommand({
    required this.id,
    required this.label,
    required this.icon,
    required this.scopes,
    required this.undoBehavior,
  });

  final String id;
  final String label;
  final String icon;
  final Set<CommandScope> scopes;
  final UndoBehavior undoBehavior;

  bool isAvailable(CommandContext context) {
    if (scopes.contains(CommandScope.advanced) && !context.advancedMode) {
      return false;
    }

    return context.activeScope == null || scopes.contains(context.activeScope);
  }
}

class CommandContext {
  const CommandContext({
    this.activeScope,
    this.selectedObjectId,
    this.advancedMode = false,
  });

  final CommandScope? activeScope;
  final String? selectedObjectId;
  final bool advancedMode;
}

enum CommandScope { workspace, enclosure, component, feature, advanced }

enum UndoBehavior { none, singleTransaction, continuousTransaction }
