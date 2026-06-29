import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/component_features/component_feature_projection.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('projects front connector anchors to surface x and z axes', () {
    final project = ProjectModel.initial();
    final placement = project.componentPlacements.single;
    final template = project.componentTemplates.single;
    final feature = template.features.singleWhere(
      (feature) => feature.id == 'usb_c',
    );

    final projection = ComponentFeatureSurfaceProjector.projectFeature(
      project: project,
      placement: placement,
      feature: feature,
    );

    expect(projection, isNotNull);
    expect(projection!.targetSurfaceId, 'main_enclosure.front_wall.outer');
    expect(projection.direction, 'front');
    expect(projection.componentFeaturePosition, [0.0, -16.0, 0.0]);
    expect(projection.rotatedOffset, [0.0, -16.0, 0.0]);
    expect(projection.worldPosition, [0.0, -16.0, 4.0]);
    expect(projection.surfaceAxes, ['x', 'z']);
    expect(projection.surfacePosition, [0.0, 4.0]);
  });

  test('projects switch centers with component rotation', () {
    final project = ProjectModel.initial();
    final template = project.componentTemplates.single;
    const placement = ComponentPlacement(
      id: 'rotated_button_board',
      templateId: 'custom_button_board_v1',
      position: [10.0, -5.0, 4.0],
      rotation: [0.0, 0.0, 90.0],
      mountingSide: 'bottom_inside',
      locked: false,
    );
    final feature = template.features.singleWhere(
      (feature) => feature.id == 'sw_a',
    );

    final projection = ComponentFeatureSurfaceProjector.projectFeature(
      project: project,
      placement: placement,
      feature: feature,
    );

    expect(projection, isNotNull);
    expect(projection!.targetSurfaceId, 'main_enclosure.top_lid.outer');
    expect(projection.componentFeaturePosition, [7.0, 0.0, 0.0]);
    expect(projection.rotatedOffset, [0.0, 7.0, 0.0]);
    expect(projection.worldPosition, [10.0, 2.0, 4.0]);
    expect(projection.surfaceAxes, ['x', 'y']);
    expect(projection.surfacePosition, [10.0, 2.0]);
  });

  test('ignores feature directions without known enclosure surface', () {
    final project = ProjectModel.initial();
    final placement = project.componentPlacements.single;
    const feature = ComponentFeature(
      id: 'antenna_keepout',
      type: 'keepout',
      position: [0.0, 0.0],
      direction: 'diagonal',
    );

    expect(
      ComponentFeatureSurfaceProjector.projectFeature(
        project: project,
        placement: placement,
        feature: feature,
      ),
      isNull,
    );
  });
}
