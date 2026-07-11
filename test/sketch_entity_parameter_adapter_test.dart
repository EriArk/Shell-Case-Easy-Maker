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

    expect(resized.parameters['center'], [7.2, 0.0]);
    expect(resized.parameters['width'], 32.5);
    expect(resized.parameters['height'], 12.0);
  });

  test('rectangle corner radius is clamped to half the smaller side', () {
    final rectangle = SketchEntityParameterAdapter.applyValues(
      defaultSketchRectangleEntity(id: 'rect_1'),
      const {'width': 8.0, 'height': 12.0, 'cornerRadius': 99.0},
    );

    expect(rectangle.parameters['cornerRadius'], 4.0);
    expect(SketchEntityParameterAdapter.validate(rectangle), isEmpty);
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
