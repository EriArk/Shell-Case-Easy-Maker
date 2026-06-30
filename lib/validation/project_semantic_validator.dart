import 'dart:math' as math;

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
      _validateComponentPlacements(project, enclosure, messages);
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

  static void _validateComponentPlacements(
    ProjectModel project,
    Enclosure enclosure,
    List<ValidationMessage> messages,
  ) {
    final inner = _innerSpace(enclosure);

    for (final placement in project.componentPlacements) {
      final template = _templateForPlacement(project, placement);
      if (template == null) {
        messages.add(
          ValidationMessage(
            severity: ValidationSeverity.error,
            code: 'component.placement.template.missing',
            message: 'Размещённый компонент ссылается на отсутствующий шаблон.',
            targetId: placement.id,
          ),
        );
        continue;
      }

      final boardWidth = template.board.outline.width;
      final boardDepth = template.board.outline.height;
      final boardThickness = template.board.thickness;
      if (boardWidth <= 0 || boardDepth <= 0 || boardThickness <= 0) {
        messages.add(
          ValidationMessage(
            severity: ValidationSeverity.error,
            code: 'component.template.board.invalid',
            message: 'Размер платы компонента должен быть больше нуля.',
            targetId: template.id,
          ),
        );
        continue;
      }

      final x = _positionAt(placement.position, 0);
      final y = _positionAt(placement.position, 1);
      final z = _positionAt(placement.position, 2);
      final boardPlan = _rotatedRectExtents(
        width: boardWidth,
        depth: boardDepth,
        rotationZDegrees: _positionAt(placement.rotation, 2),
      );
      final outsidePlan = !_fitsCenteredRect(
        centerX: x,
        centerY: y,
        width: boardPlan.width,
        depth: boardPlan.depth,
        spaceWidth: inner.width,
        spaceDepth: inner.depth,
      );
      final outsideHeight = z < 0 || z + boardThickness > inner.height;

      if (outsidePlan || outsideHeight) {
        messages.add(
          ValidationMessage(
            severity: ValidationSeverity.error,
            code: 'component.placement.outside_enclosure',
            message: 'Компонент выходит за внутренний объём корпуса.',
            targetId: placement.id,
          ),
        );
      }

      _validateComponentFeatureKeepouts(placement, template, inner, messages);
    }
  }

  static void _validateComponentFeatureKeepouts(
    ComponentPlacement placement,
    ComponentTemplate template,
    ({double width, double depth, double height}) inner,
    List<ValidationMessage> messages,
  ) {
    final placementX = _positionAt(placement.position, 0);
    final placementY = _positionAt(placement.position, 1);
    final placementZ = _positionAt(placement.position, 2);
    final rotationZ = _positionAt(placement.rotation, 2);

    for (final feature in template.features) {
      final keepout = readJsonMap(feature.metadata['keepout']);
      if (keepout.isEmpty) {
        continue;
      }

      final size = readDoubleList(keepout['size'], fallback: const []);
      if (size.length < 3 || size[0] <= 0 || size[1] <= 0 || size[2] <= 0) {
        continue;
      }

      final featurePosition = _rotatePoint(
        x: _positionAt(feature.position, 0),
        y: _positionAt(feature.position, 1),
        rotationZDegrees: rotationZ,
      );
      final keepoutPlan = _rotatedRectExtents(
        width: size[0],
        depth: size[1],
        rotationZDegrees: rotationZ,
      );
      final centerX = placementX + featurePosition.x;
      final centerY = placementY + featurePosition.y;
      final outsidePlan = !_fitsCenteredRect(
        centerX: centerX,
        centerY: centerY,
        width: keepoutPlan.width,
        depth: keepoutPlan.depth,
        spaceWidth: inner.width,
        spaceDepth: inner.depth,
      );
      final outsideHeight =
          placementZ < 0 || placementZ + size[2] > inner.height;

      if (outsidePlan || outsideHeight) {
        messages.add(
          ValidationMessage(
            severity: ValidationSeverity.warning,
            code: 'component.feature.keepout.outside_enclosure',
            message:
                'Зона доступа компонента выходит за внутренний объём корпуса.',
            targetId: '${placement.id}.${feature.id}',
          ),
        );
      }
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
          _validateUsbC(project, feature, enclosure, messages);
        case 'glass_recess':
          _validateGlassRecess(feature, enclosure, messages);
      }
    }
  }

  static void _validateUsbC(
    ProjectModel project,
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

    _validateProjectedFeatureAnchor(
      project: project,
      enclosure: enclosure,
      feature: feature,
      sizeA: width,
      sizeB: height,
      messages: messages,
    );
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
      switch (group.type) {
        case 'button_group':
          _validateButtonGroup(project, enclosure, group, messages);
        case 'standoff_mounts':
          _validateStandoffMounts(project, enclosure, group, messages);
      }
    }
  }

  static void _validateButtonGroup(
    ProjectModel project,
    Enclosure enclosure,
    FeatureGroup group,
    List<ValidationMessage> messages,
  ) {
    _validateButtonPlunger(group, messages);

    final layout = readString(group.pattern['layout'], fallback: '');
    if (layout != 'from_component_switches') {
      return;
    }

    _validateProjectedGroupSource(project, group, messages);

    final switchPositions = readJsonMapList(group.pattern['switchPositions']);
    if (switchPositions.isEmpty) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.projected_anchor.position.missing',
          message: 'Группа кнопок не содержит спроецированные центры кнопок.',
          targetId: group.id,
        ),
      );
      return;
    }

    final diameter = readDouble(group.itemPrototype['diameter'], fallback: 8);
    final ringWidth = readDouble(
      group.itemPrototype['ringWidth'],
      fallback: 1.2,
    );
    final capDiameter = readDouble(
      group.itemPrototype['capDiameter'],
      fallback: math.max(0.8, diameter - 0.6),
    );
    final outerDiameter = math.max(
      diameter + (ringWidth + 0.05) * 2,
      capDiameter,
    );
    for (final switchPosition in switchPositions) {
      final position = readDoubleList(
        switchPosition['position'],
        fallback: const [],
      );
      final axes = _projectedAnchorAxes(
        rawAxes: switchPosition['surfaceAxes'],
        targetSurface: group.targetSurface,
        targetId: group.id,
        messages: messages,
        codePrefix: 'group',
      );
      if (position.length < 2 || !_isFinitePosition(position)) {
        messages.add(
          ValidationMessage(
            severity: ValidationSeverity.warning,
            code: 'group.projected_anchor.position.missing',
            message: 'Группа кнопок содержит неполную проекцию центра кнопки.',
            targetId: group.id,
          ),
        );
        continue;
      }

      if (!_projectedAnchorFitsSurface(
        enclosure: enclosure,
        axes: axes,
        position: position,
        sizeA: outerDiameter,
        sizeB: outerDiameter,
      )) {
        messages.add(
          ValidationMessage(
            severity: ValidationSeverity.error,
            code: 'group.projected_anchor.outside_surface',
            message: 'Центр кнопки выходит за доступную поверхность корпуса.',
            targetId: group.id,
          ),
        );
        return;
      }
    }
  }

  static void _validateButtonPlunger(
    FeatureGroup group,
    List<ValidationMessage> messages,
  ) {
    final mode = readString(group.itemPrototype['mode'], fallback: 'plunger');
    if (mode != 'plunger') {
      return;
    }

    final diameter = readDouble(group.itemPrototype['diameter'], fallback: 8);
    final stemDiameter = readDouble(
      group.itemPrototype['stemDiameter'],
      fallback: 3,
    );
    final stemDepth = readDouble(
      group.itemPrototype['stemDepth'],
      fallback: 2.8,
    );
    final travel = readDouble(group.itemPrototype['travel'], fallback: 0.8);
    final switchClearance = readDouble(
      group.itemPrototype['switchClearance'],
      fallback: 0.3,
    );
    final guideClearance = readDouble(
      group.itemPrototype['guideClearance'],
      fallback: 0.25,
    );

    if (travel <= 0 || !travel.isFinite) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'group.button_plunger.travel.invalid',
          message: 'Ход плунжера должен быть больше нуля.',
          targetId: group.id,
        ),
      );
    }

    if (switchClearance < 0 || !switchClearance.isFinite) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'group.button_plunger.switch_clearance.invalid',
          message: 'Зазор до свитча не может быть отрицательным.',
          targetId: group.id,
        ),
      );
    }

    final guideClearanceValid = guideClearance >= 0 && guideClearance.isFinite;
    if (!guideClearanceValid) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'group.button_plunger.guide_clearance.invalid',
          message: 'Направляющий зазор не может быть отрицательным.',
          targetId: group.id,
        ),
      );
    }

    if (travel + switchClearance + 0.2 > stemDepth) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'group.button_plunger.travel.too_deep',
          message:
              'Ход плунжера и зазор до свитча больше доступной глубины ножки.',
          targetId: group.id,
        ),
      );
    }

    if (guideClearanceValid && stemDiameter + guideClearance * 2 > diameter) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'group.button_plunger.guide.too_wide',
          message:
              'Ножка с направляющим зазором не помещается в отверстие кнопки.',
          targetId: group.id,
        ),
      );
    }

    if (guideClearanceValid && guideClearance < 0.15) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.button_plunger.guide_clearance.tight',
          message:
              'Направляющий зазор меньше 0.15 mm может заедать после печати.',
          targetId: group.id,
        ),
      );
    }

    if (guideClearanceValid && guideClearance > 1.2) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.button_plunger.guide_clearance.loose',
          message: 'Большой направляющий зазор может сделать кнопку шаткой.',
          targetId: group.id,
        ),
      );
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

  static void _validateProjectedFeatureAnchor({
    required ProjectModel project,
    required Enclosure enclosure,
    required SemanticFeature feature,
    required double sizeA,
    required double sizeB,
    required List<ValidationMessage> messages,
  }) {
    final placement = feature.placement ?? const {};
    final projectionMode = readString(
      placement['projectionMode'],
      fallback: '',
    );
    if (projectionMode != 'component_feature_surface_projection') {
      return;
    }

    _validateProjectedFeatureSource(project, feature, messages);

    final position = readDoubleList(
      placement['surfacePosition'],
      fallback: const [],
    );
    final axes = _projectedAnchorAxes(
      rawAxes: placement['surfaceAxes'],
      targetSurface: feature.targetSurface,
      targetId: feature.id,
      messages: messages,
      codePrefix: 'feature',
    );
    if (position.length < 2 || !_isFinitePosition(position)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'feature.projected_anchor.position.missing',
          message: 'Фича содержит неполную проекцию на поверхность корпуса.',
          targetId: feature.id,
        ),
      );
      return;
    }

    if (!_projectedAnchorFitsSurface(
      enclosure: enclosure,
      axes: axes,
      position: position,
      sizeA: sizeA,
      sizeB: sizeB,
    )) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.error,
          code: 'feature.projected_anchor.outside_surface',
          message: 'Спроецированный центр фичи выходит за поверхность корпуса.',
          targetId: feature.id,
        ),
      );
    }
  }

  static void _validateProjectedFeatureSource(
    ProjectModel project,
    SemanticFeature feature,
    List<ValidationMessage> messages,
  ) {
    final source = feature.source ?? const {};
    final placementId = readString(
      source['componentPlacementId'],
      fallback: '',
    );
    final templateId = readString(source['componentTemplateId'], fallback: '');
    final featureId = readString(source['componentFeatureId'], fallback: '');

    if (placementId.isEmpty) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'feature.projected_anchor.source.missing',
          message: 'Спроецированная фича не связана с исходным компонентом.',
          targetId: feature.id,
        ),
      );
      return;
    }

    final placement = project.componentPlacements
        .where((placement) => placement.id == placementId)
        .firstOrNull;
    if (placement == null) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'feature.projected_anchor.source.missing',
          message: 'Исходный компонент для спроецированной фичи не найден.',
          targetId: feature.id,
        ),
      );
      return;
    }

    final template = project.componentTemplates
        .where(
          (template) =>
              template.id ==
              (templateId.isEmpty ? placement.templateId : templateId),
        )
        .firstOrNull;
    if (template == null) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'feature.projected_anchor.source.missing',
          message:
              'Шаблон исходного компонента для спроецированной фичи не найден.',
          targetId: feature.id,
        ),
      );
      return;
    }

    if (featureId.isNotEmpty &&
        !template.features.any((feature) => feature.id == featureId)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'feature.projected_anchor.source.missing',
          message:
              'Исходный элемент компонента для спроецированной фичи не найден.',
          targetId: feature.id,
        ),
      );
    }
  }

  static void _validateProjectedGroupSource(
    ProjectModel project,
    FeatureGroup group,
    List<ValidationMessage> messages,
  ) {
    final placementId = readString(
      group.pattern['sourcePlacementId'],
      fallback: '',
    );
    final templateId = readString(
      group.pattern['sourceTemplateId'],
      fallback: '',
    );

    if (placementId.isEmpty) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.projected_anchor.source.missing',
          message: 'Группа кнопок не связана с исходным компонентом.',
          targetId: group.id,
        ),
      );
      return;
    }

    final placement = project.componentPlacements
        .where((placement) => placement.id == placementId)
        .firstOrNull;
    if (placement == null) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.projected_anchor.source.missing',
          message: 'Исходный компонент для группы кнопок не найден.',
          targetId: group.id,
        ),
      );
      return;
    }

    final effectiveTemplateId = templateId.isEmpty
        ? placement.templateId
        : templateId;
    final template = project.componentTemplates
        .where((template) => template.id == effectiveTemplateId)
        .firstOrNull;
    if (template == null) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: 'group.projected_anchor.source.missing',
          message: 'Шаблон исходного компонента для группы кнопок не найден.',
          targetId: group.id,
        ),
      );
    }
  }

  static List<String> _projectedAnchorAxes({
    required Object? rawAxes,
    required String targetSurface,
    required String targetId,
    required List<ValidationMessage> messages,
    required String codePrefix,
  }) {
    final axes = _readStringList(rawAxes);
    final expectedAxes = _expectedAxesForSurface(targetSurface);

    if (axes.length < 2) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: '$codePrefix.projected_anchor.axes.missing',
          message: 'Проекция не содержит оси поверхности.',
          targetId: targetId,
        ),
      );
      return expectedAxes;
    }

    final normalizedAxes = axes.take(2).toList(growable: false);
    if (expectedAxes.isNotEmpty &&
        !_sameStringList(normalizedAxes, expectedAxes)) {
      messages.add(
        ValidationMessage(
          severity: ValidationSeverity.warning,
          code: '$codePrefix.projected_anchor.axes.mismatch',
          message: 'Оси проекции не совпадают с целевой поверхностью.',
          targetId: targetId,
        ),
      );
    }

    return normalizedAxes;
  }

  static bool _projectedAnchorFitsSurface({
    required Enclosure enclosure,
    required List<String> axes,
    required List<double> position,
    required double sizeA,
    required double sizeB,
  }) {
    if (axes.length < 2 || position.length < 2) {
      return true;
    }

    final firstRange = _axisRange(enclosure, axes[0]);
    final secondRange = _axisRange(enclosure, axes[1]);
    if (firstRange == null || secondRange == null) {
      return true;
    }

    const tolerance = 0.000001;
    final halfA = math.max(0, sizeA) / 2;
    final halfB = math.max(0, sizeB) / 2;
    final first = position[0];
    final second = position[1];

    return first - halfA >= firstRange.min - tolerance &&
        first + halfA <= firstRange.max + tolerance &&
        second - halfB >= secondRange.min - tolerance &&
        second + halfB <= secondRange.max + tolerance;
  }

  static ({double min, double max})? _axisRange(
    Enclosure enclosure,
    String axis,
  ) {
    final inner = _innerSpace(enclosure);
    return switch (axis) {
      'x' => (min: -inner.width / 2, max: inner.width / 2),
      'y' => (min: -inner.depth / 2, max: inner.depth / 2),
      'z' => (min: 0, max: inner.height),
      _ => null,
    };
  }

  static List<String> _expectedAxesForSurface(String targetSurface) {
    if (targetSurface.contains('front_wall') ||
        targetSurface.contains('back_wall')) {
      return const ['x', 'z'];
    }
    if (targetSurface.contains('left_wall') ||
        targetSurface.contains('right_wall')) {
      return const ['y', 'z'];
    }
    if (targetSurface.contains('top_lid') || targetSurface.contains('bottom')) {
      return const ['x', 'y'];
    }

    return const [];
  }

  static List<String> _readStringList(Object? rawValue) {
    if (rawValue is! List<Object?>) {
      return const [];
    }

    return rawValue.whereType<String>().toList(growable: false);
  }

  static bool _sameStringList(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }

  static bool _isFinitePosition(List<double> position) {
    return position.every((value) => value.isFinite);
  }

  static ComponentTemplate? _templateForPlacement(
    ProjectModel project,
    ComponentPlacement placement,
  ) {
    return project.componentTemplates
        .where((template) => template.id == placement.templateId)
        .firstOrNull;
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

  static ({double width, double depth, double height}) _innerSpace(
    Enclosure enclosure,
  ) {
    return (
      width: _positive(
        _sizeAt(enclosure, 0, 120) - enclosure.wallThickness * 2,
      ),
      depth: _positive(_sizeAt(enclosure, 1, 70) - enclosure.wallThickness * 2),
      height: _positive(
        _sizeAt(enclosure, 2, 28) - enclosure.wallThickness * 2,
      ),
    );
  }

  static bool _fitsCenteredRect({
    required double centerX,
    required double centerY,
    required double width,
    required double depth,
    required double spaceWidth,
    required double spaceDepth,
  }) {
    return centerX.abs() + width / 2 <= spaceWidth / 2 &&
        centerY.abs() + depth / 2 <= spaceDepth / 2;
  }

  static ({double width, double depth}) _rotatedRectExtents({
    required double width,
    required double depth,
    required double rotationZDegrees,
  }) {
    final radians = rotationZDegrees * math.pi / 180;
    final cos = math.cos(radians).abs();
    final sin = math.sin(radians).abs();
    return (width: width * cos + depth * sin, depth: width * sin + depth * cos);
  }

  static ({double x, double y}) _rotatePoint({
    required double x,
    required double y,
    required double rotationZDegrees,
  }) {
    final radians = rotationZDegrees * math.pi / 180;
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    return (x: x * cos - y * sin, y: x * sin + y * cos);
  }

  static double _positionAt(List<double> position, int index) {
    return position.length > index ? position[index] : 0;
  }

  static double _sizeAt(Enclosure enclosure, int index, double fallback) {
    return enclosure.size.length > index ? enclosure.size[index] : fallback;
  }

  static double _positive(double value) {
    return value < 0 ? 0 : value;
  }
}
