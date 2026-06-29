import 'dart:math' as math;

import '../project/project_model.dart';

class ComponentFeatureProjection {
  const ComponentFeatureProjection({
    required this.targetSurfaceId,
    required this.direction,
    required this.componentFeaturePosition,
    required this.rotatedOffset,
    required this.worldPosition,
    required this.surfacePosition,
    required this.surfaceAxes,
  });

  final String targetSurfaceId;
  final String direction;
  final List<double> componentFeaturePosition;
  final List<double> rotatedOffset;
  final List<double> worldPosition;
  final List<double> surfacePosition;
  final List<String> surfaceAxes;

  Map<String, Object?> toPlacementJson() {
    return {
      'projectionMode': 'component_feature_surface_projection',
      'componentFeaturePosition': componentFeaturePosition,
      'rotatedOffset': rotatedOffset,
      'worldPosition': worldPosition,
      'surfacePosition': surfacePosition,
      'surfaceAxes': surfaceAxes,
      'componentFeatureDirection': direction,
    };
  }

  Map<String, Object?> toPatternPointJson({required String id}) {
    return {
      'id': id,
      'position': surfacePosition,
      'componentFeaturePosition': componentFeaturePosition,
      'rotatedOffset': rotatedOffset,
      'worldPosition': worldPosition,
      'surfaceAxes': surfaceAxes,
      'direction': direction,
    };
  }
}

class ComponentFeatureSurfaceProjector {
  const ComponentFeatureSurfaceProjector._();

  static String? targetSurfaceId({
    required ProjectModel project,
    required ComponentFeature feature,
  }) {
    if (project.bodies.isEmpty) {
      return null;
    }

    final surfacePart = _surfacePartForDirection(feature.direction ?? 'front');
    if (surfacePart == null) {
      return null;
    }

    return '${project.bodies.first.id}.$surfacePart.outer';
  }

  static ComponentFeatureProjection? projectFeature({
    required ProjectModel project,
    required ComponentPlacement placement,
    required ComponentFeature feature,
  }) {
    final targetSurface = targetSurfaceId(project: project, feature: feature);
    if (targetSurface == null) {
      return null;
    }

    final direction = feature.direction ?? 'front';
    final localX = _listValue(feature.position, 0);
    final localY = _listValue(feature.position, 1);
    final localZ = _listValue(feature.position, 2);
    final rotationZ = _listValue(placement.rotation, 2);
    final rotated = _rotate2d(localX, localY, rotationZ);
    final world = [
      _cleanDouble(_listValue(placement.position, 0) + rotated.x),
      _cleanDouble(_listValue(placement.position, 1) + rotated.y),
      _cleanDouble(_listValue(placement.position, 2) + localZ),
    ];
    final axes = _surfaceAxesForDirection(direction);

    return ComponentFeatureProjection(
      targetSurfaceId: targetSurface,
      direction: direction,
      componentFeaturePosition: [
        _cleanDouble(localX),
        _cleanDouble(localY),
        _cleanDouble(localZ),
      ],
      rotatedOffset: [
        _cleanDouble(rotated.x),
        _cleanDouble(rotated.y),
        _cleanDouble(localZ),
      ],
      worldPosition: world,
      surfacePosition: _surfacePositionForDirection(direction, world),
      surfaceAxes: axes,
    );
  }

  static List<ComponentFeatureProjection> projectFeatures({
    required ProjectModel project,
    required ComponentPlacement placement,
    required Iterable<ComponentFeature> features,
  }) {
    final projections = <ComponentFeatureProjection>[];
    for (final feature in features) {
      final projection = projectFeature(
        project: project,
        placement: placement,
        feature: feature,
      );
      if (projection != null) {
        projections.add(projection);
      }
    }

    return projections;
  }
}

({double x, double y}) _rotate2d(double x, double y, double degrees) {
  final radians = degrees * math.pi / 180;
  final cos = math.cos(radians);
  final sin = math.sin(radians);

  return (x: x * cos - y * sin, y: x * sin + y * cos);
}

double _listValue(List<double> values, int index) {
  return values.length > index ? values[index] : 0;
}

String? _surfacePartForDirection(String direction) {
  return switch (direction) {
    'front' => 'front_wall',
    'back' => 'back_wall',
    'left' => 'left_wall',
    'right' => 'right_wall',
    'top' => 'top_lid',
    'bottom' => 'bottom',
    _ => null,
  };
}

List<String> _surfaceAxesForDirection(String direction) {
  return switch (direction) {
    'front' || 'back' => const ['x', 'z'],
    'left' || 'right' => const ['y', 'z'],
    'top' || 'bottom' => const ['x', 'y'],
    _ => const ['x', 'y'],
  };
}

List<double> _surfacePositionForDirection(
  String direction,
  List<double> world,
) {
  return switch (direction) {
    'front' || 'back' => [world[0], world[2]],
    'left' || 'right' => [world[1], world[2]],
    'top' || 'bottom' => [world[0], world[1]],
    _ => [world[0], world[1]],
  };
}

double _cleanDouble(double value) {
  if (value.abs() < 0.000001) {
    return 0;
  }

  return double.parse(value.toStringAsFixed(6));
}
