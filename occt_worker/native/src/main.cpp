#include <iostream>
#include <iterator>
#include <string>

namespace {

constexpr const char* kCapabilitiesJson = R"json({
  "schema": "shell_case.geometry.worker.capabilities",
  "version": 1,
  "entrypoint": "occt_worker/native/occt_worker_native_stub",
  "defaultBackend": "native",
  "activeBackend": "native",
  "protocol": {
    "requestSchema": "shell_case.geometry.request",
    "responseSchema": "shell_case.geometry.response",
    "version": 1
  },
  "sourceOfTruth": "semantic_project",
  "editableGeneratedGeometry": false,
  "backends": [
    {
      "id": "native",
      "status": "stub",
      "supportedOperations": [],
      "plannedOperations": [
        "preview_mesh",
        "export_step",
        "export_stl",
        "validate"
      ],
      "issueCodes": [
        "worker.backend.native_not_implemented"
      ],
      "notes": [
        "Native executable scaffold is present.",
        "OCCT is not linked in this target yet."
      ]
    }
  ]
})json";

constexpr const char* kNativeStubResponseJson = R"json({
  "schema": "shell_case.geometry.response",
  "version": 1,
  "requestId": "native_stub_request",
  "status": "error",
  "backend": "occt_worker_native_stub",
  "issues": [
    {
      "severity": "error",
      "code": "worker.backend.native_not_implemented",
      "message": "The native OCCT worker scaffold is built, but OCCT geometry generation is not implemented yet."
    }
  ],
  "metrics": {
    "requestedBackend": "native",
    "executable": "occt_worker_native_stub"
  }
})json";

void DiscardStdin() {
  const std::string input{std::istreambuf_iterator<char>{std::cin},
                          std::istreambuf_iterator<char>{}};
  (void)input;
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

void WriteInvalidArgumentResponse(const std::string& argument) {
  const std::string escaped_argument = EscapeJsonString(argument);
  std::cout << "{\n"
            << "  \"schema\": \"shell_case.geometry.response\",\n"
            << "  \"version\": 1,\n"
            << "  \"requestId\": \"invalid_request\",\n"
            << "  \"status\": \"error\",\n"
            << "  \"backend\": \"occt_worker_native_stub\",\n"
            << "  \"issues\": [\n"
            << "    {\n"
            << "      \"severity\": \"error\",\n"
            << "      \"code\": \"worker.cli.invalid_arguments\",\n"
            << "      \"message\": \"Unknown native worker argument: "
            << escaped_argument << "\"\n"
            << "    }\n"
            << "  ]\n"
            << "}\n";
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

  if (emit_capabilities) {
    std::cout << kCapabilitiesJson << '\n';
    return 0;
  }

  DiscardStdin();
  std::cout << kNativeStubResponseJson << '\n';
  return 2;
}
