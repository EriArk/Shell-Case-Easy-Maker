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

  test('OCCT target source proves linkage without exposing topology IDs', () {
    final source = File(
      'occt_worker/native/src/occt_main.cpp',
    ).readAsStringSync();

    expect(source, contains('BRepPrimAPI_MakeBox'));
    expect(source, contains('Standard_Version'));
    expect(source, contains('occt_worker_native_occt'));
    expect(source, contains('linked_smoke'));
    expect(source, contains('worker.backend.occt_link_smoke_only'));
    expect(source, contains('editableGeneratedGeometry'));
    expect(source, contains('semantic_project'));
    expect(source, contains('linkSmokeShapeNull'));
    expect(source, isNot(contains('topologyId')));
    expect(source, isNot(contains('triangleId')));
  });

  test(
    'OCCT build script requires readiness and does not install packages',
    () {
      final script = File(
        'tools/build_occt_worker_occt.ps1',
      ).readAsStringSync();

      expect(script, contains('check_occt_windows_readiness.ps1'));
      expect(script, contains('occt_worker_native_occt'));
      expect(script, contains('SHELL_CASE_ENABLE_OCCT=ON'));
      expect(script, contains('Assert-ChildPath'));
      expect(script, contains('build'));
      expect(script, contains('occt_worker_native_occt'));
      expect(script, contains('CMAKE_TOOLCHAIN_FILE'));
      expect(script, contains('OpenCASCADE_DIR'));
      expect(script, contains('exit 2'));
      expect(script, isNot(contains('& vcpkg')));
      expect(script, isNot(contains('vcpkg install')));
      expect(script, isNot(contains('Invoke-Expression')));
      expect(script, isNot(contains('releases')));
    },
  );
}
