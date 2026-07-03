import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'logger_service.dart';

class AppIdentityService extends ChangeNotifier {
  AppIdentityService._();

  static final AppIdentityService instance = AppIdentityService._();

  // Defensa en profundidad: la raíz (auth.uid() casteado a uuid en el RPC) ya
  // está arreglada server-side, pero un Firebase UID crudo cacheado acá
  // envenenaría todos los RPCs de finanzas/tareas. Rechazar la escritura es
  // gratis y deja rastro en logs.
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  SupabaseClient? _client;
  String? _currentUserId;
  String? _debugOverrideUserId;
  String? _debugOverrideHouseholdId;
  bool _initialized = false;
  bool _isRefreshing = false;

  String? get currentUserId => _debugOverrideUserId ?? _currentUserId;
  String? get currentHouseholdId => _debugOverrideHouseholdId;

  void configure({required SupabaseClient client}) {
    _client = client;
  }

  void setDebugOverride(String? userId, {String? householdId}) {
    if (_debugOverrideUserId != userId ||
        _debugOverrideHouseholdId != householdId) {
      _debugOverrideUserId = userId;
      _debugOverrideHouseholdId = householdId;
      notifyListeners();
    }
  }

  /// Directly sets the resolved user ID (e.g., from a security-definer RPC
  /// whose return value is already trusted, avoiding an extra anon DB query).
  void setDirectUserId(String userId) {
    if (!_uuidPattern.hasMatch(userId)) {
      log.w(
        'AppIdentityService.setDirectUserId rejected non-uuid value: $userId',
        stackTrace: StackTrace.current,
      );
      return;
    }
    if (userId != _currentUserId) {
      _currentUserId = userId;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
  }

  Future<String?> refresh() async {
    if (_isRefreshing) return _currentUserId;

    final firebaseUser = fa.FirebaseAuth.instance.currentUser;

    // No Firebase session → sign-out state
    if (firebaseUser == null) {
      if (_currentUserId != null) {
        _currentUserId = null;
        notifyListeners();
      }
      return null;
    }

    // Fast path: UUID already resolved (set by login flow via setDirectUserId)
    if (_currentUserId != null) return _currentUserId;

    // Cold start: resolve UUID via ensure_user_profile RPC.
    // This function is SECURITY DEFINER so it bypasses RLS and works
    // with Firebase JWTs where auth.uid() does not return a valid UUID.
    _isRefreshing = true;
    try {
      if (_client != null) {
        final result = await _client!.rpc<dynamic>(
          'ensure_user_profile',
          params: {
            'p_firebase_uid': firebaseUser.uid,
            'p_email': firebaseUser.email ?? '',
            'p_full_name': firebaseUser.displayName,
            'p_avatar_url': firebaseUser.photoURL,
          },
        );
        final userId = result?.toString();
        if (userId != null && userId.isNotEmpty) {
          _currentUserId = userId;
          notifyListeners();
        }
      }
    } catch (e) {
      // RPC failed (network issue, not yet deployed) — keep null
    } finally {
      _isRefreshing = false;
    }

    return currentUserId;
  }
}
