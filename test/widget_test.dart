import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/app/case_maker_app.dart';
import 'package:shell_case_easy_maker/commands/command_ids.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
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

      expect(find.text('14.0'), findsOneWidget);
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

      expect(find.text('60.0'), findsOneWidget);
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
      sourcePositions: [
        Offset(14, 0),
        Offset(0, -14),
        Offset(0, 14),
        Offset(-14, 0),
      ],
      referenceWidth: 120,
      referenceHeight: 70,
      itemDiameter: 8,
    );

    await tester.tapAt(
      canvasTopLeft + layout.featureGroupCenters(buttonGroup).first,
    );
    await tester.pumpAndSettle();

    final countField = find.byKey(
      const ValueKey('feature-group-param-button_group_1-count'),
    );

    await tester.enterText(countField, '6');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(tester.widget<TextFormField>(countField).controller?.text, '6');
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(tester.widget<TextFormField>(countField).controller?.text, '4');
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
    expect(find.text('12.0'), findsOneWidget);
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

    expect(find.text('Тип кнопки'), findsNothing);

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

    expect(find.text('Тип кнопки'), findsOneWidget);

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
    expect(find.text('50.0'), findsOneWidget);
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
    expect(find.text('6.0'), findsOneWidget);
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

  testWidgets('unimplemented rail commands are visible but disabled', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final generateSlotButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateSlot}'),
    );

    expect(generateSlotButton, findsOneWidget);
    expect(tester.widget<IconButton>(generateSlotButton).onPressed, isNull);
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
  );
  await tester.pumpAndSettle();
}

class _FakeProjectFileDialogService implements ProjectFileDialogService {
  _FakeProjectFileDialogService({this.openFile, this.saveFile});

  final File? openFile;
  final File? saveFile;
  int openCount = 0;
  int saveCount = 0;
  String? lastSuggestedName;

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
}

class _BlockingProjectFileDialogService implements ProjectFileDialogService {
  final Completer<File?> _saveCompleter = Completer<File?>();
  int saveCount = 0;

  void completeSave(File? file) {
    _saveCompleter.complete(file);
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
