import 'dart:convert';

class ProjectModel {
  const ProjectModel({
    this.schema = currentSchema,
    this.version = currentVersion,
    this.units = 'mm',
    required this.projectName,
    required this.printerProfile,
    required this.bodies,
    required this.componentPlacements,
    required this.features,
  });

  static const currentSchema = 'abyss-enclosure-project';
  static const currentVersion = 1;

  final String schema;
  final int version;
  final String units;
  final String projectName;
  final String printerProfile;
  final List<ProjectBody> bodies;
  final List<ComponentPlacement> componentPlacements;
  final List<SemanticFeature> features;

  factory ProjectModel.initial() {
    return const ProjectModel(
      projectName: 'Sample Button Board Case',
      printerProfile: 'fdm_04_normal',
      bodies: [
        ProjectBody(
          id: 'main_enclosure',
          type: 'enclosure',
          shape: 'rounded_box',
          size: [120, 70, 28],
          wallThickness: 2,
          cornerRadius: 4,
          lid: LidSpec(type: 'top_screw_lid', clearanceProfile: 'fdm_normal'),
        ),
      ],
      componentPlacements: [
        ComponentPlacement(
          id: 'button_board_placement',
          templateId: 'custom_button_board_v1',
          position: [0, 0, 4],
          rotation: [0, 0, 0],
          mountingSide: 'bottom_inside',
          locked: false,
        ),
      ],
      features: [
        SemanticFeature(
          id: 'front_usb_c',
          type: 'usb_c_cutout',
          targetSurface: 'main_enclosure.front_wall.outer',
          operation: 'negative',
          parameters: {
            'width': 10.5,
            'height': 4.2,
            'cornerRadius': 1.0,
            'clearanceProfile': 'fdm_normal',
          },
        ),
        SemanticFeature(
          id: 'abxy_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          operation: 'composite',
          parameters: {
            'pattern': 'diamond',
            'count': 4,
            'diameter': 8.0,
            'mode': 'plunger',
          },
        ),
      ],
    );
  }

  factory ProjectModel.fromJson(Map<String, Object?> json) {
    return ProjectModel(
      schema: json['schema'] as String? ?? currentSchema,
      version: (json['version'] as num?)?.toInt() ?? currentVersion,
      units: json['units'] as String? ?? 'mm',
      projectName: json['projectName'] as String? ?? 'Untitled Device',
      printerProfile: json['printerProfile'] as String? ?? 'fdm_04_normal',
      bodies: _readObjectList(json['bodies'], ProjectBody.fromJson),
      componentPlacements: _readObjectList(
        json['componentPlacements'],
        ComponentPlacement.fromJson,
      ),
      features: _readObjectList(json['features'], SemanticFeature.fromJson),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'units': units,
      'projectName': projectName,
      'printerProfile': printerProfile,
      'bodies': bodies.map((body) => body.toJson()).toList(),
      'componentPlacements': componentPlacements
          .map((placement) => placement.toJson())
          .toList(),
      'features': features.map((feature) => feature.toJson()).toList(),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  static List<T> _readObjectList<T>(
    Object? rawValue,
    T Function(Map<String, Object?> json) fromJson,
  ) {
    if (rawValue is! List<Object?>) {
      return const [];
    }

    return rawValue
        .whereType<Map<Object?, Object?>>()
        .map((entry) => fromJson(Map<String, Object?>.from(entry)))
        .toList(growable: false);
  }
}

class ProjectBody {
  const ProjectBody({
    required this.id,
    required this.type,
    required this.shape,
    required this.size,
    required this.wallThickness,
    required this.cornerRadius,
    this.lid,
  });

  final String id;
  final String type;
  final String shape;
  final List<double> size;
  final double wallThickness;
  final double cornerRadius;
  final LidSpec? lid;

  factory ProjectBody.fromJson(Map<String, Object?> json) {
    return ProjectBody(
      id: json['id'] as String? ?? 'body',
      type: json['type'] as String? ?? 'enclosure',
      shape: json['shape'] as String? ?? 'rounded_box',
      size: _readDoubleList(json['size'], fallback: const [120, 70, 28]),
      wallThickness: _readDouble(json['wallThickness'], fallback: 2),
      cornerRadius: _readDouble(json['cornerRadius'], fallback: 4),
      lid: json['lid'] is Map<Object?, Object?>
          ? LidSpec.fromJson(
              Map<String, Object?>.from(json['lid']! as Map<Object?, Object?>),
            )
          : null,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      'shape': shape,
      'size': size,
      'wallThickness': wallThickness,
      'cornerRadius': cornerRadius,
      if (lid != null) 'lid': lid!.toJson(),
    };
  }
}

class LidSpec {
  const LidSpec({required this.type, required this.clearanceProfile});

  final String type;
  final String clearanceProfile;

  factory LidSpec.fromJson(Map<String, Object?> json) {
    return LidSpec(
      type: json['type'] as String? ?? 'none',
      clearanceProfile: json['clearanceProfile'] as String? ?? 'fdm_normal',
    );
  }

  Map<String, Object?> toJson() {
    return {'type': type, 'clearanceProfile': clearanceProfile};
  }
}

class ComponentPlacement {
  const ComponentPlacement({
    required this.id,
    required this.templateId,
    required this.position,
    required this.rotation,
    required this.mountingSide,
    required this.locked,
  });

  final String id;
  final String templateId;
  final List<double> position;
  final List<double> rotation;
  final String mountingSide;
  final bool locked;

  factory ComponentPlacement.fromJson(Map<String, Object?> json) {
    return ComponentPlacement(
      id: json['id'] as String? ?? 'component_placement',
      templateId: json['templateId'] as String? ?? 'component_template',
      position: _readDoubleList(json['position'], fallback: const [0, 0, 0]),
      rotation: _readDoubleList(json['rotation'], fallback: const [0, 0, 0]),
      mountingSide: json['mountingSide'] as String? ?? 'bottom_inside',
      locked: json['locked'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'position': position,
      'rotation': rotation,
      'mountingSide': mountingSide,
      'locked': locked,
    };
  }
}

class SemanticFeature {
  const SemanticFeature({
    required this.id,
    required this.type,
    required this.targetSurface,
    required this.operation,
    required this.parameters,
  });

  final String id;
  final String type;
  final String targetSurface;
  final String operation;
  final Map<String, Object?> parameters;

  factory SemanticFeature.fromJson(Map<String, Object?> json) {
    return SemanticFeature(
      id: json['id'] as String? ?? 'feature',
      type: json['type'] as String? ?? 'feature',
      targetSurface: json['targetSurface'] as String? ?? 'main_enclosure',
      operation: json['operation'] as String? ?? 'helper',
      parameters: json['parameters'] is Map<Object?, Object?>
          ? Map<String, Object?>.from(
              json['parameters']! as Map<Object?, Object?>,
            )
          : const {},
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      'targetSurface': targetSurface,
      'operation': operation,
      'parameters': parameters,
    };
  }
}

double _readDouble(Object? rawValue, {required double fallback}) {
  if (rawValue is num) {
    return rawValue.toDouble();
  }

  return fallback;
}

List<double> _readDoubleList(
  Object? rawValue, {
  required List<double> fallback,
}) {
  if (rawValue is! List<Object?>) {
    return fallback;
  }

  final values = rawValue.whereType<num>().map((value) => value.toDouble());
  return values.toList(growable: false);
}
