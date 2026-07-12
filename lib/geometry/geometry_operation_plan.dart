import '../project/advanced_sketch.dart';
import '../project/json_helpers.dart';
import 'geometry_protocol.dart';

class GeometryBuildOperation {
  const GeometryBuildOperation({
    required this.id,
    required this.kind,
    required this.semanticId,
    required this.targetSurface,
    required this.operation,
    this.parentId,
    this.itemIndex,
    this.parameters = const {},
    this.placement = const {},
    this.source = const {},
  });

  factory GeometryBuildOperation.fromJson(Map<String, Object?> json) {
    return GeometryBuildOperation(
      id: readString(json['id'], fallback: 'geometry_operation'),
      kind: readString(json['kind'], fallback: 'operation'),
      semanticId: readString(json['semanticId'], fallback: 'semantic'),
      targetSurface: readString(json['targetSurface'], fallback: ''),
      operation: readString(json['operation'], fallback: 'helper'),
      parentId: json['parentId'] is String ? json['parentId']! as String : null,
      itemIndex: json['itemIndex'] is num
          ? (json['itemIndex']! as num).toInt()
          : null,
      parameters: readJsonMap(json['parameters']),
      placement: readJsonMap(json['placement']),
      source: readJsonMap(json['source']),
    );
  }

  final String id;
  final String kind;
  final String semanticId;
  final String targetSurface;
  final String operation;
  final String? parentId;
  final int? itemIndex;
  final Map<String, Object?> parameters;
  final Map<String, Object?> placement;
  final Map<String, Object?> source;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'kind': kind,
      'semanticId': semanticId,
      'targetSurface': targetSurface,
      'operation': operation,
      if (parentId != null) 'parentId': parentId,
      if (itemIndex != null) 'itemIndex': itemIndex,
      if (parameters.isNotEmpty) 'parameters': parameters,
      if (placement.isNotEmpty) 'placement': placement,
      if (source.isNotEmpty) 'source': source,
    };
  }
}

class GeometryOperationPlanner {
  const GeometryOperationPlanner._();

  static List<GeometryBuildOperation> fromRequest(GeometryRequest request) {
    return [
      for (final intent in request.featureIntents)
        ..._operationsForIntent(intent),
    ];
  }

  static List<GeometryBuildOperation> _operationsForIntent(
    GeometryFeatureIntent intent,
  ) {
    if (intent.semanticType == 'feature_group') {
      return _operationsForFeatureGroup(intent);
    }

    if (intent.kind == advancedSketchFeatureType) {
      return _operationsForAdvancedSketch(intent);
    }

    return [
      GeometryBuildOperation(
        id: intent.id,
        kind: _operationKindForFeature(intent.kind),
        semanticId: intent.id,
        targetSurface: intent.targetSurface,
        operation: intent.operation,
        parameters: intent.parameters,
        placement: intent.placement,
        source: intent.source,
      ),
    ];
  }

  static List<GeometryBuildOperation> _operationsForAdvancedSketch(
    GeometryFeatureIntent intent,
  ) {
    final helper = GeometryBuildOperation(
      id: intent.id,
      kind: _operationKindForFeature(intent.kind),
      semanticId: intent.id,
      targetSurface: intent.targetSurface,
      operation: intent.operation,
      parameters: intent.parameters,
      placement: intent.placement,
      source: intent.source,
    );
    final entities = readObjectList(
      intent.metadata[sketchEntitiesKey],
      SketchEntity.fromJson,
    );

    return [
      helper,
      for (var index = 0; index < entities.length; index++)
        if (sketchProfileIntentFor(entities[index]) !=
            sketchProfileIntentReference)
          _operationForSketchProfileEntity(intent, entities[index], index),
    ];
  }

  static GeometryBuildOperation _operationForSketchProfileEntity(
    GeometryFeatureIntent intent,
    SketchEntity entity,
    int index,
  ) {
    final profileIntent = sketchProfileIntentFor(entity);
    final operation = switch (profileIntent) {
      sketchProfileIntentCut => 'negative',
      sketchProfileIntentAdd => 'positive',
      _ => 'helper',
    };

    return GeometryBuildOperation(
      id: '${intent.id}.${entity.id}',
      kind: 'sketch.profile.$profileIntent',
      semanticId: '${intent.id}.${entity.id}',
      targetSurface: intent.targetSurface,
      operation: operation,
      parentId: intent.id,
      itemIndex: index,
      parameters: _sketchProfileEntityParameters(entity, profileIntent),
      placement: intent.placement,
      source: {
        ...intent.source,
        'sketchId': intent.id,
        'sketchEntityId': entity.id,
        'profileIntent': profileIntent,
      },
    );
  }

  static List<GeometryBuildOperation> _operationsForFeatureGroup(
    GeometryFeatureIntent intent,
  ) {
    if (intent.items.isEmpty) {
      return [
        GeometryBuildOperation(
          id: intent.id,
          kind: _operationKindForFeatureGroup(intent.kind),
          semanticId: intent.id,
          targetSurface: intent.targetSurface,
          operation: intent.operation,
          parameters: intent.parameters,
          placement: intent.placement,
          source: intent.source,
        ),
      ];
    }

    return [
      for (final item in intent.items)
        GeometryBuildOperation(
          id: item.id,
          kind: _operationKindForFeatureGroupItem(intent.kind),
          semanticId: item.id,
          targetSurface: intent.targetSurface,
          operation: _operationForFeatureGroupItem(intent.kind),
          parentId: intent.id,
          itemIndex: item.index,
          parameters: {
            ...intent.parameters,
            ...item.parameters,
            'position': item.position,
          },
          placement: intent.placement,
          source: {...intent.source, ...item.source},
        ),
    ];
  }
}

Map<String, Object?> _sketchProfileEntityParameters(
  SketchEntity entity,
  String profileIntent,
) {
  final center = readDoubleList(
    entity.parameters['center'],
    fallback: const [0.0, 0.0],
  );
  final centerX = center.isNotEmpty ? center[0] : 0.0;
  final centerY = center.length > 1 ? center[1] : 0.0;
  final depth = _sketchProfileEntityDepth(entity);
  final base = <String, Object?>{
    'entityType': entity.type,
    'profileIntent': profileIntent,
    'center': [centerX, centerY],
  };
  if (depth != null) {
    base['depth'] = depth;
  }

  return switch (entity.type) {
    'rectangle' => {
      ...base,
      'width': readDouble(entity.parameters['width'], fallback: 20.0),
      'height': readDouble(entity.parameters['height'], fallback: 12.0),
      'cornerRadius': readDouble(
        entity.parameters['cornerRadius'],
        fallback: 0.0,
      ),
      'rotation': readDouble(entity.parameters['rotation'], fallback: 0.0),
    },
    'circle' => {
      ...base,
      'diameter': readDouble(entity.parameters['diameter'], fallback: 12.0),
    },
    _ => {...base, if (entity.parameters.isNotEmpty) 'raw': entity.parameters},
  };
}

double? _sketchProfileEntityDepth(SketchEntity entity) {
  if (entity.parameters.containsKey('depth')) {
    return readDouble(entity.parameters['depth'], fallback: 3.0);
  }
  if (entity.parameters.containsKey('protrusion')) {
    return readDouble(entity.parameters['protrusion'], fallback: 3.0);
  }
  return null;
}

String _operationKindForFeature(String featureKind) {
  return switch (featureKind) {
    'usb_c_cutout' => 'cutout.usb_c',
    'circular_cutout' => 'cutout.circular',
    'rectangular_cutout' => 'cutout.rectangular',
    'glass_recess' => 'recess.glass',
    'advanced_sketch' => 'helper.advanced_sketch',
    _ => 'feature.$featureKind',
  };
}

String _operationKindForFeatureGroup(String groupKind) {
  return switch (groupKind) {
    'button_group' => 'group.button',
    'standoff_mounts' => 'group.standoff_mounts',
    _ => 'group.$groupKind',
  };
}

String _operationKindForFeatureGroupItem(String groupKind) {
  return switch (groupKind) {
    'button_group' => 'cutout.button',
    'standoff_mounts' => 'mount.standoff',
    _ => 'group_item.$groupKind',
  };
}

String _operationForFeatureGroupItem(String groupKind) {
  return switch (groupKind) {
    'button_group' => 'negative',
    'standoff_mounts' => 'positive',
    _ => 'composite',
  };
}
