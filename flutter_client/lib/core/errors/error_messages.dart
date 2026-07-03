import '../../l10n/generated/app_localizations.dart';
import 'failures.dart';

/// Default user-facing fallback when an error has no safe, specific message.
///
/// Spanish literal kept for callers without a BuildContext (and legacy tests);
/// UI call sites should pass [AppLocalizations] to `friendlyErrorMessage` so
/// the message follows the app locale.
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
/// Pass [t] (AppLocalizations) whenever a context is available so the message
/// follows the app locale; without it the legacy Spanish literals are used.
/// Pass [fallback] to customize the generic case per call site.
String friendlyErrorMessage(
  Object? error, {
  AppLocalizations? t,
  String? fallback,
}) {
  final generic = fallback ?? t?.errorGeneric ?? kGenericErrorMessage;
  if (error == null) return generic;

  // Domain failures already carry a human message (without the runtimeType
  // prefix that `Failure.toString()` would add). Known default messages are
  // swapped for their localized equivalent; custom ones pass through.
  if (error is Failure) {
    final message = error.message.trim();
    if (message.isEmpty) return generic;
    if (t != null) {
      if (error is NetworkFailure && message == kNetworkFailureDefault) {
        return t.errorServerUnreachable;
      }
      if (error is AuthFailure && message == kAuthFailureDefault) {
        return t.errorNotAuthenticated;
      }
      if (error is HouseholdFailure && message == kHouseholdFailureDefault) {
        return t.errorHouseholdNotFound;
      }
    }
    return message;
  }
  if (error is NetworkException || error is OfflineException) {
    return t?.errorOffline ?? 'Sin conexión. Verificá tu red e intentá de nuevo.';
  }
  if (error is RateLimitException) {
    return t?.errorTooManyRequests ??
        'Demasiadas solicitudes. Reintentá en un momento.';
  }

  // Last resort: heuristics for low-level errors that leak as plain exceptions.
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('connection refused') ||
      lower.contains('connection closed') ||
      lower.contains('connection reset')) {
    return t?.errorServerUnreachable ??
        'No pudimos conectar con el servidor. Verificá tu red.';
  }
  if (lower.contains('timeoutexception') || lower.contains('timed out')) {
    return t?.errorTimeout ?? 'La operación tardó demasiado. Probá de nuevo.';
  }
  if (raw.contains('429') || lower.contains('rate limit')) {
    return t?.errorTooManyRequests ??
        'Demasiadas solicitudes. Reintentá en un momento.';
  }
  // Anything else is an unexpected/internal error — never show it verbatim.
  return generic;
}
