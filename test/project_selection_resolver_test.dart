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

  test('describes selected sketch entity through parent sketch', () {
    final sketch = advancedSketchWithEntities(
      const SemanticFeature(
        id: 'advanced_sketch_1',
        type: advancedSketchFeatureType,
        targetSurface: 'main_enclosure.front_wall.outer',
        operation: 'helper',
        parameters: {'name': 'Front helper sketch'},
        metadata: {'advanced': true},
      ),
      [defaultSketchRectangleEntity(id: 'rect_1')],
    );
    final project = ProjectModel.initial().replaceFeature(sketch);
    final details = ProjectSelectionResolver(project).describe(
      const SelectionModel.sketchEntity(
        id: 'rect_1',
        parentId: 'advanced_sketch_1',
      ),
    );

    expect(details.title, contains('rect_1'));
    expect(details.subtitle, contains('Front helper sketch'));
    expect(details.status, contains('rect_1'));
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Эскиз', 'Тип', 'Назначение', 'Ширина', 'Высота', 'Центр']),
    );
    expect(
      details.properties
          .singleWhere((property) => property.label == 'Назначение')
          .value,
      'Направляющий',
    );
  });

  test('describes selected circle sketch entity with diameter', () {
    final sketch = advancedSketchWithEntities(
      const SemanticFeature(
        id: 'advanced_sketch_1',
        type: advancedSketchFeatureType,
        targetSurface: 'main_enclosure.front_wall.outer',
        operation: 'helper',
        parameters: {'name': 'Front helper sketch'},
        metadata: {'advanced': true},
      ),
      [defaultSketchCircleEntity(id: 'circle_1')],
    );
    final project = ProjectModel.initial().replaceFeature(sketch);
    final details = ProjectSelectionResolver(project).describe(
      const SelectionModel.sketchEntity(
        id: 'circle_1',
        parentId: 'advanced_sketch_1',
      ),
    );

    expect(details.title, contains('Круг'));
    expect(details.title, contains('circle_1'));
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Эскиз', 'Тип', 'Диаметр', 'Центр']),
    );
  });

  test('describes selected sketch entity profile intent', () {
    final sketch = advancedSketchWithEntities(
      const SemanticFeature(
        id: 'advanced_sketch_1',
        type: advancedSketchFeatureType,
        targetSurface: 'main_enclosure.front_wall.outer',
        operation: 'helper',
        parameters: {'name': 'Front helper sketch'},
        metadata: {'advanced': true},
      ),
      [
        sketchEntityWithProfileIntent(
          defaultSketchCircleEntity(id: 'circle_1'),
          sketchProfileIntentAdd,
        ),
      ],
    );
    final project = ProjectModel.initial().replaceFeature(sketch);
    final details = ProjectSelectionResolver(project).describe(
      const SelectionModel.sketchEntity(
        id: 'circle_1',
        parentId: 'advanced_sketch_1',
      ),
    );

    expect(
      details.properties
          .singleWhere((property) => property.label == 'Назначение')
          .value,
      'Выступ',
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
        itemPrototype: {
          'diameter': 8.0,
          'ringWidth': 1.2,
          'ringProtrusion': 0.45,
          'capDiameter': 7.4,
          'capHeight': 1.2,
          'stemDiameter': 3.0,
          'stemDepth': 2.8,
          'travel': 0.8,
          'switchClearance': 0.3,
          'guideClearance': 0.25,
          'mode': 'plunger',
        },
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
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Ободок', 'Выступ']),
    );
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Колпачок', 'Высота кнопки', 'Ножка', 'Глубина ножки']),
    );
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Ход', 'Зазор до свитча', 'Зазор направл.']),
    );
  });

  test('describes standoff mount group details', () {
    final project = ProjectModel.initial().replaceFeatureGroup(
      const FeatureGroup(
        id: 'standoff_mounts_1',
        type: 'standoff_mounts',
        targetSurface: 'main_enclosure.bottom_inside',
        pattern: {'layout': 'from_component_mounting_holes', 'count': 4},
        itemPrototype: {'diameter': 5.0, 'holeDiameter': 2.2, 'height': 4.0},
      ),
    );
    final details = ProjectSelectionResolver(
      project,
    ).describe(const SelectionModel.featureGroup('standoff_mounts_1'));

    expect(details.title, 'Крепёж');
    expect(
      details.properties.map((property) => property.label),
      containsAll(['Кол-во', 'Диаметр', 'Отверстие', 'Высота']),
    );
  });
}
