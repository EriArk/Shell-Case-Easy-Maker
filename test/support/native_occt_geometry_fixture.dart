import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

const nativeOcctExpectedPreviewVertexCount = 13550;
const nativeOcctExpectedPreviewTriangleCount = 13776;
const nativeOcctExpectedSurfaceMappingCount = 16;
const nativeOcctExpectedMappedTriangleCount = 20478;
const nativeOcctExpectedBoundsMin = [-60.0, -36.65, 0.0];
const nativeOcctExpectedBoundsMax = [60.0, 35.0, 31.73];
const nativeOcctExpectedDimensions = [120.0, 71.65, 31.73];
const nativeOcctExpectedSurfaceArea = 56226.302206;
const nativeOcctExpectedVolume = 53188.934617;
const nativeOcctExpectedFitPreviewGap = 0.08;

const nativeOcctExpectedSurfaceIds = {
  'main_enclosure.top_lid.outer',
  'main_enclosure.front_wall.outer',
  'main_enclosure.bottom_inside',
  'main_enclosure.lid_screw_bosses',
  'main_enclosure.generated_top_lid',
  'main_enclosure.generated_top_lid_seat',
  'main_enclosure.generated_top_lid_locating_lip',
  'main_enclosure.generated_top_lid_screw_holes',
  'top_lid_buttons',
  'top_lid_glass_recess',
  'top_lid_round_hole',
  'front_usb_c',
  'front_glass_recess',
  'front_round_hole',
  'front_buttons',
  'standoff_mounts_1',
};

String nativeOcctExecutablePath(
  String repoRoot, {
  String configuration = 'Release',
}) {
  return [
    repoRoot,
    'build',
    'occt_worker_native_occt',
    configuration,
    'occt_worker_native_occt.exe',
  ].join(Platform.pathSeparator);
}

GeometryWorkerProcessClient nativeOcctWorkerClient(
  String repoRoot, {
  String configuration = 'Release',
}) {
  return GeometryWorkerProcessClient(
    command: GeometryWorkerProcessCommand(
      executable: nativeOcctExecutablePath(
        repoRoot,
        configuration: configuration,
      ),
      workingDirectory: repoRoot,
      runInShell: Platform.isWindows,
    ),
    timeout: const Duration(seconds: 60),
  );
}

ProjectModel nativeOcctRegressionProject() {
  return ProjectModel.initial()
      .replaceFeature(
        const SemanticFeature(
          id: 'front_glass_recess',
          type: 'glass_recess',
          targetSurface: 'main_enclosure.front_wall.outer',
          operation: 'recess',
          parameters: {
            'width': 24.0,
            'height': 10.0,
            'recessDepth': 1.0,
            'ledgeWidth': 1.5,
            'cornerRadius': 2.0,
            'insertThickness': 1.0,
            'clearanceProfile': 'fdm_normal',
          },
          placement: {
            'surfacePosition': [28.0, 16.0],
          },
        ),
      )
      .replaceFeature(
        const SemanticFeature(
          id: 'top_lid_glass_recess',
          type: 'glass_recess',
          targetSurface: 'main_enclosure.top_lid.outer',
          operation: 'recess',
          parameters: {
            'width': 20.0,
            'height': 12.0,
            'recessDepth': 0.6,
            'ledgeWidth': 1.0,
            'cornerRadius': 2.0,
            'insertThickness': 1.0,
            'clearanceProfile': 'fdm_normal',
          },
          placement: {
            'surfacePosition': [36.0, 0.0],
          },
        ),
      )
      .replaceFeature(
        const SemanticFeature(
          id: 'front_round_hole',
          type: 'circular_cutout',
          targetSurface: 'main_enclosure.front_wall.outer',
          operation: 'negative',
          parameters: {
            'diameter': 7.0,
            'depth': 3.0,
            'positionX': -36.0,
            'positionY': 0.0,
            'clearanceProfile': 'fdm_normal',
          },
        ),
      )
      .replaceFeature(
        const SemanticFeature(
          id: 'top_lid_round_hole',
          type: 'circular_cutout',
          targetSurface: 'main_enclosure.top_lid.outer',
          operation: 'negative',
          parameters: {
            'diameter': 8.0,
            'depth': 3.0,
            'positionX': -36.0,
            'positionY': 0.0,
            'clearanceProfile': 'fdm_normal',
          },
        ),
      )
      .replaceFeatureGroup(
        const FeatureGroup(
          id: 'front_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.front_wall.outer',
          pattern: {'layout': 'row', 'count': 2, 'spacing': 16.0},
          itemPrototype: {
            'type': 'button',
            'shape': 'circle',
            'diameter': 6.0,
            'ringWidth': 1.2,
            'ringProtrusion': 0.45,
            'capDiameter': 5.0,
            'capHeight': 1.2,
            'stemDiameter': 2.8,
            'stemDepth': 2.8,
            'travel': 0.8,
            'switchClearance': 0.3,
            'guideClearance': 0.25,
            'mode': 'plunger',
          },
          placement: {'anchor': 'center'},
        ),
      )
      .replaceFeatureGroup(
        const FeatureGroup(
          id: 'top_lid_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          pattern: {'layout': 'diamond', 'count': 4, 'spacing': 14.0},
          itemPrototype: {
            'type': 'button',
            'shape': 'circle',
            'diameter': 6.0,
            'ringWidth': 1.2,
            'ringProtrusion': 0.45,
            'capDiameter': 5.0,
            'capHeight': 1.2,
            'stemDiameter': 2.8,
            'stemDepth': 2.8,
            'travel': 0.8,
            'switchClearance': 0.3,
            'guideClearance': 0.25,
            'mode': 'plunger',
          },
          placement: {'anchor': 'center'},
        ),
      )
      .replaceFeatureGroup(
        const FeatureGroup(
          id: 'standoff_mounts_1',
          type: 'standoff_mounts',
          targetSurface: 'main_enclosure.bottom_inside',
          pattern: {
            'layout': 'from_component_mounting_holes',
            'count': 4,
            'sourcePlacementId': 'button_board_placement',
            'sourceTemplateId': 'custom_button_board_v1',
            'holePositions': [
              {
                'id': 'mh1',
                'position': [-20.0, -12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
              {
                'id': 'mh2',
                'position': [20.0, -12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
              {
                'id': 'mh3',
                'position': [-20.0, 12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
              {
                'id': 'mh4',
                'position': [20.0, 12.0],
                'diameter': 2.2,
                'screw': 'M2',
              },
            ],
          },
          itemPrototype: {
            'type': 'standoff',
            'diameter': 5.0,
            'holeDiameter': 2.2,
            'height': 4.0,
            'screw': 'M2',
            'clearanceProfile': 'fdm_normal',
          },
          placement: {
            'anchor': 'component_mounting_holes',
            'componentPlacementId': 'button_board_placement',
            'mountingSide': 'bottom_inside',
          },
        ),
      );
}

int nativeOcctMappedTriangleCount(PreviewMesh mesh) {
  return mesh.surfaces
      .expand((surface) => surface.triangleRanges)
      .fold<int>(0, (sum, range) => sum + range.count);
}

bool nativeOcctTriangleRangesAreValid(PreviewMesh mesh) {
  return mesh.surfaces.every(
    (surface) =>
        surface.triangleRanges.isNotEmpty &&
        surface.triangleRanges.every(
          (range) =>
              range.start >= 0 &&
              range.count > 0 &&
              range.start + range.count <= mesh.triangleCount,
        ),
  );
}

List<double> nativeOcctReadDoubleList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value.whereType<num>().map((item) => item.toDouble()).toList();
}

Map<String, Object?> nativeOcctReadMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is! Map<Object?, Object?>) {
    return const {};
  }

  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

double? nativeOcctReadNumber(Object? value) {
  return value is num ? value.toDouble() : null;
}
