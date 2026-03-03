import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/stats/data/repositories/supabase_stats_repository.dart';
import 'package:homesync_client/features/stats/domain/repositories/stats_repository.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final statsRpc = ref.watch(statsRpcServiceProvider);
  return SupabaseStatsRepository(statsRpc);
});

final taskStatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getTaskStatsByCategory();
});

final xpHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getXpHistory();
});

final coinHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getCoinHistory();
});

final expenseStatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getExpenseStatsByCategory();
});

final memberActivityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getMemberActivityStats();
});

final weeklyRankingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getWeeklyRanking();
});
