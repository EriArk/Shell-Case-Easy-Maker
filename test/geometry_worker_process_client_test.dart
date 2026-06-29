import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test(
    'process client sends request JSON and parses worker response',
    () async {
      late GeometryWorkerProcessCommand capturedCommand;
      late String capturedPayload;
      final client = GeometryWorkerProcessClient(
        command: const GeometryWorkerProcessCommand(
          executable: 'worker',
          arguments: ['--stdio'],
          workingDirectory: 'build/worker',
        ),
        runProcess: (command, stdinPayload) async {
          capturedCommand = command;
          capturedPayload = stdinPayload;
          final request = GeometryRequest.fromJson(
            jsonDecode(stdinPayload) as Map<String, Object?>,
          );

          return GeometryWorkerProcessResult(
            exitCode: 0,
            stderr: '',
            stdout: jsonEncode(
              GeometryResponse(
                requestId: request.requestId,
                status: GeometryResponseStatus.ok,
                backend: 'fake_worker',
                metrics: const {'received': true},
              ).toJson(),
            ),
          );
        },
      );

      final response = await client.buildGeometry(
        GeometryRequest.previewMesh(
          ProjectModel.initial(),
          requestId: 'process_preview',
        ),
      );
      final sentRequest = GeometryRequest.fromJson(
        jsonDecode(capturedPayload) as Map<String, Object?>,
      );

      expect(capturedCommand.executable, 'worker');
      expect(capturedCommand.arguments, ['--stdio']);
      expect(capturedCommand.workingDirectory, 'build/worker');
      expect(sentRequest.requestId, 'process_preview');
      expect(sentRequest.featureIntents, hasLength(2));
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'fake_worker');
      expect(response.metrics['received'], isTrue);
    },
  );

  test('process client preserves worker error responses', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      runProcess: (command, stdinPayload) async {
        final request = GeometryRequest.fromJson(
          jsonDecode(stdinPayload) as Map<String, Object?>,
        );
        return GeometryWorkerProcessResult(
          exitCode: 2,
          stderr: 'worker rejected request',
          stdout: jsonEncode(
            GeometryResponse(
              requestId: request.requestId,
              status: GeometryResponseStatus.error,
              backend: 'fake_worker',
              issues: const [
                GeometryIssue(
                  severity: GeometryIssueSeverity.error,
                  code: 'fake.worker.rejected',
                  message: 'Rejected.',
                ),
              ],
            ).toJson(),
          ),
        );
      },
    );

    final response = await client.buildGeometry(
      GeometryRequest.previewMesh(
        ProjectModel.initial(),
        requestId: 'rejected',
      ),
    );

    expect(response.status, GeometryResponseStatus.error);
    expect(response.backend, 'fake_worker');
    expect(response.issues.single.code, 'fake.worker.rejected');
  });

  test('process client reports invalid worker response JSON', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      runProcess: (command, stdinPayload) async {
        return const GeometryWorkerProcessResult(
          exitCode: 0,
          stdout: 'not json',
          stderr: 'debug details',
        );
      },
    );

    final response = await client.buildGeometry(
      GeometryRequest.previewMesh(
        ProjectModel.initial(),
        requestId: 'invalid_response',
      ),
    );

    expect(response.status, GeometryResponseStatus.error);
    expect(response.backend, 'worker_process');
    expect(response.issues.single.code, 'worker.response.invalid_json');
    expect(response.metrics['stderrSample'], 'debug details');
  });

  test('process client reports non-zero exit without worker error', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      runProcess: (command, stdinPayload) async {
        final request = GeometryRequest.fromJson(
          jsonDecode(stdinPayload) as Map<String, Object?>,
        );
        return GeometryWorkerProcessResult(
          exitCode: 7,
          stderr: 'native crash',
          stdout: jsonEncode(
            GeometryResponse(
              requestId: request.requestId,
              status: GeometryResponseStatus.ok,
              backend: 'fake_worker',
            ).toJson(),
          ),
        );
      },
    );

    final response = await client.buildGeometry(
      GeometryRequest.previewMesh(
        ProjectModel.initial(),
        requestId: 'bad_exit',
      ),
    );

    expect(response.status, GeometryResponseStatus.error);
    expect(response.backend, 'worker_process');
    expect(response.issues.single.code, 'worker.process.exit');
    expect(response.metrics['exitCode'], 7);
  });

  test('process client reports process timeouts', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      timeout: const Duration(milliseconds: 1),
      runProcess: (command, stdinPayload) {
        return Completer<GeometryWorkerProcessResult>().future;
      },
    );

    final response = await client.buildGeometry(
      GeometryRequest.previewMesh(ProjectModel.initial(), requestId: 'timeout'),
    );

    expect(response.status, GeometryResponseStatus.error);
    expect(response.issues.single.code, 'worker.process.timeout');
    expect(response.metrics['timeoutMs'], 1);
  });

  test('process client queries worker capabilities', () async {
    late GeometryWorkerProcessCommand capturedCommand;
    late String capturedPayload;
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(
        executable: 'worker',
        arguments: ['--stdio'],
      ),
      runProcess: (command, stdinPayload) async {
        capturedCommand = command;
        capturedPayload = stdinPayload;
        return GeometryWorkerProcessResult(
          exitCode: 0,
          stdout: jsonEncode(
            GeometryWorkerCapabilities.forBackend('mock').toJson(),
          ),
          stderr: '',
        );
      },
    );

    final result = await client.queryCapabilities();

    expect(capturedCommand.arguments, ['--stdio', '--capabilities']);
    expect(capturedPayload, isEmpty);
    expect(result.hasErrors, isFalse);
    expect(result.capabilities?.schema, GeometryWorkerCapabilities.schemaName);
    expect(result.capabilities?.activeBackend, 'mock');
    expect(
      result.capabilities?.backends
          .singleWhere((backend) => backend.id == 'mock')
          .supportedOperations,
      contains(GeometryOperation.previewMesh),
    );
  });

  test('process client does not duplicate capabilities argument', () async {
    late GeometryWorkerProcessCommand capturedCommand;
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(
        executable: 'worker',
        arguments: ['--capabilities'],
      ),
      runProcess: (command, stdinPayload) async {
        capturedCommand = command;
        return GeometryWorkerProcessResult(
          exitCode: 0,
          stdout: jsonEncode(
            GeometryWorkerCapabilities.forBackend('native').toJson(),
          ),
          stderr: '',
        );
      },
    );

    final result = await client.queryCapabilities();

    expect(capturedCommand.arguments, ['--capabilities']);
    expect(result.capabilities?.activeBackend, 'native');
  });

  test('process client reports invalid capabilities JSON', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      runProcess: (command, stdinPayload) async {
        return const GeometryWorkerProcessResult(
          exitCode: 0,
          stdout: '{"schema":"wrong"}',
          stderr: 'debug details',
        );
      },
    );

    final result = await client.queryCapabilities();

    expect(result.hasErrors, isTrue);
    expect(result.capabilities, isNull);
    expect(result.issues.single.code, 'worker.capabilities.invalid_json');
    expect(result.metrics['stderrSample'], 'debug details');
  });

  test('process client reports non-zero capabilities exit', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      runProcess: (command, stdinPayload) async {
        return GeometryWorkerProcessResult(
          exitCode: 9,
          stdout: jsonEncode(
            GeometryWorkerCapabilities.forBackend('native').toJson(),
          ),
          stderr: 'capability failure',
        );
      },
    );

    final result = await client.queryCapabilities();

    expect(result.hasErrors, isTrue);
    expect(result.issues.single.code, 'worker.capabilities.exit');
    expect(result.metrics['exitCode'], 9);
    expect(result.metrics['activeBackend'], 'native');
  });

  test('process client reports capability timeouts', () async {
    final client = GeometryWorkerProcessClient(
      command: const GeometryWorkerProcessCommand(executable: 'worker'),
      timeout: const Duration(milliseconds: 1),
      runProcess: (command, stdinPayload) {
        return Completer<GeometryWorkerProcessResult>().future;
      },
    );

    final result = await client.queryCapabilities();

    expect(result.hasErrors, isTrue);
    expect(result.issues.single.code, 'worker.capabilities.timeout');
    expect(result.metrics['timeoutMs'], 1);
  });
}
