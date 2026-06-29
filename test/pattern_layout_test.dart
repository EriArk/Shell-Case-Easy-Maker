import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/patterns/pattern_layout.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';

void main() {
  test('button diamond layout preserves expected four-point order', () {
    final positions = PatternLayoutEngine.expandButtonLayout(
      layout: 'diamond',
      count: 4,
      spacing: 14,
    );

    expect(positions, const [
      PatternPoint(14, 0),
      PatternPoint(0, -14),
      PatternPoint(0, 14),
      PatternPoint(-14, 0),
    ]);
  });

  test(
    'button grid layout expands deterministically from count and spacing',
    () {
      final positions = PatternLayoutEngine.expandButtonLayout(
        layout: 'grid',
        count: 6,
        spacing: 10,
      );

      expect(positions, const [
        PatternPoint(-10, 5),
        PatternPoint(0, 5),
        PatternPoint(10, 5),
        PatternPoint(-10, -5),
        PatternPoint(0, -5),
        PatternPoint(10, -5),
      ]);
    },
  );

  test('unknown button layout falls back to clamped row expansion', () {
    final positions = PatternLayoutEngine.expandButtonLayout(
      layout: 'zigzag',
      count: 99,
      spacing: 1,
    );

    expect(positions, hasLength(24));
    expect(positions.first, const PatternPoint(-46, 0));
    expect(positions.last, const PatternPoint(46, 0));
  });

  test('button group positions read semantic feature group pattern data', () {
    const group = FeatureGroup(
      id: 'button_group_1',
      type: 'button_group',
      targetSurface: 'main_enclosure.top_lid.outer',
      pattern: {'layout': 'row', 'count': 3, 'spacing': 12.0},
      itemPrototype: {'diameter': 8.0},
    );

    expect(PatternLayoutEngine.buttonGroupPositions(group), const [
      PatternPoint(-12, 0),
      PatternPoint(0, 0),
      PatternPoint(12, 0),
    ]);
  });
}
