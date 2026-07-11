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
