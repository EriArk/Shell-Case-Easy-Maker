import 'dart:math' as math;

import '../project/json_helpers.dart';
import '../project/project_model.dart';
import 'parameter_model.dart';

class SketchEntityParameterAdapter {
  const SketchEntityParameterAdapter._();

  static const rectangleSchema = ParameterSchema(
    id: 'sketch.rectangle',
    label: 'Прямоугольник',
    parameters: [
      ParameterDefinition(
        id: 'centerX',
        label: 'X',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 0.0,
        range: ParameterRange(min: -500, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'centerY',
        label: 'Y',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 0.0,
        range: ParameterRange(min: -500, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'width',
        label: 'Ширина',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 20.0,
        range: ParameterRange(min: 1, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'height',
        label: 'Высота',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 12.0,
        range: ParameterRange(min: 1, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'cornerRadius',
        label: 'Радиус',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 0.0,
        range: ParameterRange(min: 0, max: 250, step: 0.1),
      ),
    ],
  );

  static ParameterSchema? schemaFor(SketchEntity entity) {
    return switch (entity.type) {
      'rectangle' => rectangleSchema,
      _ => null,
    };
  }

  static Map<String, Object?> valuesFrom(SketchEntity entity) {
    if (entity.type != 'rectangle') {
      return const {};
    }

    final center = readDoubleList(
      entity.parameters['center'],
      fallback: const [0.0, 0.0],
    );

    return rectangleSchema.applyDefaults({
      'centerX': center.isNotEmpty ? center[0] : 0.0,
      'centerY': center.length > 1 ? center[1] : 0.0,
      'width': entity.parameters['width'],
      'height': entity.parameters['height'],
      'cornerRadius': entity.parameters['cornerRadius'],
    });
  }

  static SketchEntity updateParameter(
    SketchEntity entity,
    String parameterId,
    Object? value,
  ) {
    final schema = schemaFor(entity);
    if (schema == null ||
        !schema.parameters.any((parameter) => parameter.id == parameterId)) {
      return entity;
    }

    return applyValues(entity, {
      ...valuesFrom(entity),
      parameterId: schema.byId(parameterId).normalize(value),
    });
  }

  static SketchEntity applyValues(
    SketchEntity entity,
    Map<String, Object?> values,
  ) {
    if (entity.type != 'rectangle') {
      return entity;
    }

    final normalized = rectangleSchema.applyDefaults(values);
    final width = _cleanDouble(_doubleValue(normalized, 'width'));
    final height = _cleanDouble(_doubleValue(normalized, 'height'));
    final maxRadius = math.min(width, height) / 2;
    final cornerRadius = _cleanDouble(
      _doubleValue(normalized, 'cornerRadius').clamp(0.0, maxRadius),
    );

    return SketchEntity(
      id: entity.id,
      type: entity.type,
      parameters: {
        'center': [
          _cleanDouble(_doubleValue(normalized, 'centerX')),
          _cleanDouble(_doubleValue(normalized, 'centerY')),
        ],
        'width': width,
        'height': height,
        'cornerRadius': cornerRadius,
      },
      metadata: entity.metadata,
    );
  }

  static SketchEntity duplicateWithOffset(
    SketchEntity entity, {
    required String id,
    double dx = 6.0,
    double dy = -6.0,
  }) {
    final copy = SketchEntity(
      id: id,
      type: entity.type,
      parameters: entity.parameters,
      metadata: entity.metadata,
    );

    if (entity.type != 'rectangle') {
      return copy;
    }

    final values = valuesFrom(entity);
    return applyValues(copy, {
      ...values,
      'centerX': _doubleValue(values, 'centerX') + dx,
      'centerY': _doubleValue(values, 'centerY') + dy,
    });
  }

  static List<ParameterIssue> validate(SketchEntity entity) {
    final schema = schemaFor(entity);
    if (schema == null) {
      return const [];
    }

    final values = valuesFrom(entity);
    final issues = schema.validate(values);
    final width = _doubleValue(values, 'width');
    final height = _doubleValue(values, 'height');
    final radius = _doubleValue(values, 'cornerRadius');
    final maxRadius = math.min(width, height) / 2;

    return [
      ...issues,
      if (radius > maxRadius)
        const ParameterIssue(
          parameterId: 'cornerRadius',
          severity: ParameterIssueSeverity.error,
          code: 'sketch.rectangle.cornerRadius',
          message: 'Радиус больше половины меньшей стороны.',
        ),
    ];
  }

  static List<ParameterIssue> validateWithinWorkplane(
    SketchEntity entity, {
    required double workplaneWidth,
    required double workplaneHeight,
  }) {
    final issues = validate(entity);
    if (entity.type != 'rectangle') {
      return issues;
    }

    final values = valuesFrom(entity);
    final centerX = _doubleValue(values, 'centerX');
    final centerY = _doubleValue(values, 'centerY');
    final halfWidth = _doubleValue(values, 'width') / 2;
    final halfHeight = _doubleValue(values, 'height') / 2;
    final workplaneHalfWidth = workplaneWidth / 2;
    final workplaneHalfHeight = workplaneHeight / 2;
    final inside =
        centerX - halfWidth >= -workplaneHalfWidth &&
        centerX + halfWidth <= workplaneHalfWidth &&
        centerY - halfHeight >= -workplaneHalfHeight &&
        centerY + halfHeight <= workplaneHalfHeight;

    return [
      ...issues,
      if (!inside)
        const ParameterIssue(
          parameterId: 'center',
          severity: ParameterIssueSeverity.warning,
          code: 'sketch.rectangle.workplaneBounds',
          message: 'Контур выходит за поверхность.',
        ),
    ];
  }

  static double _doubleValue(Map<String, Object?> values, String id) {
    final value = values[id];
    return value is num ? value.toDouble() : 0.0;
  }

  static double _cleanDouble(num value) {
    final rounded = double.parse(value.toStringAsFixed(6));
    return rounded.abs() < 0.000001 ? 0.0 : rounded;
  }
}
