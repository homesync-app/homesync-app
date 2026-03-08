import 'package:homesync_client/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';

// --- Repositories & Use Cases ---

part 'savings_provider.g.dart';

// --- Repositories & Use Cases ---

@riverpod
SavingsRepository savingsRepository(SavingsRepositoryRef ref) {
  return SupabaseSavingsRepository(ref: ref);
}

@riverpod
GetSavingsGoalsUseCase getSavingsGoalsUseCase(GetSavingsGoalsUseCaseRef ref) {
  return GetSavingsGoalsUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
GetGoalContributionsUseCase getGoalContributionsUseCase(
    GetGoalContributionsUseCaseRef ref) {
  return GetGoalContributionsUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
CreateSavingsGoalUseCase createSavingsGoalUseCase(
    CreateSavingsGoalUseCaseRef ref) {
  return CreateSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
AddContributionUseCase addContributionUseCase(AddContributionUseCaseRef ref) {
  return AddContributionUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
DeleteSavingsGoalUseCase deleteSavingsGoalUseCase(
    DeleteSavingsGoalUseCaseRef ref) {
  return DeleteSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

// --- UI State Providers ---

@riverpod
Future<List<SavingsContributionModel>> goalContributions(
    GoalContributionsRef ref, String goalId) async {
  final getGoalContributions = ref.watch(getGoalContributionsUseCaseProvider);
  final result = await getGoalContributions.execute(goalId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (contributions) => contributions,
  );
}

@riverpod
class SavingsGoals extends _$SavingsGoals {
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
          callback: (payload) {
            log.i('Realtime savings change detected: ${payload.eventType}');
            ref.invalidateSelf();
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
      final goals = result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );

      // Impactar en balance personal registrando un gasto tipo 'personal'
      if (amount > 0) {
        final goal = goals.firstWhere((g) => g.id == goalId);
        try {
          await ref.read(expenseControllerProvider.notifier).saveExpense(
            householdId: householdId,
            title: 'Ahorro: ${goal.title}',
            amount: amount,
            category: 'finanzas',
            paidBy: userId,
            paidAt: DateTime.now(),
            splitType: SplitType.personal,
          );
        } catch (e) {
          log.e('Error recording savings as expense: $e');
        }
      }

      return goals;
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
