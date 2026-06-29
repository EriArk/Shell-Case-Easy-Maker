import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../project/json_helpers.dart';
import 'geometry_protocol.dart';
import 'geometry_worker_capabilities.dart';

typedef GeometryWorkerProcessRunner =
    Future<GeometryWorkerProcessResult> Function(
      GeometryWorkerProcessCommand command,
      String stdinPayload,
    );

class GeometryWorkerProcessCommand {
  const GeometryWorkerProcessCommand({
    required this.executable,
    this.arguments = const [],
    this.workingDirectory,
    this.environment = const {},
    this.includeParentEnvironment = true,
    this.runInShell = false,
  });

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String> environment;
  final bool includeParentEnvironment;
  final bool runInShell;

  GeometryWorkerProcessCommand copyWith({
    String? executable,
    List<String>? arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool? includeParentEnvironment,
    bool? runInShell,
  }) {
    return GeometryWorkerProcessCommand(
      executable: executable ?? this.executable,
      arguments: arguments ?? this.arguments,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      environment: environment ?? this.environment,
      includeParentEnvironment:
          includeParentEnvironment ?? this.includeParentEnvironment,
      runInShell: runInShell ?? this.runInShell,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'executable': executable,
      if (arguments.isNotEmpty) 'arguments': arguments,
      if (workingDirectory != null) 'workingDirectory': workingDirectory,
      if (environment.isNotEmpty) 'environmentKeys': environment.keys.toList(),
      'includeParentEnvironment': includeParentEnvironment,
      'runInShell': runInShell,
    };
  }
}

class GeometryWorkerProcessResult {
  const GeometryWorkerProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

class GeometryWorkerCapabilitiesResult {
  const GeometryWorkerCapabilitiesResult({
    this.capabilities,
    this.issues = const [],
    this.metrics = const {},
  });

  final GeometryWorkerCapabilities? capabilities;
  final List<GeometryIssue> issues;
  final Map<String, Object?> metrics;

  bool get hasErrors =>
      capabilities == null ||
      issues.any((issue) => issue.severity == GeometryIssueSeverity.error);
}

class GeometryWorkerProcessClient {
  const GeometryWorkerProcessClient({
    required this.command,
    this.timeout = const Duration(seconds: 30),
    this.runProcess = runGeometryWorkerProcess,
  });

  final GeometryWorkerProcessCommand command;
  final Duration? timeout;
  final GeometryWorkerProcessRunner runProcess;

  Future<GeometryWorkerCapabilitiesResult> queryCapabilities() async {
    final capabilityCommand = _capabilityCommand();
    final GeometryWorkerProcessResult result;

    try {
      final processFuture = runProcess(capabilityCommand, '');
      result = timeout == null
          ? await processFuture
          : await processFuture.timeout(timeout!);
    } on TimeoutException {
      return _capabilityError(
        code: 'worker.capabilities.timeout',
        message:
            'Geometry worker did not report capabilities before the timeout.',
        metrics: {
          'command': capabilityCommand.toJson(),
          'timeoutMs': timeoutMillis,
        },
      );
    } on Object catch (error) {
      return _capabilityError(
        code: 'worker.capabilities.failed',
        message: 'Geometry worker failed before reporting capabilities.',
        metrics: {
          'command': capabilityCommand.toJson(),
          'error': error.toString(),
        },
      );
    }

    final capabilities = _decodeCapabilities(result);
    if (capabilities == null) {
      return _capabilityError(
        code: 'worker.capabilities.invalid_json',
        message:
            'Geometry worker capabilities output is not valid capability JSON.',
        metrics: {
          'command': capabilityCommand.toJson(),
          'exitCode': result.exitCode,
          if (result.stdout.isNotEmpty) 'stdoutSample': _sample(result.stdout),
          if (result.stderr.isNotEmpty) 'stderrSample': _sample(result.stderr),
        },
      );
    }

    if (result.exitCode != 0) {
      return _capabilityError(
        code: 'worker.capabilities.exit',
        message:
            'Geometry worker exited with code ${result.exitCode} while reporting capabilities.',
        metrics: {
          'command': capabilityCommand.toJson(),
          'exitCode': result.exitCode,
          'activeBackend': capabilities.activeBackend,
          if (result.stderr.isNotEmpty) 'stderrSample': _sample(result.stderr),
        },
      );
    }

    return GeometryWorkerCapabilitiesResult(capabilities: capabilities);
  }

  Future<GeometryResponse> buildGeometry(GeometryRequest request) async {
    final payload = const JsonEncoder.withIndent(
      '  ',
    ).convert(request.toJson());
    final GeometryWorkerProcessResult result;

    try {
      final processFuture = runProcess(command, payload);
      result = timeout == null
          ? await processFuture
          : await processFuture.timeout(timeout!);
    } on TimeoutException {
      return _errorResponse(
        request,
        code: 'worker.process.timeout',
        message: 'Geometry worker did not respond before the timeout.',
        metrics: {'command': command.toJson(), 'timeoutMs': timeoutMillis},
      );
    } on Object catch (error) {
      return _errorResponse(
        request,
        code: 'worker.process.failed',
        message: 'Geometry worker process failed before returning a response.',
        metrics: {'command': command.toJson(), 'error': error.toString()},
      );
    }

    final response = _decodeResponse(result);
    if (response == null) {
      return _errorResponse(
        request,
        code: 'worker.response.invalid_json',
        message: 'Geometry worker response is not valid response JSON.',
        metrics: {
          'command': command.toJson(),
          'exitCode': result.exitCode,
          if (result.stdout.isNotEmpty) 'stdoutSample': _sample(result.stdout),
          if (result.stderr.isNotEmpty) 'stderrSample': _sample(result.stderr),
        },
      );
    }

    if (result.exitCode != 0 && !response.hasErrors) {
      return _errorResponse(
        request,
        code: 'worker.process.exit',
        message:
            'Geometry worker exited with code ${result.exitCode} without an error response.',
        metrics: {
          'command': command.toJson(),
          'exitCode': result.exitCode,
          'workerStatus': response.status.wireName,
          if (result.stderr.isNotEmpty) 'stderrSample': _sample(result.stderr),
        },
      );
    }

    return response;
  }

  int? get timeoutMillis => timeout?.inMilliseconds;

  GeometryWorkerProcessCommand _capabilityCommand() {
    final hasCapabilityArg = command.arguments.contains('--capabilities');
    return command.copyWith(
      arguments: hasCapabilityArg
          ? command.arguments
          : [...command.arguments, '--capabilities'],
    );
  }

  GeometryWorkerCapabilities? _decodeCapabilities(
    GeometryWorkerProcessResult result,
  ) {
    Object? decoded;
    try {
      decoded = jsonDecode(result.stdout);
    } on FormatException {
      return null;
    }

    if (decoded is! Map<Object?, Object?>) {
      return null;
    }

    final json = readJsonMap(decoded);
    if (json['schema'] != GeometryWorkerCapabilities.schemaName) {
      return null;
    }

    try {
      return GeometryWorkerCapabilities.fromJson(json);
    } on Object {
      return null;
    }
  }

  GeometryResponse? _decodeResponse(GeometryWorkerProcessResult result) {
    Object? decoded;
    try {
      decoded = jsonDecode(result.stdout);
    } on FormatException {
      return null;
    }

    if (decoded is! Map<Object?, Object?>) {
      return null;
    }

    try {
      return GeometryResponse.fromJson(readJsonMap(decoded));
    } on Object {
      return null;
    }
  }

  GeometryResponse _errorResponse(
    GeometryRequest request, {
    required String code,
    required String message,
    Map<String, Object?> metrics = const {},
  }) {
    return GeometryResponse(
      requestId: request.requestId,
      status: GeometryResponseStatus.error,
      backend: 'worker_process',
      issues: [
        GeometryIssue(
          severity: GeometryIssueSeverity.error,
          code: code,
          message: message,
        ),
      ],
      metrics: metrics,
    );
  }

  GeometryWorkerCapabilitiesResult _capabilityError({
    required String code,
    required String message,
    Map<String, Object?> metrics = const {},
  }) {
    return GeometryWorkerCapabilitiesResult(
      issues: [
        GeometryIssue(
          severity: GeometryIssueSeverity.error,
          code: code,
          message: message,
        ),
      ],
      metrics: metrics,
    );
  }
}

Future<GeometryWorkerProcessResult> runGeometryWorkerProcess(
  GeometryWorkerProcessCommand command,
  String stdinPayload,
) async {
  final process = await Process.start(
    command.executable,
    command.arguments,
    workingDirectory: command.workingDirectory,
    environment: command.environment.isEmpty ? null : command.environment,
    includeParentEnvironment: command.includeParentEnvironment,
    runInShell: command.runInShell,
  );
  final stdoutFuture = process.stdout.transform(utf8.decoder).join();
  final stderrFuture = process.stderr.transform(utf8.decoder).join();

  process.stdin.write(stdinPayload);
  await process.stdin.close();

  final exitCode = await process.exitCode;
  return GeometryWorkerProcessResult(
    exitCode: exitCode,
    stdout: await stdoutFuture,
    stderr: await stderrFuture,
  );
}

String _sample(String value) {
  const maxLength = 500;
  final trimmed = value.trim();
  if (trimmed.length <= maxLength) {
    return trimmed;
  }

  return '${trimmed.substring(0, maxLength)}...';
}
