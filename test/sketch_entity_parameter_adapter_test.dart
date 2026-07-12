import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/parameters/parameter_model.dart';
import 'package:shell_case_easy_maker/parameters/sketch_entity_parameter_adapter.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('rectangle sketch entity exposes editable parameter values', () {
    final rectangle = defaultSketchRectangleEntity(id: 'rect_1');

    final values = SketchEntityParameterAdapter.valuesFrom(rectangle);

    expect(values['centerX'], 0.0);
    expect(values['centerY'], 0.0);
    expect(values['width'], 20.0);
    expect(values['height'], 12.0);
    expect(values['cornerRadius'], 0.0);
    expect(values['rotation'], 0.0);
    expect(values.containsKey('depth'), isFalse);
  });

  test('rectangle sketch entity updates semantic parameters', () {
    final rectangle = defaultSketchRectangleEntity(id: 'rect_1');

    final moved = SketchEntityParameterAdapter.updateParameter(
      rectangle,
      'centerX',
      7.2,
    );
    final resized = SketchEntityParameterAdapter.updateParameter(
      moved,
      'width',
      32.5,
    );
    final rotated = SketchEntityParameterAdapter.updateParameter(
      resized,
      'rotation',
      37,
    );
    final rounded = SketchEntityParameterAdapter.updateParameter(
      rotated,
      'cornerRadius',
      3,
    );

    expect(rounded.parameters['center'], [7.2, 0.0]);
    expect(rounded.parameters['width'], 32.5);
    expect(rounded.parameters['height'], 12.0);
    expect(rounded.parameters['cornerRadius'], 3.0);
    expect(rounded.parameters['rotation'], 37.0);
    expect(rounded.parameters.containsKey('depth'), isFalse);
  });

  test('rectangle sketch operation depth is explicit and clamped', () {
    final rectangle = defaultSketchRectangleEntity(id: 'rect_1');

    final deep = SketchEntityParameterAdapter.updateParameter(
      rectangle,
      'depth',
      4.2,
    );
    final clamped = SketchEntityParameterAdapter.updateParameter(
      deep,
      'depth',
      99.0,
    );

    expect(deep.parameters['depth'], 4.2);
    expect(SketchEntityParameterAdapter.valuesFrom(deep)['depth'], 4.2);
    expect(clamped.parameters['depth'], 10.0);
  });

  test('rectangle corner radius is clamped to half the smaller side', () {
    final rectangle = SketchEntityParameterAdapter.applyValues(
      defaultSketchRectangleEntity(id: 'rect_1'),
      const {'width': 8.0, 'height': 12.0, 'cornerRadius': 99.0},
    );

    expect(rectangle.parameters['cornerRadius'], 4.0);
    expect(SketchEntityParameterAdapter.validate(rectangle), isEmpty);
  });

  test('circle sketch entity exposes and updates semantic parameters', () {
    final circle = defaultSketchCircleEntity(id: 'circle_1');

    final values = SketchEntityParameterAdapter.valuesFrom(circle);
    final moved = SketchEntityParameterAdapter.updateParameter(
      circle,
      'centerY',
      -8,
    );
    final resized = SketchEntityParameterAdapter.updateParameter(
      moved,
      'diameter',
      18,
    );

    expect(values['centerX'], 0.0);
    expect(values['centerY'], 0.0);
    expect(values['diameter'], 12.0);
    expect(values.containsKey('depth'), isFalse);
    expect(resized.parameters['center'], [0.0, -8.0]);
    expect(resized.parameters['diameter'], 18.0);
    expect(resized.parameters.containsKey('depth'), isFalse);
  });

  test('circle sketch operation depth is explicit and duplicate-safe', () {
    final circle = SketchEntityParameterAdapter.updateParameter(
      defaultSketchCircleEntity(id: 'circle_1'),
      'depth',
      1.2,
    );

    final duplicate = SketchEntityParameterAdapter.duplicateWithOffset(
      circle,
      id: 'circle_2',
    );

    expect(circle.parameters['depth'], 1.2);
    expect(duplicate.parameters['depth'], 1.2);
  });

  test('circle duplicate gets a new id and offset center', () {
    final circle = SketchEntityParameterAdapter.applyValues(
      defaultSketchCircleEntity(id: 'circle_1'),
      const {'centerX': -5.0, 'centerY': 4.0, 'diameter': 18.0},
    );

    final duplicate = SketchEntityParameterAdapter.duplicateWithOffset(
      circle,
      id: 'circle_2',
      dx: 6,
      dy: -6,
    );

    expect(duplicate.id, 'circle_2');
    expect(duplicate.type, 'circle');
    expect(duplicate.parameters['center'], [1.0, -2.0]);
    expect(duplicate.parameters['diameter'], 18.0);
  });

  test('sketch entity profile intent is semantic metadata', () {
    final rectangle = defaultSketchRectangleEntity(id: 'rect_1');
    final cutRectangle = sketchEntityWithProfileIntent(
      rectangle,
      sketchProfileIntentCut,
    );
    final invalidRectangle = sketchEntityWithProfileIntent(
      rectangle,
      'raw_boolean',
    );
    final duplicate = SketchEntityParameterAdapter.duplicateWithOffset(
      cutRectangle,
      id: 'rect_2',
    );
    final referenceRectangle = sketchEntityWithProfileIntent(
      cutRectangle,
      sketchProfileIntentReference,
    );

    expect(sketchProfileIntentFor(rectangle), sketchProfileIntentReference);
    expect(cutRectangle.metadata[sketchProfileIntentKey], 'cut');
    expect(sketchProfileIntentFor(cutRectangle), sketchProfileIntentCut);
    expect(
      sketchProfileIntentFor(invalidRectangle),
      sketchProfileIntentReference,
    );
    expect(duplicate.metadata[sketchProfileIntentKey], 'cut');
    expect(
      referenceRectangle.metadata.containsKey(sketchProfileIntentKey),
      isFalse,
    );
  });

  test('rectangle duplicate gets a new id and offset center', () {
    final rectangle = SketchEntityParameterAdapter.applyValues(
      defaultSketchRectangleEntity(id: 'rect_1'),
      const {
        'centerX': 10.0,
        'centerY': -4.0,
        'width': 32.0,
        'height': 14.0,
        'cornerRadius': 2.0,
        'rotation': 30.0,
      },
    );

    final duplicate = SketchEntityParameterAdapter.duplicateWithOffset(
      rectangle,
      id: 'rect_2',
      dx: 6,
      dy: -6,
    );

    expect(duplicate.id, 'rect_2');
    expect(duplicate.type, 'rectangle');
    expect(duplicate.parameters['center'], [16.0, -10.0]);
    expect(duplicate.parameters['width'], 32.0);
    expect(duplicate.parameters['height'], 14.0);
    expect(duplicate.parameters['cornerRadius'], 2.0);
    expect(duplicate.parameters['rotation'], 30.0);
  });

  test(
    'rectangle workplane bounds warning reports out of surface contours',
    () {
      final inside = defaultSketchRectangleEntity(id: 'rect_1');
      final outside = SketchEntityParameterAdapter.updateParameter(
        inside,
        'centerX',
        55,
      );

      expect(
        SketchEntityParameterAdapter.validateWithinWorkplane(
          inside,
          workplaneWidth: 120,
          workplaneHeight: 70,
        ),
        isEmpty,
      );
      final issues = SketchEntityParameterAdapter.validateWithinWorkplane(
        outside,
        workplaneWidth: 120,
        workplaneHeight: 70,
      );

      expect(issues, hasLength(1));
      expect(issues.single.severity, ParameterIssueSeverity.warning);
      expect(issues.single.code, 'sketch.rectangle.workplaneBounds');
    },
  );

  test('rectangle workplane bounds warning accounts for rotation', () {
    final rectangle = SketchEntityParameterAdapter.applyValues(
      defaultSketchRectangleEntity(id: 'rect_1'),
      const {'width': 140.0, 'height': 20.0, 'rotation': 45.0},
    );

    final issues = SketchEntityParameterAdapter.validateWithinWorkplane(
      rectangle,
      workplaneWidth: 100,
      workplaneHeight: 100,
    );

    expect(issues, hasLength(1));
    expect(issues.single.code, 'sketch.rectangle.workplaneBounds');
  });

  test('circle workplane bounds warning reports out of surface contours', () {
    final circle = SketchEntityParameterAdapter.applyValues(
      defaultSketchCircleEntity(id: 'circle_1'),
      const {'centerX': 47.0, 'diameter': 12.0},
    );

    final issues = SketchEntityParameterAdapter.validateWithinWorkplane(
      circle,
      workplaneWidth: 100,
      workplaneHeight: 100,
    );

    expect(issues, hasLength(1));
    expect(issues.single.severity, ParameterIssueSeverity.warning);
    expect(issues.single.code, 'sketch.circle.workplaneBounds');
  });

  test('advanced sketch can replace one entity by stable id', () {
    final feature = advancedSketchWithEntities(
      const SemanticFeature(
        id: 'advanced_sketch_1',
        type: advancedSketchFeatureType,
        targetSurface: 'main_enclosure.top_lid.outer',
        operation: 'helper',
      ),
      [
        defaultSketchRectangleEntity(id: 'rect_1'),
        defaultSketchRectangleEntity(id: 'rect_2'),
      ],
    );
    final updatedRect = SketchEntityParameterAdapter.updateParameter(
      defaultSketchRectangleEntity(id: 'rect_2'),
      'height',
      24,
    );

    final updatedFeature = advancedSketchWithUpdatedEntity(
      feature,
      updatedRect,
    );
    final entities = sketchEntitiesForFeature(updatedFeature);

    expect(entities, hasLength(2));
    expect(entities.first.id, 'rect_1');
    expect(entities.last.id, 'rect_2');
    expect(entities.last.parameters['height'], 24.0);
    expect(updatedFeature.parameters['entityCount'], 2);
  });

  test('advanced sketch can remove one entity by stable id', () {
    final feature = advancedSketchWithEntities(
      const SemanticFeature(
        id: 'advanced_sketch_1',
        type: advancedSketchFeatureType,
        targetSurface: 'main_enclosure.top_lid.outer',
        operation: 'helper',
      ),
      [
        defaultSketchRectangleEntity(id: 'rect_1'),
        defaultSketchRectangleEntity(id: 'rect_2'),
      ],
    );

    final updatedFeature = advancedSketchWithoutEntity(feature, 'rect_1');
    final entities = sketchEntitiesForFeature(updatedFeature);

    expect(entities, hasLength(1));
    expect(entities.single.id, 'rect_2');
    expect(updatedFeature.parameters['entityCount'], 1);
  });
}
