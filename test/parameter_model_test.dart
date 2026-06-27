import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/parameters/parameter_model.dart';

void main() {
  test('rounded enclosure schema applies defaults', () {
    final values = CoreParameterSchemas.roundedEnclosure.applyDefaults(const {
      'width': 98,
    });

    expect(values['width'], 98.0);
    expect(values['depth'], 70.0);
    expect(values['height'], 28.0);
    expect(values['wallThickness'], 2.0);
    expect(values['lidType'], 'top_screw_lid');
  });

  test('numeric ranges clamp and snap values to step', () {
    const range = ParameterRange(min: 0.8, max: 8, step: 0.1);

    expect(range.snap(2.04), closeTo(2.0, 0.0001));
    expect(range.snap(2.06), closeTo(2.1, 0.0001));
    expect(range.snap(99), 8);
    expect(range.snap(-2), 0.8);
  });

  test('schema validates ranges and choices', () {
    final issues = CoreParameterSchemas.roundedEnclosure.validate(const {
      'width': 12,
      'depth': 70,
      'height': 28,
      'wallThickness': 0.2,
      'cornerRadius': 4,
      'lidType': 'hinged_magic',
    });

    expect(
      issues.map((issue) => '${issue.parameterId}:${issue.code}'),
      containsAll([
        'width:parameter.range',
        'wallThickness:parameter.range',
        'lidType:parameter.choice',
      ]),
    );
  });

  test('parameter schema round trips through JSON', () {
    final encoded = jsonEncode(CoreParameterSchemas.roundedEnclosure.toJson());
    final decoded = ParameterSchema.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );

    expect(decoded.id, 'enclosure.rounded_box');
    expect(decoded.byId('width').unit, 'mm');
    expect(decoded.byId('cornerRadius').range?.step, 0.1);
    expect(decoded.byId('lidType').options.map((option) => option.id), [
      'none',
      'top_screw_lid',
    ]);
  });

  test('invalid raw types fall back to defaults before validation', () {
    final values = CoreParameterSchemas.roundedEnclosure.applyDefaults(const {
      'width': 'large',
      'lidType': false,
    });
    final issues = CoreParameterSchemas.roundedEnclosure.validate(values);

    expect(values['width'], 120.0);
    expect(values['lidType'], 'top_screw_lid');
    expect(issues, isEmpty);
  });
}
