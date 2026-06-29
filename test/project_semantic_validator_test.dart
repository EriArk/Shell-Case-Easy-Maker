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
}
