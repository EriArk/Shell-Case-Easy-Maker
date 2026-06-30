import 'dart:convert';
import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

Future<void> main(List<String> args) async {
  final options = _SmokeOptions.fromArgs(args);
  final repoRoot = Directory.current.absolute.path;

  if (!options.skipBuild) {
    final buildResult = await _buildNativeOcct(repoRoot, options.configuration);
    if (buildResult.exitCode != 0) {
      stderr.writeln(buildResult.stdout);
      stderr.writeln(buildResult.stderr);
      stderr.writeln('Native OCCT worker build failed.');
      exitCode = buildResult.exitCode;
      return;
    }
  }

  final executable = _nativeOcctExecutablePath(repoRoot, options.configuration);
  if (!File(executable).existsSync()) {
    stderr.writeln('Native OCCT worker executable not found: $executable');
    stderr.writeln(
      'Run tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall or omit --skip-build.',
    );
    exitCode = 2;
    return;
  }

  final client = GeometryWorkerProcessClient(
    command: GeometryWorkerProcessCommand(
      executable: executable,
      workingDirectory: repoRoot,
      runInShell: Platform.isWindows,
    ),
  );
  final capabilities = await client.queryCapabilities();
  const smokeRequestId = 'native_occt_preview_smoke';
  final response = await client.buildGeometry(
    GeometryRequest.previewMesh(
      _nativeSmokeProject(),
      requestId: smokeRequestId,
    ),
  );

  final failures = <String>[];
  _expect(!capabilities.hasErrors, 'capabilities must be valid', failures);
  _expect(
    capabilities.capabilities?.activeBackend == 'native',
    'active backend must be native',
    failures,
  );
  final nativeBackend = capabilities.capabilities?.backends
      .where((backend) => backend.id == 'native')
      .firstOrNull;
  _expect(
    nativeBackend != null,
    'native backend capability must exist',
    failures,
  );
  _expect(
    nativeBackend?.status == 'preview_mesh_smoke',
    'native backend status must be preview_mesh_smoke',
    failures,
  );
  _expect(
    nativeBackend?.supportedOperations.contains(
          GeometryOperation.previewMesh,
        ) ??
        false,
    'native backend must support preview_mesh',
    failures,
  );

  _expect(
    response.requestId == smokeRequestId,
    'requestId must be preserved',
    failures,
  );
  _expect(!response.hasErrors, 'preview_mesh response must be ok', failures);
  _expect(
    response.backend == 'occt_worker_native_occt',
    'response backend must be occt_worker_native_occt',
    failures,
  );
  final previewMesh = response.previewMesh;
  _expect(
    previewMesh != null,
    'preview_mesh response must emit previewMesh',
    failures,
  );
  if (previewMesh != null) {
    _expect(
      previewMesh.units == 'mm',
      'previewMesh units must be mm',
      failures,
    );
    _expect(
      previewMesh.vertexCount == 11254,
      'previewMesh must contain the deterministic sample vertex count',
      failures,
    );
    _expect(
      previewMesh.triangleCount == 11816,
      'previewMesh must contain the deterministic sample triangle count',
      failures,
    );
    _expect(
      previewMesh.vertices.length == previewMesh.vertexCount * 3,
      'previewMesh vertices must be xyz triplets',
      failures,
    );
    _expect(
      previewMesh.triangles.length == previewMesh.triangleCount * 3,
      'previewMesh triangles must be index triplets',
      failures,
    );
    _expect(
      previewMesh.triangles.every(
        (index) => index >= 0 && index < previewMesh.vertexCount,
      ),
      'previewMesh triangle indices must reference emitted vertices',
      failures,
    );
    _expect(
      previewMesh.surfaces.length == 14,
      'previewMesh must expose body surfaces plus generated lid, body lid seat, locating lip, lid screw holes, top-lid glass, top-lid buttons, lid bosses, USB-C, glass, front button, and standoff feature mappings',
      failures,
    );
    final surfaceIds = previewMesh.surfaces
        .map((surface) => surface.semanticId)
        .toSet();
    _expect(
      surfaceIds.contains('main_enclosure.top_lid.outer'),
      'previewMesh surfaces must include the semantic top lid',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.front_wall.outer'),
      'previewMesh surfaces must include the semantic front wall',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.bottom_inside'),
      'previewMesh surfaces must include the semantic bottom inside surface',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.lid_screw_bosses'),
      'previewMesh surfaces must include the generated lid screw boss range',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.generated_top_lid'),
      'previewMesh surfaces must include the generated top lid plate range',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.generated_top_lid_seat'),
      'previewMesh surfaces must include the generated top lid body seat range',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.generated_top_lid_locating_lip'),
      'previewMesh surfaces must include the generated top lid locating lip range',
      failures,
    );
    _expect(
      surfaceIds.contains('main_enclosure.generated_top_lid_screw_holes'),
      'previewMesh surfaces must include the generated top lid screw hole range',
      failures,
    );
    _expect(
      surfaceIds.contains('top_lid_buttons'),
      'previewMesh surfaces must include the generated top lid button group range',
      failures,
    );
    _expect(
      surfaceIds.contains('top_lid_glass_recess'),
      'previewMesh surfaces must include the generated top lid glass recess range',
      failures,
    );
    _expect(
      surfaceIds.contains('front_usb_c'),
      'previewMesh surfaces must include the sample USB-C feature range',
      failures,
    );
    _expect(
      surfaceIds.contains('front_glass_recess'),
      'previewMesh surfaces must include the sample glass recess feature range',
      failures,
    );
    _expect(
      surfaceIds.contains('front_buttons'),
      'previewMesh surfaces must include the sample button group feature range',
      failures,
    );
    _expect(
      surfaceIds.contains('standoff_mounts_1'),
      'previewMesh surfaces must include the sample standoff mount group feature range',
      failures,
    );
    _expect(
      previewMesh.surfaces.every(
        (surface) =>
            surface.triangleRanges.isNotEmpty &&
            surface.triangleRanges.every(
              (range) =>
                  range.start >= 0 &&
                  range.count > 0 &&
                  range.start + range.count <= previewMesh.triangleCount,
            ),
      ),
      'previewMesh surface ranges must be positive disposable triangle ranges',
      failures,
    );
    _expect(
      previewMesh.metadata['source'] == 'occt_brep',
      'previewMesh source metadata must identify disposable OCCT B-Rep output',
      failures,
    );
    _expect(
      previewMesh.metadata['surfaceMapping'] == 'semantic_face_ranges_v1',
      'previewMesh must identify first-pass semantic face range mapping',
      failures,
    );
    _expectDoubleList(
      previewMesh.bounds.min,
      const [-60, -36.65, 0],
      'previewMesh.bounds.min',
      failures,
    );
    _expectDoubleList(
      previewMesh.bounds.max,
      const [60, 35, 32],
      'previewMesh.bounds.max',
      failures,
    );
  }

  final metrics = response.metrics;
  _expect(
    metrics['generator'] == 'occt.rounded_enclosure.shell_preview_mesh.v1',
    'generator metric must identify the rounded enclosure shell preview mesh slice',
    failures,
  );
  _expect(
    metrics['bodyId'] == 'main_enclosure',
    'bodyId must match sample enclosure',
    failures,
  );
  _expect(
    metrics['shape'] == 'rounded_box',
    'shape must be rounded_box',
    failures,
  );
  _expect(
    metrics['cornerRadiusApplied'] == true,
    'corner radius must be applied',
    failures,
  );
  _expect(
    metrics['filletedEdgeCount'] == 24,
    'filleted edge count must be deterministic',
    failures,
  );
  _expect(
    metrics['shellCavityApplied'] == true,
    'shell cavity must be applied',
    failures,
  );
  _expect(
    metrics['shellCavityValid'] == true,
    'shell cavity must pass the native validity check',
    failures,
  );
  _expect(
    metrics['shellCavityToolCount'] == 1,
    'shell cavity must use one deterministic cavity tool',
    failures,
  );
  _expect(
    metrics['shellOpening'] == 'top',
    'shell opening must be top',
    failures,
  );
  _expect(
    metrics['nativeLidScrewBossCount'] == 4,
    'nativeLidScrewBossCount must include the generated top screw lid bosses',
    failures,
  );
  _expect(
    metrics['nativeLidScrewPilotCount'] == 4,
    'nativeLidScrewPilotCount must include generated pilot holes',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidPlateCount'] == 1,
    'nativeGeneratedLidPlateCount must include the generated top lid plate',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidSeatCount'] == 1,
    'nativeGeneratedLidSeatCount must include the generated body-side lid seat',
    failures,
  );
  _expectClose(
    _readNumber(metrics['nativeGeneratedLidFitPreviewGap']),
    0.35,
    0.000001,
    'nativeGeneratedLidFitPreviewGap',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidLipCount'] == 1,
    'nativeGeneratedLidLipCount must include the generated top lid locating lip',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidScrewHoleCount'] == 4,
    'nativeGeneratedLidScrewHoleCount must include the generated top lid screw holes',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidFeatureCutCount'] == 6,
    'nativeGeneratedLidFeatureCutCount must include generated top lid recess, window, and button holes',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidGlassRecessCount'] == 1,
    'nativeGeneratedLidGlassRecessCount must include the generated top lid glass recess',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidGlassRecessFilletedEdgeCount'] == 8,
    'nativeGeneratedLidGlassRecessFilletedEdgeCount must be deterministic',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidGlassWindowCount'] == 1,
    'nativeGeneratedLidGlassWindowCount must include the generated top lid glass window',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidGlassWindowFilletedEdgeCount'] == 8,
    'nativeGeneratedLidGlassWindowFilletedEdgeCount must be deterministic',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidButtonGroupCount'] == 1,
    'nativeGeneratedLidButtonGroupCount must include the semantic top lid button group',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidButtonCutoutCount'] == 4,
    'nativeGeneratedLidButtonCutoutCount must include generated top lid button items',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidButtonRingCount'] == 4,
    'nativeGeneratedLidButtonRingCount must include generated top lid button rings',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidButtonCapCount'] == 4,
    'nativeGeneratedLidButtonCapCount must include generated top lid button caps',
    failures,
  );
  _expect(
    metrics['nativeGeneratedLidButtonStemCount'] == 4,
    'nativeGeneratedLidButtonStemCount must include generated top lid button stems',
    failures,
  );
  _expect(
    metrics['featureIntentCount'] == 7,
    'featureIntentCount must match the sample request',
    failures,
  );
  _expect(
    metrics['nativeFeatureCutCount'] == 9,
    'nativeFeatureCutCount must include USB-C, glass recess/window, button, and standoff operations',
    failures,
  );
  _expect(
    metrics['nativeIgnoredFeatureIntentCount'] == 1,
    'nativeIgnoredFeatureIntentCount must track unsupported first-pass intents',
    failures,
  );
  _expect(
    metrics['nativeUsbCCutoutCount'] == 1,
    'nativeUsbCCutoutCount must include the sample USB-C cutout',
    failures,
  );
  _expect(
    metrics['nativeUsbCCutoutFilletedEdgeCount'] == 8,
    'nativeUsbCCutoutFilletedEdgeCount must be deterministic',
    failures,
  );
  _expect(
    metrics['nativeGlassRecessCount'] == 1,
    'nativeGlassRecessCount must include the sample glass recess',
    failures,
  );
  _expect(
    metrics['nativeGlassRecessFilletedEdgeCount'] == 8,
    'nativeGlassRecessFilletedEdgeCount must be deterministic',
    failures,
  );
  _expect(
    metrics['nativeGlassWindowCount'] == 1,
    'nativeGlassWindowCount must include the sample front glass window',
    failures,
  );
  _expect(
    metrics['nativeGlassWindowFilletedEdgeCount'] == 8,
    'nativeGlassWindowFilletedEdgeCount must be deterministic',
    failures,
  );
  _expect(
    metrics['nativeButtonGroupCount'] == 1,
    'nativeButtonGroupCount must include the sample button group',
    failures,
  );
  _expect(
    metrics['nativeButtonCutoutCount'] == 2,
    'nativeButtonCutoutCount must include the sample button items',
    failures,
  );
  _expect(
    metrics['nativeButtonRingCount'] == 2,
    'nativeButtonRingCount must include the sample front button rings',
    failures,
  );
  _expect(
    metrics['nativeButtonCapCount'] == 2,
    'nativeButtonCapCount must include the sample front button caps',
    failures,
  );
  _expect(
    metrics['nativeButtonStemCount'] == 2,
    'nativeButtonStemCount must include the sample front button stems',
    failures,
  );
  _expect(
    metrics['nativeStandoffGroupCount'] == 1,
    'nativeStandoffGroupCount must include the sample standoff group',
    failures,
  );
  _expect(
    metrics['nativeStandoffMountCount'] == 4,
    'nativeStandoffMountCount must include the sample standoff items',
    failures,
  );
  _expect(
    metrics['previewMeshEmitted'] == true,
    'previewMeshEmitted must be true',
    failures,
  );
  _expect(
    metrics['editableGeneratedGeometry'] == false,
    'editableGeneratedGeometry must be false',
    failures,
  );
  _expect(
    metrics['previewVertexCount'] == previewMesh?.vertexCount,
    'previewVertexCount metric must match previewMesh.vertexCount',
    failures,
  );
  _expect(
    metrics['previewTriangleCount'] == previewMesh?.triangleCount,
    'previewTriangleCount metric must match previewMesh.triangleCount',
    failures,
  );
  _expect(
    metrics['previewSurfaceMappingCount'] == previewMesh?.surfaces.length,
    'previewSurfaceMappingCount metric must match previewMesh.surfaces.length',
    failures,
  );
  final mappedTriangleCount = previewMesh == null
      ? 0
      : previewMesh.surfaces
            .expand((surface) => surface.triangleRanges)
            .fold<int>(0, (sum, range) => sum + range.count);
  _expect(
    metrics['previewMappedTriangleCount'] == mappedTriangleCount,
    'previewMappedTriangleCount metric must match mapped surface ranges',
    failures,
  );
  _expectClose(
    _readNumber(metrics['linearDeflection']),
    0.3,
    0.000001,
    'linearDeflection',
    failures,
  );
  _expectClose(
    _readNumber(metrics['angularDeflection']),
    0.35,
    0.000001,
    'angularDeflection',
    failures,
  );
  _expect(
    !metrics.containsKey('topologyId'),
    'metrics must not expose topologyId',
    failures,
  );
  _expect(
    !metrics.containsKey('triangleId'),
    'metrics must not expose triangleId',
    failures,
  );

  _expectDoubleList(
    metrics['inputSize'],
    const [120, 70, 28],
    'inputSize',
    failures,
  );
  _expectClose(
    _readNumber(metrics['wallThickness']),
    2,
    0.000001,
    'wallThickness',
    failures,
  );
  _expectClose(
    _readNumber(metrics['cornerRadius']),
    4,
    0.000001,
    'cornerRadius',
    failures,
  );
  _expectDoubleList(
    metrics['dimensions'],
    const [120, 71.65, 32],
    'dimensions',
    failures,
  );

  final bounds = _readMap(metrics['bounds']);
  _expectDoubleList(
    bounds['min'],
    const [-60, -36.65, 0],
    'bounds.min',
    failures,
  );
  _expectDoubleList(bounds['max'], const [60, 35, 32], 'bounds.max', failures);
  _expectClose(
    _readNumber(metrics['surfaceArea']),
    55539.19378,
    0.001,
    'surfaceArea',
    failures,
  );
  _expectClose(
    _readNumber(metrics['volume']),
    53150.290056,
    0.001,
    'volume',
    failures,
  );

  final summary = {
    'executable': executable,
    'capabilities': {
      'ok': !capabilities.hasErrors,
      'activeBackend': capabilities.capabilities?.activeBackend,
      'nativeStatus': nativeBackend?.status,
      'nativeSupportedOperations': [
        for (final operation
            in nativeBackend?.supportedOperations ??
                const <GeometryOperation>[])
          operation.wireName,
      ],
      if (capabilities.issues.isNotEmpty)
        'issues': [for (final issue in capabilities.issues) issue.toJson()],
    },
    'previewSmoke': {
      'ok': failures.isEmpty,
      'requestId': response.requestId,
      'status': response.status.wireName,
      'backend': response.backend,
      'previewMeshEmitted': metrics['previewMeshEmitted'],
      'previewVertices': previewMesh?.vertexCount,
      'previewTriangles': previewMesh?.triangleCount,
      'previewSurfaceMappings': previewMesh?.surfaces.length,
      'previewMappedTriangles': metrics['previewMappedTriangleCount'],
      'shellCavityApplied': metrics['shellCavityApplied'],
      'shellCavityValid': metrics['shellCavityValid'],
      'shellCavityToolCount': metrics['shellCavityToolCount'],
      'shellOpening': metrics['shellOpening'],
      'nativeLidScrewBossCount': metrics['nativeLidScrewBossCount'],
      'nativeLidScrewPilotCount': metrics['nativeLidScrewPilotCount'],
      'nativeGeneratedLidPlateCount': metrics['nativeGeneratedLidPlateCount'],
      'nativeGeneratedLidSeatCount': metrics['nativeGeneratedLidSeatCount'],
      'nativeGeneratedLidFitPreviewGap':
          metrics['nativeGeneratedLidFitPreviewGap'],
      'nativeGeneratedLidLipCount': metrics['nativeGeneratedLidLipCount'],
      'nativeGeneratedLidScrewHoleCount':
          metrics['nativeGeneratedLidScrewHoleCount'],
      'nativeGeneratedLidFeatureCutCount':
          metrics['nativeGeneratedLidFeatureCutCount'],
      'nativeGeneratedLidGlassRecessCount':
          metrics['nativeGeneratedLidGlassRecessCount'],
      'nativeGeneratedLidGlassRecessFilletedEdgeCount':
          metrics['nativeGeneratedLidGlassRecessFilletedEdgeCount'],
      'nativeGeneratedLidGlassWindowCount':
          metrics['nativeGeneratedLidGlassWindowCount'],
      'nativeGeneratedLidGlassWindowFilletedEdgeCount':
          metrics['nativeGeneratedLidGlassWindowFilletedEdgeCount'],
      'nativeGeneratedLidButtonGroupCount':
          metrics['nativeGeneratedLidButtonGroupCount'],
      'nativeGeneratedLidButtonCutoutCount':
          metrics['nativeGeneratedLidButtonCutoutCount'],
      'nativeGeneratedLidButtonRingCount':
          metrics['nativeGeneratedLidButtonRingCount'],
      'nativeGeneratedLidButtonCapCount':
          metrics['nativeGeneratedLidButtonCapCount'],
      'nativeGeneratedLidButtonStemCount':
          metrics['nativeGeneratedLidButtonStemCount'],
      'featureIntentCount': metrics['featureIntentCount'],
      'nativeFeatureCutCount': metrics['nativeFeatureCutCount'],
      'nativeIgnoredFeatureIntentCount':
          metrics['nativeIgnoredFeatureIntentCount'],
      'nativeUsbCCutoutCount': metrics['nativeUsbCCutoutCount'],
      'nativeUsbCCutoutFilletedEdgeCount':
          metrics['nativeUsbCCutoutFilletedEdgeCount'],
      'nativeGlassRecessCount': metrics['nativeGlassRecessCount'],
      'nativeGlassRecessFilletedEdgeCount':
          metrics['nativeGlassRecessFilletedEdgeCount'],
      'nativeGlassWindowCount': metrics['nativeGlassWindowCount'],
      'nativeGlassWindowFilletedEdgeCount':
          metrics['nativeGlassWindowFilletedEdgeCount'],
      'nativeButtonGroupCount': metrics['nativeButtonGroupCount'],
      'nativeButtonCutoutCount': metrics['nativeButtonCutoutCount'],
      'nativeButtonRingCount': metrics['nativeButtonRingCount'],
      'nativeButtonCapCount': metrics['nativeButtonCapCount'],
      'nativeButtonStemCount': metrics['nativeButtonStemCount'],
      'nativeStandoffGroupCount': metrics['nativeStandoffGroupCount'],
      'nativeStandoffMountCount': metrics['nativeStandoffMountCount'],
      'bounds': metrics['bounds'],
      'dimensions': metrics['dimensions'],
      'surfaceArea': metrics['surfaceArea'],
      'volume': metrics['volume'],
      if (response.issues.isNotEmpty)
        'issues': [for (final issue in response.issues) issue.toJson()],
      if (failures.isNotEmpty) 'failures': failures,
    },
  };

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(summary));
  if (failures.isNotEmpty) {
    exitCode = 2;
  }
}

Future<ProcessResult> _buildNativeOcct(String repoRoot, String configuration) {
  return Process.run('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    _joinPath(repoRoot, ['tools', 'build_occt_worker_occt.ps1']),
    '-Configuration',
    configuration,
    '-AllowVcpkgInstall',
  ]);
}

ProjectModel _nativeSmokeProject() {
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

String _nativeOcctExecutablePath(String repoRoot, String configuration) {
  return _joinPath(repoRoot, [
    'build',
    'occt_worker_native_occt',
    configuration,
    'occt_worker_native_occt.exe',
  ]);
}

String _joinPath(String root, List<String> parts) {
  return [root, ...parts].join(Platform.pathSeparator);
}

void _expect(bool condition, String message, List<String> failures) {
  if (!condition) {
    failures.add(message);
  }
}

void _expectDoubleList(
  Object? value,
  List<double> expected,
  String label,
  List<String> failures,
) {
  final actual = _readDoubleList(value);
  if (actual.length != expected.length) {
    failures.add('$label expected $expected, got $actual.');
    return;
  }

  for (var index = 0; index < expected.length; index++) {
    if ((actual[index] - expected[index]).abs() > 0.000001) {
      failures.add('$label expected $expected, got $actual.');
      return;
    }
  }
}

void _expectClose(
  double? actual,
  double expected,
  double tolerance,
  String label,
  List<String> failures,
) {
  if (actual == null || (actual - expected).abs() > tolerance) {
    failures.add('$label expected $expected +/- $tolerance, got $actual.');
  }
}

Map<String, Object?> _readMap(Object? value) {
  return value is Map<String, Object?> ? value : const {};
}

double? _readNumber(Object? value) {
  return value is num ? value.toDouble() : null;
}

List<double> _readDoubleList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value.whereType<num>().map((item) => item.toDouble()).toList();
}

class _SmokeOptions {
  const _SmokeOptions({required this.configuration, required this.skipBuild});

  final String configuration;
  final bool skipBuild;

  factory _SmokeOptions.fromArgs(List<String> args) {
    var configuration = 'Release';
    var skipBuild = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--skip-build') {
        skipBuild = true;
        continue;
      }

      if (arg.startsWith('--configuration=')) {
        configuration = arg.substring('--configuration='.length);
        continue;
      }

      if (arg == '--configuration') {
        final valueIndex = index + 1;
        if (valueIndex >= args.length) {
          throw const FormatException('Missing value after --configuration.');
        }
        configuration = args[valueIndex];
        index = valueIndex;
        continue;
      }

      throw FormatException('Unknown native OCCT smoke argument "$arg".');
    }

    if (configuration != 'Debug' && configuration != 'Release') {
      throw FormatException(
        'Unsupported configuration "$configuration". Use Debug or Release.',
      );
    }

    return _SmokeOptions(configuration: configuration, skipBuild: skipBuild);
  }
}
