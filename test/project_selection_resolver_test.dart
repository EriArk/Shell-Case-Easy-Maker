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

  test('describes glass recess with human label', () {
    final project = ProjectModel.initial().replaceFeature(
      const SemanticFeature(
        id: 'glass_recess_1',
        type: 'glass_recess',
        targetSurface: 'main_enclosure.top_lid.outer',
        operation: 'recess',
        parameters: {'width': 50.0},
      ),
    );
    final details = ProjectSelectionResolver(
      project,
    ).describe(const SelectionModel.feature('glass_recess_1'));

    expect(details.title, 'Посадка под стекло');
    expect(
      details.properties.map((property) => property.label),
      contains('width'),
    );
  });

  test('describes feature group pattern details', () {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'button_group_1',
        type: 'button_group',
        targetSurface: 'main_enclosure.top_lid.outer',
        pattern: {'layout': 'diamond', 'count': 4, 'spacing': 14.0},
        itemPrototype: {'diameter': 8.0, 'mode': 'plunger'},
      ),
    );
    final details = ProjectSelectionResolver(
      project,
    ).describe(const SelectionModel.featureGroup('button_group_1'));

    expect(details.title, 'Группа кнопок');
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Раскладка', 'Кол-во', 'Диаметр']),
    );
  });
}
