#include <BRepBndLib.hxx>
#include <BRepAlgoAPI_Cut.hxx>
#include <BRepAlgoAPI_Fuse.hxx>
#include <BRepBuilderAPI_Transform.hxx>
#include <BRepCheck_Analyzer.hxx>
#include <BRepFilletAPI_MakeFillet.hxx>
#include <BRepGProp.hxx>
#include <BRepMesh_IncrementalMesh.hxx>
#include <BRepPrimAPI_MakeBox.hxx>
#include <BRepPrimAPI_MakeCylinder.hxx>
#include <BRep_Builder.hxx>
#include <BRep_Tool.hxx>
#include <Bnd_Box.hxx>
#include <GProp_GProps.hxx>
#include <Poly_Triangle.hxx>
#include <Poly_Triangulation.hxx>
#include <TopAbs_Orientation.hxx>
#include <Standard_Version.hxx>
#include <STEPControl_StepModelType.hxx>
#include <STEPControl_Writer.hxx>
#include <StlAPI_Writer.hxx>
#include <TopAbs_ShapeEnum.hxx>
#include <TopExp_Explorer.hxx>
#include <TopLoc_Location.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Compound.hxx>
#include <TopoDS_Edge.hxx>
#include <TopoDS_Face.hxx>
#include <TopoDS_Shape.hxx>
#include <gp_Ax1.hxx>
#include <gp_Ax2.hxx>
#include <gp_Dir.hxx>
#include <gp_Pnt.hxx>
#include <gp_Trsf.hxx>
#include <gp_Vec.hxx>

#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <filesystem>
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
constexpr double kExportStlLinearDeflection = 0.3;
constexpr double kExportStlAngularDeflection = 0.35;
constexpr double kDefaultButtonRingWidth = 1.2;
constexpr double kButtonRingInnerClearance = 0.05;
constexpr double kDefaultButtonRingProtrusion = 0.45;
constexpr double kButtonRingSurfaceOverlap = 0.12;
constexpr double kButtonRingCutOverrun = 0.1;
constexpr double kDefaultButtonCapClearance = 0.6;
constexpr double kDefaultButtonCapHeight = 1.2;
constexpr double kDefaultButtonStemDepth = 2.8;
constexpr double kDefaultButtonTravel = 0.8;
constexpr double kDefaultButtonSwitchClearance = 0.3;
constexpr double kDefaultButtonGuideClearance = 0.25;
constexpr double kButtonCapStemOverlap = 0.05;
constexpr double kButtonGuideWallThickness = 0.45;
constexpr double kButtonGuideMinLength = 0.2;
constexpr double kButtonTravelStopThickness = 0.35;
constexpr double kButtonTravelStopShoulder = 0.35;
constexpr double kDefaultSketchAddProtrusion = 1.2;
constexpr double kSketchAddSurfaceOverlap = 0.12;
constexpr double kMaxSketchAddProtrusion = 10.0;
constexpr double kPi = 3.14159265358979323846;

struct NativeRequestEnvelope {
  std::string request_id = kInvalidRequestId;
  std::string schema;
  std::string operation;
};

struct EnclosureRequest {
  std::string id;
  std::string shape;
  std::string lid_type;
  std::array<double, 3> size = {0.0, 0.0, 0.0};
  double wall_thickness = 0.0;
  double corner_radius = 0.0;
};

struct LidScrewBossRequest {
  std::string id;
  std::array<double, 2> position = {0.0, 0.0};
  double diameter = 7.0;
  double hole_diameter = 2.4;
  double height = 20.0;
};

struct GeneratedLidPlateRequest {
  std::string id;
  std::string locating_lip_id;
  std::string screw_holes_id;
  double thickness = 2.0;
  double preview_gap = 2.0;
  double lip_height = 1.2;
  double lip_width = 1.5;
  double lip_clearance = 0.3;
};

struct GeneratedLidSeatRequest {
  std::string id;
  double height = 1.4;
  double depth = 1.2;
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

struct GlassRecessRequest {
  std::string id;
  std::string target_surface;
  double width = 42.0;
  double height = 24.0;
  double recess_depth = 1.2;
  double ledge_width = 1.5;
  double corner_radius = 2.0;
  bool has_surface_position = false;
  std::array<double, 2> surface_position = {0.0, 0.0};
};

struct CircularCutoutRequest {
  std::string id;
  std::string target_surface;
  double diameter = 8.0;
  double depth = 3.0;
  bool has_surface_position = false;
  std::array<double, 2> surface_position = {0.0, 0.0};
};

struct RectangularCutoutRequest {
  std::string id;
  std::string target_surface;
  double width = 18.0;
  double height = 10.0;
  double depth = 3.0;
  double corner_radius = 2.0;
  double rotation_degrees = 0.0;
  bool has_surface_position = false;
  std::array<double, 2> surface_position = {0.0, 0.0};
};

struct SketchAddRequest {
  std::string id;
  std::string target_surface;
  std::string shape_type;
  double diameter = 8.0;
  double width = 18.0;
  double height = 10.0;
  double protrusion = kDefaultSketchAddProtrusion;
  double corner_radius = 2.0;
  double rotation_degrees = 0.0;
  bool has_surface_position = false;
  std::array<double, 2> surface_position = {0.0, 0.0};
};

struct ButtonCutoutItemRequest {
  std::string id;
  std::array<double, 2> position = {0.0, 0.0};
  double diameter = 8.0;
  double ring_width = kDefaultButtonRingWidth;
  double ring_protrusion = kDefaultButtonRingProtrusion;
  double cap_diameter = 7.4;
  double cap_height = kDefaultButtonCapHeight;
  double stem_diameter = 3.0;
  double stem_depth = kDefaultButtonStemDepth;
  double travel = kDefaultButtonTravel;
  double switch_clearance = kDefaultButtonSwitchClearance;
  double guide_clearance = kDefaultButtonGuideClearance;
  bool generate_plunger = true;
};

struct ButtonGroupCutoutRequest {
  std::string id;
  std::string target_surface;
  std::vector<ButtonCutoutItemRequest> items;
};

struct StandoffMountItemRequest {
  std::string id;
  std::array<double, 2> position = {0.0, 0.0};
  double diameter = 5.0;
  double hole_diameter = 2.2;
  double height = 4.0;
};

struct StandoffMountGroupRequest {
  std::string id;
  std::string target_surface;
  std::vector<StandoffMountItemRequest> items;
};

struct NativeRequestParseResult {
  NativeRequestEnvelope request;
  EnclosureRequest enclosure;
  std::string export_output_path;
  std::vector<UsbCCutoutRequest> usb_c_cutouts;
  std::vector<GlassRecessRequest> glass_recesses;
  std::vector<CircularCutoutRequest> circular_cutouts;
  std::vector<RectangularCutoutRequest> rectangular_cutouts;
  std::vector<SketchAddRequest> sketch_adds;
  std::vector<ButtonGroupCutoutRequest> button_groups;
  std::vector<StandoffMountGroupRequest> standoff_groups;
  std::vector<LidScrewBossRequest> lid_screw_bosses;
  std::vector<GeneratedLidPlateRequest> generated_lid_plates;
  std::vector<GeneratedLidSeatRequest> generated_lid_seats;
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
  int native_glass_recess_count = 0;
  int native_glass_recess_filleted_edge_count = 0;
  int native_glass_window_count = 0;
  int native_glass_window_filleted_edge_count = 0;
  int native_circular_cutout_count = 0;
  int native_rectangular_cutout_count = 0;
  int native_rectangular_cutout_filleted_edge_count = 0;
  int native_sketch_add_count = 0;
  int native_sketch_add_filleted_edge_count = 0;
  int native_button_group_count = 0;
  int native_button_cutout_count = 0;
  int native_button_ring_count = 0;
  int native_button_cap_count = 0;
  int native_button_stem_count = 0;
  int native_button_guide_count = 0;
  int native_button_travel_stop_count = 0;
  int native_standoff_group_count = 0;
  int native_standoff_mount_count = 0;
  int native_lid_screw_boss_count = 0;
  int native_lid_screw_pilot_count = 0;
  int native_generated_lid_seat_count = 0;
  int native_generated_lid_plate_count = 0;
  double native_generated_lid_fit_preview_gap = 0.0;
  int native_generated_lid_lip_count = 0;
  int native_generated_lid_screw_hole_count = 0;
  int native_generated_lid_feature_cut_count = 0;
  int native_generated_lid_glass_recess_count = 0;
  int native_generated_lid_glass_recess_filleted_edge_count = 0;
  int native_generated_lid_glass_window_count = 0;
  int native_generated_lid_glass_window_filleted_edge_count = 0;
  int native_generated_lid_circular_cutout_count = 0;
  int native_generated_lid_rectangular_cutout_count = 0;
  int native_generated_lid_rectangular_cutout_filleted_edge_count = 0;
  int native_generated_lid_sketch_add_count = 0;
  int native_generated_lid_sketch_add_filleted_edge_count = 0;
  int native_generated_lid_button_group_count = 0;
  int native_generated_lid_button_cutout_count = 0;
  int native_generated_lid_button_ring_count = 0;
  int native_generated_lid_button_cap_count = 0;
  int native_generated_lid_button_stem_count = 0;
  int native_generated_lid_button_guide_count = 0;
  int native_generated_lid_button_travel_stop_count = 0;
};

struct ShellBuildResult {
  TopoDS_Shape shape;
  bool cavity_applied = false;
  bool cavity_valid = false;
  int cavity_tool_count = 0;
};

struct NativeLidBossResult {
  TopoDS_Shape shape;
  int boss_count = 0;
  int pilot_hole_count = 0;
};

struct NativePreviewAssemblyResult {
  TopoDS_Shape shape;
  int button_cap_count = 0;
  int button_stem_count = 0;
  int button_guide_count = 0;
  int button_travel_stop_count = 0;
  int generated_lid_plate_count = 0;
  int generated_lid_lip_count = 0;
  int generated_lid_screw_hole_count = 0;
  int generated_lid_feature_cut_count = 0;
  int generated_lid_glass_recess_count = 0;
  int generated_lid_glass_recess_filleted_edge_count = 0;
  int generated_lid_glass_window_count = 0;
  int generated_lid_glass_window_filleted_edge_count = 0;
  int generated_lid_circular_cutout_count = 0;
  int generated_lid_rectangular_cutout_count = 0;
  int generated_lid_rectangular_cutout_filleted_edge_count = 0;
  int generated_lid_sketch_add_count = 0;
  int generated_lid_sketch_add_filleted_edge_count = 0;
  int generated_lid_button_group_count = 0;
  int generated_lid_button_cutout_count = 0;
  int generated_lid_button_ring_count = 0;
  int generated_lid_button_cap_count = 0;
  int generated_lid_button_stem_count = 0;
  int generated_lid_button_guide_count = 0;
  int generated_lid_button_travel_stop_count = 0;
  int applied_feature_intent_count = 0;
};

struct NativeGeneratedLidPlateResult {
  TopoDS_Shape shape;
  int locating_lip_count = 0;
  int screw_hole_count = 0;
  int feature_cut_count = 0;
  int glass_recess_count = 0;
  int glass_recess_filleted_edge_count = 0;
  int glass_window_count = 0;
  int glass_window_filleted_edge_count = 0;
  int circular_cutout_count = 0;
  int rectangular_cutout_count = 0;
  int rectangular_cutout_filleted_edge_count = 0;
  int sketch_add_count = 0;
  int sketch_add_filleted_edge_count = 0;
  int button_group_count = 0;
  int button_cutout_count = 0;
  int button_ring_count = 0;
  int button_cap_count = 0;
  int button_stem_count = 0;
  int applied_feature_intent_count = 0;
};

struct NativeGeneratedLidSeatResult {
  TopoDS_Shape shape;
  int seat_count = 0;
};

struct NativeFeatureCutResult {
  TopoDS_Shape shape;
  int applied_cut_count = 0;
  int applied_intent_count = 0;
  int ignored_intent_count = 0;
  int usb_c_cutout_count = 0;
  int usb_c_filleted_edge_count = 0;
  int glass_recess_count = 0;
  int glass_recess_filleted_edge_count = 0;
  int glass_window_count = 0;
  int glass_window_filleted_edge_count = 0;
  int circular_cutout_count = 0;
  int rectangular_cutout_count = 0;
  int rectangular_cutout_filleted_edge_count = 0;
  int sketch_add_count = 0;
  int sketch_add_filleted_edge_count = 0;
  int button_group_count = 0;
  int button_cutout_count = 0;
  int button_ring_count = 0;
  int button_cap_count = 0;
  int button_stem_count = 0;
  int standoff_group_count = 0;
  int standoff_mount_count = 0;
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

struct StepExportResult {
  std::string path;
  std::uintmax_t byte_count = 0;
  std::string transfer_status;
  std::string write_status;
};

struct StlExportResult {
  std::string path;
  std::uintmax_t byte_count = 0;
  int triangle_count = 0;
  int mesher_status = 0;
  bool binary = true;
  std::string write_status;
};

class ScopedCoutRedirect {
 public:
  explicit ScopedCoutRedirect(std::ostream& target)
      : original_buffer_(std::cout.rdbuf(target.rdbuf())) {}

  ScopedCoutRedirect(const ScopedCoutRedirect&) = delete;
  ScopedCoutRedirect& operator=(const ScopedCoutRedirect&) = delete;

  ~ScopedCoutRedirect() { std::cout.rdbuf(original_buffer_); }

 private:
  std::streambuf* original_buffer_;
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

bool IsApproximatelyZero(double value) {
  return std::isfinite(value) && std::abs(value) <= 0.000001;
}

double DegreesToRadians(double degrees) {
  return degrees * kPi / 180.0;
}

std::array<std::array<double, 2>, 4> RotatedRectangleCorners(
    const std::array<double, 2>& center,
    double width,
    double height,
    double rotation_degrees) {
  const double half_width = width / 2.0;
  const double half_height = height / 2.0;
  const double radians = DegreesToRadians(rotation_degrees);
  const double cos_angle = std::cos(radians);
  const double sin_angle = std::sin(radians);
  const std::array<std::array<double, 2>, 4> local_corners = {
      std::array<double, 2>{-half_width, -half_height},
      std::array<double, 2>{half_width, -half_height},
      std::array<double, 2>{half_width, half_height},
      std::array<double, 2>{-half_width, half_height}};
  std::array<std::array<double, 2>, 4> corners = {};
  for (std::size_t index = 0; index < local_corners.size(); ++index) {
    const double local_x = local_corners[index][0];
    const double local_y = local_corners[index][1];
    corners[index] = {
        center[0] + local_x * cos_angle - local_y * sin_angle,
        center[1] + local_x * sin_angle + local_y * cos_angle};
  }
  return corners;
}

std::array<double, 4> RotatedRectangleBounds2D(
    const std::array<double, 2>& center,
    double width,
    double height,
    double rotation_degrees,
    double tolerance) {
  const std::array<std::array<double, 2>, 4> corners =
      RotatedRectangleCorners(center, width, height, rotation_degrees);
  double min_x = std::numeric_limits<double>::infinity();
  double max_x = -std::numeric_limits<double>::infinity();
  double min_y = std::numeric_limits<double>::infinity();
  double max_y = -std::numeric_limits<double>::infinity();
  for (const std::array<double, 2>& corner : corners) {
    min_x = std::min(min_x, corner[0]);
    max_x = std::max(max_x, corner[0]);
    min_y = std::min(min_y, corner[1]);
    max_y = std::max(max_y, corner[1]);
  }
  return {min_x - tolerance, max_x + tolerance, min_y - tolerance,
          max_y + tolerance};
}

bool RotatedRectangleFitsBounds(const std::array<double, 2>& center,
                                double width,
                                double height,
                                double rotation_degrees,
                                double min_x,
                                double max_x,
                                double min_y,
                                double max_y,
                                double tolerance) {
  if (!IsPositiveDimension(width) || !IsPositiveDimension(height) ||
      !std::isfinite(rotation_degrees) || !std::isfinite(center[0]) ||
      !std::isfinite(center[1])) {
    return false;
  }

  const std::array<std::array<double, 2>, 4> corners =
      RotatedRectangleCorners(center, width, height, rotation_degrees);
  for (const std::array<double, 2>& corner : corners) {
    if (corner[0] < min_x - tolerance || corner[0] > max_x + tolerance ||
        corner[1] < min_y - tolerance || corner[1] > max_y + tolerance) {
      return false;
    }
  }
  return true;
}

std::array<double, 2> SketchProfileSurfacePosition(
    const EnclosureRequest& enclosure,
    const std::string& target_surface,
    const std::array<double, 2>& center) {
  if (target_surface == enclosure.id + ".front_wall.outer") {
    return {center[0], enclosure.size[2] / 2.0 + center[1]};
  }

  return center;
}

bool SketchProfileFitsSupportedSurface(const EnclosureRequest& enclosure,
                                       const std::string& target_surface,
                                       const std::array<double, 2>& center,
                                       double width,
                                       double height,
                                       double rotation_degrees = 0.0) {
  const bool targets_top_lid =
      target_surface == enclosure.id + ".top_lid.outer";
  const bool targets_front_wall =
      target_surface == enclosure.id + ".front_wall.outer";
  if (!targets_top_lid && !targets_front_wall) {
    return false;
  }

  const double available_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double available_height =
      targets_top_lid ? enclosure.size[1] - enclosure.wall_thickness * 2.0
                      : enclosure.size[2] - enclosure.wall_thickness * 2.0;
  const double min_secondary =
      targets_top_lid ? -available_height / 2.0 : enclosure.wall_thickness;
  const double max_secondary =
      targets_top_lid ? available_height / 2.0
                      : enclosure.size[2] - enclosure.wall_thickness;
  const double tolerance = 0.000001;

  return RotatedRectangleFitsBounds(center,
                                    width,
                                    height,
                                    rotation_degrees,
                                    -available_width / 2.0,
                                    available_width / 2.0,
                                    min_secondary,
                                    max_secondary,
                                    tolerance);
}

double DefaultButtonCapDiameter(double cutout_diameter) {
  return std::max(0.8, cutout_diameter - kDefaultButtonCapClearance);
}

double DefaultButtonStemDiameter(double cutout_diameter,
                                 double cap_diameter) {
  return std::max(
      0.8,
      std::min(cap_diameter * 0.55,
               std::max(0.8,
                        cutout_diameter - kDefaultButtonCapClearance * 2.0)));
}

double GeneratedTopLidLipHeight(const EnclosureRequest& enclosure) {
  return std::min(1.2, std::max(0.6, enclosure.wall_thickness * 0.6));
}

double GeneratedTopLidFitPreviewGap(const EnclosureRequest& enclosure,
                                    double lip_height) {
  const double inspection_gap =
      std::min(0.12, std::max(0.06, enclosure.wall_thickness * 0.04));
  return std::max(0.04, std::min(lip_height - 0.2, inspection_gap));
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

  if (*operation != "preview_mesh" && *operation != "export_step" &&
      *operation != "export_stl") {
    result.issue_code = "worker.backend.occt_operation_not_implemented";
    result.issue_message =
        "The native OCCT worker currently implements preview_mesh, "
        "export_step, and export_stl for the first enclosure body.";
    return result;
  }

  if (*operation == "export_step" || *operation == "export_stl") {
    const std::optional<std::string> options =
        ExtractTopLevelObjectField(payload, "options");
    if (!options.has_value()) {
      result.issue_code = "worker.export.missing_output_path";
      result.issue_message = "Native OCCT " +
                             (*operation == "export_step" ? std::string("STEP")
                                                           : std::string("STL")) +
                             " export requires options.outputPath.";
      return result;
    }

    result.export_output_path =
        ExtractTopLevelStringField(*options, "outputPath").value_or("");
    if (result.export_output_path.empty()) {
      result.issue_code = "worker.export.missing_output_path";
      result.issue_message = "Native OCCT " +
                             (*operation == "export_step" ? std::string("STEP")
                                                           : std::string("STL")) +
                             " export requires a non-empty options.outputPath.";
      return result;
    }
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
    const std::optional<std::string> lid =
        ExtractTopLevelObjectField(body, "lid");
    if (lid.has_value()) {
      result.enclosure.lid_type =
          ExtractTopLevelStringField(*lid, "type").value_or("");
    }
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

    if (result.enclosure.lid_type == "top_screw_lid") {
      GeneratedLidPlateRequest lid_plate;
      lid_plate.id = result.enclosure.id + ".generated_top_lid";
      lid_plate.locating_lip_id =
          result.enclosure.id + ".generated_top_lid_locating_lip";
      lid_plate.screw_holes_id =
          result.enclosure.id + ".generated_top_lid_screw_holes";
      lid_plate.thickness = std::max(1.0, result.enclosure.wall_thickness);
      lid_plate.lip_height = GeneratedTopLidLipHeight(result.enclosure);
      lid_plate.preview_gap =
          GeneratedTopLidFitPreviewGap(result.enclosure,
                                       lid_plate.lip_height);
      lid_plate.lip_width =
          std::max(1.0, result.enclosure.wall_thickness * 0.75);
      lid_plate.lip_clearance = 0.3;
      result.generated_lid_plates.push_back(lid_plate);

      GeneratedLidSeatRequest lid_seat;
      lid_seat.id = result.enclosure.id + ".generated_top_lid_seat";
      lid_seat.height = lid_plate.lip_height + 0.2;
      lid_seat.depth =
          std::min(result.enclosure.wall_thickness - 0.4,
                   lid_plate.lip_width + lid_plate.lip_clearance);
      if (lid_seat.height > 0.0 && lid_seat.depth > 0.0) {
        result.generated_lid_seats.push_back(lid_seat);
      }

      const double inner_width =
          result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
      const double inner_depth =
          result.enclosure.size[1] - result.enclosure.wall_thickness * 2.0;
      const double boss_diameter =
          std::min(7.0, std::min(inner_width, inner_depth) / 6.0);
      const double boss_radius = boss_diameter / 2.0;
      const double boss_inset = boss_radius + 5.0;
      const double center_x = inner_width / 2.0 - boss_inset;
      const double center_y = inner_depth / 2.0 - boss_inset;
      const double boss_height =
          std::min(result.enclosure.size[2] -
                       result.enclosure.wall_thickness - 0.5,
                   std::max(4.0,
                            result.enclosure.size[2] -
                                result.enclosure.wall_thickness * 2.0 - 1.0));
      if (boss_diameter >= 3.0 && center_x > boss_radius &&
          center_y > boss_radius && boss_height > 0.5) {
        const double hole_diameter = std::min(2.4, boss_diameter - 1.2);
        const std::array<std::array<double, 2>, 4> positions = {
            std::array<double, 2>{-center_x, -center_y},
            std::array<double, 2>{center_x, -center_y},
            std::array<double, 2>{-center_x, center_y},
            std::array<double, 2>{center_x, center_y}};
        for (int index = 0; index < 4; ++index) {
          LidScrewBossRequest boss;
          boss.id = result.enclosure.id + ".lid_screw_bosses";
          boss.position = positions[index];
          boss.diameter = boss_diameter;
          boss.hole_diameter = hole_diameter;
          boss.height = boss_height;
          result.lid_screw_bosses.push_back(boss);
        }
      }
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
  const std::string supported_top_surface =
      result.enclosure.id + ".top_lid.outer";
  const std::string supported_bottom_surface =
      result.enclosure.id + ".bottom_inside";
  for (const std::string& intent : feature_intents) {
    const std::string kind =
        ExtractTopLevelStringField(intent, "kind").value_or("");
    const std::string intent_operation =
        ExtractTopLevelStringField(intent, "operation").value_or("");
    const std::optional<std::string> parameters =
        ExtractTopLevelObjectField(intent, "parameters");
    const std::optional<std::string> placement =
        ExtractTopLevelObjectField(intent, "placement");

    if (kind == "usb_c_cutout") {
      if (intent_operation != "negative") {
        continue;
      }

      UsbCCutoutRequest cutout;
      cutout.id =
          ExtractTopLevelStringField(intent, "id").value_or("usb_c_cutout");
      cutout.target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      if (parameters.has_value()) {
        cutout.width =
            ExtractTopLevelNumberField(*parameters, "width").value_or(10.5);
        cutout.height =
            ExtractTopLevelNumberField(*parameters, "height").value_or(4.2);
        cutout.corner_radius =
            ExtractTopLevelNumberField(*parameters, "cornerRadius").value_or(1.0);
      }

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
      continue;
    }

    if (kind == "glass_recess") {
      if (intent_operation != "recess") {
        continue;
      }

      GlassRecessRequest recess;
      recess.id =
          ExtractTopLevelStringField(intent, "id").value_or("glass_recess");
      recess.target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      if (parameters.has_value()) {
        recess.width =
            ExtractTopLevelNumberField(*parameters, "width").value_or(42.0);
        recess.height =
            ExtractTopLevelNumberField(*parameters, "height").value_or(24.0);
        recess.recess_depth =
            ExtractTopLevelNumberField(*parameters, "recessDepth").value_or(1.2);
        recess.ledge_width =
            ExtractTopLevelNumberField(*parameters, "ledgeWidth").value_or(1.5);
        recess.corner_radius =
            ExtractTopLevelNumberField(*parameters, "cornerRadius").value_or(2.0);
      }

      if (placement.has_value()) {
        const std::optional<std::array<double, 2>> surface_position =
            ExtractTopLevelNumberArray2Field(*placement, "surfacePosition");
        if (surface_position.has_value()) {
          recess.surface_position = *surface_position;
          recess.has_surface_position = true;
        }
      }

      if (recess.target_surface != supported_front_surface &&
          recess.target_surface != supported_top_surface) {
        continue;
      }

      const bool targets_top_lid =
          recess.target_surface == supported_top_surface;
      const double available_width =
          result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
      const double available_height =
          targets_top_lid
              ? result.enclosure.size[1] -
                    result.enclosure.wall_thickness * 2.0
              : result.enclosure.size[2] -
                    result.enclosure.wall_thickness * 2.0;
      const double max_recess_depth =
          targets_top_lid ? std::max(1.0, result.enclosure.wall_thickness)
                          : result.enclosure.wall_thickness;
      if (!IsPositiveDimension(recess.width) ||
          !IsPositiveDimension(recess.height) ||
          !IsPositiveDimension(recess.recess_depth) ||
          !std::isfinite(recess.ledge_width) ||
          recess.ledge_width < 0.0 ||
          recess.ledge_width * 2.0 >=
              std::min(recess.width, recess.height) ||
          !std::isfinite(recess.corner_radius) ||
          recess.corner_radius < 0.0 ||
          recess.corner_radius * 2.0 >
              std::min(recess.width, recess.height) ||
          recess.width > available_width ||
          recess.height > available_height ||
          recess.recess_depth >= max_recess_depth) {
        result.issue_code = "worker.geometry.invalid_glass_recess";
        result.issue_message =
            "Native OCCT worker glass recess dimensions must fit the target surface.";
        return result;
      }

      result.glass_recesses.push_back(recess);
      continue;
    }

    if (kind == "advanced_sketch") {
      if (intent_operation != "helper") {
        continue;
      }

      const std::string sketch_id =
          ExtractTopLevelStringField(intent, "id").value_or("advanced_sketch");
      const std::string target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      if (target_surface != supported_front_surface &&
          target_surface != supported_top_surface) {
        continue;
      }

      const std::vector<std::string> entities =
          ExtractTopLevelObjectArrayField(intent, "entities");
      for (const std::string& entity : entities) {
        const std::string profile_intent =
            ExtractTopLevelStringField(entity, "profileIntent")
                .value_or("reference");
        if (profile_intent != "cut" && profile_intent != "add") {
          continue;
        }

        const std::string entity_type =
            ExtractTopLevelStringField(entity, "type").value_or("");
        const std::string entity_id =
            ExtractTopLevelStringField(entity, "id").value_or("entity");
        const std::optional<std::string> entity_parameters =
            ExtractTopLevelObjectField(entity, "parameters");
        const std::array<double, 2> center =
            entity_parameters.has_value()
                ? ExtractTopLevelNumberArray2Field(*entity_parameters, "center")
                      .value_or(std::array<double, 2>{0.0, 0.0})
                : std::array<double, 2>{0.0, 0.0};
        const std::array<double, 2> surface_position =
            SketchProfileSurfacePosition(result.enclosure,
                                         target_surface,
                                         center);
        const std::string profile_id = sketch_id + "." + entity_id;

        if (entity_type == "circle") {
          double diameter = 12.0;
          double depth = profile_intent == "add"
                             ? kDefaultSketchAddProtrusion
                             : 3.0;
          if (entity_parameters.has_value()) {
            diameter =
                ExtractTopLevelNumberField(*entity_parameters, "diameter")
                    .value_or(12.0);
            depth =
                ExtractTopLevelNumberField(*entity_parameters, "depth")
                    .value_or(
                        ExtractTopLevelNumberField(*entity_parameters,
                                                   "protrusion")
                            .value_or(depth));
          }

          if (!IsPositiveDimension(depth) ||
              !SketchProfileFitsSupportedSurface(result.enclosure,
                                                 target_surface,
                                                 surface_position,
                                                 diameter,
                                                 diameter) ||
              (profile_intent == "add" && depth > kMaxSketchAddProtrusion)) {
            result.issue_code =
                profile_intent == "add"
                    ? "worker.geometry.invalid_sketch_profile_add"
                    : "worker.geometry.invalid_sketch_profile_cut";
            result.issue_message =
                profile_intent == "add"
                    ? "Native OCCT worker sketch circle adds must fit the target surface."
                    : "Native OCCT worker sketch circle cuts must fit the target surface.";
            return result;
          }

          if (profile_intent == "add") {
            SketchAddRequest add;
            add.id = profile_id;
            add.target_surface = target_surface;
            add.shape_type = "circle";
            add.has_surface_position = true;
            add.surface_position = surface_position;
            add.diameter = diameter;
            add.protrusion = depth;
            result.sketch_adds.push_back(add);
          } else {
            CircularCutoutRequest cutout;
            cutout.id = profile_id;
            cutout.target_surface = target_surface;
            cutout.has_surface_position = true;
            cutout.surface_position = surface_position;
            cutout.diameter = diameter;
            cutout.depth = depth;
            result.circular_cutouts.push_back(cutout);
          }
          continue;
        }

        if (entity_type == "rectangle") {
          double width = 20.0;
          double height = 12.0;
          double corner_radius = 0.0;
          double depth = profile_intent == "add"
                             ? kDefaultSketchAddProtrusion
                             : 3.0;
          double rotation_degrees = 0.0;
          if (entity_parameters.has_value()) {
            width =
                ExtractTopLevelNumberField(*entity_parameters, "width")
                    .value_or(20.0);
            height =
                ExtractTopLevelNumberField(*entity_parameters, "height")
                    .value_or(12.0);
            corner_radius =
                ExtractTopLevelNumberField(*entity_parameters, "cornerRadius")
                    .value_or(0.0);
            depth =
                ExtractTopLevelNumberField(*entity_parameters, "depth")
                    .value_or(
                        ExtractTopLevelNumberField(*entity_parameters,
                                                   "protrusion")
                            .value_or(depth));
            rotation_degrees =
                ExtractTopLevelNumberField(*entity_parameters, "rotation")
                    .value_or(0.0);
          }

          if (!IsPositiveDimension(depth) ||
              !std::isfinite(corner_radius) ||
              corner_radius < 0.0 ||
              corner_radius * 2.0 > std::min(width, height) ||
              !SketchProfileFitsSupportedSurface(result.enclosure,
                                                 target_surface,
                                                 surface_position,
                                                 width,
                                                 height,
                                                 rotation_degrees) ||
              (profile_intent == "add" && depth > kMaxSketchAddProtrusion)) {
            result.issue_code =
                profile_intent == "add"
                    ? "worker.geometry.invalid_sketch_profile_add"
                    : "worker.geometry.invalid_sketch_profile_cut";
            result.issue_message =
                profile_intent == "add"
                    ? "Native OCCT worker sketch rectangle adds must fit the target surface."
                    : "Native OCCT worker sketch rectangle cuts must fit the target surface.";
            return result;
          }

          if (profile_intent == "add") {
            SketchAddRequest add;
            add.id = profile_id;
            add.target_surface = target_surface;
            add.shape_type = "rectangle";
            add.has_surface_position = true;
            add.surface_position = surface_position;
            add.width = width;
            add.height = height;
            add.protrusion = depth;
            add.corner_radius = corner_radius;
            add.rotation_degrees = rotation_degrees;
            result.sketch_adds.push_back(add);
          } else {
            RectangularCutoutRequest cutout;
            cutout.id = profile_id;
            cutout.target_surface = target_surface;
            cutout.has_surface_position = true;
            cutout.surface_position = surface_position;
            cutout.width = width;
            cutout.height = height;
            cutout.depth = depth;
            cutout.corner_radius = corner_radius;
            cutout.rotation_degrees = rotation_degrees;
            result.rectangular_cutouts.push_back(cutout);
          }
          continue;
        }
      }

      continue;
    }

    if (kind == "circular_cutout") {
      if (intent_operation != "negative") {
        continue;
      }

      CircularCutoutRequest cutout;
      cutout.id =
          ExtractTopLevelStringField(intent, "id").value_or("circular_cutout");
      cutout.target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      double parameter_position_x = 0.0;
      double parameter_position_y = 0.0;
      if (parameters.has_value()) {
        cutout.diameter =
            ExtractTopLevelNumberField(*parameters, "diameter").value_or(8.0);
        cutout.depth =
            ExtractTopLevelNumberField(*parameters, "depth").value_or(3.0);
        parameter_position_x =
            ExtractTopLevelNumberField(*parameters, "positionX").value_or(0.0);
        parameter_position_y =
            ExtractTopLevelNumberField(*parameters, "positionY").value_or(0.0);
      }

      if (cutout.target_surface == supported_top_surface) {
        cutout.surface_position = {parameter_position_x, parameter_position_y};
        cutout.has_surface_position = true;
      } else if (cutout.target_surface == supported_front_surface) {
        cutout.surface_position = {
            parameter_position_x,
            result.enclosure.size[2] / 2.0 + parameter_position_y};
        cutout.has_surface_position = true;
      }

      if (placement.has_value()) {
        const std::optional<std::array<double, 2>> surface_position =
            ExtractTopLevelNumberArray2Field(*placement, "surfacePosition");
        if (surface_position.has_value()) {
          cutout.surface_position = *surface_position;
          cutout.has_surface_position = true;
        }
      }

      if (cutout.target_surface != supported_front_surface &&
          cutout.target_surface != supported_top_surface) {
        continue;
      }

      const bool targets_top_lid =
          cutout.target_surface == supported_top_surface;
      const double radius = cutout.diameter / 2.0;
      const double available_width =
          result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
      const double available_height =
          targets_top_lid
              ? result.enclosure.size[1] -
                    result.enclosure.wall_thickness * 2.0
              : result.enclosure.size[2] -
                    result.enclosure.wall_thickness * 2.0;
      const double center_x = cutout.surface_position[0];
      const double center_y = cutout.surface_position[1];
      const double min_secondary =
          targets_top_lid ? -available_height / 2.0
                          : result.enclosure.wall_thickness;
      const double max_secondary =
          targets_top_lid ? available_height / 2.0
                          : result.enclosure.size[2] -
                                result.enclosure.wall_thickness;

      if (!IsPositiveDimension(cutout.diameter) ||
          !IsPositiveDimension(cutout.depth) ||
          !std::isfinite(cutout.surface_position[0]) ||
          !std::isfinite(cutout.surface_position[1]) ||
          cutout.diameter > std::min(available_width, available_height) ||
          center_x - radius < -available_width / 2.0 ||
          center_x + radius > available_width / 2.0 ||
          center_y - radius < min_secondary ||
          center_y + radius > max_secondary) {
        result.issue_code = "worker.geometry.invalid_circular_cutout";
        result.issue_message =
            "Native OCCT worker circular cutout dimensions must fit the target surface.";
        return result;
      }

      result.circular_cutouts.push_back(cutout);
      continue;
    }

    if (kind == "rectangular_cutout") {
      if (intent_operation != "negative") {
        continue;
      }

      RectangularCutoutRequest cutout;
      cutout.id =
          ExtractTopLevelStringField(intent, "id").value_or("rectangular_cutout");
      cutout.target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      double parameter_position_x = 0.0;
      double parameter_position_y = 0.0;
      if (parameters.has_value()) {
        cutout.width =
            ExtractTopLevelNumberField(*parameters, "width").value_or(18.0);
        cutout.height =
            ExtractTopLevelNumberField(*parameters, "height").value_or(10.0);
        cutout.depth =
            ExtractTopLevelNumberField(*parameters, "depth").value_or(3.0);
        cutout.corner_radius =
            ExtractTopLevelNumberField(*parameters, "cornerRadius").value_or(2.0);
        cutout.rotation_degrees =
            ExtractTopLevelNumberField(*parameters, "rotation").value_or(0.0);
        parameter_position_x =
            ExtractTopLevelNumberField(*parameters, "positionX").value_or(0.0);
        parameter_position_y =
            ExtractTopLevelNumberField(*parameters, "positionY").value_or(0.0);
      }

      if (cutout.target_surface == supported_top_surface) {
        cutout.surface_position = {parameter_position_x, parameter_position_y};
        cutout.has_surface_position = true;
      } else if (cutout.target_surface == supported_front_surface) {
        cutout.surface_position = {
            parameter_position_x,
            result.enclosure.size[2] / 2.0 + parameter_position_y};
        cutout.has_surface_position = true;
      }

      if (placement.has_value()) {
        const std::optional<std::array<double, 2>> surface_position =
            ExtractTopLevelNumberArray2Field(*placement, "surfacePosition");
        if (surface_position.has_value()) {
          cutout.surface_position = *surface_position;
          cutout.has_surface_position = true;
        }
      }

      if (cutout.target_surface != supported_front_surface &&
          cutout.target_surface != supported_top_surface) {
        continue;
      }

      const bool targets_top_lid =
          cutout.target_surface == supported_top_surface;
      const double available_width =
          result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
      const double available_height =
          targets_top_lid
              ? result.enclosure.size[1] -
                    result.enclosure.wall_thickness * 2.0
              : result.enclosure.size[2] -
                    result.enclosure.wall_thickness * 2.0;
      const double center_x = cutout.surface_position[0];
      const double center_y = cutout.surface_position[1];
      const double min_secondary =
          targets_top_lid ? -available_height / 2.0
                          : result.enclosure.wall_thickness;
      const double max_secondary =
          targets_top_lid ? available_height / 2.0
                          : result.enclosure.size[2] -
                                result.enclosure.wall_thickness;

      if (!IsPositiveDimension(cutout.width) ||
          !IsPositiveDimension(cutout.height) ||
          !IsPositiveDimension(cutout.depth) ||
          !std::isfinite(cutout.corner_radius) ||
          cutout.corner_radius < 0.0 ||
          cutout.corner_radius * 2.0 >
              std::min(cutout.width, cutout.height) ||
          !std::isfinite(cutout.surface_position[0]) ||
          !std::isfinite(cutout.surface_position[1]) ||
          cutout.width > available_width ||
          cutout.height > available_height ||
          center_x - cutout.width / 2.0 < -available_width / 2.0 ||
          center_x + cutout.width / 2.0 > available_width / 2.0 ||
          center_y - cutout.height / 2.0 < min_secondary ||
          center_y + cutout.height / 2.0 > max_secondary) {
        result.issue_code = "worker.geometry.invalid_rectangular_cutout";
        result.issue_message =
            "Native OCCT worker rectangular cutout dimensions must fit the target surface.";
        return result;
      }

      result.rectangular_cutouts.push_back(cutout);
      continue;
    }

    if (kind == "button_group") {
      if (intent_operation != "composite") {
        continue;
      }

      ButtonGroupCutoutRequest group;
      group.id =
          ExtractTopLevelStringField(intent, "id").value_or("button_group");
      group.target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      if (group.target_surface != supported_front_surface &&
          group.target_surface != supported_top_surface) {
        continue;
      }

      double default_diameter = 8.0;
      double default_ring_width = kDefaultButtonRingWidth;
      double default_ring_protrusion = kDefaultButtonRingProtrusion;
      double default_cap_diameter =
          DefaultButtonCapDiameter(default_diameter);
      double default_cap_height = kDefaultButtonCapHeight;
      double default_stem_diameter =
          DefaultButtonStemDiameter(default_diameter, default_cap_diameter);
      double default_stem_depth = kDefaultButtonStemDepth;
      double default_travel = kDefaultButtonTravel;
      double default_switch_clearance = kDefaultButtonSwitchClearance;
      double default_guide_clearance = kDefaultButtonGuideClearance;
      std::string default_mode = "plunger";
      if (parameters.has_value()) {
        const std::optional<std::string> item_prototype =
            ExtractTopLevelObjectField(*parameters, "itemPrototype");
        if (item_prototype.has_value()) {
          default_diameter =
              ExtractTopLevelNumberField(*item_prototype, "diameter")
                  .value_or(default_diameter);
          default_cap_diameter =
              DefaultButtonCapDiameter(default_diameter);
          default_stem_diameter =
              DefaultButtonStemDiameter(default_diameter,
                                        default_cap_diameter);
          default_ring_width =
              ExtractTopLevelNumberField(*item_prototype, "ringWidth")
                  .value_or(default_ring_width);
          default_ring_protrusion =
              ExtractTopLevelNumberField(*item_prototype, "ringProtrusion")
                  .value_or(default_ring_protrusion);
          default_cap_diameter =
              ExtractTopLevelNumberField(*item_prototype, "capDiameter")
                  .value_or(default_cap_diameter);
          default_cap_height =
              ExtractTopLevelNumberField(*item_prototype, "capHeight")
                  .value_or(default_cap_height);
          default_stem_diameter =
              ExtractTopLevelNumberField(*item_prototype, "stemDiameter")
                  .value_or(
                      DefaultButtonStemDiameter(default_diameter,
                                                default_cap_diameter));
          default_stem_depth =
              ExtractTopLevelNumberField(*item_prototype, "stemDepth")
                  .value_or(default_stem_depth);
          default_travel =
              ExtractTopLevelNumberField(*item_prototype, "travel")
                  .value_or(default_travel);
          default_switch_clearance =
              ExtractTopLevelNumberField(*item_prototype, "switchClearance")
                  .value_or(default_switch_clearance);
          default_guide_clearance =
              ExtractTopLevelNumberField(*item_prototype, "guideClearance")
                  .value_or(default_guide_clearance);
          default_mode =
              ExtractTopLevelStringField(*item_prototype, "mode")
                  .value_or(default_mode);
        }
      }

      const bool targets_top_lid =
          group.target_surface == supported_top_surface;
      const double inner_width =
          result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
      const double inner_depth =
          result.enclosure.size[1] - result.enclosure.wall_thickness * 2.0;
      const double min_z = result.enclosure.wall_thickness;
      const double max_z =
          result.enclosure.size[2] - result.enclosure.wall_thickness;
      const std::vector<std::string> items =
          ExtractTopLevelObjectArrayField(intent, "items");
      for (const std::string& item : items) {
        const std::optional<std::array<double, 2>> position =
            ExtractTopLevelNumberArray2Field(item, "position");
        if (!position.has_value()) {
          continue;
        }

        ButtonCutoutItemRequest cutout;
        cutout.id =
            ExtractTopLevelStringField(item, "id").value_or(group.id);
        cutout.position = *position;
        const std::optional<std::string> item_parameters =
            ExtractTopLevelObjectField(item, "parameters");
        if (item_parameters.has_value()) {
          cutout.diameter =
              ExtractTopLevelNumberField(*item_parameters, "diameter")
                  .value_or(default_diameter);
          cutout.ring_width =
              ExtractTopLevelNumberField(*item_parameters, "ringWidth")
                  .value_or(default_ring_width);
          cutout.ring_protrusion =
              ExtractTopLevelNumberField(*item_parameters, "ringProtrusion")
                  .value_or(default_ring_protrusion);
          cutout.cap_diameter =
              ExtractTopLevelNumberField(*item_parameters, "capDiameter")
                  .value_or(default_cap_diameter);
          cutout.cap_height =
              ExtractTopLevelNumberField(*item_parameters, "capHeight")
                  .value_or(default_cap_height);
          cutout.stem_diameter =
              ExtractTopLevelNumberField(*item_parameters, "stemDiameter")
                  .value_or(default_stem_diameter);
          cutout.stem_depth =
              ExtractTopLevelNumberField(*item_parameters, "stemDepth")
                  .value_or(default_stem_depth);
          cutout.travel =
              ExtractTopLevelNumberField(*item_parameters, "travel")
                  .value_or(default_travel);
          cutout.switch_clearance =
              ExtractTopLevelNumberField(*item_parameters, "switchClearance")
                  .value_or(default_switch_clearance);
          cutout.guide_clearance =
              ExtractTopLevelNumberField(*item_parameters, "guideClearance")
                  .value_or(default_guide_clearance);
          const std::string mode =
              ExtractTopLevelStringField(*item_parameters, "mode")
                  .value_or(default_mode);
          cutout.generate_plunger = mode == "plunger";
        } else {
          cutout.diameter = default_diameter;
          cutout.ring_width = default_ring_width;
          cutout.ring_protrusion = default_ring_protrusion;
          cutout.cap_diameter = default_cap_diameter;
          cutout.cap_height = default_cap_height;
          cutout.stem_diameter = default_stem_diameter;
          cutout.stem_depth = default_stem_depth;
          cutout.travel = default_travel;
          cutout.switch_clearance = default_switch_clearance;
          cutout.guide_clearance = default_guide_clearance;
          cutout.generate_plunger = default_mode == "plunger";
        }

        const double radius = cutout.diameter / 2.0;
        const double ring_outer_radius =
            radius + kButtonRingInnerClearance + cutout.ring_width;
        const double cap_radius =
            cutout.generate_plunger ? cutout.cap_diameter / 2.0 : 0.0;
        const double guide_inner_radius =
            cutout.stem_diameter / 2.0 + cutout.guide_clearance;
        const double guide_outer_radius =
            guide_inner_radius + kButtonGuideWallThickness;
        const double travel_stop_outer_radius =
            std::min(cutout.cap_diameter / 2.0,
                     guide_inner_radius + kButtonTravelStopShoulder);
        const double guide_length =
            cutout.stem_depth - cutout.travel - cutout.switch_clearance;
        const double plunger_fit_radius =
            cutout.generate_plunger
                ? std::max(cap_radius,
                           std::max(guide_outer_radius,
                                    travel_stop_outer_radius))
                : 0.0;
        const double fit_radius = std::max(ring_outer_radius, plunger_fit_radius);
        const double center_x = cutout.position[0];
        const double center_secondary =
            targets_top_lid
                ? cutout.position[1]
                : result.enclosure.size[2] / 2.0 + cutout.position[1];
        const double available_secondary =
            targets_top_lid ? inner_depth : max_z - min_z;
        if (!IsPositiveDimension(cutout.diameter) ||
            !IsPositiveDimension(cutout.ring_width) ||
            !IsPositiveDimension(cutout.ring_protrusion) ||
            (cutout.generate_plunger &&
             (!IsPositiveDimension(cutout.cap_diameter) ||
               !IsPositiveDimension(cutout.cap_height) ||
               !IsPositiveDimension(cutout.stem_diameter) ||
               !IsPositiveDimension(cutout.stem_depth) ||
               !IsPositiveDimension(cutout.travel) ||
               !std::isfinite(cutout.switch_clearance) ||
               cutout.switch_clearance < 0.0 ||
               !std::isfinite(cutout.guide_clearance) ||
               cutout.guide_clearance < 0.0)) ||
            cutout.ring_width > 8.0 ||
            cutout.ring_protrusion > 6.0 ||
            (cutout.generate_plunger &&
             (cutout.cap_height > 8.0 ||
              cutout.stem_depth > 12.0 ||
              guide_length < kButtonGuideMinLength ||
              guide_outer_radius >= cutout.diameter / 2.0 ||
              travel_stop_outer_radius <= cutout.stem_diameter / 2.0 ||
              cutout.cap_diameter >= cutout.diameter ||
              cutout.stem_diameter >= cutout.diameter ||
              cutout.stem_diameter > cutout.cap_diameter)) ||
            cutout.diameter > std::min(inner_width, available_secondary) ||
            ring_outer_radius * 2.0 >
                std::min(inner_width, available_secondary) ||
            fit_radius * 2.0 > std::min(inner_width, available_secondary) ||
            center_x - fit_radius < -inner_width / 2.0 ||
            center_x + fit_radius > inner_width / 2.0 ||
            (targets_top_lid &&
             (center_secondary - fit_radius < -inner_depth / 2.0 ||
              center_secondary + fit_radius > inner_depth / 2.0)) ||
            (!targets_top_lid &&
             (center_secondary - fit_radius < min_z ||
              center_secondary + fit_radius > max_z))) {
          result.issue_code = "worker.geometry.invalid_button_cutout";
          result.issue_message =
              "Native OCCT worker button cutouts, rings, and caps must fit the target surface.";
          return result;
        }

        group.items.push_back(cutout);
      }

      if (!group.items.empty()) {
        result.button_groups.push_back(group);
      }

      continue;
    }

    if (kind == "standoff_mounts") {
      if (intent_operation != "composite") {
        continue;
      }

      StandoffMountGroupRequest group;
      group.id =
          ExtractTopLevelStringField(intent, "id").value_or("standoff_mounts");
      group.target_surface =
          ExtractTopLevelStringField(intent, "targetSurface").value_or("");
      if (group.target_surface != supported_bottom_surface) {
        continue;
      }

      double default_diameter = 5.0;
      double default_hole_diameter = 2.2;
      double default_height = 4.0;
      if (parameters.has_value()) {
        const std::optional<std::string> item_prototype =
            ExtractTopLevelObjectField(*parameters, "itemPrototype");
        if (item_prototype.has_value()) {
          default_diameter =
              ExtractTopLevelNumberField(*item_prototype, "diameter")
                  .value_or(default_diameter);
          default_hole_diameter =
              ExtractTopLevelNumberField(*item_prototype, "holeDiameter")
                  .value_or(default_hole_diameter);
          default_height =
              ExtractTopLevelNumberField(*item_prototype, "height")
                  .value_or(default_height);
        }
      }

      const double inner_width =
          result.enclosure.size[0] - result.enclosure.wall_thickness * 2.0;
      const double inner_depth =
          result.enclosure.size[1] - result.enclosure.wall_thickness * 2.0;
      const double available_height =
          result.enclosure.size[2] - result.enclosure.wall_thickness;
      const std::vector<std::string> items =
          ExtractTopLevelObjectArrayField(intent, "items");
      for (const std::string& item : items) {
        const std::optional<std::array<double, 2>> position =
            ExtractTopLevelNumberArray2Field(item, "position");
        if (!position.has_value()) {
          continue;
        }

        StandoffMountItemRequest mount;
        mount.id = ExtractTopLevelStringField(item, "id").value_or(group.id);
        mount.position = *position;
        mount.diameter = default_diameter;
        mount.hole_diameter = default_hole_diameter;
        mount.height = default_height;
        const std::optional<std::string> item_parameters =
            ExtractTopLevelObjectField(item, "parameters");
        if (item_parameters.has_value()) {
          mount.diameter =
              ExtractTopLevelNumberField(*item_parameters, "diameter")
                  .value_or(mount.diameter);
          mount.hole_diameter =
              ExtractTopLevelNumberField(*item_parameters, "holeDiameter")
                  .value_or(mount.hole_diameter);
          mount.height =
              ExtractTopLevelNumberField(*item_parameters, "height")
                  .value_or(mount.height);
        }

        const double radius = mount.diameter / 2.0;
        if (!IsPositiveDimension(mount.diameter) ||
            !IsPositiveDimension(mount.hole_diameter) ||
            !IsPositiveDimension(mount.height) ||
            mount.hole_diameter >= mount.diameter - 0.8 ||
            mount.height > available_height ||
            mount.position[0] - radius < -inner_width / 2.0 ||
            mount.position[0] + radius > inner_width / 2.0 ||
            mount.position[1] - radius < -inner_depth / 2.0 ||
            mount.position[1] + radius > inner_depth / 2.0) {
          result.issue_code = "worker.geometry.invalid_standoff_mount";
          result.issue_message =
              "Native OCCT worker standoff mounts must fit the bottom inside surface.";
          return result;
        }

        group.items.push_back(mount);
      }

      if (!group.items.empty()) {
        result.standoff_groups.push_back(group);
      }
    }
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

TopoDS_Shape BuildRoundedBoxVerticalEdgeShape(
    const gp_Pnt& origin,
    const std::array<double, 3>& size,
    double corner_radius,
    bool* corner_radius_applied,
    int* filleted_edge_count) {
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(origin, size[0], size[1], size[2]).Shape();

  *corner_radius_applied = false;
  *filleted_edge_count = 0;
  const double max_radius = std::min(size[0], size[1]) / 2.0 - 0.001;
  const double safe_radius = std::min(corner_radius, max_radius);
  if (safe_radius <= 0.0) {
    return box;
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    const TopoDS_Edge edge = TopoDS::Edge(explorer.Current());
    const std::array<double, 3> edge_dimensions =
        DimensionsFromBounds(ComputeTopoBounds(edge));
    if (edge_dimensions[0] <= 0.001 && edge_dimensions[1] <= 0.001 &&
        edge_dimensions[2] > 0.001) {
      fillet.Add(safe_radius, edge);
      ++(*filleted_edge_count);
    }
  }

  if (*filleted_edge_count == 0) {
    return box;
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error(
        "OCCT vertical-edge fillet build did not complete.");
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

double GeneratedTopLidScrewClearanceDiameter(
    const LidScrewBossRequest& boss) {
  return std::min(boss.diameter - 1.0,
                  std::max(boss.hole_diameter + 0.8, boss.hole_diameter));
}

double GeneratedTopLidLipWidth(const EnclosureRequest& enclosure,
                               const GeneratedLidPlateRequest& lid_plate) {
  const double outer_width =
      enclosure.size[0] -
      (enclosure.wall_thickness + lid_plate.lip_clearance) * 2.0;
  const double outer_depth =
      enclosure.size[1] -
      (enclosure.wall_thickness + lid_plate.lip_clearance) * 2.0;
  return std::min(lid_plate.lip_width,
                  std::min(outer_width, outer_depth) / 4.0);
}

TopoDS_Shape BuildGeneratedTopLidLocatingLipShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate) {
  const double lip_width = GeneratedTopLidLipWidth(enclosure, lid_plate);
  const double lip_overlap = 0.2;
  const std::array<double, 3> outer_size = {
      enclosure.size[0] -
          (enclosure.wall_thickness + lid_plate.lip_clearance) * 2.0,
      enclosure.size[1] -
          (enclosure.wall_thickness + lid_plate.lip_clearance) * 2.0,
      lid_plate.lip_height + lip_overlap};
  const std::array<double, 3> inner_size = {
      outer_size[0] - lip_width * 2.0,
      outer_size[1] - lip_width * 2.0,
      outer_size[2] + 0.4};

  if (!IsPositiveDimension(lip_width) ||
      !IsPositiveDimension(lid_plate.lip_height) ||
      !IsPositiveDimension(outer_size[0]) ||
      !IsPositiveDimension(outer_size[1]) ||
      !IsPositiveDimension(inner_size[0]) ||
      !IsPositiveDimension(inner_size[1])) {
    return TopoDS_Shape();
  }

  const double lip_min_z =
      enclosure.size[2] + lid_plate.preview_gap - lid_plate.lip_height;
  const double outer_radius =
      std::max(0.0,
               enclosure.corner_radius - enclosure.wall_thickness -
                   lid_plate.lip_clearance);
  bool outer_radius_applied = false;
  int outer_filleted_edge_count = 0;
  const TopoDS_Shape outer_lip =
      BuildRoundedBoxShape(gp_Pnt(-outer_size[0] / 2.0,
                                  -outer_size[1] / 2.0,
                                  lip_min_z),
                           outer_size,
                           outer_radius,
                           &outer_radius_applied,
                           &outer_filleted_edge_count);
  if (outer_lip.IsNull()) {
    throw std::runtime_error("OCCT generated a null top lid locating lip.");
  }

  bool inner_radius_applied = false;
  int inner_filleted_edge_count = 0;
  const TopoDS_Shape inner_tool =
      BuildRoundedBoxShape(gp_Pnt(-inner_size[0] / 2.0,
                                  -inner_size[1] / 2.0,
                                  lip_min_z - 0.2),
                           inner_size,
                           std::max(0.0, outer_radius - lip_width),
                           &inner_radius_applied,
                           &inner_filleted_edge_count);
  if (inner_tool.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid locating lip cut tool.");
  }

  BRepAlgoAPI_Cut cut(outer_lip, inner_tool);
  cut.SimplifyResult(true, true);
  if (!cut.IsDone() || cut.HasErrors()) {
    throw std::runtime_error("OCCT top lid locating lip cut did not complete.");
  }

  const TopoDS_Shape lip_shape = cut.Shape();
  if (lip_shape.IsNull()) {
    throw std::runtime_error("OCCT generated a null top lid locating lip ring.");
  }

  BRepCheck_Analyzer analyzer(lip_shape, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid top lid locating lip.");
  }

  return lip_shape;
}

TopoDS_Shape BuildGeneratedTopLidScrewHoleTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const LidScrewBossRequest& boss) {
  const double clearance_diameter =
      GeneratedTopLidScrewClearanceDiameter(boss);
  if (!IsPositiveDimension(clearance_diameter)) {
    throw std::runtime_error("OCCT generated invalid top lid screw clearance.");
  }

  const double overcut = 0.5;
  const gp_Ax2 axis(
      gp_Pnt(boss.position[0],
             boss.position[1],
             enclosure.size[2] + lid_plate.preview_gap - overcut),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape tool =
      BRepPrimAPI_MakeCylinder(axis,
                               clearance_diameter / 2.0,
                               lid_plate.thickness + overcut * 2.0)
          .Shape();
  if (tool.IsNull()) {
    throw std::runtime_error("OCCT generated a null top lid screw hole tool.");
  }

  return tool;
}

TopoDS_Shape BuildGeneratedTopLidButtonCutoutTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout);

TopoDS_Shape BuildGeneratedTopLidButtonRingShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout);

TopoDS_Shape BuildButtonPlungerShape(const EnclosureRequest& enclosure,
                                     const ButtonCutoutItemRequest& cutout);

TopoDS_Shape BuildGeneratedTopLidButtonPlungerShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout);

TopoDS_Shape BuildGeneratedTopLidGlassRecessTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const GlassRecessRequest& recess,
    int* filleted_edge_count);

TopoDS_Shape BuildGeneratedTopLidGlassWindowTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const GlassRecessRequest& recess,
    int* filleted_edge_count);

TopoDS_Shape BuildGeneratedTopLidCircularCutoutTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const CircularCutoutRequest& cutout);

TopoDS_Shape BuildGeneratedTopLidRectangularCutoutTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const RectangularCutoutRequest& cutout,
    int* filleted_edge_count);

TopoDS_Shape BuildGeneratedTopLidSketchAddShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const SketchAddRequest& add,
    int* filleted_edge_count);

std::array<double, 2> GlassRecessTopLidCenter(
    const GlassRecessRequest& recess);

bool GlassRecessFitsTopLidSurface(const EnclosureRequest& enclosure,
                                  const GlassRecessRequest& recess,
                                  const std::array<double, 2>& center);

std::array<double, 2> CircularCutoutCenter(
    const EnclosureRequest& enclosure,
    const CircularCutoutRequest& cutout);

bool CircularCutoutFitsTopLidSurface(
    const EnclosureRequest& enclosure,
    const CircularCutoutRequest& cutout,
    const std::array<double, 2>& center);

std::array<double, 2> RectangularCutoutCenter(
    const EnclosureRequest& enclosure,
    const RectangularCutoutRequest& cutout);

bool RectangularCutoutFitsTopLidSurface(
    const EnclosureRequest& enclosure,
    const RectangularCutoutRequest& cutout,
    const std::array<double, 2>& center);

std::array<double, 2> SketchAddCenter(const EnclosureRequest& enclosure,
                                      const SketchAddRequest& add);

bool SketchAddFitsTopLidSurface(const EnclosureRequest& enclosure,
                                const SketchAddRequest& add,
                                const std::array<double, 2>& center);

NativeGeneratedLidPlateResult BuildGeneratedTopLidPlateShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const std::vector<LidScrewBossRequest>& lid_screw_bosses,
    const std::vector<GlassRecessRequest>& glass_recesses,
    const std::vector<CircularCutoutRequest>& circular_cutouts,
    const std::vector<RectangularCutoutRequest>& rectangular_cutouts,
    const std::vector<SketchAddRequest>& sketch_adds,
    const std::vector<ButtonGroupCutoutRequest>& button_groups) {
  NativeGeneratedLidPlateResult result;
  const std::array<double, 3> lid_size = {
      enclosure.size[0],
      enclosure.size[1],
      lid_plate.thickness};
  const gp_Pnt lid_origin(-lid_size[0] / 2.0,
                          -lid_size[1] / 2.0,
                          enclosure.size[2] + lid_plate.preview_gap);
  bool lid_radius_applied = false;
  int lid_filleted_edge_count = 0;
  const TopoDS_Shape lid_shape =
      BuildRoundedBoxVerticalEdgeShape(lid_origin,
                                       lid_size,
                                       enclosure.corner_radius,
                                       &lid_radius_applied,
                                       &lid_filleted_edge_count);
  if (lid_shape.IsNull()) {
    throw std::runtime_error("OCCT generated a null top lid plate.");
  }

  result.shape = lid_shape;
  const TopoDS_Shape locating_lip =
      BuildGeneratedTopLidLocatingLipShape(enclosure, lid_plate);
  if (!locating_lip.IsNull()) {
    BRepAlgoAPI_Fuse fuse(result.shape, locating_lip);
    fuse.SimplifyResult(true, true);
    if (!fuse.IsDone() || fuse.HasErrors()) {
      throw std::runtime_error(
          "OCCT top lid locating lip fuse did not complete.");
    }

    result.shape = fuse.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid locating lip fuse.");
    }

    BRepCheck_Analyzer fuse_analyzer(result.shape, false);
    if (!fuse_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid locating lip fuse.");
    }

    ++result.locating_lip_count;
  }

  for (const GlassRecessRequest& recess : glass_recesses) {
    if (recess.target_surface != enclosure.id + ".top_lid.outer") {
      continue;
    }

    const std::array<double, 2> center = GlassRecessTopLidCenter(recess);
    if (!GlassRecessFitsTopLidSurface(enclosure, recess, center)) {
      continue;
    }

    int tool_filleted_edge_count = 0;
    const TopoDS_Shape tool =
        BuildGeneratedTopLidGlassRecessTool(enclosure,
                                            lid_plate,
                                            recess,
                                            &tool_filleted_edge_count);
    if (tool.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid glass recess tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error("OCCT top lid glass recess cut did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid glass recess shape.");
    }

    BRepCheck_Analyzer cut_analyzer(result.shape, false);
    if (!cut_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid glass recess shape.");
    }

    ++result.feature_cut_count;
    ++result.glass_recess_count;
    result.glass_recess_filleted_edge_count += tool_filleted_edge_count;

    int window_filleted_edge_count = 0;
    const TopoDS_Shape window_tool =
        BuildGeneratedTopLidGlassWindowTool(enclosure,
                                            lid_plate,
                                            recess,
                                            &window_filleted_edge_count);
    if (window_tool.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid glass window tool.");
    }

    BRepAlgoAPI_Cut window_cut(result.shape, window_tool);
    window_cut.SimplifyResult(true, true);
    if (!window_cut.IsDone() || window_cut.HasErrors()) {
      throw std::runtime_error("OCCT top lid glass window cut did not complete.");
    }

    result.shape = window_cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid glass window shape.");
    }

    BRepCheck_Analyzer window_cut_analyzer(result.shape, false);
    if (!window_cut_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid glass window shape.");
    }

    ++result.feature_cut_count;
    ++result.glass_window_count;
    result.glass_window_filleted_edge_count += window_filleted_edge_count;
    ++result.applied_feature_intent_count;
  }

  for (const CircularCutoutRequest& cutout : circular_cutouts) {
    if (cutout.target_surface != enclosure.id + ".top_lid.outer") {
      continue;
    }

    const std::array<double, 2> center =
        CircularCutoutCenter(enclosure, cutout);
    if (!CircularCutoutFitsTopLidSurface(enclosure, cutout, center)) {
      continue;
    }

    const TopoDS_Shape tool =
        BuildGeneratedTopLidCircularCutoutTool(enclosure, lid_plate, cutout);
    if (tool.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid circular cutout tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error(
          "OCCT top lid circular cutout did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid circular cutout shape.");
    }

    BRepCheck_Analyzer cut_analyzer(result.shape, false);
    if (!cut_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid circular cutout shape.");
    }

    ++result.feature_cut_count;
    ++result.circular_cutout_count;
    ++result.applied_feature_intent_count;
  }

  for (const RectangularCutoutRequest& cutout : rectangular_cutouts) {
    if (cutout.target_surface != enclosure.id + ".top_lid.outer") {
      continue;
    }

    const std::array<double, 2> center =
        RectangularCutoutCenter(enclosure, cutout);
    if (!RectangularCutoutFitsTopLidSurface(enclosure, cutout, center)) {
      continue;
    }

    int tool_filleted_edge_count = 0;
    const TopoDS_Shape tool =
        BuildGeneratedTopLidRectangularCutoutTool(enclosure,
                                                 lid_plate,
                                                 cutout,
                                                 &tool_filleted_edge_count);
    if (tool.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid rectangular cutout tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error(
          "OCCT top lid rectangular cutout did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid rectangular cutout shape.");
    }

    BRepCheck_Analyzer cut_analyzer(result.shape, false);
    if (!cut_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid rectangular cutout shape.");
    }

    ++result.feature_cut_count;
    ++result.rectangular_cutout_count;
    result.rectangular_cutout_filleted_edge_count += tool_filleted_edge_count;
    ++result.applied_feature_intent_count;
  }

  for (const SketchAddRequest& add : sketch_adds) {
    if (add.target_surface != enclosure.id + ".top_lid.outer") {
      continue;
    }

    const std::array<double, 2> center = SketchAddCenter(enclosure, add);
    if (!SketchAddFitsTopLidSurface(enclosure, add, center)) {
      continue;
    }

    int filleted_edge_count = 0;
    const TopoDS_Shape add_shape =
        BuildGeneratedTopLidSketchAddShape(enclosure,
                                           lid_plate,
                                           add,
                                           &filleted_edge_count);
    if (add_shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid sketch add shape.");
    }

    BRepAlgoAPI_Fuse fuse(result.shape, add_shape);
    fuse.SimplifyResult(true, true);
    if (!fuse.IsDone() || fuse.HasErrors()) {
      throw std::runtime_error(
          "OCCT top lid sketch add fuse did not complete.");
    }

    result.shape = fuse.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid sketch add fuse shape.");
    }

    BRepCheck_Analyzer fuse_analyzer(result.shape, false);
    if (!fuse_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid sketch add fuse shape.");
    }

    ++result.sketch_add_count;
    result.sketch_add_filleted_edge_count += filleted_edge_count;
    ++result.applied_feature_intent_count;
  }

  for (const LidScrewBossRequest& boss : lid_screw_bosses) {
    const TopoDS_Shape hole_tool =
        BuildGeneratedTopLidScrewHoleTool(enclosure, lid_plate, boss);
    BRepAlgoAPI_Cut cut(result.shape, hole_tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error("OCCT top lid screw hole cut did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid screw hole shape.");
    }

    BRepCheck_Analyzer cut_analyzer(result.shape, false);
    if (!cut_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid top lid screw hole shape.");
    }

    ++result.screw_hole_count;
  }

  for (const ButtonGroupCutoutRequest& group : button_groups) {
    if (group.target_surface != enclosure.id + ".top_lid.outer") {
      continue;
    }

    int group_cut_count = 0;
    for (const ButtonCutoutItemRequest& cutout : group.items) {
      const TopoDS_Shape tool =
          BuildGeneratedTopLidButtonCutoutTool(enclosure, lid_plate, cutout);
      if (tool.IsNull()) {
        throw std::runtime_error(
            "OCCT generated a null top lid button cutout tool.");
      }

      BRepAlgoAPI_Cut cut(result.shape, tool);
      cut.SimplifyResult(true, true);
      if (!cut.IsDone() || cut.HasErrors()) {
        throw std::runtime_error(
            "OCCT top lid button cutout did not complete.");
      }

      result.shape = cut.Shape();
      if (result.shape.IsNull()) {
        throw std::runtime_error(
            "OCCT generated a null top lid button cutout shape.");
      }

      BRepCheck_Analyzer cut_analyzer(result.shape, false);
      if (!cut_analyzer.IsValid()) {
        throw std::runtime_error(
            "OCCT generated an invalid top lid button cutout shape.");
      }

      ++result.feature_cut_count;
      ++result.button_cutout_count;
      ++group_cut_count;

      const TopoDS_Shape ring =
          BuildGeneratedTopLidButtonRingShape(enclosure, lid_plate, cutout);
      if (ring.IsNull()) {
        throw std::runtime_error(
            "OCCT generated a null top lid button ring shape.");
      }

      BRepAlgoAPI_Fuse fuse(result.shape, ring);
      fuse.SimplifyResult(true, true);
      if (!fuse.IsDone() || fuse.HasErrors()) {
        throw std::runtime_error(
            "OCCT top lid button ring fuse did not complete.");
      }

      result.shape = fuse.Shape();
      if (result.shape.IsNull()) {
        throw std::runtime_error(
            "OCCT generated a null top lid button ring fuse shape.");
      }

      BRepCheck_Analyzer fuse_analyzer(result.shape, false);
      if (!fuse_analyzer.IsValid()) {
        throw std::runtime_error(
            "OCCT generated an invalid top lid button ring fuse shape.");
      }

      ++result.button_ring_count;
    }

    if (group_cut_count > 0) {
      ++result.button_group_count;
      ++result.applied_feature_intent_count;
    }
  }

  BRepCheck_Analyzer analyzer(result.shape, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid top lid plate.");
  }

  return result;
}

NativePreviewAssemblyResult BuildPreviewAssembly(
    const TopoDS_Shape& body_shape,
    const EnclosureRequest& enclosure,
    const std::vector<GeneratedLidPlateRequest>& lid_plates,
    const std::vector<LidScrewBossRequest>& lid_screw_bosses,
    const std::vector<GlassRecessRequest>& glass_recesses,
    const std::vector<CircularCutoutRequest>& circular_cutouts,
    const std::vector<RectangularCutoutRequest>& rectangular_cutouts,
    const std::vector<SketchAddRequest>& sketch_adds,
    const std::vector<ButtonGroupCutoutRequest>& button_groups) {
  NativePreviewAssemblyResult result;
  result.shape = body_shape;

  BRep_Builder builder;
  TopoDS_Compound compound;
  builder.MakeCompound(compound);
  builder.Add(compound, body_shape);

  for (const ButtonGroupCutoutRequest& group : button_groups) {
    if (group.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    for (const ButtonCutoutItemRequest& cutout : group.items) {
      if (!cutout.generate_plunger) {
        continue;
      }

      const TopoDS_Shape plunger = BuildButtonPlungerShape(enclosure, cutout);
      if (plunger.IsNull()) {
        throw std::runtime_error(
            "OCCT generated a null front button plunger preview shape.");
      }
      builder.Add(compound, plunger);
      ++result.button_cap_count;
      ++result.button_stem_count;
      ++result.button_guide_count;
      ++result.button_travel_stop_count;
    }
  }

  for (const GeneratedLidPlateRequest& lid_plate : lid_plates) {
    const NativeGeneratedLidPlateResult lid_result =
        BuildGeneratedTopLidPlateShape(enclosure,
                                       lid_plate,
                                        lid_screw_bosses,
                                        glass_recesses,
                                        circular_cutouts,
                                        rectangular_cutouts,
                                        sketch_adds,
                                        button_groups);
    builder.Add(compound, lid_result.shape);
    ++result.generated_lid_plate_count;
    result.generated_lid_lip_count += lid_result.locating_lip_count;
    result.generated_lid_screw_hole_count += lid_result.screw_hole_count;
    result.generated_lid_feature_cut_count += lid_result.feature_cut_count;
    result.generated_lid_glass_recess_count += lid_result.glass_recess_count;
    result.generated_lid_glass_recess_filleted_edge_count +=
        lid_result.glass_recess_filleted_edge_count;
    result.generated_lid_glass_window_count += lid_result.glass_window_count;
    result.generated_lid_glass_window_filleted_edge_count +=
        lid_result.glass_window_filleted_edge_count;
    result.generated_lid_circular_cutout_count +=
        lid_result.circular_cutout_count;
    result.generated_lid_rectangular_cutout_count +=
        lid_result.rectangular_cutout_count;
    result.generated_lid_rectangular_cutout_filleted_edge_count +=
        lid_result.rectangular_cutout_filleted_edge_count;
    result.generated_lid_sketch_add_count += lid_result.sketch_add_count;
    result.generated_lid_sketch_add_filleted_edge_count +=
        lid_result.sketch_add_filleted_edge_count;
    result.generated_lid_button_group_count += lid_result.button_group_count;
    result.generated_lid_button_cutout_count += lid_result.button_cutout_count;
    result.generated_lid_button_ring_count += lid_result.button_ring_count;
    result.applied_feature_intent_count +=
        lid_result.applied_feature_intent_count;

    for (const ButtonGroupCutoutRequest& group : button_groups) {
      if (group.target_surface != enclosure.id + ".top_lid.outer") {
        continue;
      }

      for (const ButtonCutoutItemRequest& cutout : group.items) {
        if (!cutout.generate_plunger) {
          continue;
        }

        const TopoDS_Shape plunger =
            BuildGeneratedTopLidButtonPlungerShape(enclosure,
                                                   lid_plate,
                                                   cutout);
        if (plunger.IsNull()) {
          throw std::runtime_error(
              "OCCT generated a null top lid button plunger preview shape.");
        }
        builder.Add(compound, plunger);
        ++result.generated_lid_button_cap_count;
        ++result.generated_lid_button_stem_count;
        ++result.generated_lid_button_guide_count;
        ++result.generated_lid_button_travel_stop_count;
      }
    }
  }

  BRepCheck_Analyzer analyzer(compound, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid preview assembly.");
  }

  result.shape = compound;
  return result;
}

std::vector<TopoDS_Shape> BuildGeneratedTopLidSeatTools(
    const EnclosureRequest& enclosure,
    const GeneratedLidSeatRequest& seat) {
  const double depth =
      std::min(seat.depth, enclosure.wall_thickness - 0.2);
  const double height = seat.height;
  const double overcut = 0.2;
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_depth =
      enclosure.size[1] - enclosure.wall_thickness * 2.0;
  const double min_z = enclosure.size[2] - height;
  const double tool_height = height + overcut * 2.0;

  if (!IsPositiveDimension(depth) ||
      !IsPositiveDimension(height) ||
      !IsPositiveDimension(inner_width) ||
      !IsPositiveDimension(inner_depth)) {
    return {};
  }

  std::vector<TopoDS_Shape> tools;
  tools.push_back(BRepPrimAPI_MakeBox(
                      gp_Pnt(-inner_width / 2.0 - overcut,
                             -inner_depth / 2.0 - depth,
                             min_z - overcut),
                      inner_width + overcut * 2.0,
                      depth + overcut,
                      tool_height)
                      .Shape());
  tools.push_back(BRepPrimAPI_MakeBox(
                      gp_Pnt(-inner_width / 2.0 - overcut,
                             inner_depth / 2.0 - overcut,
                             min_z - overcut),
                      inner_width + overcut * 2.0,
                      depth + overcut,
                      tool_height)
                      .Shape());
  tools.push_back(BRepPrimAPI_MakeBox(
                      gp_Pnt(-inner_width / 2.0 - depth,
                             -inner_depth / 2.0 - depth,
                             min_z - overcut),
                      depth + overcut,
                      inner_depth + depth * 2.0,
                      tool_height)
                      .Shape());
  tools.push_back(BRepPrimAPI_MakeBox(
                      gp_Pnt(inner_width / 2.0 - overcut,
                             -inner_depth / 2.0 - depth,
                             min_z - overcut),
                      depth + overcut,
                      inner_depth + depth * 2.0,
                      tool_height)
                      .Shape());

  for (const TopoDS_Shape& tool : tools) {
    if (tool.IsNull()) {
      throw std::runtime_error("OCCT generated a null top lid seat tool.");
    }
  }

  return tools;
}

NativeGeneratedLidSeatResult ApplyGeneratedTopLidSeats(
    const TopoDS_Shape& base_shape,
    const EnclosureRequest& enclosure,
    const std::vector<GeneratedLidSeatRequest>& seats) {
  NativeGeneratedLidSeatResult result;
  result.shape = base_shape;

  for (const GeneratedLidSeatRequest& seat : seats) {
    const std::vector<TopoDS_Shape> tools =
        BuildGeneratedTopLidSeatTools(enclosure, seat);
    if (tools.empty()) {
      continue;
    }

    for (const TopoDS_Shape& tool : tools) {
      BRepAlgoAPI_Cut cut(result.shape, tool);
      cut.SimplifyResult(true, true);
      if (!cut.IsDone() || cut.HasErrors()) {
        throw std::runtime_error("OCCT top lid seat cut did not complete.");
      }

      result.shape = cut.Shape();
      if (result.shape.IsNull()) {
        throw std::runtime_error("OCCT generated a null top lid seat shape.");
      }

      BRepCheck_Analyzer analyzer(result.shape, false);
      if (!analyzer.IsValid()) {
        throw std::runtime_error("OCCT generated an invalid top lid seat.");
      }
    }

    ++result.seat_count;
  }

  return result;
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
                                 int lid_screw_boss_count,
                                 int lid_screw_pilot_count,
                                 int button_cap_count,
                                 int button_stem_count,
                                 int button_guide_count,
                                 int button_travel_stop_count,
                                 int generated_lid_seat_count,
                                 int generated_lid_plate_count,
                                 double generated_lid_fit_preview_gap,
                                 int generated_lid_lip_count,
                                 int generated_lid_screw_hole_count,
                                 int generated_lid_feature_cut_count,
                                 int generated_lid_glass_recess_count,
                                 int generated_lid_glass_recess_filleted_edge_count,
                                 int generated_lid_glass_window_count,
                                 int generated_lid_glass_window_filleted_edge_count,
                                 int generated_lid_circular_cutout_count,
                                 int generated_lid_rectangular_cutout_count,
                                 int generated_lid_rectangular_cutout_filleted_edge_count,
                                 int generated_lid_sketch_add_count,
                                 int generated_lid_sketch_add_filleted_edge_count,
                                 int generated_lid_button_group_count,
                                 int generated_lid_button_cutout_count,
                                 int generated_lid_button_ring_count,
                                 int generated_lid_button_cap_count,
                                 int generated_lid_button_stem_count,
                                 int generated_lid_button_guide_count,
                                 int generated_lid_button_travel_stop_count,
                                 int generated_lid_applied_intent_count,
                                 int feature_intent_count,
                                 const NativeFeatureCutResult& feature_cuts) {
  ShapeMetrics metrics;
  metrics.corner_radius_applied = corner_radius_applied;
  metrics.filleted_edge_count = filleted_edge_count;
  metrics.shell_cavity_applied = shell_cavity_applied;
  metrics.shell_cavity_valid = shell_cavity_valid;
  metrics.shell_cavity_tool_count = shell_cavity_tool_count;
  metrics.native_lid_screw_boss_count = lid_screw_boss_count;
  metrics.native_lid_screw_pilot_count = lid_screw_pilot_count;
  metrics.native_button_cap_count = button_cap_count;
  metrics.native_button_stem_count = button_stem_count;
  metrics.native_button_guide_count = button_guide_count;
  metrics.native_button_travel_stop_count = button_travel_stop_count;
  metrics.native_generated_lid_seat_count = generated_lid_seat_count;
  metrics.native_generated_lid_plate_count = generated_lid_plate_count;
  metrics.native_generated_lid_fit_preview_gap =
      generated_lid_fit_preview_gap;
  metrics.native_generated_lid_lip_count = generated_lid_lip_count;
  metrics.native_generated_lid_screw_hole_count =
      generated_lid_screw_hole_count;
  metrics.native_generated_lid_feature_cut_count =
      generated_lid_feature_cut_count;
  metrics.native_generated_lid_glass_recess_count =
      generated_lid_glass_recess_count;
  metrics.native_generated_lid_glass_recess_filleted_edge_count =
      generated_lid_glass_recess_filleted_edge_count;
  metrics.native_generated_lid_glass_window_count =
      generated_lid_glass_window_count;
  metrics.native_generated_lid_glass_window_filleted_edge_count =
      generated_lid_glass_window_filleted_edge_count;
  metrics.native_generated_lid_circular_cutout_count =
      generated_lid_circular_cutout_count;
  metrics.native_generated_lid_rectangular_cutout_count =
      generated_lid_rectangular_cutout_count;
  metrics.native_generated_lid_rectangular_cutout_filleted_edge_count =
      generated_lid_rectangular_cutout_filleted_edge_count;
  metrics.native_generated_lid_sketch_add_count =
      generated_lid_sketch_add_count;
  metrics.native_generated_lid_sketch_add_filleted_edge_count =
      generated_lid_sketch_add_filleted_edge_count;
  metrics.native_generated_lid_button_group_count =
      generated_lid_button_group_count;
  metrics.native_generated_lid_button_cutout_count =
      generated_lid_button_cutout_count;
  metrics.native_generated_lid_button_ring_count =
      generated_lid_button_ring_count;
  metrics.native_generated_lid_button_cap_count =
      generated_lid_button_cap_count;
  metrics.native_generated_lid_button_stem_count =
      generated_lid_button_stem_count;
  metrics.native_generated_lid_button_guide_count =
      generated_lid_button_guide_count;
  metrics.native_generated_lid_button_travel_stop_count =
      generated_lid_button_travel_stop_count;
  metrics.feature_intent_count = feature_intent_count;
  metrics.native_feature_cut_count = feature_cuts.applied_cut_count;
  metrics.native_ignored_feature_intent_count =
      std::max(0,
               feature_intent_count - feature_cuts.applied_intent_count -
                   generated_lid_applied_intent_count);
  metrics.native_usb_c_cutout_count = feature_cuts.usb_c_cutout_count;
  metrics.native_usb_c_cutout_filleted_edge_count =
      feature_cuts.usb_c_filleted_edge_count;
  metrics.native_glass_recess_count = feature_cuts.glass_recess_count;
  metrics.native_glass_recess_filleted_edge_count =
      feature_cuts.glass_recess_filleted_edge_count;
  metrics.native_glass_window_count = feature_cuts.glass_window_count;
  metrics.native_glass_window_filleted_edge_count =
      feature_cuts.glass_window_filleted_edge_count;
  metrics.native_circular_cutout_count = feature_cuts.circular_cutout_count;
  metrics.native_rectangular_cutout_count = feature_cuts.rectangular_cutout_count;
  metrics.native_rectangular_cutout_filleted_edge_count =
      feature_cuts.rectangular_cutout_filleted_edge_count;
  metrics.native_sketch_add_count = feature_cuts.sketch_add_count;
  metrics.native_sketch_add_filleted_edge_count =
      feature_cuts.sketch_add_filleted_edge_count;
  metrics.native_button_group_count = feature_cuts.button_group_count;
  metrics.native_button_cutout_count = feature_cuts.button_cutout_count;
  metrics.native_button_ring_count = feature_cuts.button_ring_count;
  metrics.native_standoff_group_count = feature_cuts.standoff_group_count;
  metrics.native_standoff_mount_count = feature_cuts.standoff_mount_count;

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

std::array<double, 2> GlassRecessCenter(const EnclosureRequest& enclosure,
                                        const GlassRecessRequest& recess) {
  if (recess.has_surface_position) {
    return recess.surface_position;
  }

  return {0.0, enclosure.size[2] / 2.0};
}

bool GlassRecessFitsFrontSurface(const EnclosureRequest& enclosure,
                                 const GlassRecessRequest& recess,
                                 const std::array<double, 2>& center) {
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double min_z = enclosure.wall_thickness;
  const double max_z = enclosure.size[2] - enclosure.wall_thickness;
  const double tolerance = 0.000001;
  return center[0] - recess.width / 2.0 >= -inner_width / 2.0 - tolerance &&
         center[0] + recess.width / 2.0 <= inner_width / 2.0 + tolerance &&
         center[1] - recess.height / 2.0 >= min_z - tolerance &&
         center[1] + recess.height / 2.0 <= max_z + tolerance;
}

std::array<double, 2> GlassRecessTopLidCenter(
    const GlassRecessRequest& recess) {
  if (recess.has_surface_position) {
    return recess.surface_position;
  }

  return {0.0, 0.0};
}

bool GlassRecessFitsTopLidSurface(const EnclosureRequest& enclosure,
                                  const GlassRecessRequest& recess,
                                  const std::array<double, 2>& center) {
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_depth =
      enclosure.size[1] - enclosure.wall_thickness * 2.0;
  const double tolerance = 0.000001;
  return center[0] - recess.width / 2.0 >= -inner_width / 2.0 - tolerance &&
         center[0] + recess.width / 2.0 <= inner_width / 2.0 + tolerance &&
         center[1] - recess.height / 2.0 >= -inner_depth / 2.0 - tolerance &&
         center[1] + recess.height / 2.0 <= inner_depth / 2.0 + tolerance;
}

std::array<double, 2> CircularCutoutCenter(
    const EnclosureRequest& enclosure,
    const CircularCutoutRequest& cutout) {
  if (cutout.has_surface_position) {
    return cutout.surface_position;
  }

  if (cutout.target_surface == enclosure.id + ".front_wall.outer") {
    return {0.0, enclosure.size[2] / 2.0};
  }

  return {0.0, 0.0};
}

bool CircularCutoutFitsFrontSurface(
    const EnclosureRequest& enclosure,
    const CircularCutoutRequest& cutout,
    const std::array<double, 2>& center) {
  const double radius = cutout.diameter / 2.0;
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double min_z = enclosure.wall_thickness;
  const double max_z = enclosure.size[2] - enclosure.wall_thickness;
  const double tolerance = 0.000001;
  return center[0] - radius >= -inner_width / 2.0 - tolerance &&
         center[0] + radius <= inner_width / 2.0 + tolerance &&
         center[1] - radius >= min_z - tolerance &&
         center[1] + radius <= max_z + tolerance;
}

bool CircularCutoutFitsTopLidSurface(
    const EnclosureRequest& enclosure,
    const CircularCutoutRequest& cutout,
    const std::array<double, 2>& center) {
  const double radius = cutout.diameter / 2.0;
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_depth =
      enclosure.size[1] - enclosure.wall_thickness * 2.0;
  const double tolerance = 0.000001;
  return center[0] - radius >= -inner_width / 2.0 - tolerance &&
         center[0] + radius <= inner_width / 2.0 + tolerance &&
         center[1] - radius >= -inner_depth / 2.0 - tolerance &&
         center[1] + radius <= inner_depth / 2.0 + tolerance;
}

std::array<double, 2> RectangularCutoutCenter(
    const EnclosureRequest& enclosure,
    const RectangularCutoutRequest& cutout) {
  if (cutout.has_surface_position) {
    return cutout.surface_position;
  }

  if (cutout.target_surface == enclosure.id + ".front_wall.outer") {
    return {0.0, enclosure.size[2] / 2.0};
  }

  return {0.0, 0.0};
}

bool RectangularCutoutFitsFrontSurface(
    const EnclosureRequest& enclosure,
    const RectangularCutoutRequest& cutout,
    const std::array<double, 2>& center) {
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double min_z = enclosure.wall_thickness;
  const double max_z = enclosure.size[2] - enclosure.wall_thickness;
  const double tolerance = 0.000001;
  return RotatedRectangleFitsBounds(center,
                                    cutout.width,
                                    cutout.height,
                                    cutout.rotation_degrees,
                                    -inner_width / 2.0,
                                    inner_width / 2.0,
                                    min_z,
                                    max_z,
                                    tolerance);
}

bool RectangularCutoutFitsTopLidSurface(
    const EnclosureRequest& enclosure,
    const RectangularCutoutRequest& cutout,
    const std::array<double, 2>& center) {
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_depth =
      enclosure.size[1] - enclosure.wall_thickness * 2.0;
  const double tolerance = 0.000001;
  return RotatedRectangleFitsBounds(center,
                                    cutout.width,
                                    cutout.height,
                                    cutout.rotation_degrees,
                                    -inner_width / 2.0,
                                    inner_width / 2.0,
                                    -inner_depth / 2.0,
                                    inner_depth / 2.0,
                                    tolerance);
}

std::array<double, 2> SketchAddCenter(const EnclosureRequest& enclosure,
                                      const SketchAddRequest& add) {
  if (add.has_surface_position) {
    return add.surface_position;
  }

  if (add.target_surface == enclosure.id + ".front_wall.outer") {
    return {0.0, enclosure.size[2] / 2.0};
  }

  return {0.0, 0.0};
}

bool SketchAddFitsFrontSurface(const EnclosureRequest& enclosure,
                               const SketchAddRequest& add,
                               const std::array<double, 2>& center) {
  if (!IsPositiveDimension(add.protrusion) ||
      add.protrusion > kMaxSketchAddProtrusion) {
    return false;
  }

  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double min_z = enclosure.wall_thickness;
  const double max_z = enclosure.size[2] - enclosure.wall_thickness;
  const double tolerance = 0.000001;
  if (add.shape_type == "circle") {
    const double radius = add.diameter / 2.0;
    return IsPositiveDimension(add.diameter) &&
           center[0] - radius >= -inner_width / 2.0 - tolerance &&
           center[0] + radius <= inner_width / 2.0 + tolerance &&
           center[1] - radius >= min_z - tolerance &&
           center[1] + radius <= max_z + tolerance;
  }

  if (add.shape_type == "rectangle") {
    return RotatedRectangleFitsBounds(center,
                                      add.width,
                                      add.height,
                                      add.rotation_degrees,
                                      -inner_width / 2.0,
                                      inner_width / 2.0,
                                      min_z,
                                      max_z,
                                      tolerance);
  }

  return false;
}

bool SketchAddFitsTopLidSurface(const EnclosureRequest& enclosure,
                                const SketchAddRequest& add,
                                const std::array<double, 2>& center) {
  if (!IsPositiveDimension(add.protrusion) ||
      add.protrusion > kMaxSketchAddProtrusion) {
    return false;
  }

  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_depth =
      enclosure.size[1] - enclosure.wall_thickness * 2.0;
  const double tolerance = 0.000001;
  if (add.shape_type == "circle") {
    const double radius = add.diameter / 2.0;
    return IsPositiveDimension(add.diameter) &&
           center[0] - radius >= -inner_width / 2.0 - tolerance &&
           center[0] + radius <= inner_width / 2.0 + tolerance &&
           center[1] - radius >= -inner_depth / 2.0 - tolerance &&
           center[1] + radius <= inner_depth / 2.0 + tolerance;
  }

  if (add.shape_type == "rectangle") {
    return RotatedRectangleFitsBounds(center,
                                      add.width,
                                      add.height,
                                      add.rotation_degrees,
                                      -inner_width / 2.0,
                                      inner_width / 2.0,
                                      -inner_depth / 2.0,
                                      inner_depth / 2.0,
                                      tolerance);
  }

  return false;
}

double EffectiveCircularCutDepth(double requested_depth,
                                 double target_thickness,
                                 double overcut) {
  if (requested_depth >= target_thickness) {
    return target_thickness + overcut;
  }

  return requested_depth;
}

double EffectiveRectangularCutDepth(double requested_depth,
                                    double target_thickness,
                                    double overcut) {
  if (requested_depth >= target_thickness) {
    return target_thickness + overcut;
  }

  return requested_depth;
}

TopoDS_Shape RotateShapeAroundAxis(const TopoDS_Shape& shape,
                                   const gp_Ax1& axis,
                                   double rotation_degrees) {
  if (IsApproximatelyZero(rotation_degrees)) {
    return shape;
  }

  gp_Trsf rotation;
  rotation.SetRotation(axis, DegreesToRadians(rotation_degrees));
  BRepBuilderAPI_Transform transform(shape, rotation, true, false);
  const TopoDS_Shape rotated = transform.Shape();
  if (rotated.IsNull()) {
    throw std::runtime_error("OCCT generated a null rotated cutout tool.");
  }
  return rotated;
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

bool FaceIntersectsGlassRecess(const FaceBounds& face_bounds,
                               const ShapeMetrics& metrics,
                               const EnclosureRequest& enclosure,
                               const GlassRecessRequest& recess) {
  const std::array<double, 2> center = GlassRecessCenter(enclosure, recess);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double recess_min_x = center[0] - recess.width / 2.0 - tolerance;
  const double recess_max_x = center[0] + recess.width / 2.0 + tolerance;
  const double recess_min_z = center[1] - recess.height / 2.0 - tolerance;
  const double recess_max_z = center[1] + recess.height / 2.0 + tolerance;
  const double front_y = -enclosure.size[1] / 2.0;
  const double recess_min_y = front_y - tolerance;
  const double recess_max_y = front_y + recess.recess_depth + tolerance;
  const double window_width = recess.width - recess.ledge_width * 2.0;
  const double window_height = recess.height - recess.ledge_width * 2.0;

  const bool overlaps_recess_volume =
      face_bounds.max[0] >= recess_min_x &&
      face_bounds.min[0] <= recess_max_x &&
      face_bounds.max[1] >= recess_min_y &&
      face_bounds.min[1] <= recess_max_y &&
      face_bounds.max[2] >= recess_min_z &&
      face_bounds.min[2] <= recess_max_z;
  const bool is_inside_recess_outline =
      face_bounds.min[0] >= recess_min_x &&
      face_bounds.max[0] <= recess_max_x &&
      face_bounds.min[2] >= recess_min_z &&
      face_bounds.max[2] <= recess_max_z;
  const bool spans_recess_depth =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;
  const bool is_recess_back_face =
      FaceIsOnPlane(face_bounds.min[1],
                    face_bounds.max[1],
                    front_y + recess.recess_depth,
                    tolerance);
  const bool intersects_recess =
      overlaps_recess_volume && is_inside_recess_outline &&
      (spans_recess_depth || is_recess_back_face);

  if (!IsPositiveDimension(window_width) ||
      !IsPositiveDimension(window_height)) {
    return intersects_recess;
  }

  const double window_min_x = center[0] - window_width / 2.0 - tolerance;
  const double window_max_x = center[0] + window_width / 2.0 + tolerance;
  const double window_min_z = center[1] - window_height / 2.0 - tolerance;
  const double window_max_z = center[1] + window_height / 2.0 + tolerance;
  const double window_max_y =
      front_y + enclosure.wall_thickness + tolerance;
  const bool overlaps_window_volume =
      face_bounds.max[0] >= window_min_x &&
      face_bounds.min[0] <= window_max_x &&
      face_bounds.max[1] >= recess_min_y &&
      face_bounds.min[1] <= window_max_y &&
      face_bounds.max[2] >= window_min_z &&
      face_bounds.min[2] <= window_max_z;
  const bool is_inside_window_outline =
      face_bounds.min[0] >= window_min_x &&
      face_bounds.max[0] <= window_max_x &&
      face_bounds.min[2] >= window_min_z &&
      face_bounds.max[2] <= window_max_z;
  const bool spans_wall_depth =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;

  return intersects_recess ||
         (overlaps_window_volume && is_inside_window_outline &&
          spans_wall_depth);
}

bool FaceIntersectsCircularCutout(const FaceBounds& face_bounds,
                                  const ShapeMetrics& metrics,
                                  const EnclosureRequest& enclosure,
                                  const CircularCutoutRequest& cutout) {
  const std::array<double, 2> center =
      CircularCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = cutout.diameter / 2.0;
  const double cutout_min_x = center[0] - radius - tolerance;
  const double cutout_max_x = center[0] + radius + tolerance;
  const double cutout_min_z = center[1] - radius - tolerance;
  const double cutout_max_z = center[1] + radius + tolerance;
  const double front_y = -enclosure.size[1] / 2.0;
  const double cut_depth =
      std::min(cutout.depth, enclosure.wall_thickness);
  const double cutout_min_y = front_y - tolerance;
  const double cutout_max_y = front_y + cut_depth + tolerance;

  const bool overlaps_cutout_volume =
      face_bounds.max[0] >= cutout_min_x &&
      face_bounds.min[0] <= cutout_max_x &&
      face_bounds.max[1] >= cutout_min_y &&
      face_bounds.min[1] <= cutout_max_y &&
      face_bounds.max[2] >= cutout_min_z &&
      face_bounds.min[2] <= cutout_max_z;
  const bool is_inside_cutout_outline =
      face_bounds.min[0] >= cutout_min_x &&
      face_bounds.max[0] <= cutout_max_x &&
      face_bounds.min[2] >= cutout_min_z &&
      face_bounds.max[2] <= cutout_max_z;
  const bool spans_cut_depth =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;
  const bool is_cut_floor =
      FaceIsOnPlane(face_bounds.min[1],
                    face_bounds.max[1],
                    front_y + cut_depth,
                    tolerance);

  return overlaps_cutout_volume && is_inside_cutout_outline &&
         (spans_cut_depth || is_cut_floor);
}

bool FaceIntersectsRectangularCutout(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const RectangularCutoutRequest& cutout) {
  const std::array<double, 2> center =
      RectangularCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const std::array<double, 4> outline_bounds =
      RotatedRectangleBounds2D(center,
                               cutout.width,
                               cutout.height,
                               cutout.rotation_degrees,
                               tolerance);
  const double cutout_min_x = outline_bounds[0];
  const double cutout_max_x = outline_bounds[1];
  const double cutout_min_z = outline_bounds[2];
  const double cutout_max_z = outline_bounds[3];
  const double front_y = -enclosure.size[1] / 2.0;
  const double cut_depth =
      std::min(cutout.depth, enclosure.wall_thickness);
  const double cutout_min_y = front_y - tolerance;
  const double cutout_max_y = front_y + cut_depth + tolerance;

  const bool overlaps_cutout_volume =
      face_bounds.max[0] >= cutout_min_x &&
      face_bounds.min[0] <= cutout_max_x &&
      face_bounds.max[1] >= cutout_min_y &&
      face_bounds.min[1] <= cutout_max_y &&
      face_bounds.max[2] >= cutout_min_z &&
      face_bounds.min[2] <= cutout_max_z;
  const bool is_inside_cutout_outline =
      face_bounds.min[0] >= cutout_min_x &&
      face_bounds.max[0] <= cutout_max_x &&
      face_bounds.min[2] >= cutout_min_z &&
      face_bounds.max[2] <= cutout_max_z;
  const bool spans_cut_depth =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;
  const bool is_cut_floor =
      FaceIsOnPlane(face_bounds.min[1],
                    face_bounds.max[1],
                    front_y + cut_depth,
                    tolerance);

  return overlaps_cutout_volume && is_inside_cutout_outline &&
         (spans_cut_depth || is_cut_floor);
}

std::array<double, 4> SketchAddOutlineBounds2D(
    const std::array<double, 2>& center,
    const SketchAddRequest& add,
    double tolerance) {
  if (add.shape_type == "circle") {
    const double radius = add.diameter / 2.0;
    return {center[0] - radius - tolerance,
            center[0] + radius + tolerance,
            center[1] - radius - tolerance,
            center[1] + radius + tolerance};
  }

  return RotatedRectangleBounds2D(center,
                                  add.width,
                                  add.height,
                                  add.rotation_degrees,
                                  tolerance);
}

bool FaceIntersectsSketchAdd(const FaceBounds& face_bounds,
                             const ShapeMetrics& metrics,
                             const EnclosureRequest& enclosure,
                             const SketchAddRequest& add) {
  const std::array<double, 2> center = SketchAddCenter(enclosure, add);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const std::array<double, 4> outline_bounds =
      SketchAddOutlineBounds2D(center, add, tolerance);
  const double min_x = outline_bounds[0];
  const double max_x = outline_bounds[1];
  const double min_z = outline_bounds[2];
  const double max_z = outline_bounds[3];
  const double front_y = -enclosure.size[1] / 2.0;
  const double min_y = front_y - add.protrusion - tolerance;
  const double max_y = front_y + kSketchAddSurfaceOverlap + tolerance;

  const bool overlaps_volume =
      face_bounds.max[0] >= min_x &&
      face_bounds.min[0] <= max_x &&
      face_bounds.max[1] >= min_y &&
      face_bounds.min[1] <= max_y &&
      face_bounds.max[2] >= min_z &&
      face_bounds.min[2] <= max_z;
  const bool is_inside_outline =
      face_bounds.min[0] >= min_x &&
      face_bounds.max[0] <= max_x &&
      face_bounds.min[2] >= min_z &&
      face_bounds.max[2] <= max_z;
  const bool spans_protrusion =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;
  const bool is_outer_face =
      FaceIsOnPlane(face_bounds.min[1],
                    face_bounds.max[1],
                    front_y - add.protrusion,
                    tolerance);

  return overlaps_volume && is_inside_outline &&
         (spans_protrusion || is_outer_face);
}

std::array<double, 2> ButtonCutoutCenter(const EnclosureRequest& enclosure,
                                         const ButtonCutoutItemRequest& cutout) {
  return {cutout.position[0], enclosure.size[2] / 2.0 + cutout.position[1]};
}

double ButtonRingInnerRadius(const ButtonCutoutItemRequest& cutout) {
  return cutout.diameter / 2.0 + kButtonRingInnerClearance;
}

double ButtonRingOuterRadius(const ButtonCutoutItemRequest& cutout) {
  return ButtonRingInnerRadius(cutout) + cutout.ring_width;
}

double ButtonGuideInnerRadius(const ButtonCutoutItemRequest& cutout) {
  return cutout.stem_diameter / 2.0 + cutout.guide_clearance;
}

double ButtonGuideOuterRadius(const ButtonCutoutItemRequest& cutout) {
  return ButtonGuideInnerRadius(cutout) + kButtonGuideWallThickness;
}

double ButtonTravelStopOuterRadius(const ButtonCutoutItemRequest& cutout) {
  return std::min(cutout.cap_diameter / 2.0,
                  ButtonGuideInnerRadius(cutout) + kButtonTravelStopShoulder);
}

double ButtonGuideLength(const ButtonCutoutItemRequest& cutout) {
  return cutout.stem_depth - cutout.travel - cutout.switch_clearance;
}

double ButtonPlungerOuterRadius(const ButtonCutoutItemRequest& cutout) {
  return std::max(cutout.cap_diameter / 2.0,
                  std::max(ButtonGuideOuterRadius(cutout),
                           ButtonTravelStopOuterRadius(cutout)));
}

bool FaceIntersectsButtonCutout(const FaceBounds& face_bounds,
                                const ShapeMetrics& metrics,
                                const EnclosureRequest& enclosure,
                                const ButtonCutoutItemRequest& cutout) {
  const std::array<double, 2> center =
      ButtonCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = cutout.diameter / 2.0;
  const double cutout_min_x = center[0] - radius - tolerance;
  const double cutout_max_x = center[0] + radius + tolerance;
  const double cutout_min_z = center[1] - radius - tolerance;
  const double cutout_max_z = center[1] + radius + tolerance;
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
  const bool is_inside_cutout_outline =
      face_bounds.min[0] >= cutout_min_x &&
      face_bounds.max[0] <= cutout_max_x &&
      face_bounds.min[2] >= cutout_min_z &&
      face_bounds.max[2] <= cutout_max_z;
  const bool spans_wall_depth =
      face_bounds.max[1] - face_bounds.min[1] > tolerance;

  return overlaps_cutout_volume && is_inside_cutout_outline &&
         spans_wall_depth;
}

bool FaceIntersectsButtonRing(const FaceBounds& face_bounds,
                              const ShapeMetrics& metrics,
                              const EnclosureRequest& enclosure,
                              const ButtonCutoutItemRequest& cutout) {
  const std::array<double, 2> center =
      ButtonCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = ButtonRingOuterRadius(cutout);
  const double ring_min_x = center[0] - radius - tolerance;
  const double ring_max_x = center[0] + radius + tolerance;
  const double ring_min_z = center[1] - radius - tolerance;
  const double ring_max_z = center[1] + radius + tolerance;
  const double front_y = -enclosure.size[1] / 2.0;
  const double ring_min_y = front_y - cutout.ring_protrusion - tolerance;
  const double ring_max_y = front_y + kButtonRingSurfaceOverlap + tolerance;

  const bool overlaps_ring_volume =
      face_bounds.max[0] >= ring_min_x &&
      face_bounds.min[0] <= ring_max_x &&
      face_bounds.max[1] >= ring_min_y &&
      face_bounds.min[1] <= ring_max_y &&
      face_bounds.max[2] >= ring_min_z &&
      face_bounds.min[2] <= ring_max_z;
  const bool is_inside_ring_outline =
      face_bounds.min[0] >= ring_min_x &&
      face_bounds.max[0] <= ring_max_x &&
      face_bounds.min[2] >= ring_min_z &&
      face_bounds.max[2] <= ring_max_z;

  return overlaps_ring_volume && is_inside_ring_outline;
}

bool FaceIntersectsButtonPlunger(const FaceBounds& face_bounds,
                                 const ShapeMetrics& metrics,
                                 const EnclosureRequest& enclosure,
                                 const ButtonCutoutItemRequest& cutout) {
  if (!cutout.generate_plunger) {
    return false;
  }

  const std::array<double, 2> center =
      ButtonCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = ButtonPlungerOuterRadius(cutout);
  const double min_x = center[0] - radius - tolerance;
  const double max_x = center[0] + radius + tolerance;
  const double min_z = center[1] - radius - tolerance;
  const double max_z = center[1] + radius + tolerance;
  const double front_y = -enclosure.size[1] / 2.0;
  const double min_y =
      front_y - cutout.ring_protrusion - cutout.cap_height - tolerance;
  const double max_y = front_y + cutout.stem_depth + tolerance;

  const bool overlaps_volume =
      face_bounds.max[0] >= min_x &&
      face_bounds.min[0] <= max_x &&
      face_bounds.max[1] >= min_y &&
      face_bounds.min[1] <= max_y &&
      face_bounds.max[2] >= min_z &&
      face_bounds.min[2] <= max_z;
  const bool is_inside_outline =
      face_bounds.min[0] >= min_x &&
      face_bounds.max[0] <= max_x &&
      face_bounds.min[2] >= min_z &&
      face_bounds.max[2] <= max_z;

  return overlaps_volume && is_inside_outline;
}

bool FaceIntersectsStandoffMount(const FaceBounds& face_bounds,
                                 const ShapeMetrics& metrics,
                                 const EnclosureRequest& enclosure,
                                 const StandoffMountItemRequest& mount) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = mount.diameter / 2.0;
  const double mount_min_x = mount.position[0] - radius - tolerance;
  const double mount_max_x = mount.position[0] + radius + tolerance;
  const double mount_min_y = mount.position[1] - radius - tolerance;
  const double mount_max_y = mount.position[1] + radius + tolerance;
  const double mount_min_z = enclosure.wall_thickness - tolerance;
  const double mount_max_z =
      enclosure.wall_thickness + mount.height + tolerance;

  const bool overlaps_mount_volume =
      face_bounds.max[0] >= mount_min_x &&
      face_bounds.min[0] <= mount_max_x &&
      face_bounds.max[1] >= mount_min_y &&
      face_bounds.min[1] <= mount_max_y &&
      face_bounds.max[2] >= mount_min_z &&
      face_bounds.min[2] <= mount_max_z;
  const bool is_above_bottom_inside =
      face_bounds.max[2] >= enclosure.wall_thickness + tolerance;

  return overlaps_mount_volume && is_above_bottom_inside;
}

bool FaceIntersectsLidScrewBoss(const FaceBounds& face_bounds,
                                const ShapeMetrics& metrics,
                                const EnclosureRequest& enclosure,
                                const LidScrewBossRequest& boss) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = boss.diameter / 2.0;
  const double boss_min_x = boss.position[0] - radius - tolerance;
  const double boss_max_x = boss.position[0] + radius + tolerance;
  const double boss_min_y = boss.position[1] - radius - tolerance;
  const double boss_max_y = boss.position[1] + radius + tolerance;
  const double boss_min_z = enclosure.wall_thickness - tolerance;
  const double boss_max_z =
      enclosure.wall_thickness + boss.height + tolerance;

  const bool overlaps_boss_volume =
      face_bounds.max[0] >= boss_min_x &&
      face_bounds.min[0] <= boss_max_x &&
      face_bounds.max[1] >= boss_min_y &&
      face_bounds.min[1] <= boss_max_y &&
      face_bounds.max[2] >= boss_min_z &&
      face_bounds.min[2] <= boss_max_z;
  const bool is_above_bottom_inside =
      face_bounds.max[2] >= enclosure.wall_thickness + tolerance;

  return overlaps_boss_volume && is_above_bottom_inside;
}

bool FaceIntersectsGeneratedLidPlate(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double lid_min_x = -enclosure.size[0] / 2.0 - tolerance;
  const double lid_max_x = enclosure.size[0] / 2.0 + tolerance;
  const double lid_min_y = -enclosure.size[1] / 2.0 - tolerance;
  const double lid_max_y = enclosure.size[1] / 2.0 + tolerance;
  const double lid_min_z =
      enclosure.size[2] + lid_plate.preview_gap - tolerance;
  const double lid_max_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness +
      tolerance;

  return face_bounds.max[0] >= lid_min_x &&
         face_bounds.min[0] <= lid_max_x &&
         face_bounds.max[1] >= lid_min_y &&
         face_bounds.min[1] <= lid_max_y &&
         face_bounds.max[2] >= lid_min_z &&
         face_bounds.min[2] <= lid_max_z;
}

bool FaceIntersectsGeneratedLidLocatingLip(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double lip_width = GeneratedTopLidLipWidth(enclosure, lid_plate);
  const double lip_overlap = 0.2;
  const std::array<double, 2> outer_size = {
      enclosure.size[0] -
          (enclosure.wall_thickness + lid_plate.lip_clearance) * 2.0,
      enclosure.size[1] -
          (enclosure.wall_thickness + lid_plate.lip_clearance) * 2.0};
  const std::array<double, 2> inner_size = {
      outer_size[0] - lip_width * 2.0,
      outer_size[1] - lip_width * 2.0};
  if (!IsPositiveDimension(lip_width) ||
      !IsPositiveDimension(outer_size[0]) ||
      !IsPositiveDimension(outer_size[1]) ||
      !IsPositiveDimension(inner_size[0]) ||
      !IsPositiveDimension(inner_size[1])) {
    return false;
  }

  const double lip_min_x = -outer_size[0] / 2.0 - tolerance;
  const double lip_max_x = outer_size[0] / 2.0 + tolerance;
  const double lip_min_y = -outer_size[1] / 2.0 - tolerance;
  const double lip_max_y = outer_size[1] / 2.0 + tolerance;
  const double lip_min_z =
      enclosure.size[2] + lid_plate.preview_gap - lid_plate.lip_height -
      tolerance;
  const double lip_max_z =
      enclosure.size[2] + lid_plate.preview_gap + lip_overlap + tolerance;

  const bool overlaps_lip_volume =
      face_bounds.max[0] >= lip_min_x &&
      face_bounds.min[0] <= lip_max_x &&
      face_bounds.max[1] >= lip_min_y &&
      face_bounds.min[1] <= lip_max_y &&
      face_bounds.max[2] >= lip_min_z &&
      face_bounds.min[2] <= lip_max_z;
  const bool sits_inside_open_lip_hole =
      face_bounds.min[0] > -inner_size[0] / 2.0 + tolerance &&
      face_bounds.max[0] < inner_size[0] / 2.0 - tolerance &&
      face_bounds.min[1] > -inner_size[1] / 2.0 + tolerance &&
      face_bounds.max[1] < inner_size[1] / 2.0 - tolerance;

  return overlaps_lip_volume && !sits_inside_open_lip_hole;
}

bool FaceIntersectsGeneratedLidSeat(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidSeatRequest& seat) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double depth =
      std::min(seat.depth, enclosure.wall_thickness - 0.2);
  const double inner_width =
      enclosure.size[0] - enclosure.wall_thickness * 2.0;
  const double inner_depth =
      enclosure.size[1] - enclosure.wall_thickness * 2.0;
  if (!IsPositiveDimension(depth) ||
      !IsPositiveDimension(seat.height) ||
      !IsPositiveDimension(inner_width) ||
      !IsPositiveDimension(inner_depth)) {
    return false;
  }

  const double min_z = enclosure.size[2] - seat.height - tolerance;
  const double max_z = enclosure.size[2] + tolerance;
  const bool overlaps_height =
      face_bounds.max[2] >= min_z && face_bounds.min[2] <= max_z;
  if (!overlaps_height) {
    return false;
  }

  const double inner_x = inner_width / 2.0;
  const double inner_y = inner_depth / 2.0;
  const bool near_left =
      face_bounds.max[0] >= -inner_x - depth - tolerance &&
      face_bounds.min[0] <= -inner_x + tolerance &&
      face_bounds.max[1] >= -inner_y - depth - tolerance &&
      face_bounds.min[1] <= inner_y + depth + tolerance;
  const bool near_right =
      face_bounds.max[0] >= inner_x - tolerance &&
      face_bounds.min[0] <= inner_x + depth + tolerance &&
      face_bounds.max[1] >= -inner_y - depth - tolerance &&
      face_bounds.min[1] <= inner_y + depth + tolerance;
  const bool near_front =
      face_bounds.max[1] >= -inner_y - depth - tolerance &&
      face_bounds.min[1] <= -inner_y + tolerance &&
      face_bounds.max[0] >= -inner_x - depth - tolerance &&
      face_bounds.min[0] <= inner_x + depth + tolerance;
  const bool near_back =
      face_bounds.max[1] >= inner_y - tolerance &&
      face_bounds.min[1] <= inner_y + depth + tolerance &&
      face_bounds.max[0] >= -inner_x - depth - tolerance &&
      face_bounds.min[0] <= inner_x + depth + tolerance;

  return near_left || near_right || near_front || near_back;
}

bool FaceIntersectsGeneratedLidScrewHole(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const LidScrewBossRequest& boss) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double clearance_diameter =
      GeneratedTopLidScrewClearanceDiameter(boss);
  const double radius = clearance_diameter / 2.0;
  const double hole_min_x = boss.position[0] - radius - tolerance;
  const double hole_max_x = boss.position[0] + radius + tolerance;
  const double hole_min_y = boss.position[1] - radius - tolerance;
  const double hole_max_y = boss.position[1] + radius + tolerance;
  const double lid_min_z =
      enclosure.size[2] + lid_plate.preview_gap - tolerance;
  const double lid_max_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness +
      tolerance;

  const bool overlaps_hole_volume =
      face_bounds.max[0] >= hole_min_x &&
      face_bounds.min[0] <= hole_max_x &&
      face_bounds.max[1] >= hole_min_y &&
      face_bounds.min[1] <= hole_max_y &&
      face_bounds.max[2] >= lid_min_z &&
      face_bounds.min[2] <= lid_max_z;
  const bool stays_near_hole_outline =
      face_bounds.max[0] - face_bounds.min[0] <=
          clearance_diameter + tolerance * 2.0 &&
      face_bounds.max[1] - face_bounds.min[1] <=
          clearance_diameter + tolerance * 2.0;
  const bool spans_lid_thickness =
      face_bounds.max[2] - face_bounds.min[2] >=
      lid_plate.thickness - tolerance * 2.0;

  return overlaps_hole_volume && stays_near_hole_outline &&
         spans_lid_thickness;
}

bool FaceIntersectsGeneratedTopLidButtonCutout(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = cutout.diameter / 2.0;
  const double cutout_min_x = cutout.position[0] - radius - tolerance;
  const double cutout_max_x = cutout.position[0] + radius + tolerance;
  const double cutout_min_y = cutout.position[1] - radius - tolerance;
  const double cutout_max_y = cutout.position[1] + radius + tolerance;
  const double lid_min_z =
      enclosure.size[2] + lid_plate.preview_gap - tolerance;
  const double lid_max_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness +
      tolerance;

  const bool overlaps_cutout_volume =
      face_bounds.max[0] >= cutout_min_x &&
      face_bounds.min[0] <= cutout_max_x &&
      face_bounds.max[1] >= cutout_min_y &&
      face_bounds.min[1] <= cutout_max_y &&
      face_bounds.max[2] >= lid_min_z &&
      face_bounds.min[2] <= lid_max_z;
  const bool stays_near_cutout_outline =
      face_bounds.max[0] - face_bounds.min[0] <=
          cutout.diameter + tolerance * 2.0 &&
      face_bounds.max[1] - face_bounds.min[1] <=
          cutout.diameter + tolerance * 2.0;
  const bool spans_lid_thickness =
      face_bounds.max[2] - face_bounds.min[2] >=
      lid_plate.thickness - tolerance * 2.0;

  return overlaps_cutout_volume && stays_near_cutout_outline &&
         spans_lid_thickness;
}

bool FaceIntersectsGeneratedTopLidCircularCutout(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const CircularCutoutRequest& cutout) {
  const std::array<double, 2> center =
      CircularCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = cutout.diameter / 2.0;
  const double cutout_min_x = center[0] - radius - tolerance;
  const double cutout_max_x = center[0] + radius + tolerance;
  const double cutout_min_y = center[1] - radius - tolerance;
  const double cutout_max_y = center[1] + radius + tolerance;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double cut_depth =
      std::min(cutout.depth, lid_plate.thickness);
  const double cutout_min_z = lid_top_z - cut_depth - tolerance;
  const double cutout_max_z = lid_top_z + tolerance;

  const bool overlaps_cutout_volume =
      face_bounds.max[0] >= cutout_min_x &&
      face_bounds.min[0] <= cutout_max_x &&
      face_bounds.max[1] >= cutout_min_y &&
      face_bounds.min[1] <= cutout_max_y &&
      face_bounds.max[2] >= cutout_min_z &&
      face_bounds.min[2] <= cutout_max_z;
  const bool stays_near_cutout_outline =
      face_bounds.max[0] - face_bounds.min[0] <=
          cutout.diameter + tolerance * 2.0 &&
      face_bounds.max[1] - face_bounds.min[1] <=
          cutout.diameter + tolerance * 2.0;
  const bool spans_cut_depth =
      face_bounds.max[2] - face_bounds.min[2] > tolerance;
  const bool is_cut_floor =
      FaceIsOnPlane(face_bounds.min[2],
                    face_bounds.max[2],
                    lid_top_z - cut_depth,
                    tolerance);

  return overlaps_cutout_volume && stays_near_cutout_outline &&
         (spans_cut_depth || is_cut_floor);
}

bool FaceIntersectsGeneratedTopLidRectangularCutout(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const RectangularCutoutRequest& cutout) {
  const std::array<double, 2> center =
      RectangularCutoutCenter(enclosure, cutout);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const std::array<double, 4> outline_bounds =
      RotatedRectangleBounds2D(center,
                               cutout.width,
                               cutout.height,
                               cutout.rotation_degrees,
                               tolerance);
  const double cutout_min_x = outline_bounds[0];
  const double cutout_max_x = outline_bounds[1];
  const double cutout_min_y = outline_bounds[2];
  const double cutout_max_y = outline_bounds[3];
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double cut_depth =
      std::min(cutout.depth, lid_plate.thickness);
  const double cutout_min_z = lid_top_z - cut_depth - tolerance;
  const double cutout_max_z = lid_top_z + tolerance;

  const bool overlaps_cutout_volume =
      face_bounds.max[0] >= cutout_min_x &&
      face_bounds.min[0] <= cutout_max_x &&
      face_bounds.max[1] >= cutout_min_y &&
      face_bounds.min[1] <= cutout_max_y &&
      face_bounds.max[2] >= cutout_min_z &&
      face_bounds.min[2] <= cutout_max_z;
  const bool is_inside_cutout_outline =
      face_bounds.min[0] >= cutout_min_x &&
      face_bounds.max[0] <= cutout_max_x &&
      face_bounds.min[1] >= cutout_min_y &&
      face_bounds.max[1] <= cutout_max_y;
  const bool spans_cut_depth =
      face_bounds.max[2] - face_bounds.min[2] > tolerance;
  const bool is_cut_floor =
      FaceIsOnPlane(face_bounds.min[2],
                    face_bounds.max[2],
                    lid_top_z - cut_depth,
                    tolerance);

  return overlaps_cutout_volume && is_inside_cutout_outline &&
         (spans_cut_depth || is_cut_floor);
}

bool FaceIntersectsGeneratedTopLidSketchAdd(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const SketchAddRequest& add) {
  const std::array<double, 2> center = SketchAddCenter(enclosure, add);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const std::array<double, 4> outline_bounds =
      SketchAddOutlineBounds2D(center, add, tolerance);
  const double min_x = outline_bounds[0];
  const double max_x = outline_bounds[1];
  const double min_y = outline_bounds[2];
  const double max_y = outline_bounds[3];
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double min_z = lid_top_z - kSketchAddSurfaceOverlap - tolerance;
  const double max_z = lid_top_z + add.protrusion + tolerance;

  const bool overlaps_volume =
      face_bounds.max[0] >= min_x &&
      face_bounds.min[0] <= max_x &&
      face_bounds.max[1] >= min_y &&
      face_bounds.min[1] <= max_y &&
      face_bounds.max[2] >= min_z &&
      face_bounds.min[2] <= max_z;
  const bool is_inside_outline =
      face_bounds.min[0] >= min_x &&
      face_bounds.max[0] <= max_x &&
      face_bounds.min[1] >= min_y &&
      face_bounds.max[1] <= max_y;
  const bool spans_protrusion =
      face_bounds.max[2] - face_bounds.min[2] > tolerance;
  const bool is_outer_face =
      FaceIsOnPlane(face_bounds.min[2],
                    face_bounds.max[2],
                    lid_top_z + add.protrusion,
                    tolerance);

  return overlaps_volume && is_inside_outline &&
         (spans_protrusion || is_outer_face);
}

bool FaceIntersectsGeneratedTopLidButtonRing(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout) {
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = ButtonRingOuterRadius(cutout);
  const double ring_min_x = cutout.position[0] - radius - tolerance;
  const double ring_max_x = cutout.position[0] + radius + tolerance;
  const double ring_min_y = cutout.position[1] - radius - tolerance;
  const double ring_max_y = cutout.position[1] + radius + tolerance;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double ring_min_z =
      lid_top_z - kButtonRingSurfaceOverlap - tolerance;
  const double ring_max_z = lid_top_z + cutout.ring_protrusion + tolerance;

  const bool overlaps_ring_volume =
      face_bounds.max[0] >= ring_min_x &&
      face_bounds.min[0] <= ring_max_x &&
      face_bounds.max[1] >= ring_min_y &&
      face_bounds.min[1] <= ring_max_y &&
      face_bounds.max[2] >= ring_min_z &&
      face_bounds.min[2] <= ring_max_z;
  const bool is_inside_ring_outline =
      face_bounds.min[0] >= ring_min_x &&
      face_bounds.max[0] <= ring_max_x &&
      face_bounds.min[1] >= ring_min_y &&
      face_bounds.max[1] <= ring_max_y;

  return overlaps_ring_volume && is_inside_ring_outline;
}

bool FaceIntersectsGeneratedTopLidButtonPlunger(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout) {
  if (!cutout.generate_plunger) {
    return false;
  }

  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double radius = ButtonPlungerOuterRadius(cutout);
  const double min_x = cutout.position[0] - radius - tolerance;
  const double max_x = cutout.position[0] + radius + tolerance;
  const double min_y = cutout.position[1] - radius - tolerance;
  const double max_y = cutout.position[1] + radius + tolerance;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double min_z =
      lid_top_z + cutout.ring_protrusion - cutout.stem_depth - tolerance;
  const double max_z =
      lid_top_z + cutout.ring_protrusion + cutout.cap_height + tolerance;

  const bool overlaps_volume =
      face_bounds.max[0] >= min_x &&
      face_bounds.min[0] <= max_x &&
      face_bounds.max[1] >= min_y &&
      face_bounds.min[1] <= max_y &&
      face_bounds.max[2] >= min_z &&
      face_bounds.min[2] <= max_z;
  const bool is_inside_outline =
      face_bounds.min[0] >= min_x &&
      face_bounds.max[0] <= max_x &&
      face_bounds.min[1] >= min_y &&
      face_bounds.max[1] <= max_y;

  return overlaps_volume && is_inside_outline;
}

bool FaceIntersectsGeneratedTopLidGlassRecess(
    const FaceBounds& face_bounds,
    const ShapeMetrics& metrics,
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const GlassRecessRequest& recess) {
  const std::array<double, 2> center = GlassRecessTopLidCenter(recess);
  const double tolerance = PreviewSurfaceTolerance(metrics);
  const double recess_min_x = center[0] - recess.width / 2.0 - tolerance;
  const double recess_max_x = center[0] + recess.width / 2.0 + tolerance;
  const double recess_min_y = center[1] - recess.height / 2.0 - tolerance;
  const double recess_max_y = center[1] + recess.height / 2.0 + tolerance;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double recess_min_z = lid_top_z - recess.recess_depth - tolerance;
  const double recess_max_z = lid_top_z + tolerance;

  const bool overlaps_recess_volume =
      face_bounds.max[0] >= recess_min_x &&
      face_bounds.min[0] <= recess_max_x &&
      face_bounds.max[1] >= recess_min_y &&
      face_bounds.min[1] <= recess_max_y &&
      face_bounds.max[2] >= recess_min_z &&
      face_bounds.min[2] <= recess_max_z;
  const bool is_inside_recess_outline =
      face_bounds.min[0] >= recess_min_x &&
      face_bounds.max[0] <= recess_max_x &&
      face_bounds.min[1] >= recess_min_y &&
      face_bounds.max[1] <= recess_max_y;
  const bool spans_recess_depth =
      face_bounds.max[2] - face_bounds.min[2] > tolerance;
  const bool is_recess_floor =
      FaceIsOnPlane(face_bounds.min[2],
                    face_bounds.max[2],
                    lid_top_z - recess.recess_depth,
                    tolerance);

  return overlaps_recess_volume && is_inside_recess_outline &&
         (spans_recess_depth || is_recess_floor);
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

TopoDS_Shape BuildButtonCutoutTool(const EnclosureRequest& enclosure,
                                   const ButtonCutoutItemRequest& cutout) {
  const std::array<double, 2> center =
      ButtonCutoutCenter(enclosure, cutout);
  const double overcut = 2.0;
  const double height = enclosure.wall_thickness + overcut * 2.0;
  const gp_Ax2 axis(
      gp_Pnt(center[0], -enclosure.size[1] / 2.0 - overcut, center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  return BRepPrimAPI_MakeCylinder(axis, cutout.diameter / 2.0, height).Shape();
}

TopoDS_Shape BuildButtonRingShape(const EnclosureRequest& enclosure,
                                  const ButtonCutoutItemRequest& cutout) {
  const std::array<double, 2> center =
      ButtonCutoutCenter(enclosure, cutout);
  const double front_y = -enclosure.size[1] / 2.0;
  const double ring_height =
      cutout.ring_protrusion + kButtonRingSurfaceOverlap;
  const gp_Ax2 outer_axis(
      gp_Pnt(center[0], front_y - cutout.ring_protrusion, center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape outer =
      BRepPrimAPI_MakeCylinder(outer_axis,
                               ButtonRingOuterRadius(cutout),
                               ring_height)
          .Shape();
  if (outer.IsNull()) {
    throw std::runtime_error("OCCT generated a null button ring outer shape.");
  }

  const gp_Ax2 inner_axis(
      gp_Pnt(center[0],
             front_y - cutout.ring_protrusion - kButtonRingCutOverrun,
             center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape inner =
      BRepPrimAPI_MakeCylinder(inner_axis,
                               ButtonRingInnerRadius(cutout),
                               ring_height + kButtonRingCutOverrun * 2.0)
          .Shape();
  if (inner.IsNull()) {
    throw std::runtime_error("OCCT generated a null button ring inner tool.");
  }

  BRepAlgoAPI_Cut ring_cut(outer, inner);
  ring_cut.SimplifyResult(true, true);
  if (!ring_cut.IsDone() || ring_cut.HasErrors()) {
    throw std::runtime_error("OCCT button ring cut did not complete.");
  }

  const TopoDS_Shape ring = ring_cut.Shape();
  if (ring.IsNull()) {
    throw std::runtime_error("OCCT generated a null button ring shape.");
  }

  BRepCheck_Analyzer analyzer(ring, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid button ring shape.");
  }

  return ring;
}

TopoDS_Shape BuildAnnularCylinderShape(const gp_Ax2& axis,
                                       double outer_radius,
                                       double inner_radius,
                                       double height,
                                       const std::string& label) {
  const TopoDS_Shape outer =
      BRepPrimAPI_MakeCylinder(axis, outer_radius, height).Shape();
  if (outer.IsNull()) {
    throw std::runtime_error("OCCT generated a null " + label +
                             " outer shape.");
  }

  const gp_Vec backwards(axis.Direction());
  const gp_Ax2 inner_axis(
      axis.Location().Translated(backwards.Multiplied(-kButtonRingCutOverrun)),
      axis.Direction());
  const TopoDS_Shape inner =
      BRepPrimAPI_MakeCylinder(inner_axis,
                               inner_radius,
                               height + kButtonRingCutOverrun * 2.0)
          .Shape();
  if (inner.IsNull()) {
    throw std::runtime_error("OCCT generated a null " + label + " inner tool.");
  }

  BRepAlgoAPI_Cut cut(outer, inner);
  cut.SimplifyResult(true, true);
  if (!cut.IsDone() || cut.HasErrors()) {
    throw std::runtime_error("OCCT " + label + " cut did not complete.");
  }

  const TopoDS_Shape shape = cut.Shape();
  if (shape.IsNull()) {
    throw std::runtime_error("OCCT generated a null " + label + ".");
  }

  BRepCheck_Analyzer analyzer(shape, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid " + label + ".");
  }

  return shape;
}

TopoDS_Shape BuildButtonPlungerShape(const EnclosureRequest& enclosure,
                                     const ButtonCutoutItemRequest& cutout) {
  if (!cutout.generate_plunger) {
    return TopoDS_Shape();
  }

  const std::array<double, 2> center =
      ButtonCutoutCenter(enclosure, cutout);
  const double front_y = -enclosure.size[1] / 2.0;
  const gp_Ax2 cap_axis(
      gp_Pnt(center[0],
             front_y - cutout.ring_protrusion - cutout.cap_height,
             center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape cap =
      BRepPrimAPI_MakeCylinder(cap_axis,
                               cutout.cap_diameter / 2.0,
                               cutout.cap_height + kButtonCapStemOverlap)
          .Shape();
  if (cap.IsNull()) {
    throw std::runtime_error("OCCT generated a null button cap shape.");
  }

  const gp_Ax2 stem_axis(
      gp_Pnt(center[0],
             front_y - cutout.ring_protrusion - kButtonCapStemOverlap,
             center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape stem =
      BRepPrimAPI_MakeCylinder(stem_axis,
                               cutout.stem_diameter / 2.0,
                               cutout.stem_depth + kButtonCapStemOverlap)
          .Shape();
  if (stem.IsNull()) {
    throw std::runtime_error("OCCT generated a null button stem shape.");
  }

  const double guide_length = ButtonGuideLength(cutout);
  const gp_Ax2 guide_axis(
      gp_Pnt(center[0], front_y + cutout.switch_clearance, center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape guide =
      BuildAnnularCylinderShape(guide_axis,
                                ButtonGuideOuterRadius(cutout),
                                ButtonGuideInnerRadius(cutout),
                                guide_length,
                                "front button guide sleeve");

  const gp_Ax2 stop_axis(
      gp_Pnt(center[0],
             front_y + cutout.switch_clearance + guide_length,
             center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape travel_stop =
      BRepPrimAPI_MakeCylinder(stop_axis,
                               ButtonTravelStopOuterRadius(cutout),
                               kButtonTravelStopThickness)
          .Shape();
  if (travel_stop.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null button travel stop shape.");
  }

  BRep_Builder builder;
  TopoDS_Compound compound;
  builder.MakeCompound(compound);
  builder.Add(compound, cap);
  builder.Add(compound, stem);
  builder.Add(compound, guide);
  builder.Add(compound, travel_stop);

  BRepCheck_Analyzer analyzer(compound, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid button plunger shape.");
  }

  return compound;
}

TopoDS_Shape BuildGeneratedTopLidButtonCutoutTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout) {
  const double overcut = 0.5;
  const gp_Ax2 axis(
      gp_Pnt(cutout.position[0],
             cutout.position[1],
             enclosure.size[2] + lid_plate.preview_gap - overcut),
      gp_Dir(0.0, 0.0, 1.0));
  return BRepPrimAPI_MakeCylinder(axis,
                                  cutout.diameter / 2.0,
                                  lid_plate.thickness + overcut * 2.0)
      .Shape();
}

TopoDS_Shape BuildGeneratedTopLidButtonRingShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout) {
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double ring_height =
      cutout.ring_protrusion + kButtonRingSurfaceOverlap;
  const gp_Ax2 outer_axis(
      gp_Pnt(cutout.position[0],
             cutout.position[1],
             lid_top_z - kButtonRingSurfaceOverlap),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape outer =
      BRepPrimAPI_MakeCylinder(outer_axis,
                               ButtonRingOuterRadius(cutout),
                               ring_height)
          .Shape();
  if (outer.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid button ring outer shape.");
  }

  const gp_Ax2 inner_axis(
      gp_Pnt(cutout.position[0],
             cutout.position[1],
             lid_top_z - kButtonRingSurfaceOverlap - kButtonRingCutOverrun),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape inner =
      BRepPrimAPI_MakeCylinder(inner_axis,
                               ButtonRingInnerRadius(cutout),
                               ring_height + kButtonRingCutOverrun * 2.0)
          .Shape();
  if (inner.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid button ring inner tool.");
  }

  BRepAlgoAPI_Cut ring_cut(outer, inner);
  ring_cut.SimplifyResult(true, true);
  if (!ring_cut.IsDone() || ring_cut.HasErrors()) {
    throw std::runtime_error("OCCT top lid button ring cut did not complete.");
  }

  const TopoDS_Shape ring = ring_cut.Shape();
  if (ring.IsNull()) {
    throw std::runtime_error("OCCT generated a null top lid button ring.");
  }

  BRepCheck_Analyzer analyzer(ring, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error(
        "OCCT generated an invalid top lid button ring.");
  }

  return ring;
}

TopoDS_Shape BuildGeneratedTopLidButtonPlungerShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const ButtonCutoutItemRequest& cutout) {
  if (!cutout.generate_plunger) {
    return TopoDS_Shape();
  }

  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double cap_bottom_z = lid_top_z + cutout.ring_protrusion;
  const gp_Ax2 cap_axis(gp_Pnt(cutout.position[0],
                               cutout.position[1],
                               cap_bottom_z),
                        gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape cap =
      BRepPrimAPI_MakeCylinder(cap_axis,
                               cutout.cap_diameter / 2.0,
                               cutout.cap_height)
          .Shape();
  if (cap.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid button cap shape.");
  }

  const gp_Ax2 stem_axis(
      gp_Pnt(cutout.position[0],
             cutout.position[1],
             cap_bottom_z - cutout.stem_depth),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape stem =
      BRepPrimAPI_MakeCylinder(stem_axis,
                               cutout.stem_diameter / 2.0,
                               cutout.stem_depth + kButtonCapStemOverlap)
          .Shape();
  if (stem.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid button stem shape.");
  }

  const double guide_length = ButtonGuideLength(cutout);
  const double guide_start_z =
      cap_bottom_z - cutout.stem_depth + cutout.switch_clearance;
  const gp_Ax2 guide_axis(gp_Pnt(cutout.position[0],
                                 cutout.position[1],
                                 guide_start_z),
                          gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape guide =
      BuildAnnularCylinderShape(guide_axis,
                                ButtonGuideOuterRadius(cutout),
                                ButtonGuideInnerRadius(cutout),
                                guide_length,
                                "top lid button guide sleeve");

  const gp_Ax2 stop_axis(gp_Pnt(cutout.position[0],
                                cutout.position[1],
                                guide_start_z + guide_length),
                         gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape travel_stop =
      BRepPrimAPI_MakeCylinder(stop_axis,
                               ButtonTravelStopOuterRadius(cutout),
                               kButtonTravelStopThickness)
          .Shape();
  if (travel_stop.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid button travel stop shape.");
  }

  BRep_Builder builder;
  TopoDS_Compound compound;
  builder.MakeCompound(compound);
  builder.Add(compound, cap);
  builder.Add(compound, stem);
  builder.Add(compound, guide);
  builder.Add(compound, travel_stop);

  BRepCheck_Analyzer analyzer(compound, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error(
        "OCCT generated an invalid top lid button plunger shape.");
  }

  return compound;
}

TopoDS_Shape BuildStandoffMountShape(const EnclosureRequest& enclosure,
                                     const StandoffMountItemRequest& mount) {
  const double overlap = 0.05;
  const gp_Ax2 boss_axis(
      gp_Pnt(mount.position[0],
             mount.position[1],
             enclosure.wall_thickness - overlap),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape boss =
      BRepPrimAPI_MakeCylinder(boss_axis,
                               mount.diameter / 2.0,
                               mount.height + overlap)
          .Shape();
  if (boss.IsNull()) {
    throw std::runtime_error("OCCT generated a null standoff boss.");
  }

  const double hole_overcut = 0.5;
  const gp_Ax2 hole_axis(
      gp_Pnt(mount.position[0],
             mount.position[1],
             enclosure.wall_thickness - overlap - hole_overcut),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape hole_tool =
      BRepPrimAPI_MakeCylinder(hole_axis,
                               mount.hole_diameter / 2.0,
                               mount.height + overlap + hole_overcut * 2.0)
          .Shape();
  if (hole_tool.IsNull()) {
    throw std::runtime_error("OCCT generated a null standoff hole tool.");
  }

  BRepAlgoAPI_Cut cut(boss, hole_tool);
  cut.SimplifyResult(true, true);
  if (!cut.IsDone() || cut.HasErrors()) {
    throw std::runtime_error("OCCT standoff hole cut did not complete.");
  }

  const TopoDS_Shape mount_shape = cut.Shape();
  if (mount_shape.IsNull()) {
    throw std::runtime_error("OCCT generated a null standoff mount.");
  }

  BRepCheck_Analyzer analyzer(mount_shape, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid standoff mount.");
  }

  return mount_shape;
}

TopoDS_Shape BuildLidScrewBossShape(const EnclosureRequest& enclosure,
                                    const LidScrewBossRequest& boss) {
  const double overlap = 0.05;
  const gp_Ax2 boss_axis(
      gp_Pnt(boss.position[0],
             boss.position[1],
             enclosure.wall_thickness - overlap),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape outer_boss =
      BRepPrimAPI_MakeCylinder(boss_axis,
                               boss.diameter / 2.0,
                               boss.height + overlap)
          .Shape();
  if (outer_boss.IsNull()) {
    throw std::runtime_error("OCCT generated a null lid screw boss.");
  }

  const double hole_overcut = 0.5;
  const gp_Ax2 pilot_axis(
      gp_Pnt(boss.position[0],
             boss.position[1],
             enclosure.wall_thickness - overlap - hole_overcut),
      gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape pilot_tool =
      BRepPrimAPI_MakeCylinder(pilot_axis,
                               boss.hole_diameter / 2.0,
                               boss.height + overlap + hole_overcut * 2.0)
          .Shape();
  if (pilot_tool.IsNull()) {
    throw std::runtime_error("OCCT generated a null lid screw pilot tool.");
  }

  BRepAlgoAPI_Cut cut(outer_boss, pilot_tool);
  cut.SimplifyResult(true, true);
  if (!cut.IsDone() || cut.HasErrors()) {
    throw std::runtime_error("OCCT lid screw boss pilot cut did not complete.");
  }

  const TopoDS_Shape boss_shape = cut.Shape();
  if (boss_shape.IsNull()) {
    throw std::runtime_error("OCCT generated a null lid screw boss shape.");
  }

  BRepCheck_Analyzer analyzer(boss_shape, false);
  if (!analyzer.IsValid()) {
    throw std::runtime_error("OCCT generated an invalid lid screw boss.");
  }

  return boss_shape;
}

NativeLidBossResult ApplyNativeLidScrewBosses(
    const TopoDS_Shape& base_shape,
    const EnclosureRequest& enclosure,
    const std::vector<LidScrewBossRequest>& bosses) {
  NativeLidBossResult result;
  result.shape = base_shape;

  for (const LidScrewBossRequest& boss : bosses) {
    const TopoDS_Shape boss_shape = BuildLidScrewBossShape(enclosure, boss);
    if (boss_shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null lid screw boss shape.");
    }

    BRepAlgoAPI_Fuse fuse(result.shape, boss_shape);
    fuse.SimplifyResult(true, true);
    if (!fuse.IsDone() || fuse.HasErrors()) {
      throw std::runtime_error("OCCT lid screw boss fuse did not complete.");
    }

    result.shape = fuse.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null lid screw boss fuse.");
    }

    BRepCheck_Analyzer analyzer(result.shape, false);
    if (!analyzer.IsValid()) {
      throw std::runtime_error("OCCT generated an invalid lid screw boss fuse.");
    }

    ++result.boss_count;
    ++result.pilot_hole_count;
  }

  return result;
}

TopoDS_Shape BuildGlassRecessTool(const EnclosureRequest& enclosure,
                                  const GlassRecessRequest& recess,
                                  int* filleted_edge_count) {
  const std::array<double, 2> center =
      GlassRecessCenter(enclosure, recess);
  const double overcut = 0.2;
  const std::array<double, 3> tool_size = {
      recess.width,
      recess.recess_depth + overcut,
      recess.height};
  const gp_Pnt tool_origin(center[0] - recess.width / 2.0,
                           -enclosure.size[1] / 2.0 - overcut,
                           center[1] - recess.height / 2.0);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(tool_origin,
                          tool_size[0],
                          tool_size[1],
                          tool_size[2])
          .Shape();

  *filleted_edge_count = 0;
  const double safe_radius =
      std::min(recess.corner_radius,
               std::min(recess.width, recess.height) / 2.0 - 0.001);
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
    throw std::runtime_error("OCCT glass recess fillet did not complete.");
  }

  return fillet.Shape();
}

TopoDS_Shape BuildGlassWindowTool(const EnclosureRequest& enclosure,
                                  const GlassRecessRequest& recess,
                                  int* filleted_edge_count) {
  const std::array<double, 2> center =
      GlassRecessCenter(enclosure, recess);
  const double inner_width = recess.width - recess.ledge_width * 2.0;
  const double inner_height = recess.height - recess.ledge_width * 2.0;
  if (!IsPositiveDimension(inner_width) ||
      !IsPositiveDimension(inner_height)) {
    throw std::runtime_error("OCCT glass window dimensions are invalid.");
  }

  const double overcut = 0.2;
  const std::array<double, 3> tool_size = {
      inner_width,
      enclosure.wall_thickness + overcut * 2.0,
      inner_height};
  const gp_Pnt tool_origin(center[0] - inner_width / 2.0,
                           -enclosure.size[1] / 2.0 - overcut,
                           center[1] - inner_height / 2.0);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(tool_origin,
                          tool_size[0],
                          tool_size[1],
                          tool_size[2])
          .Shape();

  *filleted_edge_count = 0;
  const double inner_radius =
      std::max(0.0, recess.corner_radius - recess.ledge_width);
  const double safe_radius =
      std::min(inner_radius,
               std::min(inner_width, inner_height) / 2.0 - 0.001);
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
    throw std::runtime_error("OCCT glass window fillet did not complete.");
  }

  return fillet.Shape();
}

TopoDS_Shape BuildCircularCutoutTool(
    const EnclosureRequest& enclosure,
    const CircularCutoutRequest& cutout) {
  const std::array<double, 2> center =
      CircularCutoutCenter(enclosure, cutout);
  const double overcut = 0.5;
  const double effective_depth =
      EffectiveCircularCutDepth(cutout.depth,
                                enclosure.wall_thickness,
                                overcut);
  const double height = overcut + effective_depth;
  const gp_Ax2 axis(
      gp_Pnt(center[0], -enclosure.size[1] / 2.0 - overcut, center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  const TopoDS_Shape tool =
      BRepPrimAPI_MakeCylinder(axis, cutout.diameter / 2.0, height).Shape();
  if (tool.IsNull()) {
    throw std::runtime_error("OCCT generated a null circular cutout tool.");
  }

  return tool;
}

TopoDS_Shape BuildRectangularCutoutTool(const EnclosureRequest& enclosure,
                                        const RectangularCutoutRequest& cutout,
                                        int* filleted_edge_count) {
  const std::array<double, 2> center =
      RectangularCutoutCenter(enclosure, cutout);
  const double overcut = 0.5;
  const double effective_depth =
      EffectiveRectangularCutDepth(cutout.depth,
                                   enclosure.wall_thickness,
                                   overcut);
  const std::array<double, 3> tool_size = {
      cutout.width,
      overcut + effective_depth,
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
  const gp_Ax1 rotation_axis(
      gp_Pnt(center[0], -enclosure.size[1] / 2.0, center[1]),
      gp_Dir(0.0, 1.0, 0.0));
  if (safe_radius <= 0.0) {
    return RotateShapeAroundAxis(box, rotation_axis, cutout.rotation_degrees);
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
    throw std::runtime_error(
        "OCCT rectangular cutout fillet did not complete.");
  }

  return RotateShapeAroundAxis(fillet.Shape(),
                               rotation_axis,
                               cutout.rotation_degrees);
}

TopoDS_Shape BuildSketchAddShape(const EnclosureRequest& enclosure,
                                 const SketchAddRequest& add,
                                 int* filleted_edge_count) {
  const std::array<double, 2> center = SketchAddCenter(enclosure, add);
  const double front_y = -enclosure.size[1] / 2.0;
  const double depth = add.protrusion + kSketchAddSurfaceOverlap;
  *filleted_edge_count = 0;

  if (add.shape_type == "circle") {
    const gp_Ax2 axis(gp_Pnt(center[0],
                             front_y - add.protrusion,
                             center[1]),
                      gp_Dir(0.0, 1.0, 0.0));
    const TopoDS_Shape shape =
        BRepPrimAPI_MakeCylinder(axis, add.diameter / 2.0, depth).Shape();
    if (shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null sketch add circle.");
    }
    return shape;
  }

  if (add.shape_type != "rectangle") {
    throw std::runtime_error("OCCT sketch add shape type is unsupported.");
  }

  const std::array<double, 3> add_size = {add.width, depth, add.height};
  const gp_Pnt add_origin(center[0] - add.width / 2.0,
                          front_y - add.protrusion,
                          center[1] - add.height / 2.0);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(add_origin, add_size[0], add_size[1], add_size[2])
          .Shape();
  const double safe_radius =
      std::min(add.corner_radius, std::min(add.width, add.height) / 2.0 - 0.001);
  const gp_Ax1 rotation_axis(gp_Pnt(center[0], front_y, center[1]),
                             gp_Dir(0.0, 1.0, 0.0));
  if (safe_radius <= 0.0) {
    return RotateShapeAroundAxis(box, rotation_axis, add.rotation_degrees);
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
    throw std::runtime_error("OCCT sketch add fillet did not complete.");
  }

  return RotateShapeAroundAxis(fillet.Shape(),
                               rotation_axis,
                               add.rotation_degrees);
}

TopoDS_Shape BuildGeneratedTopLidGlassRecessTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const GlassRecessRequest& recess,
    int* filleted_edge_count) {
  const std::array<double, 2> center = GlassRecessTopLidCenter(recess);
  const double overcut = 0.2;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const std::array<double, 3> tool_size = {
      recess.width,
      recess.height,
      recess.recess_depth + overcut};
  const gp_Pnt tool_origin(center[0] - recess.width / 2.0,
                           center[1] - recess.height / 2.0,
                           lid_top_z - recess.recess_depth);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(tool_origin,
                          tool_size[0],
                          tool_size[1],
                          tool_size[2])
          .Shape();

  *filleted_edge_count = 0;
  const double safe_radius =
      std::min(recess.corner_radius,
               std::min(recess.width, recess.height) / 2.0 - 0.001);
  if (safe_radius <= 0.0) {
    return box;
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    const TopoDS_Edge edge = TopoDS::Edge(explorer.Current());
    const std::array<double, 3> edge_dimensions =
        DimensionsFromBounds(ComputeTopoBounds(edge));
    if (edge_dimensions[0] <= 0.001 && edge_dimensions[1] <= 0.001 &&
        edge_dimensions[2] > 0.001) {
      fillet.Add(safe_radius, edge);
      ++(*filleted_edge_count);
    }
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error(
        "OCCT generated top lid glass recess fillet did not complete.");
  }

  return fillet.Shape();
}

TopoDS_Shape BuildGeneratedTopLidGlassWindowTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const GlassRecessRequest& recess,
    int* filleted_edge_count) {
  const std::array<double, 2> center = GlassRecessTopLidCenter(recess);
  const double inner_width = recess.width - recess.ledge_width * 2.0;
  const double inner_height = recess.height - recess.ledge_width * 2.0;
  if (!IsPositiveDimension(inner_width) ||
      !IsPositiveDimension(inner_height)) {
    throw std::runtime_error(
        "OCCT generated top lid glass window dimensions are invalid.");
  }

  const double overcut = 0.2;
  const double lid_bottom_z = enclosure.size[2] + lid_plate.preview_gap;
  const std::array<double, 3> tool_size = {
      inner_width,
      inner_height,
      lid_plate.thickness + overcut * 2.0};
  const gp_Pnt tool_origin(center[0] - inner_width / 2.0,
                           center[1] - inner_height / 2.0,
                           lid_bottom_z - overcut);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(tool_origin,
                          tool_size[0],
                          tool_size[1],
                          tool_size[2])
          .Shape();

  *filleted_edge_count = 0;
  const double inner_radius =
      std::max(0.0, recess.corner_radius - recess.ledge_width);
  const double safe_radius =
      std::min(inner_radius,
               std::min(inner_width, inner_height) / 2.0 - 0.001);
  if (safe_radius <= 0.0) {
    return box;
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    const TopoDS_Edge edge = TopoDS::Edge(explorer.Current());
    const std::array<double, 3> edge_dimensions =
        DimensionsFromBounds(ComputeTopoBounds(edge));
    if (edge_dimensions[0] <= 0.001 && edge_dimensions[1] <= 0.001 &&
        edge_dimensions[2] > 0.001) {
      fillet.Add(safe_radius, edge);
      ++(*filleted_edge_count);
    }
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error(
        "OCCT generated top lid glass window fillet did not complete.");
  }

  return fillet.Shape();
}

TopoDS_Shape BuildGeneratedTopLidCircularCutoutTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const CircularCutoutRequest& cutout) {
  const std::array<double, 2> center =
      CircularCutoutCenter(enclosure, cutout);
  const double overcut = 0.5;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double effective_depth =
      EffectiveCircularCutDepth(cutout.depth, lid_plate.thickness, overcut);
  const gp_Ax2 axis(gp_Pnt(center[0],
                           center[1],
                           lid_top_z - effective_depth),
                    gp_Dir(0.0, 0.0, 1.0));
  const TopoDS_Shape tool =
      BRepPrimAPI_MakeCylinder(axis,
                               cutout.diameter / 2.0,
                               effective_depth + overcut)
          .Shape();
  if (tool.IsNull()) {
    throw std::runtime_error(
        "OCCT generated a null top lid circular cutout tool.");
  }

  return tool;
}

TopoDS_Shape BuildGeneratedTopLidRectangularCutoutTool(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const RectangularCutoutRequest& cutout,
    int* filleted_edge_count) {
  const std::array<double, 2> center =
      RectangularCutoutCenter(enclosure, cutout);
  const double overcut = 0.5;
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double effective_depth =
      EffectiveRectangularCutDepth(cutout.depth, lid_plate.thickness, overcut);
  const std::array<double, 3> tool_size = {
      cutout.width,
      cutout.height,
      effective_depth + overcut};
  const gp_Pnt tool_origin(center[0] - cutout.width / 2.0,
                           center[1] - cutout.height / 2.0,
                           lid_top_z - effective_depth);
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
  const gp_Ax1 rotation_axis(gp_Pnt(center[0], center[1], lid_top_z),
                             gp_Dir(0.0, 0.0, 1.0));
  if (safe_radius <= 0.0) {
    return RotateShapeAroundAxis(box, rotation_axis, cutout.rotation_degrees);
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    const TopoDS_Edge edge = TopoDS::Edge(explorer.Current());
    const std::array<double, 3> edge_dimensions =
        DimensionsFromBounds(ComputeTopoBounds(edge));
    if (edge_dimensions[0] <= 0.001 && edge_dimensions[1] <= 0.001 &&
        edge_dimensions[2] > 0.001) {
      fillet.Add(safe_radius, edge);
      ++(*filleted_edge_count);
    }
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error(
        "OCCT generated top lid rectangular cutout fillet did not complete.");
  }

  return RotateShapeAroundAxis(fillet.Shape(),
                               rotation_axis,
                               cutout.rotation_degrees);
}

TopoDS_Shape BuildGeneratedTopLidSketchAddShape(
    const EnclosureRequest& enclosure,
    const GeneratedLidPlateRequest& lid_plate,
    const SketchAddRequest& add,
    int* filleted_edge_count) {
  const std::array<double, 2> center = SketchAddCenter(enclosure, add);
  const double lid_top_z =
      enclosure.size[2] + lid_plate.preview_gap + lid_plate.thickness;
  const double depth = add.protrusion + kSketchAddSurfaceOverlap;
  *filleted_edge_count = 0;

  if (add.shape_type == "circle") {
    const gp_Ax2 axis(
        gp_Pnt(center[0], center[1], lid_top_z - kSketchAddSurfaceOverlap),
        gp_Dir(0.0, 0.0, 1.0));
    const TopoDS_Shape shape =
        BRepPrimAPI_MakeCylinder(axis, add.diameter / 2.0, depth).Shape();
    if (shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null top lid sketch add circle.");
    }
    return shape;
  }

  if (add.shape_type != "rectangle") {
    throw std::runtime_error(
        "OCCT top lid sketch add shape type is unsupported.");
  }

  const std::array<double, 3> add_size = {add.width, add.height, depth};
  const gp_Pnt add_origin(center[0] - add.width / 2.0,
                          center[1] - add.height / 2.0,
                          lid_top_z - kSketchAddSurfaceOverlap);
  const TopoDS_Shape box =
      BRepPrimAPI_MakeBox(add_origin, add_size[0], add_size[1], add_size[2])
          .Shape();
  const double safe_radius =
      std::min(add.corner_radius, std::min(add.width, add.height) / 2.0 - 0.001);
  const gp_Ax1 rotation_axis(gp_Pnt(center[0], center[1], lid_top_z),
                             gp_Dir(0.0, 0.0, 1.0));
  if (safe_radius <= 0.0) {
    return RotateShapeAroundAxis(box, rotation_axis, add.rotation_degrees);
  }

  BRepFilletAPI_MakeFillet fillet(box);
  for (TopExp_Explorer explorer(box, TopAbs_EDGE); explorer.More();
       explorer.Next()) {
    const TopoDS_Edge edge = TopoDS::Edge(explorer.Current());
    const std::array<double, 3> edge_dimensions =
        DimensionsFromBounds(ComputeTopoBounds(edge));
    if (edge_dimensions[0] <= 0.001 && edge_dimensions[1] <= 0.001 &&
        edge_dimensions[2] > 0.001) {
      fillet.Add(safe_radius, edge);
      ++(*filleted_edge_count);
    }
  }

  fillet.Build();
  if (!fillet.IsDone()) {
    throw std::runtime_error(
        "OCCT top lid sketch add fillet did not complete.");
  }

  return RotateShapeAroundAxis(fillet.Shape(),
                               rotation_axis,
                               add.rotation_degrees);
}

NativeFeatureCutResult ApplyNativeFeatureCutouts(
    const TopoDS_Shape& base_shape,
    const EnclosureRequest& enclosure,
    const std::vector<UsbCCutoutRequest>& usb_c_cutouts,
    const std::vector<GlassRecessRequest>& glass_recesses,
    const std::vector<CircularCutoutRequest>& circular_cutouts,
    const std::vector<RectangularCutoutRequest>& rectangular_cutouts,
    const std::vector<SketchAddRequest>& sketch_adds,
    const std::vector<ButtonGroupCutoutRequest>& button_groups,
    const std::vector<StandoffMountGroupRequest>& standoff_groups,
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
    ++result.applied_intent_count;
    ++result.usb_c_cutout_count;
    result.usb_c_filleted_edge_count += tool_filleted_edge_count;
  }

  for (const GlassRecessRequest& recess : glass_recesses) {
    if (recess.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    const std::array<double, 2> center =
        GlassRecessCenter(enclosure, recess);
    if (!GlassRecessFitsFrontSurface(enclosure, recess, center)) {
      continue;
    }

    int tool_filleted_edge_count = 0;
    const TopoDS_Shape tool =
        BuildGlassRecessTool(enclosure, recess, &tool_filleted_edge_count);
    if (tool.IsNull()) {
      throw std::runtime_error("OCCT generated a null glass recess tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error("OCCT glass recess cut did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null glass recess shape.");
    }

    BRepCheck_Analyzer analyzer(result.shape, false);
    if (!analyzer.IsValid()) {
      throw std::runtime_error("OCCT generated an invalid glass recess shape.");
    }

    ++result.applied_cut_count;
    ++result.glass_recess_count;
    result.glass_recess_filleted_edge_count += tool_filleted_edge_count;

    int window_filleted_edge_count = 0;
    const TopoDS_Shape window_tool =
        BuildGlassWindowTool(enclosure, recess, &window_filleted_edge_count);
    if (window_tool.IsNull()) {
      throw std::runtime_error("OCCT generated a null glass window tool.");
    }

    BRepAlgoAPI_Cut window_cut(result.shape, window_tool);
    window_cut.SimplifyResult(true, true);
    if (!window_cut.IsDone() || window_cut.HasErrors()) {
      throw std::runtime_error("OCCT glass window cut did not complete.");
    }

    result.shape = window_cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null glass window shape.");
    }

    BRepCheck_Analyzer window_analyzer(result.shape, false);
    if (!window_analyzer.IsValid()) {
      throw std::runtime_error("OCCT generated an invalid glass window shape.");
    }

    ++result.applied_cut_count;
    ++result.applied_intent_count;
    ++result.glass_window_count;
    result.glass_window_filleted_edge_count += window_filleted_edge_count;
  }

  for (const CircularCutoutRequest& cutout : circular_cutouts) {
    if (cutout.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    const std::array<double, 2> center =
        CircularCutoutCenter(enclosure, cutout);
    if (!CircularCutoutFitsFrontSurface(enclosure, cutout, center)) {
      continue;
    }

    const TopoDS_Shape tool = BuildCircularCutoutTool(enclosure, cutout);
    if (tool.IsNull()) {
      throw std::runtime_error("OCCT generated a null circular cutout tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error("OCCT circular cutout did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null circular cutout shape.");
    }

    BRepCheck_Analyzer analyzer(result.shape, false);
    if (!analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid circular cutout shape.");
    }

    ++result.applied_cut_count;
    ++result.applied_intent_count;
    ++result.circular_cutout_count;
  }

  for (const RectangularCutoutRequest& cutout : rectangular_cutouts) {
    if (cutout.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    const std::array<double, 2> center =
        RectangularCutoutCenter(enclosure, cutout);
    if (!RectangularCutoutFitsFrontSurface(enclosure, cutout, center)) {
      continue;
    }

    int tool_filleted_edge_count = 0;
    const TopoDS_Shape tool =
        BuildRectangularCutoutTool(enclosure, cutout, &tool_filleted_edge_count);
    if (tool.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null rectangular cutout tool.");
    }

    BRepAlgoAPI_Cut cut(result.shape, tool);
    cut.SimplifyResult(true, true);
    if (!cut.IsDone() || cut.HasErrors()) {
      throw std::runtime_error("OCCT rectangular cutout did not complete.");
    }

    result.shape = cut.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error(
          "OCCT generated a null rectangular cutout shape.");
    }

    BRepCheck_Analyzer analyzer(result.shape, false);
    if (!analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid rectangular cutout shape.");
    }

    ++result.applied_cut_count;
    ++result.applied_intent_count;
    ++result.rectangular_cutout_count;
    result.rectangular_cutout_filleted_edge_count += tool_filleted_edge_count;
  }

  for (const SketchAddRequest& add : sketch_adds) {
    if (add.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    const std::array<double, 2> center = SketchAddCenter(enclosure, add);
    if (!SketchAddFitsFrontSurface(enclosure, add, center)) {
      continue;
    }

    int filleted_edge_count = 0;
    const TopoDS_Shape add_shape =
        BuildSketchAddShape(enclosure, add, &filleted_edge_count);
    if (add_shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null sketch add shape.");
    }

    BRepAlgoAPI_Fuse fuse(result.shape, add_shape);
    fuse.SimplifyResult(true, true);
    if (!fuse.IsDone() || fuse.HasErrors()) {
      throw std::runtime_error("OCCT sketch add fuse did not complete.");
    }

    result.shape = fuse.Shape();
    if (result.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null sketch add fuse shape.");
    }

    BRepCheck_Analyzer fuse_analyzer(result.shape, false);
    if (!fuse_analyzer.IsValid()) {
      throw std::runtime_error(
          "OCCT generated an invalid sketch add fuse shape.");
    }

    ++result.applied_intent_count;
    ++result.sketch_add_count;
    result.sketch_add_filleted_edge_count += filleted_edge_count;
  }

  for (const ButtonGroupCutoutRequest& group : button_groups) {
    if (group.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    int group_cut_count = 0;
    for (const ButtonCutoutItemRequest& cutout : group.items) {
      const TopoDS_Shape tool = BuildButtonCutoutTool(enclosure, cutout);
      if (tool.IsNull()) {
        throw std::runtime_error("OCCT generated a null button cutout tool.");
      }

      BRepAlgoAPI_Cut cut(result.shape, tool);
      cut.SimplifyResult(true, true);
      if (!cut.IsDone() || cut.HasErrors()) {
        throw std::runtime_error("OCCT button cutout did not complete.");
      }

      result.shape = cut.Shape();
      if (result.shape.IsNull()) {
        throw std::runtime_error("OCCT generated a null button cutout shape.");
      }

      BRepCheck_Analyzer analyzer(result.shape, false);
      if (!analyzer.IsValid()) {
        throw std::runtime_error("OCCT generated an invalid button cutout shape.");
      }

      ++result.applied_cut_count;
      ++result.button_cutout_count;
      ++group_cut_count;

      const TopoDS_Shape ring = BuildButtonRingShape(enclosure, cutout);
      if (ring.IsNull()) {
        throw std::runtime_error("OCCT generated a null button ring shape.");
      }

      BRepAlgoAPI_Fuse fuse(result.shape, ring);
      fuse.SimplifyResult(true, true);
      if (!fuse.IsDone() || fuse.HasErrors()) {
        throw std::runtime_error("OCCT button ring fuse did not complete.");
      }

      result.shape = fuse.Shape();
      if (result.shape.IsNull()) {
        throw std::runtime_error(
            "OCCT generated a null button ring fuse shape.");
      }

      BRepCheck_Analyzer fuse_analyzer(result.shape, false);
      if (!fuse_analyzer.IsValid()) {
        throw std::runtime_error(
            "OCCT generated an invalid button ring fuse shape.");
      }

      ++result.button_ring_count;
    }

    if (group_cut_count > 0) {
      ++result.applied_intent_count;
      ++result.button_group_count;
    }
  }

  for (const StandoffMountGroupRequest& group : standoff_groups) {
    int group_mount_count = 0;
    for (const StandoffMountItemRequest& mount : group.items) {
      const TopoDS_Shape mount_shape =
          BuildStandoffMountShape(enclosure, mount);
      if (mount_shape.IsNull()) {
        throw std::runtime_error("OCCT generated a null standoff mount shape.");
      }

      BRepAlgoAPI_Fuse fuse(result.shape, mount_shape);
      fuse.SimplifyResult(true, true);
      if (!fuse.IsDone() || fuse.HasErrors()) {
        throw std::runtime_error("OCCT standoff mount fuse did not complete.");
      }

      result.shape = fuse.Shape();
      if (result.shape.IsNull()) {
        throw std::runtime_error("OCCT generated a null standoff fuse shape.");
      }

      BRepCheck_Analyzer analyzer(result.shape, false);
      if (!analyzer.IsValid()) {
        throw std::runtime_error("OCCT generated an invalid standoff fuse shape.");
      }

      ++result.applied_cut_count;
      ++result.standoff_mount_count;
      ++group_mount_count;
    }

    if (group_mount_count > 0) {
      ++result.applied_intent_count;
      ++result.standoff_group_count;
    }
  }

  result.ignored_intent_count =
      std::max(0, feature_intent_count - result.applied_intent_count);
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
    const std::vector<LidScrewBossRequest>& lid_screw_bosses,
    const std::vector<GeneratedLidSeatRequest>& generated_lid_seats,
    const std::vector<GeneratedLidPlateRequest>& generated_lid_plates,
    const std::vector<UsbCCutoutRequest>& usb_c_cutouts,
    const std::vector<GlassRecessRequest>& glass_recesses,
    const std::vector<CircularCutoutRequest>& circular_cutouts,
    const std::vector<RectangularCutoutRequest>& rectangular_cutouts,
    const std::vector<SketchAddRequest>& sketch_adds,
    const std::vector<ButtonGroupCutoutRequest>& button_groups,
    const std::vector<StandoffMountGroupRequest>& standoff_groups) {
  std::vector<std::pair<std::string, std::string>> surfaces;
  for (const GeneratedLidSeatRequest& seat : generated_lid_seats) {
    if (FaceIntersectsGeneratedLidSeat(face_bounds,
                                      metrics,
                                      enclosure,
                                      seat)) {
      surfaces.push_back(std::make_pair(seat.id, "Lid seat"));
      break;
    }
  }

  bool is_generated_lid_plate = false;
  bool is_generated_lid_detail = false;
  for (const GeneratedLidPlateRequest& lid_plate : generated_lid_plates) {
    if (FaceIntersectsGeneratedLidLocatingLip(face_bounds,
                                             metrics,
                                             enclosure,
                                             lid_plate)) {
      surfaces.push_back(std::make_pair(lid_plate.locating_lip_id,
                                        "Lid locating lip"));
      is_generated_lid_detail = true;
      break;
    }
  }

  for (const GeneratedLidPlateRequest& lid_plate : generated_lid_plates) {
    for (const SketchAddRequest& add : sketch_adds) {
      if (add.target_surface != enclosure.id + ".top_lid.outer") {
        continue;
      }

      if (FaceIntersectsGeneratedTopLidSketchAdd(face_bounds,
                                                 metrics,
                                                 enclosure,
                                                 lid_plate,
                                                 add)) {
        surfaces.push_back(std::make_pair(add.id, "Top lid sketch add"));
        is_generated_lid_detail = true;
        break;
      }
    }
  }

  for (const GeneratedLidPlateRequest& lid_plate : generated_lid_plates) {
    if (FaceIntersectsGeneratedLidPlate(face_bounds,
                                       metrics,
                                       enclosure,
                                       lid_plate)) {
      surfaces.push_back(std::make_pair(lid_plate.id, "Generated lid"));
      is_generated_lid_plate = true;
      for (const LidScrewBossRequest& boss : lid_screw_bosses) {
        if (FaceIntersectsGeneratedLidScrewHole(face_bounds,
                                               metrics,
                                               enclosure,
                                               lid_plate,
                                               boss)) {
          surfaces.push_back(
              std::make_pair(lid_plate.screw_holes_id, "Lid screw holes"));
          break;
        }
      }
      for (const GlassRecessRequest& recess : glass_recesses) {
        if (recess.target_surface != enclosure.id + ".top_lid.outer") {
          continue;
        }

        if (FaceIntersectsGeneratedTopLidGlassRecess(face_bounds,
                                                    metrics,
                                                    enclosure,
                                                    lid_plate,
                                                    recess)) {
          surfaces.push_back(std::make_pair(recess.id, "Top lid glass recess"));
          break;
        }
      }
      for (const CircularCutoutRequest& cutout : circular_cutouts) {
        if (cutout.target_surface != enclosure.id + ".top_lid.outer") {
          continue;
        }

        if (FaceIntersectsGeneratedTopLidCircularCutout(face_bounds,
                                                        metrics,
                                                        enclosure,
                                                        lid_plate,
                                                        cutout)) {
          surfaces.push_back(
              std::make_pair(cutout.id, "Top lid circular cutout"));
          break;
        }
      }
      for (const RectangularCutoutRequest& cutout : rectangular_cutouts) {
        if (cutout.target_surface != enclosure.id + ".top_lid.outer") {
          continue;
        }

        if (FaceIntersectsGeneratedTopLidRectangularCutout(face_bounds,
                                                           metrics,
                                                           enclosure,
                                                           lid_plate,
                                                           cutout)) {
          surfaces.push_back(
              std::make_pair(cutout.id, "Top lid rectangular cutout"));
          break;
        }
      }
      for (const ButtonGroupCutoutRequest& group : button_groups) {
        if (group.target_surface != enclosure.id + ".top_lid.outer") {
          continue;
        }

        for (const ButtonCutoutItemRequest& cutout : group.items) {
          if (FaceIntersectsGeneratedTopLidButtonCutout(face_bounds,
                                                       metrics,
                                                       enclosure,
                                                       lid_plate,
                                                       cutout) ||
              FaceIntersectsGeneratedTopLidButtonRing(face_bounds,
                                                     metrics,
                                                     enclosure,
                                                     lid_plate,
                                                     cutout) ||
              FaceIntersectsGeneratedTopLidButtonPlunger(face_bounds,
                                                        metrics,
                                                        enclosure,
                                                        lid_plate,
                                                        cutout)) {
            surfaces.push_back(std::make_pair(group.id, "Top lid buttons"));
            break;
          }
        }
      }
      break;
    }
  }

  if (!is_generated_lid_plate) {
    for (const GeneratedLidPlateRequest& lid_plate : generated_lid_plates) {
      for (const ButtonGroupCutoutRequest& group : button_groups) {
        if (group.target_surface != enclosure.id + ".top_lid.outer") {
          continue;
        }

        for (const ButtonCutoutItemRequest& cutout : group.items) {
          if (FaceIntersectsGeneratedTopLidButtonPlunger(face_bounds,
                                                        metrics,
                                                        enclosure,
                                                        lid_plate,
                                                        cutout)) {
            surfaces.push_back(std::make_pair(group.id, "Top lid buttons"));
            break;
          }
        }
      }
    }
  }

  const std::optional<std::pair<std::string, std::string>> body_surface =
      ClassifyPreviewSurface(face_bounds, metrics, body_id);
  if (body_surface.has_value() &&
      ((!is_generated_lid_plate && !is_generated_lid_detail) ||
       body_surface->first == body_id + ".top_lid.outer")) {
    surfaces.push_back(body_surface.value());
  }

  for (const LidScrewBossRequest& boss : lid_screw_bosses) {
    if (FaceIntersectsLidScrewBoss(face_bounds, metrics, enclosure, boss)) {
      surfaces.push_back(
          std::make_pair(boss.id, "Lid screw bosses"));
      break;
    }
  }

  for (const UsbCCutoutRequest& cutout : usb_c_cutouts) {
    if (FaceIntersectsUsbCCutout(face_bounds, metrics, enclosure, cutout)) {
      surfaces.push_back(std::make_pair(cutout.id, "USB-C cutout"));
    }
  }

  for (const GlassRecessRequest& recess : glass_recesses) {
    if (FaceIntersectsGlassRecess(face_bounds, metrics, enclosure, recess)) {
      surfaces.push_back(std::make_pair(recess.id, "Glass recess"));
    }
  }

  for (const CircularCutoutRequest& cutout : circular_cutouts) {
    if (cutout.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    if (FaceIntersectsCircularCutout(face_bounds, metrics, enclosure, cutout)) {
      surfaces.push_back(std::make_pair(cutout.id, "Circular cutout"));
    }
  }

  for (const RectangularCutoutRequest& cutout : rectangular_cutouts) {
    if (cutout.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    if (FaceIntersectsRectangularCutout(face_bounds, metrics, enclosure, cutout)) {
      surfaces.push_back(std::make_pair(cutout.id, "Rectangular cutout"));
    }
  }

  for (const SketchAddRequest& add : sketch_adds) {
    if (add.target_surface != enclosure.id + ".front_wall.outer") {
      continue;
    }

    if (FaceIntersectsSketchAdd(face_bounds, metrics, enclosure, add)) {
      surfaces.push_back(std::make_pair(add.id, "Sketch add"));
    }
  }

  for (const ButtonGroupCutoutRequest& group : button_groups) {
    for (const ButtonCutoutItemRequest& cutout : group.items) {
      if (FaceIntersectsButtonCutout(face_bounds, metrics, enclosure, cutout) ||
          FaceIntersectsButtonRing(face_bounds, metrics, enclosure, cutout) ||
          FaceIntersectsButtonPlunger(face_bounds, metrics, enclosure, cutout)) {
        surfaces.push_back(std::make_pair(group.id, "Button group"));
        break;
      }
    }
  }

  for (const StandoffMountGroupRequest& group : standoff_groups) {
    for (const StandoffMountItemRequest& mount : group.items) {
      if (FaceIntersectsStandoffMount(face_bounds, metrics, enclosure, mount)) {
        surfaces.push_back(std::make_pair(group.id, "Standoff mounts"));
        break;
      }
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
                                 const std::vector<LidScrewBossRequest>&
                                     lid_screw_bosses,
                                 const std::vector<GeneratedLidSeatRequest>&
                                     generated_lid_seats,
                                 const std::vector<GeneratedLidPlateRequest>&
                                     generated_lid_plates,
                                 const std::vector<UsbCCutoutRequest>&
                                     usb_c_cutouts,
                                  const std::vector<GlassRecessRequest>&
                                      glass_recesses,
                                  const std::vector<CircularCutoutRequest>&
                                      circular_cutouts,
                                  const std::vector<RectangularCutoutRequest>&
                                      rectangular_cutouts,
                                  const std::vector<SketchAddRequest>&
                                      sketch_adds,
                                  const std::vector<ButtonGroupCutoutRequest>&
                                      button_groups,
                                 const std::vector<StandoffMountGroupRequest>&
                                     standoff_groups) {
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
                                lid_screw_bosses,
                                generated_lid_seats,
                                generated_lid_plates,
                                usb_c_cutouts,
                                 glass_recesses,
                                 circular_cutouts,
                                 rectangular_cutouts,
                                 sketch_adds,
                                 button_groups,
                                standoff_groups);
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

std::string IFSelectStatusName(IFSelect_ReturnStatus status) {
  switch (status) {
    case IFSelect_RetVoid:
      return "void";
    case IFSelect_RetDone:
      return "done";
    case IFSelect_RetError:
      return "error";
    case IFSelect_RetFail:
      return "fail";
    case IFSelect_RetStop:
      return "stop";
  }

  return "unknown";
}

StepExportResult ExportStepFile(const TopoDS_Shape& shape,
                                const std::string& output_path) {
  if (shape.IsNull()) {
    throw std::runtime_error("OCCT cannot export a null STEP shape.");
  }
  if (output_path.empty()) {
    throw std::runtime_error("STEP export output path is empty.");
  }

  const std::filesystem::path step_path(output_path);
  const std::filesystem::path parent_path = step_path.parent_path();
  if (!parent_path.empty()) {
    std::filesystem::create_directories(parent_path);
  }

  IFSelect_ReturnStatus transfer_status = IFSelect_RetVoid;
  IFSelect_ReturnStatus write_status = IFSelect_RetVoid;
  {
    std::ostringstream occt_stdout;
    ScopedCoutRedirect suppress_occt_stdout(occt_stdout);
    STEPControl_Writer writer;
    transfer_status = writer.Transfer(shape, STEPControl_AsIs);
    if (transfer_status != IFSelect_RetDone) {
      throw std::runtime_error("OCCT STEP transfer failed with status " +
                               IFSelectStatusName(transfer_status) + ".");
    }

    writer.CleanDuplicateEntities();
    write_status = writer.Write(output_path.c_str());
    if (write_status != IFSelect_RetDone) {
      throw std::runtime_error("OCCT STEP write failed with status " +
                               IFSelectStatusName(write_status) + ".");
    }
  }

  StepExportResult result;
  result.path = output_path;
  result.byte_count = std::filesystem::file_size(step_path);
  result.transfer_status = IFSelectStatusName(transfer_status);
  result.write_status = IFSelectStatusName(write_status);
  return result;
}

int CountShapeTriangles(const TopoDS_Shape& shape) {
  int triangle_count = 0;
  for (TopExp_Explorer explorer(shape, TopAbs_FACE); explorer.More();
       explorer.Next()) {
    const TopoDS_Face face = TopoDS::Face(explorer.Current());
    TopLoc_Location location;
    const opencascade::handle<Poly_Triangulation> triangulation =
        BRep_Tool::Triangulation(face, location);
    if (triangulation.IsNull()) {
      continue;
    }

    triangle_count += triangulation->NbTriangles();
  }

  return triangle_count;
}

StlExportResult ExportStlFile(const TopoDS_Shape& shape,
                              const std::string& output_path) {
  if (shape.IsNull()) {
    throw std::runtime_error("OCCT cannot export a null STL shape.");
  }
  if (output_path.empty()) {
    throw std::runtime_error("STL export output path is empty.");
  }

  const std::filesystem::path stl_path(output_path);
  const std::filesystem::path parent_path = stl_path.parent_path();
  if (!parent_path.empty()) {
    std::filesystem::create_directories(parent_path);
  }

  const BRepMesh_IncrementalMesh mesher(shape,
                                        kExportStlLinearDeflection,
                                        false,
                                        kExportStlAngularDeflection,
                                        false);
  const int triangle_count = CountShapeTriangles(shape);
  if (triangle_count <= 0) {
    throw std::runtime_error("OCCT STL meshing produced no triangles.");
  }

  bool write_ok = false;
  {
    std::ostringstream occt_stdout;
    ScopedCoutRedirect suppress_occt_stdout(occt_stdout);
    StlAPI_Writer writer;
    writer.ASCIIMode() = false;
    write_ok = writer.Write(shape, output_path.c_str());
  }
  if (!write_ok) {
    throw std::runtime_error("OCCT STL write failed.");
  }

  StlExportResult result;
  result.path = output_path;
  result.byte_count = std::filesystem::file_size(stl_path);
  result.triangle_count = triangle_count;
  result.mesher_status = mesher.GetStatusFlags();
  result.binary = true;
  result.write_status = "done";
  return result;
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
      << "        \"preview_mesh\",\n"
      << "        \"export_step\",\n"
      << "        \"export_stl\"\n"
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
      << "        \"worker.geometry.invalid_usb_c_cutout\",\n"
      << "        \"worker.geometry.invalid_glass_recess\",\n"
      << "        \"worker.geometry.invalid_circular_cutout\",\n"
      << "        \"worker.geometry.invalid_rectangular_cutout\",\n"
      << "        \"worker.geometry.invalid_button_cutout\",\n"
      << "        \"worker.geometry.invalid_standoff_mount\",\n"
      << "        \"worker.geometry.occt_exception\",\n"
      << "        \"worker.export.missing_output_path\",\n"
      << "        \"worker.backend.occt_operation_not_implemented\"\n"
      << "      ],\n"
      << "      \"notes\": [\n"
      << "        \"OCCT-linked native target is available.\",\n"
      << "        \"preview_mesh returns a disposable triangulated preview mesh, first-pass semantic surface ranges, and deterministic rounded enclosure metrics.\",\n"
      << "        \"export_step writes a generated STEP artifact from the same semantic B-Rep pipeline to an explicit output path.\",\n"
      << "        \"export_stl writes a generated binary STL artifact from the same semantic B-Rep pipeline to an explicit output path.\"\n"
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
            << "    \"nativeLidScrewBossCount\": "
            << metrics.native_lid_screw_boss_count << ",\n"
            << "    \"nativeLidScrewPilotCount\": "
            << metrics.native_lid_screw_pilot_count << ",\n"
            << "    \"nativeGeneratedLidSeatCount\": "
            << metrics.native_generated_lid_seat_count << ",\n"
            << "    \"nativeGeneratedLidPlateCount\": "
            << metrics.native_generated_lid_plate_count << ",\n"
            << "    \"nativeGeneratedLidFitPreviewGap\": "
            << FormatDouble(metrics.native_generated_lid_fit_preview_gap)
            << ",\n"
            << "    \"nativeGeneratedLidLipCount\": "
            << metrics.native_generated_lid_lip_count << ",\n"
            << "    \"nativeGeneratedLidScrewHoleCount\": "
            << metrics.native_generated_lid_screw_hole_count << ",\n"
            << "    \"nativeGeneratedLidFeatureCutCount\": "
            << metrics.native_generated_lid_feature_cut_count << ",\n"
            << "    \"nativeGeneratedLidGlassRecessCount\": "
            << metrics.native_generated_lid_glass_recess_count << ",\n"
            << "    \"nativeGeneratedLidGlassRecessFilletedEdgeCount\": "
            << metrics.native_generated_lid_glass_recess_filleted_edge_count
            << ",\n"
            << "    \"nativeGeneratedLidGlassWindowCount\": "
            << metrics.native_generated_lid_glass_window_count << ",\n"
            << "    \"nativeGeneratedLidGlassWindowFilletedEdgeCount\": "
            << metrics.native_generated_lid_glass_window_filleted_edge_count
            << ",\n"
            << "    \"nativeGeneratedLidCircularCutoutCount\": "
            << metrics.native_generated_lid_circular_cutout_count << ",\n"
            << "    \"nativeGeneratedLidRectangularCutoutCount\": "
            << metrics.native_generated_lid_rectangular_cutout_count << ",\n"
            << "    \"nativeGeneratedLidRectangularCutoutFilletedEdgeCount\": "
            << metrics.native_generated_lid_rectangular_cutout_filleted_edge_count
            << ",\n"
            << "    \"nativeGeneratedLidSketchAddCount\": "
            << metrics.native_generated_lid_sketch_add_count << ",\n"
            << "    \"nativeGeneratedLidSketchAddFilletedEdgeCount\": "
            << metrics.native_generated_lid_sketch_add_filleted_edge_count
            << ",\n"
            << "    \"nativeGeneratedLidButtonGroupCount\": "
            << metrics.native_generated_lid_button_group_count << ",\n"
            << "    \"nativeGeneratedLidButtonCutoutCount\": "
            << metrics.native_generated_lid_button_cutout_count << ",\n"
            << "    \"nativeGeneratedLidButtonRingCount\": "
            << metrics.native_generated_lid_button_ring_count << ",\n"
            << "    \"nativeGeneratedLidButtonCapCount\": "
            << metrics.native_generated_lid_button_cap_count << ",\n"
            << "    \"nativeGeneratedLidButtonStemCount\": "
            << metrics.native_generated_lid_button_stem_count << ",\n"
            << "    \"nativeGeneratedLidButtonGuideCount\": "
            << metrics.native_generated_lid_button_guide_count << ",\n"
            << "    \"nativeGeneratedLidButtonTravelStopCount\": "
            << metrics.native_generated_lid_button_travel_stop_count << ",\n"
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
            << "    \"nativeGlassRecessCount\": "
            << metrics.native_glass_recess_count << ",\n"
            << "    \"nativeGlassRecessFilletedEdgeCount\": "
            << metrics.native_glass_recess_filleted_edge_count << ",\n"
            << "    \"nativeGlassWindowCount\": "
            << metrics.native_glass_window_count << ",\n"
            << "    \"nativeGlassWindowFilletedEdgeCount\": "
            << metrics.native_glass_window_filleted_edge_count << ",\n"
            << "    \"nativeCircularCutoutCount\": "
            << metrics.native_circular_cutout_count << ",\n"
            << "    \"nativeRectangularCutoutCount\": "
            << metrics.native_rectangular_cutout_count << ",\n"
            << "    \"nativeRectangularCutoutFilletedEdgeCount\": "
            << metrics.native_rectangular_cutout_filleted_edge_count << ",\n"
            << "    \"nativeSketchAddCount\": "
            << metrics.native_sketch_add_count << ",\n"
            << "    \"nativeSketchAddFilletedEdgeCount\": "
            << metrics.native_sketch_add_filleted_edge_count << ",\n"
            << "    \"nativeButtonGroupCount\": "
            << metrics.native_button_group_count << ",\n"
            << "    \"nativeButtonCutoutCount\": "
            << metrics.native_button_cutout_count << ",\n"
            << "    \"nativeButtonRingCount\": "
            << metrics.native_button_ring_count << ",\n"
            << "    \"nativeButtonCapCount\": "
            << metrics.native_button_cap_count << ",\n"
            << "    \"nativeButtonStemCount\": "
            << metrics.native_button_stem_count << ",\n"
            << "    \"nativeButtonGuideCount\": "
            << metrics.native_button_guide_count << ",\n"
            << "    \"nativeButtonTravelStopCount\": "
            << metrics.native_button_travel_stop_count << ",\n"
            << "    \"nativeStandoffGroupCount\": "
            << metrics.native_standoff_group_count << ",\n"
            << "    \"nativeStandoffMountCount\": "
            << metrics.native_standoff_mount_count << ",\n"
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

void WriteRoundedEnclosureStepExportResponse(
    const NativeRequestEnvelope& request,
    const EnclosureRequest& enclosure,
    const ShapeMetrics& metrics,
    const StepExportResult& export_result) {
  std::cout << "{\n"
            << "  \"schema\": \"" << kResponseSchema << "\",\n"
            << "  \"version\": 1,\n"
            << "  \"requestId\": \"" << EscapeJsonString(request.request_id)
            << "\",\n"
            << "  \"status\": \"ok\",\n"
            << "  \"backend\": \"" << kBackend << "\",\n"
            << "  \"artifacts\": [\n"
            << "    {\n"
            << "      \"type\": \"step\",\n"
            << "      \"path\": \"" << EscapeJsonString(export_result.path)
            << "\",\n"
            << "      \"format\": \"STEP\",\n"
            << "      \"source\": \"occt_brep\",\n"
            << "      \"units\": \"mm\",\n"
            << "      \"byteCount\": " << export_result.byte_count << "\n"
            << "    }\n"
            << "  ],\n"
            << "  \"issues\": [],\n"
            << "  \"metrics\": {\n"
            << "    \"requestedBackend\": \"native\",\n"
            << "    \"executable\": \"occt_worker_native_occt\",\n"
            << "    \"requestedOperation\": \""
            << EscapeJsonString(request.operation) << "\",\n"
            << "    \"occtVersion\": \""
            << EscapeJsonString(OCC_VERSION_COMPLETE) << "\",\n"
            << "    \"generator\": \"occt.rounded_enclosure.step_export.v1\",\n"
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
            << "    \"nativeGeneratedLidPlateCount\": "
            << metrics.native_generated_lid_plate_count << ",\n"
            << "    \"nativeGeneratedLidSeatCount\": "
            << metrics.native_generated_lid_seat_count << ",\n"
            << "    \"nativeGeneratedLidFitPreviewGap\": "
            << FormatDouble(metrics.native_generated_lid_fit_preview_gap)
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
            << "    \"exportFormat\": \"step\",\n"
            << "    \"exportArtifactCount\": 1,\n"
            << "    \"exportPath\": \""
            << EscapeJsonString(export_result.path) << "\",\n"
            << "    \"exportByteCount\": " << export_result.byte_count
            << ",\n"
            << "    \"exportTransferStatus\": \""
            << EscapeJsonString(export_result.transfer_status) << "\",\n"
            << "    \"exportWriteStatus\": \""
            << EscapeJsonString(export_result.write_status) << "\",\n"
            << "    \"previewMeshEmitted\": false,\n"
            << "    \"editableGeneratedGeometry\": false\n"
            << "  }\n"
            << "}\n";
}

void WriteRoundedEnclosureStlExportResponse(
    const NativeRequestEnvelope& request,
    const EnclosureRequest& enclosure,
    const ShapeMetrics& metrics,
    const StlExportResult& export_result) {
  std::cout << "{\n"
            << "  \"schema\": \"" << kResponseSchema << "\",\n"
            << "  \"version\": 1,\n"
            << "  \"requestId\": \"" << EscapeJsonString(request.request_id)
            << "\",\n"
            << "  \"status\": \"ok\",\n"
            << "  \"backend\": \"" << kBackend << "\",\n"
            << "  \"artifacts\": [\n"
            << "    {\n"
            << "      \"type\": \"stl\",\n"
            << "      \"path\": \"" << EscapeJsonString(export_result.path)
            << "\",\n"
            << "      \"format\": \"STL\",\n"
            << "      \"source\": \"occt_brep_tessellation\",\n"
            << "      \"units\": \"mm\",\n"
            << "      \"binary\": "
            << (export_result.binary ? "true" : "false") << ",\n"
            << "      \"byteCount\": " << export_result.byte_count << ",\n"
            << "      \"triangleCount\": " << export_result.triangle_count
            << "\n"
            << "    }\n"
            << "  ],\n"
            << "  \"issues\": [],\n"
            << "  \"metrics\": {\n"
            << "    \"requestedBackend\": \"native\",\n"
            << "    \"executable\": \"occt_worker_native_occt\",\n"
            << "    \"requestedOperation\": \""
            << EscapeJsonString(request.operation) << "\",\n"
            << "    \"occtVersion\": \""
            << EscapeJsonString(OCC_VERSION_COMPLETE) << "\",\n"
            << "    \"generator\": \"occt.rounded_enclosure.stl_export.v1\",\n"
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
            << "    \"nativeGeneratedLidPlateCount\": "
            << metrics.native_generated_lid_plate_count << ",\n"
            << "    \"nativeGeneratedLidSeatCount\": "
            << metrics.native_generated_lid_seat_count << ",\n"
            << "    \"nativeGeneratedLidFitPreviewGap\": "
            << FormatDouble(metrics.native_generated_lid_fit_preview_gap)
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
            << "    \"exportFormat\": \"stl\",\n"
            << "    \"exportArtifactCount\": 1,\n"
            << "    \"exportPath\": \""
            << EscapeJsonString(export_result.path) << "\",\n"
            << "    \"exportByteCount\": " << export_result.byte_count
            << ",\n"
            << "    \"exportBinary\": "
            << (export_result.binary ? "true" : "false") << ",\n"
            << "    \"exportTriangleCount\": "
            << export_result.triangle_count << ",\n"
            << "    \"exportMesherStatus\": "
            << export_result.mesher_status << ",\n"
            << "    \"exportLinearDeflection\": "
            << FormatDouble(kExportStlLinearDeflection) << ",\n"
            << "    \"exportAngularDeflection\": "
            << FormatDouble(kExportStlAngularDeflection) << ",\n"
            << "    \"exportWriteStatus\": \""
            << EscapeJsonString(export_result.write_status) << "\",\n"
            << "    \"previewMeshEmitted\": false,\n"
            << "    \"editableGeneratedGeometry\": false\n"
            << "  }\n"
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

    const NativeLidBossResult lid_bosses =
        ApplyNativeLidScrewBosses(shell.shape,
                                  parsed_request.enclosure,
                                  parsed_request.lid_screw_bosses);
    if (lid_bosses.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null lid boss shape.");
    }

    const NativeFeatureCutResult feature_cuts =
        ApplyNativeFeatureCutouts(lid_bosses.shape,
                                  parsed_request.enclosure,
                                  parsed_request.usb_c_cutouts,
                                  parsed_request.glass_recesses,
                                  parsed_request.circular_cutouts,
                                  parsed_request.rectangular_cutouts,
                                  parsed_request.sketch_adds,
                                  parsed_request.button_groups,
                                  parsed_request.standoff_groups,
                                  parsed_request.feature_intent_count);
    if (feature_cuts.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null feature-cut shape.");
    }

    const NativeGeneratedLidSeatResult lid_seats =
        ApplyGeneratedTopLidSeats(feature_cuts.shape,
                                  parsed_request.enclosure,
                                  parsed_request.generated_lid_seats);
    if (lid_seats.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null top lid seat shape.");
    }

    const NativePreviewAssemblyResult preview_assembly =
        BuildPreviewAssembly(lid_seats.shape,
                             parsed_request.enclosure,
                             parsed_request.generated_lid_plates,
                             parsed_request.lid_screw_bosses,
                             parsed_request.glass_recesses,
                             parsed_request.circular_cutouts,
                             parsed_request.rectangular_cutouts,
                             parsed_request.sketch_adds,
                             parsed_request.button_groups);
    if (preview_assembly.shape.IsNull()) {
      throw std::runtime_error("OCCT generated a null preview assembly.");
    }

    const ShapeMetrics metrics =
        ComputeShapeMetrics(preview_assembly.shape,
                            corner_radius_applied,
                            filleted_edge_count,
                            shell.cavity_applied,
                            shell.cavity_valid,
                            shell.cavity_tool_count,
                            lid_bosses.boss_count,
                            lid_bosses.pilot_hole_count,
                            preview_assembly.button_cap_count,
                            preview_assembly.button_stem_count,
                            preview_assembly.button_guide_count,
                            preview_assembly.button_travel_stop_count,
                            lid_seats.seat_count,
                            preview_assembly.generated_lid_plate_count,
                            parsed_request.generated_lid_plates.empty()
                                ? 0.0
                                : parsed_request.generated_lid_plates.front()
                                      .preview_gap,
                            preview_assembly.generated_lid_lip_count,
                            preview_assembly.generated_lid_screw_hole_count,
                            preview_assembly.generated_lid_feature_cut_count,
                            preview_assembly.generated_lid_glass_recess_count,
                            preview_assembly
                                .generated_lid_glass_recess_filleted_edge_count,
                            preview_assembly.generated_lid_glass_window_count,
                            preview_assembly
                                .generated_lid_glass_window_filleted_edge_count,
                            preview_assembly
                                .generated_lid_circular_cutout_count,
                            preview_assembly
                                .generated_lid_rectangular_cutout_count,
                            preview_assembly
                                .generated_lid_rectangular_cutout_filleted_edge_count,
                            preview_assembly.generated_lid_sketch_add_count,
                            preview_assembly
                                .generated_lid_sketch_add_filleted_edge_count,
                            preview_assembly.generated_lid_button_group_count,
                            preview_assembly.generated_lid_button_cutout_count,
                            preview_assembly.generated_lid_button_ring_count,
                            preview_assembly.generated_lid_button_cap_count,
                            preview_assembly.generated_lid_button_stem_count,
                            preview_assembly.generated_lid_button_guide_count,
                            preview_assembly
                                .generated_lid_button_travel_stop_count,
                            preview_assembly.applied_feature_intent_count,
                            parsed_request.feature_intent_count,
                            feature_cuts);
    if (parsed_request.request.operation == "export_step") {
      const StepExportResult export_result =
          ExportStepFile(preview_assembly.shape,
                         parsed_request.export_output_path);
      WriteRoundedEnclosureStepExportResponse(parsed_request.request,
                                              parsed_request.enclosure,
                                              metrics,
                                              export_result);
    } else if (parsed_request.request.operation == "export_stl") {
      const StlExportResult export_result =
          ExportStlFile(preview_assembly.shape,
                        parsed_request.export_output_path);
      WriteRoundedEnclosureStlExportResponse(parsed_request.request,
                                             parsed_request.enclosure,
                                             metrics,
                                             export_result);
    } else {
      const PreviewMeshData mesh =
          BuildPreviewMesh(preview_assembly.shape,
                           metrics,
                           parsed_request.enclosure,
                           parsed_request.lid_screw_bosses,
                           parsed_request.generated_lid_seats,
                           parsed_request.generated_lid_plates,
                           parsed_request.usb_c_cutouts,
                           parsed_request.glass_recesses,
                           parsed_request.circular_cutouts,
                           parsed_request.rectangular_cutouts,
                           parsed_request.sketch_adds,
                           parsed_request.button_groups,
                           parsed_request.standoff_groups);
      WriteRoundedEnclosurePreviewResponse(
          parsed_request.request, parsed_request.enclosure, metrics, mesh);
    }
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
