#include <BRepBndLib.hxx>
#include <BRepAlgoAPI_Cut.hxx>
#include <BRepCheck_Analyzer.hxx>
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
#include <limits>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
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

struct UsbCCutoutRequest {
  std::string id;
  std::string target_surface;
  double width = 10.5;
  double height = 4.2;
  double corner_radius = 1.0;
  bool has_surface_position = false;
  std::array<double, 2> surface_position = {0.0, 0.0};
};

struct NativeRequestParseResult {
  NativeRequestEnvelope request;
  EnclosureRequest enclosure;
  std::vector<UsbCCutoutRequest> usb_c_cutouts;
  int feature_intent_count = 0;
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
  bool shell_cavity_applied = false;
  bool shell_cavity_valid = false;
  int shell_cavity_tool_count = 0;
  int feature_intent_count = 0;
  int native_feature_cut_count = 0;
  int native_ignored_feature_intent_count = 0;
  int native_usb_c_cutout_count = 0;
  int native_usb_c_cutout_filleted_edge_count = 0;
};

struct ShellBuildResult {
  TopoDS_Shape shape;
  bool cavity_applied = false;
  bool cavity_valid = false;
  int cavity_tool_count = 0;
};

struct NativeFeatureCutResult {
  TopoDS_Shape shape;
  int applied_cut_count = 0;
  int ignored_intent_count = 0;
  int usb_c_cutout_count = 0;
  int usb_c_filleted_edge_count = 0;
};

struct PreviewTriangleRangeData {
  int start = 0;
  int count = 0;
};

struct PreviewSurfaceMappingData {
  std::string semantic_id;
  std::string label;
  std::vector<PreviewTriangleRangeData> triangle_ranges;
};

struct PreviewMeshData {
  std::vector<double> vertices;
  std::vector<int> triangles;
  std::vector<PreviewSurfaceMappingData> surface_mappings;
  int face_count = 0;
  int skipped_face_count = 0;
  int mesher_status = 0;

  int vertex_count() const { return static_cast<int>(vertices.size() / 3); }
  int triangle_count() const { return static_cast<int>(triangles.size() / 3); }
};

struct FaceBounds {
  std::array<double, 3> min = {0.0, 0.0, 0.0};
  std::array<double, 3> max = {0.0, 0.0, 0.0};
};

FaceBounds ComputeTopoBounds(const TopoDS_Shape& shape) {
  Bnd_Box bounds;
  BRepBndLib::AddOptimal(shape, bounds, false, false);
  if (bounds.IsVoid()) {
    throw std::runtime_error("OCCT could not compute shape bounds.");
  }

  FaceBounds result;
  bounds.Get(result.min[0],
             result.min[1],
             result.min[2],
             result.max[0],
             result.max[1],
             result.max[2]);
  return result;
}

std::array<double, 3> DimensionsFromBounds(const FaceBounds& bounds) {
  return {bounds.max[0] - bounds.min[0],
          bounds.max[1] - bounds.min[1],
          bounds.max[2] - bounds.min[2]};
}

double PreviewSurfaceToleranceForDimensions(
    const std::array<double, 3>& dimensions) {
  const double max_dimension =
      std::max({dimensions[0], dimensions[1], dimensions[2]});
  return std::max(0.01, max_dimension * 0.0001) +
         kPreviewLinearDeflection * 2.0;
}

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

std::optional<std::array<double, 2>> ExtractTopLevelNumberArray2Field(
    const std::string& json,
    std::string_view field_name) {
  const std::optional<std::size_t> value_index =
      FindTopLevelFieldValueIndex(json, field_name);
  if (!value_index.has_value() || *value_index >= json.size() ||
      json[*value_index] != '[') {
    return std::nullopt;
  }

  std::array<double, 2> values = {0.0, 0.0};
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
  bool found_enclosure = false;
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
        result.enclosure.wall_thickness * 2.0 >=
            result.enclosure.size[0] ||
        result.enclosure.wall_thickness * 2.0 >=
            result.enclosure.size[1] ||
        result.enclosure.wall_thickness >= result.enclosure.size[2] ||
        !std::isfinite(result.enclosure.corner_radius) ||
        result.enclosure.corner_radius < 0.0 ||
        result.enclosure.corner_radius >= min_size / 2.0) {
      result.issue_code = "worker.geometry.invalid_enclosure_dimensions";
      result.issue_message =
        "Native OCCT worker enclosure dimensions, wall thickness, and corner "
          "radius must be positive and physically valid.";
      return result;
    }

    found_enclosure = true;
    break;
  }

  if (!found_enclosure) {
    result.issue_code = "worker.request.enclosure_missing";
    result.issue_message =
        "Native OCCT worker request project must contain an enclosure body.";
    return result;
  }

  const std::vector<std::string> feature_intents =
      ExtractTopLevelObjectArrayField(payload, "featureIntents");
  result.feature_intent_count =
      static_cast<int>(feature_intents.size());
  const std::string supported_front_surface =
      result.enclosure.id + ".front_wall.outer";
  for (const std::string& intent : feature_intents) {
    const std::string kind =
        ExtractTopLevelStringField(intent, "kind").value_or("");
    if (kind != "usb_c_cutout") {
      continue;
    }

    const std::string intent_operation =
        ExtractTopLevelStringField(intent, "operation").value_or("");
    if (intent_operation != "negative") {
      continue;
    }

    UsbCCutoutRequest cutout;
    cutout.id =
        ExtractTopLevelStringField(intent, "id").value_or("usb_c_cutout");
    cutout.target_surface =
        ExtractTopLevelStringField(intent, "targetSurface").value_or("");
    const std::optional<std::string> parameters =
        ExtractTopLevelObjectField(intent, "parameters");
    if (parameters.has_value()) {
      cutout.width =
          ExtractTopLevelNumberField(*parameters, "width").value_or(10.5);
      cutout.height =
          ExtractTopLevelNumberField(*parameters, "height").value_or(4.2);
      cutout.corner_radius =
          ExtractTopLevelNumberField(*parameters, "cornerRadius").value_or(1.0);
    }

    const std::optional<std::string> placement =
        ExtractTopLevelObjectField(intent, "placement");
    if (placement.has_value()) {
      const std::optional<std::array<double, 2>> surface_position =
          ExtractTopLevelNumberArray2Field(*placement, "surfacePosition");
      if (surface_position.has_value()) {
        cutout.surface_position = *surface_position;
        cutout.has_surface_position = true;
      }
    }

    if (cutout.target_surface != supported_front_surface) {
      continue;
    }

    const double available_width =
        result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
    const double available_height =
        result.enclosure.size[2] - result.enclosure.wall_thickness * 2.0;
    if (!IsPositiveDimension(cutout.width) ||
        !IsPositiveDimension(cutout.height) ||
        !std::isfinite(cutout.corner_radius) ||
        cutout.corner_radius < 0.0 ||
        cutout.corner_radius * 2.0 > std::min(cutout.width, cutout.height) ||
        cutout.width > available_width ||
        cutout.height > available_height) {
      result.issue_code = "worker.geometry.invalid_usb_c_cutout";
      result.issue_message =
          "Native OCCT worker USB-C cutout dimensions must fit the front wall.";
      return result;
    }

    result.usb_c_cutouts.push_back(cutout);
  }

  return result;
}

TopoDS_Shape BuildRoundedBoxShape(const gp_Pnt& origin,
                                  const std::array<double, 3>& size,
                                  double corner_radius,
                                  bool* corner_radius_applied,
                                  int* filleted_edge_count) {
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(origin, size[0], size[1], size[2]).Shape();

  *corner_radius_applied = false;
  *filleted_edge_count = 0;
  const double max_radius =
      std::min({size[0], size[1], size[2]}) / 2.0 - 0.001;
  const double safe_radius = std::min(corner_radius, max_radius);
  if (safe_radius <= 0.0) {
    return box;
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    fillet.Add(safe_radius, TopoDS::Edge(explorer.Current()));
    ++(*filleted_edge_count);
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error("OCCT fillet build did not complete.");
  }

  *corner_radius_applied = true;
  return fillet.Shape();
}

TopoDS_Shape BuildRoundedEnclosureShape(const EnclosureRequest& enclosure,
                                        bool* corner_radius_applied,
                                        int* filleted_edge_count) {
  return BuildRoundedBoxShape(gp_Pnt(-enclosure.size[0] / 2.0,
                                     -enclosure.size[1] / 2.0,
                                     0.0),
                              enclosure.size,
                              enclosure.corner_radius,
                              corner_radius_applied,
                              filleted_edge_count);
}

TopoDS_Shape BuildCavityCutTool(const EnclosureRequest& enclosure) {
  const std::array<double, 3> inner_size = {
      enclosure.size[0] - enclosure.wall_thickness * 2.0,
      enclosure.size[1] - enclosure.wall_thickness * 2.0,
      enclosure.size[2]};
  const gp_Pnt inner_origin(-inner_size[0] / 2.0,
                            -inner_size[1] / 2.0,
                            enclosure.wall_thickness);
  const double inner_radius =
      std::max(0.0, enclosure.corner_radius - enclosure.wall_thickness);
  bool inner_radius_applied = false;
  int inner_filleted_edge_count = 0;
  return BuildRoundedBoxShape(inner_origin,
                              inner_size,
                              inner_radius,
                              &inner_radius_applied,
                              &inner_filleted_edge_count);
}

ShapeMetrics ComputeShapeMetrics(const TopoDS_Shape& shape,
                                 bool corner_radius_applied,
                                 int filleted_edge_count,
                                 bool shell_cavity_applied,
                                 bool shell_cavity_valid,
                                 int shell_cavity_tool_count,
                                 int feature_intent_count,
                                 const NativeFeatureCutResult& feature_cuts) {
  ShapeMetrics metrics;
  metrics.corner_radius_applied = corner_radius_applied;
  metrics.filleted_edge_count = filleted_edge_count;
  metrics.shell_cavity_applied = shell_cavity_applied;
  metrics.shell_cavity_valid = shell_cavity_valid;
  metrics.shell_cavity_tool_count = shell_cavity_tool_count;
  metrics.feature_intent_count = feature_intent_count;
  metrics.native_feature_cut_count = feature_cuts.applied_cut_count;
  metrics.native_ignored_feature_intent_count =
      feature_cuts.ignored_intent_count;
  metrics.native_usb_c_cutout_count = feature_cuts.usb_c_cutout_count;
  metrics.native_usb_c_cutout_filleted_edge_count =
      feature_cuts.usb_c_filleted_edge_count;

  const FaceBounds bounds = ComputeTopoBounds(shape);
  metrics.bounds_min = bounds.min;
  metrics.bounds_max = bounds.max;
  metrics.dimensions = DimensionsFromBounds(bounds);

  GProp_GProps surface_properties;
  BRepGProp::SurfaceProperties(shape, surface_properties, false, false);
  metrics.surface_area = surface_properties.Mass();

  GProp_GProps volume_properties;
  BRepGProp::VolumeProperties(shape, volume_properties, false, false, false);
  metrics.volume = volume_properties.Mass();

  return metrics;
}

double PreviewSurfaceTolerance(const ShapeMetrics& metrics) {
  return PreviewSurfaceToleranceForDimensions(metrics.dimensions);
}

bool FaceIsOnPlane(double face_min,
                   double face_max,
                   double plane,
                   double tolerance) {
  return std::abs(face_min - plane) <= tolerance &&
         std::abs(face_max - plane) <= tolerance;
}

ShellBuildResult BuildTopOpenEnclosureShell(const TopoDS_Shape& outer_shape,
                                            const EnclosureRequest& enclosure) {
  ShellBuildResult result;
  result.shape = outer_shape;

  const TopoDS_Shape cavity_tool = BuildCavityCutTool(enclosure);
  if (cavity_tool.IsNull()) {
    throw std::runtime_error("OCCT generated a null cavity cut tool.");
  }

  BRepAlgoAPI_Cut cut(outer_shape, cavity_tool);
  cut.SimplifyResult(true, true);
  if (!cut.IsDone() || cut.HasErrors()) {
    throw std::runtime_error("OCCT shell/cavity cut did not complete.");
  }

  result.shape = cut.Shape();
  if (result.shape.IsNull()) {
    throw std::runtime_error("OCCT generated a null shell/cavity shape.");
  }

  BRepCheck_Analyzer analyzer(result.shape, false);
  result.cavity_valid = analyzer.IsValid();

  result.cavity_applied = true;
  result.cavity_tool_count = 1;
  return result;
}

std::array<double, 2> UsbCCutoutCenter(const EnclosureRequest& enclosure,
                                       const UsbCCutoutRequest& cutout) {
  if (cutout.has_surface_position) {
    return cutout.surface_position;
  }

  const double default_z =
      std::max(4.0, cutout.height / 2.0 + enclosure.wall_thickness);
  return {0.0, default_z};
}

bool UsbCCutoutFitsFrontSurface(const EnclosureRequest& enclosure,
                                const UsbCCutoutRequest& cutout,
                                const std::array<double, 2>& center) {
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_height =
      enclosure.size[2] - enclosure.wall_thickness * 2.0;
  const double tolerance = 0.000001;
  return center[0] - cutout.width / 2.0 >= -inner_width / 2.0 - tolerance &&
         center[0] + cutout.width / 2.0 <= inner_width / 2.0 + tolerance &&
         center[1] - cutout.height / 2.0 >= -tolerance &&
         center[1] + cutout.height / 2.0 <= inner_height + tolerance;
}

bool FaceIntersectsUsbCCutout(const FaceBounds& face_bounds,
                              const ShapeMetrics& metrics,
                              const EnclosureRequest& enclosure,
                              const UsbCCutoutRequest& cutout) {
  const std::array<double, 2> center =
      UsbCCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double cutout_min_x = center[0] - cutout.width / 2.0 - tolerance;
  const double cutout_max_x = center[0] + cutout.width / 2.0 + tolerance;
  const double cutout_min_z = center[1] - cutout.height / 2.0 - tolerance;
  const double cutout_max_z = center[1] + cutout.height / 2.0 + tolerance;
  const double front_y = -enclosure.size[1] / 2.0;
  const double cutout_min_y = front_y - tolerance;
  const double cutout_max_y =
      front_y + enclosure.wall_thickness + tolerance;

  const bool overlaps_cutout_volume =
      face_bounds.max[0] >= cutout_min_x &&
      face_bounds.min[0] <= cutout_max_x &&
      face_bounds.max[1] >= cutout_min_y &&
      face_bounds.min[1] <= cutout_max_y &&
      face_bounds.max[2] >= cutout_min_z &&
      face_bounds.min[2] <= cutout_max_z;
  const bool is_inside_cutout_opening =
      face_bounds.min[0] >= cutout_min_x &&
      face_bounds.max[0] <= cutout_max_x &&
      face_bounds.min[2] >= cutout_min_z &&
      face_bounds.max[2] <= cutout_max_z;
  const bool spans_wall_depth =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;

  return overlaps_cutout_volume && is_inside_cutout_opening && spans_wall_depth;
}

TopoDS_Shape BuildUsbCCutoutTool(const EnclosureRequest& enclosure,
                                 const UsbCCutoutRequest& cutout,
                                 int* filleted_edge_count) {
  const std::array<double, 2> center =
      UsbCCutoutCenter(enclosure, cutout);
  const double overcut = 2.0;
  const std::array<double, 3> tool_size = {
      cutout.width,
      enclosure.wall_thickness + overcut * 2.0,
      cutout.height};
  const gp_Pnt tool_origin(center[0] - cutout.width / 2.0,
                           -enclosure.size[1] / 2.0 - overcut,
                           center[1] - cutout.height / 2.0);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(tool_origin,
                          tool_size[0],
                          tool_size[1],
                          tool_size[2])
          .Shape();

  *filleted_edge_count = 0;
  const double safe_radius =
      std::min(cutout.corner_radius,
               std::min(cutout.width, cutout.height) / 2.0 - 0.001);
  if (safe_radius <= 0.0) {
    return box;
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    const TopoDS_Edge edge = TopoDS::Edge(explorer.Current());
    const std::array<double, 3> edge_dimensions =
        DimensionsFromBounds(ComputeTopoBounds(edge));
    if (edge_dimensions[0] <= 0.001 && edge_dimensions[2] <= 0.001 &&
        edge_dimensions[1] > 0.001) {
      fillet.Add(safe_radius, edge);
      ++(*filleted_edge_count);
    }
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error("OCCT USB-C cutout fillet did not complete.");
  }

  return fillet.Shape();
}

NativeFeatureCutResult ApplyNativeFeatureCutouts(
    const TopoDS_Shape& base_shape,
    const EnclosureRequest& enclosure,
    const std::vector<UsbCCutoutRequest>& usb_c_cutouts,
    int feature_intent_count) {
  NativeFeatureCutResult result;
  result.shape = base_shape;

  for (const UsbCCutoutRequest& cutout : usb_c_cutouts) {
    const std::array<double, 2> center =
        UsbCCutoutCenter(enclosure, cutout);
    if (!UsbCCutoutFitsFrontSurface(enclosure, cutout, center)) {
      continue;
    }

    int tool_filleted_edge_count = 0;
    const TopoDS_Shape tool =
        BuildUsbCCutoutTool(enclosure, cutout, &tool_filleted_edge_count);
    if (tool.IsNull()) {
      throw std::runtime_error("OCCT generated a null USB-C cutout tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error("OCCT USB-C cutout did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null USB-C cutout shape.");
    }

    BRepCheck_Analyzer analyzer(result.shape, false);
    if (!analyzer.IsValid()) {
      throw std::runtime_error("OCCT generated an invalid USB-C cutout shape.");
    }

    ++result.applied_cut_count;
    ++result.usb_c_cutout_count;
    result.usb_c_filleted_edge_count += tool_filleted_edge_count;
  }

  result.ignored_intent_count =
      std::max(0, feature_intent_count - result.applied_cut_count);
  return result;
}

FaceBounds ComputeFaceBounds(const Handle(Poly_Triangulation)& triangulation,
                             const TopLoc_Location& location) {
  FaceBounds bounds;
  bounds.min = {std::numeric_limits<double>::infinity(),
                std::numeric_limits<double>::infinity(),
                std::numeric_limits<double>::infinity()};
  bounds.max = {-std::numeric_limits<double>::infinity(),
                -std::numeric_limits<double>::infinity(),
                -std::numeric_limits<double>::infinity()};

  for (int node_index = 1; node_index <= triangulation->NbNodes();
       ++node_index) {
    const gp_Pnt point =
        triangulation->Node(node_index).Transformed(location.Transformation());
    bounds.min[0] = std::min(bounds.min[0], point.X());
    bounds.min[1] = std::min(bounds.min[1], point.Y());
    bounds.min[2] = std::min(bounds.min[2], point.Z());
    bounds.max[0] = std::max(bounds.max[0], point.X());
    bounds.max[1] = std::max(bounds.max[1], point.Y());
    bounds.max[2] = std::max(bounds.max[2], point.Z());
  }

  return bounds;
}

std::optional<std::pair<std::string, std::string>> ClassifyPreviewSurface(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const std::string& body_id) {
  const double tolerance = PreviewSurfaceTolerance(metrics);

  if (FaceIsOnPlane(face_bounds.min[2],
                    face_bounds.max[2],
                    metrics.bounds_max[2],
                    tolerance)) {
    return std::make_pair(body_id + ".top_lid.outer", "Top lid");
  }

  if (face_bounds.max[2] >= metrics.bounds_max[2] - tolerance &&
      face_bounds.min[2] > metrics.bounds_min[2] + tolerance) {
    return std::make_pair(body_id + ".top_lid.outer", "Top rim");
  }

  if (FaceIsOnPlane(face_bounds.min[2],
                    face_bounds.max[2],
                    metrics.bounds_min[2],
                    tolerance)) {
    return std::make_pair(body_id + ".bottom_inside", "Bottom inside");
  }

  if (FaceIsOnPlane(face_bounds.min[1],
                    face_bounds.max[1],
                    metrics.bounds_min[1],
                    tolerance)) {
    return std::make_pair(body_id + ".front_wall.outer", "Front wall");
  }

  return std::nullopt;
}

std::vector<std::pair<std::string, std::string>> ClassifyPreviewSurfaces(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const std::string& body_id,
    const EnclosureRequest& enclosure,
    const std::vector<UsbCCutoutRequest>& usb_c_cutouts) {
  std::vector<std::pair<std::string, std::string>> surfaces;
  const std::optional<std::pair<std::string, std::string>> body_surface =
      ClassifyPreviewSurface(face_bounds, metrics, body_id);
  if (body_surface.has_value()) {
    surfaces.push_back(body_surface.value());
  }

  for (const UsbCCutoutRequest& cutout : usb_c_cutouts) {
    if (FaceIntersectsUsbCCutout(face_bounds, metrics, enclosure, cutout)) {
      surfaces.push_back(std::make_pair(cutout.id, "USB-C cutout"));
    }
  }

  return surfaces;
}

void AddPreviewSurfaceRange(
    PreviewMeshData* mesh,
    const std::optional<std::pair<std::string, std::string>>& surface,
    int triangle_start,
    int triangle_count) {
  if (!surface.has_value() || triangle_count <= 0) {
    return;
  }

  for (PreviewSurfaceMappingData& mapping : mesh->surface_mappings) {
    if (mapping.semantic_id == surface->first) {
      mapping.triangle_ranges.push_back({triangle_start, triangle_count});
      return;
    }
  }

  mesh->surface_mappings.push_back(
      {surface->first, surface->second, {{triangle_start, triangle_count}}});
}

int PreviewMappedTriangleCount(const PreviewMeshData& mesh) {
  int count = 0;
  for (const PreviewSurfaceMappingData& mapping : mesh.surface_mappings) {
    for (const PreviewTriangleRangeData& range : mapping.triangle_ranges) {
      count += range.count;
    }
  }

  return count;
}

PreviewMeshData BuildPreviewMesh(const TopoDS_Shape& shape,
                                 const ShapeMetrics& metrics,
                                 const EnclosureRequest& enclosure,
                                 const std::vector<UsbCCutoutRequest>&
                                     usb_c_cutouts) {
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

    const FaceBounds face_bounds = ComputeFaceBounds(triangulation, location);
    const std::vector<std::pair<std::string, std::string>> surfaces =
        ClassifyPreviewSurfaces(face_bounds,
                                metrics,
                                enclosure.id,
                                enclosure,
                                usb_c_cutouts);
    const int vertex_offset = mesh.vertex_count();
    const int triangle_start = mesh.triangle_count();
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

    for (const std::pair<std::string, std::string>& surface : surfaces) {
      AddPreviewSurfaceRange(&mesh,
                             surface,
                             triangle_start,
                             mesh.triangle_count() - triangle_start);
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
      << "        \"preview_mesh returns a disposable triangulated preview mesh, first-pass semantic surface ranges, and deterministic rounded enclosure metrics.\"\n"
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

void WritePreviewSurfaceMappings(const PreviewMeshData& mesh) {
  std::cout << "[";
  if (!mesh.surface_mappings.empty()) {
    std::cout << "\n";
  }

  for (std::size_t mapping_index = 0;
       mapping_index < mesh.surface_mappings.size();
       ++mapping_index) {
    const PreviewSurfaceMappingData& mapping =
        mesh.surface_mappings[mapping_index];
    std::cout << "      {\n"
              << "        \"semanticId\": \""
              << EscapeJsonString(mapping.semantic_id) << "\",\n"
              << "        \"label\": \"" << EscapeJsonString(mapping.label)
              << "\",\n"
              << "        \"triangleRanges\": [";
    if (!mapping.triangle_ranges.empty()) {
      std::cout << "\n";
    }
    for (std::size_t range_index = 0;
         range_index < mapping.triangle_ranges.size();
         ++range_index) {
      const PreviewTriangleRangeData& range =
          mapping.triangle_ranges[range_index];
      std::cout << "          {\n"
                << "            \"start\": " << range.start << ",\n"
                << "            \"count\": " << range.count << "\n"
                << "          }";
      if (range_index + 1 < mapping.triangle_ranges.size()) {
        std::cout << ",";
      }
      std::cout << "\n";
    }
    std::cout << "        ]\n"
              << "      }";
    if (mapping_index + 1 < mesh.surface_mappings.size()) {
      std::cout << ",";
    }
    std::cout << "\n";
  }

  std::cout << "    ]";
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
            << "    \"surfaces\": ";
  WritePreviewSurfaceMappings(mesh);
  std::cout << ",\n"
            << "    \"source\": \"occt_brep\",\n"
            << "    \"surfaceMapping\": \"semantic_face_ranges_v1\",\n"
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
            << "    \"generator\": \"occt.rounded_enclosure.shell_preview_mesh.v1\",\n"
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
            << "    \"shellCavityApplied\": "
            << (metrics.shell_cavity_applied ? "true" : "false") << ",\n"
            << "    \"shellCavityValid\": "
            << (metrics.shell_cavity_valid ? "true" : "false") << ",\n"
            << "    \"shellCavityToolCount\": "
            << metrics.shell_cavity_tool_count << ",\n"
            << "    \"shellOpening\": \"top\",\n"
            << "    \"featureIntentCount\": "
            << metrics.feature_intent_count << ",\n"
            << "    \"nativeFeatureCutCount\": "
            << metrics.native_feature_cut_count << ",\n"
            << "    \"nativeIgnoredFeatureIntentCount\": "
            << metrics.native_ignored_feature_intent_count << ",\n"
            << "    \"nativeUsbCCutoutCount\": "
            << metrics.native_usb_c_cutout_count << ",\n"
            << "    \"nativeUsbCCutoutFilletedEdgeCount\": "
            << metrics.native_usb_c_cutout_filleted_edge_count << ",\n"
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
            << "    \"previewSurfaceMappingCount\": "
            << mesh.surface_mappings.size() << ",\n"
            << "    \"previewMappedTriangleCount\": "
            << PreviewMappedTriangleCount(mesh) << ",\n"
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
    const TopoDS_Shape outer_shape =
        BuildRoundedEnclosureShape(parsed_request.enclosure,
                                   &corner_radius_applied,
                                   &filleted_edge_count);
    if (outer_shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null enclosure shape.");
    }

    const ShellBuildResult shell =
        BuildTopOpenEnclosureShell(outer_shape, parsed_request.enclosure);
    if (shell.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null shell/cavity shape.");
    }

    const NativeFeatureCutResult feature_cuts =
        ApplyNativeFeatureCutouts(shell.shape,
                                  parsed_request.enclosure,
                                  parsed_request.usb_c_cutouts,
                                  parsed_request.feature_intent_count);
    if (feature_cuts.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null feature-cut shape.");
    }

    const ShapeMetrics metrics =
        ComputeShapeMetrics(feature_cuts.shape,
                            corner_radius_applied,
                            filleted_edge_count,
                            shell.cavity_applied,
                            shell.cavity_valid,
                            shell.cavity_tool_count,
                            parsed_request.feature_intent_count,
                            feature_cuts);
    const PreviewMeshData mesh =
        BuildPreviewMesh(feature_cuts.shape,
                         metrics,
                         parsed_request.enclosure,
                         parsed_request.usb_c_cutouts);
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
