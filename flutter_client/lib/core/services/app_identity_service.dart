import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:homesync_client/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppIdentityService extends ChangeNotifier {
  AppIdentityService._();

  static final AppIdentityService instance = AppIdentityService._();

  final SupabaseClient _client = Supabase.instance.client;
  final fa.FirebaseAuth _firebaseAuth = fa.FirebaseAuth.instance;

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<fa.User?>? _firebaseSubscription;
  String? _currentUserId;
  String? _debugOverrideUserId;
  String? _debugOverrideHouseholdId;
  bool _initialized = false;
  bool _isRefreshing = false;

  String? get currentUserId => _debugOverrideUserId ?? _currentUserId;
  String? get currentHouseholdId => _debugOverrideHouseholdId;

  void setDebugOverride(String? userId, {String? householdId}) {
    if (_debugOverrideUserId != userId ||
        _debugOverrideHouseholdId != householdId) {
      _debugOverrideUserId = userId;
      _debugOverrideHouseholdId = householdId;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await refresh();
    if (AppEnvironment.usesFirebaseJwtForSupabase) {
      _firebaseSubscription = _firebaseAuth.idTokenChanges().listen((_) async {
        await refresh();
      });
    } else {
      _authSubscription = _client.auth.onAuthStateChange.listen((_) async {
        await refresh();
      });
    }
  }

  Future<String?> refresh() async {
    if (_isRefreshing) {
      return _currentUserId;
    }

    _isRefreshing = true;
    try {
      final resolvedUserId = await _resolveCurrentUserId();
      if (resolvedUserId != _currentUserId) {
        _currentUserId = resolvedUserId;
        notifyListeners();
      }
    } finally {
      _isRefreshing = false;
    }

    return currentUserId;
  }

  Future<String?> _resolveCurrentUserId() async {
    // Ya no es necesario el RPC bloqueante por red porque hemos vuelto
    // al flujo estandar de Third-Party Auth donde Supabase mantiene 
    // la sesion localmente de forma sincronica.
    final authUser = _client.auth.currentUser;
    return authUser?.id;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    _firebaseSubscription?.cancel();
    _firebaseSubscription = null;
    super.dispose();
  }
}
