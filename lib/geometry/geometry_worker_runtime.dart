import 'dart:convert';
import 'dart:io';

import 'geometry_service.dart';

enum GeometryWorkerRuntimeBackend {
  mock('mock'),
  native('native');

  const GeometryWorkerRuntimeBackend(this.wireName);

  final String wireName;

  static GeometryWorkerRuntimeBackend fromWireName(String value) {
    for (final backend in values) {
      if (backend.wireName == value) {
        return backend;
      }
    }

    throw FormatException(
      'Unsupported geometry worker backend "$value". Supported backends: '
      '${values.map((backend) => backend.wireName).join(', ')}.',
    );
  }
}

class GeometryWorkerRuntimeSettings {
  const GeometryWorkerRuntimeSettings({
    this.backend = GeometryWorkerRuntimeBackend.mock,
  });

  factory GeometryWorkerRuntimeSettings.fromArgs(List<String> args) {
    var backend = GeometryWorkerRuntimeBackend.mock;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg.startsWith('--backend=')) {
        backend = GeometryWorkerRuntimeBackend.fromWireName(
          arg.substring('--backend='.length),
        );
        continue;
      }

      if (arg == '--backend') {
        final valueIndex = index + 1;
        if (valueIndex >= args.length) {
          throw const FormatException(
            'Missing value after --backend. Supported backends: mock, native.',
          );
        }
        backend = GeometryWorkerRuntimeBackend.fromWireName(args[valueIndex]);
        index = valueIndex;
        continue;
      }

      throw FormatException('Unknown geometry worker argument "$arg".');
    }

    return GeometryWorkerRuntimeSettings(backend: backend);
  }

  final GeometryWorkerRuntimeBackend backend;
}

class GeometryWorkerRunResult {
  const GeometryWorkerRunResult({
    required this.response,
    required this.responseJson,
    required this.exitCode,
  });

  factory GeometryWorkerRunResult.fromResponse(GeometryResponse response) {
    return GeometryWorkerRunResult(
      response: response,
      responseJson: const JsonEncoder.withIndent(
        '  ',
      ).convert(response.toJson()),
      exitCode: response.hasErrors ? 2 : 0,
    );
  }

  factory GeometryWorkerRunResult.invalidConfiguration(String message) {
    return GeometryWorkerRunResult.fromResponse(
      GeometryResponse(
        requestId: 'invalid_request',
        status: GeometryResponseStatus.error,
        backend: 'geometry_worker_cli',
        issues: [
          GeometryIssue(
            severity: GeometryIssueSeverity.error,
            code: 'worker.cli.invalid_arguments',
            message: message,
          ),
        ],
      ),
    );
  }

  final GeometryResponse response;
  final String responseJson;
  final int exitCode;
}

class GeometryWorkerRuntime {
  const GeometryWorkerRuntime({
    this.settings = const GeometryWorkerRuntimeSettings(),
  });

  final GeometryWorkerRuntimeSettings settings;

  Future<GeometryWorkerRunResult> handlePayload(String payload) async {
    final handler = GeometryWorkerProtocolHandler(
      buildGeometry: _buildGeometry,
    );
    final response = await handler.handleJson(payload);
    return GeometryWorkerRunResult.fromResponse(response);
  }

  Future<GeometryResponse> _buildGeometry(GeometryRequest request) {
    return switch (settings.backend) {
      GeometryWorkerRuntimeBackend.mock =>
        const MockGeometryService().buildGeometry(request),
      GeometryWorkerRuntimeBackend.native => _nativeUnavailable(request),
    };
  }

  Future<GeometryResponse> _nativeUnavailable(GeometryRequest request) async {
    return GeometryResponse(
      requestId: request.requestId,
      status: GeometryResponseStatus.error,
      backend: 'occt_worker_stub',
      issues: const [
        GeometryIssue(
          severity: GeometryIssueSeverity.error,
          code: 'worker.backend.native_not_implemented',
          message:
              'The native OCCT backend is not implemented in this worker yet.',
        ),
      ],
      metrics: const {'requestedBackend': 'native'},
    );
  }
}

Future<void> runGeometryWorkerStdio(List<String> args) async {
  final GeometryWorkerRuntime runtime;
  try {
    runtime = GeometryWorkerRuntime(
      settings: GeometryWorkerRuntimeSettings.fromArgs(args),
    );
  } on FormatException catch (error) {
    final result = GeometryWorkerRunResult.invalidConfiguration(error.message);
    stdout.writeln(result.responseJson);
    exitCode = result.exitCode;
    return;
  }

  final payload = await stdin.transform(utf8.decoder).join();
  final result = await runtime.handlePayload(payload);
  stdout.writeln(result.responseJson);
  exitCode = result.exitCode;
}
