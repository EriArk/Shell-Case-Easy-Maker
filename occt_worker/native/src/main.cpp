#include <iostream>
#include <iterator>
#include <optional>
#include <string>
#include <string_view>

namespace {

constexpr const char* kRequestSchema = "shell_case.geometry.request";
constexpr const char* kResponseSchema = "shell_case.geometry.response";
constexpr const char* kBackend = "occt_worker_native_stub";
constexpr const char* kInvalidRequestId = "invalid_request";

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
        "worker.request.empty",
        "worker.request.invalid_json",
        "worker.request.invalid_schema",
        "worker.request.invalid_operation",
        "worker.backend.native_not_implemented"
      ],
      "notes": [
        "Native executable scaffold is present.",
        "OCCT is not linked in this target yet."
      ]
    }
  ]
})json";

struct NativeRequestEnvelope {
  std::string request_id = kInvalidRequestId;
  std::string schema;
  std::string operation;
};

struct NativeRequestParseResult {
  NativeRequestEnvelope request;
  std::string issue_code;
  std::string issue_message;

  bool ok() const { return issue_code.empty(); }
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

std::optional<std::string> ExtractTopLevelStringField(
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
            if (value_index >= json.size() || json[value_index] != '"') {
              return std::nullopt;
            }

            std::string value;
            std::size_t after_value = 0;
            if (!ParseJsonStringAt(json, value_index, &value, &after_value)) {
              return std::nullopt;
            }
            return value;
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

bool IsRecognizedOperation(const std::string& operation) {
  return operation == "preview_mesh" || operation == "export_step" ||
         operation == "export_stl" || operation == "validate";
}

NativeRequestParseResult ReadNativeRequestEnvelope(
    const std::string& payload) {
  NativeRequestParseResult result;
  const std::optional<std::string> request_id =
      ExtractTopLevelStringField(payload, "requestId");
  if (request_id.has_value() && !request_id->empty()) {
    result.request.request_id = *request_id;
  }

  const std::size_t first_token = SkipWhitespace(payload, 0);
  if (first_token == payload.size()) {
    result.issue_code = "worker.request.empty";
    result.issue_message = "Native worker request payload is empty.";
    return result;
  }

  if (payload[first_token] != '{') {
    result.issue_code = "worker.request.invalid_json";
    result.issue_message = "Native worker request payload must be a JSON object.";
    return result;
  }

  const std::optional<std::string> schema =
      ExtractTopLevelStringField(payload, "schema");
  if (!schema.has_value() || *schema != kRequestSchema) {
    result.issue_code = "worker.request.invalid_schema";
    result.issue_message =
        "Native worker request schema must be shell_case.geometry.request.";
    return result;
  }
  result.request.schema = *schema;

  const std::optional<std::string> operation =
      ExtractTopLevelStringField(payload, "operation");
  if (!operation.has_value() || !IsRecognizedOperation(*operation)) {
    result.issue_code = "worker.request.invalid_operation";
    result.issue_message =
        "Native worker request operation must be preview_mesh, export_step, "
        "export_stl, or validate.";
    return result;
  }
  result.request.operation = *operation;

  return result;
}

void WriteIssueResponse(const std::string& request_id,
                        const std::string& issue_code,
                        const std::string& issue_message,
                        const std::string& requested_operation) {
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
            << "    \"executable\": \"occt_worker_native_stub\"";

  if (!requested_operation.empty()) {
    std::cout << ",\n"
              << "    \"requestedOperation\": \""
              << EscapeJsonString(requested_operation) << "\"";
  }

  std::cout << "\n"
            << "  }\n"
            << "}\n";
}

void WriteInvalidArgumentResponse(const std::string& argument) {
  WriteIssueResponse(kInvalidRequestId,
                     "worker.cli.invalid_arguments",
                     "Unknown native worker argument: " + argument,
                     "");
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

  const NativeRequestParseResult parsed_request =
      ReadNativeRequestEnvelope(ReadStdin());
  if (!parsed_request.ok()) {
    WriteIssueResponse(parsed_request.request.request_id,
                       parsed_request.issue_code,
                       parsed_request.issue_message,
                       parsed_request.request.operation);
    return 2;
  }

  WriteIssueResponse(
      parsed_request.request.request_id,
      "worker.backend.native_not_implemented",
      "The native OCCT worker scaffold is built, but OCCT geometry generation "
      "is not implemented yet.",
      parsed_request.request.operation);
  return 2;
}
