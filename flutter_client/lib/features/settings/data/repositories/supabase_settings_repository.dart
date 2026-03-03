import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/settings_repository.dart';

class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient _client;

  SupabaseSettingsRepository({required SupabaseClient client})
      : _client = client;

  @override
  Future<Map<String, dynamic>> resetUserAccount() async {
    final response = await _client.rpc('reset_user_account');
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<void> updateAvatar(String avatarUrl) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    await _client
        .from('users')
        .update({'avatar_url': avatarUrl})
        .eq('id', user.id);
  }

  @override
  Future<void> updateFullName(String name) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    await _client
        .from('users')
        .update({'full_name': name})
        .eq('id', user.id);
  }

  @override
  Future<void> updateNotificationSettings(bool enabled) async {
    // This currently updates local shared preferences via a Notifier
    // but we could store it in the database too in the future.
    // For now, the implementation might be just a placeholder or 
    // it could interact with Supabase if we add it to the 'users' table.
  }
}
