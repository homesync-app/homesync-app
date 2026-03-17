import 'package:supabase_flutter/supabase_flutter.dart';
import '../../errors/failures.dart';
import 'package:homesync_client/core/services/retry/retry_service.dart';

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
    final retryService = RetryService();
    return retryService.executeWithRetry(
      request: () async {
        try {
          return await request();
        } on PostgrestException catch (e) {
          if (_isRateLimitError(e)) {
            throw RateLimitException(
              'Rate limit exceeded after $_maxRetries attempts',
              timeUntilReset: _extractRetryAfter(e),
            );
          }
          rethrow;
        }
      },
      policy: const RetryPolicy(
        maxRetries: _maxRetries,
        initialDelay: _initialDelay,
        maxDelay: _maxDelay,
        exponentialBackoff: true,
        jitterRatio: 0.3,
      ),
      shouldRetry: (_) => true,
    );
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
