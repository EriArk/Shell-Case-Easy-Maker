import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native worker scaffold declares isolated CMake target', () {
    final cmake = File('occt_worker/native/CMakeLists.txt').readAsStringSync();

    expect(
      cmake,
      contains('project(shell_case_occt_worker_native LANGUAGES CXX)'),
    );
    expect(cmake, contains('option(SHELL_CASE_ENABLE_OCCT'));
    expect(cmake, contains('add_executable(occt_worker_native_stub'));
    expect(cmake, contains('src/main.cpp'));
    expect(cmake, contains('cxx_std_17'));
    expect(cmake, contains('if(SHELL_CASE_ENABLE_OCCT)'));
  });

  test('native worker stub emits protocol-compatible capability JSON', () {
    final source = File('occt_worker/native/src/main.cpp').readAsStringSync();
    final capabilities =
        jsonDecode(_rawJsonString(source, 'kCapabilitiesJson'))
            as Map<String, Object?>;
    final backends = capabilities['backends']! as List<Object?>;
    final native = backends.cast<Map<String, Object?>>().singleWhere(
      (backend) => backend['id'] == 'native',
    );

    expect(capabilities['schema'], 'shell_case.geometry.worker.capabilities');
    expect(capabilities['activeBackend'], 'native');
    expect(capabilities['sourceOfTruth'], 'semantic_project');
    expect(capabilities['editableGeneratedGeometry'], isFalse);
    expect(native['status'], 'stub');
    expect(native['supportedOperations'], isEmpty);
    expect(native['plannedOperations'], contains('preview_mesh'));
    expect(native['plannedOperations'], contains('export_step'));
    expect(
      native['issueCodes'],
      contains('worker.backend.native_not_implemented'),
    );
    expect(native['issueCodes'], contains('worker.request.empty'));
    expect(native['issueCodes'], contains('worker.request.invalid_json'));
    expect(native['issueCodes'], contains('worker.request.invalid_schema'));
    expect(native['issueCodes'], contains('worker.request.invalid_operation'));
    expect(source, isNot(contains('TopoDS')));
  });

  test(
    'native worker stub validates request envelope before scaffold response',
    () {
      final source = File('occt_worker/native/src/main.cpp').readAsStringSync();

      expect(source, contains('ReadNativeRequestEnvelope'));
      expect(source, contains('ExtractTopLevelStringField'));
      expect(source, contains('request.request_id'));
      expect(source, contains('worker.request.empty'));
      expect(source, contains('worker.request.invalid_json'));
      expect(source, contains('worker.request.invalid_schema'));
      expect(source, contains('worker.request.invalid_operation'));
      expect(source, contains('worker.backend.native_not_implemented'));
      expect(source, contains('requestedOperation'));
      expect(source, isNot(contains('native_stub_request')));
      expect(source, isNot(contains('DiscardStdin')));
      expect(source, isNot(contains('TopoDS')));
    },
  );

  test(
    'native worker build script confines generated output to build folder',
    () {
      final script = File(
        'tools/build_occt_worker_stub.ps1',
      ).readAsStringSync();

      expect(script, contains('Assert-ChildPath'));
      expect(script, contains('occt_worker\\native'));
      expect(script, contains('build'));
      expect(script, contains('occt_worker_native'));
      expect(script, contains('occt_worker_native_stub'));
      expect(script, isNot(contains('releases')));
    },
  );

  test('native worker smoke tool exercises build and process client paths', () {
    final tool = File('tool/native_worker_stub_smoke.dart').readAsStringSync();

    expect(tool, contains('build_occt_worker_stub.ps1'));
    expect(tool, contains('GeometryWorkerProcessClient'));
    expect(tool, contains('queryCapabilities()'));
    expect(tool, contains('GeometryRequest.previewMesh'));
    expect(tool, contains('worker.backend.native_not_implemented'));
    expect(tool, contains('requestIdPreserved'));
    expect(tool, contains('--skip-build'));
    expect(tool, contains('--configuration'));
  });
}

String _rawJsonString(String source, String variableName) {
  final pattern = RegExp(
    'constexpr const char\\* $variableName = R"json\\((.*?)\\)json";',
    dotAll: true,
  );
  final match = pattern.firstMatch(source);
  if (match == null) {
    fail('Raw JSON string $variableName was not found.');
  }

  return match.group(1)!;
}
