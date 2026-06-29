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

enum MockViewportFeatureGroupKind { standoffMounts }

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

class MockViewportFeatureGroupPreview {
  const MockViewportFeatureGroupPreview({
    required this.semanticId,
    required this.kind,
    required this.sourcePositions,
    required this.boardWidth,
    required this.boardHeight,
    required this.itemDiameter,
  });

  final String semanticId;
  final MockViewportFeatureGroupKind kind;
  final List<Offset> sourcePositions;
  final double boardWidth;
  final double boardHeight;
  final double itemDiameter;

  @override
  bool operator ==(Object other) {
    return other is MockViewportFeatureGroupPreview &&
        other.semanticId == semanticId &&
        other.kind == kind &&
        _offsetListsEqual(other.sourcePositions, sourcePositions) &&
        other.boardWidth == boardWidth &&
        other.boardHeight == boardHeight &&
        other.itemDiameter == itemDiameter;
  }

  @override
  int get hashCode {
    return Object.hash(
      semanticId,
      kind,
      Object.hashAll(sourcePositions),
      boardWidth,
      boardHeight,
      itemDiameter,
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
    required this.buttonCenters,
    required this.bodyRadius,
    required this.lidRadius,
    required this.boardRadius,
    required this.buttonRadius,
    required this.portRadius,
  });

  final Rect bodyRect;
  final Rect shadowRect;
  final Rect lidRect;
  final Rect boardRect;
  final Rect portRect;
  final List<Offset> buttonCenters;
  final double bodyRadius;
  final double lidRadius;
  final double boardRadius;
  final double buttonRadius;
  final double portRadius;

  List<Offset> featureGroupCenters(MockViewportFeatureGroupPreview group) {
    return [
      for (final position in group.sourcePositions)
        _boardLocalToCanvas(
          position,
          boardWidth: group.boardWidth,
          boardHeight: group.boardHeight,
        ),
    ];
  }

  double featureGroupRadius(MockViewportFeatureGroupPreview group) {
    final boardScale = math.min(
      boardRect.width / group.boardWidth.clamp(1, 1000),
      boardRect.height / group.boardHeight.clamp(1, 1000),
    );
    return (group.itemDiameter * boardScale / 2).clamp(5, 14).toDouble();
  }

  Offset _boardLocalToCanvas(
    Offset position, {
    required double boardWidth,
    required double boardHeight,
  }) {
    final safeWidth = boardWidth.clamp(1, 1000).toDouble();
    final safeHeight = boardHeight.clamp(1, 1000).toDouble();
    return Offset(
      boardRect.center.dx + (position.dx / safeWidth) * boardRect.width,
      boardRect.center.dy - (position.dy / safeHeight) * boardRect.height,
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

    return MockViewportLayout(
      bodyRect: bodyRect,
      shadowRect: bodyRect.shift(Offset(18 * zoom, 20 * zoom)),
      lidRect: lidRect,
      boardRect: boardRect,
      portRect: portRect,
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
    );
  }
}

class MockViewportHitTester {
  const MockViewportHitTester();

  ViewportHitResult? hitTest({
    required Offset position,
    required Size size,
    required ViewportState state,
    MockViewportBodyDimensions bodyDimensions =
        const MockViewportBodyDimensions(),
    List<MockViewportFeatureGroupPreview> featureGroups = const [],
  }) {
    final layout = MockViewportLayout.fromSize(
      size,
      state,
      bodyDimensions: bodyDimensions,
    );

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

    if (layout.boardRect.contains(position)) {
      return const ViewportHitResult(
        kind: ViewportHitKind.componentPlacement,
        semanticId: 'button_board_placement',
      );
    }

    if (layout.lidRect.contains(position)) {
      return const ViewportHitResult(
        kind: ViewportHitKind.surface,
        semanticId: 'main_enclosure.top_lid.outer',
        parentId: 'main_enclosure',
      );
    }

    final frontWallRect = Rect.fromLTWH(
      layout.bodyRect.left + layout.bodyRect.width * 0.22,
      layout.bodyRect.bottom - 30 * state.zoom,
      layout.bodyRect.width * 0.56,
      30 * state.zoom,
    );
    if (frontWallRect.contains(position)) {
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
