import '../project/json_helpers.dart';
import '../project/project_model.dart';
import '../patterns/pattern_layout.dart';

class GeometryProtocol {
  const GeometryProtocol._();

  static const requestSchema = 'shell_case.geometry.request';
  static const responseSchema = 'shell_case.geometry.response';
  static const currentVersion = 1;
}

enum GeometryOperation {
  previewMesh('preview_mesh'),
  exportStep('export_step'),
  exportStl('export_stl'),
  validate('validate');

  const GeometryOperation(this.wireName);

  final String wireName;

  static GeometryOperation fromWireName(String value) {
    return GeometryOperation.values.firstWhere(
      (operation) => operation.wireName == value,
      orElse: () => GeometryOperation.previewMesh,
    );
  }
}

enum GeometryResponseStatus {
  ok('ok'),
  warning('warning'),
  error('error');

  const GeometryResponseStatus(this.wireName);

  final String wireName;

  static GeometryResponseStatus fromWireName(String value) {
    return GeometryResponseStatus.values.firstWhere(
      (status) => status.wireName == value,
      orElse: () => GeometryResponseStatus.error,
    );
  }
}

enum GeometryIssueSeverity {
  info('info'),
  warning('warning'),
  error('error');

  const GeometryIssueSeverity(this.wireName);

  final String wireName;

  static GeometryIssueSeverity fromWireName(String value) {
    return GeometryIssueSeverity.values.firstWhere(
      (severity) => severity.wireName == value,
      orElse: () => GeometryIssueSeverity.error,
    );
  }
}

class GeometryRequest {
  const GeometryRequest({
    this.schema = GeometryProtocol.requestSchema,
    this.version = GeometryProtocol.currentVersion,
    required this.requestId,
    required this.operation,
    required this.project,
    this.featureIntents = const [],
    this.targetIds = const [],
    this.options = const {},
  });

  factory GeometryRequest.previewMesh(
    ProjectModel project, {
    required String requestId,
    Map<String, Object?> options = const {},
  }) {
    return GeometryRequest(
      requestId: requestId,
      operation: GeometryOperation.previewMesh,
      project: project.toJson(),
      featureIntents: GeometryFeatureIntent.fromProject(project),
      options: {'linearDeflection': 0.3, 'angularDeflection': 0.35, ...options},
    );
  }

  factory GeometryRequest.exportStep(
    ProjectModel project, {
    required String requestId,
    required String outputPath,
    Map<String, Object?> options = const {},
  }) {
    return GeometryRequest(
      requestId: requestId,
      operation: GeometryOperation.exportStep,
      project: project.toJson(),
      featureIntents: GeometryFeatureIntent.fromProject(project),
      options: {'outputPath': outputPath, ...options},
    );
  }

  factory GeometryRequest.exportStl(
    ProjectModel project, {
    required String requestId,
    required String outputPath,
    Map<String, Object?> options = const {},
  }) {
    return GeometryRequest(
      requestId: requestId,
      operation: GeometryOperation.exportStl,
      project: project.toJson(),
      featureIntents: GeometryFeatureIntent.fromProject(project),
      options: {'outputPath': outputPath, ...options},
    );
  }

  factory GeometryRequest.fromJson(Map<String, Object?> json) {
    return GeometryRequest(
      schema: readString(
        json['schema'],
        fallback: GeometryProtocol.requestSchema,
      ),
      version: readInt(
        json['version'],
        fallback: GeometryProtocol.currentVersion,
      ),
      requestId: readString(json['requestId'], fallback: 'request'),
      operation: GeometryOperation.fromWireName(
        readString(
          json['operation'],
          fallback: GeometryOperation.previewMesh.wireName,
        ),
      ),
      project: readJsonMap(json['project']),
      featureIntents: readObjectList(
        json['featureIntents'],
        GeometryFeatureIntent.fromJson,
      ),
      targetIds: _readStringList(json['targetIds']),
      options: readJsonMap(json['options']),
    );
  }

  final String schema;
  final int version;
  final String requestId;
  final GeometryOperation operation;
  final Map<String, Object?> project;
  final List<GeometryFeatureIntent> featureIntents;
  final List<String> targetIds;
  final Map<String, Object?> options;

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'requestId': requestId,
      'operation': operation.wireName,
      'project': project,
      if (featureIntents.isNotEmpty)
        'featureIntents': featureIntents
            .map((intent) => intent.toJson())
            .toList(),
      if (targetIds.isNotEmpty) 'targetIds': targetIds,
      if (options.isNotEmpty) 'options': options,
    };
  }
}

class GeometryFeatureIntent {
  const GeometryFeatureIntent({
    required this.id,
    required this.semanticType,
    required this.kind,
    required this.targetSurface,
    required this.operation,
    this.parameters = const {},
    this.placement = const {},
    this.source = const {},
    this.items = const [],
    this.metadata = const {},
  });

  factory GeometryFeatureIntent.fromJson(Map<String, Object?> json) {
    return GeometryFeatureIntent(
      id: readString(json['id'], fallback: 'feature_intent'),
      semanticType: readString(json['semanticType'], fallback: 'feature'),
      kind: readString(json['kind'], fallback: 'feature'),
      targetSurface: readString(json['targetSurface'], fallback: ''),
      operation: readString(json['operation'], fallback: 'helper'),
      parameters: readJsonMap(json['parameters']),
      placement: readJsonMap(json['placement']),
      source: readJsonMap(json['source']),
      items: readObjectList(json['items'], GeometryFeatureItemIntent.fromJson),
      metadata: withoutKeys(json, const {
        'id',
        'semanticType',
        'kind',
        'targetSurface',
        'operation',
        'parameters',
        'placement',
        'source',
        'items',
      }),
    );
  }

  factory GeometryFeatureIntent.fromFeature(SemanticFeature feature) {
    return GeometryFeatureIntent(
      id: feature.id,
      semanticType: 'feature',
      kind: feature.type,
      targetSurface: feature.targetSurface,
      operation: feature.operation,
      parameters: feature.parameters,
      placement: feature.placement ?? const {},
      source: feature.source ?? const {},
      metadata: feature.metadata,
    );
  }

  factory GeometryFeatureIntent.fromFeatureGroup(
    ProjectModel project,
    FeatureGroup group,
  ) {
    return GeometryFeatureIntent(
      id: group.id,
      semanticType: 'feature_group',
      kind: group.type,
      targetSurface: group.targetSurface,
      operation: 'composite',
      parameters: {
        if (group.pattern.isNotEmpty) 'pattern': group.pattern,
        if (group.itemPrototype.isNotEmpty)
          'itemPrototype': group.itemPrototype,
        if (group.overrides.isNotEmpty) 'overrides': group.overrides,
      },
      placement: group.placement,
      source: _featureGroupSource(group),
      items: _featureGroupItems(project, group),
      metadata: group.metadata,
    );
  }

  static List<GeometryFeatureIntent> fromProject(ProjectModel project) {
    return [
      for (final feature in project.features)
        GeometryFeatureIntent.fromFeature(feature),
      for (final group in project.featureGroups)
        GeometryFeatureIntent.fromFeatureGroup(project, group),
    ];
  }

  final String id;
  final String semanticType;
  final String kind;
  final String targetSurface;
  final String operation;
  final Map<String, Object?> parameters;
  final Map<String, Object?> placement;
  final Map<String, Object?> source;
  final List<GeometryFeatureItemIntent> items;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'semanticType': semanticType,
      'kind': kind,
      'targetSurface': targetSurface,
      'operation': operation,
      if (parameters.isNotEmpty) 'parameters': parameters,
      if (placement.isNotEmpty) 'placement': placement,
      if (source.isNotEmpty) 'source': source,
      if (items.isNotEmpty)
        'items': items.map((item) => item.toJson()).toList(),
      ...metadata,
    };
  }
}

class GeometryFeatureItemIntent {
  const GeometryFeatureItemIntent({
    required this.id,
    required this.index,
    required this.position,
    this.parameters = const {},
    this.source = const {},
  });

  factory GeometryFeatureItemIntent.fromJson(Map<String, Object?> json) {
    return GeometryFeatureItemIntent(
      id: readString(json['id'], fallback: 'feature_item'),
      index: readInt(json['index'], fallback: 0),
      position: readDoubleList(json['position'], fallback: const []),
      parameters: readJsonMap(json['parameters']),
      source: readJsonMap(json['source']),
    );
  }

  final String id;
  final int index;
  final List<double> position;
  final Map<String, Object?> parameters;
  final Map<String, Object?> source;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'index': index,
      'position': position,
      if (parameters.isNotEmpty) 'parameters': parameters,
      if (source.isNotEmpty) 'source': source,
    };
  }
}

class GeometryResponse {
  const GeometryResponse({
    this.schema = GeometryProtocol.responseSchema,
    this.version = GeometryProtocol.currentVersion,
    required this.requestId,
    required this.status,
    required this.backend,
    this.previewMesh,
    this.artifacts = const [],
    this.issues = const [],
    this.metrics = const {},
  });

  factory GeometryResponse.fromJson(Map<String, Object?> json) {
    return GeometryResponse(
      schema: readString(
        json['schema'],
        fallback: GeometryProtocol.responseSchema,
      ),
      version: readInt(
        json['version'],
        fallback: GeometryProtocol.currentVersion,
      ),
      requestId: readString(json['requestId'], fallback: 'request'),
      status: GeometryResponseStatus.fromWireName(
        readString(
          json['status'],
          fallback: GeometryResponseStatus.error.wireName,
        ),
      ),
      backend: readString(json['backend'], fallback: 'unknown'),
      previewMesh: json['previewMesh'] is Map<Object?, Object?>
          ? PreviewMesh.fromJson(readJsonMap(json['previewMesh']))
          : null,
      artifacts: readObjectList(json['artifacts'], GeometryArtifact.fromJson),
      issues: readObjectList(json['issues'], GeometryIssue.fromJson),
      metrics: readJsonMap(json['metrics']),
    );
  }

  final String schema;
  final int version;
  final String requestId;
  final GeometryResponseStatus status;
  final String backend;
  final PreviewMesh? previewMesh;
  final List<GeometryArtifact> artifacts;
  final List<GeometryIssue> issues;
  final Map<String, Object?> metrics;

  bool get hasErrors =>
      status == GeometryResponseStatus.error ||
      issues.any((issue) => issue.severity == GeometryIssueSeverity.error);

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'requestId': requestId,
      'status': status.wireName,
      'backend': backend,
      if (previewMesh != null) 'previewMesh': previewMesh!.toJson(),
      if (artifacts.isNotEmpty)
        'artifacts': artifacts.map((artifact) => artifact.toJson()).toList(),
      if (issues.isNotEmpty)
        'issues': issues.map((issue) => issue.toJson()).toList(),
      if (metrics.isNotEmpty) 'metrics': metrics,
    };
  }
}

class PreviewMesh {
  const PreviewMesh({
    required this.units,
    required this.vertices,
    required this.triangles,
    required this.bounds,
    required this.surfaces,
    this.metadata = const {},
  });

  factory PreviewMesh.fromJson(Map<String, Object?> json) {
    return PreviewMesh(
      units: readString(json['units'], fallback: 'mm'),
      vertices: readDoubleList(json['vertices'], fallback: const []),
      triangles: _readIntList(json['triangles']),
      bounds: json['bounds'] is Map<Object?, Object?>
          ? GeometryBounds.fromJson(readJsonMap(json['bounds']))
          : GeometryBounds.empty(),
      surfaces: readObjectList(
        json['surfaces'],
        PreviewSurfaceMapping.fromJson,
      ),
      metadata: withoutKeys(json, const {
        'units',
        'vertices',
        'triangles',
        'bounds',
        'surfaces',
      }),
    );
  }

  final String units;
  final List<double> vertices;
  final List<int> triangles;
  final GeometryBounds bounds;
  final List<PreviewSurfaceMapping> surfaces;
  final Map<String, Object?> metadata;

  int get vertexCount => vertices.length ~/ 3;

  int get triangleCount => triangles.length ~/ 3;

  Map<String, Object?> toJson() {
    return {
      'units': units,
      'vertices': vertices,
      'triangles': triangles,
      'bounds': bounds.toJson(),
      'surfaces': surfaces.map((surface) => surface.toJson()).toList(),
      ...metadata,
    };
  }
}

class PreviewSurfaceMapping {
  const PreviewSurfaceMapping({
    required this.semanticId,
    required this.label,
    required this.triangleRanges,
    this.metadata = const {},
  });

  factory PreviewSurfaceMapping.fromJson(Map<String, Object?> json) {
    return PreviewSurfaceMapping(
      semanticId: readString(json['semanticId'], fallback: 'surface'),
      label: readString(json['label'], fallback: 'Surface'),
      triangleRanges: readObjectList(
        json['triangleRanges'],
        PreviewTriangleRange.fromJson,
      ),
      metadata: withoutKeys(json, const {
        'semanticId',
        'label',
        'triangleRanges',
      }),
    );
  }

  final String semanticId;
  final String label;
  final List<PreviewTriangleRange> triangleRanges;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() {
    return {
      'semanticId': semanticId,
      'label': label,
      'triangleRanges': triangleRanges.map((range) => range.toJson()).toList(),
      ...metadata,
    };
  }
}

class PreviewTriangleRange {
  const PreviewTriangleRange({required this.start, required this.count});

  factory PreviewTriangleRange.fromJson(Map<String, Object?> json) {
    return PreviewTriangleRange(
      start: readInt(json['start'], fallback: 0),
      count: readInt(json['count'], fallback: 0),
    );
  }

  final int start;
  final int count;

  Map<String, Object?> toJson() {
    return {'start': start, 'count': count};
  }
}

class GeometryBounds {
  const GeometryBounds({required this.min, required this.max});

  factory GeometryBounds.empty() {
    return const GeometryBounds(min: [0, 0, 0], max: [0, 0, 0]);
  }

  factory GeometryBounds.fromJson(Map<String, Object?> json) {
    return GeometryBounds(
      min: readDoubleList(json['min'], fallback: const [0, 0, 0]),
      max: readDoubleList(json['max'], fallback: const [0, 0, 0]),
    );
  }

  final List<double> min;
  final List<double> max;

  Map<String, Object?> toJson() {
    return {'min': min, 'max': max};
  }
}

class GeometryArtifact {
  const GeometryArtifact({
    required this.type,
    required this.path,
    this.metadata = const {},
  });

  factory GeometryArtifact.fromJson(Map<String, Object?> json) {
    return GeometryArtifact(
      type: readString(json['type'], fallback: 'artifact'),
      path: readString(json['path'], fallback: ''),
      metadata: withoutKeys(json, const {'type', 'path'}),
    );
  }

  final String type;
  final String path;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() {
    return {'type': type, 'path': path, ...metadata};
  }
}

class GeometryIssue {
  const GeometryIssue({
    required this.severity,
    required this.code,
    required this.message,
    this.targetId,
  });

  factory GeometryIssue.fromJson(Map<String, Object?> json) {
    return GeometryIssue(
      severity: GeometryIssueSeverity.fromWireName(
        readString(
          json['severity'],
          fallback: GeometryIssueSeverity.error.wireName,
        ),
      ),
      code: readString(json['code'], fallback: 'geometry.issue'),
      message: readString(json['message'], fallback: 'Geometry issue'),
      targetId: json['targetId'] is String ? json['targetId']! as String : null,
    );
  }

  final GeometryIssueSeverity severity;
  final String code;
  final String message;
  final String? targetId;

  Map<String, Object?> toJson() {
    return {
      'severity': severity.wireName,
      'code': code,
      'message': message,
      if (targetId != null) 'targetId': targetId,
    };
  }
}

Map<String, Object?> _featureGroupSource(FeatureGroup group) {
  final source = <String, Object?>{};
  final sourcePlacementId = readString(
    group.pattern['sourcePlacementId'],
    fallback: '',
  );
  final sourceTemplateId = readString(
    group.pattern['sourceTemplateId'],
    fallback: '',
  );
  final componentPlacementId = readString(
    group.placement['componentPlacementId'],
    fallback: '',
  );

  if (sourcePlacementId.isNotEmpty) {
    source['componentPlacementId'] = sourcePlacementId;
  } else if (componentPlacementId.isNotEmpty) {
    source['componentPlacementId'] = componentPlacementId;
  }
  if (sourceTemplateId.isNotEmpty) {
    source['componentTemplateId'] = sourceTemplateId;
  }

  return source;
}

List<GeometryFeatureItemIntent> _featureGroupItems(
  ProjectModel project,
  FeatureGroup group,
) {
  return switch (group.type) {
    'button_group' => _buttonGroupItems(group),
    'standoff_mounts' => _standoffMountItems(project, group),
    _ => const [],
  };
}

List<GeometryFeatureItemIntent> _buttonGroupItems(FeatureGroup group) {
  final positions = PatternLayoutEngine.buttonGroupPositions(group);
  final sourceEntries = readJsonMapList(group.pattern['switchPositions']);
  final surfacePosition = readDoubleList(
    group.placement['surfacePosition'],
    fallback: const [],
  );
  final offsetX = surfacePosition.length >= 2 ? surfacePosition[0] : 0.0;
  final offsetY = surfacePosition.length >= 2 ? surfacePosition[1] : 0.0;

  return [
    for (var index = 0; index < positions.length; index++)
      GeometryFeatureItemIntent(
        id: _itemId(group.id, index, sourceEntries),
        index: index,
        position: [positions[index].x + offsetX, positions[index].y + offsetY],
        parameters: group.itemPrototype,
        source: _sourceEntryAt(sourceEntries, index),
      ),
  ];
}

List<GeometryFeatureItemIntent> _standoffMountItems(
  ProjectModel project,
  FeatureGroup group,
) {
  final template = _templateForGroup(project, group);
  final positions = PatternLayoutEngine.standoffMountPositions(
    group,
    fallbackTemplate: template,
  );
  final sourceEntries = readJsonMapList(group.pattern['holePositions']);
  final fallbackEntries = sourceEntries.isNotEmpty
      ? sourceEntries
      : [
          for (final hole in template?.mountingHoles ?? const <MountingHole>[])
            hole.toJson(),
        ];

  return [
    for (var index = 0; index < positions.length; index++)
      GeometryFeatureItemIntent(
        id: _itemId(group.id, index, fallbackEntries),
        index: index,
        position: [positions[index].x, positions[index].y],
        parameters: group.itemPrototype,
        source: _sourceEntryAt(fallbackEntries, index),
      ),
  ];
}

ComponentTemplate? _templateForGroup(ProjectModel project, FeatureGroup group) {
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

String _itemId(
  String groupId,
  int index,
  List<Map<String, Object?>> sourceEntries,
) {
  final sourceId = readString(
    index < sourceEntries.length ? sourceEntries[index]['id'] : null,
    fallback: '',
  );
  if (sourceId.isNotEmpty) {
    return '$groupId.$sourceId';
  }

  return '$groupId.item_${index + 1}';
}

Map<String, Object?> _sourceEntryAt(
  List<Map<String, Object?>> entries,
  int index,
) {
  if (index >= entries.length) {
    return const {};
  }

  return entries[index];
}

List<String> _readStringList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}

List<int> _readIntList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value
      .whereType<num>()
      .map((item) => item.toInt())
      .toList(growable: false);
}
