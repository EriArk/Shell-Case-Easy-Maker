import '../project/project_model.dart';
import 'selection_model.dart';

class ProjectSelectionResolver {
  const ProjectSelectionResolver(this.project, {this.surfaceLabels = const {}});

  final ProjectModel project;
  final Map<String, String> surfaceLabels;

  ProjectSelectionDetails describe(SelectionModel selection) {
    return switch (selection.kind) {
      SelectionKind.workspace => _workspaceDetails(),
      SelectionKind.enclosure => _enclosureDetails(selection.id),
      SelectionKind.surface => _surfaceDetails(
        selection.id,
        selection.parentId,
      ),
      SelectionKind.componentPlacement => _componentPlacementDetails(
        selection.id,
      ),
      SelectionKind.componentTemplate => _componentTemplateDetails(
        selection.id,
      ),
      SelectionKind.feature => _featureDetails(selection.id),
      SelectionKind.featureGroup => _featureGroupDetails(selection.id),
    };
  }

  ProjectSelectionDetails _workspaceDetails() {
    return ProjectSelectionDetails(
      title: project.projectName,
      subtitle: 'Проект',
      iconKey: 'project',
      status: 'Выбран проект: ${project.projectName}',
      properties: [
        ProjectSelectionProperty(label: 'Единицы', value: project.units),
        ProjectSelectionProperty(
          label: 'Профиль',
          value: project.printerProfile,
        ),
        ProjectSelectionProperty(
          label: 'Корпуса',
          value: '${project.bodies.length}',
        ),
        ProjectSelectionProperty(
          label: 'Компоненты',
          value: '${project.componentPlacements.length}',
        ),
        ProjectSelectionProperty(
          label: 'Фичи',
          value: '${project.features.length}',
        ),
      ],
    );
  }

  ProjectSelectionDetails _enclosureDetails(String? id) {
    final body = project.bodies.where((body) => body.id == id).firstOrNull;
    if (body == null) {
      return _missingDetails('Корпус', id);
    }

    return ProjectSelectionDetails(
      title: 'Корпус',
      subtitle: body.id,
      iconKey: 'enclosure',
      status: 'Выбран корпус ${body.id}',
      properties: [
        ProjectSelectionProperty(label: 'Форма', value: body.shape),
        ProjectSelectionProperty(
          label: 'Размер',
          value: _formatSize(body.size),
        ),
        ProjectSelectionProperty(
          label: 'Стенка',
          value: '${body.wallThickness.toStringAsFixed(1)} mm',
        ),
        ProjectSelectionProperty(
          label: 'Радиус',
          value: '${body.cornerRadius.toStringAsFixed(1)} mm',
        ),
        ProjectSelectionProperty(
          label: 'Крышка',
          value: body.lid?.type ?? 'нет',
        ),
      ],
    );
  }

  ProjectSelectionDetails _surfaceDetails(String? id, String? parentId) {
    final label = surfaceLabels[id] ?? id ?? 'surface';
    return ProjectSelectionDetails(
      title: label,
      subtitle: parentId == null ? 'Грань' : 'Грань на $parentId',
      iconKey: 'surface',
      status: 'Выбрана грань: $label',
      properties: [
        ProjectSelectionProperty(label: 'ID', value: id ?? 'unknown'),
        if (parentId != null)
          ProjectSelectionProperty(label: 'Объект', value: parentId),
        ProjectSelectionProperty(
          label: 'Команды',
          value: 'порты, кнопки, стекло',
        ),
      ],
    );
  }

  ProjectSelectionDetails _componentPlacementDetails(String? id) {
    final placement = project.componentPlacements
        .where((placement) => placement.id == id)
        .firstOrNull;
    if (placement == null) {
      return _missingDetails('Компонент', id);
    }

    final template = project.componentTemplates
        .where((template) => template.id == placement.templateId)
        .firstOrNull;

    return ProjectSelectionDetails(
      title: template?.name ?? 'Компонент',
      subtitle: placement.id,
      iconKey: 'component',
      status: 'Выбран компонент ${template?.name ?? placement.id}',
      properties: [
        ProjectSelectionProperty(label: 'Шаблон', value: placement.templateId),
        ProjectSelectionProperty(
          label: 'Позиция',
          value: _formatSize(placement.position),
        ),
        ProjectSelectionProperty(
          label: 'Поворот',
          value: _formatSize(placement.rotation),
        ),
        ProjectSelectionProperty(
          label: 'Сторона',
          value: placement.mountingSide,
        ),
        ProjectSelectionProperty(
          label: 'Закреплен',
          value: placement.locked ? 'да' : 'нет',
        ),
        ProjectSelectionProperty(
          label: 'Показан',
          value: placement.visible ? 'да' : 'нет',
        ),
      ],
    );
  }

  ProjectSelectionDetails _componentTemplateDetails(String? id) {
    final template = project.componentTemplates
        .where((template) => template.id == id)
        .firstOrNull;
    if (template == null) {
      return _missingDetails('Шаблон', id);
    }

    return ProjectSelectionDetails(
      title: template.name,
      subtitle: 'Шаблон компонента',
      iconKey: 'component',
      status: 'Выбран шаблон компонента ${template.name}',
      properties: [
        ProjectSelectionProperty(
          label: 'Плата',
          value: template.board.outline.type,
        ),
        ProjectSelectionProperty(
          label: 'Размер платы',
          value:
              '${template.board.outline.width.toStringAsFixed(0)} x '
              '${template.board.outline.height.toStringAsFixed(0)} mm',
        ),
        ProjectSelectionProperty(
          label: 'Толщина',
          value: '${template.board.thickness.toStringAsFixed(1)} mm',
        ),
        ProjectSelectionProperty(
          label: 'Отверстия',
          value: '${template.mountingHoles.length}',
        ),
        ProjectSelectionProperty(
          label: 'Элементы',
          value: '${template.features.length}',
        ),
      ],
    );
  }

  ProjectSelectionDetails _featureDetails(String? id) {
    final feature = project.features
        .where((feature) => feature.id == id)
        .firstOrNull;
    if (feature == null) {
      return _missingDetails('Фича', id);
    }

    return ProjectSelectionDetails(
      title: _humanizeFeatureType(feature.type),
      subtitle: feature.id,
      iconKey: 'feature',
      status: 'Выбрана фича ${_humanizeFeatureType(feature.type)}',
      properties: [
        ProjectSelectionProperty(label: 'Тип', value: feature.type),
        ProjectSelectionProperty(label: 'Грань', value: feature.targetSurface),
        ProjectSelectionProperty(label: 'Операция', value: feature.operation),
        ..._parameterProperties(feature.parameters),
      ],
    );
  }

  ProjectSelectionDetails _featureGroupDetails(String? id) {
    final group = project.featureGroups
        .where((group) => group.id == id)
        .firstOrNull;
    if (group == null) {
      return _missingDetails('Группа', id);
    }

    return ProjectSelectionDetails(
      title: _humanizeFeatureType(group.type),
      subtitle: group.id,
      iconKey: 'feature',
      status: 'Выбрана группа фич ${_humanizeFeatureType(group.type)}',
      properties: [
        ProjectSelectionProperty(label: 'Тип', value: group.type),
        ProjectSelectionProperty(label: 'Грань', value: group.targetSurface),
        ..._featureGroupProperties(group),
      ],
    );
  }

  ProjectSelectionDetails _missingDetails(String title, String? id) {
    return ProjectSelectionDetails(
      title: title,
      subtitle: id ?? 'unknown',
      iconKey: 'warning',
      status: 'Выбор не найден',
      properties: const [
        ProjectSelectionProperty(label: 'Состояние', value: 'нет в модели'),
      ],
    );
  }
}

class ProjectSelectionDetails {
  const ProjectSelectionDetails({
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.status,
    required this.properties,
  });

  final String title;
  final String subtitle;
  final String iconKey;
  final String status;
  final List<ProjectSelectionProperty> properties;
}

class ProjectSelectionProperty {
  const ProjectSelectionProperty({required this.label, required this.value});

  final String label;
  final String value;
}

String _formatSize(List<double> values) {
  return '${values.map((value) => value.toStringAsFixed(0)).join(' x ')} mm';
}

String _humanizeFeatureType(String type) {
  return switch (type) {
    'usb_c_cutout' => 'USB-C',
    'glass_recess' => 'Посадка под стекло',
    'button_group' => 'Группа кнопок',
    'standoff_mounts' => 'Крепёж',
    _ => type.replaceAll('_', ' '),
  };
}

List<ProjectSelectionProperty> _parameterProperties(
  Map<String, Object?> parameters,
) {
  final entries = parameters.entries.take(5);
  return [
    for (final entry in entries)
      ProjectSelectionProperty(
        label: entry.key,
        value: _formatValue(entry.value),
      ),
  ];
}

List<ProjectSelectionProperty> _featureGroupProperties(FeatureGroup group) {
  return [
    if (group.pattern.containsKey('layout'))
      ProjectSelectionProperty(
        label: 'Раскладка',
        value: _formatValue(group.pattern['layout']),
      ),
    if (group.pattern.containsKey('count'))
      ProjectSelectionProperty(
        label: 'Кол-во',
        value: _formatValue(group.pattern['count']),
      ),
    if (group.pattern.containsKey('spacing'))
      ProjectSelectionProperty(
        label: 'Шаг',
        value: _formatValue(group.pattern['spacing']),
      ),
    if (group.itemPrototype.containsKey('diameter'))
      ProjectSelectionProperty(
        label: 'Диаметр',
        value: _formatValue(group.itemPrototype['diameter']),
      ),
    if (group.itemPrototype.containsKey('holeDiameter'))
      ProjectSelectionProperty(
        label: 'Отверстие',
        value: _formatValue(group.itemPrototype['holeDiameter']),
      ),
    if (group.itemPrototype.containsKey('height'))
      ProjectSelectionProperty(
        label: 'Высота',
        value: _formatValue(group.itemPrototype['height']),
      ),
    if (group.itemPrototype.containsKey('mode'))
      ProjectSelectionProperty(
        label: 'Тип кнопки',
        value: _formatValue(group.itemPrototype['mode']),
      ),
  ];
}

String _formatValue(Object? value) {
  return switch (value) {
    double() => value.toStringAsFixed(1),
    List<Object?>() => value.join(', '),
    _ => value?.toString() ?? 'none',
  };
}
