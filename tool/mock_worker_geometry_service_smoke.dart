import 'dart:convert';
import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

Future<void> main(List<String> args) async {
  final service = WorkerGeometryService(
    workerClient: GeometryWorkerProcessClient(
      command: GeometryWorkerProcessCommand(
        executable: Platform.resolvedExecutable,
        arguments: const ['run', 'tool/mock_geometry_worker.dart'],
        workingDirectory: Directory.current.path,
      ),
    ),
  );
  final preview = await service.generatePreview(ProjectModel.initial());

  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'backendLabel': preview.backendLabel,
      'projectName': preview.projectName,
      'surfaceCount': preview.surfaces.length,
      'stats': preview.stats,
    }),
  );
  if (preview.stats['responseStatus'] != GeometryResponseStatus.ok.wireName) {
    exitCode = 2;
  }
}
