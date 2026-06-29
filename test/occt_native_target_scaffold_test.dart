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
      expect(source, contains('BRepMesh_IncrementalMesh'));
      expect(source, contains('BRep_Tool'));
      expect(source, contains('Poly_Triangulation'));
      expect(source, contains('BRepBndLib'));
      expect(source, contains('BRepGProp'));
      expect(source, contains('GProp_GProps'));
      expect(source, contains('Standard_Version'));
      expect(source, contains('occt_worker_native_occt'));
      expect(source, contains('preview_mesh_smoke'));
      expect(source, contains('occt.rounded_enclosure.preview_mesh.v1'));
      expect(source, contains('ReadNativeRequest'));
      expect(source, contains('BuildRoundedEnclosureShape'));
      expect(source, contains('BuildPreviewMesh'));
      expect(source, contains('ComputeShapeMetrics'));
      expect(source, contains('WritePreviewMesh'));
      expect(source, contains('worker.backend.occt_operation_not_implemented'));
      expect(source, contains('worker.geometry.invalid_enclosure_dimensions'));
      expect(source, contains('cornerRadiusApplied'));
      expect(source, contains('filletedEdgeCount'));
      expect(source, contains('bounds'));
      expect(source, contains('surfaceArea'));
      expect(source, contains('volume'));
      expect(source, contains('previewMeshEmitted'));
      expect(source, contains('previewVertexCount'));
      expect(source, contains('previewTriangleCount'));
      expect(source, contains('pending_semantic_face_mapping'));
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
      expect(tool, contains('occt.rounded_enclosure.preview_mesh.v1'));
      expect(tool, contains('previewMesh.vertexCount'));
      expect(tool, contains('previewMesh.triangleCount'));
      expect(tool, contains('pending_semantic_face_mapping'));
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
