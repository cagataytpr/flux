/// Flux Application - App Failure
///
/// A unified failure model for error handling across the app.
library;

/// Represents a domain-level failure.
///
/// Features should extend this to create specific failure types,
/// or use it directly for generic errors.
class Failure {
  const Failure({required this.message, this.code});

  /// Human-readable error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
