import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/settings_repository.dart';

class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient _client;

  SupabaseSettingsRepository({required SupabaseClient client})
      : _client = client;

  Future<String> _requireCurrentUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }

    throw Exception('No autenticado');
  }

  @override
  Future<Map<String, dynamic>> resetUserAccount() async {
    final response = await _client.rpc('reset_user_account');
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<void> updateAvatar(String avatarUrl) async {
    // Direct RLS updates on `users` fail under Firebase JWTs. Use the
    // SECURITY DEFINER RPC that resolves the caller via current_app_user_id().
    await _requireCurrentUserId();
    await _client.rpc(
      'update_own_profile',
      params: {'p_full_name': null, 'p_avatar_url': avatarUrl},
    );
  }

  @override
  Future<void> updateFullName(String name) async {
    // Direct RLS updates on `users` fail under Firebase JWTs. Use the
    // SECURITY DEFINER RPC that resolves the caller via current_app_user_id().
    await _requireCurrentUserId();
    await _client.rpc(
      'update_own_profile',
      params: {'p_full_name': name, 'p_avatar_url': null},
    );
  }

  @override
  Future<void> updateNotificationSettings(bool enabled) async {}
}
