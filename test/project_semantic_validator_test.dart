import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';
import 'package:shell_case_easy_maker/validation/project_semantic_validator.dart';
import 'package:shell_case_easy_maker/validation/validation_result.dart';

void main() {
  test('initial project passes semantic validation', () {
    final report = ProjectSemanticValidator.validate(ProjectModel.initial());

    expect(report.hasErrors, isFalse);
    expect(report.hasWarnings, isFalse);
    expect(report.messages.single.code, 'semantic.ok');
  });

  test('thin enclosure wall reports a warning', () {
    final initial = ProjectModel.initial();
    final project = initial.replaceEnclosure(
      initial.bodies.single.copyWith(wallThickness: 0.4),
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isFalse);
    expect(report.hasWarnings, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('enclosure.wall.thin'),
    );
  });

  test('oversized USB-C and glass recess report semantic errors', () {
    final initial = ProjectModel.initial();
    final project = initial
        .replaceFeature(
          const SemanticFeature(
            id: 'bad_usb_c',
            type: 'usb_c_cutout',
            targetSurface: 'main_enclosure.front_wall.outer',
            operation: 'negative',
            parameters: {'width': 200.0, 'height': 4.2, 'cornerRadius': 1.0},
          ),
        )
        .replaceFeature(
          const SemanticFeature(
            id: 'bad_glass',
            type: 'glass_recess',
            targetSurface: 'main_enclosure.top_lid.outer',
            operation: 'recess',
            parameters: {
              'width': 200.0,
              'height': 100.0,
              'recessDepth': 1.2,
              'ledgeWidth': 1.5,
              'cornerRadius': 2.0,
            },
          ),
        );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      containsAll([
        'feature.usb_c.width.too_large',
        'feature.glass_recess.size.too_large',
      ]),
    );
  });

  test('unsafe standoff hole diameter reports an error', () {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'standoff_mounts_1',
        type: 'standoff_mounts',
        targetSurface: 'main_enclosure.bottom_inside',
        pattern: {
          'holePositions': [
            {
              'position': [0.0, 0.0],
            },
          ],
        },
        itemPrototype: {'diameter': 5.0, 'holeDiameter': 4.5, 'height': 4.0},
      ),
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(report.primaryIssue?.severity, ValidationSeverity.error);
    expect(
      report.messages.map((message) => message.code),
      contains('group.standoff_mounts.hole.too_large'),
    );
  });

  test('component placement outside enclosure reports an error', () {
    final project = ProjectModel.initial().replaceComponentPlacement(
      const ComponentPlacement(
        id: 'button_board_placement',
        templateId: 'custom_button_board_v1',
        position: [80.0, 0.0, 4.0],
        rotation: [0.0, 0.0, 0.0],
        mountingSide: 'bottom_inside',
        locked: false,
      ),
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('component.placement.outside_enclosure'),
    );
  });

  test('component placement bounds account for z rotation', () {
    const template = ComponentTemplate(
      id: 'wide_board',
      name: 'Wide Board',
      board: ComponentBoard(
        outline: BoardOutline(type: 'rectangle', width: 64.0, height: 10.0),
        thickness: 1.6,
        referencePlane: 'bottom',
      ),
    );
    const unrotatedPlacement = ComponentPlacement(
      id: 'wide_board_placement',
      templateId: 'wide_board',
      position: [35.0, 0.0, 4.0],
      rotation: [0.0, 0.0, 0.0],
      mountingSide: 'bottom_inside',
      locked: false,
    );
    final project = ProjectModel.initial().copyWith(
      componentTemplates: const [template],
      componentPlacements: const [unrotatedPlacement],
      features: const [],
    );

    final unrotatedReport = ProjectSemanticValidator.validate(project);
    final rotatedReport = ProjectSemanticValidator.validate(
      project.replaceComponentPlacement(
        const ComponentPlacement(
          id: 'wide_board_placement',
          templateId: 'wide_board',
          position: [35.0, 0.0, 4.0],
          rotation: [0.0, 0.0, 90.0],
          mountingSide: 'bottom_inside',
          locked: false,
        ),
      ),
    );

    expect(
      unrotatedReport.messages.map((message) => message.code),
      contains('component.placement.outside_enclosure'),
    );
    expect(rotatedReport.hasErrors, isFalse);
    expect(rotatedReport.hasWarnings, isFalse);
  });

  test('missing component template reports an error', () {
    final project = ProjectModel.initial().copyWith(
      componentTemplates: const [],
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('component.placement.template.missing'),
    );
  });

  test('component keepout outside enclosure reports a warning', () {
    final project = ProjectModel.initial().replaceComponentPlacement(
      const ComponentPlacement(
        id: 'button_board_placement',
        templateId: 'custom_button_board_v1',
        position: [0.0, -12.0, 4.0],
        rotation: [0.0, 0.0, 0.0],
        mountingSide: 'bottom_inside',
        locked: false,
      ),
    );

    final report = ProjectSemanticValidator.validate(project);
    final codes = report.messages.map((message) => message.code);

    expect(report.hasErrors, isFalse);
    expect(report.hasWarnings, isTrue);
    expect(codes, contains('component.feature.keepout.outside_enclosure'));
    expect(codes, isNot(contains('component.placement.outside_enclosure')));
  });

  test('projected USB-C anchor outside target surface reports an error', () {
    final project = ProjectModel.initial().copyWith(
      features: const [
        SemanticFeature(
          id: 'projected_usb_c',
          type: 'usb_c_cutout',
          targetSurface: 'main_enclosure.front_wall.outer',
          operation: 'negative',
          source: {
            'componentPlacementId': 'button_board_placement',
            'componentTemplateId': 'custom_button_board_v1',
            'componentFeatureId': 'usb_c',
          },
          placement: {
            'projectionMode': 'component_feature_surface_projection',
            'surfacePosition': [80.0, 4.0],
            'surfaceAxes': ['x', 'z'],
          },
          parameters: {'width': 10.5, 'height': 4.2, 'cornerRadius': 1.0},
        ),
      ],
      featureGroups: const [],
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('feature.projected_anchor.outside_surface'),
    );
  });

  test('projected button group anchor outside lid reports an error', () {
    final project = ProjectModel.initial().copyWith(
      features: const [],
      featureGroups: const [
        FeatureGroup(
          id: 'projected_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {
            'layout': 'from_component_switches',
            'count': 1,
            'sourcePlacementId': 'button_board_placement',
            'sourceTemplateId': 'custom_button_board_v1',
            'switchPositions': [
              {
                'id': 'sw_far',
                'position': [70.0, 0.0],
                'surfaceAxes': ['x', 'y'],
                'componentFeaturePosition': [70.0, 0.0, 0.0],
              },
            ],
          },
          itemPrototype: {'diameter': 8.0},
        ),
      ],
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('group.projected_anchor.outside_surface'),
    );
  });

  test('projected button cap diameter is included in surface fit', () {
    final project = ProjectModel.initial().copyWith(
      features: const [],
      featureGroups: const [
        FeatureGroup(
          id: 'projected_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {
            'layout': 'from_component_switches',
            'count': 1,
            'sourcePlacementId': 'button_board_placement',
            'sourceTemplateId': 'custom_button_board_v1',
            'switchPositions': [
              {
                'id': 'sw_near_edge',
                'position': [50.0, 0.0],
                'surfaceAxes': ['x', 'y'],
                'componentFeaturePosition': [50.0, 0.0, 0.0],
              },
            ],
          },
          itemPrototype: {
            'diameter': 2.0,
            'ringWidth': 0.2,
            'capDiameter': 20.0,
          },
        ),
      ],
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('group.projected_anchor.outside_surface'),
    );
  });

  test('button plunger travel and guide fit are validated', () {
    final project = ProjectModel.initial().copyWith(
      features: const [],
      featureGroups: const [
        FeatureGroup(
          id: 'bad_plunger',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {'layout': 'diamond', 'count': 1, 'spacing': 14.0},
          itemPrototype: {
            'diameter': 8.0,
            'stemDiameter': 7.8,
            'stemDepth': 1.0,
            'travel': 0.8,
            'switchClearance': 0.3,
            'guideClearance': 0.2,
            'mode': 'plunger',
          },
        ),
      ],
    );

    final report = ProjectSemanticValidator.validate(project);
    final codes = report.messages.map((message) => message.code);

    expect(report.hasErrors, isTrue);
    expect(codes, contains('group.button_plunger.travel.too_deep'));
    expect(codes, contains('group.button_plunger.guide.too_wide'));
  });

  test('button plunger negative guide clearance is an error', () {
    final project = ProjectModel.initial().copyWith(
      features: const [],
      featureGroups: const [
        FeatureGroup(
          id: 'invalid_guide_plunger',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {'layout': 'diamond', 'count': 1, 'spacing': 14.0},
          itemPrototype: {
            'diameter': 8.0,
            'stemDiameter': 3.0,
            'stemDepth': 2.8,
            'travel': 0.8,
            'switchClearance': 0.3,
            'guideClearance': -0.1,
            'mode': 'plunger',
          },
        ),
      ],
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('group.button_plunger.guide_clearance.invalid'),
    );
  });

  test('button plunger guide clearance warnings keep cutout mode quiet', () {
    final plungerProject = ProjectModel.initial().copyWith(
      features: const [],
      featureGroups: const [
        FeatureGroup(
          id: 'tight_plunger',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {'layout': 'diamond', 'count': 1, 'spacing': 14.0},
          itemPrototype: {
            'diameter': 8.0,
            'stemDiameter': 3.0,
            'stemDepth': 2.8,
            'travel': 0.8,
            'switchClearance': 0.3,
            'guideClearance': 0.05,
            'mode': 'plunger',
          },
        ),
      ],
    );
    final cutoutProject = plungerProject.replaceFeatureGroup(
      const FeatureGroup(
        id: 'tight_plunger',
        type: 'button_group',
        targetSurface: 'main_enclosure.top_lid.outer',
        pattern: {'layout': 'diamond', 'count': 1, 'spacing': 14.0},
        itemPrototype: {
          'diameter': 8.0,
          'stemDiameter': 3.0,
          'stemDepth': 2.8,
          'travel': 0.8,
          'switchClearance': 0.3,
          'guideClearance': 0.05,
          'mode': 'cutout',
        },
      ),
    );

    final plungerReport = ProjectSemanticValidator.validate(plungerProject);
    final cutoutReport = ProjectSemanticValidator.validate(cutoutProject);

    expect(plungerReport.hasErrors, isFalse);
    expect(plungerReport.hasWarnings, isTrue);
    expect(
      plungerReport.messages.map((message) => message.code),
      contains('group.button_plunger.guide_clearance.tight'),
    );
    expect(cutoutReport.hasErrors, isFalse);
    expect(cutoutReport.hasWarnings, isFalse);
  });

  test('projected feature with missing source reports a warning', () {
    final project = ProjectModel.initial().copyWith(
      componentPlacements: const [],
      features: const [
        SemanticFeature(
          id: 'orphan_projected_usb_c',
          type: 'usb_c_cutout',
          targetSurface: 'main_enclosure.front_wall.outer',
          operation: 'negative',
          source: {
            'componentPlacementId': 'missing_placement',
            'componentTemplateId': 'custom_button_board_v1',
            'componentFeatureId': 'usb_c',
          },
          placement: {
            'projectionMode': 'component_feature_surface_projection',
            'surfacePosition': [0.0, 4.0],
            'surfaceAxes': ['x', 'z'],
          },
          parameters: {'width': 10.5, 'height': 4.2, 'cornerRadius': 1.0},
        ),
      ],
      featureGroups: const [],
    );

    final report = ProjectSemanticValidator.validate(project);

    expect(report.hasErrors, isFalse);
    expect(report.hasWarnings, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('feature.projected_anchor.source.missing'),
    );
  });
}
