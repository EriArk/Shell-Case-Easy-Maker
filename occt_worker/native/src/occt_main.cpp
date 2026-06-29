#include <BRepPrimAPI_MakeBox.hxx>
#include <Standard_Version.hxx>
#include <TopoDS_Shape.hxx>

#include <iostream>
#include <iterator>
#include <string>

#ifndef OCC_VERSION_COMPLETE
#define OCC_VERSION_COMPLETE "unknown"
#endif

namespace {

constexpr const char* kResponseSchema = "shell_case.geometry.response";
constexpr const char* kBackend = "occt_worker_native_occt";

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

TopoDS_Shape BuildLinkSmokeShape() {
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
      << "      \"status\": \"linked_smoke\",\n"
      << "      \"supportedOperations\": [],\n"
      << "      \"plannedOperations\": [\n"
      << "        \"preview_mesh\",\n"
      << "        \"export_step\",\n"
      << "        \"export_stl\",\n"
      << "        \"validate\"\n"
      << "      ],\n"
      << "      \"issueCodes\": [\n"
      << "        \"worker.backend.occt_link_smoke_only\"\n"
      << "      ],\n"
      << "      \"notes\": [\n"
      << "        \"OCCT-linked native target was built.\",\n"
      << "        \"Semantic enclosure generation is not implemented in this target yet.\"\n"
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
                        bool link_smoke_shape_null) {
  std::cout << "{\n"
            << "  \"schema\": \"" << kResponseSchema << "\",\n"
            << "  \"version\": 1,\n"
            << "  \"requestId\": \"" << EscapeJsonString(request_id) << "\",\n"
            << "  \"status\": \"error\",\n"
            << "  \"backend\": \"" << kBackend << "\",\n"
            << "  \"issues\": [\n"
            << "    {\n"
            << "      \"severity\": \"error\",\n"
            << "      \"code\": \"" << EscapeJsonString(issue_code) << "\",\n"
            << "      \"message\": \"" << EscapeJsonString(issue_message)
            << "\"\n"
            << "    }\n"
            << "  ],\n"
            << "  \"metrics\": {\n"
            << "    \"requestedBackend\": \"native\",\n"
            << "    \"executable\": \"occt_worker_native_occt\",\n"
            << "    \"occtVersion\": \""
            << EscapeJsonString(OCC_VERSION_COMPLETE) << "\",\n"
            << "    \"linkSmokeShapeNull\": "
            << (link_smoke_shape_null ? "true" : "false") << "\n"
            << "  }\n"
            << "}\n";
}

void WriteInvalidArgumentResponse(const std::string& argument) {
  WriteIssueResponse("invalid_request",
                     "worker.cli.invalid_arguments",
                     "Unknown native OCCT worker argument: " + argument,
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

  const TopoDS_Shape link_smoke_shape = BuildLinkSmokeShape();
  const bool link_smoke_shape_null = link_smoke_shape.IsNull();

  if (emit_capabilities) {
    WriteCapabilities();
    return link_smoke_shape_null ? 2 : 0;
  }

  const std::string payload = ReadStdin();
  (void)payload;

  WriteIssueResponse(
      "occt_link_smoke_request",
      "worker.backend.occt_link_smoke_only",
      "The native OCCT worker target is linked, but semantic enclosure "
      "generation is not implemented in this target yet.",
      link_smoke_shape_null);
  return 2;
}
