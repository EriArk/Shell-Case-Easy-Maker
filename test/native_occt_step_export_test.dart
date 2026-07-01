import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';

import 'support/native_occt_geometry_fixture.dart';

void main() {
  final repoRoot = Directory.current.absolute.path;
  final executable = nativeOcctExecutablePath(repoRoot);
  final hasNativeWorker = File(executable).existsSync();

  test(
    'native OCCT worker exports known sample as STEP artifact',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'shell_case_step_export_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final output = File(
        '${tempDir.path}${Platform.pathSeparator}sample_button_board_case.step',
      );
      final client = nativeOcctWorkerClient(repoRoot);
      final capabilities = await client.queryCapabilities();
      final nativeBackend = capabilities.capabilities!.backends.singleWhere(
        (backend) => backend.id == 'native',
      );

      expect(capabilities.hasErrors, isFalse);
      expect(
        nativeBackend.supportedOperations,
        contains(GeometryOperation.exportStep),
      );

      final response = await client.buildGeometry(
        GeometryRequest.exportStep(
          nativeOcctRegressionProject(),
          requestId: 'native_occt_step_export',
          outputPath: output.path,
        ),
      );

      expect(response.requestId, 'native_occt_step_export');
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'occt_worker_native_occt');
      expect(response.hasErrors, isFalse);
      expect(response.previewMesh, isNull);
      expect(response.artifacts, hasLength(1));

      final artifact = response.artifacts.single;
      expect(artifact.type, 'step');
      expect(artifact.path, output.path);
      expect(artifact.metadata['format'], 'STEP');
      expect(artifact.metadata['source'], 'occt_brep');
      expect(artifact.metadata['units'], 'mm');
      expect(await output.exists(), isTrue);
      expect(await output.length(), greaterThan(1000));
      expect(artifact.metadata['byteCount'], await output.length());

      final stepText = await output.readAsString();
      expect(stepText, startsWith('ISO-10303-21;'));
      expect(stepText, contains('HEADER;'));
      expect(stepText, contains('DATA;'));
      expect(stepText, contains('ENDSEC;'));
      expect(stepText, contains('END-ISO-10303-21;'));

      final metrics = response.metrics;
      expect(metrics['generator'], 'occt.rounded_enclosure.step_export.v1');
      expect(metrics['requestedOperation'], 'export_step');
      expect(metrics['exportFormat'], 'step');
      expect(metrics['exportArtifactCount'], 1);
      expect(metrics['exportPath'], output.path);
      expect(metrics['exportByteCount'], await output.length());
      expect(metrics['exportTransferStatus'], 'done');
      expect(metrics['exportWriteStatus'], 'done');
      expect(metrics['previewMeshEmitted'], isFalse);
      expect(metrics['editableGeneratedGeometry'], isFalse);
      expect(
        nativeOcctReadDoubleList(metrics['dimensions']),
        nativeOcctExpectedDimensions,
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
}
