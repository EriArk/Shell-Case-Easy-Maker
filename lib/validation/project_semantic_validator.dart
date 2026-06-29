import '../patterns/pattern_layout.dart';
import '../project/project_model.dart';
import '../project/json_helpers.dart';
import 'validation_result.dart';

class ProjectSemanticValidator {
  const ProjectSemanticValidator._();

  static ValidationReport validate(ProjectModel project) {
    final messages = <ValidationMessage>[];
    final enclosure = project.bodies.firstOrNull;

    if (enclosure == null) {
      messages.add(
        const ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'project.enclosure.missing',
          message: 'В проекте нет корпуса для генерации.',
        ),
      );
    } else {
      _validateEnclosure(enclosure, messages);
      _validateFeatures(project, enclosure, messages);
      _validateFeatureGroups(project, enclosure, messages);
    }

    if (messages.isEmpty) {
      messages.add(
        const ValidationMessage(
          severity: ValidationSeverity.info,
          code: 'semantic.ok',
          message: 'Семантическая проверка пройдена.',
        ),
      );
    }

    return ValidationReport(messages: messages);
  }

  static void _validateEnclosure(
    Enclosure enclosure,
    List<ValidationMessage> messages,
  ) {
    final width = _sizeAt(enclosure, 0, 120);
    final depth = _sizeAt(enclosure, 1, 70);
    final height = _sizeAt(enclosure, 2, 28);
    final minDimension = [width, depth, height].reduce((a, b) => a < b ? a : b);

    if (width <= 0 || depth <= 0 || height <= 0) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'enclosure.size.invalid',
          message: 'Размер корпуса должен быть больше нуля.',
          targetId: enclosure.id,
        ),
      );
    }

    if (enclosure.wallThickness < 0.8) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'enclosure.wall.thin',
          message: 'Стенка тоньше 0.8 mm может плохо печататься.',
          targetId: enclosure.id,
        ),
      );
    }

    if (enclosure.wallThickness * 2 >= minDimension) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'enclosure.wall.too_thick',
          message: 'Стенка толще доступного внутреннего размера корпуса.',
          targetId: enclosure.id,
        ),
      );
    }

    if (enclosure.cornerRadius > (width < depth ? width : depth) / 2) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'enclosure.corner_radius.large',
          message: 'Радиус корпуса больше половины габарита основания.',
          targetId: enclosure.id,
        ),
      );
    }
  }

  static void _validateFeatures(
    ProjectModel project,
    Enclosure enclosure,
    List<ValidationMessage> messages,
  ) {
    for (final feature in project.features) {
      switch (feature.type) {
        case 'usb_c_cutout':
          _validateUsbC(feature, enclosure, messages);
        case 'glass_recess':
          _validateGlassRecess(feature, enclosure, messages);
      }
    }
  }

  static void _validateUsbC(
    SemanticFeature feature,
    Enclosure enclosure,
    List<ValidationMessage> messages,
  ) {
    final width = readDouble(feature.parameters['width'], fallback: 10.5);
    final height = readDouble(feature.parameters['height'], fallback: 4.2);
    final cornerRadius = readDouble(
      feature.parameters['cornerRadius'],
      fallback: 1,
    );
    final availableWidth =
        _sizeAt(enclosure, 0, 120) - enclosure.wallThickness * 2;
    final availableHeight =
        _sizeAt(enclosure, 2, 28) - enclosure.wallThickness * 2;

    if (width > availableWidth) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.usb_c.width.too_large',
          message: 'USB-C шире доступной стенки корпуса.',
          targetId: feature.id,
        ),
      );
    }

    if (height > availableHeight) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.usb_c.height.too_large',
          message: 'USB-C выше доступной высоты стенки корпуса.',
          targetId: feature.id,
        ),
      );
    }

    if (cornerRadius * 2 > (width < height ? width : height)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.usb_c.radius.too_large',
          message: 'Радиус USB-C больше половины размера отверстия.',
          targetId: feature.id,
        ),
      );
    }
  }

  static void _validateGlassRecess(
    SemanticFeature feature,
    Enclosure enclosure,
    List<ValidationMessage> messages,
  ) {
    final width = readDouble(feature.parameters['width'], fallback: 42);
    final height = readDouble(feature.parameters['height'], fallback: 24);
    final recessDepth = readDouble(
      feature.parameters['recessDepth'],
      fallback: 1.2,
    );
    final ledgeWidth = readDouble(
      feature.parameters['ledgeWidth'],
      fallback: 1.5,
    );
    final cornerRadius = readDouble(
      feature.parameters['cornerRadius'],
      fallback: 2,
    );
    final availableWidth =
        _sizeAt(enclosure, 0, 120) - enclosure.wallThickness * 2;
    final availableDepth =
        _sizeAt(enclosure, 1, 70) - enclosure.wallThickness * 2;

    if (width > availableWidth || height > availableDepth) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.glass_recess.size.too_large',
          message: 'Посадка под стекло больше доступной крышки.',
          targetId: feature.id,
        ),
      );
    }

    if (recessDepth >= enclosure.wallThickness) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'feature.glass_recess.depth.deep',
          message: 'Глубина посадки не оставляет запаса стенки под стеклом.',
          targetId: feature.id,
        ),
      );
    }

    if (ledgeWidth * 2 >= (width < height ? width : height)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.glass_recess.ledge.too_large',
          message: 'Полка посадки перекрывает внутреннее окно.',
          targetId: feature.id,
        ),
      );
    }

    if (cornerRadius * 2 > (width < height ? width : height)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.glass_recess.radius.too_large',
          message: 'Радиус посадки больше половины размера окна.',
          targetId: feature.id,
        ),
      );
    }
  }

  static void _validateFeatureGroups(
    ProjectModel project,
    Enclosure enclosure,
    List<ValidationMessage> messages,
  ) {
    for (final group in project.featureGroups) {
      if (group.type == 'standoff_mounts') {
        _validateStandoffMounts(project, enclosure, group, messages);
      }
    }
  }

  static void _validateStandoffMounts(
    ProjectModel project,
    Enclosure enclosure,
    FeatureGroup group,
    List<ValidationMessage> messages,
  ) {
    final diameter = readDouble(group.itemPrototype['diameter'], fallback: 5);
    final holeDiameter = readDouble(
      group.itemPrototype['holeDiameter'],
      fallback: 2.2,
    );
    final height = readDouble(group.itemPrototype['height'], fallback: 4);
    final template = _templateForGroup(project, group);
    final positions = PatternLayoutEngine.standoffMountPositions(
      group,
      fallbackTemplate: template,
    );

    if (positions.isEmpty) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.standoff_mounts.source.missing',
          message: 'Крепёж не нашёл исходные монтажные отверстия.',
          targetId: group.id,
        ),
      );
    }

    if (holeDiameter >= diameter - 0.8) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'group.standoff_mounts.hole.too_large',
          message: 'Отверстие крепежа слишком близко к диаметру стойки.',
          targetId: group.id,
        ),
      );
    }

    if (height > _sizeAt(enclosure, 2, 28)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.standoff_mounts.height.tall',
          message: 'Высота стойки больше высоты корпуса.',
          targetId: group.id,
        ),
      );
    }
  }

  static ComponentTemplate? _templateForGroup(
    ProjectModel project,
    FeatureGroup group,
  ) {
    final sourceTemplateId = readString(
      group.pattern['sourceTemplateId'],
      fallback: '',
    );
    if (sourceTemplateId.isNotEmpty) {
      final template = project.componentTemplates
          .where((template) => template.id == sourceTemplateId)
          .firstOrNull;
      if (template != null) {
        return template;
      }
    }

    final sourcePlacementId = readString(
      group.placement['componentPlacementId'],
      fallback: readString(group.pattern['sourcePlacementId'], fallback: ''),
    );
    if (sourcePlacementId.isEmpty) {
      return null;
    }

    final placement = project.componentPlacements
        .where((placement) => placement.id == sourcePlacementId)
        .firstOrNull;
    if (placement == null) {
      return null;
    }

    return project.componentTemplates
        .where((template) => template.id == placement.templateId)
        .firstOrNull;
  }

  static double _sizeAt(Enclosure enclosure, int index, double fallback) {
    return enclosure.size.length > index ? enclosure.size[index] : fallback;
  }
}
