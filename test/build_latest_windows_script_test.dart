import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('latest Windows build can bundle native OCCT worker explicitly', () {
    final script = File('tools/build_latest_windows.ps1').readAsStringSync();

    expect(script, contains('NativeOcct'));
    expect(script, contains('SkipNativeOcctBuild'));
    expect(script, contains('build_occt_worker_occt.ps1'));
    expect(script, contains('AllowVcpkgInstall'));
    expect(script, contains('SHELL_CASE_GEOMETRY_BACKEND=native_occt'));
    expect(script, contains('occt_worker\\native'));
    expect(script, contains('occt_worker_native_occt.exe'));
    expect(script, contains(r'Assert-ChildPath -Path $nativeWorkerTargetDir'));
    expect(script, contains('Copy-Item'));
    expect(script, isNot(contains('git clone')));
    expect(script, isNot(contains('Invoke-Expression')));
  });
}
