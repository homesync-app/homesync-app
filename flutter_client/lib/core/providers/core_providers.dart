import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/services/expense_service.dart';

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

// ── Singleton service providers ───────────────────────────────────────────────
final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  throw UnimplementedError('authServiceProvider must be overridden in ProviderScope.');
});

final rpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  throw UnimplementedError('rpcServiceProvider must be overridden in ProviderScope.');
});

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
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

// ── ExpenseModel balances for all household members ────────────────────────────────
final expenseBalancesProvider = FutureProvider<List<dynamic>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return [];

  final rpc = ref.read(rpcServiceProvider);
  final result = await rpc.getHouseholdBalances(householdId);
  return (result['balances'] as List<dynamic>?) ?? [];
});

// ── Recent activity (tasks + expenses combined) ───────────────────────────────
final recentActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return [];

  final client = Supabase.instance.client;
  final activities = <Map<String, dynamic>>[];
  final now = DateTime.now();
  final since = DateTime(now.year, now.month, now.day);




  // 1. Fetch Completed Tasks (joined with user info)
  try {
    // Note: We use aliases 'user' and 'completed_user' to satisfy different parts of the UI
    final tasksResponse = await client
        .from('tasks')
        .select('''
          id, title, category, xp_reward, coin_reward, completed_at, status, updated_at, created_at, objection_reason,
          user:users!tasks_completed_by_fkey(id, full_name, avatar_url),
          completed_user:users!tasks_completed_by_fkey(id, full_name, avatar_url)
        ''')
        .eq('household_id', householdId)
        .not('completed_at', 'is', null) 
        .gte('updated_at', since.toIso8601String())
        .order('updated_at', ascending: false)
        .limit(20);

    for (final t in tasksResponse) {
      final timeStr = t['completed_at'] ?? t['updated_at'] ?? t['created_at'];
      activities.add({
        'type': 'TaskModel',
        'data': t,
        'time': DateTime.parse(timeStr as String),
      });
    }
  } catch (e) {
    dev.log('Error fetching TaskModel history with join: $e');
    // Fallback: Fetch without JOIN if the FK name is wrong or schema changed
    try {
      final fallbackTasks = await client
          .from('tasks')
          .select('*')
          .eq('household_id', householdId)
          .not('completed_at', 'is', null)
          .gte('completed_at', since.toIso8601String())
          .order('updated_at', ascending: false)
          .limit(20);
      
      for (final t in fallbackTasks) {
        final timeStr = t['completed_at'] ?? t['updated_at'] ?? t['created_at'];
        activities.add({
          'type': 'TaskModel',
          'data': t,
          'time': DateTime.parse(timeStr as String),
        });
      }
    } catch (e2) {
      dev.log('Fallback TaskModel fetch failed: $e2');
    }
  }

  // 2. Fetch Expenses (joined with user info)
  try {
    final expensesResponse = await client
        .from('expenses')
        .select('''
          id, amount, title, category, split_type, created_at, paid_at, paid_by,
          user:users!expenses_paid_by_fkey(id, full_name, avatar_url)
        ''')
        .eq('household_id', householdId)
        .gte('created_at', since.toIso8601String())
        .order('created_at', ascending: false)
        .limit(20);

    for (final e in expensesResponse) {
      final timeStr = e['paid_at'] ?? e['created_at'];
      activities.add({
        'type': 'expense',
        'data': e,
        'time': DateTime.parse(timeStr as String),
      });
    }
  } catch (e) {
    dev.log('Error fetching expense history with join: $e');
    // Fallback ExpenseModel Fetch
    try {
      final fallbackExpenses = await client
          .from('expenses')
          .select('*')
          .eq('household_id', householdId)
          .gte('created_at', since.toIso8601String())
          .order('created_at', ascending: false)
          .limit(20);
      
      for (final e in fallbackExpenses) {
        final timeStr = e['paid_at'] ?? e['created_at'];
        activities.add({
          'type': 'expense',
          'data': e,
          'time': DateTime.parse(timeStr as String),
        });
      }
    } catch (_) {}
  }

  // 3. Final cleanup and sorting
  activities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
  
  return activities.take(30).toList();
});
