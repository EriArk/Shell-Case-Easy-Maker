import 'json_helpers.dart';

class Enclosure {
  const Enclosure({
    required this.id,
    this.type = 'enclosure',
    required this.shape,
    required this.size,
    required this.wallThickness,
    required this.cornerRadius,
    this.lid,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String shape;
  final List<double> size;
  final double wallThickness;
  final double cornerRadius;
  final LidSpec? lid;
  final Map<String, Object?> metadata;

  Enclosure copyWith({
    String? id,
    String? type,
    String? shape,
    List<double>? size,
    double? wallThickness,
    double? cornerRadius,
    Object? lid = _unchanged,
    Map<String, Object?>? metadata,
  }) {
    return Enclosure(
      id: id ?? this.id,
      type: type ?? this.type,
      shape: shape ?? this.shape,
      size: List<double>.unmodifiable(size ?? this.size),
      wallThickness: wallThickness ?? this.wallThickness,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      lid: lid == _unchanged ? this.lid : lid as LidSpec?,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Enclosure.fromJson(Map<String, Object?> json) {
    return Enclosure(
      id: readString(json['id'], fallback: 'main_enclosure'),
      type: readString(json['type'], fallback: 'enclosure'),
      shape: readString(json['shape'], fallback: 'rounded_box'),
      size: readDoubleList(json['size'], fallback: const [120, 70, 28]),
      wallThickness: readDouble(json['wallThickness'], fallback: 2),
      cornerRadius: readDouble(json['cornerRadius'], fallback: 4),
      lid: json['lid'] is Map<Object?, Object?>
          ? LidSpec.fromJson(readJsonMap(json['lid']))
          : null,
      metadata: withoutKeys(json, const {
        'id',
        'type',
        'shape',
        'size',
        'wallThickness',
        'cornerRadius',
        'lid',
      }),
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
      ...metadata,
    };
  }
}

class LidSpec {
  const LidSpec({
    required this.type,
    required this.clearanceProfile,
    this.metadata = const {},
  });

  final String type;
  final String clearanceProfile;
  final Map<String, Object?> metadata;

  factory LidSpec.fromJson(Map<String, Object?> json) {
    return LidSpec(
      type: readString(json['type'], fallback: 'none'),
      clearanceProfile: readString(
        json['clearanceProfile'],
        fallback: 'fdm_normal',
      ),
      metadata: withoutKeys(json, const {'type', 'clearanceProfile'}),
    );
  }

  Map<String, Object?> toJson() {
    return {'type': type, 'clearanceProfile': clearanceProfile, ...metadata};
  }
}

const _unchanged = Object();
