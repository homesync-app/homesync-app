import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/dashboard/domain/models/solo_progress_snapshot.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';

final soloWeeklyRitualProvider = StateProvider<Set<SoloWeeklyRitualStep>>(
  (ref) => const {},
);

final soloProgressServerSnapshotProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final householdId = await ref.watch(householdIdProvider.future);
  if (userId == null || householdId == null) return null;

  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client.rpc(
      'get_solo_progress_snapshot',
      params: {
        'p_user_id': userId,
        'p_household_id': householdId,
      },
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
  } catch (_) {
    return null;
  }
  return null;
});

final soloProgressSnapshotProvider = Provider<SoloProgressSnapshot>((ref) {
  final balance = ref.watch(userBalanceProvider).value;
  final tasks = ref.watch(tasksProvider).value ?? const [];
  final todayTasks = ref.watch(todayTasksProvider).value ?? const [];
  final financeSummary = ref.watch(personalFinanceSummaryProvider).value;
  final recentActivities =
      ref.watch(recentActivityProvider).value ?? const <Map<String, dynamic>>[];
  final stats = ref.watch(statsControllerProvider).value;
  final serverSnapshot = ref.watch(soloProgressServerSnapshotProvider).value;

  return SoloProgressSnapshot.fromInputs(
    xp: (balance?['xp'] as num?)?.toInt() ?? 0,
    tasks: tasks,
    todayTasks: todayTasks,
    financeSummary: financeSummary,
    recentActivities: recentActivities,
    taskStats: stats?.taskStats ?? const <Map<String, dynamic>>[],
    memberStats: stats?.memberActivity ?? const <Map<String, dynamic>>[],
    xpHistory: stats?.xpHistory ?? const <Map<String, dynamic>>[],
    serverSnapshot: serverSnapshot,
  );
});
