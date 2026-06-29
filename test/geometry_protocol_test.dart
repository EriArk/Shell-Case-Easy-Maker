import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('preview mesh request round trips semantic project JSON', () {
    final project = ProjectModel.initial();
    final request = GeometryRequest.previewMesh(
      project,
      requestId: 'preview_001',
      options: const {'linearDeflection': 0.2},
    );
    final decoded = GeometryRequest.fromJson(
      jsonDecode(jsonEncode(request.toJson())) as Map<String, Object?>,
    );

    expect(decoded.schema, GeometryProtocol.requestSchema);
    expect(decoded.version, GeometryProtocol.currentVersion);
    expect(decoded.requestId, 'preview_001');
    expect(decoded.operation, GeometryOperation.previewMesh);
    expect(decoded.project['schema'], ProjectModel.currentSchema);
    expect(decoded.options['linearDeflection'], 0.2);
  });

  test('preview mesh request includes semantic feature intents', () {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'projected_buttons',
        type: 'button_group',
        targetSurface: 'main_enclosure.top_lid.outer',
        pattern: {
          'layout': 'from_component_switches',
          'count': 2,
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
          ],
        },
        itemPrototype: {'type': 'button', 'diameter': 8.0},
        placement: {'anchor': 'component_switch_centers'},
      ),
    );
    final request = GeometryRequest.previewMesh(
      project,
      requestId: 'preview_intents',
    );
    final decoded = GeometryRequest.fromJson(
      jsonDecode(jsonEncode(request.toJson())) as Map<String, Object?>,
    );

    final usbCIntent = decoded.featureIntents.singleWhere(
      (intent) => intent.id == 'front_usb_c',
    );
    final buttonIntent = decoded.featureIntents.singleWhere(
      (intent) => intent.id == 'projected_buttons',
    );

    expect(decoded.featureIntents, hasLength(3));
    expect(usbCIntent.semanticType, 'feature');
    expect(usbCIntent.kind, 'usb_c_cutout');
    expect(usbCIntent.operation, 'negative');
    expect(usbCIntent.parameters['width'], 10.5);
    expect(buttonIntent.semanticType, 'feature_group');
    expect(buttonIntent.kind, 'button_group');
    expect(buttonIntent.operation, 'composite');
    expect(
      buttonIntent.source['componentPlacementId'],
      'button_board_placement',
    );
    expect(buttonIntent.items, hasLength(2));
    expect(buttonIntent.items.first.id, 'projected_buttons.sw_a');
    expect(buttonIntent.items.first.position, [7.0, 0.0]);
    expect(buttonIntent.items.first.parameters['diameter'], 8.0);
    expect(buttonIntent.items.first.source['direction'], 'top');
  });

  test('standoff group intents can expand from component template holes', () {
    final project = ProjectModel.initial().replaceFeatureGroup(
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
    final request = GeometryRequest.previewMesh(
      project,
      requestId: 'preview_standoffs',
    );

    final standoffIntent = request.featureIntents.singleWhere(
      (intent) => intent.id == 'standoff_mounts_1',
    );

    expect(standoffIntent.items, hasLength(4));
    expect(standoffIntent.items.first.id, 'standoff_mounts_1.mh1');
    expect(standoffIntent.items.first.position, [-20.0, -12.0]);
    expect(standoffIntent.items.first.source['screw'], 'M2');
  });

  test('geometry response preserves preview mesh semantic mappings', () {
    const response = GeometryResponse(
      requestId: 'preview_001',
      status: GeometryResponseStatus.ok,
      backend: 'mock',
      previewMesh: PreviewMesh(
        units: 'mm',
        vertices: [0, 0, 0, 10, 0, 0, 0, 10, 0],
        triangles: [0, 1, 2],
        bounds: GeometryBounds(min: [0, 0, 0], max: [10, 10, 0]),
        surfaces: [
          PreviewSurfaceMapping(
            semanticId: 'main_enclosure.top_lid.outer',
            label: 'Top lid',
            triangleRanges: [PreviewTriangleRange(start: 0, count: 1)],
          ),
        ],
      ),
    );

    final encoded = jsonEncode(response.toJson());
    final decoded = GeometryResponse.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );

    expect(decoded.status, GeometryResponseStatus.ok);
    expect(decoded.previewMesh?.vertexCount, 3);
    expect(decoded.previewMesh?.triangleCount, 1);
    expect(
      decoded.previewMesh?.surfaces.single.semanticId,
      'main_enclosure.top_lid.outer',
    );
    expect(encoded, isNot(contains('TopoDS')));
    expect(encoded, isNot(contains('occtFaceId')));
  });

  test('mock geometry service returns deterministic preview mesh', () async {
    const service = MockGeometryService();
    final request = GeometryRequest.previewMesh(
      ProjectModel.initial(),
      requestId: 'mock_preview',
    );

    final response = await service.buildGeometry(request);

    expect(response.status, GeometryResponseStatus.ok);
    expect(response.backend, 'mock');
    expect(response.previewMesh?.vertexCount, 8);
    expect(response.previewMesh?.triangleCount, 12);
    expect(response.metrics['featureIntents'], 2);
    expect(
      response.previewMesh?.surfaces.map((surface) => surface.semanticId),
      contains('main_enclosure.front_wall.outer'),
    );
  });

  test('mock geometry service uses semantic enclosure dimensions', () async {
    const service = MockGeometryService();
    final project = ProjectModel.initial().replaceEnclosure(
      ProjectModel.initial().bodies.single.copyWith(size: const [150, 90, 32]),
    );
    final request = GeometryRequest.previewMesh(
      project,
      requestId: 'mock_preview',
    );

    final response = await service.buildGeometry(request);

    expect(response.previewMesh?.bounds.min, [-75, -45, 0]);
    expect(response.previewMesh?.bounds.max, [75, 45, 32]);
  });

  test('mock geometry service rejects unsupported operations', () async {
    const service = MockGeometryService();
    final request = GeometryRequest(
      requestId: 'step_001',
      operation: GeometryOperation.exportStep,
      project: ProjectModel.initial().toJson(),
    );

    final response = await service.buildGeometry(request);

    expect(response.status, GeometryResponseStatus.error);
    expect(response.hasErrors, isTrue);
    expect(response.issues.single.code, 'mock.unsupported_operation');
  });

  test('mock geometry validation returns semantic warnings', () async {
    const service = MockGeometryService();
    final initial = ProjectModel.initial();
    final project = initial.replaceEnclosure(
      initial.bodies.single.copyWith(wallThickness: 0.4),
    );

    final report = await service.validateGeometry(project);

    expect(report.hasWarnings, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('enclosure.wall.thin'),
    );
  });
}
