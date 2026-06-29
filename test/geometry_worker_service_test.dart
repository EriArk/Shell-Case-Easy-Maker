import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test(
    'worker geometry service builds geometry through process client',
    () async {
      late GeometryRequest sentRequest;
      final service = WorkerGeometryService(
        workerClient: GeometryWorkerProcessClient(
          command: const GeometryWorkerProcessCommand(executable: 'worker'),
          runProcess: (command, stdinPayload) async {
            sentRequest = GeometryRequest.fromJson(
              jsonDecode(stdinPayload) as Map<String, Object?>,
            );
            return GeometryWorkerProcessResult(
              exitCode: 0,
              stderr: '',
              stdout: jsonEncode(
                const GeometryResponse(
                  requestId: 'worker_build',
                  status: GeometryResponseStatus.ok,
                  backend: 'fake_worker',
                ).toJson(),
              ),
            );
          },
        ),
      );
      final request = GeometryRequest.previewMesh(
        ProjectModel.initial(),
        requestId: 'worker_build',
      );

      final response = await service.buildGeometry(request);

      expect(sentRequest.requestId, 'worker_build');
      expect(sentRequest.featureIntents, hasLength(2));
      expect(response.status, GeometryResponseStatus.ok);
      expect(response.backend, 'fake_worker');
    },
  );

  test(
    'worker geometry service exposes preview stats from worker response',
    () async {
      final service = WorkerGeometryService(
        workerClient: GeometryWorkerProcessClient(
          command: const GeometryWorkerProcessCommand(executable: 'worker'),
          runProcess: (command, stdinPayload) async {
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
                  previewMesh: const PreviewMesh(
                    units: 'mm',
                    vertices: [0, 0, 0, 1, 0, 0, 0, 1, 0],
                    triangles: [0, 1, 2],
                    bounds: GeometryBounds(min: [0, 0, 0], max: [1, 1, 0]),
                    surfaces: [],
                  ),
                  metrics: const {'operationCount': 2},
                ).toJson(),
              ),
            );
          },
        ),
      );

      final preview = await service.generatePreview(ProjectModel.initial());

      expect(preview.backendLabel, 'fake_worker');
      expect(preview.stats['source'], 'worker_process');
      expect(preview.stats['responseStatus'], 'ok');
      expect(preview.stats['previewVertices'], 3);
      expect(preview.stats['previewTriangles'], 1);
      expect(preview.stats['featureIntents'], 2);
      expect(preview.stats['operationCount'], 2);
      expect(
        preview.surfaces.map((surface) => surface.id),
        contains('main_enclosure.front_wall.outer'),
      );
    },
  );

  test(
    'worker geometry service reports process issues in preview stats',
    () async {
      final service = WorkerGeometryService(
        workerClient: GeometryWorkerProcessClient(
          command: const GeometryWorkerProcessCommand(executable: 'worker'),
          runProcess: (command, stdinPayload) async {
            final request = GeometryRequest.fromJson(
              jsonDecode(stdinPayload) as Map<String, Object?>,
            );
            return GeometryWorkerProcessResult(
              exitCode: 2,
              stderr: '',
              stdout: jsonEncode(
                GeometryResponse(
                  requestId: request.requestId,
                  status: GeometryResponseStatus.error,
                  backend: 'fake_worker',
                  issues: const [
                    GeometryIssue(
                      severity: GeometryIssueSeverity.error,
                      code: 'fake.worker.failed',
                      message: 'Worker failed.',
                    ),
                  ],
                ).toJson(),
              ),
            );
          },
        ),
      );

      final preview = await service.generatePreview(ProjectModel.initial());

      expect(preview.backendLabel, 'fake_worker');
      expect(preview.stats['responseStatus'], 'error');
      expect(preview.stats['previewVertices'], 0);
      expect(preview.stats['issueCount'], 1);
    },
  );

  test('worker geometry service keeps semantic validation local', () async {
    final initial = ProjectModel.initial();
    final project = initial.replaceEnclosure(
      initial.bodies.single.copyWith(wallThickness: 0.4),
    );
    final service = WorkerGeometryService(
      workerClient: GeometryWorkerProcessClient(
        command: const GeometryWorkerProcessCommand(executable: 'worker'),
        runProcess: (command, stdinPayload) async {
          throw StateError('build geometry should not run for validation');
        },
      ),
    );

    final report = await service.validateGeometry(project);

    expect(report.hasWarnings, isTrue);
    expect(
      report.messages.map((message) => message.code),
      contains('enclosure.wall.thin'),
    );
  });
}
