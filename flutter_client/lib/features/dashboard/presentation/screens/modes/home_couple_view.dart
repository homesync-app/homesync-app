import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_actions_sheet.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_activity_tile.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_home_widgets.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_settlement_flow.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_editorial_header.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_shopping_preview_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/love_note_envelope.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/partner_invite_card.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/tour_target_keys.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_completion_flow_mixin.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_feed_entry_motion.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/expressive/expressive.dart';
import 'package:intl/intl.dart';

class HomeCoupleView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;
  final VoidCallback onAvatarTap;

  const HomeCoupleView({
    super.key,
    required this.onRefresh,
    required this.householdId,
    required this.onAvatarTap,
  });

  @override
  ConsumerState<HomeCoupleView> createState() => _HomeCoupleViewState();
}

class _HomeCoupleViewState extends ConsumerState<HomeCoupleView>
    with TaskCompletionFlowMixin<HomeCoupleView> {
  final GlobalKey _balanceKey = GlobalKey(debugLabel: 'tour_balance');
  final GlobalKey _tasksKey = GlobalKey(debugLabel: 'tour_tasks');
  bool _tourTriggered = false;
  bool _settlementJustCompleted = false;
  double? _optimisticExpenseBalance;
  // Cached pre-dispose so dispose() never calls ref after unmount
  TourTargetKeysNotifier? _tourKeysNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerTourKeys();
      _maybeStartTour();
    });
  }

  void _registerTourKeys() {
    _tourKeysNotifier = ref.read(tourTargetKeysProvider.notifier);
    _tourKeysNotifier?.register(TourTarget.balanceCard, _balanceKey);
    _tourKeysNotifier?.register(TourTarget.tasksSection, _tasksKey);
  }

  void _maybeStartTour() {
    if (_tourTriggered) return;
    // Read SharedPreferences directly instead of trusting the Riverpod
    // provider — the provider's value is computed once at first build and
    // can return stale `false` even after another State persisted the flag.
    final prefs = ref.read(sharedPreferencesProvider);
    final alreadySeen = prefs.getBool(tourFlagKey) ?? false;
    if (alreadySeen) return;
    final tourState = ref.read(coupleHomeTourControllerProvider);
    if (tourState.isActive) return;
    _tourTriggered = true;
    // Let entrance animations of the home settle before opening the tour.
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      // Re-check inside the delay in case another instance/route persisted
      // the flag while we were waiting.
      final stillUnseen =
          !(ref.read(sharedPreferencesProvider).getBool(tourFlagKey) ?? false);
      if (!stillUnseen) return;
      ref
          .read(coupleHomeTourControllerProvider.notifier)
          .start(buildHomeTourContext(ref));
    });
  }

  @override
  void dispose() {
    // Defer the unregister: modifying a provider synchronously during the
    // widget-tree finalize phase trips Riverpod's "modify provider while
    // building" assert. Capture locally so we don't touch ref after dispose.
    final notifier = _tourKeysNotifier;
    final balanceKey = _balanceKey;
    final tasksKey = _tasksKey;
    if (notifier != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.unregister(TourTarget.balanceCard, balanceKey);
        notifier.unregister(TourTarget.tasksSection, tasksKey);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    final t = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: theme.primary,
      edgeOffset: 20,
      child: ListView(
        // Se adjunta al PrimaryScrollController del tab (re-tap sube al tope).
        primary: true,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppInsets.screenHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          KeyedSubtree(
            key: _balanceKey,
            child: _buildFinancialSummary(widget.householdId),
          ),
          ..._buildFirstExpenseNudge(theme),
          const SizedBox(height: AppSpacing.lg),
          if (caps.showTasks)
            KeyedSubtree(
              key: _tasksKey,
              child: _buildTasksSection(theme),
            )
          else
            HomeShoppingPreviewCard(title: t.homeCoupleShoppingListTitle),
          const SizedBox(height: AppSpacing.lg),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final partnerMember =
        members.where((m) => m.userId != currentUserId).firstOrNull;

    final t = AppLocalizations.of(context);
    final note = ref.watch(pendingLoveNoteProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                _buildWelcomeGreetingSpan(
                  theme: theme,
                  currentMemberName: currentMember?.displayName,
                ),
                style: AppTypography.cardTitle,
              ),
            ),
            IconButton(
              onPressed: widget.onAvatarTap,
              tooltip: t.settingsAppBarTitle,
              icon: Icon(Icons.settings_outlined, color: theme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        CoupleHomeWelcome(
          me: currentMember,
          partner: partnerMember,
          onTap: partnerMember == null
              ? null
              : () => showCouplePlansSheet(
                    context,
                    householdId: widget.householdId,
                    partner: partnerMember,
                    senderName: _firstName(currentMember?.displayName) ??
                        t.commonUserFallback,
                  ),
          note: note == null
              ? null
              : LoveNoteEnvelope(
                  note: note,
                  senderName: _firstName(partnerMember?.displayName) ??
                      t.homeCouplePartnerFallback,
                ),
        ),
      ],
    ).animateEntrance();
  }

  void _goTo(MainTab tab) {
    final index = indexForMainTab(ref.read(householdCapabilitiesProvider), tab);
    if (index >= 0) ref.read(bottomNavIndexProvider.notifier).setIndex(index);
  }

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.split(' ').first;
  }

  /// Saludo neutro por hora, igual que en los otros modos. Antes adivinaba el
  /// género por la última letra del nombre ("Bienvenida" si terminaba en a),
  /// y se equivocaba con nombres como Luca o Andrea.
  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final t = AppLocalizations.of(context);
    final firstName = _firstName(currentMemberName);
    final greeting = homeGreetingForHour(DateTime.now().hour, t);

    return TextSpan(
      children: [
        TextSpan(
          text: '$greeting ',
          style: TextStyle(color: theme.textSecondary),
        ),
        TextSpan(
          text: firstName ?? t.commonUserFallback,
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(String householdId) {
    final membersAsync = ref.watch(householdMembersProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final householdAsync = ref.watch(currentHouseholdProvider);
    final isIntegratedEconomy = householdAsync.value?.financeMode == 'shared';

    if (membersAsync.hasError ||
        expenseBalancesAsync.hasError ||
        householdAsync.hasError) {
      return AppInlineError(
        message: AppLocalizations.of(context).expensesSummaryLoadError,
        onRetry: () {
          ref.invalidate(householdMembersProvider);
          ref.invalidate(expenseBalancesProvider);
          ref.invalidate(currentHouseholdProvider);
        },
      );
    }
    if (!membersAsync.hasValue ||
        !expenseBalancesAsync.hasValue ||
        !householdAsync.hasValue) {
      return const SizedBox(height: 120, child: Center(child: AppLoader()));
    }

    double myExpenseBalance = 0;
    expenseBalancesAsync.whenData((balances) {
      final myBalanceModel =
          balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (myBalanceModel != null) myExpenseBalance = myBalanceModel.balance;
    });
    final displayedExpenseBalance =
        _optimisticExpenseBalance ?? myExpenseBalance;

    if (_optimisticExpenseBalance != null && myExpenseBalance.abs() <= 10.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _optimisticExpenseBalance = null);
      });
    }

    final partner = membersAsync.whenOrNull(
      data: (members) =>
          members.where((m) => m.userId != currentUserId).firstOrNull,
    );

    // Sin la otra persona no hay balance entre dos que mostrar (antes decía
    // "Balance en calma" a alguien que estaba solo). En su lugar va la
    // invitación: es lo que destraba el resto de la app.
    if (membersAsync.hasValue && partner == null) {
      return const PartnerInviteCard(
        variant: PartnerInviteVariant.compact,
        source: 'home',
      ).animateEntrance(delay: 100);
    }

    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final partnerName =
        _firstName(partner?.displayName) ?? t.homeCouplePartnerFallback;
    // Integrated economy: no debt/balance between partners, so the card shows
    // the shared household monthly spend instead of a balance + settle action.
    if (isIntegratedEconomy) {
      final projection = ref.watch(monthlyProjectionProvider);
      return projection.when(
        loading: () =>
            const SizedBox(height: 120, child: Center(child: AppLoader())),
        error: (_, __) => AppInlineError(
          message: t.expensesSummaryLoadError,
          onRetry: () => ref.invalidate(monthlyProjectionProvider),
        ),
        data: (month) => CoupleHomeBalance(
          balance: 0,
          partnerName: partnerName,
          formatAmount: currency.format,
          onMovements: () => _goTo(MainTab.expenses),
          shared: true,
          monthlySpent: month.spent,
        ).animateEntrance(delay: 100),
      );
    }

    return CoupleHomeBalance(
      balance: displayedExpenseBalance,
      partnerName: partnerName,
      formatAmount: currency.format,
      onMovements: () => _goTo(MainTab.expenses),
      justSettled: _settlementJustCompleted,
      // Solo quien debe registra el pago; a quien tiene plata a favor no le
      // toca hacer nada (se salda cuando el otro paga).
      onSettle: partner != null && displayedExpenseBalance < -10.0
          ? () => _showSettlementDialog(
                partnerId: partner.userId,
                partnerName: partner.displayName,
                amount: displayedExpenseBalance.abs(),
              )
          : null,
    ).animateEntrance(delay: 100);
  }

  /// Siguiente paso una vez que están los dos: el primer gasto. Se va sola en
  /// cuanto existe uno (o hay un saldo abierto, que implica que ya hubo).
  List<Widget> _buildFirstExpenseNudge(AppThemeColors theme) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final members = ref.watch(householdMembersProvider).value;
    final hasPartner = members?.any((m) => m.userId != currentUserId) ?? false;
    if (!hasPartner) return const [];

    final feed = ref.watch(combinedFeedControllerProvider).value;
    if (feed == null || feed.any((item) => item.isRealExpense)) {
      return const [];
    }
    final balances = ref.watch(expenseBalancesProvider).value;
    if (balances == null || balances.any((b) => b.balance.abs() > 0.01)) {
      return const [];
    }

    final t = AppLocalizations.of(context);
    return [
      const SizedBox(height: AppSpacing.md),
      AppCard(
        padding: AppInsets.compactCard,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: theme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.homeNextStepExpenseTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.homeNextStepExpenseBody,
                    style: AppTypography.caption.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: t.homeNextStepExpenseAction,
              size: AppButtonSize.small,
              onTap: () => ExpenseFormSheet.show(context),
            ),
          ],
        ),
      ).animateEntrance(delay: 140),
    ];
  }

  Widget _buildTasksSection(AppThemeColors theme) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final members =
        ref.watch(householdMembersProvider).value ?? const <MemberModel>[];
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateEyebrow =
        DateFormat('EEEE, d MMM', locale).format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final title = Text(
              t.homeCoupleTasksTitle,
              style:
                  AppTypography.sectionTitle.copyWith(color: theme.textPrimary),
            );
            final action = TextButton(
              onPressed: () => _goTo(MainTab.tasks),
              child: Text(t.homeViewWeekButton),
            );
            if (constraints.maxWidth < 330 ||
                MediaQuery.textScalerOf(context).scale(14) > 16) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, action],
              );
            }
            return Row(children: [Expanded(child: title), action]);
          },
        ),
        Text(
          dateEyebrow,
          style: AppTypography.caption.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(theme),
          error: (_, __) => AppInlineError(
            message: t.tasksLoadError,
            onRetry: () => ref.invalidate(tasksProvider),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildEmptyState(t.homeAllDoneToday, theme);
            }
            const taskPreviewLimit = 5;
            final visibleTasks =
                tasks.take(taskPreviewLimit).toList(growable: false);
            return Column(
              children: [
                for (var index = 0; index < visibleTasks.length; index++) ...[
                  if (index > 0) const SizedBox(height: 14),
                  _buildTaskCard(visibleTasks[index], theme, members)
                      .animateStaggered(index),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    TaskModel task,
    AppThemeColors theme,
    List<MemberModel> members,
  ) {
    final assignedMember =
        members.where((member) => member.userId == task.assignedTo).firstOrNull;

    return CoupleHomeTaskRow(
      task: task,
      busy: completingTaskIds.contains(task.id),
      assigned: assignedMember,
      currentUserId: ref.watch(currentUserIdProvider),
      onTap: () => _completeTask(task),
    );
  }

  // Shared flow lives in TaskCompletionFlowMixin. The optimistic feed entry is
  // added centrally by Tasks.completeTask (with the server activity_id), so the
  // view must NOT add it again — that caused a duplicate row in the feed.
  Future<void> _completeTask(TaskModel task) => runTaskCompletion(task);

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final t = AppLocalizations.of(context);

    if (activityAsync.hasValue &&
        !activityAsync.isLoading &&
        !activityAsync.hasError &&
        activityAsync.value!
            .every((activity) => activity['type'] == 'reward')) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.homeCoupleActivityTitle,
          style: AppTypography.sectionTitle.copyWith(
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        activityAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: AppLoader()),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppInlineError(
              message: t.homeActivityLoadError,
              onRetry: () => ref.invalidate(recentActivityRemoteProvider),
            ),
          ),
          data: (activities) {
            final visibleActivities = activities
                .where((activity) => activity['type'] != 'reward')
                .toList();
            if (visibleActivities.isEmpty) {
              return const SizedBox.shrink();
            }
            final previewActivities =
                visibleActivities.take(4).toList(growable: false);
            return Column(
              children: previewActivities.map(
                (activity) {
                  final creatorId = activity['creator_id'] as String?;
                  final isMe = creatorId == currentUserId;
                  return AppFeedEntryMotion(
                    key: ValueKey(_activityStableKey(activity)),
                    direction: isMe
                        ? AppFeedEntryDirection.fromRight
                        : AppFeedEntryDirection.fromLeft,
                    distance: 18,
                    beginScale: 0.98,
                    child: CoupleActivityTile(
                      activity: activity,
                      currentUserId: currentUserId,
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  String _activityStableKey(Map<String, dynamic> activity) {
    final type = activity['type']?.toString() ?? 'unknown';
    // Prefer the REAL server activity id. Optimistic rows carry it in
    // data['activity_id'] (the complete-task RPC returns it — see
    // task_provider.dart) and it equals the real remote row's top-level `id`.
    // Keying on it makes the optimistic→real swap reuse the SAME widget, so the
    // feed-entry animation does NOT replay (fixes the "movement re-enters a few
    // seconds later" glitch). The optimistic/remote merge already suppresses the
    // optimistic once the real arrives, so the two never coexist → no
    // duplicate-key risk. Multiple completions of the same task get distinct
    // activity ids; offline/queued rows (no activity_id yet) fall back to id.
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final activityId = data['activity_id']?.toString();
    if (activityId != null && activityId.isNotEmpty) {
      return '$type-$activityId';
    }
    final id = activity['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return '$type-$id';
    }
    return [
      activity['created_at'],
      data['task_id'],
      data['expense_id'],
    ].whereType<Object>().join('-');
  }

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(
      children: List.generate(
        2,
        (_) => ShimmerLoading(
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.primary.withValues(alpha: 0.065)),
      ),
      child: Column(
        children: [
          // Silueta de corazón M3E en vez de círculo: el acento "love" de
          // AppShapes, hecho para estos momentos de pareja.
          AppShapedBadge(
            shape: AppShapes.love,
            color: theme.primary.withValues(alpha: 0.12),
            size: 54,
            child: Icon(
              Icons.favorite_rounded,
              color: theme.primary.withValues(alpha: 0.68),
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTypography.cardTitle.copyWith(
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettlementDialog({
    required String partnerId,
    required String partnerName,
    required double amount,
  }) {
    showCoupleSettlementDialog(
      context: context,
      ref: ref,
      partnerId: partnerId,
      partnerName: partnerName,
      amount: amount,
      onSettled: () {
        if (mounted) {
          setState(() {
            _optimisticExpenseBalance = 0;
            _settlementJustCompleted = true;
          });
        }
        // Let the balance-card "just settled" flourish play, then clear it.
        Future<void>.delayed(const Duration(milliseconds: 2200), () {
          if (!mounted) return;
          setState(() => _settlementJustCompleted = false);
        });
      },
    );
  }
}
