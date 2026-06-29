import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'OCCT Windows readiness script is read-only and reports JSON contract',
    () {
      final script = File(
        'tools/check_occt_windows_readiness.ps1',
      ).readAsStringSync();

      expect(script, contains('shell_case.occt.windows_readiness'));
      expect(script, contains('OpenCASCADEConfig.cmake'));
      expect(script, contains('VCPKG_ROOT'));
      expect(script, contains('OpenCASCADE_DIR'));
      expect(script, contains('CASROOT'));
      expect(script, contains('RequireOcct'));
      expect(script, contains('ConvertTo-Json'));
      expect(script, contains('exit 2'));
      expect(script, contains('vcpkg install'));
      expect(script, isNot(contains('& vcpkg')));
      expect(script, isNot(contains('Start-Process')));
      expect(script, isNot(contains('Invoke-Expression')));
      expect(script, isNot(contains('cmake --build')));
      expect(script, isNot(contains('Remove-Item')));
    },
  );

  test('OCCT Windows dependency plan keeps worker boundary explicit', () {
    final note = File(
      'docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md',
    ).readAsStringSync();

    expect(note, contains('OpenCASCADEConfig.cmake'));
    expect(note, contains('LGPL 2.1'));
    expect(note, contains('Open CASCADE additional exception'));
    expect(note, contains('occt_worker_native_stub'));
    expect(note, contains('occt_worker_native_occt'));
    expect(note, contains('GeometryService'));
    expect(note, contains('generated B-Rep'));
    expect(note, contains('tools\\check_occt_windows_readiness.ps1'));
    expect(note, contains('editable project state'));
    expect(note, contains('Do not copy GPL/AGPL'));
  });
}
