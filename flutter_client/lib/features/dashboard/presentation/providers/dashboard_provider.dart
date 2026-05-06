import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseDashboardRepository(client, ref);
}

@riverpod
GetRecentActivityUseCase getRecentActivityUseCase(
    GetRecentActivityUseCaseRef ref,) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetRecentActivityUseCase(repository);
}

@riverpod
Stream<List<Map<String, dynamic>>> recentActivity(RecentActivityRef ref) {
  final householdIdAsync = ref.watch(householdIdProvider);

  return householdIdAsync.when(
    data: (householdId) {
      final userId = ref.watch(currentUserIdProvider);
      if (householdId == null || householdId.isEmpty || userId == null) {
        return Stream.value([]);
      }

      final repository = ref.watch(dashboardRepositoryProvider);
      return repository.watchRecentActivity(householdId, userId);
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.value([]),
  );
}
