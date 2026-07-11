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

  test('view presets reset camera while preserving semantic overlays', () {
    final controller = ViewportController();
    const ghost = GhostPreview(
      kind: GhostPreviewKind.buttonGroup,
      semanticId: 'ghost_button_group',
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      label: 'Buttons',
    );

    controller.setSelectedSemanticId('main_enclosure.top_lid.outer');
    controller.setGhostPreview(ghost);
    controller.pan(const Offset(18, 12));
    controller.zoomByFactor(1.7);

    controller.applyViewPreset(ViewportViewPreset.top);
    expect(controller.state.yawDegrees, 0);
    expect(controller.state.pitchDegrees, 70);
    expect(controller.state.zoom, 1);
    expect(controller.state.panOffset, Offset.zero);
    expect(controller.state.selectedSemanticId, 'main_enclosure.top_lid.outer');
    expect(controller.state.ghostPreview, ghost);
    expect(controller.state.activePreset, ViewportViewPreset.top);
    expect(controller.state.viewLabel, contains('TOP'));

    controller.applyViewPreset(ViewportViewPreset.right);
    expect(controller.state.yawDegrees, 90);
    expect(controller.state.pitchDegrees, 0);
    expect(controller.state.activePreset, ViewportViewPreset.right);
    expect(controller.state.viewLabel, contains('RGT'));
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

  test('mock hit tester respects component placement preview list', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const hitTester = MockViewportHitTester();
    const visiblePlacement = MockViewportComponentPlacementPreview(
      semanticId: 'second_board_placement',
      width: 48,
      depth: 32,
      referenceWidth: 120,
      referenceDepth: 70,
    );

    final hiddenHit = hitTester.hitTest(
      position: layout.boardRect.center,
      size: size,
      state: state,
      componentPlacements: const [],
    );
    final visibleHit = hitTester.hitTest(
      position: layout.componentPlacementRect(visiblePlacement).center,
      size: size,
      state: state,
      componentPlacements: const [visiblePlacement],
    );

    expect(hiddenHit?.kind, isNot(ViewportHitKind.componentPlacement));
    expect(visibleHit?.kind, ViewportHitKind.componentPlacement);
    expect(visibleHit?.semanticId, 'second_board_placement');
  });

  test('mock workplane overlay maps surface snap hints to active surface', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'main_enclosure.top_lid.outer',
      kind: MockViewportWorkplaneKind.topLid,
      width: 120,
      height: 70,
      snapPoints: [Offset.zero, Offset(30, 0), Offset(0, 17.5)],
    );

    final rect = layout.workplaneRect(workplane);
    final points = layout.workplaneSnapPoints(workplane);

    expect(rect, layout.lidRect);
    expect(points, hasLength(3));
    expect(points[0], layout.lidRect.center);
    expect(points[1].dx, greaterThan(points[0].dx));
    expect(points[1].dy, closeTo(points[0].dy, 0.001));
    expect(points[2].dx, closeTo(points[0].dx, 0.001));
    expect(points[2].dy, lessThan(points[0].dy));
  });

  test('mock hit tester returns snap point hits before surface hits', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'main_enclosure.top_lid.outer',
      kind: MockViewportWorkplaneKind.topLid,
      width: 120,
      height: 70,
      snapPoints: [Offset.zero, Offset(30, 0)],
    );
    const hitTester = MockViewportHitTester();

    final hit = hitTester.hitTest(
      position: layout.workplaneSnapPoints(workplane).last,
      size: size,
      state: state,
      workplaneOverlay: workplane,
    );

    expect(hit?.kind, ViewportHitKind.snapPoint);
    expect(hit?.semanticId, 'main_enclosure.top_lid.outer');
    expect(hit?.workplaneKind, MockViewportWorkplaneKind.topLid);
    expect(hit?.snapIndex, 1);
    expect(hit?.localPosition, const Offset(30, 0));
  });

  test('mock hit tester maps surface workplane clicks to local positions', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'main_enclosure.top_lid.outer',
      kind: MockViewportWorkplaneKind.topLid,
      width: 120,
      height: 70,
      snapPoints: [Offset.zero],
    );
    const hitTester = MockViewportHitTester();
    const localPoint = Offset(24, -14);

    final hit = hitTester.hitTest(
      position: layout.workplaneLocalToCanvas(workplane, localPoint),
      size: size,
      state: state,
      workplaneOverlay: workplane,
      componentPlacements: const [],
    );

    expect(hit?.kind, ViewportHitKind.snapPoint);
    expect(hit?.semanticId, 'main_enclosure.top_lid.outer');
    expect(hit?.workplaneKind, MockViewportWorkplaneKind.topLid);
    expect(hit?.snapIndex, isNull);
    expect(hit?.localPosition?.dx, closeTo(localPoint.dx, 0.001));
    expect(hit?.localPosition?.dy, closeTo(localPoint.dy, 0.001));
  });

  test(
    'mock hit tester keeps visible placements above overlapping snap points',
    () {
      const state = ViewportState();
      const size = Size(900, 600);
      final layout = MockViewportLayout.fromSize(size, state);
      const workplane = MockViewportWorkplaneOverlay(
        semanticId: 'main_enclosure.top_lid.outer',
        kind: MockViewportWorkplaneKind.topLid,
        width: 120,
        height: 70,
        snapPoints: [Offset.zero],
      );
      const placement = MockViewportComponentPlacementPreview(
        semanticId: 'button_board_placement',
        width: 48,
        depth: 32,
        referenceWidth: 120,
        referenceDepth: 70,
      );
      const hitTester = MockViewportHitTester();

      final hit = hitTester.hitTest(
        position: layout.workplaneSnapPoints(workplane).single,
        size: size,
        state: state,
        componentPlacements: const [placement],
        workplaneOverlay: workplane,
      );

      expect(hit?.kind, ViewportHitKind.componentPlacement);
      expect(hit?.semanticId, 'button_board_placement');
    },
  );

  test('mock workplane overlay rotates component placement snap hints', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'button_board_placement',
      kind: MockViewportWorkplaneKind.componentPlacement,
      width: 48,
      height: 32,
      referenceWidth: 120,
      referenceHeight: 70,
      rotationZDegrees: 90,
      snapPoints: [Offset.zero, Offset(20, 0)],
    );

    final rect = layout.workplaneRect(workplane);
    final points = layout.workplaneSnapPoints(workplane);
    final placementRect = layout.componentPlacementRect(
      const MockViewportComponentPlacementPreview(
        semanticId: 'button_board_placement',
        width: 48,
        depth: 32,
        referenceWidth: 120,
        referenceDepth: 70,
        rotationZDegrees: 90,
      ),
    );

    expect(rect.center, placementRect.center);
    expect(points[0], rect.center);
    expect(points[1].dx, closeTo(points[0].dx, 0.001));
    expect(points[1].dy, greaterThan(points[0].dy));
  });

  test('mock hit tester returns semantic feature marker ids', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const usbC = MockViewportFeaturePreview(
      semanticId: 'usb_c_cutout_2',
      kind: MockViewportFeatureKind.usbC,
      targetSurfaceId: 'main_enclosure.front_wall.outer',
      width: 12,
      height: 4.2,
      cornerRadius: 1,
      slotIndex: 1,
    );
    const glass = MockViewportFeaturePreview(
      semanticId: 'glass_recess_1',
      kind: MockViewportFeatureKind.glassRecess,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 50,
      height: 24,
      cornerRadius: 2,
    );
    const circularCutout = MockViewportFeaturePreview(
      semanticId: 'circular_cutout_1',
      kind: MockViewportFeatureKind.circularCutout,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 10,
      height: 10,
      position: Offset(16, -8),
    );
    const rectangularCutout = MockViewportFeaturePreview(
      semanticId: 'rectangular_cutout_1',
      kind: MockViewportFeatureKind.rectangularCutout,
      targetSurfaceId: 'main_enclosure.top_lid.outer',
      width: 18,
      height: 10,
      cornerRadius: 2,
      position: Offset(-20, 10),
    );
    const hitTester = MockViewportHitTester();

    expect(
      layout.featureRect(usbC).center.dy,
      lessThan(layout.portRect.center.dy),
    );
    expect(layout.lidRect.contains(layout.featureRect(glass).center), isTrue);
    expect(
      layout.lidRect.contains(layout.featureRect(circularCutout).center),
      isTrue,
    );
    expect(
      layout.lidRect.contains(layout.featureRect(rectangularCutout).center),
      isTrue,
    );

    final usbHit = hitTester.hitTest(
      position: layout.featureRect(usbC).center,
      size: size,
      state: state,
      features: const [usbC, glass, circularCutout, rectangularCutout],
    );
    expect(usbHit?.kind, ViewportHitKind.feature);
    expect(usbHit?.semanticId, 'usb_c_cutout_2');

    final glassHit = hitTester.hitTest(
      position: layout.featureRect(glass).center,
      size: size,
      state: state,
      features: const [usbC, glass, circularCutout, rectangularCutout],
    );
    expect(glassHit?.kind, ViewportHitKind.feature);
    expect(glassHit?.semanticId, 'glass_recess_1');

    final circularHit = hitTester.hitTest(
      position: layout.featureRect(circularCutout).center,
      size: size,
      state: state,
      features: const [usbC, glass, circularCutout, rectangularCutout],
    );
    expect(circularHit?.kind, ViewportHitKind.feature);
    expect(circularHit?.semanticId, 'circular_cutout_1');

    final rectangularHit = hitTester.hitTest(
      position: layout.featureRect(rectangularCutout).center,
      size: size,
      state: state,
      features: const [usbC, glass, circularCutout, rectangularCutout],
    );
    expect(rectangularHit?.kind, ViewportHitKind.feature);
    expect(rectangularHit?.semanticId, 'rectangular_cutout_1');
  });

  test(
    'mock hit tester returns parent sketch feature for rectangle overlays',
    () {
      const state = ViewportState();
      const size = Size(900, 600);
      final layout = MockViewportLayout.fromSize(size, state);
      const workplane = MockViewportWorkplaneOverlay(
        semanticId: 'main_enclosure.top_lid.outer',
        kind: MockViewportWorkplaneKind.topLid,
        width: 120,
        height: 70,
      );
      const rectangle = MockViewportSketchRectanglePreview(
        featureId: 'advanced_sketch_1',
        entityId: 'rect_1',
        workplane: workplane,
        center: Offset(18, -12),
        width: 24,
        height: 16,
        cornerRadius: 2,
      );
      const hitTester = MockViewportHitTester();

      final hit = hitTester.hitTest(
        position: rectangle.canvasRect(layout).center,
        size: size,
        state: state,
        componentPlacements: const [],
        sketchRectangles: const [rectangle],
      );

      expect(hit?.kind, ViewportHitKind.feature);
      expect(hit?.semanticId, 'advanced_sketch_1');
      expect(hit?.childId, 'rect_1');
    },
  );

  test('mock hit tester uses rotated bounds for sketch rectangles', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'main_enclosure.top_lid.outer',
      kind: MockViewportWorkplaneKind.topLid,
      width: 120,
      height: 70,
    );
    const rectangle = MockViewportSketchRectanglePreview(
      featureId: 'advanced_sketch_1',
      entityId: 'rect_1',
      workplane: workplane,
      center: Offset.zero,
      width: 60,
      height: 10,
      cornerRadius: 1,
      rotationZDegrees: 45,
    );
    const hitTester = MockViewportHitTester();

    final rect = rectangle.canvasRect(layout);
    final axisOnlyPoint = rect.center.translate(rect.width / 2 - 1, 0);

    final hit = hitTester.hitTest(
      position: axisOnlyPoint,
      size: size,
      state: state,
      componentPlacements: const [],
      sketchRectangles: const [rectangle],
    );

    expect(hit?.semanticId, isNot('advanced_sketch_1'));
    expect(hit?.childId, isNot('rect_1'));
  });

  test('mock hit tester returns parent sketch feature for circle overlays', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const workplane = MockViewportWorkplaneOverlay(
      semanticId: 'main_enclosure.top_lid.outer',
      kind: MockViewportWorkplaneKind.topLid,
      width: 120,
      height: 70,
    );
    const circle = MockViewportSketchCirclePreview(
      featureId: 'advanced_sketch_1',
      entityId: 'circle_1',
      workplane: workplane,
      center: Offset(-18, 12),
      diameter: 18,
    );
    const hitTester = MockViewportHitTester();

    final hit = hitTester.hitTest(
      position: circle.canvasCenter(layout),
      size: size,
      state: state,
      componentPlacements: const [],
      sketchCircles: const [circle],
    );

    expect(hit?.kind, ViewportHitKind.feature);
    expect(hit?.semanticId, 'advanced_sketch_1');
    expect(hit?.childId, 'circle_1');
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
      referenceWidth: 48,
      referenceHeight: 32,
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

  test('mock hit tester maps button group markers to lid surface', () {
    const state = ViewportState();
    const size = Size(900, 600);
    final layout = MockViewportLayout.fromSize(size, state);
    const buttonGroup = MockViewportFeatureGroupPreview(
      semanticId: 'button_group_1',
      kind: MockViewportFeatureGroupKind.buttonGroup,
      sourcePositions: [
        Offset(14, 0),
        Offset(0, -14),
        Offset(0, 14),
        Offset(-14, 0),
      ],
      referenceWidth: 120,
      referenceHeight: 70,
      itemDiameter: 8,
    );
    const hitTester = MockViewportHitTester();

    final centers = layout.featureGroupCenters(buttonGroup);
    expect(centers, hasLength(4));
    expect(layout.lidRect.contains(centers.first), isTrue);

    final hit = hitTester.hitTest(
      position: centers.first,
      size: size,
      state: state,
      featureGroups: const [buttonGroup],
    );

    expect(hit?.kind, ViewportHitKind.featureGroup);
    expect(hit?.semanticId, 'button_group_1');
  });
}
