import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/savings/data/repositories/supabase_savings_repository.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/domain/usecases/add_contribution_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/archive_savings_goal_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/create_savings_goal_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/delete_savings_goal_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/get_goal_contributions_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/get_savings_goals_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/update_savings_goal_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'savings_provider.g.dart';

const _savingsGoalsPageSize = 12;

class SavingsGoalsPageState {
  final List<SavingsGoalModel> items;
  final bool hasMore;
  final bool isLoadingMore;

  const SavingsGoalsPageState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
  });

  SavingsGoalsPageState copyWith({
    List<SavingsGoalModel>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SavingsGoalsPageState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class _SavingsGoalsChunk {
  final List<SavingsGoalModel> items;
  final bool hasMore;

  const _SavingsGoalsChunk({
    required this.items,
    required this.hasMore,
  });
}

// keepAlive: a repository is a stateless session-lived singleton that holds its
// Ref and reads it after async gaps. As auto-dispose it could be torn down
// mid-await, making a post-await `_ref` read throw "Cannot use the Ref ... after
// it has been disposed" (see expense/stats repos for the same rationale).
@Riverpod(keepAlive: true)
SavingsRepository savingsRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSavingsRepository(client: client, ref: ref);
}

@riverpod
GetSavingsGoalsUseCase getSavingsGoalsUseCase(Ref ref) {
  return GetSavingsGoalsUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
GetGoalContributionsUseCase getGoalContributionsUseCase(Ref ref) {
  return GetGoalContributionsUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
CreateSavingsGoalUseCase createSavingsGoalUseCase(Ref ref) {
  return CreateSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
AddContributionUseCase addContributionUseCase(Ref ref) {
  return AddContributionUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
DeleteSavingsGoalUseCase deleteSavingsGoalUseCase(Ref ref) {
  return DeleteSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
UpdateSavingsGoalUseCase updateSavingsGoalUseCase(Ref ref) {
  return UpdateSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
ArchiveSavingsGoalUseCase archiveSavingsGoalUseCase(Ref ref) {
  return ArchiveSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
Future<List<SavingsContributionModel>> goalContributions(
  Ref ref,
  String goalId,
) async {
  final getGoalContributions = ref.watch(getGoalContributionsUseCaseProvider);
  final result = await getGoalContributions.execute(goalId);
  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
}

@riverpod
class SavingsGoals extends _$SavingsGoals {
  @override
  Future<List<SavingsGoalModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final getSavingsGoals = ref.watch(getSavingsGoalsUseCaseProvider);
    final result = await getSavingsGoals.execute(householdId);
    return result.fold(
      (failure) => throw failure,
      (goals) => goals,
    );
  }

  Future<void> addGoal(
    String title,
    double targetAmount,
    String color,
    String icon, {
    DateTime? targetDate,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    // Capture use cases before any await: this notifier is auto-dispose, so a
    // mid-flight teardown would make a post-await `ref.read` throw "Cannot use
    // the Ref ... after it has been disposed".
    final createGoal = ref.read(createSavingsGoalUseCaseProvider);
    final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);

    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() async {
      await createGoal.execute(
        householdId: householdId,
        title: title,
        targetAmount: targetAmount,
        color: color,
        icon: icon,
        targetDate: targetDate,
      );
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw failure,
        (goals) => goals,
      );
    });

    // Guard the cache refresh and the state write: touching `ref`/`state` on a
    // disposed notifier throws, and that throw is outside the guard above.
    if (!ref.mounted) return;
    ref.invalidate(paginatedSavingsGoalsProvider);
    state = next;
  }

  Future<void> editGoal(
    String goalId, {
    String? title,
    double? targetAmount,
    String? color,
    String? icon,
    DateTime? targetDate,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final updateGoal = ref.read(updateSavingsGoalUseCaseProvider);
    final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);

    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() async {
      await updateGoal.execute(
        goalId: goalId,
        title: title,
        targetAmount: targetAmount,
        color: color,
        icon: icon,
        targetDate: targetDate,
      );
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw failure,
        (goals) => goals,
      );
    });

    if (!ref.mounted) return;
    ref.invalidate(paginatedSavingsGoalsProvider);
    state = next;
  }

  Future<void> archiveGoal(String goalId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final archiveGoal = ref.read(archiveSavingsGoalUseCaseProvider);
    final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);

    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() async {
      await archiveGoal.execute(goalId);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw failure,
        (goals) => goals,
      );
    });

    if (!ref.mounted) return;
    ref.invalidate(paginatedSavingsGoalsProvider);
    state = next;
  }

  /// Registers a contribution to a savings goal.
  ///
  /// The full [amount] always lands on the goal (the savings progress is a
  /// household figure). What [splitType]/[splits] control is how the matching
  /// LEDGER expense is attributed:
  ///  - [SplitType.personal] → "solo yo / regalo": only the contributor's
  ///    balance is debited.
  ///  - [SplitType.equal]/[SplitType.fixed] → "entre todos": the expense is
  ///    shared/divided across members per the household's economy config.
  Future<void> contribute(
    String goalId,
    double amount, {
    String? note,
    required String goalTitle,
    SplitType splitType = SplitType.personal,
    SplitType? savingsSplitType,
    List<Map<String, dynamic>>? splits,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.read(householdIdProvider.future);
    if (userId == null || householdId == null) return;

    final addContribution = ref.read(addContributionUseCaseProvider);
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);

    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() async {
      final members = await ref.read(householdMembersProvider.future);
      final membersByUserId = {
        for (final member in members) member.userId: member,
      };
      final contributionSplitType = savingsSplitType ?? splitType;
      final participantIds = contributionSplitType == SplitType.personal
          ? <String>[userId]
          : (splits ?? const <Map<String, dynamic>>[])
              .map((split) => split['user_id']?.toString())
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList();
      final participants = participantIds
          .map((id) => membersByUserId[id])
          .whereType<MemberModel>()
          .map(
            (member) => {
              'user_id': member.userId,
              'name': member.fullDisplayName,
              'email': member.email,
              'avatar_url': member.avatarUrl,
            },
          )
          .toList();

      // 1. Add the contribution to the savings goal
      await addContribution.execute(
        goalId: goalId,
        userId: userId,
        amount: amount,
        note: note,
        splitType: contributionSplitType.name,
        participants: participants,
      );

      // 2. Create a matching expense so the contribution leaves the ledger.
      //    The split attribution mirrors the contribution sheet's choice.
      try {
        final saveResult = await expenseRepo.saveExpense(
          householdId: householdId,
          title: 'Ahorro: $goalTitle',
          amount: amount,
          category: 'finanzas',
          paidBy: userId,
          paidAt: DateTime.now(),
          description: note ?? 'Aportación a meta de ahorro',
          splitType: splitType,
          splits: splits,
          type: 'expense',
        );
        // saveExpense returns Either<Failure, void>; a Left means the ledger
        // write failed silently — surface it so the contribution doesn't look
        // like it "didn't deduct anything".
        saveResult.fold(
          (failure) => log.w(
            'Savings contribution: ledger expense failed: ${failure.message}',
          ),
          (_) {},
        );
      } catch (e, stack) {
        // Log error but don't fail the whole operation if ledger failed
        log.w(
          'Error creating expense for contribution',
          error: e,
          stackTrace: stack,
        );
      }

      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw failure,
        (goals) => goals,
      );
    });

    if (!ref.mounted) return;
    ref.invalidate(goalContributionsProvider(goalId));
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(expenseControllerProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(combinedFeedControllerProvider);
    ref.invalidate(recentActivityRemoteProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(paginatedSavingsGoalsProvider);
    state = next;
  }

  Future<void> removeGoal(String goalId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final deleteGoal = ref.read(deleteSavingsGoalUseCaseProvider);
    final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);

    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() async {
      await deleteGoal.execute(goalId);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw failure,
        (goals) => goals,
      );
    });

    if (!ref.mounted) return;
    ref.invalidate(paginatedSavingsGoalsProvider);
    state = next;
  }
}

@riverpod
class PaginatedSavingsGoals extends _$PaginatedSavingsGoals {
  @override
  Future<SavingsGoalsPageState> build() async {
    final chunk = await _fetchChunk(offset: 0);
    return SavingsGoalsPageState(
      items: chunk.items,
      hasMore: chunk.hasMore,
      isLoadingMore: false,
    );
  }

  Future<_SavingsGoalsChunk> _fetchChunk({required int offset}) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) {
      return const _SavingsGoalsChunk(items: [], hasMore: false);
    }

    final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
    final result = await getSavingsGoals.execute(
      householdId,
      limit: _savingsGoalsPageSize,
      offset: offset,
    );

    return result.fold(
      (failure) => throw failure,
      (goals) => _SavingsGoalsChunk(
        items: goals,
        hasMore: goals.length == _savingsGoalsPageSize,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<SavingsGoalsPageState>();
    final next = await AsyncValue.guard(() async {
      final chunk = await _fetchChunk(offset: 0);
      return SavingsGoalsPageState(
        items: chunk.items,
        hasMore: chunk.hasMore,
        isLoadingMore: false,
      );
    });
    if (!ref.mounted) return;
    state = next;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final chunk = await _fetchChunk(offset: current.items.length);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...chunk.items],
          hasMore: chunk.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      }
      log.e(
        'Error loading more savings goals: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class SavingsSuggestion {
  final SavingsGoalModel goal;
  final double surplus;
  final double percentageBoost;

  SavingsSuggestion({
    required this.goal,
    required this.surplus,
    required this.percentageBoost,
  });
}

@riverpod
Future<SavingsSuggestion?> savingsSuggester(Ref ref) async {
  final summary = await ref.watch(personalFinanceSummaryProvider.future);
  final projection = await ref.watch(monthlyProjectionProvider.future);
  final goals = await ref.watch(savingsGoalsProvider.future);

  if (goals.isEmpty) return null;

  final income = (summary['income'] as num?)?.toDouble() ?? 0.0;
  final totalExpectedSpend = projection.total;

  // If income is not registered, we can't calculate surplus accurately
  if (income <= 0) return null;

  final surplus = income - totalExpectedSpend;

  // Only suggest if surplus is relevant (e.g. > $1000 ARS)
  if (surplus <= 1000) return null;

  // Find the goal with the highest progress but not yet reached.
  final eligibleGoals = goals.where((g) => !g.isReached).toList();
  if (eligibleGoals.isEmpty) return null;

  eligibleGoals.sort((a, b) => b.progress.compareTo(a.progress));
  final targetGoal = eligibleGoals.first;

  return SavingsSuggestion(
    goal: targetGoal,
    surplus: surplus,
    percentageBoost: targetGoal.targetAmount > 0
        ? (surplus / targetGoal.targetAmount) * 100
        : 0,
  );
}

/// What the current user is allowed to do with savings goals.
///
/// Only **family** households gate by role (per product decision):
///  - parent/guardian → full control;
///  - teen → may view and contribute, but not create/edit/delete;
///  - child → view only.
/// Every other household type (couple/solo/friends) keeps full access.
class SavingsPermissions {
  final bool canCreate;
  final bool canContribute;
  final bool canManage; // edit / delete / archive

  const SavingsPermissions({
    required this.canCreate,
    required this.canContribute,
    required this.canManage,
  });

  static const full = SavingsPermissions(
    canCreate: true,
    canContribute: true,
    canManage: true,
  );
}

@riverpod
SavingsPermissions savingsPermissions(Ref ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (!caps.usesFamilyRoles) return SavingsPermissions.full;

  final member = ref.watch(currentMemberProvider);
  // While members load, assume the most permissive non-destructive baseline
  // for adults; gating tightens once the real type resolves.
  switch (member?.type) {
    case MemberType.teen:
      return const SavingsPermissions(
        canCreate: false,
        canContribute: true,
        canManage: false,
      );
    case MemberType.child:
      return const SavingsPermissions(
        canCreate: false,
        canContribute: false,
        canManage: false,
      );
    case MemberType.parent:
    case MemberType.guardian:
    case null:
      return SavingsPermissions.full;
  }
}
