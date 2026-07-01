import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/viewport/preview_mesh_edges.dart';

void main() {
  test('previewMeshBoundaryEdges omits shared internal triangle edges', () {
    final edges = previewMeshBoundaryEdges(
      triangles: const [0, 1, 2, 0, 2, 3],
      vertexCount: 4,
    );

    expect(edges, hasLength(4));
    expect(edges, contains(const PreviewMeshEdgeKey(0, 1)));
    expect(edges, contains(const PreviewMeshEdgeKey(1, 2)));
    expect(edges, contains(const PreviewMeshEdgeKey(2, 3)));
    expect(edges, contains(const PreviewMeshEdgeKey(0, 3)));
    expect(edges, isNot(contains(const PreviewMeshEdgeKey(0, 2))));
  });

  test('previewMeshBoundaryEdges can isolate a selected triangle contour', () {
    final triangles = const [0, 1, 2, 0, 2, 3];

    final singleTriangleEdges = previewMeshBoundaryEdges(
      triangles: triangles,
      vertexCount: 4,
      triangleIndices: const [0],
    );
    final selectedSurfaceEdges = previewMeshBoundaryEdges(
      triangles: triangles,
      vertexCount: 4,
      triangleIndices: const [0, 1],
    );

    expect(singleTriangleEdges, contains(const PreviewMeshEdgeKey(0, 2)));
    expect(
      selectedSurfaceEdges,
      isNot(contains(const PreviewMeshEdgeKey(0, 2))),
    );
  });

  test('previewMeshBoundaryEdges skips invalid triangles', () {
    final edges = previewMeshBoundaryEdges(
      triangles: const [0, 1, 5, 0, 2, 3],
      vertexCount: 4,
      triangleIndices: const [-1, 0, 1, 99],
    );

    expect(edges, {
      const PreviewMeshEdgeKey(0, 2),
      const PreviewMeshEdgeKey(2, 3),
      const PreviewMeshEdgeKey(0, 3),
    });
  });
}
