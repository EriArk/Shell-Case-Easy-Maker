Map<String, Object?> readJsonMap(Object? rawValue) {
  if (rawValue is! Map<Object?, Object?>) {
    return const {};
  }

  return rawValue.map(
    (key, value) => MapEntry(key.toString(), normalizeJsonValue(value)),
  );
}

List<Map<String, Object?>> readJsonMapList(Object? rawValue) {
  if (rawValue is! List<Object?>) {
    return const [];
  }

  return rawValue
      .whereType<Map<Object?, Object?>>()
      .map(readJsonMap)
      .toList(growable: false);
}

List<T> readObjectList<T>(
  Object? rawValue,
  T Function(Map<String, Object?> json) fromJson,
) {
  return readJsonMapList(rawValue).map(fromJson).toList(growable: false);
}

String readString(Object? rawValue, {required String fallback}) {
  if (rawValue is String && rawValue.trim().isNotEmpty) {
    return rawValue;
  }

  return fallback;
}

int readInt(Object? rawValue, {required int fallback}) {
  if (rawValue is num) {
    return rawValue.toInt();
  }

  return fallback;
}

double readDouble(Object? rawValue, {required double fallback}) {
  if (rawValue is num) {
    return rawValue.toDouble();
  }

  return fallback;
}

bool readBool(Object? rawValue, {required bool fallback}) {
  if (rawValue is bool) {
    return rawValue;
  }

  return fallback;
}

List<double> readDoubleList(
  Object? rawValue, {
  required List<double> fallback,
}) {
  if (rawValue is! List<Object?>) {
    return fallback;
  }

  final values = rawValue.whereType<num>().map((value) => value.toDouble());
  final result = values.toList(growable: false);
  return result.isEmpty ? fallback : result;
}

Object? normalizeJsonValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }

  if (value is Map<Object?, Object?>) {
    return readJsonMap(value);
  }

  if (value is List<Object?>) {
    return value.map(normalizeJsonValue).toList(growable: false);
  }

  return value.toString();
}

Map<String, Object?> withoutKeys(
  Map<String, Object?> source,
  Set<String> keys,
) {
  return Map.fromEntries(
    source.entries.where((entry) => !keys.contains(entry.key)),
  );
}
