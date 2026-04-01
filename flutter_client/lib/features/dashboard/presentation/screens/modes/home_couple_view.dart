import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_chat_bubble.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
          _buildFinancialSummary(widget.householdId),
          const SizedBox(height: 28),
          _buildTasksSection(theme),
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
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ).animateEntrance(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildProfileAvatar(currentMember).animateScaleIn(delay: 70),
          ],
        ),
        const SizedBox(height: 24),
        _buildHomeWelcome(theme: theme, partnerMember: partnerMember),
      ],
    );
  }

  Widget _buildHomeWelcome({
    required AppThemeColors theme,
    required dynamic partnerMember,
  }) {
    final partnerFirstName = _firstName(partnerMember?.displayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Todo lo importante',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.55,
          ),
        ).animate().fadeIn(delay: 100.ms),
        Text(
          'del hogar',
          style: TextStyle(
            color: theme.textPrimary.withValues(alpha: 0.7),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 24,
              height: 1.5,
              color: theme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'con ',
              style: TextStyle(color: theme.textSecondary, fontSize: 14),
            ),
            Text(
              partnerFirstName ?? 'tu pareja',
              style: TextStyle(
                color: theme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.favorite_rounded,
              size: 12,
              color: AppColors.accentOrange,
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
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
      child: CustomUserAvatar(
        name: member?.displayName,
        avatarUrl: member?.avatarUrl,
        radius: 26,
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
              onPressed: () =>
                  ref.read(bottomNavIndexProvider.notifier).setIndex(1),
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

    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = dialogContext.theme;
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isOwedByMe ? 'Equilibrar con $partnerName' : 'Registrar equilibrio',
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
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;

      try {
        await ref.read(expenseControllerProvider.notifier).settleDebt(
              fromUserId: payerId,
              toUserId: receiverId,
              amount: amount,
            );

        if (!mounted) return;
        _showMessage(
          isOwedByMe
              ? 'Balance equilibrado con $partnerName.'
              : 'Registramos el equilibrio con $partnerName.',
        );
      } catch (e) {
        if (!mounted) return;
        _showMessage('No se pudo equilibrar el balance: $e');
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
