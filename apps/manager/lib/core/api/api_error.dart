// The client half of the error taxonomy (docs/eng/errors.md).
//
// The server maps every domain error to a Connect code and a message already
// localised to the caller's locale. So the app's job is NOT to invent copy
// for failures -- it is to render the message the server sent, and to branch
// on the code where the UI genuinely differs.
//
// That split is deliberate: bn is the source of truth and it lives in one
// place. A client that writes its own error strings ends up with two
// vocabularies that drift, and the user meets whichever one the screen
// happened to use.

/// The Connect error codes this app branches on.
///
/// Anything the server sends that is not listed here becomes
/// [ApiErrorCode.unknown] rather than throwing: a client that crashes on an
/// unfamiliar error code turns a recoverable failure into a lost session.
enum ApiErrorCode {
  unauthenticated,
  permissionDenied,
  notFound,
  invalidArgument,
  /// "The request was well-formed but the world is not in the right state" --
  /// cutoff passed, period closed, already voided. The UI usually needs to
  /// refetch rather than offer a plain retry.
  failedPrecondition,
  resourceExhausted,
  unavailable,
  deadlineExceeded,
  unimplemented,
  internal,
  unknown;

  static ApiErrorCode parse(String? wire) => switch (wire) {
        'unauthenticated' => ApiErrorCode.unauthenticated,
        'permission_denied' => ApiErrorCode.permissionDenied,
        'not_found' => ApiErrorCode.notFound,
        'invalid_argument' => ApiErrorCode.invalidArgument,
        'failed_precondition' => ApiErrorCode.failedPrecondition,
        'resource_exhausted' => ApiErrorCode.resourceExhausted,
        'unavailable' => ApiErrorCode.unavailable,
        'deadline_exceeded' => ApiErrorCode.deadlineExceeded,
        'unimplemented' => ApiErrorCode.unimplemented,
        'internal' => ApiErrorCode.internal,
        _ => ApiErrorCode.unknown,
      };
}

/// A failed call, carrying what the UI needs to decide what to show.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.requestId,
  });

  final ApiErrorCode code;

  /// Already localised by the server. Render it; do not translate it again.
  final String message;

  /// Every error carries one (docs/eng/errors.md). It is what a user quotes
  /// to support, so it has to survive as far as the error screen.
  final String? requestId;

  /// Whether retrying the same call could plausibly succeed.
  ///
  /// UX law 8 says no error without a retry -- but a retry button on
  /// "you are not the manager" is a lie, and mess wifi is bad enough that
  /// the distinction matters. Only transport-shaped failures are retryable.
  bool get isRetryable => switch (code) {
        ApiErrorCode.unavailable ||
        ApiErrorCode.deadlineExceeded ||
        ApiErrorCode.resourceExhausted ||
        ApiErrorCode.internal ||
        ApiErrorCode.unknown =>
          true,
        _ => false,
      };

  @override
  String toString() => 'ApiException(${code.name}: $message)';
}
