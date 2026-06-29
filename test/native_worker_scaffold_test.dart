import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native worker scaffold declares isolated CMake target', () {
    final cmake = File('occt_worker/native/CMakeLists.txt').readAsStringSync();

    expect(
      cmake,
      contains('project(shell_case_occt_worker_native_stub LANGUAGES CXX)'),
    );
    expect(cmake, contains('add_executable(occt_worker_native_stub'));
    expect(cmake, contains('src/main.cpp'));
    expect(cmake, contains('cxx_std_17'));
    expect(cmake.contains('find_package(OpenCASCADE'), isFalse);
    expect(cmake.contains('TopoDS'), isFalse);
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
    expect(source, isNot(contains('TopoDS')));
  });

  test('native worker stub emits structured not implemented response', () {
    final source = File('occt_worker/native/src/main.cpp').readAsStringSync();
    final response =
        jsonDecode(_rawJsonString(source, 'kNativeStubResponseJson'))
            as Map<String, Object?>;
    final issues = response['issues']! as List<Object?>;
    final issue = issues.single as Map<String, Object?>;

    expect(response['schema'], 'shell_case.geometry.response');
    expect(response['status'], 'error');
    expect(response['backend'], 'occt_worker_native_stub');
    expect(issue['severity'], 'error');
    expect(issue['code'], 'worker.backend.native_not_implemented');
    expect(jsonEncode(response), isNot(contains('TopoDS')));
  });

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
