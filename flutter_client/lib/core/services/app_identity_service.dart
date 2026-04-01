import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppIdentityService extends ChangeNotifier {
  AppIdentityService._();

  static final AppIdentityService instance = AppIdentityService._();

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

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
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
    // The app user identity comes from the active Supabase session.
    final authUser = _client?.auth.currentUser;
    return authUser?.id;
  }
}
