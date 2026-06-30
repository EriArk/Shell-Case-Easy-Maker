import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OCCT native target is opt-in and separate from the stub', () {
    final cmake = File('occt_worker/native/CMakeLists.txt').readAsStringSync();

    expect(cmake, contains('SHELL_CASE_ENABLE_OCCT'));
    expect(cmake, contains('add_executable(occt_worker_native_stub'));
    expect(cmake, contains('add_executable(occt_worker_native_occt'));
    expect(cmake, contains('src/occt_main.cpp'));
    expect(cmake, contains('find_package(OpenCASCADE CONFIG REQUIRED)'));
    expect(cmake, contains('target_link_libraries(occt_worker_native_occt'));
    expect(cmake, contains('OpenCASCADE_LIBRARIES'));
    expect(cmake, contains('OpenCASCADE_INCLUDE_DIR'));

    final optionIndex = cmake.indexOf('if(SHELL_CASE_ENABLE_OCCT)');
    final findPackageIndex = cmake.indexOf('find_package(OpenCASCADE');
    expect(optionIndex, isNonNegative);
    expect(findPackageIndex, greaterThan(optionIndex));
  });

  test(
    'OCCT target source emits deterministic rounded enclosure preview mesh',
    () {
      final source = File(
        'occt_worker/native/src/occt_main.cpp',
      ).readAsStringSync();

      expect(source, contains('BRepPrimAPI_MakeBox'));
      expect(source, contains('BRepFilletAPI_MakeFillet'));
      expect(source, contains('BRepAlgoAPI_Cut'));
      expect(source, contains('BRepMesh_IncrementalMesh'));
      expect(source, contains('BRep_Tool'));
      expect(source, contains('Poly_Triangulation'));
      expect(source, contains('BRepBndLib'));
      expect(source, contains('BRepGProp'));
      expect(source, contains('GProp_GProps'));
      expect(source, contains('Standard_Version'));
      expect(source, contains('occt_worker_native_occt'));
      expect(source, contains('preview_mesh_smoke'));
      expect(source, contains('occt.rounded_enclosure.shell_preview_mesh.v1'));
      expect(source, contains('ReadNativeRequest'));
      expect(source, contains('BuildRoundedEnclosureShape'));
      expect(source, contains('BuildCavityCutTool'));
      expect(source, contains('BuildTopOpenEnclosureShell'));
      expect(source, contains('LidScrewBossRequest'));
      expect(source, contains('UsbCCutoutRequest'));
      expect(source, contains('GlassRecessRequest'));
      expect(source, contains('ButtonGroupCutoutRequest'));
      expect(source, contains('StandoffMountGroupRequest'));
      expect(source, contains('GeneratedLidSeatRequest'));
      expect(source, contains('BuildLidScrewBossShape'));
      expect(source, contains('ApplyNativeLidScrewBosses'));
      expect(source, contains('BuildUsbCCutoutTool'));
      expect(source, contains('BuildGlassRecessTool'));
      expect(source, contains('BuildButtonCutoutTool'));
      expect(source, contains('BuildStandoffMountShape'));
      expect(source, contains('ApplyNativeFeatureCutouts'));
      expect(source, contains('BuildPreviewMesh'));
      expect(source, contains('FaceIntersectsUsbCCutout'));
      expect(source, contains('FaceIntersectsLidScrewBoss'));
      expect(source, contains('FaceIntersectsGeneratedLidSeat'));
      expect(source, contains('FaceIntersectsGeneratedLidPlate'));
      expect(source, contains('FaceIntersectsGeneratedLidLocatingLip'));
      expect(source, contains('FaceIntersectsGeneratedLidScrewHole'));
      expect(source, contains('FaceIntersectsGlassRecess'));
      expect(source, contains('FaceIntersectsButtonCutout'));
      expect(source, contains('FaceIntersectsStandoffMount'));
      expect(source, contains('BRepPrimAPI_MakeCylinder'));
      expect(source, contains('BRepAlgoAPI_Fuse'));
      expect(source, contains('BRep_Builder'));
      expect(source, contains('TopoDS_Compound'));
      expect(source, contains('GeneratedLidPlateRequest'));
      expect(source, contains('BuildGeneratedTopLidSeatTools'));
      expect(source, contains('ApplyGeneratedTopLidSeats'));
      expect(source, contains('BuildGeneratedTopLidPlateShape'));
      expect(source, contains('BuildGeneratedTopLidLocatingLipShape'));
      expect(source, contains('GeneratedTopLidLipWidth'));
      expect(source, contains('GeneratedTopLidLipHeight'));
      expect(source, contains('GeneratedTopLidFitPreviewGap'));
      expect(source, contains('BuildGeneratedTopLidScrewHoleTool'));
      expect(source, contains('BuildGeneratedTopLidButtonCutoutTool'));
      expect(source, contains('GeneratedTopLidScrewClearanceDiameter'));
      expect(source, contains('BuildPreviewAssembly'));
      expect(source, contains('ClassifyPreviewSurface'));
      expect(source, contains('ClassifyPreviewSurfaces'));
      expect(source, contains('PreviewSurfaceMappingData'));
      expect(source, contains('ComputeShapeMetrics'));
      expect(source, contains('WritePreviewMesh'));
      expect(source, contains('WritePreviewSurfaceMappings'));
      expect(source, contains('worker.backend.occt_operation_not_implemented'));
      expect(source, contains('worker.geometry.invalid_enclosure_dimensions'));
      expect(source, contains('cornerRadiusApplied'));
      expect(source, contains('filletedEdgeCount'));
      expect(source, contains('shellCavityApplied'));
      expect(source, contains('shellCavityValid'));
      expect(source, contains('shellCavityToolCount'));
      expect(source, contains('shellOpening'));
      expect(source, contains('featureIntentCount'));
      expect(source, contains('nativeFeatureCutCount'));
      expect(source, contains('nativeIgnoredFeatureIntentCount'));
      expect(source, contains('nativeLidScrewBossCount'));
      expect(source, contains('nativeLidScrewPilotCount'));
      expect(source, contains('nativeGeneratedLidPlateCount'));
      expect(source, contains('nativeGeneratedLidSeatCount'));
      expect(source, contains('nativeGeneratedLidFitPreviewGap'));
      expect(source, contains('nativeGeneratedLidLipCount'));
      expect(source, contains('nativeGeneratedLidScrewHoleCount'));
      expect(source, contains('nativeGeneratedLidFeatureCutCount'));
      expect(source, contains('nativeGeneratedLidButtonGroupCount'));
      expect(source, contains('nativeGeneratedLidButtonCutoutCount'));
      expect(source, contains('nativeUsbCCutoutCount'));
      expect(source, contains('nativeUsbCCutoutFilletedEdgeCount'));
      expect(source, contains('nativeGlassRecessCount'));
      expect(source, contains('nativeGlassRecessFilletedEdgeCount'));
      expect(source, contains('nativeButtonGroupCount'));
      expect(source, contains('nativeButtonCutoutCount'));
      expect(source, contains('nativeStandoffGroupCount'));
      expect(source, contains('nativeStandoffMountCount'));
      expect(source, contains('bounds'));
      expect(source, contains('surfaceArea'));
      expect(source, contains('volume'));
      expect(source, contains('previewMeshEmitted'));
      expect(source, contains('previewVertexCount'));
      expect(source, contains('previewTriangleCount'));
      expect(source, contains('previewSurfaceMappingCount'));
      expect(source, contains('previewMappedTriangleCount'));
      expect(source, contains('semantic_face_ranges_v1'));
      expect(source, contains('.top_lid.outer'));
      expect(source, contains('.front_wall.outer'));
      expect(source, contains('.bottom_inside'));
      expect(source, contains('.lid_screw_bosses'));
      expect(source, contains('.generated_top_lid'));
      expect(source, contains('.generated_top_lid_seat'));
      expect(source, contains('.generated_top_lid_locating_lip'));
      expect(source, contains('.generated_top_lid_screw_holes'));
      expect(source, contains('FaceIntersectsGeneratedTopLidButtonCutout'));
      expect(source, contains('Lid screw bosses'));
      expect(source, contains('Generated lid'));
      expect(source, contains('Lid seat'));
      expect(source, contains('Lid locating lip'));
      expect(source, contains('Lid screw holes'));
      expect(source, contains('Top lid buttons'));
      expect(source, contains('USB-C cutout'));
      expect(source, contains('Glass recess'));
      expect(source, contains('Button group'));
      expect(source, contains('Standoff mounts'));
      expect(source, contains('editableGeneratedGeometry'));
      expect(source, contains('semantic_project'));
      expect(source, contains('nativeHealthShapeNull'));
      expect(source, isNot(contains('linked_smoke')));
      expect(source, isNot(contains('worker.backend.occt_link_smoke_only')));
      expect(source, isNot(contains('topologyId')));
      expect(source, isNot(contains('triangleId')));
    },
  );

  test(
    'OCCT build script requires readiness and does not install packages',
    () {
      final script = File(
        'tools/build_occt_worker_occt.ps1',
      ).readAsStringSync();

      expect(script, contains('check_occt_windows_readiness.ps1'));
      expect(script, contains('AllowVcpkgInstall'));
      expect(script, contains('occt_worker_native_occt'));
      expect(script, contains('SHELL_CASE_ENABLE_OCCT=ON'));
      expect(script, contains('Assert-ChildPath'));
      expect(script, contains('build'));
      expect(script, contains('occt_worker_native_occt'));
      expect(script, contains('CMAKE_TOOLCHAIN_FILE'));
      expect(script, contains('VCPKG_TARGET_TRIPLET'));
      expect(script, contains('VCPKG_MANIFEST_MODE=ON'));
      expect(script, contains('VCPKG_MANIFEST_MODE=OFF'));
      expect(script, contains('vcpkg_installed'));
      expect(script, contains('OCCT is ready from a vcpkg manifest install'));
      expect(script, contains('OpenCASCADE_DIR'));
      expect(script, contains('exit 2'));
      expect(script, isNot(contains('& vcpkg')));
      expect(script, isNot(contains('vcpkg install')));
      expect(script, isNot(contains('Invoke-Expression')));
      expect(script, isNot(contains('releases')));
    },
  );

  test('OCCT vcpkg manifest keeps dependency explicit', () {
    final manifest =
        jsonDecode(File('occt_worker/native/vcpkg.json').readAsStringSync())
            as Map<String, Object?>;
    final dependencies = manifest['dependencies']! as List<Object?>;

    expect(manifest['name'], 'shell-case-occt-worker-native');
    expect(dependencies, contains('opencascade'));
    expect(jsonEncode(manifest), isNot(contains('freecad')));
    expect(jsonEncode(manifest), isNot(contains('opencascade source')));
  });

  test(
    'OCCT smoke tool validates the native preview mesh response contract',
    () {
      final tool = File(
        'tool/native_occt_worker_metrics_smoke.dart',
      ).readAsStringSync();

      expect(tool, contains('build_occt_worker_occt.ps1'));
      expect(tool, contains('AllowVcpkgInstall'));
      expect(tool, contains('GeometryWorkerProcessClient'));
      expect(tool, contains('queryCapabilities()'));
      expect(tool, contains('GeometryRequest.previewMesh'));
      expect(tool, contains('preview_mesh_smoke'));
      expect(tool, contains('occt.rounded_enclosure.shell_preview_mesh.v1'));
      expect(tool, contains('previewMesh.vertexCount'));
      expect(tool, contains('previewMesh.triangleCount'));
      expect(tool, contains('previewMesh.surfaces.length == 13'));
      expect(tool, contains('main_enclosure.lid_screw_bosses'));
      expect(tool, contains('main_enclosure.generated_top_lid'));
      expect(tool, contains('main_enclosure.generated_top_lid_seat'));
      expect(tool, contains('main_enclosure.generated_top_lid_locating_lip'));
      expect(tool, contains('main_enclosure.generated_top_lid_screw_holes'));
      expect(tool, contains('top_lid_buttons'));
      expect(tool, contains('front_usb_c'));
      expect(tool, contains('front_glass_recess'));
      expect(tool, contains('front_buttons'));
      expect(tool, contains('standoff_mounts_1'));
      expect(tool, contains('shellCavityApplied'));
      expect(tool, contains('shellCavityValid'));
      expect(tool, contains('shellCavityToolCount'));
      expect(tool, contains('shellOpening'));
      expect(tool, contains('featureIntentCount'));
      expect(tool, contains('nativeFeatureCutCount'));
      expect(tool, contains('nativeIgnoredFeatureIntentCount'));
      expect(tool, contains('nativeLidScrewBossCount'));
      expect(tool, contains('nativeLidScrewPilotCount'));
      expect(tool, contains('nativeGeneratedLidPlateCount'));
      expect(tool, contains('nativeGeneratedLidSeatCount'));
      expect(tool, contains('nativeGeneratedLidFitPreviewGap'));
      expect(tool, contains('nativeGeneratedLidLipCount'));
      expect(tool, contains('nativeGeneratedLidScrewHoleCount'));
      expect(tool, contains('nativeGeneratedLidFeatureCutCount'));
      expect(tool, contains('nativeGeneratedLidButtonGroupCount'));
      expect(tool, contains('nativeGeneratedLidButtonCutoutCount'));
      expect(tool, contains('nativeUsbCCutoutCount'));
      expect(tool, contains('nativeUsbCCutoutFilletedEdgeCount'));
      expect(tool, contains('nativeGlassRecessCount'));
      expect(tool, contains('nativeGlassRecessFilletedEdgeCount'));
      expect(tool, contains('nativeButtonGroupCount'));
      expect(tool, contains('nativeButtonCutoutCount'));
      expect(tool, contains('nativeStandoffGroupCount'));
      expect(tool, contains('nativeStandoffMountCount'));
      expect(tool, contains('semantic_face_ranges_v1'));
      expect(tool, contains('previewSurfaceMappingCount'));
      expect(tool, contains('previewMappedTriangleCount'));
      expect(tool, contains('surfaceArea'));
      expect(tool, contains('volume'));
      expect(tool, contains('previewMeshEmitted'));
      expect(tool, contains('editableGeneratedGeometry'));
      expect(tool, contains('topologyId'));
      expect(tool, contains('triangleId'));
      expect(tool, contains('--skip-build'));
      expect(tool, contains('--configuration'));
    },
  );
}
