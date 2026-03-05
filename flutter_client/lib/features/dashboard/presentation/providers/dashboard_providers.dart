import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';

// 1. Repository Provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  // We can pass Supabase.instance.client directly directly since it is globally configured
  // Alternatively we could get a SupabaseClient provider if we had one.
  return SupabaseDashboardRepository(Supabase.instance.client);
});

// 2. UseCase Provider
final getRecentActivityUseCaseProvider =
    Provider<GetRecentActivityUseCase>((ref) {
  final repository = ref.read(dashboardRepositoryProvider);
  return GetRecentActivityUseCase(repository);
});

// 3. Data Provider (replaces the old one in core_providers)
final recentActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return [];

  final useCase = ref.watch(getRecentActivityUseCaseProvider);
  return useCase.execute(householdId);
});
