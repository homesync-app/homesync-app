import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(
      String householdId, String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay =
          DateTime(today.year, today.month, today.day).toIso8601String();

      final response = await _client
          .from('household_activities')
          .select('''
            id, event_type, title, description, metadata, created_at, user_id,
            user:users!household_activities_user_id_fkey(id, full_name, avatar_url)
          ''')
          .eq('household_id', householdId)
          .gte('created_at', startOfDay) // Only today's activity
          .order('created_at', ascending: false)
          .limit(30);

      final activities = (response as List).map((item) {
        final eventType = item['event_type'] as String;
        final user = item['user'] as Map<String, dynamic>?;
        final creatorId = item['user_id'] as String?;
        final userName = user?['full_name'] ?? 'Alguien';
        final userAvatar = user?['avatar_url'];
        final metadata = Map<String, dynamic>.from(item['metadata'] ?? {});

        String uiType = 'unknown';
        final data = <String, dynamic>{
          'user_name': userName,
          'avatar_url': userAvatar,
          'title': item['title'],
          ...metadata,
        };

        if (eventType == 'task_completed') {
          uiType = 'task';
          final taskTitle = metadata['task_title'] ?? item['title'] ?? 'una tarea';
          data['title'] = 'Complet\u00f3 la tarea: $taskTitle';
          data['task_title'] = taskTitle;
          data['xp_reward'] = metadata['xp_reward'] ??
              metadata['xpReward'] ??
              metadata['p_xp_reward'] ??
              metadata['score_impact'] ??
              metadata['xp'] ??
              metadata['reward'];
        } else if (eventType == 'expense_added') {
          uiType = 'expense';
          final amount = metadata['amount'] ?? 0;
          final expenseDesc = item['description'] ?? metadata['description'] ?? 'un gasto';
          data['title'] = 'Agreg\u00f3 un gasto: $expenseDesc';
          data['amount'] = amount;
          data['description'] = expenseDesc;
          data['expense_id'] = metadata['expense_id'] ?? metadata['id'];
          data['is_shared'] = metadata['is_shared'];
          data['split_type'] = metadata['split_type'];
        } else if (eventType == 'reward_redeemed') {
          uiType = 'task';
          data['title'] = 'Canje\u00f3 un premio: ${item['title'] ?? 'Premio'}';
        } else {
          data['title'] = item['title'] ?? item['description'] ?? 'Realiz\u00f3 una acci\u00f3n';
        }

        return {
          'id': item['id'],
          'type': uiType,
          'data': data,
          'created_at': item['created_at'],
          'creator_id': creatorId,
        };
      }).where((activity) {
        final data = activity['data'] as Map<String, dynamic>;
        final type = activity['type'] as String;
        final creatorId = activity['creator_id'] as String?;

        if (type == 'expense') {
          final isIncome = data['type'] == 'income' ||
              data['type'] == 'ingreso' ||
              data['category'] == 'salary';
          if (isIncome) return false;

          final isShared = data['is_shared'] == true;
          final splitType = (data['split_type'] as String?)?.toLowerCase();
          final isGift = splitType == 'gift' || splitType == 'regalo';

          final shouldShow = isShared || isGift || creatorId == userId;

          dev.log(
              'Activity Filter Trace [Expense]: title="${data['title']}", isShared=$isShared, isGift=$isGift, creatorId=$creatorId, currentUserId=$userId, results SHOW=$shouldShow');

          return shouldShow;
        }

        return true;
      }).toList();

      dev.log(
          'SupabaseDashboardRepository: Fetched ${activities.length} activities');
      return activities;
    } catch (e) {
      dev.log('Error fetching activities: $e');
      return [];
    }
  }
}
