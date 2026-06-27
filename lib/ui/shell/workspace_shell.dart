import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../commands/app_command.dart';
import '../../commands/command_ids.dart';
import '../../commands/command_registry.dart';
import '../../geometry/geometry_service.dart';
import '../../project/project_model.dart';
import '../../selection/project_selection_resolver.dart';
import '../../selection/selection_model.dart';
import '../../validation/validation_result.dart';

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({
    super.key,
    required this.project,
    required this.geometryService,
  });

  final ProjectModel project;
  final GeometryService geometryService;

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  late Future<GeometryPreview> _previewFuture;
  late Future<ValidationReport> _validationFuture;
  SelectionModel _selection = const SelectionModel.workspace();

  @override
  void initState() {
    super.initState();
    _loadGeometry();
  }

  @override
  void didUpdateWidget(covariant WorkspaceShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project ||
        oldWidget.geometryService != widget.geometryService) {
      _loadGeometry();
    }
  }

  void _loadGeometry() {
    _previewFuture = widget.geometryService.generatePreview(widget.project);
    _validationFuture = widget.geometryService.validateGeometry(widget.project);
  }

  void _select(SelectionModel selection) {
    setState(() {
      _selection = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<GeometryPreview>(
          future: _previewFuture,
          builder: (context, previewSnapshot) {
            final preview = previewSnapshot.data;
            final surfaceLabels = {
              for (final surface in preview?.surfaces ?? <SelectableSurface>[])
                surface.id: surface.label,
            };
            final details = ProjectSelectionResolver(
              widget.project,
              surfaceLabels: surfaceLabels,
            ).describe(_selection);
            final commandContext = _selection.toCommandContext();

            return Column(
              children: [
                _TopToolbar(projectName: widget.project.projectName),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ToolRail(commandContext: commandContext),
                      _ProjectBrowser(
                        project: widget.project,
                        surfaces: preview?.surfaces ?? const [],
                        selection: _selection,
                        onSelectionChanged: _select,
                      ),
                      Expanded(
                        child: _ViewportArea(
                          project: widget.project,
                          preview: preview,
                          selection: _selection,
                          selectionDetails: details,
                        ),
                      ),
                      _Inspector(details: details),
                    ],
                  ),
                ),
                FutureBuilder<ValidationReport>(
                  future: _validationFuture,
                  builder: (context, snapshot) {
                    return _StatusBar(
                      report: snapshot.data,
                      selectionDetails: details,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopToolbar extends StatelessWidget {
  const _TopToolbar({required this.projectName});

  final String projectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registry = CommandRegistry.core;
    const commandContext = CommandContext(activeScope: CommandScope.workspace);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.view_in_ar_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            AppStrings.appTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              projectName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Spacer(),
          _ToolbarCommand(
            command: registry.byId(CommandIds.undo),
            context: commandContext,
            onPressed: () {},
          ),
          _ToolbarCommand(
            command: registry.byId(CommandIds.redo),
            context: commandContext,
            onPressed: () {},
          ),
          _ToolbarCommand(
            command: registry.byId(CommandIds.exportProject),
            context: commandContext,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ToolbarCommand extends StatelessWidget {
  const _ToolbarCommand({
    required this.command,
    required this.context,
    required this.onPressed,
  });

  final AppCommand command;
  final CommandContext context;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = command.isAvailable(this.context);

    return Tooltip(
      message: command.label,
      child: IconButton(
        icon: Icon(_iconForCommand(command.icon)),
        iconSize: 20,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

class _ToolRail extends StatelessWidget {
  const _ToolRail({required this.commandContext});

  final CommandContext commandContext;

  static const commandIds = [
    CommandIds.createEnclosure,
    CommandIds.placeComponent,
    CommandIds.addUsbC,
    CommandIds.createButtonGroup,
    CommandIds.generateMount,
    CommandIds.generateSlot,
    CommandIds.createGlassRecess,
    CommandIds.generateCase,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registry = CommandRegistry.core;

    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2226),
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < commandIds.length; index++)
            _RailButton(
              command: registry.byId(commandIds[index]),
              commandContext: commandContext,
            ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.command, required this.commandContext});

  final AppCommand command;
  final CommandContext commandContext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = command.isAvailable(commandContext);
    final contextual =
        commandContext.activeScope != null &&
        command.scopes.contains(commandContext.activeScope);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: command.label,
        child: IconButton(
          icon: Icon(_iconForCommand(command.icon)),
          color: contextual && enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          style: IconButton.styleFrom(
            backgroundColor: contextual && enabled
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: enabled ? () {} : null,
        ),
      ),
    );
  }
}

IconData _iconForCommand(String icon) {
  return switch (icon) {
    'undo' => Icons.undo_rounded,
    'redo' => Icons.redo_rounded,
    'export' => Icons.file_download_outlined,
    'enclosure' => Icons.crop_square_rounded,
    'component' => Icons.memory_rounded,
    'port' => Icons.settings_input_component_rounded,
    'button' => Icons.radio_button_checked_rounded,
    'mount' => Icons.construction_rounded,
    'slot' => Icons.inventory_2_outlined,
    'glass' => Icons.crop_16_9_rounded,
    'case' => Icons.cases_rounded,
    'advanced' => Icons.architecture_rounded,
    _ => Icons.circle_outlined,
  };
}

class _ProjectBrowser extends StatelessWidget {
  const _ProjectBrowser({
    required this.project,
    required this.surfaces,
    required this.selection,
    required this.onSelectionChanged,
  });

  final ProjectModel project;
  final List<SelectableSurface> surfaces;
  final SelectionModel selection;
  final ValueChanged<SelectionModel> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 226,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F22),
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        children: [
          _BrowserHeader(label: 'Проект'),
          _BrowserRow(
            icon: Icons.account_tree_rounded,
            title: project.projectName,
            subtitle: '${project.units} · ${project.printerProfile}',
            selected: selection.kind == SelectionKind.workspace,
            onTap: () => onSelectionChanged(const SelectionModel.workspace()),
          ),
          const SizedBox(height: 8),
          _BrowserHeader(label: 'Корпус'),
          for (final body in project.bodies)
            _BrowserRow(
              icon: Icons.crop_square_rounded,
              title: body.id,
              subtitle: body.shape,
              selected:
                  selection.kind == SelectionKind.enclosure &&
                  selection.id == body.id,
              onTap: () =>
                  onSelectionChanged(SelectionModel.enclosure(body.id)),
            ),
          if (surfaces.isNotEmpty) ...[
            const SizedBox(height: 8),
            _BrowserHeader(label: 'Грани'),
            for (final surface in surfaces)
              _BrowserRow(
                icon: Icons.flip_to_front_rounded,
                title: surface.label,
                subtitle: surface.id,
                depth: 1,
                selected:
                    selection.kind == SelectionKind.surface &&
                    selection.id == surface.id,
                onTap: () => onSelectionChanged(
                  SelectionModel.surface(
                    id: surface.id,
                    parentId: _surfaceParentId(project, surface.id),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 8),
          _BrowserHeader(label: 'Компоненты'),
          for (final placement in project.componentPlacements)
            _BrowserRow(
              icon: Icons.memory_rounded,
              title: _templateName(project, placement.templateId),
              subtitle: placement.id,
              selected:
                  selection.kind == SelectionKind.componentPlacement &&
                  selection.id == placement.id,
              onTap: () => onSelectionChanged(
                SelectionModel.componentPlacement(placement.id),
              ),
            ),
          for (final template in project.componentTemplates)
            _BrowserRow(
              icon: Icons.developer_board_rounded,
              title: template.name,
              subtitle: 'template',
              depth: 1,
              selected:
                  selection.kind == SelectionKind.componentTemplate &&
                  selection.id == template.id,
              onTap: () => onSelectionChanged(
                SelectionModel.componentTemplate(template.id),
              ),
            ),
          const SizedBox(height: 8),
          _BrowserHeader(label: 'Фичи'),
          for (final feature in project.features)
            _BrowserRow(
              icon: _featureIcon(feature.type),
              title: _featureTitle(feature.type),
              subtitle: feature.id,
              selected:
                  selection.kind == SelectionKind.feature &&
                  selection.id == feature.id,
              onTap: () =>
                  onSelectionChanged(SelectionModel.feature(feature.id)),
            ),
          for (final group in project.featureGroups)
            _BrowserRow(
              icon: Icons.apps_rounded,
              title: _featureTitle(group.type),
              subtitle: group.id,
              selected:
                  selection.kind == SelectionKind.featureGroup &&
                  selection.id == group.id,
              onTap: () =>
                  onSelectionChanged(SelectionModel.featureGroup(group.id)),
            ),
        ],
      ),
    );
  }
}

class _BrowserHeader extends StatelessWidget {
  const _BrowserHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BrowserRow extends StatelessWidget {
  const _BrowserRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.depth = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final int depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: depth * 12, top: 2, bottom: 2),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: selected ? FontWeight.w700 : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _surfaceParentId(ProjectModel project, String surfaceId) {
  for (final body in project.bodies) {
    if (surfaceId.startsWith('${body.id}.')) {
      return body.id;
    }
  }

  return project.bodies.firstOrNull?.id ?? 'project';
}

String _templateName(ProjectModel project, String templateId) {
  return project.componentTemplates
          .where((template) => template.id == templateId)
          .firstOrNull
          ?.name ??
      templateId;
}

IconData _featureIcon(String type) {
  return switch (type) {
    'usb_c_cutout' => Icons.settings_input_component_rounded,
    'button_group' => Icons.radio_button_checked_rounded,
    _ => Icons.extension_rounded,
  };
}

String _featureTitle(String type) {
  return switch (type) {
    'usb_c_cutout' => 'USB-C',
    'button_group' => 'Группа кнопок',
    _ => type.replaceAll('_', ' '),
  };
}

class _ViewportArea extends StatelessWidget {
  const _ViewportArea({
    required this.project,
    required this.preview,
    required this.selection,
    required this.selectionDetails,
  });

  final ProjectModel project;
  final GeometryPreview? preview;
  final SelectionModel selection;
  final ProjectSelectionDetails selectionDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF151719)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewportPainter(
                colorScheme: theme.colorScheme,
                selection: selection,
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 16,
            child: _ViewportLabel(
              icon: Icons.view_quilt_rounded,
              text: AppStrings.workspaceTitle,
              detail: preview?.backendLabel ?? AppStrings.mockBackend,
            ),
          ),
          const Positioned(right: 18, top: 16, child: _ViewCube()),
          Positioned(
            left: 18,
            bottom: 16,
            child: _ViewportLabel(
              icon: Icons.schema_rounded,
              text: selectionDetails.title,
              detail: selectionDetails.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewportLabel extends StatelessWidget {
  const _ViewportLabel({
    required this.icon,
    required this.text,
    required this.detail,
  });

  final IconData icon;
  final String text;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC1E2226),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      detail,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewCube extends StatelessWidget {
  const _ViewCube();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.square(
      dimension: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'ISO',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Inspector extends StatelessWidget {
  const _Inspector({required this.details});

  final ProjectSelectionDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 286,
      decoration: BoxDecoration(
        color: const Color(0xFF202428),
        border: Border(
          left: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      details.subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final property in details.properties)
            _InspectorValue(label: property.label, value: property.value),
        ],
      ),
    );
  }
}

class _InspectorValue extends StatelessWidget {
  const _InspectorValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.report, required this.selectionDetails});

  final ValidationReport? report;
  final ProjectSelectionDetails selectionDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasErrors = report?.hasErrors ?? false;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasErrors
                ? Icons.error_outline_rounded
                : Icons.check_circle_rounded,
            size: 18,
            color: hasErrors
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            hasErrors ? 'Validation issue' : AppStrings.previewReady,
            style: theme.textTheme.labelMedium,
          ),
          const Spacer(),
          Flexible(
            child: Text(
              hasErrors ? AppStrings.viewportHint : selectionDetails.status,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewportPainter extends CustomPainter {
  const _ViewportPainter({required this.colorScheme, required this.selection});

  final ColorScheme colorScheme;
  final SelectionModel selection;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = Offset(size.width / 2, size.height / 2);
    final bodySize = Size(size.width * 0.42, size.height * 0.34);
    final bodyRect = Rect.fromCenter(
      center: center,
      width: bodySize.width.clamp(260, 420),
      height: bodySize.height.clamp(150, 240),
    );
    final shadowRect = bodyRect.shift(const Offset(18, 20));
    final bodyPaint = Paint()..color = const Color(0xFF3D474D);
    final topPaint = Paint()..color = const Color(0xFF657179);
    final accentPaint = Paint()..color = colorScheme.primary;
    final portPaint = Paint()..color = colorScheme.secondary;

    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(26)),
      Paint()..color = Colors.black.withValues(alpha: 0.24),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(28)),
      bodyPaint,
    );

    final lidRect = bodyRect.deflate(16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lidRect, const Radius.circular(20)),
      topPaint,
    );

    final boardRect = Rect.fromCenter(
      center: center.translate(0, 4),
      width: lidRect.width * 0.42,
      height: lidRect.height * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF243F3D),
    );

    final buttonOffsets = [
      const Offset(28, 0),
      const Offset(0, -28),
      const Offset(0, 28),
      const Offset(-28, 0),
    ];
    for (final offset in buttonOffsets) {
      canvas.drawCircle(center + offset, 9, accentPaint);
      canvas.drawCircle(center + offset, 4, Paint()..color = Colors.black26);
    }

    final portRect = Rect.fromCenter(
      center: Offset(center.dx, bodyRect.bottom - 10),
      width: 54,
      height: 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(portRect, const Radius.circular(6)),
      portPaint,
    );

    final highlightPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final secondaryHighlightPaint = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (selection.kind == SelectionKind.enclosure) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect.inflate(4), const Radius.circular(31)),
        highlightPaint,
      );
    }

    if (selection.kind == SelectionKind.surface) {
      final selectedSurface = selection.id ?? '';
      if (selectedSurface.contains('top_lid')) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            lidRect.inflate(4),
            const Radius.circular(23),
          ),
          highlightPaint,
        );
      } else if (selectedSurface.contains('front_wall')) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            portRect.inflate(8),
            const Radius.circular(10),
          ),
          highlightPaint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            bodyRect.inflate(4),
            const Radius.circular(31),
          ),
          highlightPaint,
        );
      }
    }

    if (selection.kind == SelectionKind.componentPlacement ||
        selection.kind == SelectionKind.componentTemplate) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          boardRect.inflate(5),
          const Radius.circular(11),
        ),
        secondaryHighlightPaint,
      );
    }

    if (selection.kind == SelectionKind.feature &&
        selection.id == 'front_usb_c') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(portRect.inflate(8), const Radius.circular(10)),
        secondaryHighlightPaint,
      );
    }

    if (selection.kind == SelectionKind.feature &&
        selection.id == 'abxy_buttons') {
      for (final offset in buttonOffsets) {
        canvas.drawCircle(center + offset, 14, secondaryHighlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ViewportPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.selection != selection;
  }
}
