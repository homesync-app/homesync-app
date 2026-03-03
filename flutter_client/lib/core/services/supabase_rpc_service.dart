import 'rpc/task_rpc_service.dart';
import 'rpc/reward_rpc_service.dart';
import 'rpc/stats_rpc_service.dart';
import 'rpc/household_rpc_service.dart';
import 'rpc/balance_rpc_service.dart';
import 'rpc/admin_rpc_service.dart';

/// Facade for the new split RPC services.
/// Keeps backward compatibility with the rest of the application.
class SupabaseRpcService {
  static final SupabaseRpcService _instance = SupabaseRpcService._internal();
  factory SupabaseRpcService() => _instance;
  SupabaseRpcService._internal();

  final _task = TaskRpcService();
  final _reward = RewardRpcService();
  final _stats = StatsRpcService();
  final _household = HouseholdRpcService();
  final _balance = BalanceRpcService();
  final _admin = AdminRpcService();

  Future<void> initialize() async {}

  // ============================================
  // TASKS
  // ============================================

  Future<String> createTask({
    required String title,
    String? description,
    String? category,
    String? assignedTo,
    String type = 'one_time',
    String difficulty = 'medium',
    int xpReward = 0,
    int coinReward = 0,
    String priority = 'medium',
    DateTime? dueAt,
    String? recurrenceType,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndAt,
  }) => _task.createTask(
    title: title,
    description: description,
    category: category,
    assignedTo: assignedTo,
    type: type,
    difficulty: difficulty,
    xpReward: xpReward,
    coinReward: coinReward,
    priority: priority,
    dueAt: dueAt,
    recurrenceType: recurrenceType,
    recurrenceInterval: recurrenceInterval,
    recurrenceEndAt: recurrenceEndAt,
  );

  Future<Map<String, dynamic>> completeTaskTransaction({
    required String taskId,
    required String taskTitle,
    required int xpReward,
    required int coinReward,
    required String householdId,
    String? userId,
  }) => _task.completeTaskTransaction(
    taskId: taskId,
    taskTitle: taskTitle,
    xpReward: xpReward,
    coinReward: coinReward,
    householdId: householdId,
    userId: userId,
  );

  Future<Map<String, dynamic>> verifyTaskTransaction({
    required String taskId,
    String? nextDueAt,
  }) => _task.verifyTaskTransaction(taskId: taskId, nextDueAt: nextDueAt);

  Future<Map<String, dynamic>> rejectTaskTransaction({
    required String taskId,
    String? reason,
  }) => _task.rejectTaskTransaction(taskId: taskId, reason: reason);

  Future<List<Map<String, dynamic>>> getTasks({int limit = 100, int offset = 0}) => 
    _task.getTasks(limit: limit, offset: offset);

  Future<Map<String, dynamic>> objectTask({
    required String taskId,
    String? reason,
  }) => _task.objectTask(taskId: taskId, reason: reason);

  Future<Map<String, dynamic>> restoreTaskCoins({required String taskId}) => 
    _task.restoreTaskCoins(taskId: taskId);

  Future<List<Map<String, dynamic>>> getTaskHistory({int limit = 50}) => 
    _task.getTaskHistory(limit: limit);

  // ============================================
  // REWARDS
  // ============================================

  Future<List<Map<String, dynamic>>> getAvailableRewards() => 
    _reward.getAvailableRewards();

  Future<String> createCustomReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
  }) => _reward.createCustomReward(
    householdId: householdId,
    title: title,
    description: description,
    cost: cost,
    icon: icon,
  );

  Future<Map<String, dynamic>> redeemReward(String rewardId) => 
    _reward.redeemReward(rewardId);

  Future<Map<String, dynamic>> transferCoins({
    required String toUserId,
    required int amount,
    required String householdId,
    String? note,
  }) => _reward.transferCoins(
    toUserId: toUserId,
    amount: amount,
    householdId: householdId,
    note: note,
  );

  Future<List<Map<String, dynamic>>> getRedemptionHistory() => 
    _reward.getRedemptionHistory();

  Future<Map<String, dynamic>> fulfillRedemption(String redemptionId) => 
    _reward.fulfillRedemption(redemptionId);

  // ============================================
  // STATS
  // ============================================

  Future<List<Map<String, dynamic>>> getTaskStatsByCategory() => 
    _stats.getTaskStatsByCategory();

  Future<List<Map<String, dynamic>>> getXpHistory() => 
    _stats.getXpHistory();

  Future<List<Map<String, dynamic>>> getCoinHistory() => 
    _stats.getCoinHistory();

  Future<List<Map<String, dynamic>>> getExpenseStatsByCategory() => 
    _stats.getExpenseStatsByCategory();

  Future<List<Map<String, dynamic>>> getMemberActivityStats() => 
    _stats.getMemberActivityStats();

  Future<List<Map<String, dynamic>>> getWeeklyRanking() => 
    _stats.getWeeklyRanking();

  Future<bool> isWeekProcessed() => 
    _stats.isWeekProcessed();

  Future<Map<String, dynamic>> awardWeeklyWinner() => 
    _stats.awardWeeklyWinner();

  Future<Map<String, dynamic>> checkShouldShowWinner() => 
    _stats.checkShouldShowWinner();

  Future<List<Map<String, dynamic>>> getWeeklyDuelHistory() => 
    _stats.getWeeklyDuelHistory();

  Future<Map<String, dynamic>> saveWeeklyDuelResult({
    required String householdId,
    required DateTime weekStartDate,
    required String winnerUserId,
    required String winnerName,
    required String loserUserId,
    required String loserName,
    required int winnerXp,
    required int loserXp,
  }) => _stats.saveWeeklyDuelResult(
    householdId: householdId,
    weekStartDate: weekStartDate,
    winnerUserId: winnerUserId,
    winnerName: winnerName,
    loserUserId: loserUserId,
    loserName: loserName,
    winnerXp: winnerXp,
    loserXp: loserXp,
  );

  // ============================================
  // HOUSEHOLD
  // ============================================

  Future<Map<String, dynamic>> getHouseholdInfo() => 
    _household.getHouseholdInfo();

  Future<String> generateInvitationCode() => 
    _household.generateInvitationCode();

  Future<Map<String, dynamic>> joinHousehold(String code) => 
    _household.joinHousehold(code);

  Future<List<Map<String, dynamic>>> getHouseholdMembers() => 
    _household.getHouseholdMembers();

  // ============================================
  // BALANCE
  // ============================================

  Future<Map<String, dynamic>> getUserBalance({required String householdId}) => 
    _balance.getUserBalance(householdId: householdId);

  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  }) => _balance.getTransactionHistory(limit: limit, offset: offset, typeFilter: typeFilter);

  Future<List<Map<String, dynamic>>> getTransactionTypes() => 
    _balance.getTransactionTypes();

  Future<Map<String, dynamic>> getHouseholdBalances(String householdId) => 
    _balance.getHouseholdBalances(householdId);

  Future<Map<String, dynamic>> runIntegrityCheck(String householdId) => 
    _balance.runIntegrityCheck(householdId);

  // ============================================
  // ADMIN
  // ============================================

  Future<void> logApplicationError({
    required String message,
    String? stackTrace,
    String level = 'error',
    Map<String, dynamic>? context,
  }) => _admin.logApplicationError(
    message: message,
    stackTrace: stackTrace,
    level: level,
    context: context,
  );

  Future<Map<String, dynamic>> resetUserAccount() => 
    _admin.resetUserAccount();
}
