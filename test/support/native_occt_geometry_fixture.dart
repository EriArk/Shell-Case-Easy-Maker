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

const nativeOcctRectangularCutoutExpectedPreviewVertexCount = 4510;
const nativeOcctRectangularCutoutExpectedPreviewTriangleCount = 4940;
const nativeOcctRectangularCutoutExpectedSurfaceMappingCount = 10;
const nativeOcctRectangularCutoutExpectedMappedTriangleCount = 7648;
const nativeOcctRectangularCutoutExpectedBoundsMin = [-60.0, -35.0, 0.0];
const nativeOcctRectangularCutoutExpectedBoundsMax = [60.0, 35.0, 30.08];
const nativeOcctRectangularCutoutExpectedDimensions = [120.0, 70.0, 30.08];
const nativeOcctRectangularCutoutExpectedSurfaceArea = 54833.278006;
const nativeOcctRectangularCutoutExpectedVolume = 53202.341646;

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

const nativeOcctRectangularCutoutExpectedSurfaceIds = {
  'main_enclosure.generated_top_lid_seat',
  'main_enclosure.generated_top_lid_locating_lip',
  'main_enclosure.front_wall.outer',
  'front_rect_slot',
  'main_enclosure.lid_screw_bosses',
  'main_enclosure.bottom_inside',
  'main_enclosure.generated_top_lid',
  'main_enclosure.top_lid.outer',
  'main_enclosure.generated_top_lid_screw_holes',
  'top_rect_slot',
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

ProjectModel nativeOcctRectangularCutoutProject() {
  return ProjectModel.initial().copyWith(
    features: const [
      SemanticFeature(
        id: 'front_rect_slot',
        type: 'rectangular_cutout',
        targetSurface: 'main_enclosure.front_wall.outer',
        operation: 'negative',
        parameters: {
          'width': 18.0,
          'height': 8.0,
          'depth': 3.0,
          'cornerRadius': 2.0,
          'positionX': 28.0,
          'positionY': 0.0,
          'clearanceProfile': 'fdm_normal',
        },
      ),
      SemanticFeature(
        id: 'top_rect_slot',
        type: 'rectangular_cutout',
        targetSurface: 'main_enclosure.top_lid.outer',
        operation: 'negative',
        parameters: {
          'width': 22.0,
          'height': 10.0,
          'depth': 3.0,
          'cornerRadius': 2.0,
          'positionX': -28.0,
          'positionY': 0.0,
          'clearanceProfile': 'fdm_normal',
        },
      ),
    ],
    featureGroups: const [],
  );
}

ProjectModel nativeOcctSketchProfileCutProject() {
  final sketch = advancedSketchWithEntities(
    const SemanticFeature(
      id: 'advanced_sketch_1',
      type: advancedSketchFeatureType,
      targetSurface: 'main_enclosure.top_lid.outer',
      operation: 'helper',
      source: {'type': 'advanced_mode'},
      placement: {'mode': 'surface_workplane', 'anchor': 'center'},
      parameters: {'name': 'Lid sketch', 'plane': 'surface'},
      metadata: {'advanced': true},
    ),
    [
      defaultSketchRectangleEntity(id: 'reference_rect'),
      sketchEntityWithProfileIntent(
        const SketchEntity(
          id: 'lid_round_cut',
          type: 'circle',
          parameters: {
            'center': [-24.0, 0.0],
            'diameter': 8.0,
          },
        ),
        sketchProfileIntentCut,
      ),
      sketchEntityWithProfileIntent(
        const SketchEntity(
          id: 'lid_rect_cut',
          type: 'rectangle',
          parameters: {
            'center': [24.0, 0.0],
            'width': 18.0,
            'height': 8.0,
            'cornerRadius': 2.0,
            'rotation': 0.0,
          },
        ),
        sketchProfileIntentCut,
      ),
      sketchEntityWithProfileIntent(
        const SketchEntity(
          id: 'future_add',
          type: 'circle',
          parameters: {
            'center': [0.0, 18.0],
            'diameter': 6.0,
          },
        ),
        sketchProfileIntentAdd,
      ),
    ],
  );

  return ProjectModel.initial().copyWith(
    features: [sketch],
    featureGroups: const [],
  );
}

ProjectModel nativeOcctSwitchSourcedButtonProject() {
  final initial = ProjectModel.initial();

  return initial.copyWith(
    features: [
      initial.features.singleWhere((feature) => feature.id == 'front_usb_c'),
    ],
    featureGroups: const [
      FeatureGroup(
        id: 'component_switch_buttons',
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
              'rotatedOffset': [7.0, 0.0, 0.0],
              'worldPosition': [7.0, 0.0, 4.0],
              'surfaceAxes': ['x', 'y'],
              'direction': 'top',
            },
            {
              'id': 'sw_b',
              'position': [0.0, -7.0],
              'componentFeaturePosition': [0.0, -7.0, 0.0],
              'rotatedOffset': [0.0, -7.0, 0.0],
              'worldPosition': [0.0, -7.0, 4.0],
              'surfaceAxes': ['x', 'y'],
              'direction': 'top',
            },
            {
              'id': 'sw_x',
              'position': [0.0, 7.0],
              'componentFeaturePosition': [0.0, 7.0, 0.0],
              'rotatedOffset': [0.0, 7.0, 0.0],
              'worldPosition': [0.0, 7.0, 4.0],
              'surfaceAxes': ['x', 'y'],
              'direction': 'top',
            },
            {
              'id': 'sw_y',
              'position': [-7.0, 0.0],
              'componentFeaturePosition': [-7.0, 0.0, 0.0],
              'rotatedOffset': [-7.0, 0.0, 0.0],
              'worldPosition': [-7.0, 0.0, 4.0],
              'surfaceAxes': ['x', 'y'],
              'direction': 'top',
            },
          ],
        },
        itemPrototype: {
          'type': 'button',
          'shape': 'circle',
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
        placement: {
          'anchor': 'component_switch_centers',
          'componentPlacementId': 'button_board_placement',
          'componentPosition': [0.0, 0.0, 4.0],
          'componentRotation': [0.0, 0.0, 0.0],
        },
      ),
    ],
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
