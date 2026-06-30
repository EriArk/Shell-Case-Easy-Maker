import 'dart:convert';
import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

Future<void> main(List<String> args) async {
  final request = GeometryRequest.previewMesh(
    _fixtureProject(),
    requestId: 'preview_sample_001',
  );
  const service = MockGeometryService();
  final response = await service.buildGeometry(request);
  const encoder = JsonEncoder.withIndent('  ');

  await File(
    'occt_worker/protocol/preview_request.example.json',
  ).writeAsString('${encoder.convert(request.toJson())}\n');
  await File(
    'occt_worker/protocol/preview_response.example.json',
  ).writeAsString('${encoder.convert(response.toJson())}\n');

  stdout.writeln('Updated geometry protocol fixtures.');
  stdout.writeln('featureIntents=${request.featureIntents.length}');
  stdout.writeln('operationCount=${response.metrics['operationCount']}');
}

ProjectModel _fixtureProject() {
  return ProjectModel.initial()
      .replaceFeatureGroup(
        const FeatureGroup(
          id: 'projected_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {
            'layout': 'from_component_switches',
            'count': 4,
            'sourcePlacementId': 'button_board_placement',
            'sourceTemplateId': 'custom_button_board_v1',
            'switchPositions': [
              {
                'id': 'sw_a',
                'position': [7.0, 0.0],
                'componentFeaturePosition': [7.0, 0.0, 0.0],
                'surfaceAxes': ['x', 'y'],
                'direction': 'top',
              },
              {
                'id': 'sw_b',
                'position': [0.0, -7.0],
                'componentFeaturePosition': [0.0, -7.0, 0.0],
                'surfaceAxes': ['x', 'y'],
                'direction': 'top',
              },
              {
                'id': 'sw_x',
                'position': [0.0, 7.0],
                'componentFeaturePosition': [0.0, 7.0, 0.0],
                'surfaceAxes': ['x', 'y'],
                'direction': 'top',
              },
              {
                'id': 'sw_y',
                'position': [-7.0, 0.0],
                'componentFeaturePosition': [-7.0, 0.0, 0.0],
                'surfaceAxes': ['x', 'y'],
                'direction': 'top',
              },
            ],
          },
          itemPrototype: {
            'type': 'button',
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
          placement: {'anchor': 'component_switch_centers'},
        ),
      )
      .replaceFeatureGroup(
        const FeatureGroup(
          id: 'standoff_mounts_1',
          type: 'standoff_mounts',
          targetSurface: 'main_enclosure.bottom_inside',
          pattern: {
            'layout': 'from_component_mounting_holes',
            'sourcePlacementId': 'button_board_placement',
            'sourceTemplateId': 'custom_button_board_v1',
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
}
