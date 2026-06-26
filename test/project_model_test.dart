import 'dart:convert';

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
}
