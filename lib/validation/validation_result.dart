class ValidationReport {
  const ValidationReport({required this.messages});

  final List<ValidationMessage> messages;

  List<ValidationMessage> get issues => messages
      .where(
        (message) =>
            message.severity == ValidationSeverity.error ||
            message.severity == ValidationSeverity.warning,
      )
      .toList(growable: false);

  List<ValidationMessage> get errors => messages
      .where((message) => message.severity == ValidationSeverity.error)
      .toList(growable: false);

  List<ValidationMessage> get warnings => messages
      .where((message) => message.severity == ValidationSeverity.warning)
      .toList(growable: false);

  bool get isClean => messages.every((message) => !message.isBlocking);

  bool get hasErrors =>
      messages.any((message) => message.severity == ValidationSeverity.error);

  bool get hasWarnings =>
      messages.any((message) => message.severity == ValidationSeverity.warning);

  bool get hasIssues => hasErrors || hasWarnings;

  ValidationMessage? get primaryIssue {
    final error = errors.firstOrNull;
    if (error != null) {
      return error;
    }

    return warnings.firstOrNull;
  }
}

class ValidationMessage {
  const ValidationMessage({
    required this.severity,
    required this.code,
    required this.message,
    this.targetId,
  });

  final ValidationSeverity severity;
  final String code;
  final String message;
  final String? targetId;

  bool get isBlocking => severity == ValidationSeverity.error;
}

enum ValidationSeverity { info, warning, error }
