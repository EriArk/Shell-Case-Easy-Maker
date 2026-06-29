import 'dart:math' as math;

import '../project/feature_group.dart';
import '../project/json_helpers.dart';

class PatternPoint {
  const PatternPoint(this.x, this.y);

  final double x;
  final double y;

  @override
  bool operator ==(Object other) {
    return other is PatternPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'PatternPoint($x, $y)';
}

class PatternLayoutEngine {
  const PatternLayoutEngine._();

  static List<PatternPoint> buttonGroupPositions(FeatureGroup group) {
    return expandButtonLayout(
      layout: readString(group.pattern['layout'], fallback: 'diamond'),
      count: readDouble(group.pattern['count'], fallback: 4).round(),
      spacing: readDouble(group.pattern['spacing'], fallback: 14),
    );
  }

  static List<PatternPoint> expandButtonLayout({
    required String layout,
    required int count,
    required double spacing,
  }) {
    final safeCount = count.clamp(1, 24).toInt();
    final safeSpacing = spacing.clamp(4, 80).toDouble();

    return switch (layout) {
      'row' => _rowPatternPositions(safeCount, safeSpacing),
      'grid' => _gridPatternPositions(safeCount, safeSpacing),
      'diamond' => _diamondPatternPositions(safeCount, safeSpacing),
      _ => _rowPatternPositions(safeCount, safeSpacing),
    };
  }
}

List<PatternPoint> _rowPatternPositions(int count, double spacing) {
  final origin = (count - 1) / 2;
  return [
    for (var index = 0; index < count; index++)
      PatternPoint((index - origin) * spacing, 0),
  ];
}

List<PatternPoint> _gridPatternPositions(int count, double spacing) {
  final columns = math.sqrt(count).ceil().clamp(1, count);
  final rows = (count / columns).ceil();
  final positions = <PatternPoint>[];

  for (var index = 0; index < count; index++) {
    final column = index % columns;
    final row = index ~/ columns;
    positions.add(
      PatternPoint(
        (column - (columns - 1) / 2) * spacing,
        ((rows - 1) / 2 - row) * spacing,
      ),
    );
  }

  return positions;
}

List<PatternPoint> _diamondPatternPositions(int count, double spacing) {
  if (count == 1) {
    return const [PatternPoint(0, 0)];
  }

  if (count == 4) {
    return [
      PatternPoint(spacing, 0),
      PatternPoint(0, -spacing),
      PatternPoint(0, spacing),
      PatternPoint(-spacing, 0),
    ];
  }

  return [
    for (var index = 0; index < count; index++)
      PatternPoint(
        math.cos(index * math.pi * 2 / count) * spacing,
        math.sin(index * math.pi * 2 / count) * spacing,
      ),
  ];
}
