import 'dart:io' show SocketException;

import 'package:homesync_client/core/services/logger_service.dart';
import 'package:http/http.dart' show ClientException;

import 'base_rpc_service.dart';

/// Returns true for transient network failures such as DNS/offline errors.
/// These should be treated as expected offline states, not Crashlytics issues.
bool _isTransientNetworkError(Object error) {
  if (error is SocketException) return true;
  if (error is ClientException) return true;
  // Some clients wrap SocketException in another exception whose toString()
  // starts with "ClientException with SocketException".
  final msg = error.toString();
  return msg.contains('SocketException') ||
      msg.contains('Failed host lookup') ||
      msg.contains('Connection closed') ||
      msg.contains('Connection refused');
}

class StatsRpcService extends BaseRpcService {
  StatsRpcService({required super.clientOverride});

  Future<List<Map<String, dynamic>>> getTaskStatsByCategory() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_task_stats_by_category',
        params: {'p_user_id': userId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.getTaskStatsByCategory fallback to empty list',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getXpHistory() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_xp_history',
        params: {'p_user_id': userId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.getXpHistory fallback to empty list',
        error: error,
        stackTrace: stackTrace,
      );
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
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.getCoinHistory fallback to empty list',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExpenseStatsByCategory() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_expense_stats_by_category',
        params: {'p_user_id': userId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.getExpenseStatsByCategory fallback to empty list',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMemberActivityStats() async {
    try {
      final userId = await requireCurrentUserId();
      final response = await client.rpc(
        'get_member_activity_stats',
        params: {'p_user_id': userId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      // log.d (no reporta a Crashlytics): es estado esperado para usuarios
      // sin hogar todavía. Antes con log.w llenaba el panel con 16+ eventos
      // diarios (issue 4a4cfda83d).
      log.d(
        'StatsRpcService.getMemberActivityStats fallback to empty list: $error',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
    try {
      final householdId = await requireHouseholdId();

      final response = await client.rpc(
        'get_weekly_ranking',
        params: {'p_household_id': householdId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      // log.d: usuario sin hogar es estado válido (recién registrado).
      // No es un error reportable; antes inflaba Crashlytics issue 4a4cfda8.
      log.d(
        'StatsRpcService.getWeeklyRanking fallback to empty list: $error',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyRankingForWeek(
    DateTime weekStartDate,
  ) async {
    try {
      final householdId = await requireHouseholdId();

      final response = await client.rpc(
        'get_weekly_ranking_for_week',
        params: {
          'p_household_id': householdId,
          'p_week_start_date': _dateParam(weekStartDate),
        },
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      log.d(
        'StatsRpcService.getWeeklyRankingForWeek fallback to empty list: $error',
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<bool> isWeekProcessed() async {
    try {
      final householdId = await requireHouseholdId();

      final response = await client.rpc(
        'is_week_processed',
        params: {'p_household_id': householdId},
      );

      return response == true;
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.isWeekProcessed fallback to false',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> isWeekProcessedForWeek(DateTime weekStartDate) async {
    try {
      final householdId = await requireHouseholdId();

      final response = await client.rpc(
        'is_week_processed_for_week',
        params: {
          'p_household_id': householdId,
          'p_week_start_date': _dateParam(weekStartDate),
        },
      );

      return response == true;
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.isWeekProcessedForWeek fallback to false',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> awardWeeklyWinner() async {
    final householdId = await requireHouseholdId();

    final response = await client.rpc(
      'award_weekly_winner',
      params: {'p_household_id': householdId},
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> awardWeeklyWinnerForWeek(
    DateTime weekStartDate,
  ) async {
    final householdId = await requireHouseholdId();

    final response = await client.rpc(
      'award_weekly_winner_for_week',
      params: {
        'p_household_id': householdId,
        'p_week_start_date': _dateParam(weekStartDate),
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> debugAwardWeeklyWinnerBonus(
    DateTime weekStartDate,
  ) async {
    final householdId = await requireHouseholdId();

    final response = await client.rpc(
      'debug_award_weekly_winner_bonus',
      params: {
        'p_household_id': householdId,
        'p_week_start_date': _dateParam(weekStartDate),
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> checkShouldShowWinner() async {
    try {
      final householdId = await requireHouseholdId();

      final response = await client.rpc(
        'should_show_winner',
        params: {'p_household_id': householdId},
      );

      return Map<String, dynamic>.from(response);
    } catch (error, stackTrace) {
      log.w(
        'StatsRpcService.checkShouldShowWinner fallback to hidden',
        error: error,
        stackTrace: stackTrace,
      );
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
    } catch (e, stack) {
      if (_isTransientNetworkError(e)) {
        log.d('getWeeklyDuelHistory offline fallback: $e');
        return [];
      }
      log.e('Error getting duel history: $e', error: e, stackTrace: stack);
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
    } catch (e, stack) {
      if (_isTransientNetworkError(e)) {
        log.d('saveWeeklyDuelResult offline fallback: $e');
        return {'success': false, 'message': 'offline', 'offline': true};
      }
      log.e('Error saving duel result: $e', error: e, stackTrace: stack);
      return {'success': false, 'message': e.toString()};
    }
  }

  String _dateParam(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];
  }
}
