import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/json_helpers.dart';

void main() {
  test('preview request fixture includes feature intents and group items', () {
    final request = _readFixtureRequest();

    expect(request.requestId, 'preview_sample_001');
    expect(
      request.featureIntents.map((intent) => intent.id),
      containsAll([
        'front_usb_c',
        'abxy_buttons',
        'projected_buttons',
        'standoff_mounts_1',
      ]),
    );
    expect(
      request.featureIntents
          .singleWhere((intent) => intent.id == 'projected_buttons')
          .items,
      hasLength(4),
    );
    expect(
      request.featureIntents
          .singleWhere((intent) => intent.id == 'standoff_mounts_1')
          .items,
      hasLength(4),
    );
  });

  test('preview response fixture carries operation plan metrics', () {
    final response = _readFixtureResponse();

    expect(response.requestId, 'preview_sample_001');
    expect(response.status, GeometryResponseStatus.ok);
    expect(response.backend, 'mock');
    expect(response.previewMesh?.vertexCount, 8);
    expect(response.previewMesh?.triangleCount, 12);
    expect(response.metrics['featureIntents'], 4);
    expect(response.metrics['operationCount'], 10);
    expect(response.metrics['operationPlan'], isA<List<Object?>>());
  });

  test('preview fixture request reproduces response operation count', () async {
    const service = MockGeometryService();
    final response = await service.buildGeometry(_readFixtureRequest());

    expect(response.status, GeometryResponseStatus.ok);
    expect(response.metrics['featureIntents'], 4);
    expect(response.metrics['operationCount'], 10);
  });
}

GeometryRequest _readFixtureRequest() {
  final decoded = jsonDecode(
    File(
      'occt_worker/protocol/preview_request.example.json',
    ).readAsStringSync(),
  );
  return GeometryRequest.fromJson(readJsonMap(decoded));
}

GeometryResponse _readFixtureResponse() {
  final decoded = jsonDecode(
    File(
      'occt_worker/protocol/preview_response.example.json',
    ).readAsStringSync(),
  );
  return GeometryResponse.fromJson(readJsonMap(decoded));
}
