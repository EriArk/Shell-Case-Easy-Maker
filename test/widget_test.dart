import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/app/case_maker_app.dart';
import 'package:shell_case_easy_maker/commands/command_ids.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_file_dialog_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';
import 'package:shell_case_easy_maker/ui/shell/workspace_shell.dart';
import 'package:shell_case_easy_maker/viewport/viewport_controller.dart';

void main() {
  testWidgets('workspace shell shows semantic enclosure UI', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text('Shell Case Easy Maker'), findsOneWidget);
    expect(find.text('main_enclosure'), findsWidgets);
    expect(find.text('Custom Button Board'), findsWidgets);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('workspace side panels can collapse and expand', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('project-panel-collapsed')), findsNothing);
    expect(
      find.byKey(const ValueKey('inspector-panel-collapsed')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('project-panel-collapse')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('inspector-panel-collapse')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('project-panel-collapse')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('project-panel-collapsed')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('project-panel-expand')), findsOneWidget);
    expect(find.byKey(const ValueKey('project-panel-collapse')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('project-panel-expand')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('project-panel-collapsed')), findsNothing);
    expect(
      find.byKey(const ValueKey('project-panel-collapse')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('inspector-panel-collapse')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('inspector-panel-collapsed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('inspector-panel-expand')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('inspector-panel-collapse')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('inspector-panel-expand')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('inspector-panel-collapsed')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('inspector-panel-collapse')),
      findsOneWidget,
    );
  });

  testWidgets('viewport context menu exposes surface generator actions', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    await _secondaryTapTopLidWorkplane(tester, const Offset(30, 0));

    expect(
      find.byKey(
        const ValueKey('viewport-context-command-${CommandIds.placeComponent}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('viewport-context-command-${CommandIds.addUsbC}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'viewport-context-command-${CommandIds.createGlassRecess}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'viewport-context-command-${CommandIds.createButtonGroup}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('viewport-context-command-${CommandIds.generateSlot}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('viewport-context-command-${CommandIds.generateMount}'),
      ),
      findsNothing,
    );
  });

  testWidgets('viewport context menu can start snap-seeded cutout command', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    await _secondaryTapTopLidWorkplane(tester, const Offset(30, 0));

    await tester.tap(
      find.byKey(
        const ValueKey('viewport-context-command-${CommandIds.generateSlot}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cutout-shape')), findsOneWidget);
    expect(_dialogNumberText(tester, 'circular-cutout-position-x'), '30');
    expect(_dialogNumberText(tester, 'circular-cutout-position-y'), '0');
  });

  testWidgets('command palette opens from toolbar and shortcut', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('toolbar-command-${CommandIds.commandPalette}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('command-palette-search')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.createEnclosure}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.generateSlot}'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('command-palette-cancel')));
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('command-palette-search')),
      findsOneWidget,
    );
  });

  testWidgets('command palette filters and launches surface command', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('toolbar-command-${CommandIds.commandPalette}'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('command-palette-search')),
      'slot',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.generateSlot}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.createEnclosure}'),
      ),
      findsNothing,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.generateSlot}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cutout-shape')), findsOneWidget);
  });

  testWidgets('command palette reveals sketch only in advanced mode', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('toolbar-command-${CommandIds.commandPalette}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.advancedSketch}'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('command-palette-cancel')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('advanced-mode-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('toolbar-command-${CommandIds.commandPalette}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('command-palette-command-${CommandIds.advancedSketch}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('semantic validation warnings are visible in status bar', (
    tester,
  ) async {
    final initial = ProjectModel.initial();
    final project = initial.replaceEnclosure(
      initial.bodies.single.copyWith(wallThickness: 0.4),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Предупреждение'), findsOneWidget);
    expect(
      find.text('Стенка тоньше 0.8 mm может плохо печататься.'),
      findsOneWidget,
    );
  });

  testWidgets('semantic validation details sheet lists all issues', (
    tester,
  ) async {
    final initial = ProjectModel.initial();
    final project = initial
        .replaceEnclosure(initial.bodies.single.copyWith(wallThickness: 0.4))
        .replaceFeature(
          const SemanticFeature(
            id: 'glass_recess_1',
            type: 'glass_recess',
            targetSurface: 'main_enclosure.top_lid.outer',
            operation: 'recess',
            parameters: {
              'width': 42.0,
              'height': 24.0,
              'recessDepth': 1.2,
              'ledgeWidth': 1.5,
              'cornerRadius': 2.0,
            },
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('status-validation-details')));
    await tester.pumpAndSettle();

    expect(find.text('Проверка проекта'), findsOneWidget);
    expect(find.text('Ошибки: 0'), findsOneWidget);
    expect(find.text('Предупреждения: 2'), findsOneWidget);
    expect(
      find.text('Стенка тоньше 0.8 mm может плохо печататься.'),
      findsWidgets,
    );
    expect(
      find.text('Глубина посадки не оставляет запаса стенки под стеклом.'),
      findsOneWidget,
    );
    expect(find.text('glass_recess_1'), findsOneWidget);
  });

  testWidgets('semantic validation issue row selects its target', (
    tester,
  ) async {
    final project = ProjectModel.initial().replaceFeature(
      const SemanticFeature(
        id: 'glass_recess_1',
        type: 'glass_recess',
        targetSurface: 'main_enclosure.top_lid.outer',
        operation: 'recess',
        parameters: {
          'width': 42.0,
          'height': 24.0,
          'recessDepth': 2.2,
          'ledgeWidth': 1.5,
          'cornerRadius': 2.0,
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('status-validation-details')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('glass_recess_1').last);
    await tester.pumpAndSettle();

    expect(find.text('Проверка проекта'), findsNothing);
    expect(find.text('ledgeWidth'), findsOneWidget);
    expect(find.text('glass_recess_1'), findsWidgets);
  });

  testWidgets('surface and placement selections expose workplane overlay', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    const overlayKey = ValueKey('mock-workplane-overlay-active');
    expect(find.byKey(overlayKey), findsNothing);

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    expect(find.byKey(overlayKey), findsOneWidget);

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();

    expect(find.byKey(overlayKey), findsOneWidget);
  });

  testWidgets('viewport exposes geometry preview mesh from service', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('geometry-preview-mesh-active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-semantic-overlay-mode-active')),
      findsOneWidget,
    );
    expect(find.textContaining('fake_worker_preview'), findsOneWidget);
  });

  testWidgets('native preview keeps semantic overlays muted until selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('native-semantic-overlays-muted')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-semantic-overlays-focused')),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.text('USB-C'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('USB-C').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('native-semantic-overlays-muted')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('native-semantic-overlays-focused')),
      findsOneWidget,
    );
  });

  testWidgets('native preview hides mapped schematic feature overlays', (
    tester,
  ) async {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'button_group_1',
        type: 'button_group',
        targetSurface: 'main_enclosure.top_lid.outer',
        pattern: {'layout': 'row', 'count': 2, 'spacing': 14.0},
        itemPrototype: {'type': 'button', 'shape': 'circle', 'diameter': 8.0},
        placement: {'anchor': 'center'},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const _MappedFeaturePreviewMeshService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('native-mapped-feature-overlays-hidden')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-mapped-feature-group-overlays-hidden')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('USB-C'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('USB-C').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('geometry-preview-surface-highlight-active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-mapped-feature-overlays-hidden')),
      findsOneWidget,
    );
  });

  testWidgets('viewport preset controls switch standard camera views', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('viewport-preset-top')));
    await tester.pumpAndSettle();
    expect(find.textContaining('TOP · 1.00x · 0° / 70°'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('viewport-preset-right')));
    await tester.pumpAndSettle();
    expect(find.textContaining('RGT · 1.00x · 90° / 0°'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('viewport-fit-view')));
    await tester.pumpAndSettle();
    expect(find.textContaining('ISO · 1.00x · -24° / 18°'), findsOneWidget);
  });

  testWidgets('selected surface highlights mapped preview mesh range', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    const highlightKey = ValueKey('geometry-preview-surface-highlight-active');
    expect(find.byKey(highlightKey), findsNothing);

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    expect(find.byKey(highlightKey), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mock-workplane-overlay-active')),
      findsOneWidget,
    );
  });

  testWidgets('native preview softens surface workplane overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('mock-workplane-overlay-active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-workplane-overlay-hidden')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-workplane-overlay-focused')),
      findsNothing,
    );

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('native-workplane-overlay-hidden')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('native-workplane-overlay-focused')),
      findsOneWidget,
    );
  });

  testWidgets('native preview shows active surface snap as point only', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidSnap(tester, const Offset(30, 0));

    expect(
      find.byKey(const ValueKey('active-snap-target-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mock-workplane-overlay-active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-workplane-overlay-hidden')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('native-workplane-overlay-focused')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('native-workplane-overlay-point-only')),
      findsOneWidget,
    );
  });

  testWidgets('selected feature highlights mapped preview mesh range', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _PreviewMeshGeometryService()),
    );
    await tester.pumpAndSettle();

    const highlightKey = ValueKey('geometry-preview-surface-highlight-active');
    expect(find.byKey(highlightKey), findsNothing);

    await tester.scrollUntilVisible(
      find.text('USB-C'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('USB-C').first);
    await tester.pumpAndSettle();

    expect(find.byKey(highlightKey), findsOneWidget);
  });

  testWidgets('native preview mesh click selects mapped semantic feature', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CaseMakerApp(geometryService: _SingleFeaturePreviewMeshService()),
    );
    await tester.pumpAndSettle();

    const highlightKey = ValueKey('geometry-preview-surface-highlight-active');
    expect(find.byKey(highlightKey), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    await tester.tapAt(tester.getCenter(canvasFinder));
    await tester.pumpAndSettle();

    expect(find.byKey(highlightKey), findsOneWidget);
  });

  testWidgets('selected feature group highlights mapped preview mesh range', (
    tester,
  ) async {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'button_group_1',
        type: 'button_group',
        targetSurface: 'main_enclosure.front_wall.outer',
        pattern: {'layout': 'row', 'count': 2, 'spacing': 14.0},
        itemPrototype: {
          'type': 'button',
          'shape': 'circle',
          'diameter': 8.0,
          'ringWidth': 1.2,
          'ringProtrusion': 0.45,
          'capDiameter': 7.4,
          'capHeight': 1.2,
          'stemDiameter': 3.0,
          'stemDepth': 2.8,
          'travel': 0.8,
          'switchClearance': 0.3,
          'guideClearance': 0.25,
          'mode': 'plunger',
        },
        placement: {'anchor': 'center'},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const _PreviewMeshGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const highlightKey = ValueKey('geometry-preview-surface-highlight-active');
    expect(find.byKey(highlightKey), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const buttonGroup = MockViewportFeatureGroupPreview(
      semanticId: 'button_group_1',
      kind: MockViewportFeatureGroupKind.buttonGroup,
      sourcePositions: [Offset(-7, 0), Offset(7, 0)],
      referenceWidth: 120,
      referenceHeight: 70,
      itemDiameter: 8,
    );

    await tester.tapAt(
      canvasTopLeft + layout.featureGroupCenters(buttonGroup).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(highlightKey), findsOneWidget);
  });

  testWidgets('selected standoff group highlights mapped preview mesh range', (
    tester,
  ) async {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'standoff_mounts_1',
        type: 'standoff_mounts',
        targetSurface: 'main_enclosure.bottom_inside',
        pattern: {
          'layout': 'from_component_mounting_holes',
          'sourceTemplateId': 'custom_button_board_v1',
          'holePositions': [
            {
              'id': 'mh1',
              'position': [-20.0, -12.0],
              'diameter': 2.2,
            },
          ],
        },
        itemPrototype: {
          'type': 'standoff',
          'diameter': 5.0,
          'holeDiameter': 2.2,
          'height': 4.0,
        },
        placement: {'anchor': 'component_mounting_holes'},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const _PreviewMeshGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const highlightKey = ValueKey('geometry-preview-surface-highlight-active');
    expect(find.byKey(highlightKey), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const mountGroup = MockViewportFeatureGroupPreview(
      semanticId: 'standoff_mounts_1',
      kind: MockViewportFeatureGroupKind.standoffMounts,
      sourcePositions: [Offset(-20, -12)],
      referenceWidth: 48,
      referenceHeight: 32,
      itemDiameter: 5,
    );

    await tester.tapAt(
      canvasTopLeft + layout.featureGroupCenters(mountGroup).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(highlightKey), findsOneWidget);
  });

  testWidgets('surface snap point seeds component placement dialog', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'main_enclosure.top_lid.outer',
      kind: MockViewportWorkplaneKind.topLid,
      width: 120,
      height: 70,
      snapPoints: [
        Offset.zero,
        Offset(30, 0),
        Offset(-30, 0),
        Offset(0, 17.5),
        Offset(0, -17.5),
      ],
    );

    await tester.tapAt(
      canvasTopLeft +
          layout.workplaneLocalToCanvas(workplane, const Offset(30, 0)),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('active-snap-target-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mock-active-snap-placement-preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('active-snap-placement-check')),
      findsOneWidget,
    );
    expect(find.text('Плата помещается в текущий корпус.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('rail-command-${CommandIds.placeComponent}')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('place-component-snap-hint')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('place-component-x')),
              matching: find.byType(TextFormField),
            ),
          )
          .initialValue,
      '30',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('place-component-y')),
              matching: find.byType(TextFormField),
            ),
          )
          .initialValue,
      '0',
    );
  });

  testWidgets('guided component placement picks viewport snap point', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('rail-command-${CommandIds.placeComponent}')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('place-component-pick-from-viewport')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('component-placement-guide-banner')),
      findsOneWidget,
    );

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidWorkplane(tester, const Offset(30, 0));

    expect(
      find.byKey(const ValueKey('component-placement-guide-banner')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('place-component-snap-hint')),
      findsOneWidget,
    );
    expect(_dialogNumberText(tester, 'place-component-x'), '30');
    expect(_dialogNumberText(tester, 'place-component-y'), '0');
  });

  testWidgets('active snap target inspector action opens placement dialog', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidSnap(tester, const Offset(30, 0));

    final placeFromSnap = find.byKey(
      const ValueKey('active-snap-place-component'),
    );
    expect(placeFromSnap, findsOneWidget);

    await tester.tap(placeFromSnap);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('place-component-snap-hint')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('place-component-x')),
              matching: find.byType(TextFormField),
            ),
          )
          .initialValue,
      '30',
    );
  });

  testWidgets('snap-seeded circular cutout starts from clicked surface point', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidWorkplane(tester, const Offset(42, 20));

    final createHoleFromSnap = find.byKey(
      const ValueKey('active-snap-create-circular-cutout'),
    );
    expect(createHoleFromSnap, findsOneWidget);

    await tester.tap(createHoleFromSnap);
    await tester.pumpAndSettle();

    expect(_dialogNumberText(tester, 'circular-cutout-position-x'), '42');
    expect(_dialogNumberText(tester, 'circular-cutout-position-y'), '20');

    await tester.tap(find.byKey(const ValueKey('circular-cutout-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('circular_cutout_1'), findsWidgets);
    expect(
      find.byKey(const ValueKey('active-snap-target-panel')),
      findsNothing,
    );

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();
    expect(find.text('diameter'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdHole = MockViewportFeaturePreview(
      semanticId: 'circular_cutout_1',
      kind: MockViewportFeatureKind.circularCutout,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 8,
      height: 8,
      cornerRadius: 4,
      position: Offset(42, 20),
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdHole).center);
    await tester.pumpAndSettle();

    expect(find.text('diameter'), findsOneWidget);
  });

  testWidgets('snap-seeded USB-C stores front wall surface position', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final saveFile = File('snap_usb_c.enclosure.json');
    final dialog = _FakeProjectFileDialogService(saveFile: saveFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Front wall').first);
    await tester.pumpAndSettle();
    await _tapFrontWallWorkplane(tester, const Offset(-48, 10));

    final createUsbCFromSnap = find.byKey(
      const ValueKey('active-snap-create-usb-c'),
    );
    expect(createUsbCFromSnap, findsOneWidget);

    await tester.ensureVisible(createUsbCFromSnap);
    await tester.pumpAndSettle();
    await tester.tap(createUsbCFromSnap);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('usb-c-confirm')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('usb-c-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsWidgets);
    expect(
      find.byKey(const ValueKey('active-snap-target-panel')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final saved = await fileService.readProject(saveFile);
    final created = saved.features.singleWhere(
      (feature) => feature.id == 'usb_c_cutout_2',
    );

    expect(created.targetSurface, 'main_enclosure.front_wall.outer');
    expect(created.placement?['projectionMode'], 'surface_snap_target');
    expect(created.placement?['surfacePosition'], [-48.0, 24.0]);
    expect(created.placement?['surfaceAxes'], ['x', 'z']);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();
    expect(find.text('width'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdUsbC = MockViewportFeaturePreview(
      semanticId: 'usb_c_cutout_2',
      kind: MockViewportFeatureKind.usbC,
      targetSurfaceId: 'main_enclosure.front_wall.outer',
      width: 10.5,
      height: 4.2,
      cornerRadius: 1,
      referenceHeight: 28,
      position: Offset(-48, 24),
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdUsbC).center);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsOneWidget);
  });

  testWidgets('snap-seeded glass recess stores top lid surface position', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final saveFile = File('snap_glass.enclosure.json');
    final dialog = _FakeProjectFileDialogService(saveFile: saveFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidWorkplane(tester, const Offset(-34, 16));

    final createGlassFromSnap = find.byKey(
      const ValueKey('active-snap-create-glass-recess'),
    );
    expect(createGlassFromSnap, findsOneWidget);

    await tester.ensureVisible(createGlassFromSnap);
    await tester.pumpAndSettle();
    await tester.tap(createGlassFromSnap);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('glass-recess-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('glass_recess_1'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final saved = await fileService.readProject(saveFile);
    final created = saved.features.singleWhere(
      (feature) => feature.id == 'glass_recess_1',
    );

    expect(created.placement?['projectionMode'], 'surface_snap_target');
    expect(created.placement?['surfacePosition'], [-34.0, 16.0]);
    expect(created.placement?['surfaceAxes'], ['x', 'y']);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();
    expect(find.text('ledgeWidth'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdGlass = MockViewportFeaturePreview(
      semanticId: 'glass_recess_1',
      kind: MockViewportFeatureKind.glassRecess,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 42,
      height: 24,
      cornerRadius: 2,
      position: Offset(-34, 16),
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdGlass).center);
    await tester.pumpAndSettle();

    expect(find.text('ledgeWidth'), findsOneWidget);
  });

  testWidgets('snap-seeded button group stores top lid surface position', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final saveFile = File('snap_buttons.enclosure.json');
    final dialog = _FakeProjectFileDialogService(saveFile: saveFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidWorkplane(tester, const Offset(-36, 10));

    final createButtonsFromSnap = find.byKey(
      const ValueKey('active-snap-create-button-group'),
    );
    expect(createButtonsFromSnap, findsOneWidget);

    await tester.ensureVisible(createButtonsFromSnap);
    await tester.pumpAndSettle();
    await tester.tap(createButtonsFromSnap);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('button-group-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('button_group_1'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final saved = await fileService.readProject(saveFile);
    final created = saved.featureGroups.singleWhere(
      (group) => group.id == 'button_group_1',
    );

    expect(created.placement['projectionMode'], 'surface_snap_target');
    expect(created.placement['surfacePosition'], [-36.0, 10.0]);
    expect(created.placement['surfaceAxes'], ['x', 'y']);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    const modeFieldKey = ValueKey('feature-group-param-button_group_1-mode');
    expect(find.byKey(modeFieldKey, skipOffstage: false), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdButtonGroup = MockViewportFeatureGroupPreview(
      semanticId: 'button_group_1',
      kind: MockViewportFeatureGroupKind.buttonGroup,
      sourcePositions: [Offset(14, 0)],
      referenceWidth: 120,
      referenceHeight: 70,
      itemDiameter: 8,
      position: Offset(-36, 10),
    );

    await tester.tapAt(
      canvasTopLeft + layout.featureGroupCenters(createdButtonGroup).first,
    );
    await tester.pumpAndSettle();

    final modeField = find.byKey(modeFieldKey, skipOffstage: false);
    await tester.ensureVisible(modeField);
    await tester.pump();

    expect(modeField, findsOneWidget);
  });

  testWidgets('snap-seeded placement dialog can align a component anchor', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidSnap(tester, const Offset(30, 0));

    await tester.tap(
      find.byKey(const ValueKey('rail-command-${CommandIds.placeComponent}')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('place-component-anchor')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('place-component-anchor')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USB-C usb_c').last);
    await tester.pumpAndSettle();

    expect(_dialogNumberText(tester, 'place-component-x'), '30');
    expect(_dialogNumberText(tester, 'place-component-y'), '16');

    await tester.tap(
      find.byKey(const ValueKey('place-component-rotate-right')),
    );
    await tester.pump();

    expect(_dialogNumberText(tester, 'place-component-rotation-z'), '90');
    expect(_dialogNumberText(tester, 'place-component-x'), '14');
    expect(_dialogNumberText(tester, 'place-component-y'), '0');

    await tester.tap(find.byKey(const ValueKey('place-component-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsWidgets);
    expect(find.text('14 x 0 x 4 mm'), findsOneWidget);
  });

  testWidgets('active snap target can be cleared from inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidSnap(tester, const Offset(30, 0));

    expect(
      find.byKey(const ValueKey('active-snap-target-panel')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('active-snap-clear')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('active-snap-target-panel')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('mock-active-snap-placement-preview')),
      findsNothing,
    );
  });

  testWidgets('active snap placement check reports oversized footprint', (
    tester,
  ) async {
    final baseTemplate = ComponentTemplate.buttonBoard();
    final oversizedTemplate = ComponentTemplate(
      id: baseTemplate.id,
      name: baseTemplate.name,
      board: const ComponentBoard(
        outline: BoardOutline(
          type: 'rounded_rectangle',
          width: 140,
          height: 32,
          cornerRadius: 2,
        ),
        thickness: 1.6,
        referencePlane: 'bottom',
      ),
      mountingHoles: baseTemplate.mountingHoles,
      features: baseTemplate.features,
      zones: baseTemplate.zones,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial().copyWith(
            componentTemplates: [oversizedTemplate],
            componentPlacements: const [],
          ),
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await _tapTopLidSnap(tester, const Offset(30, 0));

    expect(
      find.byKey(const ValueKey('active-snap-placement-check')),
      findsOneWidget,
    );
    expect(find.textContaining('Компонент выходит'), findsOneWidget);
  });

  testWidgets('selecting a feature updates contextual inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text('width'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('USB-C'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('USB-C').first);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsOneWidget);
    expect(find.text('front_usb_c'), findsWidgets);
  });

  testWidgets(
    'selected USB-C feature inspector edits parameters through undo',
    (tester) async {
      await tester.pumpWidget(const CaseMakerApp());
      await tester.pumpAndSettle();

      final undoButton = find.byKey(
        const ValueKey('toolbar-command-${CommandIds.undo}'),
      );

      await tester.scrollUntilVisible(
        find.text('USB-C'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('USB-C').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('feature-param-front_usb_c-width')),
        '14',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('14.0'), findsWidgets);
      expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

      await tester.tap(undoButton);
      await _pumpAsyncUi(tester);

      expect(find.text('10.5'), findsWidgets);
    },
  );

  testWidgets(
    'selected glass recess feature inspector edits parameters through undo',
    (tester) async {
      final project = ProjectModel.initial().replaceFeature(
        const SemanticFeature(
          id: 'glass_recess_1',
          type: 'glass_recess',
          targetSurface: 'main_enclosure.top_lid.outer',
          operation: 'recess',
          parameters: {
            'width': 42.0,
            'height': 24.0,
            'recessDepth': 1.2,
            'ledgeWidth': 1.5,
            'cornerRadius': 2.0,
            'insertThickness': 1.0,
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WorkspaceShell(
            project: project,
            geometryService: const MockGeometryService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final undoButton = find.byKey(
        const ValueKey('toolbar-command-${CommandIds.undo}'),
      );

      final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
      final canvasTopLeft = tester.getTopLeft(canvasFinder);
      final canvasSize = tester.getSize(canvasFinder);
      final layout = MockViewportLayout.fromSize(
        canvasSize,
        const ViewportState(),
      );
      const glassFeature = MockViewportFeaturePreview(
        semanticId: 'glass_recess_1',
        kind: MockViewportFeatureKind.glassRecess,
        targetSurfaceId: 'main_enclosure.top_lid.outer',
        width: 42,
        height: 24,
        cornerRadius: 2,
      );

      await tester.tapAt(
        canvasTopLeft + layout.featureRect(glassFeature).center,
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('feature-param-glass_recess_1-width')),
        '60',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('60.0'), findsWidgets);
      expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

      await tester.tap(undoButton);
      await _pumpAsyncUi(tester);

      expect(find.text('42.0'), findsWidgets);
    },
  );

  testWidgets('selected button group inspector edits pattern through undo', (
    tester,
  ) async {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'button_group_1',
        type: 'button_group',
        targetSurface: 'main_enclosure.top_lid.outer',
        pattern: {'layout': 'diamond', 'count': 4, 'spacing': 14.0},
        itemPrototype: {
          'type': 'button',
          'shape': 'circle',
          'diameter': 8.0,
          'capDiameter': 7.4,
          'capHeight': 1.2,
          'stemDiameter': 3.0,
          'stemDepth': 2.8,
          'travel': 0.8,
          'switchClearance': 0.3,
          'guideClearance': 0.25,
          'mode': 'plunger',
        },
        placement: {'anchor': 'center'},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    final browserGroup = find.text('button_group_1', skipOffstage: false);
    await tester.ensureVisible(browserGroup);
    await tester.pumpAndSettle();
    await tester.tap(browserGroup.first);
    await tester.pumpAndSettle();

    Finder parameterField(String id) => find.byKey(
      ValueKey('feature-group-param-button_group_1-$id'),
      skipOffstage: false,
    );

    Future<void> enterParameterText(Finder field, String value) async {
      await tester.ensureVisible(field);
      await tester.pump();
      await tester.enterText(field, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    final countField = parameterField('count');

    await enterParameterText(countField, '6');

    expect(tester.widget<TextFormField>(countField).controller?.text, '6');
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(tester.widget<TextFormField>(countField).controller?.text, '4');

    final ringWidthField = parameterField('ringWidth');
    final ringProtrusionField = parameterField('ringProtrusion');
    final capDiameterField = parameterField('capDiameter');
    final stemDepthField = parameterField('stemDepth');
    final travelField = parameterField('travel');
    final switchClearanceField = parameterField('switchClearance');
    final guideClearanceField = parameterField('guideClearance');

    expect(
      tester.widget<TextFormField>(ringWidthField).controller?.text,
      '1.2',
    );
    expect(
      tester.widget<TextFormField>(ringProtrusionField).controller?.text,
      '0.45',
    );
    expect(
      tester.widget<TextFormField>(capDiameterField).controller?.text,
      '7.4',
    );
    expect(
      tester.widget<TextFormField>(stemDepthField).controller?.text,
      '2.8',
    );
    expect(tester.widget<TextFormField>(travelField).controller?.text, '0.80');
    expect(
      tester.widget<TextFormField>(switchClearanceField).controller?.text,
      '0.30',
    );
    expect(
      tester.widget<TextFormField>(guideClearanceField).controller?.text,
      '0.25',
    );

    await enterParameterText(ringWidthField, '2.4');

    expect(
      tester.widget<TextFormField>(ringWidthField).controller?.text,
      '2.4',
    );

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(
      tester.widget<TextFormField>(ringWidthField).controller?.text,
      '1.2',
    );

    await enterParameterText(capDiameterField, '6.4');

    expect(
      tester.widget<TextFormField>(capDiameterField).controller?.text,
      '6.4',
    );

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(
      tester.widget<TextFormField>(capDiameterField).controller?.text,
      '7.4',
    );

    await enterParameterText(travelField, '1.1');

    expect(tester.widget<TextFormField>(travelField).controller?.text, '1.10');

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(tester.widget<TextFormField>(travelField).controller?.text, '0.80');
  });
  testWidgets(
    'selected standoff group inspector edits mount parameters through undo',
    (tester) async {
      final project = ProjectModel.initial().replaceFeatureGroup(
        const FeatureGroup(
          id: 'standoff_mounts_1',
          type: 'standoff_mounts',
          targetSurface: 'main_enclosure.bottom_inside',
          pattern: {
            'layout': 'from_component_mounting_holes',
            'count': 4,
            'sourcePlacementId': 'button_board_placement',
            'sourceTemplateId': 'custom_button_board_v1',
            'holePositions': [
              {
                'id': 'mh1',
                'position': [-20.0, -12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
              {
                'id': 'mh2',
                'position': [20.0, -12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
              {
                'id': 'mh3',
                'position': [-20.0, 12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
              {
                'id': 'mh4',
                'position': [20.0, 12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
            ],
          },
          itemPrototype: {
            'type': 'standoff',
            'diameter': 5.0,
            'height': 4.0,
            'holeDiameter': 2.2,
            'screw': 'M2',
            'clearanceProfile': 'fdm_normal',
          },
          placement: {
            'anchor': 'component_mounting_holes',
            'componentPlacementId': 'button_board_placement',
            'componentPosition': [0.0, 0.0, 4.0],
            'componentRotation': [0.0, 0.0, 0.0],
            'mountingSide': 'bottom_inside',
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WorkspaceShell(
            project: project,
            geometryService: const MockGeometryService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final undoButton = find.byKey(
        const ValueKey('toolbar-command-${CommandIds.undo}'),
      );

      final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
      final canvasTopLeft = tester.getTopLeft(canvasFinder);
      final canvasSize = tester.getSize(canvasFinder);
      final layout = MockViewportLayout.fromSize(
        canvasSize,
        const ViewportState(),
      );
      const mountGroup = MockViewportFeatureGroupPreview(
        semanticId: 'standoff_mounts_1',
        kind: MockViewportFeatureGroupKind.standoffMounts,
        sourcePositions: [
          Offset(-20, -12),
          Offset(20, -12),
          Offset(-20, 12),
          Offset(20, 12),
        ],
        referenceWidth: 48,
        referenceHeight: 32,
        itemDiameter: 5,
      );

      await tester.tapAt(
        canvasTopLeft + layout.featureGroupCenters(mountGroup).first,
      );
      await tester.pumpAndSettle();

      final holeField = find.byKey(
        const ValueKey('feature-group-param-standoff_mounts_1-holeDiameter'),
      );

      await tester.enterText(holeField, '9');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(tester.widget<TextFormField>(holeField).controller?.text, '4.2');
      expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

      await tester.tap(undoButton);
      await _pumpAsyncUi(tester);

      expect(tester.widget<TextFormField>(holeField).controller?.text, '2.2');
    },
  );

  testWidgets('editing enclosure width updates semantic inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('enclosure parameter edits can be undone and redone', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );
    final redoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.redo}'),
    );

    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(tester.widget<IconButton>(redoButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);
    expect(tester.widget<IconButton>(redoButton).onPressed, isNull);

    await tester.tap(undoButton);
    await tester.pumpAndSettle();

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(tester.widget<IconButton>(redoButton).onPressed, isNotNull);

    await tester.tap(redoButton);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('create enclosure rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createEnclosure}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(createButton).onPressed, isNotNull);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create-enclosure-confirm')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('create-enclosure-param-width')),
      '180',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('create-enclosure-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('180 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('create enclosure rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createEnclosure}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(createButton);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('create-enclosure-param-width')),
      '180',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('create-enclosure-cancel')));
    await _pumpAsyncUi(tester);

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('create enclosure presets apply guided dimensions', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('rail-command-${CommandIds.createEnclosure}')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('create-enclosure-preset-handheld')),
    );
    await tester.pumpAndSettle();

    expect(_textFormFieldText(tester, 'create-enclosure-param-width'), '160');
    expect(_textFormFieldText(tester, 'create-enclosure-param-depth'), '84');
    expect(_textFormFieldText(tester, 'create-enclosure-param-height'), '34');
    expect(
      _textFormFieldText(tester, 'create-enclosure-param-wallThickness'),
      '2.4',
    );
    expect(
      find.byKey(const ValueKey('create-enclosure-validation-summary')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('create-enclosure-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('160 x 84 x 34 mm'), findsWidgets);
  });

  testWidgets('create enclosure validation blocks unusable inner cavity', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('rail-command-${CommandIds.createEnclosure}')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('create-enclosure-param-width')),
      '20',
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('create-enclosure-param-wallThickness')),
      '8',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create-enclosure-validation-error-0')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('create-enclosure-confirm')),
          )
          .onPressed,
      isNull,
    );

    final boardPreset = find.byKey(
      const ValueKey('create-enclosure-preset-board_case'),
    );
    await tester.ensureVisible(boardPreset);
    await tester.pumpAndSettle();
    await tester.tap(boardPreset);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create-enclosure-validation-error-0')),
      findsNothing,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('create-enclosure-confirm')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('place component rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final placeButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.placeComponent}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(placeButton).onPressed, isNotNull);

    await tester.tap(placeButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('place-component-confirm')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mock-placement-candidate-preview')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('place-component-x')),
      '24',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('place-component-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsWidgets);
    expect(find.text('24 x 0 x 4 mm'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mock-placement-candidate-preview')),
      findsNothing,
    );
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsNothing);
  });

  testWidgets('place component dialog validates current candidate placement', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('rail-command-${CommandIds.placeComponent}')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('place-component-fit-check')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('place-component-template-summary')),
      findsOneWidget,
    );
    expect(find.textContaining('48 x 32 x 1.6 mm'), findsOneWidget);
    expect(find.text('Плата помещается в текущий корпус.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('place-component-x')),
      '200',
    );
    await tester.pump();

    expect(find.textContaining('Компонент выходит'), findsOneWidget);
  });

  testWidgets(
    'place component dialog quick presets update candidate position',
    (tester) async {
      await tester.pumpWidget(const CaseMakerApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('rail-command-${CommandIds.placeComponent}')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('place-component-preset-right')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('place-component-preset-right')),
      );
      await tester.pump();

      final xField = tester.widget<TextFormField>(
        find.descendant(
          of: find.byKey(const ValueKey('place-component-x')),
          matching: find.byType(TextFormField),
        ),
      );
      expect(xField.controller?.text, '26');
      expect(
        find.byKey(const ValueKey('mock-placement-candidate-preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('place-component-fit-check')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('place-component-confirm')));
      await _pumpAsyncUi(tester);

      expect(find.text('custom_button_board_v1_placement_2'), findsWidgets);
      expect(find.text('26 x 0 x 4 mm'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('mock-placement-candidate-preview')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'place component dialog rotation updates candidate fit and commit',
    (tester) async {
      await tester.pumpWidget(const CaseMakerApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('rail-command-${CommandIds.placeComponent}')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('place-component-x')),
        '36',
      );
      await tester.pump();

      expect(find.textContaining('Компонент выходит'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('place-component-rotate-right')),
      );
      await tester.pump();

      final rotationField = tester.widget<TextFormField>(
        find.descendant(
          of: find.byKey(const ValueKey('place-component-rotation-z')),
          matching: find.byType(TextFormField),
        ),
      );
      expect(rotationField.controller?.text, '90');
      expect(find.textContaining('Компонент выходит'), findsNothing);
      expect(
        find.byKey(const ValueKey('mock-placement-candidate-preview')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('place-component-confirm')));
      await _pumpAsyncUi(tester);

      expect(find.text('custom_button_board_v1_placement_2'), findsWidgets);
      expect(find.text('36 x 0 x 4 mm'), findsOneWidget);

      final inspectorRotationField = tester.widget<TextFormField>(
        find.byKey(
          const ValueKey(
            'component-placement-param-custom_button_board_v1_placement_2-rotationZ',
          ),
        ),
      );
      expect(inspectorRotationField.controller?.text, '90');
    },
  );

  testWidgets('place component rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final placeButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.placeComponent}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(placeButton);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mock-placement-candidate-preview')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('place-component-cancel')));
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsNothing);
    expect(
      find.byKey(const ValueKey('mock-placement-candidate-preview')),
      findsNothing,
    );
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets(
    'selected component placement inspector edits position through undo',
    (tester) async {
      await tester.pumpWidget(const CaseMakerApp());
      await tester.pumpAndSettle();

      final undoButton = find.byKey(
        const ValueKey('toolbar-command-${CommandIds.undo}'),
      );

      await tester.tap(find.text('button_board_placement').first);
      await tester.pumpAndSettle();

      final xField = find.byKey(
        const ValueKey('component-placement-param-button_board_placement-x'),
      );
      final rotationField = find.byKey(
        const ValueKey(
          'component-placement-param-button_board_placement-rotationZ',
        ),
      );

      await tester.enterText(rotationField, '90');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _pumpAsyncUi(tester);

      expect(
        tester.widget<TextFormField>(rotationField).controller?.text,
        '90',
      );
      expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

      await tester.tap(undoButton);
      await _pumpAsyncUi(tester);

      expect(tester.widget<TextFormField>(rotationField).controller?.text, '0');

      await tester.enterText(xField, '80');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _pumpAsyncUi(tester);

      expect(tester.widget<TextFormField>(xField).controller?.text, '80');
      expect(
        find.text('Компонент выходит за внутренний объём корпуса.'),
        findsOneWidget,
      );
      expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

      await tester.tap(undoButton);
      await _pumpAsyncUi(tester);

      expect(tester.widget<TextFormField>(xField).controller?.text, '0');
      expect(
        find.text('Компонент выходит за внутренний объём корпуса.'),
        findsNothing,
      );
    },
  );

  testWidgets('locked component placement disables placement fields', (
    tester,
  ) async {
    final initial = ProjectModel.initial();
    final project = initial.replaceComponentPlacement(
      const ComponentPlacement(
        id: 'button_board_placement',
        templateId: 'custom_button_board_v1',
        position: [0.0, 0.0, 4.0],
        rotation: [0.0, 0.0, 0.0],
        mountingSide: 'bottom_inside',
        locked: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();

    final xField = find.byKey(
      const ValueKey('component-placement-param-button_board_placement-x'),
    );
    final lockedField = find.byKey(
      const ValueKey('component-placement-param-button_board_placement-locked'),
    );

    expect(tester.widget<TextFormField>(xField).enabled, isFalse);
    expect(find.text('Размещение зафиксировано.'), findsOneWidget);

    await tester.ensureVisible(lockedField);
    await tester.pump();
    await tester.tap(lockedField);
    await _pumpAsyncUi(tester);

    expect(tester.widget<TextFormField>(xField).enabled, isTrue);
    expect(find.text('Размещение зафиксировано.'), findsNothing);
  });

  testWidgets(
    'component placement visibility toggle hides viewport hit target',
    (tester) async {
      await tester.pumpWidget(const CaseMakerApp());
      await tester.pumpAndSettle();

      final undoButton = find.byKey(
        const ValueKey('toolbar-command-${CommandIds.undo}'),
      );

      await tester.tap(find.text('button_board_placement').first);
      await tester.pumpAndSettle();

      final xField = find.byKey(
        const ValueKey('component-placement-param-button_board_placement-x'),
      );
      final visibleField = find.byKey(
        const ValueKey(
          'component-placement-param-button_board_placement-visible',
        ),
      );
      expect(tester.widget<CheckboxListTile>(visibleField).value, isTrue);

      await tester.ensureVisible(visibleField);
      await tester.pump();
      await tester.tap(visibleField);
      await _pumpAsyncUi(tester);

      expect(tester.widget<CheckboxListTile>(visibleField).value, isFalse);
      expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);
      expect(
        find.byKey(const ValueKey('mock-workplane-overlay-active')),
        findsNothing,
      );

      await tester.tap(find.text('main_enclosure').first);
      await tester.pumpAndSettle();
      expect(xField, findsNothing);

      final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
      final canvasTopLeft = tester.getTopLeft(canvasFinder);
      final canvasSize = tester.getSize(canvasFinder);
      final layout = MockViewportLayout.fromSize(
        canvasSize,
        const ViewportState(),
      );
      const placementPreview = MockViewportComponentPlacementPreview(
        semanticId: 'button_board_placement',
        width: 48,
        depth: 32,
        referenceWidth: 120,
        referenceDepth: 70,
      );

      await tester.tapAt(
        canvasTopLeft + layout.componentPlacementRect(placementPreview).center,
      );
      await tester.pumpAndSettle();

      expect(xField, findsNothing);

      await tester.tap(undoButton);
      await _pumpAsyncUi(tester);
      await tester.tapAt(
        canvasTopLeft + layout.componentPlacementRect(placementPreview).center,
      );
      await tester.pumpAndSettle();

      expect(xField, findsOneWidget);
    },
  );

  testWidgets('place component command is disabled without templates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial().copyWith(
            componentTemplates: const [],
            componentPlacements: const [],
          ),
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final placeButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.placeComponent}'),
    );

    expect(tester.widget<IconButton>(placeButton).onPressed, isNull);
  });

  testWidgets('add USB-C rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final addUsbCButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.addUsbC}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(addUsbCButton).onPressed, isNull);

    await tester.tap(find.text('Front wall').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(addUsbCButton).onPressed, isNotNull);

    await tester.tap(addUsbCButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('usb-c-confirm')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('usb-c-width')), '12');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('usb-c-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsWidgets);
    expect(find.text('12.0'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdUsbC = MockViewportFeaturePreview(
      semanticId: 'usb_c_cutout_2',
      kind: MockViewportFeatureKind.usbC,
      targetSurfaceId: 'main_enclosure.front_wall.outer',
      width: 12,
      height: 4.2,
      cornerRadius: 1,
      slotIndex: 1,
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdUsbC).center);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsOneWidget);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsNothing);
  });

  testWidgets('add USB-C rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final addUsbCButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.addUsbC}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Front wall').first);
    await tester.pumpAndSettle();
    await tester.tap(addUsbCButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('usb-c-cancel')));
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('component USB-C rail command creates sourced cutout', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final saveFile = File('component_usb.enclosure.json');
    final dialog = _FakeProjectFileDialogService(saveFile: saveFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final addUsbCButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.addUsbC}'),
    );

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(addUsbCButton).onPressed, isNotNull);

    await tester.tap(addUsbCButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('usb-c-confirm')), findsOneWidget);
    expect(_dialogNumberText(tester, 'usb-c-width'), '10.5');
    expect(_dialogNumberText(tester, 'usb-c-height'), '4.2');

    await tester.tap(find.byKey(const ValueKey('usb-c-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final saved = await fileService.readProject(saveFile);
    final created = saved.features.singleWhere(
      (feature) => feature.id == 'usb_c_cutout_2',
    );

    expect(created.targetSurface, 'main_enclosure.front_wall.outer');
    expect(created.parameters['width'], 10.5);
    expect(created.parameters['height'], 4.2);
    expect(created.source?['componentPlacementId'], 'button_board_placement');
    expect(created.source?['componentTemplateId'], 'custom_button_board_v1');
    expect(created.source?['componentFeatureId'], 'usb_c');
    expect(
      created.placement?['projectionMode'],
      'component_feature_surface_projection',
    );
    expect(created.placement?['componentFeatureDirection'], 'front');
    expect(created.placement?['componentFeaturePosition'], [0.0, -16.0, 0.0]);
    expect(created.placement?['rotatedOffset'], [0.0, -16.0, 0.0]);
    expect(created.placement?['worldPosition'], [0.0, -16.0, 4.0]);
    expect(created.placement?['surfacePosition'], [0.0, 4.0]);
    expect(created.placement?['surfaceAxes'], ['x', 'z']);
  });

  testWidgets('button group rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final buttonGroupButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createButtonGroup}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(buttonGroupButton).onPressed, isNull);

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(buttonGroupButton).onPressed, isNotNull);

    await tester.tap(buttonGroupButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('button-group-confirm')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('button-group-count')),
      '6',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('button-group-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('button_group_1'), findsWidgets);
    expect(find.text('6'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    const modeFieldKey = ValueKey('feature-group-param-button_group_1-mode');
    expect(find.byKey(modeFieldKey, skipOffstage: false), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdButtonGroup = MockViewportFeatureGroupPreview(
      semanticId: 'button_group_1',
      kind: MockViewportFeatureGroupKind.buttonGroup,
      sourcePositions: [Offset(14, 0)],
      referenceWidth: 120,
      referenceHeight: 70,
      itemDiameter: 8,
    );

    await tester.tapAt(
      canvasTopLeft + layout.featureGroupCenters(createdButtonGroup).first,
    );
    await tester.pumpAndSettle();

    final modeField = find.byKey(modeFieldKey, skipOffstage: false);
    await tester.ensureVisible(modeField);
    await tester.pump();

    expect(modeField, findsOneWidget);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('button_group_1'), findsNothing);
  });

  testWidgets('button group rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final buttonGroupButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createButtonGroup}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await tester.tap(buttonGroupButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('button-group-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('button_group_1'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('component button command creates switch-sourced group', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final saveFile = File('component_buttons.enclosure.json');
    final dialog = _FakeProjectFileDialogService(saveFile: saveFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final buttonGroupButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createButtonGroup}'),
    );

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(buttonGroupButton).onPressed, isNotNull);

    await tester.tap(buttonGroupButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('button-group-confirm')), findsOneWidget);
    expect(_dialogNumberText(tester, 'button-group-count'), '4');
    expect(_dialogNumberText(tester, 'button-group-diameter'), '8');
    expect(_dialogNumberText(tester, 'button-group-ring-width'), '1.2');
    expect(_dialogNumberText(tester, 'button-group-ring-protrusion'), '0.45');
    expect(_dialogNumberText(tester, 'button-group-cap-diameter'), '7.4');
    expect(_dialogNumberText(tester, 'button-group-cap-height'), '1.2');
    expect(_dialogNumberText(tester, 'button-group-stem-diameter'), '3');
    expect(_dialogNumberText(tester, 'button-group-stem-depth'), '2.8');
    expect(_dialogNumberText(tester, 'button-group-travel'), '0.8');
    expect(_dialogNumberText(tester, 'button-group-switch-clearance'), '0.3');
    expect(_dialogNumberText(tester, 'button-group-guide-clearance'), '0.25');

    await tester.tap(find.byKey(const ValueKey('button-group-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('button_group_1'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final saved = await fileService.readProject(saveFile);
    final created = saved.featureGroups.singleWhere(
      (group) => group.id == 'button_group_1',
    );
    final switchPositions = created.pattern['switchPositions'] as List<Object?>;

    expect(created.targetSurface, 'main_enclosure.top_lid.outer');
    expect(created.pattern['layout'], 'from_component_switches');
    expect(created.pattern['count'], 4);
    expect(created.pattern['sourcePlacementId'], 'button_board_placement');
    expect(created.pattern['sourceTemplateId'], 'custom_button_board_v1');
    expect(created.itemPrototype['ringWidth'], 1.2);
    expect(created.itemPrototype['ringProtrusion'], 0.45);
    expect(created.itemPrototype['capDiameter'], 7.4);
    expect(created.itemPrototype['capHeight'], 1.2);
    expect(created.itemPrototype['stemDiameter'], 3.0);
    expect(created.itemPrototype['stemDepth'], 2.8);
    expect(created.itemPrototype['travel'], 0.8);
    expect(created.itemPrototype['switchClearance'], 0.3);
    expect(created.itemPrototype['guideClearance'], 0.25);
    expect(switchPositions, hasLength(4));
    expect(
      switchPositions
          .whereType<Map<Object?, Object?>>()
          .map((entry) => entry['id'])
          .toList(),
      ['sw_a', 'sw_b', 'sw_x', 'sw_y'],
    );
    expect(
      switchPositions.whereType<Map<Object?, Object?>>().first['position'],
      [7.0, 0.0],
    );
    expect(
      switchPositions
          .whereType<Map<Object?, Object?>>()
          .first['componentFeaturePosition'],
      [7.0, 0.0, 0.0],
    );
    expect(
      switchPositions.whereType<Map<Object?, Object?>>().first['worldPosition'],
      [7.0, 0.0, 4.0],
    );
    expect(
      switchPositions.whereType<Map<Object?, Object?>>().first['surfaceAxes'],
      ['x', 'y'],
    );
    expect(created.placement['anchor'], 'component_switch_centers');
  });

  testWidgets('glass recess rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final glassButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createGlassRecess}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(glassButton).onPressed, isNull);

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(glassButton).onPressed, isNotNull);

    await tester.tap(glassButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('glass-recess-confirm')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('glass-recess-width')),
      '50',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('glass-recess-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('glass_recess_1'), findsWidgets);
    expect(find.text('50.0'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('ledgeWidth'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdGlass = MockViewportFeaturePreview(
      semanticId: 'glass_recess_1',
      kind: MockViewportFeatureKind.glassRecess,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 50,
      height: 24,
      cornerRadius: 2,
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdGlass).center);
    await tester.pumpAndSettle();

    expect(find.text('ledgeWidth'), findsOneWidget);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('glass_recess_1'), findsNothing);
  });

  testWidgets('glass recess rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final glassButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createGlassRecess}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await tester.tap(glassButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('glass-recess-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('glass_recess_1'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('mount generation rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final mountButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateMount}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(mountButton).onPressed, isNull);

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(mountButton).onPressed, isNotNull);

    await tester.tap(mountButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mount-confirm')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('mount-diameter')), '6');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('mount-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('standoff_mounts_1'), findsWidgets);
    expect(find.text('6.0'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('Отверстие'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const mountGroup = MockViewportFeatureGroupPreview(
      semanticId: 'standoff_mounts_1',
      kind: MockViewportFeatureGroupKind.standoffMounts,
      sourcePositions: [
        Offset(-20, -12),
        Offset(20, -12),
        Offset(-20, 12),
        Offset(20, 12),
      ],
      referenceWidth: 48,
      referenceHeight: 32,
      itemDiameter: 6,
    );

    await tester.tapAt(
      canvasTopLeft + layout.featureGroupCenters(mountGroup).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Отверстие'), findsWidgets);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('standoff_mounts_1'), findsNothing);
  });

  testWidgets('mount generation rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final mountButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateMount}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('button_board_placement').first);
    await tester.pumpAndSettle();
    await tester.tap(mountButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mount-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('standoff_mounts_1'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('circular cutout rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final generateSlotButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateSlot}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(generateSlotButton).onPressed, isNull);

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(generateSlotButton).onPressed, isNotNull);

    await tester.tap(generateSlotButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('circular-cutout-confirm')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('circular-cutout-diameter')),
      '14',
    );
    await tester.enterText(
      find.byKey(const ValueKey('circular-cutout-position-x')),
      '8',
    );
    await tester.enterText(
      find.byKey(const ValueKey('circular-cutout-position-y')),
      '-6',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('circular-cutout-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('circular_cutout_1'), findsWidgets);
    expect(find.text('14.0'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('diameter'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdHole = MockViewportFeaturePreview(
      semanticId: 'circular_cutout_1',
      kind: MockViewportFeatureKind.circularCutout,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 14,
      height: 14,
      cornerRadius: 7,
      position: Offset(8, -6),
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdHole).center);
    await tester.pumpAndSettle();

    expect(find.text('diameter'), findsOneWidget);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('circular_cutout_1'), findsNothing);
  });

  testWidgets('circular cutout rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final generateSlotButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateSlot}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await tester.tap(generateSlotButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('circular-cutout-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('circular_cutout_1'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('rectangular cutout rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final generateSlotButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateSlot}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await tester.tap(generateSlotButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cutout-shape')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Прямоугольное').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('rectangular-cutout-width')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-width')),
      '24',
    );
    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-height')),
      '12',
    );
    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-position-x')),
      '-18',
    );
    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-position-y')),
      '10',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('circular-cutout-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('rectangular_cutout_1'), findsWidgets);
    expect(find.text('24.0'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsNothing);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdSlot = MockViewportFeaturePreview(
      semanticId: 'rectangular_cutout_1',
      kind: MockViewportFeatureKind.rectangularCutout,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 24,
      height: 12,
      cornerRadius: 2,
      position: Offset(-18, 10),
    );

    await tester.tapAt(canvasTopLeft + layout.featureRect(createdSlot).center);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsOneWidget);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('rectangular_cutout_1'), findsNothing);
  });

  testWidgets('slot cutout preset creates pill-shaped semantic rectangle', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _FakeProjectFileDialogService(saveFile: File('slot_case'));

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final generateSlotButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateSlot}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Top lid').first);
    await tester.pumpAndSettle();
    await tester.tap(generateSlotButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cutout-shape')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Слот').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('slot-cutout-derived-radius')),
      findsOneWidget,
    );
    expect(_dialogNumberText(tester, 'rectangular-cutout-width'), '24');
    expect(_dialogNumberText(tester, 'rectangular-cutout-height'), '8');

    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-width')),
      '32',
    );
    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-height')),
      '8',
    );
    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-position-x')),
      '12',
    );
    await tester.enterText(
      find.byKey(const ValueKey('rectangular-cutout-position-y')),
      '-4',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('circular-cutout-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('rectangular_cutout_1'), findsWidgets);
    expect(find.text('Слот'), findsWidgets);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    final layout = MockViewportLayout.fromSize(
      canvasSize,
      const ViewportState(),
    );
    const createdSlot = MockViewportFeaturePreview(
      semanticId: 'rectangular_cutout_1',
      kind: MockViewportFeatureKind.rectangularCutout,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 32,
      height: 8,
      cornerRadius: 4,
      position: Offset(12, -4),
    );

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();
    await tester.tapAt(canvasTopLeft + layout.featureRect(createdSlot).center);
    await tester.pumpAndSettle();

    expect(find.text('Слот'), findsWidgets);
    expect(find.text('cornerRadius'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final savedProject = await fileService.readProject(
      File('slot_case.enclosure.json'),
    );
    final savedSlot = savedProject.features.firstWhere(
      (feature) => feature.id == 'rectangular_cutout_1',
    );

    expect(savedSlot.type, 'rectangular_cutout');
    expect(savedSlot.parameters['preset'], 'slot');
    expect(savedSlot.parameters['width'], 32.0);
    expect(savedSlot.parameters['height'], 8.0);
    expect(savedSlot.parameters['cornerRadius'], 4.0);
    expect(savedSlot.parameters['positionX'], 12.0);
    expect(savedSlot.parameters['positionY'], -4.0);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('rectangular_cutout_1'), findsNothing);
  });

  testWidgets('slot inspector keeps derived corner radius after edits', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _FakeProjectFileDialogService(
      saveFile: File('edited_slot_case'),
    );
    final project = ProjectModel.initial().replaceFeature(
      const SemanticFeature(
        id: 'rectangular_cutout_1',
        type: 'rectangular_cutout',
        targetSurface: 'main_enclosure.top_lid.outer',
        operation: 'negative',
        parameters: {
          'width': 32.0,
          'height': 8.0,
          'depth': 3.0,
          'cornerRadius': 4.0,
          'positionX': 12.0,
          'positionY': -4.0,
          'preset': 'slot',
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: project,
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );
    final slotRow = find.text('rectangular_cutout_1', skipOffstage: false);
    await tester.ensureVisible(slotRow);
    await tester.pump();
    await tester.tap(slotRow.first);
    await tester.pumpAndSettle();

    final widthField = find.byKey(
      const ValueKey('feature-param-rectangular_cutout_1-width'),
    );
    final heightField = find.byKey(
      const ValueKey('feature-param-rectangular_cutout_1-height'),
    );

    expect(find.text('Слот'), findsWidgets);
    expect(widthField, findsOneWidget);
    expect(heightField, findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('feature-param-rectangular_cutout_1-cornerRadius'),
      ),
      findsNothing,
    );

    await tester.enterText(widthField, '48');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpAsyncUi(tester);

    await tester.enterText(heightField, '12');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpAsyncUi(tester);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    var savedProject = await fileService.readProject(
      File('edited_slot_case.enclosure.json'),
    );
    var savedSlot = savedProject.features.firstWhere(
      (feature) => feature.id == 'rectangular_cutout_1',
    );

    expect(savedSlot.parameters['preset'], 'slot');
    expect(savedSlot.parameters['width'], 48.0);
    expect(savedSlot.parameters['height'], 12.0);
    expect(savedSlot.parameters['cornerRadius'], 6.0);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);
    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    savedProject = await fileService.readProject(
      File('edited_slot_case.enclosure.json'),
    );
    savedSlot = savedProject.features.firstWhere(
      (feature) => feature.id == 'rectangular_cutout_1',
    );

    expect(savedSlot.parameters['height'], 8.0);
    expect(savedSlot.parameters['cornerRadius'], 4.0);
  });

  testWidgets('unimplemented rail commands are visible but disabled', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final generateCaseButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateCase}'),
    );

    expect(generateCaseButton, findsOneWidget);
    expect(tester.widget<IconButton>(generateCaseButton).onPressed, isNull);
  });

  testWidgets('advanced sketch command creates semantic helper feature', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final saveFile = File('advanced_sketch_case.enclosure.json');
    final dialog = _FakeProjectFileDialogService(saveFile: saveFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggle = find.byKey(const ValueKey('advanced-mode-toggle'));
    final sketchButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.advancedSketch}'),
    );

    expect(toggle, findsOneWidget);
    expect(sketchButton, findsNothing);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(sketchButton, findsOneWidget);
    expect(tester.widget<IconButton>(sketchButton).onPressed, isNotNull);

    await tester.tap(find.text('Front wall').first);
    await tester.pumpAndSettle();

    await tester.tap(sketchButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('advanced-sketch-confirm')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('advanced-sketch-name')),
      'Front helper sketch',
    );
    await tester.tap(find.byKey(const ValueKey('advanced-sketch-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('Front helper sketch'), findsWidgets);
    expect(find.text('advanced_sketch_1'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final saved = await fileService.readProject(saveFile);
    final sketch = saved.features.singleWhere(
      (feature) => feature.id == 'advanced_sketch_1',
    );

    expect(sketch.type, 'advanced_sketch');
    expect(sketch.operation, 'helper');
    expect(sketch.targetSurface, 'main_enclosure.front_wall.outer');
    expect(sketch.parameters['name'], 'Front helper sketch');
    expect(sketch.parameters['entityCount'], 0);
    expect(sketch.metadata['advanced'], isTrue);
    expect(sketch.metadata['entities'], isEmpty);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('advanced_sketch_1'), findsNothing);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(sketchButton, findsNothing);
  });

  testWidgets('save command writes current semantic project file', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _FakeProjectFileDialogService(saveFile: File('edited_case'));

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpAsyncUi(tester);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final savedFile = File('edited_case.enclosure.json');
    final savedProject = await fileService.readProject(savedFile);

    expect(fileService.hasFile(savedFile), isTrue);
    expect(savedProject.bodies.single.size, [150, 70, 28]);
    expect(dialog.saveCount, 1);
    expect(find.textContaining('Сохранено:'), findsOneWidget);
  });

  testWidgets('save picker opens without pre-picker status rebuild', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _BlockingProjectFileDialogService();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.saveProject}'),
    );

    await tester.tap(saveButton);
    await tester.pump();

    expect(dialog.saveCount, 1);
    expect(find.textContaining('Сохранение проекта'), findsNothing);

    await tester.tap(saveButton);
    await tester.pump();

    expect(dialog.saveCount, 1);

    dialog.completeSave(File('stable_case'));
    await _pumpAsyncUi(tester);

    expect(fileService.hasFile(File('stable_case.enclosure.json')), isTrue);
    expect(find.textContaining('Сохранено:'), findsOneWidget);
  });

  testWidgets('export command writes STEP artifact through geometry service', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _FakeProjectFileDialogService(
      exportStepFile: File('exported_case'),
    );
    final geometryService = _ExportGeometryService();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: geometryService,
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.exportProject}')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('export-format-step')));
    await _pumpAsyncUi(tester);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(dialog.exportStepCount, 1);
    expect(geometryService.exportCount, 1);
    expect(
      geometryService.lastExportRequest?.operation,
      GeometryOperation.exportStep,
    );
    expect(
      geometryService.lastExportRequest?.options['outputPath'],
      'exported_case.step',
    );
    expect(fileService.hasFile(File('exported_case.enclosure.json')), isFalse);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(find.textContaining('STEP экспортирован:'), findsOneWidget);
  });

  testWidgets('export command writes STL artifact through geometry service', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _FakeProjectFileDialogService(
      exportStlFile: File('print_case'),
    );
    final geometryService = _ExportGeometryService();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: geometryService,
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.exportProject}')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('export-format-step')), findsOneWidget);
    expect(find.byKey(const ValueKey('export-format-stl')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('export-format-stl')));
    await _pumpAsyncUi(tester);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(dialog.exportStlCount, 1);
    expect(dialog.lastExportStlSuggestedName, 'sample_button_board_case.stl');
    expect(geometryService.exportCount, 1);
    expect(
      geometryService.lastExportRequest?.operation,
      GeometryOperation.exportStl,
    );
    expect(
      geometryService.lastExportRequest?.options['outputPath'],
      'print_case.stl',
    );
    expect(fileService.hasFile(File('print_case.enclosure.json')), isFalse);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(find.textContaining('STL экспортирован:'), findsOneWidget);
  });

  testWidgets('export picker opens without pre-picker status rebuild', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _BlockingProjectFileDialogService();
    final geometryService = _ExportGeometryService();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: geometryService,
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final exportButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.exportProject}'),
    );

    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    expect(dialog.exportStepCount, 0);
    expect(find.byKey(const ValueKey('export-format-step')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('export-format-step')));
    await tester.pump();

    expect(dialog.exportStepCount, 1);
    expect(find.textContaining('Экспорт STEP'), findsNothing);

    await tester.tap(exportButton);
    await tester.pump();

    expect(dialog.exportStepCount, 1);

    dialog.completeExportStep(File('stable_case_export'));
    await _pumpAsyncUi(tester);

    expect(geometryService.exportCount, 1);
    expect(
      geometryService.lastExportRequest?.options['outputPath'],
      'stable_case_export.step',
    );
    expect(
      fileService.hasFile(File('stable_case_export.enclosure.json')),
      isFalse,
    );
    expect(find.textContaining('STEP экспортирован:'), findsOneWidget);
  });

  testWidgets('export format chooser can be cancelled before file picker', (
    tester,
  ) async {
    final dialog = _FakeProjectFileDialogService(
      exportStepFile: File('unused_step'),
      exportStlFile: File('unused_stl'),
    );
    final geometryService = _ExportGeometryService();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: geometryService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.exportProject}')),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(dialog.exportStepCount, 0);
    expect(dialog.exportStlCount, 0);
    expect(geometryService.exportCount, 0);
    expect(find.textContaining('Экспорт отменён'), findsOneWidget);
  });

  testWidgets('open command loads semantic project file and resets undo', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final openFile = File('opened.enclosure.json');
    final openedProject = ProjectModel.initial().replaceEnclosure(
      ProjectModel.initial().bodies.single.copyWith(size: const [160, 80, 32]),
    );
    fileService.seed(openFile, openedProject);
    final dialog = _FakeProjectFileDialogService(openFile: openFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.openProject}')),
    );
    await _pumpAsyncUi(tester);

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(find.text('160 x 80 x 32 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(dialog.openCount, 1);
    expect(find.textContaining('Открыто:'), findsOneWidget);
  });

  testWidgets(
    'open command can be cancelled when project has unsaved changes',
    (tester) async {
      final fileService = _MemoryProjectFileService();
      final openFile = File('opened.enclosure.json');
      fileService.seed(
        openFile,
        ProjectModel.initial().replaceEnclosure(
          ProjectModel.initial().bodies.single.copyWith(
            size: const [160, 80, 32],
          ),
        ),
      );
      final dialog = _FakeProjectFileDialogService(openFile: openFile);

      await tester.pumpWidget(
        MaterialApp(
          home: WorkspaceShell(
            project: ProjectModel.initial(),
            geometryService: const MockGeometryService(),
            projectFileService: fileService,
            projectFileDialogService: dialog,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('main_enclosure').first);
      await _pumpAsyncUi(tester);
      await tester.enterText(
        find.byKey(const ValueKey('enclosure-param-width')),
        '150',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _pumpAsyncUi(tester);

      await tester.tap(
        find.byKey(const ValueKey('toolbar-command-${CommandIds.openProject}')),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('discard-unsaved-cancel')),
        findsOneWidget,
      );
      expect(dialog.openCount, 0);

      await tester.tap(find.byKey(const ValueKey('discard-unsaved-cancel')));
      await _pumpAsyncUi(tester);

      expect(dialog.openCount, 0);
      expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
      expect(
        find.textContaining('Есть несохранённые изменения'),
        findsOneWidget,
      );
    },
  );

  testWidgets('open command can discard unsaved changes after confirmation', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final openFile = File('opened.enclosure.json');
    fileService.seed(
      openFile,
      ProjectModel.initial().replaceEnclosure(
        ProjectModel.initial().bodies.single.copyWith(
          size: const [160, 80, 32],
        ),
      ),
    );
    final dialog = _FakeProjectFileDialogService(openFile: openFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpAsyncUi(tester);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.openProject}')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('discard-unsaved-confirm')));
    await _pumpAsyncUi(tester);
    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(dialog.openCount, 1);
    expect(find.text('160 x 80 x 32 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(find.textContaining('Открыто:'), findsOneWidget);
  });
}

Future<void> _pumpAsyncUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

Future<void> _tapTopLidSnap(WidgetTester tester, Offset localPosition) async {
  await _tapTopLidWorkplane(tester, localPosition);
}

Future<void> _tapTopLidWorkplane(
  WidgetTester tester,
  Offset localPosition,
) async {
  await _tapTopLidWorkplaneWithButtons(
    tester,
    localPosition,
    kPrimaryMouseButton,
  );
}

Future<void> _secondaryTapTopLidWorkplane(
  WidgetTester tester,
  Offset localPosition,
) async {
  await _tapTopLidWorkplaneWithButtons(
    tester,
    localPosition,
    kSecondaryMouseButton,
  );
}

Future<void> _tapTopLidWorkplaneWithButtons(
  WidgetTester tester,
  Offset localPosition,
  int buttons,
) async {
  final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
  final canvasTopLeft = tester.getTopLeft(canvasFinder);
  final canvasSize = tester.getSize(canvasFinder);
  final layout = MockViewportLayout.fromSize(canvasSize, const ViewportState());
  const workplane = MockViewportWorkplaneOverlay(
    semanticId: 'main_enclosure.top_lid.outer',
    kind: MockViewportWorkplaneKind.topLid,
    width: 120,
    height: 70,
    snapPoints: [
      Offset.zero,
      Offset(30, 0),
      Offset(-30, 0),
      Offset(0, 17.5),
      Offset(0, -17.5),
    ],
  );

  await tester.tapAt(
    canvasTopLeft + layout.workplaneLocalToCanvas(workplane, localPosition),
    buttons: buttons,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapFrontWallWorkplane(
  WidgetTester tester,
  Offset localPosition,
) async {
  final canvasFinder = find.byKey(const ValueKey('mock-viewport-canvas'));
  final canvasTopLeft = tester.getTopLeft(canvasFinder);
  final canvasSize = tester.getSize(canvasFinder);
  final layout = MockViewportLayout.fromSize(canvasSize, const ViewportState());
  const workplane = MockViewportWorkplaneOverlay(
    semanticId: 'main_enclosure.front_wall.outer',
    kind: MockViewportWorkplaneKind.frontWall,
    width: 120,
    height: 28,
    snapPoints: [
      Offset.zero,
      Offset(30, 0),
      Offset(-30, 0),
      Offset(0, 7),
      Offset(0, -7),
    ],
  );

  await tester.tapAt(
    canvasTopLeft + layout.workplaneLocalToCanvas(workplane, localPosition),
  );
  await tester.pumpAndSettle();
}

String _dialogNumberText(WidgetTester tester, String key) {
  final field = tester.widget<TextFormField>(
    find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextFormField),
    ),
  );
  return field.controller?.text ?? field.initialValue ?? '';
}

String _textFormFieldText(WidgetTester tester, String key) {
  final field = tester.widget<TextFormField>(find.byKey(ValueKey(key)));
  return field.controller?.text ?? field.initialValue ?? '';
}

class _FakeProjectFileDialogService implements ProjectFileDialogService {
  _FakeProjectFileDialogService({
    this.openFile,
    this.saveFile,
    this.exportStepFile,
    this.exportStlFile,
  });

  final File? openFile;
  final File? saveFile;
  final File? exportStepFile;
  final File? exportStlFile;
  int openCount = 0;
  int saveCount = 0;
  int exportStepCount = 0;
  int exportStlCount = 0;
  String? lastSuggestedName;
  String? lastExportStepSuggestedName;
  String? lastExportStlSuggestedName;

  @override
  Future<File?> pickOpenProjectFile() async {
    openCount += 1;
    return openFile;
  }

  @override
  Future<File?> pickSaveProjectFile({required String suggestedName}) async {
    saveCount += 1;
    lastSuggestedName = suggestedName;
    return saveFile;
  }

  @override
  Future<File?> pickExportFile({
    required ProjectExportFormat format,
    required String suggestedName,
  }) async {
    switch (format) {
      case ProjectExportFormat.step:
        exportStepCount += 1;
        lastExportStepSuggestedName = suggestedName;
        return exportStepFile;
      case ProjectExportFormat.stl:
        exportStlCount += 1;
        lastExportStlSuggestedName = suggestedName;
        return exportStlFile;
    }
  }
}

class _BlockingProjectFileDialogService implements ProjectFileDialogService {
  final Completer<File?> _saveCompleter = Completer<File?>();
  final Completer<File?> _exportStepCompleter = Completer<File?>();
  final Completer<File?> _exportStlCompleter = Completer<File?>();
  int saveCount = 0;
  int exportStepCount = 0;
  int exportStlCount = 0;

  void completeSave(File? file) {
    _saveCompleter.complete(file);
  }

  void completeExportStep(File? file) {
    _exportStepCompleter.complete(file);
  }

  @override
  Future<File?> pickOpenProjectFile() async {
    return null;
  }

  @override
  Future<File?> pickSaveProjectFile({required String suggestedName}) async {
    saveCount += 1;
    return _saveCompleter.future;
  }

  @override
  Future<File?> pickExportFile({
    required ProjectExportFormat format,
    required String suggestedName,
  }) async {
    switch (format) {
      case ProjectExportFormat.step:
        exportStepCount += 1;
        return _exportStepCompleter.future;
      case ProjectExportFormat.stl:
        exportStlCount += 1;
        return _exportStlCompleter.future;
    }
  }
}

class _MemoryProjectFileService extends ProjectFileService {
  final Map<String, String> _files = {};

  void seed(File file, ProjectModel project) {
    _files[file.path] = encode(project);
  }

  bool hasFile(File file) {
    return _files.containsKey(file.path);
  }

  @override
  Future<void> writeProject(File file, ProjectModel project) async {
    _files[file.path] = encode(project);
  }

  @override
  Future<ProjectModel> readProject(File file) async {
    final source = _files[file.path];
    if (source == null) {
      throw FileSystemException('File not found.', file.path);
    }

    return decode(source);
  }
}

class _ExportGeometryService extends MockGeometryService {
  int exportCount = 0;
  GeometryRequest? lastExportRequest;

  @override
  Future<GeometryResponse> buildGeometry(GeometryRequest request) async {
    if (request.operation != GeometryOperation.exportStep &&
        request.operation != GeometryOperation.exportStl) {
      return super.buildGeometry(request);
    }

    exportCount += 1;
    lastExportRequest = request;
    final outputPath = request.options['outputPath'] as String? ?? '';
    final artifactType = switch (request.operation) {
      GeometryOperation.exportStep => 'step',
      GeometryOperation.exportStl => 'stl',
      _ => 'artifact',
    };
    final formatLabel = artifactType.toUpperCase();

    return GeometryResponse(
      requestId: request.requestId,
      status: GeometryResponseStatus.ok,
      backend: 'fake_${artifactType}_export',
      artifacts: [
        GeometryArtifact(
          type: artifactType,
          path: outputPath,
          metadata: {
            'format': formatLabel,
            'source': 'occt_brep',
            'units': 'mm',
          },
        ),
      ],
      metrics: {
        'requestedOperation': request.operation.wireName,
        'editableGeneratedGeometry': false,
      },
    );
  }
}

class _PreviewMeshGeometryService extends MockGeometryService {
  const _PreviewMeshGeometryService();

  @override
  Future<GeometryPreview> generatePreview(ProjectModel project) async {
    return GeometryPreview(
      backendLabel: 'fake_worker_preview',
      projectName: project.projectName,
      surfaces: await getSelectableSurfaces(project),
      previewMesh: const PreviewMesh(
        units: 'mm',
        vertices: [-10, -10, 0, 10, -10, 0, 0, 10, 0, 0, 0, 12],
        triangles: [0, 1, 2, 0, 3, 1, 1, 3, 2, 2, 3, 0],
        bounds: GeometryBounds(min: [-10, -10, 0], max: [10, 10, 12]),
        surfaces: [
          PreviewSurfaceMapping(
            semanticId: 'main_enclosure.top_lid.outer',
            label: 'Top lid',
            triangleRanges: [PreviewTriangleRange(start: 0, count: 1)],
          ),
          PreviewSurfaceMapping(
            semanticId: 'front_usb_c',
            label: 'USB-C cutout',
            triangleRanges: [PreviewTriangleRange(start: 1, count: 2)],
          ),
          PreviewSurfaceMapping(
            semanticId: 'button_group_1',
            label: 'Button group',
            triangleRanges: [PreviewTriangleRange(start: 3, count: 1)],
          ),
          PreviewSurfaceMapping(
            semanticId: 'standoff_mounts_1',
            label: 'Standoff mounts',
            triangleRanges: [PreviewTriangleRange(start: 2, count: 1)],
          ),
        ],
      ),
      stats: const {
        'source': 'fake_worker_preview',
        'previewVertices': 4,
        'previewTriangles': 4,
      },
    );
  }
}

class _MappedFeaturePreviewMeshService extends MockGeometryService {
  const _MappedFeaturePreviewMeshService();

  @override
  Future<GeometryPreview> generatePreview(ProjectModel project) async {
    return GeometryPreview(
      backendLabel: 'fake_worker_preview',
      projectName: project.projectName,
      surfaces: await getSelectableSurfaces(project),
      previewMesh: const PreviewMesh(
        units: 'mm',
        vertices: [-10, -10, 0, 10, -10, 0, 0, 10, 0, 0, 0, 12],
        triangles: [0, 1, 2, 0, 3, 1, 1, 3, 2, 2, 3, 0],
        bounds: GeometryBounds(min: [-10, -10, 0], max: [10, 10, 12]),
        metadata: {'source': 'occt_brep'},
        surfaces: [
          PreviewSurfaceMapping(
            semanticId: 'front_usb_c',
            label: 'USB-C cutout',
            triangleRanges: [PreviewTriangleRange(start: 0, count: 1)],
          ),
          PreviewSurfaceMapping(
            semanticId: 'button_group_1',
            label: 'Button group',
            triangleRanges: [PreviewTriangleRange(start: 1, count: 1)],
          ),
        ],
      ),
      stats: const {
        'source': 'fake_worker_preview',
        'previewVertices': 4,
        'previewTriangles': 4,
      },
    );
  }
}

class _SingleFeaturePreviewMeshService extends MockGeometryService {
  const _SingleFeaturePreviewMeshService();

  @override
  Future<GeometryPreview> generatePreview(ProjectModel project) async {
    return GeometryPreview(
      backendLabel: 'fake_worker_preview',
      projectName: project.projectName,
      surfaces: await getSelectableSurfaces(project),
      previewMesh: const PreviewMesh(
        units: 'mm',
        vertices: [-10, -10, 0, 10, -10, 0, 0, 10, 0],
        triangles: [0, 1, 2],
        bounds: GeometryBounds(min: [-10, -10, 0], max: [10, 10, 0]),
        metadata: {'source': 'occt_brep'},
        surfaces: [
          PreviewSurfaceMapping(
            semanticId: 'front_usb_c',
            label: 'USB-C cutout',
            triangleRanges: [PreviewTriangleRange(start: 0, count: 1)],
          ),
        ],
      ),
      stats: const {
        'source': 'fake_worker_preview',
        'previewVertices': 3,
        'previewTriangles': 1,
      },
    );
  }
}
