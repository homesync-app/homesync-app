import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(String householdId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      
      final response = await _client
          .from('household_activities')
          .select('''
            id, event_type, title, description, metadata, created_at,
            user:users!household_activities_user_id_fkey(id, full_name, avatar_url)
          ''')
          .eq('household_id', householdId)
          .gte('created_at', startOfDay) // Only today's activity
          .order('created_at', ascending: false)
          .limit(30);

      final activities = (response as List).map((item) {
        final eventType = item['event_type'] as String;
        final user = item['user'] as Map<String, dynamic>?;
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
          data['task_title'] = item['title'];
          data['xp_reward'] = metadata['xp_reward'] ?? metadata['xpReward'] ?? metadata['p_xp_reward'] ?? metadata['score_impact'] ?? metadata['xp'] ?? metadata['reward'];
        } else if (eventType == 'expense_added') {
          uiType = 'expense';
          data['amount'] = metadata['amount'] ?? 0;
          data['description'] = item['description']; // Include description for detail check
          data['expense_id'] = metadata['expense_id'] ?? metadata['id']; 
        } else if (eventType == 'reward_redeemed') {
          uiType = 'task'; // Denotes productivity/rewards
          data['task_title'] = 'Canjeó premio: ${item['title']}';
        }

        return {
          'id': item['id'], // Important for keys
          'type': uiType,
          'data': data,
          'created_at': item['created_at'],
        };
      }).where((activity) {
        final data = activity['data'] as Map<String, dynamic>;
        final type = activity['type'] as String;
        
        if (type == 'expense') {
          final isIncome = data['type'] == 'income' || data['type'] == 'ingreso';
          if (isIncome) return false;

          // If metadata explicitly says it's not shared or it's personal, hide it
          if (data['is_shared'] == false) return false;
          if (data['split_type'] == 'personal') return false;
          
          // Otherwise, assume it's a shared expense/activity
        }
        
        return true;
      }).toList();

      return activities;
    } catch (e) {
      dev.log('Error fetching activities from household_activities: $e');
      return [];
    }
  }
}
