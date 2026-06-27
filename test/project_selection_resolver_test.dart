import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';
import 'package:shell_case_easy_maker/selection/project_selection_resolver.dart';
import 'package:shell_case_easy_maker/selection/selection_model.dart';

void main() {
  test('describes workspace selection with project counts', () {
    final project = ProjectModel.initial();
    final details = ProjectSelectionResolver(
      project,
    ).describe(const SelectionModel.workspace());

    expect(details.title, project.projectName);
    expect(details.subtitle, 'Проект');
    expect(
      details.properties.map((property) => property.label),
      contains('Фичи'),
    );
  });

  test('describes selected surface with human label', () {
    final project = ProjectModel.initial();
    final details =
        ProjectSelectionResolver(
          project,
          surfaceLabels: const {'main_enclosure.top_lid.outer': 'Top lid'},
        ).describe(
          const SelectionModel.surface(
            id: 'main_enclosure.top_lid.outer',
            parentId: 'main_enclosure',
          ),
        );

    expect(details.title, 'Top lid');
    expect(details.subtitle, 'Грань на main_enclosure');
    expect(details.status, contains('Top lid'));
  });

  test('describes semantic feature parameters', () {
    final project = ProjectModel.initial();
    final details = ProjectSelectionResolver(
      project,
    ).describe(const SelectionModel.feature('front_usb_c'));

    expect(details.title, 'USB-C');
    expect(
      details.properties.map((property) => property.label),
      contains('width'),
    );
  });
}
