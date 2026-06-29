import 'dart:math' as math;
import 'dart:ui';

enum ViewportHitKind {
  enclosure,
  surface,
  componentPlacement,
  feature,
  featureGroup,
}

enum GhostPreviewKind { usbC, buttonGroup }

enum MockViewportFeatureKind { usbC, glassRecess }

enum MockViewportFeatureGroupKind { buttonGroup, standoffMounts }

enum MockViewportWorkplaneKind { topLid, frontWall, componentPlacement }

class ViewportController {
  ViewportController({ViewportState initialState = const ViewportState()})
    : _state = initialState;

  ViewportState _state;

  ViewportState get state => _state;

  void orbit(Offset delta) {
    _state = _state.copyWith(
      yawDegrees: _wrapDegrees(_state.yawDegrees + delta.dx * 0.35),
      pitchDegrees: (_state.pitchDegrees - delta.dy * 0.25).clamp(-70, 70),
    );
  }

  void pan(Offset delta) {
    _state = _state.copyWith(panOffset: _state.panOffset + delta);
  }

  void zoomByScroll(double scrollDeltaY) {
    final factor = math.pow(1.0018, -scrollDeltaY).toDouble();
    zoomByFactor(factor);
  }

  void zoomByFactor(double factor) {
    _state = _state.copyWith(zoom: (_state.zoom * factor).clamp(0.45, 2.8));
  }

  void fit() {
    _state = const ViewportState();
  }

  void setSelectedSemanticId(String? semanticId) {
    _state = _state.copyWith(selectedSemanticId: semanticId);
  }

  void setGhostPreview(GhostPreview? ghostPreview) {
    _state = _state.copyWith(ghostPreview: ghostPreview);
  }
}

class ViewportState {
  const ViewportState({
    this.yawDegrees = -24,
    this.pitchDegrees = 18,
    this.zoom = 1,
    this.panOffset = Offset.zero,
    this.selectedSemanticId,
    this.ghostPreview,
  });

  final double yawDegrees;
  final double pitchDegrees;
  final double zoom;
  final Offset panOffset;
  final String? selectedSemanticId;
  final GhostPreview? ghostPreview;

  String get viewLabel {
    return '${zoom.toStringAsFixed(2)}x · '
        '${yawDegrees.toStringAsFixed(0)}° / '
        '${pitchDegrees.toStringAsFixed(0)}°';
  }

  ViewportState copyWith({
    double? yawDegrees,
    double? pitchDegrees,
    double? zoom,
    Offset? panOffset,
    Object? selectedSemanticId = _unchanged,
    Object? ghostPreview = _unchanged,
  }) {
    return ViewportState(
      yawDegrees: yawDegrees ?? this.yawDegrees,
      pitchDegrees: pitchDegrees ?? this.pitchDegrees,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      selectedSemanticId: selectedSemanticId == _unchanged
          ? this.selectedSemanticId
          : selectedSemanticId as String?,
      ghostPreview: ghostPreview == _unchanged
          ? this.ghostPreview
          : ghostPreview as GhostPreview?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ViewportState &&
        other.yawDegrees == yawDegrees &&
        other.pitchDegrees == pitchDegrees &&
        other.zoom == zoom &&
        other.panOffset == panOffset &&
        other.selectedSemanticId == selectedSemanticId &&
        other.ghostPreview == ghostPreview;
  }

  @override
  int get hashCode {
    return Object.hash(
      yawDegrees,
      pitchDegrees,
      zoom,
      panOffset,
      selectedSemanticId,
      ghostPreview,
    );
  }
}

class GhostPreview {
  const GhostPreview({
    required this.kind,
    required this.semanticId,
    required this.targetSurfaceId,
    required this.label,
  });

  final GhostPreviewKind kind;
  final String semanticId;
  final String targetSurfaceId;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is GhostPreview &&
        other.kind == kind &&
        other.semanticId == semanticId &&
        other.targetSurfaceId == targetSurfaceId &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(kind, semanticId, targetSurfaceId, label);
}

class ViewportHitResult {
  const ViewportHitResult({
    required this.kind,
    required this.semanticId,
    this.parentId,
  });

  final ViewportHitKind kind;
  final String semanticId;
  final String? parentId;
}

class MockViewportFeaturePreview {
  const MockViewportFeaturePreview({
    required this.semanticId,
    required this.kind,
    required this.targetSurfaceId,
    required this.width,
    required this.height,
    this.cornerRadius = 0,
    this.referenceWidth = 120,
    this.referenceHeight = 70,
    this.slotIndex = 0,
  });

  final String semanticId;
  final MockViewportFeatureKind kind;
  final String targetSurfaceId;
  final double width;
  final double height;
  final double cornerRadius;
  final double referenceWidth;
  final double referenceHeight;
  final int slotIndex;

  @override
  bool operator ==(Object other) {
    return other is MockViewportFeaturePreview &&
        other.semanticId == semanticId &&
        other.kind == kind &&
        other.targetSurfaceId == targetSurfaceId &&
        other.width == width &&
        other.height == height &&
        other.cornerRadius == cornerRadius &&
        other.referenceWidth == referenceWidth &&
        other.referenceHeight == referenceHeight &&
        other.slotIndex == slotIndex;
  }

  @override
  int get hashCode {
    return Object.hash(
      semanticId,
      kind,
      targetSurfaceId,
      width,
      height,
      cornerRadius,
      referenceWidth,
      referenceHeight,
      slotIndex,
    );
  }
}

class MockViewportFeatureGroupPreview {
  const MockViewportFeatureGroupPreview({
    required this.semanticId,
    required this.kind,
    required this.sourcePositions,
    required this.referenceWidth,
    required this.referenceHeight,
    required this.itemDiameter,
  });

  final String semanticId;
  final MockViewportFeatureGroupKind kind;
  final List<Offset> sourcePositions;
  final double referenceWidth;
  final double referenceHeight;
  final double itemDiameter;

  @override
  bool operator ==(Object other) {
    return other is MockViewportFeatureGroupPreview &&
        other.semanticId == semanticId &&
        other.kind == kind &&
        _offsetListsEqual(other.sourcePositions, sourcePositions) &&
        other.referenceWidth == referenceWidth &&
        other.referenceHeight == referenceHeight &&
        other.itemDiameter == itemDiameter;
  }

  @override
  int get hashCode {
    return Object.hash(
      semanticId,
      kind,
      Object.hashAll(sourcePositions),
      referenceWidth,
      referenceHeight,
      itemDiameter,
    );
  }
}

class MockViewportComponentPlacementPreview {
  const MockViewportComponentPlacementPreview({
    required this.semanticId,
    required this.width,
    required this.depth,
    required this.referenceWidth,
    required this.referenceDepth,
    this.position = Offset.zero,
    this.rotationZDegrees = 0,
  });

  final String semanticId;
  final double width;
  final double depth;
  final double referenceWidth;
  final double referenceDepth;
  final Offset position;
  final double rotationZDegrees;

  @override
  bool operator ==(Object other) {
    return other is MockViewportComponentPlacementPreview &&
        other.semanticId == semanticId &&
        other.width == width &&
        other.depth == depth &&
        other.referenceWidth == referenceWidth &&
        other.referenceDepth == referenceDepth &&
        other.position == position &&
        other.rotationZDegrees == rotationZDegrees;
  }

  @override
  int get hashCode {
    return Object.hash(
      semanticId,
      width,
      depth,
      referenceWidth,
      referenceDepth,
      position,
      rotationZDegrees,
    );
  }
}

class MockViewportWorkplaneOverlay {
  const MockViewportWorkplaneOverlay({
    required this.semanticId,
    required this.kind,
    required this.width,
    required this.height,
    this.referenceWidth = 120,
    this.referenceHeight = 70,
    this.position = Offset.zero,
    this.rotationZDegrees = 0,
    this.snapPoints = const [],
  });

  final String semanticId;
  final MockViewportWorkplaneKind kind;
  final double width;
  final double height;
  final double referenceWidth;
  final double referenceHeight;
  final Offset position;
  final double rotationZDegrees;
  final List<Offset> snapPoints;

  List<Offset> get effectiveSnapPoints {
    if (snapPoints.isNotEmpty) {
      return snapPoints;
    }

    return [
      Offset.zero,
      Offset(width / 4, 0),
      Offset(-width / 4, 0),
      Offset(0, height / 4),
      Offset(0, -height / 4),
    ];
  }

  @override
  bool operator ==(Object other) {
    return other is MockViewportWorkplaneOverlay &&
        other.semanticId == semanticId &&
        other.kind == kind &&
        other.width == width &&
        other.height == height &&
        other.referenceWidth == referenceWidth &&
        other.referenceHeight == referenceHeight &&
        other.position == position &&
        other.rotationZDegrees == rotationZDegrees &&
        _offsetListsEqual(other.snapPoints, snapPoints);
  }

  @override
  int get hashCode {
    return Object.hash(
      semanticId,
      kind,
      width,
      height,
      referenceWidth,
      referenceHeight,
      position,
      rotationZDegrees,
      Object.hashAll(snapPoints),
    );
  }
}

class MockViewportBodyDimensions {
  const MockViewportBodyDimensions({
    this.width = 120,
    this.depth = 70,
    this.height = 28,
    this.cornerRadius = 4,
  });

  final double width;
  final double depth;
  final double height;
  final double cornerRadius;

  @override
  bool operator ==(Object other) {
    return other is MockViewportBodyDimensions &&
        other.width == width &&
        other.depth == depth &&
        other.height == height &&
        other.cornerRadius == cornerRadius;
  }

  @override
  int get hashCode => Object.hash(width, depth, height, cornerRadius);
}

class MockViewportLayout {
  const MockViewportLayout({
    required this.bodyRect,
    required this.shadowRect,
    required this.lidRect,
    required this.boardRect,
    required this.portRect,
    required this.frontWallRect,
    required this.buttonCenters,
    required this.bodyRadius,
    required this.lidRadius,
    required this.boardRadius,
    required this.buttonRadius,
    required this.portRadius,
    required this.zoom,
  });

  final Rect bodyRect;
  final Rect shadowRect;
  final Rect lidRect;
  final Rect boardRect;
  final Rect portRect;
  final Rect frontWallRect;
  final List<Offset> buttonCenters;
  final double bodyRadius;
  final double lidRadius;
  final double boardRadius;
  final double buttonRadius;
  final double portRadius;
  final double zoom;

  List<Offset> featureGroupCenters(MockViewportFeatureGroupPreview group) {
    return [
      for (final position in group.sourcePositions)
        _featureGroupLocalToCanvas(
          group.kind,
          position,
          referenceWidth: group.referenceWidth,
          referenceHeight: group.referenceHeight,
        ),
    ];
  }

  double featureGroupRadius(MockViewportFeatureGroupPreview group) {
    final targetRect = _featureGroupTargetRect(group.kind);
    final boardScale = math.min(
      targetRect.width / group.referenceWidth.clamp(1, 1000),
      targetRect.height / group.referenceHeight.clamp(1, 1000),
    );
    return (group.itemDiameter * boardScale / 2).clamp(5, 14).toDouble();
  }

  Offset _featureGroupLocalToCanvas(
    MockViewportFeatureGroupKind kind,
    Offset position, {
    required double referenceWidth,
    required double referenceHeight,
  }) {
    final targetRect = _featureGroupTargetRect(kind);
    final safeWidth = referenceWidth.clamp(1, 1000).toDouble();
    final safeHeight = referenceHeight.clamp(1, 1000).toDouble();
    return Offset(
      targetRect.center.dx + (position.dx / safeWidth) * targetRect.width,
      targetRect.center.dy - (position.dy / safeHeight) * targetRect.height,
    );
  }

  Rect _featureGroupTargetRect(MockViewportFeatureGroupKind kind) {
    return switch (kind) {
      MockViewportFeatureGroupKind.buttonGroup => lidRect,
      MockViewportFeatureGroupKind.standoffMounts => boardRect,
    };
  }

  Rect componentPlacementRect(MockViewportComponentPlacementPreview placement) {
    final safeWidth = placement.referenceWidth.clamp(1, 1000).toDouble();
    final safeDepth = placement.referenceDepth.clamp(1, 1000).toDouble();
    final center = lidRect.center.translate(
      (placement.position.dx / safeWidth) * lidRect.width,
      -(placement.position.dy / safeDepth) * lidRect.height,
    );
    final width = (placement.width / safeWidth * lidRect.width)
        .clamp(28 * zoom, lidRect.width * 0.78)
        .toDouble();
    final depth = (placement.depth / safeDepth * lidRect.height)
        .clamp(20 * zoom, lidRect.height * 0.78)
        .toDouble();

    return Rect.fromCenter(center: center, width: width, height: depth);
  }

  Rect workplaneRect(MockViewportWorkplaneOverlay workplane) {
    return switch (workplane.kind) {
      MockViewportWorkplaneKind.topLid => lidRect,
      MockViewportWorkplaneKind.frontWall => frontWallRect,
      MockViewportWorkplaneKind.componentPlacement => componentPlacementRect(
        MockViewportComponentPlacementPreview(
          semanticId: workplane.semanticId,
          width: workplane.width,
          depth: workplane.height,
          referenceWidth: workplane.referenceWidth,
          referenceDepth: workplane.referenceHeight,
          position: workplane.position,
          rotationZDegrees: workplane.rotationZDegrees,
        ),
      ),
    };
  }

  List<Offset> workplaneSnapPoints(MockViewportWorkplaneOverlay workplane) {
    return [
      for (final point in workplane.effectiveSnapPoints)
        workplaneLocalToCanvas(workplane, point),
    ];
  }

  Offset workplaneLocalToCanvas(
    MockViewportWorkplaneOverlay workplane,
    Offset point,
  ) {
    final rect = workplaneRect(workplane);
    final safeWidth = workplane.width.clamp(1, 1000).toDouble();
    final safeHeight = workplane.height.clamp(1, 1000).toDouble();
    final canvasPoint = Offset(
      rect.center.dx + (point.dx / safeWidth) * rect.width,
      rect.center.dy - (point.dy / safeHeight) * rect.height,
    );

    if (workplane.kind != MockViewportWorkplaneKind.componentPlacement) {
      return canvasPoint;
    }

    return _rotateOffset(
      point: canvasPoint,
      center: rect.center,
      degrees: workplane.rotationZDegrees,
    );
  }

  bool containsComponentPlacement(
    MockViewportComponentPlacementPreview placement,
    Offset position, {
    double inflate = 0,
  }) {
    final rect = componentPlacementRect(placement).inflate(inflate);
    final radians = -placement.rotationZDegrees * math.pi / 180;
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    final offset = position - rect.center;
    final local = Offset(
      offset.dx * cos - offset.dy * sin,
      offset.dx * sin + offset.dy * cos,
    );
    final localRect = Rect.fromCenter(
      center: Offset.zero,
      width: rect.width,
      height: rect.height,
    );

    return localRect.contains(local);
  }

  Rect featureRect(MockViewportFeaturePreview feature) {
    return switch (feature.kind) {
      MockViewportFeatureKind.usbC => _usbCFeatureRect(feature),
      MockViewportFeatureKind.glassRecess => _glassRecessFeatureRect(feature),
    };
  }

  double featureCornerRadius(MockViewportFeaturePreview feature) {
    return switch (feature.kind) {
      MockViewportFeatureKind.usbC =>
        (portRadius * (feature.cornerRadius / 1.0).clamp(0.4, 1.8)).toDouble(),
      MockViewportFeatureKind.glassRecess =>
        (feature.cornerRadius / feature.referenceWidth.clamp(1, 1000)) *
            lidRect.width,
    };
  }

  Rect _usbCFeatureRect(MockViewportFeaturePreview feature) {
    final widthScale = (feature.width / 10.5).clamp(0.55, 2.2).toDouble();
    final heightScale = (feature.height / 4.2).clamp(0.55, 2.2).toDouble();
    return Rect.fromCenter(
      center: portRect.center.translate(0, -feature.slotIndex * 18 * zoom),
      width: portRect.width * widthScale,
      height: portRect.height * heightScale,
    );
  }

  Rect _glassRecessFeatureRect(MockViewportFeaturePreview feature) {
    final safeWidth = feature.referenceWidth.clamp(1, 1000).toDouble();
    final safeHeight = feature.referenceHeight.clamp(1, 1000).toDouble();
    final width = (feature.width / safeWidth * lidRect.width)
        .clamp(24 * zoom, lidRect.width * 0.88)
        .toDouble();
    final height = (feature.height / safeHeight * lidRect.height)
        .clamp(18 * zoom, lidRect.height * 0.82)
        .toDouble();
    return Rect.fromCenter(
      center: lidRect.center.translate(
        feature.slotIndex * 10 * zoom,
        -feature.slotIndex * 8 * zoom,
      ),
      width: width,
      height: height,
    );
  }

  static MockViewportLayout fromSize(
    Size size,
    ViewportState state, {
    MockViewportBodyDimensions bodyDimensions =
        const MockViewportBodyDimensions(),
  }) {
    final zoom = state.zoom;
    final center = Offset(size.width / 2, size.height / 2) + state.panOffset;
    final safeWidth = bodyDimensions.width.clamp(20, 300).toDouble();
    final safeDepth = bodyDimensions.depth.clamp(20, 240).toDouble();
    final safeCorner = bodyDimensions.cornerRadius
        .clamp(0, safeDepth / 2)
        .toDouble();
    final bodyAspect = (safeWidth / safeDepth).clamp(1.05, 2.7).toDouble();
    final maxBodyHeight = (size.height * 0.42).clamp(150, 260).toDouble();
    var bodyWidth = (size.width * 0.42).clamp(260, 420).toDouble();
    var bodyHeight = bodyWidth / bodyAspect;
    if (bodyHeight > maxBodyHeight) {
      bodyHeight = maxBodyHeight;
      bodyWidth = bodyHeight * bodyAspect;
    }
    final bodyRect = Rect.fromCenter(
      center: center,
      width: bodyWidth * zoom,
      height: bodyHeight * zoom,
    );
    final yawShift = (state.yawDegrees / 45).clamp(-1.4, 1.4) * 16 * zoom;
    final pitchShift = -(state.pitchDegrees / 45).clamp(-1.2, 1.2) * 14 * zoom;
    final inset = 16 * zoom;
    final lidRect = bodyRect.deflate(inset).shift(Offset(yawShift, pitchShift));
    final boardRect = Rect.fromCenter(
      center: lidRect.center.translate(yawShift * 0.25, 4 * zoom),
      width: lidRect.width * 0.42,
      height: lidRect.height * 0.42,
    );
    final buttonDistance = 28 * zoom;
    final buttonCenters = [
      boardRect.center + Offset(buttonDistance, 0),
      boardRect.center + Offset(0, -buttonDistance),
      boardRect.center + Offset(0, buttonDistance),
      boardRect.center + Offset(-buttonDistance, 0),
    ];
    final portRect = Rect.fromCenter(
      center: Offset(
        bodyRect.center.dx + yawShift * 0.4,
        bodyRect.bottom - 10 * zoom,
      ),
      width: 54 * zoom,
      height: 12 * zoom,
    );
    final frontWallRect = Rect.fromLTWH(
      bodyRect.left + bodyRect.width * 0.22,
      bodyRect.bottom - 30 * zoom,
      bodyRect.width * 0.56,
      30 * zoom,
    );

    return MockViewportLayout(
      bodyRect: bodyRect,
      shadowRect: bodyRect.shift(Offset(18 * zoom, 20 * zoom)),
      lidRect: lidRect,
      boardRect: boardRect,
      portRect: portRect,
      frontWallRect: frontWallRect,
      buttonCenters: buttonCenters,
      bodyRadius: (bodyRect.shortestSide * (safeCorner / safeDepth))
          .clamp(8 * zoom, 32 * zoom)
          .toDouble(),
      lidRadius: (bodyRect.shortestSide * (safeCorner / safeDepth))
          .clamp(6 * zoom, 24 * zoom)
          .toDouble(),
      boardRadius: 8 * zoom,
      buttonRadius: 9 * zoom,
      portRadius: 6 * zoom,
      zoom: zoom,
    );
  }
}

const _defaultComponentPlacementPreviews = [
  MockViewportComponentPlacementPreview(
    semanticId: 'button_board_placement',
    width: 48,
    depth: 32,
    referenceWidth: 120,
    referenceDepth: 70,
  ),
];

class MockViewportHitTester {
  const MockViewportHitTester();

  ViewportHitResult? hitTest({
    required Offset position,
    required Size size,
    required ViewportState state,
    MockViewportBodyDimensions bodyDimensions =
        const MockViewportBodyDimensions(),
    List<MockViewportComponentPlacementPreview> componentPlacements =
        _defaultComponentPlacementPreviews,
    List<MockViewportFeaturePreview> features = const [],
    List<MockViewportFeatureGroupPreview> featureGroups = const [],
  }) {
    final layout = MockViewportLayout.fromSize(
      size,
      state,
      bodyDimensions: bodyDimensions,
    );

    for (final feature in features.reversed) {
      if (layout
          .featureRect(feature)
          .inflate(6 * state.zoom)
          .contains(position)) {
        return ViewportHitResult(
          kind: ViewportHitKind.feature,
          semanticId: feature.semanticId,
        );
      }
    }

    for (final group in featureGroups.reversed) {
      final hitRadius = layout.featureGroupRadius(group) + 8 * state.zoom;
      for (final center in layout.featureGroupCenters(group)) {
        if ((position - center).distance <= hitRadius) {
          return ViewportHitResult(
            kind: ViewportHitKind.featureGroup,
            semanticId: group.semanticId,
          );
        }
      }
    }

    if (layout.portRect.inflate(10 * state.zoom).contains(position)) {
      return const ViewportHitResult(
        kind: ViewportHitKind.feature,
        semanticId: 'front_usb_c',
      );
    }

    for (final center in layout.buttonCenters) {
      if ((position - center).distance <= 16 * state.zoom) {
        return const ViewportHitResult(
          kind: ViewportHitKind.feature,
          semanticId: 'abxy_buttons',
        );
      }
    }

    for (final placement in componentPlacements.reversed) {
      if (layout.containsComponentPlacement(
        placement,
        position,
        inflate: 4 * state.zoom,
      )) {
        return ViewportHitResult(
          kind: ViewportHitKind.componentPlacement,
          semanticId: placement.semanticId,
        );
      }
    }

    if (layout.lidRect.contains(position)) {
      return const ViewportHitResult(
        kind: ViewportHitKind.surface,
        semanticId: 'main_enclosure.top_lid.outer',
        parentId: 'main_enclosure',
      );
    }

    if (layout.frontWallRect.contains(position)) {
      return const ViewportHitResult(
        kind: ViewportHitKind.surface,
        semanticId: 'main_enclosure.front_wall.outer',
        parentId: 'main_enclosure',
      );
    }

    if (layout.bodyRect.contains(position)) {
      return const ViewportHitResult(
        kind: ViewportHitKind.enclosure,
        semanticId: 'main_enclosure',
      );
    }

    return null;
  }
}

const _unchanged = Object();

double _wrapDegrees(double value) {
  var wrapped = value % 360;
  if (wrapped > 180) {
    wrapped -= 360;
  }
  if (wrapped < -180) {
    wrapped += 360;
  }
  return wrapped;
}

Offset _rotateOffset({
  required Offset point,
  required Offset center,
  required double degrees,
}) {
  final radians = degrees * math.pi / 180;
  final cos = math.cos(radians);
  final sin = math.sin(radians);
  final offset = point - center;
  return Offset(
    center.dx + offset.dx * cos - offset.dy * sin,
    center.dy + offset.dx * sin + offset.dy * cos,
  );
}

bool _offsetListsEqual(List<Offset> left, List<Offset> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
