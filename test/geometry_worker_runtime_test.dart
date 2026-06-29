import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('worker runtime defaults to mock backend', () async {
    const runtime = GeometryWorkerRuntime();
    final request = GeometryRequest.previewMesh(
      ProjectModel.initial(),
      requestId: 'runtime_mock',
    );

    final result = await runtime.handlePayload(jsonEncode(request.toJson()));

    expect(result.exitCode, 0);
    expect(result.response.status, GeometryResponseStatus.ok);
    expect(result.response.backend, 'mock');
    expect(result.response.previewMesh?.vertexCount, 8);
    expect(result.response.metrics['featureIntents'], 2);
    expect(
      result.responseJson,
      contains('"schema": "shell_case.geometry.response"'),
    );
  });

  test('worker runtime parses explicit backend arguments', () {
    expect(
      GeometryWorkerRuntimeSettings.fromArgs(const ['--backend=mock']).backend,
      GeometryWorkerRuntimeBackend.mock,
    );
    expect(
      GeometryWorkerRuntimeSettings.fromArgs(const [
        '--backend',
        'native',
      ]).backend,
      GeometryWorkerRuntimeBackend.native,
    );
    expect(
      GeometryWorkerRuntimeSettings.fromArgs(const [
        '--backend=native',
        '--capabilities',
      ]).emitCapabilities,
      isTrue,
    );
  });

  test('worker capabilities describe mock availability and native stub', () {
    const runtime = GeometryWorkerRuntime(
      settings: GeometryWorkerRuntimeSettings(
        backend: GeometryWorkerRuntimeBackend.native,
        emitCapabilities: true,
      ),
    );

    final capabilities = runtime.capabilities().toJson();
    final backends = capabilities['backends']! as List<Object?>;
    final mock = backends.cast<Map<String, Object?>>().singleWhere(
      (backend) => backend['id'] == 'mock',
    );
    final native = backends.cast<Map<String, Object?>>().singleWhere(
      (backend) => backend['id'] == 'native',
    );

    expect(capabilities['schema'], GeometryWorkerCapabilities.schemaName);
    expect(capabilities['activeBackend'], 'native');
    expect(capabilities['sourceOfTruth'], 'semantic_project');
    expect(capabilities['editableGeneratedGeometry'], isFalse);
    expect(mock['status'], 'available');
    expect(mock['supportedOperations'], contains('preview_mesh'));
    expect(native['status'], 'stub');
    expect(native['plannedOperations'], contains('export_step'));
    expect(
      native['issueCodes'],
      contains('worker.backend.native_not_implemented'),
    );
    expect(jsonEncode(capabilities), isNot(contains('TopoDS')));
  });

  test('worker runtime rejects invalid payloads as protocol errors', () async {
    const runtime = GeometryWorkerRuntime();

    final result = await runtime.handlePayload('{not json');

    expect(result.exitCode, 2);
    expect(result.response.status, GeometryResponseStatus.error);
    expect(result.response.backend, 'worker_protocol');
    expect(result.response.issues.single.code, 'worker.request.invalid_json');
  });

  test(
    'native backend mode reports an explicit not implemented response',
    () async {
      const runtime = GeometryWorkerRuntime(
        settings: GeometryWorkerRuntimeSettings(
          backend: GeometryWorkerRuntimeBackend.native,
        ),
      );
      final request = GeometryRequest.previewMesh(
        ProjectModel.initial(),
        requestId: 'native_stub',
      );

      final result = await runtime.handlePayload(jsonEncode(request.toJson()));

      expect(result.exitCode, 2);
      expect(result.response.requestId, 'native_stub');
      expect(result.response.backend, 'occt_worker_stub');
      expect(
        result.response.issues.single.code,
        'worker.backend.native_not_implemented',
      );
      expect(result.response.metrics['requestedBackend'], 'native');
    },
  );

  test('invalid CLI arguments produce response JSON', () {
    final result = GeometryWorkerRunResult.invalidConfiguration(
      'Unknown geometry worker argument "--bad".',
    );

    expect(result.exitCode, 2);
    expect(result.response.backend, 'geometry_worker_cli');
    expect(result.response.issues.single.code, 'worker.cli.invalid_arguments');
    expect(jsonDecode(result.responseJson), isA<Map<String, Object?>>());
  });

  test(
    'canonical occt_worker CLI runs through the process client',
    () async {
      final client = GeometryWorkerProcessClient(
        command: GeometryWorkerProcessCommand(
          executable: 'dart',
          arguments: const ['run', 'occt_worker/bin/occt_worker.dart'],
          workingDirectory: Directory.current.path,
          runInShell: Platform.isWindows,
        ),
        timeout: const Duration(seconds: 30),
      );

      final response = await client.buildGeometry(
        GeometryRequest.previewMesh(
          ProjectModel.initial(),
          requestId: 'occt_worker_cli_process',
        ),
      );

      expect(response.requestId, 'occt_worker_cli_process');
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'mock');
      expect(response.previewMesh?.triangleCount, 12);
      expect(response.metrics['operationCount'], 2);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'canonical occt_worker CLI emits capabilities without stdin',
    () async {
      final result = await Process.run(
        'dart',
        const ['run', 'occt_worker/bin/occt_worker.dart', '--capabilities'],
        workingDirectory: Directory.current.path,
        runInShell: Platform.isWindows,
      );
      final decoded = jsonDecode(result.stdout as String);

      expect(result.exitCode, 0);
      expect(decoded, isA<Map<String, Object?>>());
      expect(
        (decoded as Map<String, Object?>)['schema'],
        GeometryWorkerCapabilities.schemaName,
      );
      expect(decoded['activeBackend'], 'mock');
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
