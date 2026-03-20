import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(() {
  return BottomNavNotifier();
});

class ParejaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index.clamp(0, 1);
  }
}

final parejaTabIndexProvider = NotifierProvider<ParejaTabNotifier, int>(() {
  return ParejaTabNotifier();
});

// ── Auth state provider ──────────────────────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// ── Singleton service providers ───────────────────────────────────────────────
final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  throw UnimplementedError('authServiceProvider must be overridden in ProviderScope.');
});

final rpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  throw UnimplementedError('rpcServiceProvider must be overridden in ProviderScope.');
});

// ── Current user convenience providers ────────────────────────────────────────
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.currentUser?.id;
});

// ── Household ID — single source of truth ─────────────────────────────────────
final householdIdProvider = FutureProvider<String?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final client = Supabase.instance.client;
  final result = await client
      .from('household_members')
      .select('household_id')
      .eq('user_id', userId)
      .maybeSingle();

  return result?['household_id'] as String?;
});

// ── User profile (full_name, avatar) ──────────────────────────────────────────
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final client = Supabase.instance.client;
  return await client
      .from('users')
      .select('id, full_name, email, avatar_url, mercadopago_alias')
      .eq('id', userId)
      .maybeSingle();
});

// ── Mercado Pago connection status ─────────────────────────────────────────────
final mercadopagoConnectionProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  final client = Supabase.instance.client;
  return client
      .from('mercadopago_connections')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map((data) => data.isNotEmpty ? data.first : null);
});

final mercadopagoMovementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  // Re-check connection status
  final connection = ref.watch(mercadopagoConnectionProvider).value;
  if (connection == null) return [];

  try {
    final response = await Supabase.instance.client.functions.invoke(
      'mercadopago-api',
      body: {
        'action': 'get_recent_movements',
        'userId': userId,
      },
    );

    if (response.status == 200) {
      final movements = (response.data['movements'] as List).cast<Map<String, dynamic>>();
      return movements;
    }
    return [];
  } catch (e) {
    debugPrint('Error fetching MP movements: $e');
    return [];
  }
});

// ── User balance (XP + coins) ─────────────────────────────────────────────────
final userBalanceProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final householdAsync = await ref.watch(householdIdProvider.future);
  if (householdAsync == null) return null;

  final rpc = ref.read(rpcServiceProvider);
  final result = await rpc.getUserBalance(householdId: householdAsync);
  return result['data'] as Map<String, dynamic>?;
});

