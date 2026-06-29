import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_backend.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';

void main() {
  test('geometry backend defaults to mock service', () {
    final service = createGeometryService(const GeometryBackendSettings());

    expect(service, isA<MockGeometryService>());
  });

  test(
    'geometry backend creates worker service when executable is explicit',
    () {
      final service = createGeometryService(
        const GeometryBackendSettings(
          backend: GeometryBackendKind.worker,
          workerExecutable: 'worker',
          workerArguments: ['--stdio'],
          workerWorkingDirectory: 'build/worker',
          workerTimeout: Duration(seconds: 2),
        ),
      );

      expect(service, isA<WorkerGeometryService>());
      final workerService = service as WorkerGeometryService;
      expect(workerService.workerClient.command.executable, 'worker');
      expect(workerService.workerClient.command.arguments, ['--stdio']);
      expect(
        workerService.workerClient.command.workingDirectory,
        'build/worker',
      );
      expect(workerService.workerClient.timeout, const Duration(seconds: 2));
    },
  );

  test(
    'geometry backend falls back to mock when worker executable is missing',
    () {
      final service = createGeometryService(
        const GeometryBackendSettings(backend: GeometryBackendKind.worker),
      );

      expect(service, isA<MockGeometryService>());
    },
  );

  test('geometry worker arguments parse pipe-separated dart defines', () {
    expect(
      parseGeometryWorkerArguments('run|tool/mock_geometry_worker.dart|--flag'),
      ['run', 'tool/mock_geometry_worker.dart', '--flag'],
    );
    expect(parseGeometryWorkerArguments('  | run |  | worker.exe  '), [
      'run',
      'worker.exe',
    ]);
  });
}
