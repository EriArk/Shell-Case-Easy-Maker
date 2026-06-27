import 'json_helpers.dart';

class FeatureGroup {
  const FeatureGroup({
    required this.id,
    required this.type,
    required this.targetSurface,
    this.pattern = const {},
    this.itemPrototype = const {},
    this.placement = const {},
    this.overrides = const {},
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String targetSurface;
  final Map<String, Object?> pattern;
  final Map<String, Object?> itemPrototype;
  final Map<String, Object?> placement;
  final Map<String, Object?> overrides;
  final Map<String, Object?> metadata;

  factory FeatureGroup.fromJson(Map<String, Object?> json) {
    return FeatureGroup(
      id: readString(json['id'], fallback: 'feature_group'),
      type: readString(json['type'], fallback: 'feature_group'),
      targetSurface: readString(
        json['targetSurface'],
        fallback: 'main_enclosure',
      ),
      pattern: readJsonMap(json['pattern']),
      itemPrototype: readJsonMap(json['itemPrototype']),
      placement: readJsonMap(json['placement']),
      overrides: readJsonMap(json['overrides']),
      metadata: withoutKeys(json, const {
        'id',
        'type',
        'targetSurface',
        'pattern',
        'itemPrototype',
        'placement',
        'overrides',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      'targetSurface': targetSurface,
      if (pattern.isNotEmpty) 'pattern': pattern,
      if (itemPrototype.isNotEmpty) 'itemPrototype': itemPrototype,
      if (placement.isNotEmpty) 'placement': placement,
      if (overrides.isNotEmpty) 'overrides': overrides,
      ...metadata,
    };
  }
}
