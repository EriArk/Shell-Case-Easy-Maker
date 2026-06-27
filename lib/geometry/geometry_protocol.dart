import '../project/json_helpers.dart';
import '../project/project_model.dart';

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
      options: {'linearDeflection': 0.3, 'angularDeflection': 0.35, ...options},
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
      targetIds: _readStringList(json['targetIds']),
      options: readJsonMap(json['options']),
    );
  }

  final String schema;
  final int version;
  final String requestId;
  final GeometryOperation operation;
  final Map<String, Object?> project;
  final List<String> targetIds;
  final Map<String, Object?> options;

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'requestId': requestId,
      'operation': operation.wireName,
      'project': project,
      if (targetIds.isNotEmpty) 'targetIds': targetIds,
      if (options.isNotEmpty) 'options': options,
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
