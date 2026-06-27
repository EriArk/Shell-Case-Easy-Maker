import '../project/project_model.dart';
import 'parameter_model.dart';

class EnclosureParameterAdapter {
  const EnclosureParameterAdapter._();

  static const schema = CoreParameterSchemas.roundedEnclosure;

  static Map<String, Object?> valuesFrom(Enclosure enclosure) {
    return schema.applyDefaults({
      'width': _sizeAt(enclosure, 0, 120),
      'depth': _sizeAt(enclosure, 1, 70),
      'height': _sizeAt(enclosure, 2, 28),
      'wallThickness': enclosure.wallThickness,
      'cornerRadius': enclosure.cornerRadius,
      'lidType': enclosure.lid?.type ?? 'none',
    });
  }

  static Enclosure applyValues(
    Enclosure enclosure,
    Map<String, Object?> values,
  ) {
    final normalized = schema.applyDefaults(values);
    final lidType = _stringValue(normalized, 'lidType');

    return enclosure.copyWith(
      size: [
        _doubleValue(normalized, 'width'),
        _doubleValue(normalized, 'depth'),
        _doubleValue(normalized, 'height'),
      ],
      wallThickness: _doubleValue(normalized, 'wallThickness'),
      cornerRadius: _doubleValue(normalized, 'cornerRadius'),
      lid: lidType == 'none'
          ? null
          : LidSpec(
              type: lidType,
              clearanceProfile: enclosure.lid?.clearanceProfile ?? 'fdm_normal',
            ),
    );
  }

  static Enclosure updateParameter(
    Enclosure enclosure,
    String parameterId,
    Object? value,
  ) {
    final values = valuesFrom(enclosure);
    return applyValues(enclosure, {...values, parameterId: value});
  }

  static List<ParameterIssue> validateValues(Map<String, Object?> values) {
    return schema.validate(values);
  }

  static double _sizeAt(Enclosure enclosure, int index, double fallback) {
    return enclosure.size.length > index ? enclosure.size[index] : fallback;
  }

  static double _doubleValue(Map<String, Object?> values, String id) {
    final value = values[id];
    return value is num ? value.toDouble() : schema.byId(id).defaultDouble;
  }

  static String _stringValue(Map<String, Object?> values, String id) {
    final value = values[id];
    return value is String ? value : schema.byId(id).defaultString;
  }
}

extension on ParameterDefinition {
  double get defaultDouble {
    final value = defaultValue;
    return value is num ? value.toDouble() : 0;
  }

  String get defaultString {
    final value = defaultValue;
    return value is String ? value : '';
  }
}
