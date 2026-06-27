import '../project/json_helpers.dart';

enum ParameterKind {
  length('length'),
  angle('angle'),
  count('count'),
  ratio('ratio'),
  boolean('boolean'),
  choice('choice'),
  text('text');

  const ParameterKind(this.wireName);

  final String wireName;

  static ParameterKind fromWireName(String value) {
    return ParameterKind.values.firstWhere(
      (kind) => kind.wireName == value,
      orElse: () => ParameterKind.text,
    );
  }
}

enum ParameterIssueSeverity {
  warning('warning'),
  error('error');

  const ParameterIssueSeverity(this.wireName);

  final String wireName;
}

class ParameterSchema {
  const ParameterSchema({
    required this.id,
    required this.label,
    required this.parameters,
    this.metadata = const {},
  });

  factory ParameterSchema.fromJson(Map<String, Object?> json) {
    return ParameterSchema(
      id: readString(json['id'], fallback: 'parameter_schema'),
      label: readString(json['label'], fallback: 'Parameters'),
      parameters: readObjectList(
        json['parameters'],
        ParameterDefinition.fromJson,
      ),
      metadata: withoutKeys(json, const {'id', 'label', 'parameters'}),
    );
  }

  final String id;
  final String label;
  final List<ParameterDefinition> parameters;
  final Map<String, Object?> metadata;

  Map<String, Object?> applyDefaults(Map<String, Object?> values) {
    return {
      for (final parameter in parameters)
        parameter.id: parameter.normalize(values[parameter.id]),
      for (final entry in values.entries)
        if (!parameters.any((parameter) => parameter.id == entry.key))
          entry.key: normalizeJsonValue(entry.value),
    };
  }

  List<ParameterIssue> validate(Map<String, Object?> values) {
    return [
      for (final parameter in parameters)
        ...parameter.validate(values[parameter.id]),
    ];
  }

  ParameterDefinition byId(String id) {
    final parameter = parameters
        .where((parameter) => parameter.id == id)
        .firstOrNull;
    if (parameter == null) {
      throw ArgumentError.value(id, 'id', 'Unknown parameter id');
    }

    return parameter;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'label': label,
      'parameters': parameters.map((parameter) => parameter.toJson()).toList(),
      ...metadata,
    };
  }
}

class ParameterDefinition {
  const ParameterDefinition({
    required this.id,
    required this.label,
    required this.kind,
    required this.defaultValue,
    this.unit,
    this.range,
    this.options = const [],
    this.required = true,
    this.metadata = const {},
  });

  factory ParameterDefinition.fromJson(Map<String, Object?> json) {
    return ParameterDefinition(
      id: readString(json['id'], fallback: 'parameter'),
      label: readString(json['label'], fallback: 'Parameter'),
      kind: ParameterKind.fromWireName(
        readString(json['kind'], fallback: ParameterKind.text.wireName),
      ),
      unit: json['unit'] is String ? json['unit']! as String : null,
      defaultValue: normalizeJsonValue(json['defaultValue']),
      range: json['range'] is Map<Object?, Object?>
          ? ParameterRange.fromJson(readJsonMap(json['range']))
          : null,
      options: readObjectList(json['options'], ParameterOption.fromJson),
      required: readBool(json['required'], fallback: true),
      metadata: withoutKeys(json, const {
        'id',
        'label',
        'kind',
        'unit',
        'defaultValue',
        'range',
        'options',
        'required',
      }),
    );
  }

  final String id;
  final String label;
  final ParameterKind kind;
  final String? unit;
  final Object? defaultValue;
  final ParameterRange? range;
  final List<ParameterOption> options;
  final bool required;
  final Map<String, Object?> metadata;

  Object? normalize(Object? value) {
    if (value == null) {
      return normalizeJsonValue(defaultValue);
    }

    return switch (kind) {
      ParameterKind.length ||
      ParameterKind.angle ||
      ParameterKind.ratio => _normalizeDouble(value),
      ParameterKind.count => _normalizeInt(value),
      ParameterKind.boolean => value is bool ? value : defaultValue,
      ParameterKind.choice => _normalizeChoice(value),
      ParameterKind.text => value is String ? value : defaultValue,
    };
  }

  List<ParameterIssue> validate(Object? value) {
    final normalized = normalize(value);

    if (required && normalized == null) {
      return [
        ParameterIssue(
          parameterId: id,
          severity: ParameterIssueSeverity.error,
          code: 'parameter.required',
          message: 'Parameter is required.',
        ),
      ];
    }

    return [
      if (value != null && !_matchesRawKind(value))
        ParameterIssue(
          parameterId: id,
          severity: ParameterIssueSeverity.error,
          code: 'parameter.type',
          message: 'Parameter has invalid type.',
        ),
      if (value is num && range != null && !range!.contains(value))
        ParameterIssue(
          parameterId: id,
          severity: ParameterIssueSeverity.error,
          code: 'parameter.range',
          message: 'Parameter is outside allowed range.',
        ),
      if (kind == ParameterKind.choice &&
          value is String &&
          options.isNotEmpty &&
          !options.any((option) => option.id == value))
        ParameterIssue(
          parameterId: id,
          severity: ParameterIssueSeverity.error,
          code: 'parameter.choice',
          message: 'Parameter choice is not available.',
        ),
    ];
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'label': label,
      'kind': kind.wireName,
      if (unit != null) 'unit': unit,
      'defaultValue': normalizeJsonValue(defaultValue),
      if (range != null) 'range': range!.toJson(),
      if (options.isNotEmpty)
        'options': options.map((option) => option.toJson()).toList(),
      if (!required) 'required': required,
      ...metadata,
    };
  }

  Object? _normalizeDouble(Object? value) {
    if (value is num) {
      return range?.snap(value.toDouble()) ?? value.toDouble();
    }

    return defaultValue;
  }

  Object? _normalizeInt(Object? value) {
    if (value is num) {
      return range?.snap(value.toDouble()).round() ?? value.toInt();
    }

    return defaultValue;
  }

  Object? _normalizeChoice(Object? value) {
    if (value is String) {
      return value;
    }

    return defaultValue;
  }

  bool _matchesRawKind(Object? value) {
    return switch (kind) {
      ParameterKind.length ||
      ParameterKind.angle ||
      ParameterKind.ratio => value is num,
      ParameterKind.count => value is num,
      ParameterKind.boolean => value is bool,
      ParameterKind.choice => value is String,
      ParameterKind.text => value is String,
    };
  }
}

class ParameterRange {
  const ParameterRange({required this.min, required this.max, this.step});

  factory ParameterRange.fromJson(Map<String, Object?> json) {
    return ParameterRange(
      min: readDouble(json['min'], fallback: double.negativeInfinity),
      max: readDouble(json['max'], fallback: double.infinity),
      step: json['step'] is num ? (json['step']! as num).toDouble() : null,
    );
  }

  final double min;
  final double max;
  final double? step;

  bool contains(num value) {
    return value >= min && value <= max;
  }

  double clamp(num value) {
    return value.toDouble().clamp(min, max);
  }

  double snap(num value) {
    final clamped = clamp(value);
    final stepValue = step;
    if (stepValue == null || stepValue <= 0 || !stepValue.isFinite) {
      return clamped;
    }

    final snapped = min + (((clamped - min) / stepValue).round() * stepValue);
    return snapped.clamp(min, max);
  }

  Map<String, Object?> toJson() {
    return {'min': min, 'max': max, if (step != null) 'step': step};
  }
}

class ParameterOption {
  const ParameterOption({
    required this.id,
    required this.label,
    this.metadata = const {},
  });

  factory ParameterOption.fromJson(Map<String, Object?> json) {
    return ParameterOption(
      id: readString(json['id'], fallback: 'option'),
      label: readString(json['label'], fallback: 'Option'),
      metadata: withoutKeys(json, const {'id', 'label'}),
    );
  }

  final String id;
  final String label;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() {
    return {'id': id, 'label': label, ...metadata};
  }
}

class ParameterIssue {
  const ParameterIssue({
    required this.parameterId,
    required this.severity,
    required this.code,
    required this.message,
  });

  final String parameterId;
  final ParameterIssueSeverity severity;
  final String code;
  final String message;
}

class CoreParameterSchemas {
  const CoreParameterSchemas._();

  static const roundedEnclosure = ParameterSchema(
    id: 'enclosure.rounded_box',
    label: 'Корпус',
    parameters: [
      ParameterDefinition(
        id: 'width',
        label: 'Ширина',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 120.0,
        range: ParameterRange(min: 20, max: 300, step: 1),
      ),
      ParameterDefinition(
        id: 'depth',
        label: 'Глубина',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 70.0,
        range: ParameterRange(min: 20, max: 240, step: 1),
      ),
      ParameterDefinition(
        id: 'height',
        label: 'Высота',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 28.0,
        range: ParameterRange(min: 8, max: 120, step: 1),
      ),
      ParameterDefinition(
        id: 'wallThickness',
        label: 'Стенка',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 2.0,
        range: ParameterRange(min: 0.8, max: 8, step: 0.1),
      ),
      ParameterDefinition(
        id: 'cornerRadius',
        label: 'Радиус',
        kind: ParameterKind.length,
        unit: 'mm',
        defaultValue: 4.0,
        range: ParameterRange(min: 0, max: 40, step: 0.1),
      ),
      ParameterDefinition(
        id: 'lidType',
        label: 'Крышка',
        kind: ParameterKind.choice,
        defaultValue: 'top_screw_lid',
        options: [
          ParameterOption(id: 'none', label: 'Без крышки'),
          ParameterOption(id: 'top_screw_lid', label: 'Верхняя на винтах'),
        ],
      ),
    ],
  );
}
