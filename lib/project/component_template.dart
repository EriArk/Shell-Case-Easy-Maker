import 'json_helpers.dart';
import 'schema.dart';

class ComponentTemplate {
  const ComponentTemplate({
    this.schema = ComponentTemplateSchema.name,
    this.version = ComponentTemplateSchema.currentVersion,
    required this.id,
    required this.name,
    this.units = 'mm',
    required this.board,
    this.mountingHoles = const [],
    this.features = const [],
    this.zones = const [],
    this.metadata = const {},
  });

  final String schema;
  final int version;
  final String id;
  final String name;
  final String units;
  final ComponentBoard board;
  final List<MountingHole> mountingHoles;
  final List<ComponentFeature> features;
  final List<ComponentZone> zones;
  final Map<String, Object?> metadata;

  factory ComponentTemplate.buttonBoard() {
    return const ComponentTemplate(
      id: 'custom_button_board_v1',
      name: 'Custom Button Board',
      board: ComponentBoard(
        outline: BoardOutline(
          type: 'rounded_rectangle',
          width: 48,
          height: 32,
          cornerRadius: 2,
        ),
        thickness: 1.6,
        referencePlane: 'bottom',
      ),
      mountingHoles: [
        MountingHole(
          id: 'mh1',
          position: [-20, -12],
          diameter: 2.2,
          screw: 'M2',
        ),
        MountingHole(
          id: 'mh2',
          position: [20, -12],
          diameter: 2.2,
          screw: 'M2',
        ),
        MountingHole(
          id: 'mh3',
          position: [-20, 12],
          diameter: 2.2,
          screw: 'M2',
        ),
        MountingHole(id: 'mh4', position: [20, 12], diameter: 2.2, screw: 'M2'),
      ],
      features: [
        ComponentFeature(
          id: 'usb_c',
          type: 'usb_c',
          position: [0, -16],
          direction: 'front',
          metadata: {
            'protrusion': 1.2,
            'cutout': {
              'shape': 'rounded_rectangle',
              'width': 10.5,
              'height': 4.2,
              'cornerRadius': 1.0,
              'clearanceProfile': 'fdm_normal',
            },
            'keepout': {
              'type': 'box',
              'size': [16, 12, 8],
            },
          },
        ),
        ComponentFeature(
          id: 'sw_a',
          type: 'switch',
          position: [7, 0],
          direction: 'top',
          metadata: {'actuationHeight': 5.0},
        ),
        ComponentFeature(
          id: 'sw_b',
          type: 'switch',
          position: [0, -7],
          direction: 'top',
          metadata: {'actuationHeight': 5.0},
        ),
        ComponentFeature(
          id: 'sw_x',
          type: 'switch',
          position: [0, 7],
          direction: 'top',
          metadata: {'actuationHeight': 5.0},
        ),
        ComponentFeature(
          id: 'sw_y',
          type: 'switch',
          position: [-7, 0],
          direction: 'top',
          metadata: {'actuationHeight': 5.0},
        ),
      ],
      zones: [
        ComponentZone(
          id: 'solder_zone',
          type: 'forbidden_clamp_zone',
          metadata: {
            'shape': 'rectangle',
            'position': [0, 14],
            'size': [42, 4],
          },
        ),
        ComponentZone(
          id: 'safe_side_clamp_left',
          type: 'mountable_surface',
          metadata: {'side': 'left'},
        ),
        ComponentZone(
          id: 'safe_side_clamp_right',
          type: 'mountable_surface',
          metadata: {'side': 'right'},
        ),
      ],
    );
  }

  factory ComponentTemplate.fromJson(Map<String, Object?> json) {
    return ComponentTemplate(
      schema: readString(
        json['schema'],
        fallback: ComponentTemplateSchema.name,
      ),
      version: readInt(
        json['version'],
        fallback: ComponentTemplateSchema.currentVersion,
      ),
      id: readString(json['id'], fallback: 'component_template'),
      name: readString(json['name'], fallback: 'Component Template'),
      units: readString(json['units'], fallback: 'mm'),
      board: json['board'] is Map<Object?, Object?>
          ? ComponentBoard.fromJson(readJsonMap(json['board']))
          : ComponentBoard.defaultBoard(),
      mountingHoles: readObjectList(
        json['mountingHoles'],
        MountingHole.fromJson,
      ),
      features: readObjectList(json['features'], ComponentFeature.fromJson),
      zones: readObjectList(json['zones'], ComponentZone.fromJson),
      metadata: withoutKeys(json, const {
        'schema',
        'version',
        'id',
        'name',
        'units',
        'board',
        'mountingHoles',
        'features',
        'zones',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'id': id,
      'name': name,
      'units': units,
      'board': board.toJson(),
      'mountingHoles': mountingHoles.map((hole) => hole.toJson()).toList(),
      'features': features.map((feature) => feature.toJson()).toList(),
      'zones': zones.map((zone) => zone.toJson()).toList(),
      ...metadata,
    };
  }
}

class ComponentBoard {
  const ComponentBoard({
    required this.outline,
    required this.thickness,
    required this.referencePlane,
    this.metadata = const {},
  });

  final BoardOutline outline;
  final double thickness;
  final String referencePlane;
  final Map<String, Object?> metadata;

  factory ComponentBoard.defaultBoard() {
    return const ComponentBoard(
      outline: BoardOutline(type: 'rounded_rectangle', width: 40, height: 30),
      thickness: 1.6,
      referencePlane: 'bottom',
    );
  }

  factory ComponentBoard.fromJson(Map<String, Object?> json) {
    return ComponentBoard(
      outline: json['outline'] is Map<Object?, Object?>
          ? BoardOutline.fromJson(readJsonMap(json['outline']))
          : const BoardOutline(
              type: 'rounded_rectangle',
              width: 40,
              height: 30,
            ),
      thickness: readDouble(json['thickness'], fallback: 1.6),
      referencePlane: readString(json['referencePlane'], fallback: 'bottom'),
      metadata: withoutKeys(json, const {
        'outline',
        'thickness',
        'referencePlane',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'outline': outline.toJson(),
      'thickness': thickness,
      'referencePlane': referencePlane,
      ...metadata,
    };
  }
}

class BoardOutline {
  const BoardOutline({
    required this.type,
    required this.width,
    required this.height,
    this.cornerRadius = 0,
    this.metadata = const {},
  });

  final String type;
  final double width;
  final double height;
  final double cornerRadius;
  final Map<String, Object?> metadata;

  factory BoardOutline.fromJson(Map<String, Object?> json) {
    return BoardOutline(
      type: readString(json['type'], fallback: 'rounded_rectangle'),
      width: readDouble(json['width'], fallback: 40),
      height: readDouble(json['height'], fallback: 30),
      cornerRadius: readDouble(json['cornerRadius'], fallback: 0),
      metadata: withoutKeys(json, const {
        'type',
        'width',
        'height',
        'cornerRadius',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'width': width,
      'height': height,
      if (cornerRadius != 0) 'cornerRadius': cornerRadius,
      ...metadata,
    };
  }
}

class MountingHole {
  const MountingHole({
    required this.id,
    required this.position,
    required this.diameter,
    this.screw,
    this.metadata = const {},
  });

  final String id;
  final List<double> position;
  final double diameter;
  final String? screw;
  final Map<String, Object?> metadata;

  factory MountingHole.fromJson(Map<String, Object?> json) {
    return MountingHole(
      id: readString(json['id'], fallback: 'mounting_hole'),
      position: readDoubleList(json['position'], fallback: const [0, 0]),
      diameter: readDouble(json['diameter'], fallback: 2),
      screw: json['screw'] is String ? json['screw']! as String : null,
      metadata: withoutKeys(json, const {
        'id',
        'position',
        'diameter',
        'screw',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'position': position,
      'diameter': diameter,
      if (screw != null) 'screw': screw,
      ...metadata,
    };
  }
}

class ComponentFeature {
  const ComponentFeature({
    required this.id,
    required this.type,
    this.position = const [0, 0],
    this.direction,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final List<double> position;
  final String? direction;
  final Map<String, Object?> metadata;

  factory ComponentFeature.fromJson(Map<String, Object?> json) {
    return ComponentFeature(
      id: readString(json['id'], fallback: 'component_feature'),
      type: readString(json['type'], fallback: 'feature'),
      position: readDoubleList(json['position'], fallback: const [0, 0]),
      direction: json['direction'] is String
          ? json['direction']! as String
          : null,
      metadata: withoutKeys(json, const {
        'id',
        'type',
        'position',
        'direction',
      }),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      'position': position,
      if (direction != null) 'direction': direction,
      ...metadata,
    };
  }
}

class ComponentZone {
  const ComponentZone({
    required this.id,
    required this.type,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final Map<String, Object?> metadata;

  factory ComponentZone.fromJson(Map<String, Object?> json) {
    return ComponentZone(
      id: readString(json['id'], fallback: 'component_zone'),
      type: readString(json['type'], fallback: 'zone'),
      metadata: withoutKeys(json, const {'id', 'type'}),
    );
  }

  Map<String, Object?> toJson() {
    return {'id': id, 'type': type, ...metadata};
  }
}
