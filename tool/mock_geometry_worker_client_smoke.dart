import 'dart:convert';
import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

Future<void> main(List<String> args) async {
  final client = GeometryWorkerProcessClient(
    command: GeometryWorkerProcessCommand(
      executable: Platform.resolvedExecutable,
      arguments: const ['run', 'occt_worker/bin/occt_worker.dart'],
      workingDirectory: Directory.current.path,
    ),
  );
  final response = await client.buildGeometry(
    GeometryRequest.previewMesh(
      ProjectModel.initial(),
      requestId: 'mock_worker_process_smoke',
    ),
  );

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(response.toJson()));
  if (response.hasErrors) {
    exitCode = 2;
  }
}
