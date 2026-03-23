import 'package:homesync_client/core/services/logger_service.dart';

import 'base_rpc_service.dart';

class StatsRpcService extends BaseRpcService {
  StatsRpcService({super.clientOverride});

  Future<List<Map<String, dynamic>>> getTaskStatsByCategory() async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'get_task_stats_by_category',
      params: {'p_user_id': userId},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getXpHistory() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_xp_history',
        params: {'p_user_id': userId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCoinHistory() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_coin_history',
        params: {'p_user_id': userId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExpenseStatsByCategory() async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'get_expense_stats_by_category',
      params: {'p_user_id': userId},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMemberActivityStats() async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'get_member_activity_stats',
      params: {'p_user_id': userId},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
    final userId = await requireCurrentUserId();
    final householdMembers = await client
        .from('household_members')
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (householdMembers == null) {
      return [];
    }

    final response = await client.rpc(
      'get_weekly_ranking',
      params: {'p_household_id': householdMembers['household_id']},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> isWeekProcessed() async {
    try {
      final userId = await requireCurrentUserId();
      final householdMembers = await client
          .from('household_members')
          .select('household_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (householdMembers == null) return false;

      final response = await client.rpc(
        'is_week_processed',
        params: {'p_household_id': householdMembers['household_id']},
      );

      return response == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> awardWeeklyWinner() async {
    final userId = await requireCurrentUserId();
    final householdMembers = await client
        .from('household_members')
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (householdMembers == null) {
      throw Exception('No perteneces a un hogar');
    }

    final response = await client.rpc(
      'award_weekly_winner',
      params: {'p_household_id': householdMembers['household_id']},
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> checkShouldShowWinner() async {
    try {
      final userId = await requireCurrentUserId();
      final householdMembers = await client
          .from('household_members')
          .select('household_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (householdMembers == null) {
        return {'show_winner': false};
      }

      final response = await client.rpc(
        'should_show_winner',
        params: {'p_household_id': householdMembers['household_id']},
      );

      return Map<String, dynamic>.from(response);
    } catch (_) {
      return {'show_winner': false};
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyDuelHistory() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_weekly_duel_history',
        params: {'p_user_id': userId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log.e('Error getting duel history: $e', error: e);
      return [];
    }
  }

  Future<Map<String, dynamic>> saveWeeklyDuelResult({
    required String householdId,
    required DateTime weekStartDate,
    required String winnerUserId,
    required String winnerName,
    required String loserUserId,
    required String loserName,
    required int winnerXp,
    required int loserXp,
  }) async {
    try {
      final response = await client.rpc(
        'save_weekly_duel_result',
        params: {
          'p_household_id': householdId,
          'p_week_start_date': weekStartDate.toIso8601String().split('T')[0],
          'p_winner_user_id': winnerUserId,
          'p_winner_name': winnerName,
          'p_loser_user_id': loserUserId,
          'p_loser_name': loserName,
          'p_winner_xp': winnerXp,
          'p_loser_xp': loserXp,
        },
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      log.e('Error saving duel result: $e', error: e);
      return {'success': false, 'message': e.toString()};
    }
  }
}
