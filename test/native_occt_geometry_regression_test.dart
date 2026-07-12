import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';

import 'support/native_occt_geometry_fixture.dart';

void main() {
  final repoRoot = Directory.current.absolute.path;
  final executable = nativeOcctExecutablePath(repoRoot);
  final hasNativeWorker = File(executable).existsSync();

  test(
    'native OCCT preview preserves known sample dimensions and mappings',
    () async {
      final client = nativeOcctWorkerClient(repoRoot);
      final capabilities = await client.queryCapabilities();

      expect(
        capabilities.hasErrors,
        isFalse,
        reason: capabilities.issues.map((issue) => issue.message).join('\n'),
      );
      expect(capabilities.capabilities?.activeBackend, 'native');
      expect(capabilities.capabilities?.sourceOfTruth, 'semantic_project');
      expect(capabilities.capabilities?.editableGeneratedGeometry, isFalse);

      final nativeBackend = capabilities.capabilities!.backends.singleWhere(
        (backend) => backend.id == 'native',
      );
      expect(nativeBackend.status, 'preview_mesh_smoke');
      expect(
        nativeBackend.supportedOperations,
        contains(GeometryOperation.previewMesh),
      );

      final response = await client.buildGeometry(
        GeometryRequest.previewMesh(
          nativeOcctRegressionProject(),
          requestId: 'native_occt_geometry_regression',
        ),
      );

      expect(response.requestId, 'native_occt_geometry_regression');
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'occt_worker_native_occt');
      expect(response.hasErrors, isFalse);

      final mesh = response.previewMesh;
      expect(mesh, isNotNull);
      expect(mesh!.units, 'mm');
      expect(mesh.vertexCount, nativeOcctExpectedPreviewVertexCount);
      expect(mesh.triangleCount, nativeOcctExpectedPreviewTriangleCount);
      expect(mesh.vertices, hasLength(mesh.vertexCount * 3));
      expect(mesh.triangles, hasLength(mesh.triangleCount * 3));
      expect(
        mesh.triangles.every((index) => index >= 0 && index < mesh.vertexCount),
        isTrue,
      );
      expect(mesh.bounds.min, nativeOcctExpectedBoundsMin);
      expect(mesh.bounds.max, nativeOcctExpectedBoundsMax);
      expect(mesh.surfaces, hasLength(nativeOcctExpectedSurfaceMappingCount));
      expect(nativeOcctTriangleRangesAreValid(mesh), isTrue);
      expect(
        nativeOcctMappedTriangleCount(mesh),
        nativeOcctExpectedMappedTriangleCount,
      );

      final surfaceIds = mesh.surfaces
          .map((surface) => surface.semanticId)
          .toSet();
      expect(surfaceIds, containsAll(nativeOcctExpectedSurfaceIds));
      expect(mesh.metadata['source'], 'occt_brep');
      expect(mesh.metadata['surfaceMapping'], 'semantic_face_ranges_v1');

      final metrics = response.metrics;
      expect(
        metrics['generator'],
        'occt.rounded_enclosure.shell_preview_mesh.v1',
      );
      expect(metrics['bodyId'], 'main_enclosure');
      expect(metrics['shape'], 'rounded_box');
      expect(metrics['cornerRadiusApplied'], isTrue);
      expect(metrics['filletedEdgeCount'], 24);
      expect(metrics['shellCavityApplied'], isTrue);
      expect(metrics['shellCavityValid'], isTrue);
      expect(metrics['shellCavityToolCount'], 1);
      expect(metrics['shellOpening'], 'top');
      expect(metrics['featureIntentCount'], 9);
      expect(metrics['nativeFeatureCutCount'], 10);
      expect(metrics['nativeIgnoredFeatureIntentCount'], 1);
      expect(metrics['nativeLidScrewBossCount'], 4);
      expect(metrics['nativeLidScrewPilotCount'], 4);
      expect(metrics['nativeGeneratedLidPlateCount'], 1);
      expect(metrics['nativeGeneratedLidSeatCount'], 1);
      expect(
        nativeOcctReadNumber(metrics['nativeGeneratedLidFitPreviewGap']),
        closeTo(nativeOcctExpectedFitPreviewGap, 0.000001),
      );
      expect(metrics['nativeGeneratedLidLipCount'], 1);
      expect(metrics['nativeGeneratedLidScrewHoleCount'], 4);
      expect(metrics['nativeGeneratedLidFeatureCutCount'], 7);
      expect(metrics['nativeGeneratedLidCircularCutoutCount'], 1);
      expect(metrics['nativeGeneratedLidGlassRecessCount'], 1);
      expect(metrics['nativeGeneratedLidGlassRecessFilletedEdgeCount'], 8);
      expect(metrics['nativeGeneratedLidGlassWindowCount'], 1);
      expect(metrics['nativeGeneratedLidGlassWindowFilletedEdgeCount'], 8);
      expect(metrics['nativeGeneratedLidButtonGroupCount'], 1);
      expect(metrics['nativeGeneratedLidButtonCutoutCount'], 4);
      expect(metrics['nativeGeneratedLidButtonRingCount'], 4);
      expect(metrics['nativeGeneratedLidButtonCapCount'], 4);
      expect(metrics['nativeGeneratedLidButtonStemCount'], 4);
      expect(metrics['nativeGeneratedLidButtonGuideCount'], 4);
      expect(metrics['nativeGeneratedLidButtonTravelStopCount'], 4);
      expect(metrics['nativeUsbCCutoutCount'], 1);
      expect(metrics['nativeUsbCCutoutFilletedEdgeCount'], 8);
      expect(metrics['nativeGlassRecessCount'], 1);
      expect(metrics['nativeGlassRecessFilletedEdgeCount'], 8);
      expect(metrics['nativeGlassWindowCount'], 1);
      expect(metrics['nativeGlassWindowFilletedEdgeCount'], 8);
      expect(metrics['nativeCircularCutoutCount'], 1);
      expect(metrics['nativeButtonGroupCount'], 1);
      expect(metrics['nativeButtonCutoutCount'], 2);
      expect(metrics['nativeButtonRingCount'], 2);
      expect(metrics['nativeButtonCapCount'], 2);
      expect(metrics['nativeButtonStemCount'], 2);
      expect(metrics['nativeButtonGuideCount'], 2);
      expect(metrics['nativeButtonTravelStopCount'], 2);
      expect(metrics['nativeStandoffGroupCount'], 1);
      expect(metrics['nativeStandoffMountCount'], 4);
      expect(metrics['previewMeshEmitted'], isTrue);
      expect(metrics['editableGeneratedGeometry'], isFalse);
      expect(metrics['previewVertexCount'], mesh.vertexCount);
      expect(metrics['previewTriangleCount'], mesh.triangleCount);
      expect(metrics['previewSurfaceMappingCount'], mesh.surfaces.length);
      expect(
        metrics['previewMappedTriangleCount'],
        nativeOcctMappedTriangleCount(mesh),
      );
      expect(nativeOcctReadDoubleList(metrics['inputSize']), [
        120.0,
        70.0,
        28.0,
      ]);
      expect(nativeOcctReadNumber(metrics['wallThickness']), closeTo(2, 0));
      expect(nativeOcctReadNumber(metrics['cornerRadius']), closeTo(4, 0));
      expect(
        nativeOcctReadDoubleList(metrics['dimensions']),
        nativeOcctExpectedDimensions,
      );

      final bounds = nativeOcctReadMap(metrics['bounds']);
      expect(
        nativeOcctReadDoubleList(bounds['min']),
        nativeOcctExpectedBoundsMin,
      );
      expect(
        nativeOcctReadDoubleList(bounds['max']),
        nativeOcctExpectedBoundsMax,
      );
      expect(
        nativeOcctReadNumber(metrics['surfaceArea']),
        closeTo(nativeOcctExpectedSurfaceArea, 0.001),
      );
      expect(
        nativeOcctReadNumber(metrics['volume']),
        closeTo(nativeOcctExpectedVolume, 0.001),
      );
      expect(metrics, isNot(contains('topologyId')));
      expect(metrics, isNot(contains('triangleId')));
    },
    skip: hasNativeWorker
        ? false
        : 'Native OCCT worker executable not built. Run tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall.',
    timeout: const Timeout(Duration(seconds: 90)),
  );

  test(
    'native OCCT preview cuts semantic rectangular cutouts',
    () async {
      final client = nativeOcctWorkerClient(repoRoot);
      final response = await client.buildGeometry(
        GeometryRequest.previewMesh(
          nativeOcctRectangularCutoutProject(),
          requestId: 'native_occt_rectangular_cutouts',
        ),
      );

      expect(response.requestId, 'native_occt_rectangular_cutouts');
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'occt_worker_native_occt');
      expect(response.hasErrors, isFalse);

      final mesh = response.previewMesh;
      expect(mesh, isNotNull);
      expect(mesh!.units, 'mm');
      expect(
        mesh.vertexCount,
        nativeOcctRectangularCutoutExpectedPreviewVertexCount,
      );
      expect(
        mesh.triangleCount,
        nativeOcctRectangularCutoutExpectedPreviewTriangleCount,
      );
      expect(mesh.bounds.min, nativeOcctRectangularCutoutExpectedBoundsMin);
      expect(mesh.bounds.max, nativeOcctRectangularCutoutExpectedBoundsMax);
      expect(
        mesh.surfaces,
        hasLength(nativeOcctRectangularCutoutExpectedSurfaceMappingCount),
      );
      expect(nativeOcctTriangleRangesAreValid(mesh), isTrue);
      expect(
        nativeOcctMappedTriangleCount(mesh),
        nativeOcctRectangularCutoutExpectedMappedTriangleCount,
      );

      final surfaceIds = mesh.surfaces
          .map((surface) => surface.semanticId)
          .toSet();
      expect(
        surfaceIds,
        containsAll(nativeOcctRectangularCutoutExpectedSurfaceIds),
      );

      final metrics = response.metrics;
      expect(metrics['featureIntentCount'], 2);
      expect(metrics['nativeFeatureCutCount'], 1);
      expect(metrics['nativeGeneratedLidFeatureCutCount'], 1);
      expect(metrics['nativeIgnoredFeatureIntentCount'], 0);
      expect(metrics['nativeRectangularCutoutCount'], 1);
      expect(metrics['nativeRectangularCutoutFilletedEdgeCount'], 8);
      expect(metrics['nativeGeneratedLidRectangularCutoutCount'], 1);
      expect(
        metrics['nativeGeneratedLidRectangularCutoutFilletedEdgeCount'],
        8,
      );
      expect(
        nativeOcctReadDoubleList(metrics['dimensions']),
        nativeOcctRectangularCutoutExpectedDimensions,
      );
      expect(
        nativeOcctReadNumber(metrics['surfaceArea']),
        closeTo(nativeOcctRectangularCutoutExpectedSurfaceArea, 0.001),
      );
      expect(
        nativeOcctReadNumber(metrics['volume']),
        closeTo(nativeOcctRectangularCutoutExpectedVolume, 0.001),
      );
      expect(metrics, isNot(contains('topologyId')));
      expect(metrics, isNot(contains('triangleId')));
    },
    skip: hasNativeWorker
        ? false
        : 'Native OCCT worker executable not built. Run tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall.',
    timeout: const Timeout(Duration(seconds: 90)),
  );

  test(
    'native OCCT preview cuts advanced sketch profile contours',
    () async {
      final client = nativeOcctWorkerClient(repoRoot);
      final response = await client.buildGeometry(
        GeometryRequest.previewMesh(
          nativeOcctSketchProfileCutProject(),
          requestId: 'native_occt_sketch_profile_cuts',
        ),
      );

      expect(response.requestId, 'native_occt_sketch_profile_cuts');
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'occt_worker_native_occt');
      expect(response.hasErrors, isFalse);

      final mesh = response.previewMesh;
      expect(mesh, isNotNull);
      expect(mesh!.vertexCount, greaterThan(0));
      expect(mesh.triangleCount, greaterThan(0));
      expect(nativeOcctTriangleRangesAreValid(mesh), isTrue);

      final surfaceIds = mesh.surfaces
          .map((surface) => surface.semanticId)
          .toSet();
      expect(surfaceIds, contains('advanced_sketch_1.lid_round_cut'));
      expect(surfaceIds, contains('advanced_sketch_1.lid_rect_cut'));
      expect(surfaceIds, contains('advanced_sketch_1.lid_rotated_rect_cut'));
      expect(surfaceIds, isNot(contains('advanced_sketch_1.future_add')));

      final metrics = response.metrics;
      expect(metrics['featureIntentCount'], 1);
      expect(metrics['nativeFeatureCutCount'], 0);
      expect(metrics['nativeIgnoredFeatureIntentCount'], 0);
      expect(metrics['nativeCircularCutoutCount'], 0);
      expect(metrics['nativeRectangularCutoutCount'], 0);
      expect(metrics['nativeGeneratedLidFeatureCutCount'], 3);
      expect(metrics['nativeGeneratedLidCircularCutoutCount'], 1);
      expect(metrics['nativeGeneratedLidRectangularCutoutCount'], 2);
      expect(
        metrics['nativeGeneratedLidRectangularCutoutFilletedEdgeCount'],
        16,
      );
      expect(metrics, isNot(contains('topologyId')));
      expect(metrics, isNot(contains('triangleId')));
    },
    skip: hasNativeWorker
        ? false
        : 'Native OCCT worker executable not built. Run tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall.',
    timeout: const Timeout(Duration(seconds: 90)),
  );

  test(
    'native OCCT preview cuts component switch-sourced top lid buttons',
    () async {
      final client = nativeOcctWorkerClient(repoRoot);
      final response = await client.buildGeometry(
        GeometryRequest.previewMesh(
          nativeOcctSwitchSourcedButtonProject(),
          requestId: 'native_occt_switch_sourced_buttons',
        ),
      );

      expect(response.requestId, 'native_occt_switch_sourced_buttons');
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'occt_worker_native_occt');
      expect(response.hasErrors, isFalse);

      final mesh = response.previewMesh;
      expect(mesh, isNotNull);
      expect(mesh!.units, 'mm');
      expect(mesh.vertexCount, greaterThan(0));
      expect(mesh.triangleCount, greaterThan(0));
      expect(nativeOcctTriangleRangesAreValid(mesh), isTrue);

      final surfaceIds = mesh.surfaces
          .map((surface) => surface.semanticId)
          .toSet();
      expect(surfaceIds, contains('component_switch_buttons'));

      final metrics = response.metrics;
      expect(metrics['featureIntentCount'], 2);
      expect(metrics['nativeIgnoredFeatureIntentCount'], 0);
      expect(metrics['nativeUsbCCutoutCount'], 1);
      expect(metrics['nativeGeneratedLidButtonGroupCount'], 1);
      expect(metrics['nativeGeneratedLidButtonCutoutCount'], 4);
      expect(metrics['nativeGeneratedLidButtonRingCount'], 4);
      expect(metrics['nativeGeneratedLidButtonCapCount'], 4);
      expect(metrics['nativeGeneratedLidButtonStemCount'], 4);
      expect(metrics['nativeGeneratedLidButtonGuideCount'], 4);
      expect(metrics['nativeGeneratedLidButtonTravelStopCount'], 4);
      expect(metrics['nativeButtonGroupCount'], 0);
      expect(metrics['nativeButtonCutoutCount'], 0);
      expect(metrics, isNot(contains('topologyId')));
      expect(metrics, isNot(contains('triangleId')));
    },
    skip: hasNativeWorker
        ? false
        : 'Native OCCT worker executable not built. Run tools/build_occt_worker_occt.ps1 -AllowVcpkgInstall.',
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
