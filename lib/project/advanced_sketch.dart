import 'feature.dart';
import 'json_helpers.dart';

const advancedSketchFeatureType = 'advanced_sketch';
const sketchEntitiesKey = 'entities';
const sketchProfileIntentKey = 'profileIntent';
const sketchProfileIntentReference = 'reference';
const sketchProfileIntentCut = 'cut';
const sketchProfileIntentAdd = 'add';
const sketchProfileIntents = [
  sketchProfileIntentReference,
  sketchProfileIntentCut,
  sketchProfileIntentAdd,
];

class SketchEntity {
  const SketchEntity({
    required this.id,
    required this.type,
    this.parameters = const {},
    this.metadata = const {},
  });

  final String id;
  final String type;
  final Map<String, Object?> parameters;
  final Map<String, Object?> metadata;

  factory SketchEntity.fromJson(Map<String, Object?> json) {
    return SketchEntity(
      id: readString(json['id'], fallback: 'entity'),
      type: readString(json['type'], fallback: 'unknown'),
      parameters: readJsonMap(json['parameters']),
      metadata: withoutKeys(json, const {'id', 'type', 'parameters'}),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      if (parameters.isNotEmpty) 'parameters': parameters,
      ...metadata,
    };
  }
}

List<SketchEntity> sketchEntitiesForFeature(SemanticFeature feature) {
  if (feature.type != advancedSketchFeatureType) {
    return const [];
  }

  return readObjectList(
    feature.metadata[sketchEntitiesKey],
    SketchEntity.fromJson,
  );
}

SemanticFeature advancedSketchWithEntities(
  SemanticFeature feature,
  List<SketchEntity> entities,
) {
  return SemanticFeature(
    id: feature.id,
    type: feature.type,
    targetSurface: feature.targetSurface,
    operation: feature.operation,
    source: feature.source,
    placement: feature.placement,
    parameters: {...feature.parameters, 'entityCount': entities.length},
    metadata: {
      ...feature.metadata,
      sketchEntitiesKey: [for (final entity in entities) entity.toJson()],
    },
  );
}

SemanticFeature advancedSketchWithUpdatedEntity(
  SemanticFeature feature,
  SketchEntity updatedEntity,
) {
  final entities = sketchEntitiesForFeature(feature);
  var replaced = false;
  final updatedEntities = <SketchEntity>[];

  for (final entity in entities) {
    if (entity.id == updatedEntity.id) {
      updatedEntities.add(updatedEntity);
      replaced = true;
    } else {
      updatedEntities.add(entity);
    }
  }

  if (!replaced) {
    return advancedSketchWithEntities(feature, [...entities, updatedEntity]);
  }

  return advancedSketchWithEntities(feature, updatedEntities);
}

SemanticFeature advancedSketchWithoutEntity(
  SemanticFeature feature,
  String entityId,
) {
  return advancedSketchWithEntities(feature, [
    for (final entity in sketchEntitiesForFeature(feature))
      if (entity.id != entityId) entity,
  ]);
}

SketchEntity defaultSketchRectangleEntity({required String id}) {
  return SketchEntity(
    id: id,
    type: 'rectangle',
    parameters: const {
      'center': [0.0, 0.0],
      'width': 20.0,
      'height': 12.0,
      'cornerRadius': 0.0,
      'rotation': 0.0,
    },
  );
}

SketchEntity defaultSketchCircleEntity({required String id}) {
  return SketchEntity(
    id: id,
    type: 'circle',
    parameters: const {
      'center': [0.0, 0.0],
      'diameter': 12.0,
    },
  );
}

String normalizeSketchProfileIntent(Object? value) {
  final intent = readString(
    value,
    fallback: sketchProfileIntentReference,
  ).trim();
  return sketchProfileIntents.contains(intent)
      ? intent
      : sketchProfileIntentReference;
}

String sketchProfileIntentFor(SketchEntity entity) {
  return normalizeSketchProfileIntent(entity.metadata[sketchProfileIntentKey]);
}

SketchEntity sketchEntityWithProfileIntent(
  SketchEntity entity,
  String profileIntent,
) {
  final normalized = normalizeSketchProfileIntent(profileIntent);
  final metadata = {...entity.metadata};
  if (normalized == sketchProfileIntentReference) {
    metadata.remove(sketchProfileIntentKey);
  } else {
    metadata[sketchProfileIntentKey] = normalized;
  }

  return SketchEntity(
    id: entity.id,
    type: entity.type,
    parameters: entity.parameters,
    metadata: metadata,
  );
}

String nextSketchEntityId(Iterable<SketchEntity> entities, String prefix) {
  var index =
      entities.where((entity) => entity.id.startsWith(prefix)).length + 1;
  while (true) {
    final candidate = '${prefix}_$index';
    if (!entities.any((entity) => entity.id == candidate)) {
      return candidate;
    }
    index += 1;
  }
}
