import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../errors/failures.dart';

/// Base class for all RPC services.
/// Provides retry logic and rate limit handling.
abstract class BaseRpcService {
  final SupabaseClient client;

  BaseRpcService({SupabaseClient? clientOverride})
      : client = clientOverride ?? Supabase.instance.client;

  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 30);

  Future<T> executeWithRetry<T>(
    Future<T> Function() request, {
    String operation = 'RPC',
  }) async {
    int retryCount = 0;
    Duration delay = _initialDelay;

    while (true) {
      try {
        return await request();
      } on PostgrestException catch (e) {
        if (_isRateLimitError(e)) {
          retryCount++;
          if (retryCount >= _maxRetries) {
            throw RateLimitException(
              'Rate limit exceeded after $retryCount attempts',
              timeUntilReset: _extractRetryAfter(e),
            );
          }

          await Future.delayed(delay);
          if (delay.inSeconds < _maxDelay.inSeconds) {
            delay = Duration(
                seconds: min(delay.inSeconds * 2, _maxDelay.inSeconds));
          }
        } else {
          rethrow;
        }
      } catch (e) {
        if (e is RateLimitException) rethrow;

        retryCount++;
        if (retryCount >= _maxRetries) {
          throw NetworkException(
              'Operation failed after $_maxRetries attempts: $e');
        }

        await Future.delayed(delay);
        if (delay.inSeconds < _maxDelay.inSeconds) {
          delay =
              Duration(seconds: min(delay.inSeconds * 2, _maxDelay.inSeconds));
        }
      }
    }
  }

  bool _isRateLimitError(PostgrestException e) {
    return e.code == '429' ||
        e.message.toLowerCase().contains('rate limit') ||
        e.message.toLowerCase().contains('too many requests');
  }

  Duration? _extractRetryAfter(PostgrestException e) {
    final match = RegExp(r'retry[- ]?after["\s:]+(\d+)').firstMatch(e.message);
    if (match != null) {
      final seconds = int.tryParse(match.group(1) ?? '');
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    return null;
  }

  String generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
