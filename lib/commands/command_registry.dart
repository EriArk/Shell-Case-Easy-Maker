import 'app_command.dart';
import 'command_ids.dart';

class CommandRegistry {
  CommandRegistry(Iterable<AppCommand> commands)
    : _commandsById = {
        for (final command in commands)
          if (command.id.trim().isNotEmpty) command.id: command,
      };

  static final core = CommandRegistry(CoreCommands.all);

  final Map<String, AppCommand> _commandsById;

  Iterable<AppCommand> get commands => _commandsById.values;

  AppCommand byId(String id) {
    final command = _commandsById[id];
    if (command == null) {
      throw ArgumentError.value(id, 'id', 'Unknown command id');
    }

    return command;
  }

  Iterable<AppCommand> availableFor(CommandContext context) {
    return commands.where((command) => command.isAvailable(context));
  }
}

class CoreCommands {
  const CoreCommands._();

  static const all = [
    AppCommand(
      id: CommandIds.undo,
      label: 'Отменить',
      icon: 'undo',
      scopes: {CommandScope.workspace},
      undoBehavior: UndoBehavior.none,
      availability: {CommandAvailability.canUndo},
    ),
    AppCommand(
      id: CommandIds.redo,
      label: 'Повторить',
      icon: 'redo',
      scopes: {CommandScope.workspace},
      undoBehavior: UndoBehavior.none,
      availability: {CommandAvailability.canRedo},
    ),
    AppCommand(
      id: CommandIds.openProject,
      label: 'Открыть',
      icon: 'open',
      scopes: {CommandScope.workspace},
      undoBehavior: UndoBehavior.none,
    ),
    AppCommand(
      id: CommandIds.saveProject,
      label: 'Сохранить',
      icon: 'save',
      scopes: {CommandScope.workspace},
      undoBehavior: UndoBehavior.none,
    ),
    AppCommand(
      id: CommandIds.exportProject,
      label: 'Экспорт',
      icon: 'export',
      scopes: {CommandScope.workspace},
      undoBehavior: UndoBehavior.none,
    ),
    AppCommand(
      id: CommandIds.createEnclosure,
      label: 'Корпус',
      icon: 'enclosure',
      scopes: {CommandScope.workspace, CommandScope.enclosure},
      undoBehavior: UndoBehavior.singleTransaction,
    ),
    AppCommand(
      id: CommandIds.placeComponent,
      label: 'Компоненты',
      icon: 'component',
      scopes: {
        CommandScope.workspace,
        CommandScope.enclosure,
        CommandScope.component,
      },
      undoBehavior: UndoBehavior.singleTransaction,
    ),
    AppCommand(
      id: CommandIds.addUsbC,
      label: 'Порты',
      icon: 'port',
      scopes: {CommandScope.surface, CommandScope.feature},
      undoBehavior: UndoBehavior.singleTransaction,
      availability: {CommandAvailability.activeSurface},
    ),
    AppCommand(
      id: CommandIds.createButtonGroup,
      label: 'Кнопки',
      icon: 'button',
      scopes: {CommandScope.surface, CommandScope.feature},
      undoBehavior: UndoBehavior.singleTransaction,
      availability: {CommandAvailability.activeSurface},
    ),
    AppCommand(
      id: CommandIds.generateMount,
      label: 'Крепёж',
      icon: 'mount',
      scopes: {CommandScope.component, CommandScope.feature},
      undoBehavior: UndoBehavior.singleTransaction,
      availability: {CommandAvailability.selectedObject},
    ),
    AppCommand(
      id: CommandIds.generateSlot,
      label: 'Слоты',
      icon: 'slot',
      scopes: {CommandScope.workspace, CommandScope.feature},
      undoBehavior: UndoBehavior.singleTransaction,
    ),
    AppCommand(
      id: CommandIds.createGlassRecess,
      label: 'Стекло',
      icon: 'glass',
      scopes: {CommandScope.surface, CommandScope.feature},
      undoBehavior: UndoBehavior.singleTransaction,
      availability: {CommandAvailability.activeSurface},
    ),
    AppCommand(
      id: CommandIds.generateCase,
      label: 'Чехлы',
      icon: 'case',
      scopes: {CommandScope.workspace, CommandScope.feature},
      undoBehavior: UndoBehavior.singleTransaction,
      availability: {CommandAvailability.selectedObject},
    ),
    AppCommand(
      id: CommandIds.advancedSketch,
      label: 'Эскиз',
      icon: 'advanced',
      scopes: {CommandScope.advanced},
      undoBehavior: UndoBehavior.singleTransaction,
    ),
  ];
}
