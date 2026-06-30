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
      previewMesh.vertexCount == 1594,
      'previewMesh must contain the deterministic sample vertex count',
      failures,
    );
    _expect(
      previewMesh.triangleCount == 1914,
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
      previewMesh.surfaces.length == 5,
      'previewMesh must expose body surfaces plus USB-C and glass feature mappings',
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
      const [-60, -35, 0],
      'previewMesh.bounds.min',
      failures,
    );
    _expectDoubleList(
      previewMesh.bounds.max,
      const [60, 35, 27.464102],
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
    metrics['featureIntentCount'] == 3,
    'featureIntentCount must match the sample request',
    failures,
  );
  _expect(
    metrics['nativeFeatureCutCount'] == 2,
    'nativeFeatureCutCount must include USB-C and glass recess cuts',
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
    const [120, 70, 27.464102],
    'dimensions',
    failures,
  );

  final bounds = _readMap(metrics['bounds']);
  _expectDoubleList(bounds['min'], const [-60, -35, 0], 'bounds.min', failures);
  _expectDoubleList(
    bounds['max'],
    const [60, 35, 27.464102],
    'bounds.max',
    failures,
  );
  _expectClose(
    _readNumber(metrics['surfaceArea']),
    34797.533162,
    0.001,
    'surfaceArea',
    failures,
  );
  _expectClose(
    _readNumber(metrics['volume']),
    33427.951321,
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
  return ProjectModel.initial().replaceFeature(
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
