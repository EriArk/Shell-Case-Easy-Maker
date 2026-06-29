import 'dart:convert';
import 'dart:io';

import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/json_helpers.dart';

Future<void> main(List<String> args) async {
  final payload = await stdin.transform(utf8.decoder).join();
  const geometryService = MockGeometryService();
  final handler = GeometryWorkerProtocolHandler(
    buildGeometry: geometryService.buildGeometry,
  );
  final responseJson = await handler.handleJsonToString(payload);

  stdout.writeln(responseJson);

  final decoded = jsonDecode(responseJson);
  final response = decoded is Map<Object?, Object?>
      ? GeometryResponse.fromJson(readJsonMap(decoded))
      : null;
  if (response == null || response.hasErrors) {
    exitCode = 2;
  }
}
