import 'dart:async';

import 'package:flutter_riverpod/misc.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _maxProviderRetries = 2;
const _initialProviderRetryDelay = Duration(milliseconds: 350);
const _maxProviderRetryDelay = Duration(seconds: 2);

Duration? appRiverpodRetry(int retryCount, Object error) {
  if (retryCount >= _maxProviderRetries) return null;
  if (!_isProviderRetryable(error)) return null;

  final multiplier = 1 << retryCount;
  final delay = _initialProviderRetryDelay * multiplier;
  if (delay > _maxProviderRetryDelay) return _maxProviderRetryDelay;
  return delay;
}

bool _isProviderRetryable(Object error) {
  if (error is ProviderException) return false;
  if (error is Error) return false;

  if (error is TimeoutException ||
      error is NetworkException ||
      error is OfflineException ||
      error is NetworkFailure ||
      error is RateLimitException) {
    return true;
  }

  if (error is ValidationFailure ||
      error is AuthFailure ||
      error is HouseholdFailure ||
      error is InsufficientCoinsFailure) {
    return false;
  }

  if (error is ServerFailure) {
    return _messageLooksTransient(error.message);
  }

  if (error is PostgrestException) {
    return _postgrestLooksTransient(error);
  }

  return _messageLooksTransient(error.toString());
}

bool _postgrestLooksTransient(PostgrestException error) {
  final code = error.code;
  if (code == '429' || code == '502' || code == '503' || code == '504') {
    return true;
  }
  return _messageLooksTransient(error.message);
}

bool _messageLooksTransient(String message) {
  final lower = message.toLowerCase();
  return lower.contains('network') ||
      lower.contains('timeout') ||
      lower.contains('timed out') ||
      lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('connection refused') ||
      lower.contains('connection reset') ||
      lower.contains('no se pudo establecer conexion') ||
      lower.contains('sin conexion') ||
      lower.contains('no hay conexion') ||
      lower.contains('rate limit') ||
      lower.contains('too many requests') ||
      lower.contains('temporarily unavailable') ||
      lower.contains('503') ||
      lower.contains('504') ||
      lower.contains('520');
}
