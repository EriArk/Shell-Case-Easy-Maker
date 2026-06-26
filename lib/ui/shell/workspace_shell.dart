import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../geometry/geometry_service.dart';
import '../../project/project_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopToolbar(projectName: widget.project.projectName),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ToolRail(),
                  Expanded(
                    child: FutureBuilder<GeometryPreview>(
                      future: _previewFuture,
                      builder: (context, snapshot) {
                        return _ViewportArea(
                          project: widget.project,
                          preview: snapshot.data,
                        );
                      },
                    ),
                  ),
                  _Inspector(project: widget.project),
                ],
              ),
            ),
            FutureBuilder<ValidationReport>(
              future: _validationFuture,
              builder: (context, snapshot) {
                return _StatusBar(report: snapshot.data);
              },
            ),
          ],
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
          _ToolbarIcon(
            icon: Icons.undo_rounded,
            label: 'Undo',
            onPressed: () {},
          ),
          _ToolbarIcon(
            icon: Icons.redo_rounded,
            label: 'Redo',
            onPressed: () {},
          ),
          _ToolbarIcon(
            icon: Icons.file_download_outlined,
            label: 'Export',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(icon: Icon(icon), iconSize: 20, onPressed: onPressed),
    );
  }
}

class _ToolRail extends StatelessWidget {
  const _ToolRail();

  static const tools = [
    _ToolItem(Icons.crop_square_rounded, AppStrings.toolEnclosure),
    _ToolItem(Icons.memory_rounded, AppStrings.toolComponents),
    _ToolItem(Icons.settings_input_component_rounded, AppStrings.toolPorts),
    _ToolItem(Icons.radio_button_checked_rounded, AppStrings.toolButtons),
    _ToolItem(Icons.construction_rounded, AppStrings.toolMounts),
    _ToolItem(Icons.inventory_2_outlined, AppStrings.toolSlots),
    _ToolItem(Icons.crop_16_9_rounded, AppStrings.toolGlass),
    _ToolItem(Icons.cases_rounded, AppStrings.toolCases),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          for (var index = 0; index < tools.length; index++)
            _RailButton(item: tools[index], selected: index == 0),
        ],
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.item, required this.selected});

  final _ToolItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: item.label,
        child: IconButton(
          icon: Icon(item.icon),
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          style: IconButton.styleFrom(
            backgroundColor: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _ViewportArea extends StatelessWidget {
  const _ViewportArea({required this.project, required this.preview});

  final ProjectModel project;
  final GeometryPreview? preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF151719)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewportPainter(colorScheme: theme.colorScheme),
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
              text: AppStrings.semanticModel,
              detail:
                  '${project.bodies.length} body, '
                  '${project.features.length} features',
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

    return DecoratedBox(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: theme.textTheme.labelMedium),
                Text(
                  detail,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
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
  const _Inspector({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = project.bodies.firstOrNull;

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
              Text(
                AppStrings.inspectorTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (body != null) ...[
            _InspectorValue(label: 'Shape', value: body.shape),
            _InspectorValue(
              label: 'Size',
              value: body.size
                  .map((value) => '${value.toStringAsFixed(0)} mm')
                  .join(' x '),
            ),
            _InspectorValue(
              label: 'Wall',
              value: '${body.wallThickness.toStringAsFixed(1)} mm',
            ),
            _InspectorValue(
              label: 'Radius',
              value: '${body.cornerRadius.toStringAsFixed(1)} mm',
            ),
            _InspectorValue(label: 'Lid', value: body.lid?.type ?? 'none'),
          ],
          const Divider(height: 28),
          _InspectorValue(
            label: 'Components',
            value: project.componentPlacements.length.toString(),
          ),
          _InspectorValue(
            label: 'Features',
            value: project.features.length.toString(),
          ),
          _InspectorValue(label: 'Fit', value: project.printerProfile),
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
  const _StatusBar({required this.report});

  final ValidationReport? report;

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
          Text(
            AppStrings.viewportHint,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewportPainter extends CustomPainter {
  const _ViewportPainter({required this.colorScheme});

  final ColorScheme colorScheme;

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
  }

  @override
  bool shouldRepaint(covariant _ViewportPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
