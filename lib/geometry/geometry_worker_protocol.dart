import 'dart:convert';

import '../project/json_helpers.dart';
import 'geometry_protocol.dart';

typedef GeometryBuildHandler =
    Future<GeometryResponse> Function(GeometryRequest request);

class GeometryWorkerProtocolHandler {
  const GeometryWorkerProtocolHandler({required this.buildGeometry});

  final GeometryBuildHandler buildGeometry;

  Future<GeometryResponse> handleJson(String payload) async {
    Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException catch (error) {
      return _errorResponse(
        code: 'worker.request.invalid_json',
        message: 'Geometry worker request is not valid JSON: ${error.message}',
      );
    }

    if (decoded is! Map<Object?, Object?>) {
      return _errorResponse(
        code: 'worker.request.invalid_shape',
        message: 'Geometry worker request must be a JSON object.',
      );
    }

    if (decoded['project'] is! Map<Object?, Object?>) {
      return _errorResponse(
        code: 'worker.request.invalid_payload',
        message: 'Geometry worker request must contain a project object.',
      );
    }

    final GeometryRequest request;
    try {
      request = GeometryRequest.fromJson(readJsonMap(decoded));
    } on Object catch (error) {
      return _errorResponse(
        code: 'worker.request.invalid_payload',
        message: 'Geometry worker request payload is invalid: $error',
      );
    }
    return buildGeometry(request);
  }

  Future<String> handleJsonToString(String payload) async {
    final response = await handleJson(payload);
    return const JsonEncoder.withIndent('  ').convert(response.toJson());
  }

  GeometryResponse _errorResponse({
    required String code,
    required String message,
  }) {
    return GeometryResponse(
      requestId: 'invalid_request',
      status: GeometryResponseStatus.error,
      backend: 'worker_protocol',
      issues: [
        GeometryIssue(
          severity: GeometryIssueSeverity.error,
          code: code,
          message: message,
        ),
      ],
    );
  }
}
