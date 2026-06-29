import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vcpkg bootstrap helper keeps OpenCASCADE restore explicit', () {
    final script = File('tools/bootstrap_vcpkg_windows.ps1').readAsStringSync();

    expect(script, contains('PlanOnly'));
    expect(script, contains('InstallOpenCascade'));
    expect(script, contains('SetUserEnvironment'));
    expect(script, contains('shell_case.occt.vcpkg_bootstrap'));
    expect(script, contains('external'));
    expect(script, contains('vcpkg'));
    expect(script, contains('https://github.com/microsoft/vcpkg.git'));
    expect(script, contains('bootstrap-vcpkg.bat'));
    expect(script, contains('occt_worker\\native'));
    expect(script, contains('vcpkg.json'));
    expect(script, contains('opencascade'));
    expect(script, contains('check_occt_windows_readiness.ps1'));
    expect(script, contains('Assert-ChildPath'));

    final gateIndex = script.indexOf(r'if ($InstallOpenCascade)');
    final installIndex = script.indexOf('"install"', gateIndex);
    expect(gateIndex, isNonNegative);
    expect(installIndex, greaterThan(gateIndex));

    expect(script, isNot(contains('Start-Process')));
    expect(script, isNot(contains('Invoke-Expression')));
    expect(script, isNot(contains('Remove-Item')));
    expect(script, isNot(contains('releases')));
    expect(script, isNot(contains('build_latest_windows')));
  });

  test('repo-local vcpkg checkout is ignored by git', () {
    final gitignore = File('.gitignore').readAsStringSync();

    expect(gitignore, contains('/external/'));
    expect(gitignore, contains('/occt_worker/native/vcpkg_installed/'));
  });
}
