import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('initial project serializes as semantic enclosure data', () {
    final project = ProjectModel.initial();
    final json = project.toJson();

    expect(json['schema'], ProjectModel.currentSchema);
    expect(json['version'], ProjectModel.currentVersion);
    expect(json['units'], 'mm');
    expect(project.bodies.single.id, 'main_enclosure');
    expect(project.componentTemplates.single.id, 'custom_button_board_v1');
    expect(
      project.features.map((feature) => feature.type),
      contains('button_group'),
    );
  });

  test('project model round trips through JSON', () {
    final encoded = ProjectModel.initial().toPrettyJson();
    final decoded = jsonDecode(encoded) as Map<String, Object?>;
    final project = ProjectModel.fromJson(decoded);

    expect(project.projectName, 'Sample Button Board Case');
    expect(project.bodies.single.size, [120, 70, 28]);
    expect(
      project.componentPlacements.single.templateId,
      'custom_button_board_v1',
    );
    expect(project.features.length, 2);
  });

  test('minimal project JSON migrates to current defaults', () {
    final project = ProjectModel.fromJson(const {});

    expect(project.schema, ProjectModel.currentSchema);
    expect(project.version, ProjectModel.currentVersion);
    expect(project.units, 'mm');
    expect(project.projectName, 'Untitled Device');
    expect(project.printerProfile, 'fdm_04_normal');
    expect(project.bodies, isEmpty);
    expect(project.features, isEmpty);
  });

  test('project root metadata survives round trip', () {
    final project = ProjectModel.fromJson(const {
      'projectName': 'Theme Test',
      'theme': 'minimal_dark',
    });

    expect(project.metadata['theme'], 'minimal_dark');
    expect(project.toJson()['theme'], 'minimal_dark');
  });

  test('sample project fixture keeps semantic feature metadata', () {
    final fixture = File('examples/sample_project.enclosure.json');
    final json = jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
    final project = ProjectModel.fromJson(json);
    final feature = project.features.single;
    final encodedFeature = feature.toJson();

    expect(project.bodies.single.lid?.type, 'top_screw_lid');
    expect(feature.id, 'abxy_buttons');
    expect(feature.source?['type'], 'switch_centers');
    expect(feature.placement?['mode'], 'projected_from_component');
    expect(encodedFeature['pattern'], isA<Map<String, Object?>>());
    expect(encodedFeature['button'], isA<Map<String, Object?>>());
  });

  test('component template fixture round trips typed board data', () {
    final fixture = File('examples/component_template_button_board.json');
    final json = jsonDecode(fixture.readAsStringSync()) as Map<String, Object?>;
    final template = ComponentTemplate.fromJson(json);
    final encoded = template.toJson();

    expect(template.schema, ComponentTemplateSchema.name);
    expect(template.id, 'custom_button_board_v1');
    expect(template.board.outline.width, 48);
    expect(template.mountingHoles.length, 4);
    expect(
      template.features.where((feature) => feature.type == 'switch'),
      hasLength(4),
    );
    expect(
      template.zones.map((zone) => zone.type),
      contains('mountable_surface'),
    );
    expect(encoded['features'], isA<List<Object?>>());
    expect(encoded['zones'], isA<List<Object?>>());
  });

  test('project replaces or appends component placements by stable id', () {
    final project = ProjectModel.initial();
    final added = const ComponentPlacement(
      id: 'second_board_placement',
      templateId: 'custom_button_board_v1',
      position: [12, 0, 4],
      rotation: [0, 0, 0],
      mountingSide: 'bottom_inside',
      locked: false,
    );

    final withAdded = project.replaceComponentPlacement(added);
    final replaced = withAdded.replaceComponentPlacement(
      const ComponentPlacement(
        id: 'second_board_placement',
        templateId: 'custom_button_board_v1',
        position: [24, 0, 4],
        rotation: [0, 0, 0],
        mountingSide: 'top_lid_inside',
        locked: true,
      ),
    );

    expect(withAdded.componentPlacements, hasLength(2));
    expect(replaced.componentPlacements, hasLength(2));
    expect(replaced.componentPlacements.last.position, [24, 0, 4]);
    expect(replaced.componentPlacements.last.mountingSide, 'top_lid_inside');
    expect(replaced.componentPlacements.last.locked, isTrue);
  });

  test('project replaces or appends semantic features by stable id', () {
    final project = ProjectModel.initial();
    const added = SemanticFeature(
      id: 'usb_c_cutout_2',
      type: 'usb_c_cutout',
      targetSurface: 'main_enclosure.front_wall.outer',
      operation: 'negative',
      parameters: {'width': 12.0},
    );

    final withAdded = project.replaceFeature(added);
    final replaced = withAdded.replaceFeature(
      const SemanticFeature(
        id: 'usb_c_cutout_2',
        type: 'usb_c_cutout',
        targetSurface: 'main_enclosure.front_wall.outer',
        operation: 'negative',
        parameters: {'width': 14.0},
      ),
    );

    expect(withAdded.features, hasLength(3));
    expect(replaced.features, hasLength(3));
    expect(replaced.features.last.parameters['width'], 14.0);
  });

  test('newer project versions fail explicitly', () {
    expect(
      () => ProjectModel.fromJson(const {
        'schema': ProjectModel.currentSchema,
        'version': ProjectModel.currentVersion + 1,
      }),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
