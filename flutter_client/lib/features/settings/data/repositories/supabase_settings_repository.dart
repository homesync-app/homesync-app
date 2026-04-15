import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/config/app_environment.dart';

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
    final userId = await _requireCurrentUserId();
    await _client
        .from('users')
        .update({'avatar_url': avatarUrl}).eq('id', userId);
  }

  @override
  Future<void> updateFullName(String name) async {
    final userId = await _requireCurrentUserId();
    await _client.from('users').update({'full_name': name}).eq('id', userId);
  }

  @override
  Future<void> updateNotificationSettings(bool enabled) async {}
}
