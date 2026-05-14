import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Single source of truth for the SupabaseClient.
/// All repositories get the client via this provider, never via Supabase.instance.
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
