import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_chat_bubble.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_shopping_preview_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/love_note_envelope.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/tour_target_keys.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
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

class _HomeCoupleViewState extends ConsumerState<HomeCoupleView> {
  final Set<String> _completedTaskIds = {};
  final GlobalKey _balanceKey = GlobalKey(debugLabel: 'tour_balance');
  final GlobalKey _tasksKey = GlobalKey(debugLabel: 'tour_tasks');
  bool _tourTriggered = false;

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
    final notifier = ref.read(tourTargetKeysProvider.notifier);
    notifier.register(TourTarget.balanceCard, _balanceKey);
    notifier.register(TourTarget.tasksSection, _tasksKey);
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
      final stillUnseen = !(ref
              .read(sharedPreferencesProvider)
              .getBool(tourFlagKey) ??
          false);
      if (!stillUnseen) return;
      final tasks = ref.read(todayTasksProvider).whenOrNull(data: (t) => t);
      ref.read(coupleHomeTourControllerProvider.notifier).start(
            hasTasks: (tasks?.isNotEmpty ?? false),
          );
    });
  }

  @override
  void dispose() {
    final notifier = ref.read(tourTargetKeysProvider.notifier);
    notifier.unregister(TourTarget.balanceCard, _balanceKey);
    notifier.unregister(TourTarget.tasksSection, _tasksKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: theme.primary,
      edgeOffset: 20,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          KeyedSubtree(
            key: _balanceKey,
            child: _buildFinancialSummary(widget.householdId),
          ),
          const SizedBox(height: 28),
          if (caps.showTasks)
            KeyedSubtree(
              key: _tasksKey,
              child: _buildTasksSection(theme),
            )
          else
            const HomeShoppingPreviewCard(title: 'Lista actual'),
          const SizedBox(height: 18),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final partnerMember =
        members.where((m) => m.userId != currentUserId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    _buildWelcomeGreetingSpan(
                      theme: theme,
                      currentMemberName: currentMember?.displayName,
                    ),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                      letterSpacing: -0.8,
                    ),
                  ).animateEntrance(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildProfileAvatar(currentMember).animateScaleIn(delay: 70),
          ],
        ),
        const SizedBox(height: 8),
        _buildHomeWelcome(
          theme: theme,
          partnerMember: partnerMember,
          senderName: partnerMember != null
              ? (partnerMember.displayName.split(' ').first)
              : 'tu pareja',
        ),
      ],
    );
  }

  Widget _buildHomeWelcome({
    required AppThemeColors theme,
    required dynamic partnerMember,
    required String senderName,
  }) {
    final partnerFirstName = _firstName(partnerMember?.displayName);
    final pendingNote = ref.watch(pendingLoveNoteProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Texto "Todo lo importante / del hogar / con X"
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Todo lo importante',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                  letterSpacing: -0.45,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 3),
              Text(
                'del hogar',
                style: TextStyle(
                  color: theme.textPrimary.withValues(alpha: 0.62),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                  letterSpacing: -0.35,
                ),
              ).animate().fadeIn(delay: 170.ms),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          theme.primary.withValues(alpha: 0.55),
                          theme.primary.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'con ',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    partnerFirstName ?? 'tu pareja',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.favorite_rounded,
                    size: 13,
                    color: theme.primary.withValues(alpha: 0.82),
                  ),
                ],
              ).animate().fadeIn(delay: 240.ms),
            ],
          ),
        ),

        // Sobre animado — solo si hay nota pendiente
        if (pendingNote != null) ...[
          const SizedBox(width: 10),
          LoveNoteEnvelope(
            note: pendingNote,
            senderName: senderName,
          ),
        ],
      ],
    );
  }

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.split(' ').first;
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final firstName = _firstName(currentMemberName);
    final welcome = firstName != null
        ? (_looksFeminineName(firstName) ? 'Bienvenida' : 'Bienvenido')
        : 'Bienvenido';

    return TextSpan(
      children: [
        TextSpan(
          text: '$welcome, ',
          style: TextStyle(color: theme.textPrimary),
        ),
        TextSpan(
          text: firstName ?? 'Usuario',
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  bool _looksFeminineName(String name) {
    final normalized = name.trim().toLowerCase();
    const masculineExceptions = {'blas', 'luca', 'noa', 'andrea'};
    if (masculineExceptions.contains(normalized)) return false;
    return normalized.endsWith('a');
  }

  Widget _buildProfileAvatar(dynamic member) {
    return AnimatedPress(
      onTap: widget.onAvatarTap,
      child: Transform.translate(
        offset: const Offset(6, 0),
        child: SizedBox(
          width: 88,
          height: 58,
          child: OverflowBox(
            alignment: Alignment.topRight,
            maxWidth: 104,
            maxHeight: 104,
            child: CustomUserAvatar(
              name: member?.displayName,
              avatarUrl: member?.avatarUrl,
              radius: 26,
              isAnimated: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    double myExpenseBalance = 0;
    expenseBalancesAsync.whenData((balances) {
      final myBalanceModel =
          balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (myBalanceModel != null) myExpenseBalance = myBalanceModel.balance;
    });

    final partner = membersAsync.whenOrNull(
      data: (members) =>
          members.where((m) => m.userId != currentUserId).firstOrNull,
    );

    return BalanceCard(
      coins: balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0,
      xp: balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0,
      userBalance: myExpenseBalance,
      partnerName: partner?.displayName,
      onSettle: partner != null && myExpenseBalance.abs() > 10.0
          ? () => _showSettlementDialog(
                householdId: householdId,
                partnerId: partner.userId,
                partnerName: partner.displayName,
                amount: myExpenseBalance.abs(),
                isOwedByMe: myExpenseBalance < 0,
              )
          : null,
    ).animateEntrance(delay: 100);
  }

  Widget _buildTasksSection(AppThemeColors theme) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final caps = ref.watch(householdCapabilitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoy en casa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.7,
              ),
            ),
            TextButton(
              onPressed: () {
                final index = indexForMainTab(caps, MainTab.tasks);
                if (index >= 0) {
                  ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                }
              },
              child: Text(
                'Ver Semana',
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(theme),
          error: (e, _) => Text('Error: $e'),
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildEmptyState('Todo listo por hoy', theme);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) =>
                  _buildTaskCard(tasks.elementAt(index), theme),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, AppThemeColors theme) {
    return DashboardTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      onTap: () => _completeTask(task),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).completeTask(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Movimientos del hogar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.textPrimary,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        activityAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Error: $e'),
          ),
          data: (activities) {
            if (activities.isEmpty) {
              return _buildActivityEmptyState(theme);
            }
            return Column(
              children: activities
                  .map(
                    (activity) => ActivityChatBubble(
                      activity: activity,
                      currentUserId: currentUserId,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityEmptyState(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surfaceVariant.withValues(alpha: 0.32),
            theme.surface.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.border.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: theme.primary.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todavia no hay movimientos',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Cuando haya una tarea o un gasto nuevo, aparece aca.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(
      children: List.generate(
        2,
        (_) => ShimmerLoading(
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20),
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
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: theme.primary.withValues(alpha: 0.68),
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettlementDialog({
    required String householdId,
    required String partnerId,
    required String partnerName,
    required double amount,
    required bool isOwedByMe,
  }) {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) {
      _showMessage('No pudimos identificar tu usuario.');
      return;
    }

    final payerId = isOwedByMe ? currentUserId : partnerId;
    final receiverId = isOwedByMe ? partnerId : currentUserId;
    final formattedAmount =
        NumberFormat.decimalPattern('es_AR').format(amount.round());

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = dialogContext.theme;
        var isSubmitting = false;
        var showSuccess = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                isOwedByMe
                    ? 'Equilibrar con $partnerName'
                    : 'Registrar equilibrio',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Text(
                isOwedByMe
                    ? 'Se va a registrar un pago de \$ $formattedAmount para saldar el balance con $partnerName.'
                    : 'Se va a registrar que $partnerName te compenso \$ $formattedAmount para dejar el balance al dia.',
                style: TextStyle(
                  color: theme.textSecondary,
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);

                          try {
                            await ref
                                .read(expenseControllerProvider.notifier)
                                .settleDebt(
                                  fromUserId: payerId,
                                  toUserId: receiverId,
                                  amount: amount,
                                );

                            HapticFeedback.mediumImpact();
                            setDialogState(() {
                              isSubmitting = false;
                              showSuccess = true;
                            });

                            await Future<void>.delayed(
                              const Duration(milliseconds: 420),
                            );

                            if (!mounted || !dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            _showMessage(
                              isOwedByMe
                                  ? 'Balance equilibrado con $partnerName.'
                                  : 'Registramos el equilibrio con $partnerName.',
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() => isSubmitting = false);
                            _showMessage(
                              'No se pudo equilibrar el balance: $e',
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        showSuccess ? AppColors.sage : theme.primary,
                    disabledBackgroundColor:
                        showSuccess ? AppColors.sage : theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: isSubmitting
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : showSuccess
                            ? const Row(
                                key: ValueKey('success'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Listo'),
                                ],
                              )
                            : const Text(
                                'Confirmar',
                                key: ValueKey('idle'),
                              ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
