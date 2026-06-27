import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../commands/app_command.dart';
import '../../commands/command_ids.dart';
import '../../commands/command_registry.dart';
import '../../geometry/geometry_service.dart';
import '../../parameters/enclosure_parameter_adapter.dart';
import '../../parameters/parameter_model.dart';
import '../../project/project_model.dart';
import '../../selection/project_selection_resolver.dart';
import '../../selection/selection_model.dart';
import '../../validation/validation_result.dart';
import '../../viewport/viewport_controller.dart';

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
  final _viewportController = ViewportController();
  late ProjectModel _project;
  late Future<GeometryPreview> _previewFuture;
  late Future<ValidationReport> _validationFuture;
  SelectionModel _selection = const SelectionModel.workspace();

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _loadGeometry();
  }

  @override
  void didUpdateWidget(covariant WorkspaceShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project) {
      _project = widget.project;
      _loadGeometry();
    } else if (oldWidget.geometryService != widget.geometryService) {
      _loadGeometry();
    }
  }

  void _loadGeometry() {
    _previewFuture = widget.geometryService.generatePreview(_project);
    _validationFuture = widget.geometryService.validateGeometry(_project);
  }

  void _select(SelectionModel selection) {
    setState(() {
      _selection = selection;
      _viewportController.setSelectedSemanticId(selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(selection));
    });
  }

  void _orbitViewport(Offset delta) {
    setState(() {
      _viewportController.orbit(delta);
    });
  }

  void _panViewport(Offset delta) {
    setState(() {
      _viewportController.pan(delta);
    });
  }

  void _zoomViewport(double scrollDeltaY) {
    setState(() {
      _viewportController.zoomByScroll(scrollDeltaY);
    });
  }

  void _fitViewport() {
    setState(() {
      _viewportController.fit();
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
    });
  }

  void _selectViewportHit(ViewportHitResult? hit) {
    final selection = _selectionFromViewportHit(hit);
    if (selection != null) {
      _select(selection);
    }
  }

  void _updateEnclosureParameter(
    String enclosureId,
    String parameterId,
    Object? value,
  ) {
    final enclosure = _project.bodies
        .where((body) => body.id == enclosureId)
        .firstOrNull;
    if (enclosure == null) {
      return;
    }

    setState(() {
      _project = _project.replaceEnclosure(
        EnclosureParameterAdapter.updateParameter(
          enclosure,
          parameterId,
          value,
        ),
      );
      _loadGeometry();
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
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
              _project,
              surfaceLabels: surfaceLabels,
            ).describe(_selection);
            final commandContext = _selection.toCommandContext();

            return Column(
              children: [
                _TopToolbar(projectName: _project.projectName),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ToolRail(commandContext: commandContext),
                      _ProjectBrowser(
                        project: _project,
                        surfaces: preview?.surfaces ?? const [],
                        selection: _selection,
                        onSelectionChanged: _select,
                      ),
                      Expanded(
                        child: _ViewportArea(
                          project: _project,
                          preview: preview,
                          selection: _selection,
                          selectionDetails: details,
                          viewportState: _viewportController.state,
                          onOrbit: _orbitViewport,
                          onPan: _panViewport,
                          onZoom: _zoomViewport,
                          onFit: _fitViewport,
                          onHit: _selectViewportHit,
                        ),
                      ),
                      _Inspector(
                        details: details,
                        project: _project,
                        selection: _selection,
                        onEnclosureParameterChanged: _updateEnclosureParameter,
                      ),
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

GhostPreview? _ghostPreviewFor(SelectionModel selection) {
  if (selection.kind != SelectionKind.surface || selection.id == null) {
    return null;
  }

  if (selection.id!.contains('front_wall')) {
    return GhostPreview(
      kind: GhostPreviewKind.usbC,
      semanticId: 'ghost_usb_c',
      targetSurfaceId: selection.id!,
      label: 'USB-C',
    );
  }

  if (selection.id!.contains('top_lid')) {
    return GhostPreview(
      kind: GhostPreviewKind.buttonGroup,
      semanticId: 'ghost_button_group',
      targetSurfaceId: selection.id!,
      label: 'Группа кнопок',
    );
  }

  return null;
}

SelectionModel? _selectionFromViewportHit(ViewportHitResult? hit) {
  if (hit == null) {
    return const SelectionModel.workspace();
  }

  return switch (hit.kind) {
    ViewportHitKind.enclosure => SelectionModel.enclosure(hit.semanticId),
    ViewportHitKind.surface => SelectionModel.surface(
      id: hit.semanticId,
      parentId: hit.parentId ?? 'main_enclosure',
    ),
    ViewportHitKind.componentPlacement => SelectionModel.componentPlacement(
      hit.semanticId,
    ),
    ViewportHitKind.feature => SelectionModel.feature(hit.semanticId),
  };
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

class _ViewportArea extends StatefulWidget {
  const _ViewportArea({
    required this.project,
    required this.preview,
    required this.selection,
    required this.selectionDetails,
    required this.viewportState,
    required this.onOrbit,
    required this.onPan,
    required this.onZoom,
    required this.onFit,
    required this.onHit,
  });

  final ProjectModel project;
  final GeometryPreview? preview;
  final SelectionModel selection;
  final ProjectSelectionDetails selectionDetails;
  final ViewportState viewportState;
  final ValueChanged<Offset> onOrbit;
  final ValueChanged<Offset> onPan;
  final ValueChanged<double> onZoom;
  final VoidCallback onFit;
  final ValueChanged<ViewportHitResult?> onHit;

  @override
  State<_ViewportArea> createState() => _ViewportAreaState();
}

class _ViewportAreaState extends State<_ViewportArea> {
  static const _hitTester = MockViewportHitTester();

  Offset? _lastPointerPosition;
  Offset? _pointerDownPosition;
  bool _movedSincePointerDown = false;

  void _handlePointerDown(PointerDownEvent event) {
    _lastPointerPosition = event.localPosition;
    _pointerDownPosition = event.localPosition;
    _movedSincePointerDown = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final last = _lastPointerPosition;
    _lastPointerPosition = event.localPosition;

    if (last == null || event.buttons == 0) {
      return;
    }

    final delta = event.localPosition - last;
    final downPosition = _pointerDownPosition;
    if (downPosition != null &&
        (event.localPosition - downPosition).distance > 4) {
      _movedSincePointerDown = true;
    }

    if ((event.buttons & kSecondaryMouseButton) != 0 ||
        (event.buttons & kMiddleMouseButton) != 0) {
      widget.onPan(delta);
      return;
    }

    widget.onOrbit(delta);
  }

  void _handlePointerUp(PointerUpEvent event, Size viewportSize) {
    _lastPointerPosition = null;

    if (!_movedSincePointerDown) {
      widget.onHit(
        _hitTester.hitTest(
          position: event.localPosition,
          size: viewportSize,
          state: widget.viewportState,
          bodyDimensions: _mockViewportBodyDimensions(widget.project),
        ),
      );
    }

    _pointerDownPosition = null;
    _movedSincePointerDown = false;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _lastPointerPosition = null;
    _pointerDownPosition = null;
    _movedSincePointerDown = false;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      widget.onZoom(event.scrollDelta.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF151719)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = constraints.biggest;

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: (event) => _handlePointerUp(event, viewportSize),
            onPointerCancel: _handlePointerCancel,
            onPointerSignal: _handlePointerSignal,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ViewportPainter(
                        colorScheme: theme.colorScheme,
                        bodyDimensions: _mockViewportBodyDimensions(
                          widget.project,
                        ),
                        selection: widget.selection,
                        viewportState: widget.viewportState,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 16,
                    child: _ViewportLabel(
                      icon: Icons.view_quilt_rounded,
                      text: AppStrings.workspaceTitle,
                      detail:
                          '${widget.preview?.backendLabel ?? AppStrings.mockBackend} · '
                          '${widget.viewportState.viewLabel}',
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 16,
                    child: _ViewCube(
                      viewportState: widget.viewportState,
                      onFit: widget.onFit,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 16,
                    child: _ViewportLabel(
                      icon: Icons.schema_rounded,
                      text: widget.selectionDetails.title,
                      detail: widget.selectionDetails.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
  const _ViewCube({required this.viewportState, required this.onFit});

  final ViewportState viewportState;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.square(
      dimension: 64,
      child: Tooltip(
        message: 'Вписать вид',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onFit,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: viewportState.yawDegrees * math.pi / 720,
                  child: Text(
                    'ISO',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Inspector extends StatelessWidget {
  const _Inspector({
    required this.details,
    required this.project,
    required this.selection,
    required this.onEnclosureParameterChanged,
  });

  final ProjectSelectionDetails details;
  final ProjectModel project;
  final SelectionModel selection;
  final void Function(String enclosureId, String parameterId, Object? value)
  onEnclosureParameterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedEnclosure = selection.kind == SelectionKind.enclosure
        ? project.bodies.where((body) => body.id == selection.id).firstOrNull
        : null;

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
          if (selectedEnclosure != null) ...[
            const SizedBox(height: 14),
            _EnclosureParameterEditor(
              enclosure: selectedEnclosure,
              onChanged: (parameterId, value) {
                onEnclosureParameterChanged(
                  selectedEnclosure.id,
                  parameterId,
                  value,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _EnclosureParameterEditor extends StatelessWidget {
  const _EnclosureParameterEditor({
    required this.enclosure,
    required this.onChanged,
  });

  final Enclosure enclosure;
  final void Function(String parameterId, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schema = EnclosureParameterAdapter.schema;
    final values = EnclosureParameterAdapter.valuesFrom(enclosure);
    final issues = EnclosureParameterAdapter.validateValues(values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              schema.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final parameter in schema.parameters) ...[
          if (parameter.kind == ParameterKind.choice)
            _ParameterChoiceField(
              parameter: parameter,
              value: values[parameter.id] as String?,
              onChanged: (value) => onChanged(parameter.id, value),
            )
          else
            _ParameterNumberField(
              parameter: parameter,
              value: values[parameter.id],
              onSubmitted: (value) => onChanged(parameter.id, value),
            ),
          const SizedBox(height: 10),
        ],
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              issue.message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _ParameterNumberField extends StatefulWidget {
  const _ParameterNumberField({
    required this.parameter,
    required this.value,
    required this.onSubmitted,
  });

  final ParameterDefinition parameter;
  final Object? value;
  final ValueChanged<double> onSubmitted;

  @override
  State<_ParameterNumberField> createState() => _ParameterNumberFieldState();
}

class _ParameterNumberFieldState extends State<_ParameterNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatParameterValue());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ParameterNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = _formatParameterValue();
    if (!_focusNode.hasFocus && _controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed != null) {
      widget.onSubmitted(parsed);
      _focusNode.unfocus();
    } else {
      _controller.text = _formatParameterValue();
    }
  }

  String _formatParameterValue() {
    final value = widget.value;
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toStringAsFixed(0);
      }
      return value.toStringAsFixed(1);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final parameter = widget.parameter;
    final range = parameter.range;
    final suffix = parameter.unit;
    final helperText = range == null
        ? null
        : '${_formatNumber(range.min)}-${_formatNumber(range.max)}';

    return TextFormField(
      key: ValueKey('enclosure-param-${parameter.id}'),
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: _submit,
      decoration: InputDecoration(
        labelText: parameter.label,
        helperText: helperText,
        suffixText: suffix,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
    );
  }
}

class _ParameterChoiceField extends StatelessWidget {
  const _ParameterChoiceField({
    required this.parameter,
    required this.value,
    required this.onChanged,
  });

  final ParameterDefinition parameter;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('enclosure-param-${parameter.id}'),
      initialValue: value,
      isExpanded: true,
      items: [
        for (final option in parameter.options)
          DropdownMenuItem(value: option.id, child: Text(option.label)),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: parameter.label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
    );
  }
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
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
  const _ViewportPainter({
    required this.colorScheme,
    required this.bodyDimensions,
    required this.selection,
    required this.viewportState,
  });

  final ColorScheme colorScheme;
  final MockViewportBodyDimensions bodyDimensions;
  final SelectionModel selection;
  final ViewportState viewportState;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = MockViewportLayout.fromSize(
      size,
      viewportState,
      bodyDimensions: bodyDimensions,
    );
    final gridStep = 32 * viewportState.zoom;
    final gridOrigin = Offset(
      viewportState.panOffset.dx % gridStep,
      viewportState.panOffset.dy % gridStep,
    );
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    for (var x = gridOrigin.dx - gridStep; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = gridOrigin.dy - gridStep; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final bodyPaint = Paint()..color = const Color(0xFF3D474D);
    final topPaint = Paint()..color = const Color(0xFF657179);
    final accentPaint = Paint()..color = colorScheme.primary;
    final portPaint = Paint()..color = colorScheme.secondary;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.shadowRect,
        Radius.circular(layout.bodyRadius),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.24),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.bodyRect,
        Radius.circular(layout.bodyRadius),
      ),
      bodyPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.lidRect,
        Radius.circular(layout.lidRadius),
      ),
      topPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.boardRect,
        Radius.circular(layout.boardRadius),
      ),
      Paint()..color = const Color(0xFF243F3D),
    );

    for (final center in layout.buttonCenters) {
      canvas.drawCircle(center, layout.buttonRadius, accentPaint);
      canvas.drawCircle(
        center,
        layout.buttonRadius * 0.44,
        Paint()..color = Colors.black26,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.portRect,
        Radius.circular(layout.portRadius),
      ),
      portPaint,
    );

    _paintGhostPreview(canvas, layout);

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
        RRect.fromRectAndRadius(
          layout.bodyRect.inflate(4),
          Radius.circular(layout.bodyRadius + 3),
        ),
        highlightPaint,
      );
    }

    if (selection.kind == SelectionKind.surface) {
      final selectedSurface = selection.id ?? '';
      if (selectedSurface.contains('top_lid')) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            layout.lidRect.inflate(4),
            Radius.circular(layout.lidRadius + 3),
          ),
          highlightPaint,
        );
      } else if (selectedSurface.contains('front_wall')) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            layout.portRect.inflate(8),
            Radius.circular(layout.portRadius + 4),
          ),
          highlightPaint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            layout.bodyRect.inflate(4),
            Radius.circular(layout.bodyRadius + 3),
          ),
          highlightPaint,
        );
      }
    }

    if (selection.kind == SelectionKind.componentPlacement ||
        selection.kind == SelectionKind.componentTemplate) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.boardRect.inflate(5),
          Radius.circular(layout.boardRadius + 3),
        ),
        secondaryHighlightPaint,
      );
    }

    if (selection.kind == SelectionKind.feature &&
        selection.id == 'front_usb_c') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.portRect.inflate(8),
          Radius.circular(layout.portRadius + 4),
        ),
        secondaryHighlightPaint,
      );
    }

    if (selection.kind == SelectionKind.feature &&
        selection.id == 'abxy_buttons') {
      for (final center in layout.buttonCenters) {
        canvas.drawCircle(
          center,
          layout.buttonRadius + 5,
          secondaryHighlightPaint,
        );
      }
    }
  }

  void _paintGhostPreview(Canvas canvas, MockViewportLayout layout) {
    final ghost = viewportState.ghostPreview;
    if (ghost == null) {
      return;
    }

    final ghostFill = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final ghostStroke = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (ghost.kind == GhostPreviewKind.usbC) {
      final rect = layout.portRect.shift(Offset(0, -22 * viewportState.zoom));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(layout.portRadius)),
        ghostFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(layout.portRadius)),
        ghostStroke,
      );
      return;
    }

    final ghostCenter = layout.lidRect.center.translate(
      layout.lidRect.width * 0.22,
      -layout.lidRect.height * 0.18,
    );
    final distance = 22 * viewportState.zoom;
    final radius = 7 * viewportState.zoom;
    final centers = [
      ghostCenter + Offset(distance, 0),
      ghostCenter + Offset(0, -distance),
      ghostCenter + Offset(0, distance),
      ghostCenter + Offset(-distance, 0),
    ];
    for (final center in centers) {
      canvas.drawCircle(center, radius, ghostFill);
      canvas.drawCircle(center, radius, ghostStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ViewportPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.bodyDimensions != bodyDimensions ||
        oldDelegate.selection != selection ||
        oldDelegate.viewportState != viewportState;
  }
}

MockViewportBodyDimensions _mockViewportBodyDimensions(ProjectModel project) {
  final enclosure = project.bodies.firstOrNull;
  if (enclosure == null) {
    return const MockViewportBodyDimensions();
  }

  return MockViewportBodyDimensions(
    width: _sizeAt(enclosure, 0, 120),
    depth: _sizeAt(enclosure, 1, 70),
    height: _sizeAt(enclosure, 2, 28),
    cornerRadius: enclosure.cornerRadius,
  );
}

double _sizeAt(Enclosure enclosure, int index, double fallback) {
  return enclosure.size.length > index ? enclosure.size[index] : fallback;
}
