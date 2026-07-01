class PreviewMeshEdgeKey {
  const PreviewMeshEdgeKey(int first, int second)
    : start = first < second ? first : second,
      end = first < second ? second : first;

  final int start;
  final int end;

  @override
  bool operator ==(Object other) {
    return other is PreviewMeshEdgeKey &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'PreviewMeshEdgeKey($start, $end)';
}

Set<PreviewMeshEdgeKey> previewMeshBoundaryEdges({
  required List<int> triangles,
  required int vertexCount,
  Iterable<int>? triangleIndices,
}) {
  final maxTriangleCount = triangles.length ~/ 3;
  final source = triangleIndices ?? Iterable<int>.generate(maxTriangleCount);
  final edgeCounts = <PreviewMeshEdgeKey, int>{};

  for (final triangleIndex in source) {
    if (triangleIndex < 0 || triangleIndex >= maxTriangleCount) {
      continue;
    }

    final base = triangleIndex * 3;
    final a = triangles[base];
    final b = triangles[base + 1];
    final c = triangles[base + 2];
    if (!_validPreviewMeshIndex(a, vertexCount) ||
        !_validPreviewMeshIndex(b, vertexCount) ||
        !_validPreviewMeshIndex(c, vertexCount)) {
      continue;
    }

    _incrementEdge(edgeCounts, a, b);
    _incrementEdge(edgeCounts, b, c);
    _incrementEdge(edgeCounts, c, a);
  }

  return {
    for (final entry in edgeCounts.entries)
      if (entry.value == 1) entry.key,
  };
}

void _incrementEdge(
  Map<PreviewMeshEdgeKey, int> counts,
  int first,
  int second,
) {
  final key = PreviewMeshEdgeKey(first, second);
  counts[key] = (counts[key] ?? 0) + 1;
}

bool _validPreviewMeshIndex(int index, int vertexCount) {
  return index >= 0 && index < vertexCount;
}
