import 'failures.dart';

/// Default user-facing fallback when an error has no safe, specific message.
const String kGenericErrorMessage =
    'Algo salió mal. Probá de nuevo en un momento.';

/// Converts any caught error into a short, user-facing message.
///
/// The UI must NEVER surface a raw `toString()`: framework stack traces (e.g.
/// "Cannot use the Ref ... after it has been disposed"), or typed-`Failure`
/// prefixes like "ServerFailure: ...". The raw detail belongs in logs
/// (`log.e`/`log.w` → application_logs); the user gets the domain message or a
/// friendly fallback.
///
/// Pass [fallback] to localize/customize the generic case per call site.
String friendlyErrorMessage(
  Object? error, {
  String fallback = kGenericErrorMessage,
}) {
  if (error == null) return fallback;

  // Domain failures already carry a human message (without the runtimeType
  // prefix that `Failure.toString()` would add).
  if (error is Failure) {
    return error.message.trim().isEmpty ? fallback : error.message;
  }
  if (error is NetworkException || error is OfflineException) {
    return 'Sin conexión. Verificá tu red e intentá de nuevo.';
  }
  if (error is RateLimitException) {
    return 'Demasiadas solicitudes. Reintentá en un momento.';
  }

  // Last resort: heuristics for low-level errors that leak as plain exceptions.
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('connection refused') ||
      lower.contains('connection closed') ||
      lower.contains('connection reset')) {
    return 'No pudimos conectar con el servidor. Verificá tu red.';
  }
  if (lower.contains('timeoutexception') || lower.contains('timed out')) {
    return 'La operación tardó demasiado. Probá de nuevo.';
  }
  if (raw.contains('429') || lower.contains('rate limit')) {
    return 'Demasiadas solicitudes. Reintentá en un momento.';
  }
  // Anything else is an unexpected/internal error — never show it verbatim.
  return fallback;
}
