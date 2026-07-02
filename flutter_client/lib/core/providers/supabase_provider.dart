import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Single source of truth for the SupabaseClient.
/// All repositories get the client via this provider, never via Supabase.instance.
///
/// keepAlive: wraps the global [Supabase.instance.client] singleton, which has
/// no disposable state and lives for the whole app. Marking it keepAlive lets
/// the many keepAlive repository providers depend on it without forcing an
/// auto-dispose provider to behave as keepAlive (riverpod_lint
/// only_use_keep_alive_inside_keep_alive).
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
