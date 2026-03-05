import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(
      String householdId) async {
    final activities = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 7));

    // 1. Fetch Completed Tasks (joined with user info)
    try {
      final tasksResponse = await _client
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
        final fallbackTasks = await _client
            .from('tasks')
            .select('*')
            .eq('household_id', householdId)
            .not('completed_at', 'is', null)
            .gte('completed_at', since.toIso8601String())
            .order('updated_at', ascending: false)
            .limit(20);

        for (final t in fallbackTasks) {
          final timeStr =
              t['completed_at'] ?? t['updated_at'] ?? t['created_at'];
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
      final expensesResponse = await _client
          .from('expenses')
          .select('''
            id, amount, title, category, split_type, is_shared, created_at, paid_at, paid_by,
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
        final fallbackExpenses = await _client
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
    activities.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return activities.take(30).toList();
  }
}
