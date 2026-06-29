import 'dart:io';

import 'geometry_service.dart';

enum GeometryBackendKind {
  mock('mock'),
  worker('worker'),
  nativeOcct('native_occt');

  const GeometryBackendKind(this.wireName);

  final String wireName;

  static GeometryBackendKind fromWireName(String value) {
    return GeometryBackendKind.values.firstWhere(
      (kind) => kind.wireName == value.trim(),
      orElse: () => GeometryBackendKind.mock,
    );
  }
}

class GeometryBackendSettings {
  const GeometryBackendSettings({
    this.backend = GeometryBackendKind.mock,
    this.workerExecutable = '',
    this.workerArguments = const [],
    this.workerWorkingDirectory,
    this.workerTimeout = const Duration(seconds: 30),
  });

  factory GeometryBackendSettings.fromCompileTimeEnvironment() {
    const backend = String.fromEnvironment(
      'SHELL_CASE_GEOMETRY_BACKEND',
      defaultValue: 'mock',
    );
    const workerExecutable = String.fromEnvironment(
      'SHELL_CASE_GEOMETRY_WORKER_EXECUTABLE',
    );
    const workerArguments = String.fromEnvironment(
      'SHELL_CASE_GEOMETRY_WORKER_ARGUMENTS',
    );
    const workerWorkingDirectory = String.fromEnvironment(
      'SHELL_CASE_GEOMETRY_WORKER_WORKING_DIRECTORY',
    );
    const workerTimeoutMs = int.fromEnvironment(
      'SHELL_CASE_GEOMETRY_WORKER_TIMEOUT_MS',
      defaultValue: 30000,
    );

    return GeometryBackendSettings(
      backend: GeometryBackendKind.fromWireName(backend),
      workerExecutable: workerExecutable,
      workerArguments: parseGeometryWorkerArguments(workerArguments),
      workerWorkingDirectory: workerWorkingDirectory.trim().isEmpty
          ? null
          : workerWorkingDirectory,
      workerTimeout: Duration(milliseconds: workerTimeoutMs),
    );
  }

  final GeometryBackendKind backend;
  final String workerExecutable;
  final List<String> workerArguments;
  final String? workerWorkingDirectory;
  final Duration workerTimeout;

  bool get canUseWorker =>
      backend == GeometryBackendKind.worker &&
      workerExecutable.trim().isNotEmpty;

  bool get canUseExplicitNativeOcctWorker =>
      backend == GeometryBackendKind.nativeOcct &&
      workerExecutable.trim().isNotEmpty;
}

GeometryService createGeometryServiceFromEnvironment() {
  return createGeometryService(
    GeometryBackendSettings.fromCompileTimeEnvironment(),
  );
}

GeometryService createGeometryService(
  GeometryBackendSettings settings, {
  String Function() nativeOcctWorkerExecutablePath =
      defaultNativeOcctWorkerExecutablePath,
  bool Function(String path) fileExists = _fileExists,
}) {
  if (settings.canUseWorker) {
    return WorkerGeometryService(
      workerClient: GeometryWorkerProcessClient(
        command: GeometryWorkerProcessCommand(
          executable: settings.workerExecutable,
          arguments: settings.workerArguments,
          workingDirectory: settings.workerWorkingDirectory,
        ),
        timeout: settings.workerTimeout,
      ),
    );
  }

  if (settings.backend == GeometryBackendKind.nativeOcct) {
    final explicitExecutable = settings.workerExecutable.trim();
    final executable = explicitExecutable.isNotEmpty
        ? explicitExecutable
        : nativeOcctWorkerExecutablePath();
    final canUseNativeWorker =
        explicitExecutable.isNotEmpty || fileExists(executable);

    if (canUseNativeWorker) {
      return WorkerGeometryService(
        workerClient: GeometryWorkerProcessClient(
          command: GeometryWorkerProcessCommand(
            executable: executable,
            arguments: settings.workerArguments,
            workingDirectory:
                settings.workerWorkingDirectory ?? _parentDirectory(executable),
          ),
          timeout: settings.workerTimeout,
        ),
      );
    }
  }

  return const MockGeometryService();
}

String defaultNativeOcctWorkerExecutablePath() {
  return _joinPath(File(Platform.resolvedExecutable).parent.path, const [
    'occt_worker',
    'native',
    'occt_worker_native_occt.exe',
  ]);
}

List<String> parseGeometryWorkerArguments(String rawValue) {
  return rawValue
      .split('|')
      .map((argument) => argument.trim())
      .where((argument) => argument.isNotEmpty)
      .toList(growable: false);
}

bool _fileExists(String path) => File(path).existsSync();

String _parentDirectory(String path) => File(path).parent.path;

String _joinPath(String root, List<String> parts) {
  return [root, ...parts].join(Platform.pathSeparator);
}
