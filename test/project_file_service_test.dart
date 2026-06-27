import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('encodes and decodes project JSON', () {
    const service = ProjectFileService();
    final project = ProjectModel.initial();
    final decoded = service.decode(service.encode(project));

    expect(decoded.projectName, project.projectName);
    expect(decoded.bodies.single.id, project.bodies.single.id);
    expect(
      decoded.features.map((feature) => feature.id),
      contains('front_usb_c'),
    );
  });

  test('writes and reads project file from disk', () async {
    const service = ProjectFileService();
    final directory = await Directory.systemTemp.createTemp('case_maker_test_');
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final file = File('${directory.path}/project.enclosure.json');
    await service.writeProject(file, ProjectModel.initial());
    final decoded = await service.readProject(file);

    expect(file.existsSync(), isTrue);
    expect(decoded.componentTemplates.single.id, 'custom_button_board_v1');
  });

  test('rejects non-object project files', () {
    const service = ProjectFileService();

    expect(() => service.decode('[]'), throwsA(isA<FormatException>()));
  });

  test('project dialog helper preserves or adds project extension', () {
    expect(
      ensureProjectFileExtension(File('case.enclosure.json')).path,
      'case.enclosure.json',
    );
    expect(ensureProjectFileExtension(File('case.json')).path, 'case.json');
    expect(
      ensureProjectFileExtension(File('case')).path,
      'case.enclosure.json',
    );
  });
}
