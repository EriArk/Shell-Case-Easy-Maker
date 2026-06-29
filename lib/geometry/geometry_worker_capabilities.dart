import '../project/json_helpers.dart';
import 'geometry_protocol.dart';

class GeometryWorkerCapabilities {
  const GeometryWorkerCapabilities({
    required this.entrypoint,
    required this.activeBackend,
    required this.backends,
    this.schema = schemaName,
    this.version = currentVersion,
    this.defaultBackend = 'mock',
    this.sourceOfTruth = 'semantic_project',
    this.editableGeneratedGeometry = false,
  });

  static const schemaName = 'shell_case.geometry.worker.capabilities';
  static const currentVersion = 1;

  factory GeometryWorkerCapabilities.fromJson(Map<String, Object?> json) {
    return GeometryWorkerCapabilities(
      schema: readString(json['schema'], fallback: schemaName),
      version: readInt(json['version'], fallback: currentVersion),
      entrypoint: readString(json['entrypoint'], fallback: 'worker'),
      defaultBackend: readString(json['defaultBackend'], fallback: 'mock'),
      activeBackend: readString(json['activeBackend'], fallback: 'mock'),
      sourceOfTruth: readString(
        json['sourceOfTruth'],
        fallback: 'semantic_project',
      ),
      editableGeneratedGeometry: json['editableGeneratedGeometry'] == true,
      backends: readObjectList(
        json['backends'],
        GeometryWorkerBackendCapability.fromJson,
      ),
    );
  }

  factory GeometryWorkerCapabilities.forBackend(String activeBackend) {
    return GeometryWorkerCapabilities(
      entrypoint: 'occt_worker/bin/occt_worker.dart',
      activeBackend: activeBackend,
      backends: const [
        GeometryWorkerBackendCapability(
          id: 'mock',
          status: 'available',
          supportedOperations: [GeometryOperation.previewMesh],
          notes: [
            'Uses Dart MockGeometryService.',
            'Produces deterministic preview mesh only.',
            'Does not generate B-Rep, STEP, STL, or OCCT topology.',
          ],
        ),
        GeometryWorkerBackendCapability(
          id: 'native',
          status: 'stub',
          plannedOperations: [
            GeometryOperation.previewMesh,
            GeometryOperation.exportStep,
            GeometryOperation.exportStl,
            GeometryOperation.validate,
          ],
          issueCodes: ['worker.backend.native_not_implemented'],
          notes: [
            'Reserved for the future OCCT implementation.',
            'Currently returns a structured not-implemented response.',
          ],
        ),
      ],
    );
  }

  final String schema;
  final int version;
  final String entrypoint;
  final String defaultBackend;
  final String activeBackend;
  final String sourceOfTruth;
  final bool editableGeneratedGeometry;
  final List<GeometryWorkerBackendCapability> backends;

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'entrypoint': entrypoint,
      'defaultBackend': defaultBackend,
      'activeBackend': activeBackend,
      'protocol': {
        'requestSchema': GeometryProtocol.requestSchema,
        'responseSchema': GeometryProtocol.responseSchema,
        'version': GeometryProtocol.currentVersion,
      },
      'sourceOfTruth': sourceOfTruth,
      'editableGeneratedGeometry': editableGeneratedGeometry,
      'backends': [for (final backend in backends) backend.toJson()],
    };
  }
}

class GeometryWorkerBackendCapability {
  const GeometryWorkerBackendCapability({
    required this.id,
    required this.status,
    this.supportedOperations = const [],
    this.plannedOperations = const [],
    this.issueCodes = const [],
    this.notes = const [],
  });

  factory GeometryWorkerBackendCapability.fromJson(Map<String, Object?> json) {
    return GeometryWorkerBackendCapability(
      id: readString(json['id'], fallback: 'backend'),
      status: readString(json['status'], fallback: 'unknown'),
      supportedOperations: _readOperations(json['supportedOperations']),
      plannedOperations: _readOperations(json['plannedOperations']),
      issueCodes: _readStringList(json['issueCodes']),
      notes: _readStringList(json['notes']),
    );
  }

  final String id;
  final String status;
  final List<GeometryOperation> supportedOperations;
  final List<GeometryOperation> plannedOperations;
  final List<String> issueCodes;
  final List<String> notes;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'status': status,
      'supportedOperations': [
        for (final operation in supportedOperations) operation.wireName,
      ],
      if (plannedOperations.isNotEmpty)
        'plannedOperations': [
          for (final operation in plannedOperations) operation.wireName,
        ],
      if (issueCodes.isNotEmpty) 'issueCodes': issueCodes,
      if (notes.isNotEmpty) 'notes': notes,
    };
  }
}

List<GeometryOperation> _readOperations(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value
      .whereType<String>()
      .map(GeometryOperation.fromWireName)
      .toList(growable: false);
}

List<String> _readStringList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}
