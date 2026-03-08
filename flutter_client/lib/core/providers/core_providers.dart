import 'package:homesync_client/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/reward_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/stats_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/household_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/balance_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/admin_rpc_service.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/notification_service.dart';

part 'core_providers.g.dart';

@riverpod
class BottomNavIndex extends _$BottomNavIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

// ── Singleton service providers ───────────────────────────────────────────────
@riverpod
SupabaseAuthService authService(AuthServiceRef ref) {
  throw UnimplementedError('authService must be overridden in ProviderScope.');
}

@riverpod
TaskRpcService taskRpcService(TaskRpcServiceRef ref) => TaskRpcService();

@riverpod
RewardRpcService rewardRpcService(RewardRpcServiceRef ref) => RewardRpcService();

@riverpod
StatsRpcService statsRpcService(StatsRpcServiceRef ref) => StatsRpcService();

@riverpod
HouseholdRpcService householdRpcService(HouseholdRpcServiceRef ref) => HouseholdRpcService();

@riverpod
BalanceRpcService balanceRpcService(BalanceRpcServiceRef ref) => BalanceRpcService();

@riverpod
AdminRpcService adminRpcService(AdminRpcServiceRef ref) => AdminRpcService();

// ── Current user convenience providers ────────────────────────────────────────
@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.currentUser?.id;
}

// ── Household ID — single source of truth ─────────────────────────────────────
@riverpod
Future<String?> householdId(HouseholdIdRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final client = ref.read(supabaseClientProvider);
  final List<dynamic> response = await client
      .from('household_members')
      .select('household_id')
      .eq('user_id', userId)
      .limit(1);

  if (response.isEmpty) return null;
  return response.first['household_id'] as String?;
}

// ── User profile (full_name, avatar) ──────────────────────────────────────────
@riverpod
Stream<Map<String, dynamic>?> userProfile(UserProfileRef ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    yield null;
    return;
  }

  final client = ref.read(supabaseClientProvider);

  Future<Map<String, dynamic>?> fetch() async {
    final List<dynamic> response = await client
        .from('users')
        .select('id, full_name, email, avatar_url, mercadopago_alias')
        .eq('id', userId)
        .limit(1);
        
    return response.isNotEmpty ? response.first as Map<String, dynamic> : null;
  }

  yield await fetch();

  final channel = client
      .channel('user_profile_$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'users',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: userId,
        ),
        callback: (payload) {
          log.i('Realtime user profile change detected: ${payload.eventType}');
          ref.invalidateSelf();
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
  });
}

// ── Mercado Pago connection status ─────────────────────────────────────────────
@riverpod
Stream<Map<String, dynamic>?> mercadopagoConnection(MercadopagoConnectionRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  final client = ref.read(supabaseClientProvider);
  return client
      .from('mercadopago_connections')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map((data) => data.isNotEmpty ? data.first : null);
}

@riverpod
Future<List<Map<String, dynamic>>> mercadopagoMovements(MercadopagoMovementsRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final connection = ref.watch(mercadopagoConnectionProvider).value;
  if (connection == null) return [];

  try {
    final client = ref.read(supabaseClientProvider);
    final response = await client.functions.invoke(
      'mercadopago-api',
      body: {
        'action': 'get_recent_movements',
        'userId': userId,
      },
    );

    if (response.status == 200) {
      final movements =
          (response.data['movements'] as List).cast<Map<String, dynamic>>();
      return movements;
    }
    return [];
  } catch (e) {
    log.e('Error fetching MP movements: $e', error: e);
    return [];
  }
}

// ── User balance (XP + coins) ─────────────────────────────────────────────────
@riverpod
Stream<Map<String, dynamic>?> userBalance(UserBalanceRef ref) async* {
  final householdId = await ref.watch(householdIdProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  if (householdId == null || userId == null) {
    yield null;
    return;
  }

  final client = ref.read(supabaseClientProvider);
  final rpc = ref.read(balanceRpcServiceProvider);

  Future<Map<String, dynamic>?> fetch() async {
    final result = await rpc.getUserBalance(householdId: householdId);
    return result['data'] as Map<String, dynamic>?;
  }

  yield await fetch();

  final channel = client
      .channel('user_balance_$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ledger_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          log.i('Realtime balance change detected (ledger entry): ${payload.eventType}');
          ref.invalidateSelf();
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
  });
}

// ── Notifications enabled provider ──────────────────────────────────────────
@riverpod
class NotificationEnabled extends _$NotificationEnabled {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    // Update the service
    await NotificationService.instance.setEnabled(enabled);
  }
}
