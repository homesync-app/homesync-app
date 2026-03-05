/// Base class for all domain-level failures.
/// Instead of throwing raw exceptions, use Failures to communicate errors
/// in a typed, predictable way through the architecture layers.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Failures coming from Supabase / network calls
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failures from local validation / business rules
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// When the user is not authenticated
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Usuario no autenticado']);
}

/// When the user does not belong to a household
class HouseholdFailure extends Failure {
  const HouseholdFailure([super.message = 'Hogar no encontrado']);
}

/// When coins are insufficient for redemption
class InsufficientCoinsFailure extends Failure {
  final int available;
  final int required;
  const InsufficientCoinsFailure(
      {required this.available, required this.required})
      : super('Coins insuficientes: tenés $available, necesitás $required');
}

/// Exception thrown when rate limited (429)
class RateLimitException implements Exception {
  final String message;
  final Duration? timeUntilReset;
  const RateLimitException(this.message, {this.timeUntilReset});

  @override
  String toString() => 'RateLimitException: $message';
}

/// Exception thrown when network is unavailable
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when offline and request cannot be completed
class OfflineException implements Exception {
  final String message;
  const OfflineException(this.message);

  @override
  String toString() => 'OfflineException: $message';
}
