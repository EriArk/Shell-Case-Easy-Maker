import '../project/project_model.dart';
import '../validation/project_semantic_validator.dart';
import '../validation/validation_result.dart';
import 'geometry_operation_plan.dart';
import 'geometry_protocol.dart';

export 'geometry_operation_plan.dart';
export 'geometry_protocol.dart';
export 'geometry_worker_process_client.dart';
export 'geometry_worker_protocol.dart';

abstract interface class GeometryService {
  Future<GeometryPreview> generatePreview(ProjectModel project);

  Future<GeometryResponse> buildGeometry(GeometryRequest request);

  Future<ValidationReport> validateGeometry(ProjectModel project);

  Future<List<SelectableSurface>> getSelectableSurfaces(ProjectModel project);
}

class GeometryPreview {
  const GeometryPreview({
    required this.backendLabel,
    required this.projectName,
    required this.surfaces,
    required this.stats,
  });

  final String backendLabel;
  final String projectName;
  final List<SelectableSurface> surfaces;
  final Map<String, Object?> stats;
}

class SelectableSurface {
  const SelectableSurface({required this.id, required this.label});

  final String id;
  final String label;
}

class MockGeometryService implements GeometryService {
  const MockGeometryService();

  @override
  Future<GeometryResponse> buildGeometry(GeometryRequest request) async {
    final project = ProjectModel.fromJson(request.project);

    if (request.operation != GeometryOperation.previewMesh) {
      return GeometryResponse(
        requestId: request.requestId,
        status: GeometryResponseStatus.error,
        backend: 'mock',
        issues: [
          GeometryIssue(
            severity: GeometryIssueSeverity.error,
            code: 'mock.unsupported_operation',
            message: 'Mock backend only supports preview mesh requests.',
          ),
        ],
      );
    }

    final operationPlan = GeometryOperationPlanner.fromRequest(request);

    return GeometryResponse(
      requestId: request.requestId,
      status: GeometryResponseStatus.ok,
      backend: 'mock',
      previewMesh: _samplePreviewMesh(project),
      metrics: {
        'source': 'semantic',
        'deterministic': true,
        'worker': 'mock',
        'featureIntents': request.featureIntents.length,
        'operationCount': operationPlan.length,
        'operationPlan': [
          for (final operation in operationPlan) operation.toJson(),
        ],
      },
    );
  }

  @override
  Future<GeometryPreview> generatePreview(ProjectModel project) async {
    final surfaces = await getSelectableSurfaces(project);
    final response = await buildGeometry(
      GeometryRequest.previewMesh(project, requestId: 'mock_preview'),
    );

    return GeometryPreview(
      backendLabel: 'mock',
      projectName: project.projectName,
      surfaces: surfaces,
      stats: {
        'bodies': project.bodies.length,
        'features': project.features.length,
        'featureGroups': project.featureGroups.length,
        'source': 'semantic',
        'previewVertices': response.previewMesh?.vertexCount ?? 0,
        'previewTriangles': response.previewMesh?.triangleCount ?? 0,
        'featureIntents': response.metrics['featureIntents'] ?? 0,
        'operationCount': response.metrics['operationCount'] ?? 0,
      },
    );
  }

  @override
  Future<List<SelectableSurface>> getSelectableSurfaces(
    ProjectModel project,
  ) async {
    return const [
      SelectableSurface(id: 'main_enclosure.top_lid.outer', label: 'Top lid'),
      SelectableSurface(
        id: 'main_enclosure.front_wall.outer',
        label: 'Front wall',
      ),
      SelectableSurface(
        id: 'main_enclosure.bottom_inside',
        label: 'Bottom inside',
      ),
    ];
  }

  @override
  Future<ValidationReport> validateGeometry(ProjectModel project) async {
    return ProjectSemanticValidator.validate(project);
  }

  PreviewMesh _samplePreviewMesh(ProjectModel project) {
    final body = project.bodies.firstOrNull;
    final width = _sizeAt(body, 0, 120);
    final depth = _sizeAt(body, 1, 70);
    final height = _sizeAt(body, 2, 28);
    final halfWidth = width / 2;
    final halfDepth = depth / 2;

    return PreviewMesh(
      units: 'mm',
      vertices: [
        -halfWidth,
        -halfDepth,
        0,
        halfWidth,
        -halfDepth,
        0,
        halfWidth,
        halfDepth,
        0,
        -halfWidth,
        halfDepth,
        0,
        -halfWidth,
        -halfDepth,
        height,
        halfWidth,
        -halfDepth,
        height,
        halfWidth,
        halfDepth,
        height,
        -halfWidth,
        halfDepth,
        height,
      ],
      triangles: const [
        4,
        5,
        6,
        4,
        6,
        7,
        0,
        2,
        1,
        0,
        3,
        2,
        1,
        5,
        6,
        1,
        6,
        2,
        0,
        7,
        4,
        0,
        3,
        7,
        3,
        6,
        2,
        3,
        7,
        6,
        0,
        1,
        5,
        0,
        5,
        4,
      ],
      bounds: GeometryBounds(
        min: [-halfWidth, -halfDepth, 0],
        max: [halfWidth, halfDepth, height],
      ),
      surfaces: const [
        PreviewSurfaceMapping(
          semanticId: 'main_enclosure.top_lid.outer',
          label: 'Top lid',
          triangleRanges: [PreviewTriangleRange(start: 0, count: 2)],
        ),
        PreviewSurfaceMapping(
          semanticId: 'main_enclosure.bottom_inside',
          label: 'Bottom inside',
          triangleRanges: [PreviewTriangleRange(start: 2, count: 2)],
        ),
        PreviewSurfaceMapping(
          semanticId: 'main_enclosure.front_wall.outer',
          label: 'Front wall',
          triangleRanges: [PreviewTriangleRange(start: 4, count: 2)],
        ),
      ],
    );
  }
}

double _sizeAt(Enclosure? enclosure, int index, double fallback) {
  final size = enclosure?.size;
  return size != null && size.length > index ? size[index] : fallback;
}
