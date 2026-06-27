import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/parameters/enclosure_parameter_adapter.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('reads enclosure values through rounded enclosure schema', () {
    final enclosure = ProjectModel.initial().bodies.single;
    final values = EnclosureParameterAdapter.valuesFrom(enclosure);

    expect(values['width'], 120);
    expect(values['depth'], 70);
    expect(values['height'], 28);
    expect(values['wallThickness'], 2);
    expect(values['cornerRadius'], 4);
    expect(values['lidType'], 'top_screw_lid');
  });

  test('updates one parameter without flattening semantic enclosure', () {
    final project = ProjectModel.initial();
    final enclosure = project.bodies.single;
    final updated = EnclosureParameterAdapter.updateParameter(
      enclosure,
      'width',
      154.4,
    );

    expect(updated.id, enclosure.id);
    expect(updated.shape, 'rounded_box');
    expect(updated.size, [154, 70, 28]);
    expect(updated.wallThickness, 2);
    expect(updated.lid?.type, 'top_screw_lid');
  });

  test('lid type none removes lid spec semantically', () {
    final enclosure = ProjectModel.initial().bodies.single;
    final updated = EnclosureParameterAdapter.updateParameter(
      enclosure,
      'lidType',
      'none',
    );

    expect(updated.lid, isNull);
  });

  test('project replaces enclosure by stable id', () {
    final project = ProjectModel.initial();
    final updatedBody = project.bodies.single.copyWith(
      size: const [150, 80, 32],
    );
    final updatedProject = project.replaceEnclosure(updatedBody);

    expect(updatedProject.bodies, hasLength(1));
    expect(updatedProject.bodies.single.id, 'main_enclosure');
    expect(updatedProject.bodies.single.size, [150, 80, 32]);
    expect(updatedProject.features, project.features);
  });
}
