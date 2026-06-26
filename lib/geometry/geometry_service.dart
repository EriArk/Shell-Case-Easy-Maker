import '../project/project_model.dart';
import '../validation/validation_result.dart';

abstract interface class GeometryService {
  Future<GeometryPreview> generatePreview(ProjectModel project);

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
  Future<GeometryPreview> generatePreview(ProjectModel project) async {
    final surfaces = await getSelectableSurfaces(project);

    return GeometryPreview(
      backendLabel: 'mock',
      projectName: project.projectName,
      surfaces: surfaces,
      stats: const {'bodies': 1, 'features': 2, 'source': 'semantic'},
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
    return const ValidationReport(
      messages: [
        ValidationMessage(
          severity: ValidationSeverity.info,
          code: 'mock.preview',
          message: 'Mock backend returned semantic preview metadata.',
          targetId: 'main_enclosure',
        ),
      ],
    );
  }
}
