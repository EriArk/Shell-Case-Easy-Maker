import 'dart:convert';
import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

Future<void> main(List<String> args) async {
  final options = _SmokeOptions.fromArgs(args);
  final repoRoot = Directory.current.absolute.path;

  if (!options.skipBuild) {
    final buildResult = await _buildNativeStub(repoRoot, options.configuration);
    if (buildResult.exitCode != 0) {
      stderr.writeln(buildResult.stdout);
      stderr.writeln(buildResult.stderr);
      stderr.writeln('Native worker stub build failed.');
      exitCode = buildResult.exitCode;
      return;
    }
  }

  final executable = _nativeStubExecutablePath(repoRoot, options.configuration);
  if (!File(executable).existsSync()) {
    stderr.writeln('Native worker stub executable not found: $executable');
    stderr.writeln(
      'Run tools/build_occt_worker_stub.ps1 or omit --skip-build.',
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
  const smokeRequestId = 'native_worker_stub_smoke';
  final response = await client.buildGeometry(
    GeometryRequest.previewMesh(
      ProjectModel.initial(),
      requestId: smokeRequestId,
    ),
  );
  final requestIdPreserved = response.requestId == smokeRequestId;
  final expectedNativeStub =
      requestIdPreserved &&
      response.hasErrors &&
      response.backend == 'occt_worker_native_stub' &&
      response.issues.any(
        (issue) => issue.code == 'worker.backend.native_not_implemented',
      );

  final summary = {
    'executable': executable,
    'capabilities': {
      'ok': !capabilities.hasErrors,
      'activeBackend': capabilities.capabilities?.activeBackend,
      'backends': [
        for (final backend
            in capabilities.capabilities?.backends ??
                const <GeometryWorkerBackendCapability>[])
          {'id': backend.id, 'status': backend.status},
      ],
      if (capabilities.issues.isNotEmpty)
        'issues': [for (final issue in capabilities.issues) issue.toJson()],
    },
    'requestSmoke': {
      'expectedNotImplemented': expectedNativeStub,
      'requestId': response.requestId,
      'requestIdPreserved': requestIdPreserved,
      'status': response.status.wireName,
      'backend': response.backend,
      'issues': [for (final issue in response.issues) issue.toJson()],
    },
  };

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(summary));
  if (capabilities.hasErrors || !expectedNativeStub) {
    exitCode = 2;
  }
}

Future<ProcessResult> _buildNativeStub(String repoRoot, String configuration) {
  return Process.run('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    _joinPath(repoRoot, ['tools', 'build_occt_worker_stub.ps1']),
    '-Configuration',
    configuration,
  ]);
}

String _nativeStubExecutablePath(String repoRoot, String configuration) {
  return _joinPath(repoRoot, [
    'build',
    'occt_worker_native',
    configuration,
    'occt_worker_native_stub.exe',
  ]);
}

String _joinPath(String root, List<String> parts) {
  return [root, ...parts].join(Platform.pathSeparator);
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

      throw FormatException('Unknown native worker smoke argument "$arg".');
    }

    if (configuration != 'Debug' && configuration != 'Release') {
      throw FormatException(
        'Unsupported configuration "$configuration". Use Debug or Release.',
      );
    }

    return _SmokeOptions(configuration: configuration, skipBuild: skipBuild);
  }
}
