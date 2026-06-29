#include <BRepBndLib.hxx>
#include <BRepFilletAPI_MakeFillet.hxx>
#include <BRepGProp.hxx>
#include <BRepMesh_IncrementalMesh.hxx>
#include <BRepPrimAPI_MakeBox.hxx>
#include <BRep_Tool.hxx>
#include <Bnd_Box.hxx>
#include <GProp_GProps.hxx>
#include <Poly_Triangle.hxx>
#include <Poly_Triangulation.hxx>
#include <TopAbs_Orientation.hxx>
#include <Standard_Version.hxx>
#include <TopAbs_ShapeEnum.hxx>
#include <TopExp_Explorer.hxx>
#include <TopLoc_Location.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Edge.hxx>
#include <TopoDS_Face.hxx>
#include <TopoDS_Shape.hxx>
#include <gp_Pnt.hxx>

#include <algorithm>
#include <array>
#include <cmath>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

#ifndef OCC_VERSION_COMPLETE
#define OCC_VERSION_COMPLETE "unknown"
#endif

namespace {

constexpr const char* kRequestSchema = "shell_case.geometry.request";
constexpr const char* kResponseSchema = "shell_case.geometry.response";
constexpr const char* kBackend = "occt_worker_native_occt";
constexpr const char* kInvalidRequestId = "invalid_request";
constexpr double kPreviewLinearDeflection = 0.3;
constexpr double kPreviewAngularDeflection = 0.35;

struct NativeRequestEnvelope {
  std::string request_id = kInvalidRequestId;
  std::string schema;
  std::string operation;
};

struct EnclosureRequest {
  std::string id;
  std::string shape;
  std::array<double, 3> size = {0.0, 0.0, 0.0};
  double wall_thickness = 0.0;
  double corner_radius = 0.0;
};

struct NativeRequestParseResult {
  NativeRequestEnvelope request;
  EnclosureRequest enclosure;
  std::string issue_code;
  std::string issue_message;

  bool ok() const { return issue_code.empty(); }
};

struct ShapeMetrics {
  std::array<double, 3> bounds_min = {0.0, 0.0, 0.0};
  std::array<double, 3> bounds_max = {0.0, 0.0, 0.0};
  std::array<double, 3> dimensions = {0.0, 0.0, 0.0};
  double surface_area = 0.0;
  double volume = 0.0;
  bool corner_radius_applied = false;
  int filleted_edge_count = 0;
};

struct PreviewMeshData {
  std::vector<double> vertices;
  std::vector<int> triangles;
  int face_count = 0;
  int skipped_face_count = 0;
  int mesher_status = 0;

  int vertex_count() const { return static_cast<int>(vertices.size() / 3); }
  int triangle_count() const { return static_cast<int>(triangles.size() / 3); }
};

std::string ReadStdin() {
  return std::string{std::istreambuf_iterator<char>{std::cin},
                     std::istreambuf_iterator<char>{}};
}

std::string EscapeJsonString(const std::string& value) {
  std::string escaped;
  escaped.reserve(value.size());

  for (const char character : value) {
    switch (character) {
      case '\\':
        escaped += "\\\\";
        break;
      case '"':
        escaped += "\\\"";
        break;
      case '\n':
        escaped += "\\n";
        break;
      case '\r':
        escaped += "\\r";
        break;
      case '\t':
        escaped += "\\t";
        break;
      default:
        escaped += character;
        break;
    }
  }

  return escaped;
}

std::string FormatDouble(double value) {
  if (std::abs(value) < 0.0000005) {
    value = 0.0;
  }

  std::ostringstream stream;
  stream << std::fixed << std::setprecision(6) << value;
  std::string formatted = stream.str();
  while (formatted.size() > 1 && formatted.back() == '0') {
    formatted.pop_back();
  }
  if (!formatted.empty() && formatted.back() == '.') {
    formatted.pop_back();
  }
  return formatted;
}

void WriteDoubleArray(const std::array<double, 3>& values) {
  std::cout << "[" << FormatDouble(values[0]) << ", " << FormatDouble(values[1])
            << ", " << FormatDouble(values[2]) << "]";
}

void WriteDoubleVector(const std::vector<double>& values) {
  std::cout << "[";
  for (std::size_t index = 0; index < values.size(); ++index) {
    if (index > 0) {
      std::cout << ", ";
    }
    std::cout << FormatDouble(values[index]);
  }
  std::cout << "]";
}

void WriteIntVector(const std::vector<int>& values) {
  std::cout << "[";
  for (std::size_t index = 0; index < values.size(); ++index) {
    if (index > 0) {
      std::cout << ", ";
    }
    std::cout << values[index];
  }
  std::cout << "]";
}

bool IsJsonWhitespace(char character) {
  return character == ' ' || character == '\n' || character == '\r' ||
         character == '\t';
}

bool IsUtf8BomAt(const std::string& text, std::size_t index) {
  return index + 2 < text.size() &&
         static_cast<unsigned char>(text[index]) == 0xef &&
         static_cast<unsigned char>(text[index + 1]) == 0xbb &&
         static_cast<unsigned char>(text[index + 2]) == 0xbf;
}

bool IsHexDigit(char character) {
  return (character >= '0' && character <= '9') ||
         (character >= 'a' && character <= 'f') ||
         (character >= 'A' && character <= 'F');
}

int HexDigitValue(char character) {
  if (character >= '0' && character <= '9') {
    return character - '0';
  }
  if (character >= 'a' && character <= 'f') {
    return 10 + character - 'a';
  }
  return 10 + character - 'A';
}

std::size_t SkipWhitespace(const std::string& text, std::size_t index) {
  while (index < text.size()) {
    if (IsJsonWhitespace(text[index])) {
      ++index;
      continue;
    }
    if (IsUtf8BomAt(text, index)) {
      index += 3;
      continue;
    }
    break;
  }
  return index;
}

bool ParseJsonStringAt(const std::string& text,
                       std::size_t quote_index,
                       std::string* value,
                       std::size_t* next_index) {
  if (quote_index >= text.size() || text[quote_index] != '"') {
    return false;
  }

  std::string parsed;
  for (std::size_t index = quote_index + 1; index < text.size(); ++index) {
    const char character = text[index];
    if (character == '"') {
      *value = parsed;
      *next_index = index + 1;
      return true;
    }

    if (character != '\\') {
      parsed += character;
      continue;
    }

    ++index;
    if (index >= text.size()) {
      return false;
    }

    const char escaped = text[index];
    switch (escaped) {
      case '"':
      case '\\':
      case '/':
        parsed += escaped;
        break;
      case 'b':
        parsed += '\b';
        break;
      case 'f':
        parsed += '\f';
        break;
      case 'n':
        parsed += '\n';
        break;
      case 'r':
        parsed += '\r';
        break;
      case 't':
        parsed += '\t';
        break;
      case 'u': {
        if (index + 4 >= text.size()) {
          return false;
        }

        int code_point = 0;
        for (std::size_t offset = 1; offset <= 4; ++offset) {
          const char hex = text[index + offset];
          if (!IsHexDigit(hex)) {
            return false;
          }
          code_point = (code_point * 16) + HexDigitValue(hex);
        }
        parsed += code_point <= 0x7f ? static_cast<char>(code_point) : '?';
        index += 4;
        break;
      }
      default:
        return false;
    }
  }

  return false;
}

bool ParseJsonNumberAt(const std::string& text,
                       std::size_t value_index,
                       double* value,
                       std::size_t* next_index) {
  std::size_t index = SkipWhitespace(text, value_index);
  const std::size_t start = index;

  if (index < text.size() && text[index] == '-') {
    ++index;
  }

  bool has_digit = false;
  while (index < text.size() && text[index] >= '0' && text[index] <= '9') {
    has_digit = true;
    ++index;
  }

  if (index < text.size() && text[index] == '.') {
    ++index;
    while (index < text.size() && text[index] >= '0' && text[index] <= '9') {
      has_digit = true;
      ++index;
    }
  }

  if (!has_digit) {
    return false;
  }

  if (index < text.size() && (text[index] == 'e' || text[index] == 'E')) {
    ++index;
    if (index < text.size() && (text[index] == '+' || text[index] == '-')) {
      ++index;
    }

    bool has_exponent_digit = false;
    while (index < text.size() && text[index] >= '0' && text[index] <= '9') {
      has_exponent_digit = true;
      ++index;
    }
    if (!has_exponent_digit) {
      return false;
    }
  }

  try {
    *value = std::stod(text.substr(start, index - start));
  } catch (const std::exception&) {
    return false;
  }
  *next_index = index;
  return true;
}

std::optional<std::size_t> FindMatchingJsonDelimiter(const std::string& text,
                                                     std::size_t open_index) {
  if (open_index >= text.size()) {
    return std::nullopt;
  }

  const char open = text[open_index];
  const char close = open == '{' ? '}' : open == '[' ? ']' : '\0';
  if (close == '\0') {
    return std::nullopt;
  }

  int depth = 0;
  for (std::size_t index = open_index; index < text.size();) {
    if (text[index] == '"') {
      std::string ignored;
      std::size_t next_index = 0;
      if (!ParseJsonStringAt(text, index, &ignored, &next_index)) {
        return std::nullopt;
      }
      index = next_index;
      continue;
    }

    if (text[index] == open) {
      ++depth;
    } else if (text[index] == close) {
      --depth;
      if (depth == 0) {
        return index;
      }
    }

    ++index;
  }

  return std::nullopt;
}

std::optional<std::size_t> FindTopLevelFieldValueIndex(
    const std::string& json,
    std::string_view field_name) {
  int object_depth = 0;
  int array_depth = 0;

  for (std::size_t index = 0; index < json.size();) {
    const char character = json[index];
    if (character == '"') {
      std::string token;
      std::size_t next_index = 0;
      if (!ParseJsonStringAt(json, index, &token, &next_index)) {
        return std::nullopt;
      }

      if (object_depth == 1 && array_depth == 0) {
        const std::size_t colon_index = SkipWhitespace(json, next_index);
        if (colon_index < json.size() && json[colon_index] == ':') {
          const std::size_t value_index = SkipWhitespace(json, colon_index + 1);
          if (token == field_name) {
            return value_index;
          }
        }
      }

      index = next_index;
      continue;
    }

    switch (character) {
      case '{':
        ++object_depth;
        break;
      case '}':
        --object_depth;
        if (object_depth < 0) {
          return std::nullopt;
        }
        break;
      case '[':
        ++array_depth;
        break;
      case ']':
        --array_depth;
        if (array_depth < 0) {
          return std::nullopt;
        }
        break;
      default:
        break;
    }

    ++index;
  }

  return std::nullopt;
}

std::optional<std::string> ExtractTopLevelStringField(
    const std::string& json,
    std::string_view field_name) {
  const std::optional<std::size_t> value_index =
      FindTopLevelFieldValueIndex(json, field_name);
  if (!value_index.has_value() || *value_index >= json.size() ||
      json[*value_index] != '"') {
    return std::nullopt;
  }

  std::string value;
  std::size_t next_index = 0;
  if (!ParseJsonStringAt(json, *value_index, &value, &next_index)) {
    return std::nullopt;
  }
  return value;
}

std::optional<std::string> ExtractTopLevelObjectField(
    const std::string& json,
    std::string_view field_name) {
  const std::optional<std::size_t> value_index =
      FindTopLevelFieldValueIndex(json, field_name);
  if (!value_index.has_value() || *value_index >= json.size() ||
      json[*value_index] != '{') {
    return std::nullopt;
  }

  const std::optional<std::size_t> close_index =
      FindMatchingJsonDelimiter(json, *value_index);
  if (!close_index.has_value()) {
    return std::nullopt;
  }
  return json.substr(*value_index, *close_index - *value_index + 1);
}

std::optional<double> ExtractTopLevelNumberField(
    const std::string& json,
    std::string_view field_name) {
  const std::optional<std::size_t> value_index =
      FindTopLevelFieldValueIndex(json, field_name);
  if (!value_index.has_value()) {
    return std::nullopt;
  }

  double value = 0.0;
  std::size_t next_index = 0;
  if (!ParseJsonNumberAt(json, *value_index, &value, &next_index)) {
    return std::nullopt;
  }
  return value;
}

std::optional<std::array<double, 3>> ExtractTopLevelNumberArray3Field(
    const std::string& json,
    std::string_view field_name) {
  const std::optional<std::size_t> value_index =
      FindTopLevelFieldValueIndex(json, field_name);
  if (!value_index.has_value() || *value_index >= json.size() ||
      json[*value_index] != '[') {
    return std::nullopt;
  }

  std::array<double, 3> values = {0.0, 0.0, 0.0};
  std::size_t index = SkipWhitespace(json, *value_index + 1);
  for (std::size_t item_index = 0; item_index < values.size(); ++item_index) {
    std::size_t next_index = 0;
    if (!ParseJsonNumberAt(json, index, &values[item_index], &next_index)) {
      return std::nullopt;
    }
    index = SkipWhitespace(json, next_index);

    if (item_index + 1 < values.size()) {
      if (index >= json.size() || json[index] != ',') {
        return std::nullopt;
      }
      index = SkipWhitespace(json, index + 1);
    }
  }

  if (index >= json.size() || json[index] != ']') {
    return std::nullopt;
  }
  return values;
}

std::vector<std::string> ExtractTopLevelObjectArrayField(
    const std::string& json,
    std::string_view field_name) {
  std::vector<std::string> objects;
  const std::optional<std::size_t> value_index =
      FindTopLevelFieldValueIndex(json, field_name);
  if (!value_index.has_value() || *value_index >= json.size() ||
      json[*value_index] != '[') {
    return objects;
  }

  const std::optional<std::size_t> close_array =
      FindMatchingJsonDelimiter(json, *value_index);
  if (!close_array.has_value()) {
    return objects;
  }

  for (std::size_t index = *value_index + 1; index < *close_array;) {
    index = SkipWhitespace(json, index);
    if (index >= *close_array) {
      break;
    }

    if (json[index] != '{') {
      ++index;
      continue;
    }

    const std::optional<std::size_t> close_object =
        FindMatchingJsonDelimiter(json, index);
    if (!close_object.has_value() || *close_object > *close_array) {
      return {};
    }
    objects.push_back(json.substr(index, *close_object - index + 1));
    index = *close_object + 1;
  }

  return objects;
}

bool IsRecognizedOperation(const std::string& operation) {
  return operation == "preview_mesh" || operation == "export_step" ||
         operation == "export_stl" || operation == "validate";
}

bool IsPositiveDimension(double value) {
  return std::isfinite(value) && value > 0.0;
}

NativeRequestParseResult ReadNativeRequest(const std::string& payload) {
  NativeRequestParseResult result;
  const std::optional<std::string> request_id =
      ExtractTopLevelStringField(payload, "requestId");
  if (request_id.has_value() && !request_id->empty()) {
    result.request.request_id = *request_id;
  }

  const std::size_t first_token = SkipWhitespace(payload, 0);
  if (first_token == payload.size()) {
    result.issue_code = "worker.request.empty";
    result.issue_message = "Native OCCT worker request payload is empty.";
    return result;
  }

  if (payload[first_token] != '{') {
    result.issue_code = "worker.request.invalid_json";
    result.issue_message =
        "Native OCCT worker request payload must be a JSON object.";
    return result;
  }

  const std::optional<std::string> schema =
      ExtractTopLevelStringField(payload, "schema");
  if (!schema.has_value() || *schema != kRequestSchema) {
    result.issue_code = "worker.request.invalid_schema";
    result.issue_message =
        "Native OCCT worker request schema must be shell_case.geometry.request.";
    return result;
  }
  result.request.schema = *schema;

  const std::optional<std::string> operation =
      ExtractTopLevelStringField(payload, "operation");
  if (!operation.has_value() || !IsRecognizedOperation(*operation)) {
    result.issue_code = "worker.request.invalid_operation";
    result.issue_message =
        "Native OCCT worker request operation must be preview_mesh, "
        "export_step, export_stl, or validate.";
    return result;
  }
  result.request.operation = *operation;

  if (*operation != "preview_mesh") {
    result.issue_code = "worker.backend.occt_operation_not_implemented";
    result.issue_message =
        "The native OCCT worker currently implements only preview_mesh "
        "generation for the first enclosure body.";
    return result;
  }

  const std::optional<std::string> project =
      ExtractTopLevelObjectField(payload, "project");
  if (!project.has_value()) {
    result.issue_code = "worker.request.invalid_project";
    result.issue_message = "Native OCCT worker request must contain a project.";
    return result;
  }

  const std::vector<std::string> bodies =
      ExtractTopLevelObjectArrayField(*project, "bodies");
  for (const std::string& body : bodies) {
    const std::optional<std::string> type =
        ExtractTopLevelStringField(body, "type");
    if (!type.has_value() || *type != "enclosure") {
      continue;
    }

    result.enclosure.id = ExtractTopLevelStringField(body, "id").value_or("");
    result.enclosure.shape =
        ExtractTopLevelStringField(body, "shape").value_or("");
    const std::optional<std::array<double, 3>> size =
        ExtractTopLevelNumberArray3Field(body, "size");
    const std::optional<double> wall_thickness =
        ExtractTopLevelNumberField(body, "wallThickness");
    const std::optional<double> corner_radius =
        ExtractTopLevelNumberField(body, "cornerRadius");

    if (result.enclosure.id.empty() || result.enclosure.shape.empty() ||
        !size.has_value() || !wall_thickness.has_value() ||
        !corner_radius.has_value()) {
      result.issue_code = "worker.request.invalid_enclosure";
      result.issue_message =
          "Native OCCT worker enclosure body is missing id, shape, size, "
          "wallThickness, or cornerRadius.";
      return result;
    }

    result.enclosure.size = *size;
    result.enclosure.wall_thickness = *wall_thickness;
    result.enclosure.corner_radius = *corner_radius;
    if (result.enclosure.shape != "rounded_box") {
      result.issue_code = "worker.geometry.unsupported_enclosure_shape";
      result.issue_message =
          "Native OCCT worker currently supports only rounded_box enclosures.";
      return result;
    }

    const double min_size =
        std::min({result.enclosure.size[0], result.enclosure.size[1],
                  result.enclosure.size[2]});
    if (!IsPositiveDimension(result.enclosure.size[0]) ||
        !IsPositiveDimension(result.enclosure.size[1]) ||
        !IsPositiveDimension(result.enclosure.size[2]) ||
        !std::isfinite(result.enclosure.wall_thickness) ||
        result.enclosure.wall_thickness <= 0.0 ||
        !std::isfinite(result.enclosure.corner_radius) ||
        result.enclosure.corner_radius < 0.0 ||
        result.enclosure.corner_radius >= min_size / 2.0) {
      result.issue_code = "worker.geometry.invalid_enclosure_dimensions";
      result.issue_message =
          "Native OCCT worker enclosure dimensions, wall thickness, and corner "
          "radius must be positive and physically valid.";
      return result;
    }

    return result;
  }

  result.issue_code = "worker.request.enclosure_missing";
  result.issue_message =
      "Native OCCT worker request project must contain an enclosure body.";
  return result;
}

TopoDS_Shape BuildRoundedEnclosureShape(const EnclosureRequest& enclosure,
                                        bool* corner_radius_applied,
                                        int* filleted_edge_count) {
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(gp_Pnt(-enclosure.size[0] / 2.0,
                                 -enclosure.size[1] / 2.0,
                                 0.0),
                          enclosure.size[0],
                          enclosure.size[1],
                          enclosure.size[2])
          .Shape();

  *corner_radius_applied = false;
  *filleted_edge_count = 0;
  if (enclosure.corner_radius <= 0.0) {
    return box;
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    fillet.Add(enclosure.corner_radius, TopoDS::Edge(explorer.Current()));
    ++(*filleted_edge_count);
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error("OCCT fillet build did not complete.");
  }

  *corner_radius_applied = true;
  return fillet.Shape();
}

ShapeMetrics ComputeShapeMetrics(const TopoDS_Shape& shape,
                                 bool corner_radius_applied,
                                 int filleted_edge_count) {
  ShapeMetrics metrics;
  metrics.corner_radius_applied = corner_radius_applied;
  metrics.filleted_edge_count = filleted_edge_count;

  Bnd_Box bounds;
  BRepBndLib::AddOptimal(shape, bounds, false, false);
  bounds.Get(metrics.bounds_min[0],
             metrics.bounds_min[1],
             metrics.bounds_min[2],
             metrics.bounds_max[0],
             metrics.bounds_max[1],
             metrics.bounds_max[2]);
  metrics.dimensions = {metrics.bounds_max[0] - metrics.bounds_min[0],
                        metrics.bounds_max[1] - metrics.bounds_min[1],
                        metrics.bounds_max[2] - metrics.bounds_min[2]};

  GProp_GProps surface_properties;
  BRepGProp::SurfaceProperties(shape, surface_properties, false, false);
  metrics.surface_area = surface_properties.Mass();

  GProp_GProps volume_properties;
  BRepGProp::VolumeProperties(shape, volume_properties, false, false, false);
  metrics.volume = volume_properties.Mass();

  return metrics;
}

PreviewMeshData BuildPreviewMesh(const TopoDS_Shape& shape) {
  PreviewMeshData mesh;
  BRepMesh_IncrementalMesh mesher(shape,
                                  kPreviewLinearDeflection,
                                  false,
                                  kPreviewAngularDeflection,
                                  false);
  mesh.mesher_status = mesher.GetStatusFlags();

  for (TopExp_Explorer explorer(shape, TopAbs_FACE); explorer.More();
       explorer.Next()) {
    ++mesh.face_count;
    const TopoDS_Face face = TopoDS::Face(explorer.Current());
    TopLoc_Location location;
    const auto triangulation = BRep_Tool::Triangulation(face, location);
    if (triangulation.IsNull() || !triangulation->HasGeometry()) {
      ++mesh.skipped_face_count;
      continue;
    }

    const int vertex_offset = mesh.vertex_count();
    for (int node_index = 1; node_index <= triangulation->NbNodes();
         ++node_index) {
      const gp_Pnt point =
          triangulation->Node(node_index).Transformed(location.Transformation());
      mesh.vertices.push_back(point.X());
      mesh.vertices.push_back(point.Y());
      mesh.vertices.push_back(point.Z());
    }

    for (int triangle_index = 1;
         triangle_index <= triangulation->NbTriangles();
         ++triangle_index) {
      int node_1 = 0;
      int node_2 = 0;
      int node_3 = 0;
      triangulation->Triangle(triangle_index).Get(node_1, node_2, node_3);

      if (node_1 < 1 || node_2 < 1 || node_3 < 1 ||
          node_1 > triangulation->NbNodes() ||
          node_2 > triangulation->NbNodes() ||
          node_3 > triangulation->NbNodes()) {
        throw std::runtime_error("OCCT generated an invalid triangle index.");
      }

      if (face.Orientation() == TopAbs_REVERSED) {
        mesh.triangles.push_back(vertex_offset + node_1 - 1);
        mesh.triangles.push_back(vertex_offset + node_3 - 1);
        mesh.triangles.push_back(vertex_offset + node_2 - 1);
      } else {
        mesh.triangles.push_back(vertex_offset + node_1 - 1);
        mesh.triangles.push_back(vertex_offset + node_2 - 1);
        mesh.triangles.push_back(vertex_offset + node_3 - 1);
      }
    }
  }

  if (mesh.triangles.empty()) {
    throw std::runtime_error("OCCT preview meshing produced no triangles.");
  }

  return mesh;
}

TopoDS_Shape BuildNativeHealthShape() {
  return BRepPrimAPI_MakeBox(10.0, 20.0, 30.0).Shape();
}

void WriteCapabilities() {
  std::cout
      << "{\n"
      << "  \"schema\": \"shell_case.geometry.worker.capabilities\",\n"
      << "  \"version\": 1,\n"
      << "  \"entrypoint\": \"occt_worker/native/occt_worker_native_occt\",\n"
      << "  \"defaultBackend\": \"native\",\n"
      << "  \"activeBackend\": \"native\",\n"
      << "  \"protocol\": {\n"
      << "    \"requestSchema\": \"shell_case.geometry.request\",\n"
      << "    \"responseSchema\": \"shell_case.geometry.response\",\n"
      << "    \"version\": 1\n"
      << "  },\n"
      << "  \"sourceOfTruth\": \"semantic_project\",\n"
      << "  \"editableGeneratedGeometry\": false,\n"
      << "  \"backends\": [\n"
      << "    {\n"
      << "      \"id\": \"native\",\n"
      << "      \"status\": \"preview_mesh_smoke\",\n"
      << "      \"supportedOperations\": [\n"
      << "        \"preview_mesh\"\n"
      << "      ],\n"
      << "      \"plannedOperations\": [\n"
      << "        \"preview_mesh\",\n"
      << "        \"export_step\",\n"
      << "        \"export_stl\",\n"
      << "        \"validate\"\n"
      << "      ],\n"
      << "      \"issueCodes\": [\n"
      << "        \"worker.request.empty\",\n"
      << "        \"worker.request.invalid_json\",\n"
      << "        \"worker.request.invalid_schema\",\n"
      << "        \"worker.request.invalid_operation\",\n"
      << "        \"worker.request.invalid_project\",\n"
      << "        \"worker.request.invalid_enclosure\",\n"
      << "        \"worker.request.enclosure_missing\",\n"
      << "        \"worker.geometry.invalid_enclosure_dimensions\",\n"
      << "        \"worker.geometry.unsupported_enclosure_shape\",\n"
      << "        \"worker.geometry.occt_exception\",\n"
      << "        \"worker.backend.occt_operation_not_implemented\"\n"
      << "      ],\n"
      << "      \"notes\": [\n"
      << "        \"OCCT-linked native target is available.\",\n"
      << "        \"preview_mesh returns a disposable triangulated preview mesh plus deterministic rounded enclosure metrics.\"\n"
      << "      ]\n"
      << "    }\n"
      << "  ],\n"
      << "  \"metrics\": {\n"
      << "    \"occtVersion\": \"" << EscapeJsonString(OCC_VERSION_COMPLETE)
      << "\"\n"
      << "  }\n"
      << "}\n";
}

void WriteIssueResponse(const std::string& request_id,
                        const std::string& issue_code,
                        const std::string& issue_message,
                        const std::string& requested_operation,
                        bool native_health_shape_null) {
  const std::string safe_request_id =
      request_id.empty() ? kInvalidRequestId : request_id;

  std::cout << "{\n"
            << "  \"schema\": \"" << kResponseSchema << "\",\n"
            << "  \"version\": 1,\n"
            << "  \"requestId\": \"" << EscapeJsonString(safe_request_id)
            << "\",\n"
            << "  \"status\": \"error\",\n"
            << "  \"backend\": \"" << kBackend << "\",\n"
            << "  \"issues\": [\n"
            << "    {\n"
            << "      \"severity\": \"error\",\n"
            << "      \"code\": \"" << EscapeJsonString(issue_code)
            << "\",\n"
            << "      \"message\": \"" << EscapeJsonString(issue_message)
            << "\"\n"
            << "    }\n"
            << "  ],\n"
            << "  \"metrics\": {\n"
            << "    \"requestedBackend\": \"native\",\n"
            << "    \"executable\": \"occt_worker_native_occt\",\n"
            << "    \"occtVersion\": \""
            << EscapeJsonString(OCC_VERSION_COMPLETE) << "\",\n"
            << "    \"nativeHealthShapeNull\": "
            << (native_health_shape_null ? "true" : "false");

  if (!requested_operation.empty()) {
    std::cout << ",\n"
              << "    \"requestedOperation\": \""
              << EscapeJsonString(requested_operation) << "\"";
  }

  std::cout << "\n"
            << "  }\n"
            << "}\n";
}

void WritePreviewMesh(const PreviewMeshData& mesh,
                      const ShapeMetrics& metrics) {
  std::cout << "  \"previewMesh\": {\n"
            << "    \"units\": \"mm\",\n"
            << "    \"vertices\": ";
  WriteDoubleVector(mesh.vertices);
  std::cout << ",\n"
            << "    \"triangles\": ";
  WriteIntVector(mesh.triangles);
  std::cout << ",\n"
            << "    \"bounds\": {\n"
            << "      \"min\": ";
  WriteDoubleArray(metrics.bounds_min);
  std::cout << ",\n"
            << "      \"max\": ";
  WriteDoubleArray(metrics.bounds_max);
  std::cout << "\n"
            << "    },\n"
            << "    \"surfaces\": [],\n"
            << "    \"source\": \"occt_brep\",\n"
            << "    \"surfaceMapping\": \"pending_semantic_face_mapping\",\n"
            << "    \"linearDeflection\": "
            << FormatDouble(kPreviewLinearDeflection) << ",\n"
            << "    \"angularDeflection\": "
            << FormatDouble(kPreviewAngularDeflection) << "\n"
            << "  }";
}

void WriteRoundedEnclosurePreviewResponse(const NativeRequestEnvelope& request,
                                          const EnclosureRequest& enclosure,
                                          const ShapeMetrics& metrics,
                                          const PreviewMeshData& mesh) {
  std::cout << "{\n"
            << "  \"schema\": \"" << kResponseSchema << "\",\n"
            << "  \"version\": 1,\n"
            << "  \"requestId\": \"" << EscapeJsonString(request.request_id)
            << "\",\n"
            << "  \"status\": \"ok\",\n"
            << "  \"backend\": \"" << kBackend << "\",\n"
            << "  \"issues\": [],\n"
            << "  \"metrics\": {\n"
            << "    \"requestedBackend\": \"native\",\n"
            << "    \"executable\": \"occt_worker_native_occt\",\n"
            << "    \"requestedOperation\": \""
            << EscapeJsonString(request.operation) << "\",\n"
            << "    \"occtVersion\": \""
            << EscapeJsonString(OCC_VERSION_COMPLETE) << "\",\n"
            << "    \"generator\": \"occt.rounded_enclosure.preview_mesh.v1\",\n"
            << "    \"bodyId\": \"" << EscapeJsonString(enclosure.id)
            << "\",\n"
            << "    \"shape\": \"" << EscapeJsonString(enclosure.shape)
            << "\",\n"
            << "    \"inputSize\": ";
  WriteDoubleArray(enclosure.size);
  std::cout << ",\n"
            << "    \"wallThickness\": "
            << FormatDouble(enclosure.wall_thickness) << ",\n"
            << "    \"cornerRadius\": "
            << FormatDouble(enclosure.corner_radius) << ",\n"
            << "    \"cornerRadiusApplied\": "
            << (metrics.corner_radius_applied ? "true" : "false") << ",\n"
            << "    \"filletedEdgeCount\": " << metrics.filleted_edge_count
            << ",\n"
            << "    \"bounds\": {\n"
            << "      \"min\": ";
  WriteDoubleArray(metrics.bounds_min);
  std::cout << ",\n"
            << "      \"max\": ";
  WriteDoubleArray(metrics.bounds_max);
  std::cout << "\n"
            << "    },\n"
            << "    \"dimensions\": ";
  WriteDoubleArray(metrics.dimensions);
  std::cout << ",\n"
            << "    \"surfaceArea\": " << FormatDouble(metrics.surface_area)
            << ",\n"
            << "    \"volume\": " << FormatDouble(metrics.volume) << ",\n"
            << "    \"previewMeshEmitted\": true,\n"
            << "    \"previewVertexCount\": " << mesh.vertex_count() << ",\n"
            << "    \"previewTriangleCount\": " << mesh.triangle_count()
            << ",\n"
            << "    \"previewFaceCount\": " << mesh.face_count << ",\n"
            << "    \"previewSkippedFaceCount\": " << mesh.skipped_face_count
            << ",\n"
            << "    \"mesherStatus\": " << mesh.mesher_status << ",\n"
            << "    \"linearDeflection\": "
            << FormatDouble(kPreviewLinearDeflection) << ",\n"
            << "    \"angularDeflection\": "
            << FormatDouble(kPreviewAngularDeflection) << ",\n"
            << "    \"editableGeneratedGeometry\": false\n"
            << "  },\n";
  WritePreviewMesh(mesh, metrics);
  std::cout << "\n"
            << "}\n";
}

void WriteInvalidArgumentResponse(const std::string& argument) {
  WriteIssueResponse(kInvalidRequestId,
                     "worker.cli.invalid_arguments",
                     "Unknown native OCCT worker argument: " + argument,
                     "",
                     false);
}

}  // namespace

int main(int argc, char* argv[]) {
  bool emit_capabilities = false;

  for (int index = 1; index < argc; ++index) {
    const std::string argument = argv[index];
    if (argument == "--capabilities") {
      emit_capabilities = true;
      continue;
    }

    WriteInvalidArgumentResponse(argument);
    return 2;
  }

  const TopoDS_Shape native_health_shape = BuildNativeHealthShape();
  const bool native_health_shape_null = native_health_shape.IsNull();

  if (emit_capabilities) {
    WriteCapabilities();
    return native_health_shape_null ? 2 : 0;
  }

  const NativeRequestParseResult parsed_request = ReadNativeRequest(ReadStdin());
  if (!parsed_request.ok()) {
    WriteIssueResponse(parsed_request.request.request_id,
                       parsed_request.issue_code,
                       parsed_request.issue_message,
                       parsed_request.request.operation,
                       native_health_shape_null);
    return 2;
  }

  try {
    bool corner_radius_applied = false;
    int filleted_edge_count = 0;
    const TopoDS_Shape shape =
        BuildRoundedEnclosureShape(parsed_request.enclosure,
                                   &corner_radius_applied,
                                   &filleted_edge_count);
    if (shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null enclosure shape.");
    }

    const ShapeMetrics metrics =
        ComputeShapeMetrics(shape, corner_radius_applied, filleted_edge_count);
    const PreviewMeshData mesh = BuildPreviewMesh(shape);
    WriteRoundedEnclosurePreviewResponse(
        parsed_request.request, parsed_request.enclosure, metrics, mesh);
    return 0;
  } catch (const std::exception& error) {
    WriteIssueResponse(parsed_request.request.request_id,
                       "worker.geometry.occt_exception",
                       error.what(),
                       parsed_request.request.operation,
                       native_health_shape_null);
    return 2;
  }
}
