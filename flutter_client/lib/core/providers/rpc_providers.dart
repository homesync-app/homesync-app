import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/rpc/admin_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/balance_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/household_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/reward_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/stats_rpc_service.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';

final adminRpcServiceProvider = Provider<AdminRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminRpcService(clientOverride: client);
});

final balanceRpcServiceProvider = Provider<BalanceRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BalanceRpcService(clientOverride: client);
});

final householdRpcServiceProvider = Provider<HouseholdRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HouseholdRpcService(clientOverride: client);
});

final rewardRpcServiceProvider = Provider<RewardRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RewardRpcService(clientOverride: client);
});

final statsRpcServiceProvider = Provider<StatsRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StatsRpcService(clientOverride: client);
});

final taskRpcServiceProvider = Provider<TaskRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TaskRpcService(clientOverride: client);
});
