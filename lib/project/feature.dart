import 'json_helpers.dart';

class SemanticFeature {
  const SemanticFeature({
    required this.id,
    required this.type,
    required this.targetSurface,
    required this.operation,
    this.parameters = const {},
    this.source,
    this.placement,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String targetSurface;
  final String operation;
  final Map<String, Object?> parameters;
  final Map<String, Object?>? source;
  final Map<String, Object?>? placement;
  final Map<String, Object?> metadata;

  factory SemanticFeature.fromJson(Map<String, Object?> json) {
    return SemanticFeature(
      id: readString(json['id'], fallback: 'feature'),
      type: readString(json['type'], fallback: 'feature'),
      targetSurface: readString(
        json['targetSurface'],
        fallback: 'main_enclosure',
      ),
      operation: readString(json['operation'], fallback: 'helper'),
      parameters: readJsonMap(json['parameters']),
      source: json['source'] is Map<Object?, Object?>
          ? readJsonMap(json['source'])
          : null,
      placement: json['placement'] is Map<Object?, Object?>
          ? readJsonMap(json['placement'])
          : null,
      metadata: withoutKeys(json, const {
        'id',
        'type',
        'targetSurface',
        'operation',
        'parameters',
        'source',
        'placement',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      'targetSurface': targetSurface,
      'operation': operation,
      if (source != null) 'source': source,
      if (placement != null) 'placement': placement,
      if (parameters.isNotEmpty) 'parameters': parameters,
      ...metadata,
    };
  }
}
