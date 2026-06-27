import 'json_helpers.dart';

class ComponentPlacement {
  const ComponentPlacement({
    required this.id,
    required this.templateId,
    required this.position,
    required this.rotation,
    required this.mountingSide,
    required this.locked,
    this.metadata = const {},
  });

  final String id;
  final String templateId;
  final List<double> position;
  final List<double> rotation;
  final String mountingSide;
  final bool locked;
  final Map<String, Object?> metadata;

  factory ComponentPlacement.fromJson(Map<String, Object?> json) {
    return ComponentPlacement(
      id: readString(json['id'], fallback: 'component_placement'),
      templateId: readString(
        json['templateId'],
        fallback: 'component_template',
      ),
      position: readDoubleList(json['position'], fallback: const [0, 0, 0]),
      rotation: readDoubleList(json['rotation'], fallback: const [0, 0, 0]),
      mountingSide: readString(json['mountingSide'], fallback: 'bottom_inside'),
      locked: readBool(json['locked'], fallback: false),
      metadata: withoutKeys(json, const {
        'id',
        'templateId',
        'position',
        'rotation',
        'mountingSide',
        'locked',
      }),
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
      ...metadata,
    };
  }
}
