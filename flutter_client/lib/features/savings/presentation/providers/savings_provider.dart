import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/savings_model.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/usecases/get_savings_goals_usecase.dart';
import '../../domain/usecases/get_goal_contributions_usecase.dart';
import '../../domain/usecases/create_savings_goal_usecase.dart';
import '../../domain/usecases/add_contribution_usecase.dart';
import '../../domain/usecases/delete_savings_goal_usecase.dart';
import '../../data/repositories/supabase_savings_repository.dart';

// --- Repositories & Use Cases ---

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SupabaseSavingsRepository(ref: ref);
});

final getSavingsGoalsUseCaseProvider = Provider<GetSavingsGoalsUseCase>((ref) {
  return GetSavingsGoalsUseCase(ref.watch(savingsRepositoryProvider));
});

final getGoalContributionsUseCaseProvider =
    Provider<GetGoalContributionsUseCase>((ref) {
  return GetGoalContributionsUseCase(ref.watch(savingsRepositoryProvider));
});

final createSavingsGoalUseCaseProvider =
    Provider<CreateSavingsGoalUseCase>((ref) {
  return CreateSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
});

final addContributionUseCaseProvider = Provider<AddContributionUseCase>((ref) {
  return AddContributionUseCase(ref.watch(savingsRepositoryProvider));
});

final deleteSavingsGoalUseCaseProvider =
    Provider<DeleteSavingsGoalUseCase>((ref) {
  return DeleteSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
});

// --- UI State Providers ---

final goalContributionsProvider =
    FutureProvider.family<List<SavingsContributionModel>, String>(
        (ref, goalId) async {
  final getGoalContributions = ref.watch(getGoalContributionsUseCaseProvider);
  final result = await getGoalContributions.execute(goalId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (contributions) => contributions,
  );
});

final savingsGoalsProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoalModel>>(() {
  return SavingsGoalsNotifier();
});

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoalModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<SavingsGoalModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    // Realtime setup
    _setupRealtime(householdId);

    final getSavingsGoals = ref.watch(getSavingsGoalsUseCaseProvider);
    final result = await getSavingsGoals.execute(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (goals) => goals,
    );
  }

  void _setupRealtime(String householdId) {
    _channel?.unsubscribe();
    final client = ref.read(supabaseClientProvider);

    _channel = client
        .channel('savings_realtime_$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableSavingsGoals,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (payload) async {
            // Trigger a re-fetch when changes are detected
            final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
            final result = await getSavingsGoals.execute(householdId);
            state = result.fold(
              (failure) => AsyncValue.error(failure, StackTrace.current),
              (goals) => AsyncValue.data(goals),
            );
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> addGoal(
      String title, double targetAmount, String color, String icon) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) throw Exception('No household ID found');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createSavingsGoalUseCaseProvider).execute(
            householdId: householdId,
            title: title,
            targetAmount: targetAmount,
            color: color,
            icon: icon,
          );

      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );
    });
  }

  Future<void> contribute(String goalId, double amount, {String? note}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('No user ID found');

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) throw Exception('No household ID found');

    state = await AsyncValue.guard(() async {
      await ref.read(addContributionUseCaseProvider).execute(
            goalId: goalId,
            userId: userId,
            amount: amount,
            note: note,
          );

      ref.invalidate(goalContributionsProvider(goalId));

      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );
    });
  }

  Future<void> removeGoal(String goalId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) throw Exception('No household ID found');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteSavingsGoalUseCaseProvider).execute(goalId);

      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );
    });
  }
}
