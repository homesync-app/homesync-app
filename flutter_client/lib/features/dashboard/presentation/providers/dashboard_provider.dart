import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_provider.g.dart';

// 1. Repository Provider
@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  // We can pass Supabase.instance.client directly directly since it is globally configured
  // Alternatively we could get a SupabaseClient provider if we had one.
  return SupabaseDashboardRepository(Supabase.instance.client);
}

// 2. UseCase Provider
@riverpod
GetRecentActivityUseCase getRecentActivityUseCase(
    GetRecentActivityUseCaseRef ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetRecentActivityUseCase(repository);
}

// 3. Data Provider (replaces the old one in core_providers)
@riverpod
Future<List<Map<String, dynamic>>> recentActivity(RecentActivityRef ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  if (householdId == null || userId == null) return [];

  final useCase = ref.watch(getRecentActivityUseCaseProvider);
  return useCase.execute(householdId, userId);
}
