import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/viewport/viewport_controller.dart';

void main() {
  test('orbit updates yaw and pitch with clamping', () {
    final controller = ViewportController();

    controller.orbit(const Offset(20, -12));
    expect(controller.state.yawDegrees, closeTo(-17, 0.001));
    expect(controller.state.pitchDegrees, closeTo(21, 0.001));

    controller.orbit(const Offset(0, -1000));
    expect(controller.state.pitchDegrees, 70);
  });

  test('pan and fit update camera state without touching selection', () {
    final controller = ViewportController();

    controller.setSelectedSemanticId('main_enclosure');
    controller.pan(const Offset(12, -8));
    controller.zoomByFactor(1.4);

    expect(controller.state.panOffset, const Offset(12, -8));
    expect(controller.state.zoom, closeTo(1.4, 0.001));
    expect(controller.state.selectedSemanticId, 'main_enclosure');

    controller.fit();
    expect(controller.state.panOffset, Offset.zero);
    expect(controller.state.zoom, 1);
    expect(controller.state.selectedSemanticId, isNull);
  });

  test('zoom is clamped to usable bounds', () {
    final controller = ViewportController();

    controller.zoomByFactor(100);
    expect(controller.state.zoom, 2.8);

    controller.zoomByFactor(0.001);
    expect(controller.state.zoom, 0.45);
  });

  test('ghost preview can be set and cleared', () {
    final controller = ViewportController();
    const ghost = GhostPreview(
      kind: GhostPreviewKind.usbC,
      semanticId: 'ghost_usb_c',
      targetSurfaceId: 'main_enclosure.front_wall.outer',
      label: 'USB-C',
    );

    controller.setGhostPreview(ghost);
    expect(controller.state.ghostPreview, ghost);

    controller.setGhostPreview(null);
    expect(controller.state.ghostPreview, isNull);
  });

  test('mock hit tester returns semantic ids, not mesh ids', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const hitTester = MockViewportHitTester();

    final bodyHit = hitTester.hitTest(
      position: layout.bodyRect.topLeft + const Offset(8, 8),
      size: size,
      state: state,
    );
    expect(bodyHit?.kind, ViewportHitKind.enclosure);
    expect(bodyHit?.semanticId, 'main_enclosure');

    final boardHit = hitTester.hitTest(
      position: layout.boardRect.center,
      size: size,
      state: state,
    );
    expect(boardHit?.kind, ViewportHitKind.componentPlacement);
    expect(boardHit?.semanticId, 'button_board_placement');

    final portHit = hitTester.hitTest(
      position: layout.portRect.center,
      size: size,
      state: state,
    );
    expect(portHit?.kind, ViewportHitKind.feature);
    expect(portHit?.semanticId, 'front_usb_c');
  });

  test('mock hit tester returns semantic feature group ids', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const mountGroup = MockViewportFeatureGroupPreview(
      semanticId: 'standoff_mounts_1',
      kind: MockViewportFeatureGroupKind.standoffMounts,
      sourcePositions: [
        Offset(-20, -12),
        Offset(20, -12),
        Offset(-20, 12),
        Offset(20, 12),
      ],
      boardWidth: 48,
      boardHeight: 32,
      itemDiameter: 6,
    );
    const hitTester = MockViewportHitTester();

    final centers = layout.featureGroupCenters(mountGroup);
    expect(centers, hasLength(4));
    expect(centers.first.dx, lessThan(layout.boardRect.center.dx));
    expect(centers.first.dy, greaterThan(layout.boardRect.center.dy));

    final hit = hitTester.hitTest(
      position: centers.first,
      size: size,
      state: state,
      featureGroups: const [mountGroup],
    );

    expect(hit?.kind, ViewportHitKind.featureGroup);
    expect(hit?.semanticId, 'standoff_mounts_1');
  });
}
