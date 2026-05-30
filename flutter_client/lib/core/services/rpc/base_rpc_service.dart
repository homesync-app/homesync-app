import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/retry/retry_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      shouldRetry: _shouldRetryRpcException,
    );
  }

  /// True solo para errores transitorios — no para fallas permanentes que el
  /// servidor no resolverá esperando.
  ///
  /// Antes era `(_) => true`, que reintentaba TODO. Eso causaba que después de
  /// un primer intento exitoso server-side cuya respuesta se perdió, el retry
  /// volviera a insertar y pegara contra una unique constraint (Crashlytics
  /// 68638317 — 23505 en `tasks_unique_active_per_household`, 17 eventos).
  ///
  /// NO se reintentan:
  ///  • Postgres data-integrity (23xxx): unique, FK, NOT NULL, check.
  ///  • Postgres invalid-input (22xxx): tipos, rangos.
  ///  • Postgres syntax / access-rule (42xxx): incluye RLS 42501.
  ///  • HTTP 4xx (400, 401, 403, 404, 422...): error del cliente, no del server.
  ///
  /// Sí se reintentan: timeouts, sockets caidos, 5xx, rate-limit (manejado
  /// aparte por RetryService.RateLimitException).
  static bool _shouldRetryRpcException(Exception e) {
    if (e is PostgrestException) {
      final code = e.code ?? '';
      if (code.startsWith('23') ||
          code.startsWith('22') ||
          code.startsWith('42')) {
        return false;
      }
      // HTTP status como string ("400", "401", ...). 4xx no se reintenta.
      final asInt = int.tryParse(code);
      if (asInt != null && asInt >= 400 && asInt < 500) {
        return false;
      }
    }
    if (e is AuthException) return false;
    // Default conservador: reintentar (cubre timeouts, parseo, 5xx).
    return true;
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
