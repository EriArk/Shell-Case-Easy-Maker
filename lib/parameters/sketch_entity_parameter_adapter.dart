import 'dart:math' as math;

import '../project/json_helpers.dart';
import '../project/project_model.dart';
import 'parameter_model.dart';

class SketchEntityParameterAdapter {
  const SketchEntityParameterAdapter._();

  static const defaultProfileDepth = 3.0;
  static const defaultAddProtrusion = 1.2;
  static const minProfileDepth = 0.2;
  static const maxProfileDepth = 10.0;

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
      ParameterDefinition(
        id: 'rotation',
        label: 'Поворот',
        kind: ParameterKind.angle,
        unit: '°',
        defaultValue: 0.0,
        range: ParameterRange(min: -180, max: 180, step: 1),
      ),
      ParameterDefinition(
        id: 'depth',
        label: 'Глубина',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: defaultProfileDepth,
        range: ParameterRange(
          min: minProfileDepth,
          max: maxProfileDepth,
          step: 0.1,
        ),
      ),
    ],
  );

  static const circleSchema = ParameterSchema(
    id: 'sketch.circle',
    label: 'Круг',
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
        id: 'diameter',
        label: 'Диаметр',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 12.0,
        range: ParameterRange(min: 1, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'depth',
        label: 'Глубина',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: defaultProfileDepth,
        range: ParameterRange(
          min: minProfileDepth,
          max: maxProfileDepth,
          step: 0.1,
        ),
      ),
    ],
  );

  static const lineSchema = ParameterSchema(
    id: 'sketch.line',
    label: 'Line',
    parameters: [
      ParameterDefinition(
        id: 'startX',
        label: 'Start X',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: -10.0,
        range: ParameterRange(min: -500, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'startY',
        label: 'Start Y',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 0.0,
        range: ParameterRange(min: -500, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'endX',
        label: 'End X',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 10.0,
        range: ParameterRange(min: -500, max: 500, step: 0.1),
      ),
      ParameterDefinition(
        id: 'endY',
        label: 'End Y',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 0.0,
        range: ParameterRange(min: -500, max: 500, step: 0.1),
      ),
    ],
  );

  static ParameterSchema? schemaFor(SketchEntity entity) {
    return switch (entity.type) {
      'rectangle' => rectangleSchema,
      'circle' => circleSchema,
      'line' => lineSchema,
      _ => null,
    };
  }

  static Map<String, Object?> valuesFrom(SketchEntity entity) {
    final center = readDoubleList(
      entity.parameters['center'],
      fallback: const [0.0, 0.0],
    );

    return switch (entity.type) {
      'rectangle' => _removeMissingOperationDepth(
        entity,
        rectangleSchema.applyDefaults({
          'centerX': center.isNotEmpty ? center[0] : 0.0,
          'centerY': center.length > 1 ? center[1] : 0.0,
          'width': entity.parameters['width'],
          'height': entity.parameters['height'],
          'cornerRadius': entity.parameters['cornerRadius'],
          'rotation': entity.parameters['rotation'],
          'depth': _operationDepthValue(entity),
        }),
      ),
      'circle' => _removeMissingOperationDepth(
        entity,
        circleSchema.applyDefaults({
          'centerX': center.isNotEmpty ? center[0] : 0.0,
          'centerY': center.length > 1 ? center[1] : 0.0,
          'diameter': entity.parameters['diameter'],
          'depth': _operationDepthValue(entity),
        }),
      ),
      'line' => _lineValuesFrom(entity),
      _ => const {},
    };
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
    return switch (entity.type) {
      'rectangle' => _applyRectangleValues(entity, values),
      'circle' => _applyCircleValues(entity, values),
      'line' => _applyLineValues(entity, values),
      _ => entity,
    };
  }

  static SketchEntity _applyRectangleValues(
    SketchEntity entity,
    Map<String, Object?> values,
  ) {
    final shouldStoreDepth =
        _hasOperationDepth(entity) ||
        values.containsKey('depth') ||
        values.containsKey('protrusion');
    final normalized = rectangleSchema.applyDefaults(values);
    final width = _cleanDouble(_doubleValue(normalized, 'width'));
    final height = _cleanDouble(_doubleValue(normalized, 'height'));
    final maxRadius = math.min(width, height) / 2;
    final cornerRadius = _cleanDouble(
      _doubleValue(normalized, 'cornerRadius').clamp(0.0, maxRadius),
    );
    final rotation = _cleanDouble(_doubleValue(normalized, 'rotation'));

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
        'rotation': rotation,
        if (shouldStoreDepth)
          'depth': _cleanDouble(_doubleValue(normalized, 'depth')),
      },
      metadata: entity.metadata,
    );
  }

  static SketchEntity _applyCircleValues(
    SketchEntity entity,
    Map<String, Object?> values,
  ) {
    final shouldStoreDepth =
        _hasOperationDepth(entity) ||
        values.containsKey('depth') ||
        values.containsKey('protrusion');
    final normalized = circleSchema.applyDefaults(values);

    return SketchEntity(
      id: entity.id,
      type: entity.type,
      parameters: {
        'center': [
          _cleanDouble(_doubleValue(normalized, 'centerX')),
          _cleanDouble(_doubleValue(normalized, 'centerY')),
        ],
        'diameter': _cleanDouble(_doubleValue(normalized, 'diameter')),
        if (shouldStoreDepth)
          'depth': _cleanDouble(_doubleValue(normalized, 'depth')),
      },
      metadata: entity.metadata,
    );
  }

  static Map<String, Object?> _lineValuesFrom(SketchEntity entity) {
    final start = readDoubleList(
      entity.parameters['start'],
      fallback: const [-10.0, 0.0],
    );
    final end = readDoubleList(
      entity.parameters['end'],
      fallback: const [10.0, 0.0],
    );
    final startX = start.isNotEmpty ? start[0] : -10.0;
    final startY = start.length > 1 ? start[1] : 0.0;
    final endX = end.isNotEmpty ? end[0] : 10.0;
    final endY = end.length > 1 ? end[1] : 0.0;
    final centerX = (startX + endX) / 2;
    final centerY = (startY + endY) / 2;
    final length = math.sqrt(
      math.pow(endX - startX, 2) + math.pow(endY - startY, 2),
    );

    return {
      ...lineSchema.applyDefaults({
        'startX': startX,
        'startY': startY,
        'endX': endX,
        'endY': endY,
      }),
      'centerX': _cleanDouble(centerX),
      'centerY': _cleanDouble(centerY),
      'length': _cleanDouble(length),
    };
  }

  static SketchEntity _applyLineValues(
    SketchEntity entity,
    Map<String, Object?> values,
  ) {
    final current = valuesFrom(entity);
    final normalized = lineSchema.applyDefaults({...current, ...values});
    var startX = _doubleValue(normalized, 'startX');
    var startY = _doubleValue(normalized, 'startY');
    var endX = _doubleValue(normalized, 'endX');
    var endY = _doubleValue(normalized, 'endY');

    if (values.containsKey('centerX') || values.containsKey('centerY')) {
      final currentCenterX = _doubleValue(current, 'centerX');
      final currentCenterY = _doubleValue(current, 'centerY');
      final nextCenterX = values.containsKey('centerX')
          ? readDouble(values['centerX'], fallback: currentCenterX)
          : currentCenterX;
      final nextCenterY = values.containsKey('centerY')
          ? readDouble(values['centerY'], fallback: currentCenterY)
          : currentCenterY;
      final dx = nextCenterX - currentCenterX;
      final dy = nextCenterY - currentCenterY;
      startX += dx;
      startY += dy;
      endX += dx;
      endY += dy;
    }

    final length = math.sqrt(
      math.pow(endX - startX, 2) + math.pow(endY - startY, 2),
    );
    if (length < 1.0) {
      endX = startX + 1.0;
      endY = startY;
    }

    return SketchEntity(
      id: entity.id,
      type: entity.type,
      parameters: {
        'start': [_cleanDouble(startX), _cleanDouble(startY)],
        'end': [_cleanDouble(endX), _cleanDouble(endY)],
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

    final schema = schemaFor(entity);
    if (schema == null) {
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
    if (entity.type != 'rectangle') {
      return issues;
    }

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
    final values = valuesFrom(entity);
    if (entity.type == 'line') {
      return [
        ...issues,
        if (!_lineInsideWorkplane(
          values,
          workplaneWidth: workplaneWidth,
          workplaneHeight: workplaneHeight,
        ))
          const ParameterIssue(
            parameterId: 'start',
            severity: ParameterIssueSeverity.warning,
            code: 'sketch.line.workplaneBounds',
            message: 'Line is outside the sketch surface.',
          ),
      ];
    }

    if (entity.type == 'circle') {
      return [
        ...issues,
        if (!_circleInsideWorkplane(
          values,
          workplaneWidth: workplaneWidth,
          workplaneHeight: workplaneHeight,
        ))
          const ParameterIssue(
            parameterId: 'center',
            severity: ParameterIssueSeverity.warning,
            code: 'sketch.circle.workplaneBounds',
            message: 'Контур выходит за поверхность.',
          ),
      ];
    }

    if (entity.type != 'rectangle') {
      return issues;
    }

    final centerX = _doubleValue(values, 'centerX');
    final centerY = _doubleValue(values, 'centerY');
    final halfWidth = _doubleValue(values, 'width') / 2;
    final halfHeight = _doubleValue(values, 'height') / 2;
    final rotationRadians = _doubleValue(values, 'rotation') * math.pi / 180;
    final cos = math.cos(rotationRadians);
    final sin = math.sin(rotationRadians);
    final workplaneHalfWidth = workplaneWidth / 2;
    final workplaneHalfHeight = workplaneHeight / 2;
    final inside =
        const [
          _SketchCorner(-1, -1),
          _SketchCorner(1, -1),
          _SketchCorner(1, 1),
          _SketchCorner(-1, 1),
        ].every((corner) {
          final localX = corner.xSign * halfWidth;
          final localY = corner.ySign * halfHeight;
          final x = centerX + localX * cos - localY * sin;
          final y = centerY + localX * sin + localY * cos;

          return x >= -workplaneHalfWidth &&
              x <= workplaneHalfWidth &&
              y >= -workplaneHalfHeight &&
              y <= workplaneHalfHeight;
        });

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

  static bool _circleInsideWorkplane(
    Map<String, Object?> values, {
    required double workplaneWidth,
    required double workplaneHeight,
  }) {
    final centerX = _doubleValue(values, 'centerX');
    final centerY = _doubleValue(values, 'centerY');
    final radius = _doubleValue(values, 'diameter') / 2;
    final workplaneHalfWidth = workplaneWidth / 2;
    final workplaneHalfHeight = workplaneHeight / 2;

    return centerX - radius >= -workplaneHalfWidth &&
        centerX + radius <= workplaneHalfWidth &&
        centerY - radius >= -workplaneHalfHeight &&
        centerY + radius <= workplaneHalfHeight;
  }

  static bool _lineInsideWorkplane(
    Map<String, Object?> values, {
    required double workplaneWidth,
    required double workplaneHeight,
  }) {
    final workplaneHalfWidth = workplaneWidth / 2;
    final workplaneHalfHeight = workplaneHeight / 2;

    bool pointInside(double x, double y) {
      return x >= -workplaneHalfWidth &&
          x <= workplaneHalfWidth &&
          y >= -workplaneHalfHeight &&
          y <= workplaneHalfHeight;
    }

    return pointInside(
          _doubleValue(values, 'startX'),
          _doubleValue(values, 'startY'),
        ) &&
        pointInside(_doubleValue(values, 'endX'), _doubleValue(values, 'endY'));
  }

  static Map<String, Object?> _removeMissingOperationDepth(
    SketchEntity entity,
    Map<String, Object?> values,
  ) {
    if (_hasOperationDepth(entity)) {
      return values;
    }

    return {...values}..remove('depth');
  }

  static bool _hasOperationDepth(SketchEntity entity) {
    return entity.parameters.containsKey('depth') ||
        entity.parameters.containsKey('protrusion');
  }

  static Object? _operationDepthValue(SketchEntity entity) {
    if (entity.parameters.containsKey('depth')) {
      return entity.parameters['depth'];
    }

    return entity.parameters['protrusion'];
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

class _SketchCorner {
  const _SketchCorner(this.xSign, this.ySign);

  final double xSign;
  final double ySign;
}
