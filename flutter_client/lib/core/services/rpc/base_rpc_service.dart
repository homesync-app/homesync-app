import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/retry/retry_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/config/app_environment.dart';

import '../../errors/failures.dart';

/// Base class for all RPC services.
/// Provides retry logic, rate limit handling and a unified auth guard.
abstract class BaseRpcService {
  final SupabaseClient client;

  BaseRpcService({required SupabaseClient clientOverride})
      : client = clientOverride;

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

  Future<String> requireCurrentUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }

    throw Exception('Usuario no autenticado');
  }

  Future<String> requireHouseholdId() async {
    final debugHouseholdId = AppIdentityService.instance.currentHouseholdId;
    if (debugHouseholdId != null && debugHouseholdId.isNotEmpty) {
      return debugHouseholdId;
    }

    final userId = await requireCurrentUserId();
    final response = await client
        .from('household_members')
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null && response['household_id'] != null) {
      return response['household_id'] as String;
    }

    throw Exception('El usuario no pertenece a ningún hogar');
  }

  String? currentAuthEmail() {
    return fa.FirebaseAuth.instance.currentUser?.email;
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
