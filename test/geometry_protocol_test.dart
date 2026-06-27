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
    expect(
      response.previewMesh?.surfaces.map((surface) => surface.semanticId),
      contains('main_enclosure.front_wall.outer'),
    );
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
}
