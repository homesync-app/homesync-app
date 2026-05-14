import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'rpc/admin_rpc_service.dart';
import 'rpc/balance_rpc_service.dart';
import 'rpc/household_rpc_service.dart';
import 'rpc/stats_rpc_service.dart';
import 'rpc/task_rpc_service.dart';

/// One-stop-shop for access to all legacy RPC functionality
/// while the app transitions to the new split services.
class SupabaseRpcService {
  final SupabaseClient _client;

  late final AdminRpcService _admin;
  late final TaskRpcService _task;
  late final StatsRpcService _stats;
  late final BalanceRpcService _balance;
  late final HouseholdRpcService _household;

  SupabaseRpcService({required SupabaseClient clientOverride})
      : _client = clientOverride {
    _admin = AdminRpcService(clientOverride: _client);
    _task = TaskRpcService(clientOverride: _client);
    _stats = StatsRpcService(clientOverride: _client);
    _balance = BalanceRpcService(clientOverride: _client);
    _household = HouseholdRpcService(clientOverride: _client);
  }

  Future<void> initialize() async {
    // Initialization logic if any
    log.d('SupabaseRpcService initialized');
  }

  // --- Admin ---
  Future<void> logApplicationError({
    required String message,
    String? stackTrace,
    String level = 'error',
    Map<String, dynamic>? context,
  }) =>
      _admin.logApplicationError(
        message: message,
        stackTrace: stackTrace,
        level: level,
        context: context,
      );

  // --- Stats / Weekly ---
  Future<bool> isWeekProcessed() => _stats.isWeekProcessed();
  Future<List<Map<String, dynamic>>> getWeeklyRanking() =>
      _stats.getWeeklyRanking();
  Future<List<Map<String, dynamic>>> getTaskStatsByCategory() =>
      _stats.getTaskStatsByCategory();
  Future<List<Map<String, dynamic>>> getMemberActivityStats() =>
      _stats.getMemberActivityStats();
  Future<List<Map<String, dynamic>>> getXpHistory() => _stats.getXpHistory();
  Future<List<Map<String, dynamic>>> getCoinHistory() =>
      _stats.getCoinHistory();
  Future<List<Map<String, dynamic>>> getWeeklyDuelHistory() =>
      _stats.getWeeklyDuelHistory();
  Future<Map<String, dynamic>> awardWeeklyWinner() =>
      _stats.awardWeeklyWinner();

  // --- Balance ---
  Future<Map<String, dynamic>> getUserBalance({required String householdId}) =>
      _balance.getUserBalance(householdId: householdId);

  // --- Task ---
  Future<TaskCompletionResult> completeTaskTransaction({
    required String taskId,
    required String taskTitle,
    required int xpReward,
    required int coinReward,
    required String householdId,
    List<String>? userIds,
  }) =>
      _task.completeTaskTransaction(
        taskId: taskId,
        taskTitle: taskTitle,
        xpReward: xpReward,
        coinReward: coinReward,
        householdId: householdId,
        userIds: userIds,
      );

  // --- Household ---
  Future<List<Map<String, dynamic>>> getHouseholdMembers() =>
      _household.getHouseholdMembers();
}
