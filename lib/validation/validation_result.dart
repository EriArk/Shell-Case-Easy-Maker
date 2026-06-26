class ValidationReport {
  const ValidationReport({required this.messages});

  final List<ValidationMessage> messages;

  bool get isClean => messages.every((message) => !message.isBlocking);

  bool get hasErrors =>
      messages.any((message) => message.severity == ValidationSeverity.error);
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
