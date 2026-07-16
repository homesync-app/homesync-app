import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/settings_repository.dart';

class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient _client;

  SupabaseSettingsRepository({required SupabaseClient client})
      : _client = client;

  @override
  Future<Map<String, dynamic>> deleteAccount() async {
    // SECURITY DEFINER RPC; resolves the caller via current_app_user_id() and
    // only ever deletes the caller's own data. Firebase credential deletion +
    // sign-out are handled by the caller (DeleteAccountUseCase).
    final response = await _client.rpc('delete_account');
    return Map<String, dynamic>.from(response);
  }
}
