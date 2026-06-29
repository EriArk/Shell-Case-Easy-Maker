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
    this.emitCapabilities = false,
  });

  factory GeometryWorkerRuntimeSettings.fromArgs(List<String> args) {
    var backend = GeometryWorkerRuntimeBackend.mock;
    var emitCapabilities = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--capabilities') {
        emitCapabilities = true;
        continue;
      }

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

    return GeometryWorkerRuntimeSettings(
      backend: backend,
      emitCapabilities: emitCapabilities,
    );
  }

  final GeometryWorkerRuntimeBackend backend;
  final bool emitCapabilities;
}

class GeometryWorkerCapabilities {
  const GeometryWorkerCapabilities({
    required this.entrypoint,
    required this.activeBackend,
    required this.backends,
  });

  static const schema = 'shell_case.geometry.worker.capabilities';
  static const currentVersion = 1;

  factory GeometryWorkerCapabilities.forSettings(
    GeometryWorkerRuntimeSettings settings,
  ) {
    return GeometryWorkerCapabilities(
      entrypoint: 'occt_worker/bin/occt_worker.dart',
      activeBackend: settings.backend.wireName,
      backends: const [
        GeometryWorkerBackendCapability(
          id: 'mock',
          status: 'available',
          supportedOperations: [GeometryOperation.previewMesh],
          notes: [
            'Uses Dart MockGeometryService.',
            'Produces deterministic preview mesh only.',
            'Does not generate B-Rep, STEP, STL, or OCCT topology.',
          ],
        ),
        GeometryWorkerBackendCapability(
          id: 'native',
          status: 'stub',
          plannedOperations: [
            GeometryOperation.previewMesh,
            GeometryOperation.exportStep,
            GeometryOperation.exportStl,
            GeometryOperation.validate,
          ],
          issueCodes: ['worker.backend.native_not_implemented'],
          notes: [
            'Reserved for the future OCCT implementation.',
            'Currently returns a structured not-implemented response.',
          ],
        ),
      ],
    );
  }

  final String entrypoint;
  final String activeBackend;
  final List<GeometryWorkerBackendCapability> backends;

  String get prettyJson {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': currentVersion,
      'entrypoint': entrypoint,
      'defaultBackend': GeometryWorkerRuntimeBackend.mock.wireName,
      'activeBackend': activeBackend,
      'protocol': {
        'requestSchema': GeometryProtocol.requestSchema,
        'responseSchema': GeometryProtocol.responseSchema,
        'version': GeometryProtocol.currentVersion,
      },
      'sourceOfTruth': 'semantic_project',
      'editableGeneratedGeometry': false,
      'backends': [for (final backend in backends) backend.toJson()],
    };
  }
}

class GeometryWorkerBackendCapability {
  const GeometryWorkerBackendCapability({
    required this.id,
    required this.status,
    this.supportedOperations = const [],
    this.plannedOperations = const [],
    this.issueCodes = const [],
    this.notes = const [],
  });

  final String id;
  final String status;
  final List<GeometryOperation> supportedOperations;
  final List<GeometryOperation> plannedOperations;
  final List<String> issueCodes;
  final List<String> notes;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'status': status,
      'supportedOperations': [
        for (final operation in supportedOperations) operation.wireName,
      ],
      if (plannedOperations.isNotEmpty)
        'plannedOperations': [
          for (final operation in plannedOperations) operation.wireName,
        ],
      if (issueCodes.isNotEmpty) 'issueCodes': issueCodes,
      if (notes.isNotEmpty) 'notes': notes,
    };
  }
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

  GeometryWorkerCapabilities capabilities() {
    return GeometryWorkerCapabilities.forSettings(settings);
  }

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

  if (runtime.settings.emitCapabilities) {
    stdout.writeln(runtime.capabilities().prettyJson);
    exitCode = 0;
    return;
  }

  final payload = await stdin.transform(utf8.decoder).join();
  final result = await runtime.handlePayload(payload);
  stdout.writeln(result.responseJson);
  exitCode = result.exitCode;
}
