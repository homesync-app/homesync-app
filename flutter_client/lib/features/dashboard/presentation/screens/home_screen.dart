import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/offline_indicator.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/complete_task_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onAvatarTap;

  const HomeScreen({
    super.key,
    this.onAvatarTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  final Set<String> _completedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setupTaskCompletionListener(ref);
    final householdAsync = ref.watch(householdIdProvider);
    final theme = context.theme;

    return householdAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.background,
        body: const AppLoadingState(message: 'Cargando inicio...'),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: theme.background,
        body: AppErrorState(
          message: 'No pudimos cargar tu hogar.\n$e',
          onRetry: _refreshHome,
        ),
      ),
      data: (householdId) {
        if (householdId == null) {
          return Scaffold(
            backgroundColor: theme.background,
            body: const AppEmptyState(
              title: 'No perteneces a un hogar todavia',
              subtitle: 'Crea o unite a un hogar para comenzar.',
              icon: Icons.home_work_outlined,
            ),
          );
        }
        return Stack(
          children: [
            _buildMainContent(householdId, theme),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  theme.primary,
                  AppColors.success,
                  AppColors.accentOrange,
                  Colors.blue,
                  Colors.pink,
                ],
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
        );
      },
    );
  }

  void _setupTaskCompletionListener(WidgetRef ref) {
    ref.listen(todayTasksProvider, (previous, next) {
      if (previous?.asData?.value.isNotEmpty == true &&
          next.asData?.value.isEmpty == true &&
          !next.isLoading &&
          !next.hasError) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    });
  }

  Widget _buildMainContent(String householdId, AppThemeColors theme) {
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => _refreshHome(),
                color: theme.primary,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFinancialSummary(householdId),
                    const SizedBox(height: 30),
                    _buildTasksSection(theme),
                    const SizedBox(height: 30),
                    _buildActivitySection(theme),
                    const SizedBox(height: AppSpacing.xxl + 56),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: FloatingActionButton.extended(
          onPressed: () => _showQuickActionMenu(householdId),
          backgroundColor: theme.primary,
          elevation: 6,
          extendedPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 17),
          label: const Text(
            'Nueva Accion',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: -0.25,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ).animateScaleIn(delay: 600),
      ),
    );
  }

  Future<void> _refreshHome() async {
    ref.invalidate(todayTasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(expenseControllerProvider);
  }

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final sortedMembers = [...members]..sort((a, b) {
        if (a.userId == currentUserId) return -1;
        if (b.userId == currentUserId) return 1;
        return a.displayName.compareTo(b.displayName);
      });
    final currentMember = sortedMembers
        .where((member) => member.userId == currentUserId)
        .firstOrNull;
    final partnerMember = sortedMembers
        .where((member) => member.userId != currentUserId)
        .firstOrNull;
    double balance = 0;
    expenseBalancesAsync.whenData((balances) {
      final mine = balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (mine != null) {
        balance = mine.balance;
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      child: Column(
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
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                        height: 0.98,
                      ),
                    ).animateEntrance(),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildProfileAvatar(currentMember).animateScaleIn(delay: 70),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHomeWelcome(
            theme: theme,
            partnerMember: partnerMember,
            balance: balance,
          ).animateEntrance(delay: 110),
        ],
      ),
    );
  }

  Widget _buildHomeWelcome({
    required AppThemeColors theme,
    required dynamic partnerMember,
    required double balance,
  }) {
    final accentColor = balance < -0.01 ? AppColors.accentOrange : AppColors.sage;

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 78),
      child: Text.rich(
        _buildHomeSummarySpan(
          theme: theme,
          accentColor: accentColor,
          partnerName: partnerMember?.displayName,
        ),
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.34,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final firstName = _firstName(currentMemberName);
    final welcome = _buildWelcomeWord(firstName);
    if (firstName == null) {
      return TextSpan(
        text: welcome,
        style: TextStyle(
          color: theme.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return TextSpan(
      children: [
        TextSpan(
          text: '$welcome, ',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: firstName,
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  TextSpan _buildHomeSummarySpan({
    required AppThemeColors theme,
    required Color accentColor,
    required String? partnerName,
  }) {
    final partnerFirstName = _firstName(partnerName);
    if (partnerFirstName == null) {
      return TextSpan(
        children: [
          TextSpan(
            text: 'Aca vive ',
            style: TextStyle(color: theme.textSecondary),
          ),
          TextSpan(
            text: 'todo lo que hace a tu hogar',
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(color: theme.textSecondary),
          ),
        ],
      );
    }
    return TextSpan(
      children: [
        TextSpan(
          text: 'Aca vive ',
          style: TextStyle(
            color: theme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextSpan(
          text: 'lo importante de tu hogar',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: ' con ',
          style: TextStyle(
            color: theme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(left: 1),
            padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.55),
                  const Color(0xFFFFF2EA).withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  partnerFirstName,
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.favorite_rounded,
                  size: 8,
                  color: accentColor.withValues(alpha: 0.85),
                ),
                Transform.translate(
                  offset: const Offset(-1.5, -1.5),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 6.5,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextSpan(
          text: '.',
          style: TextStyle(color: theme.textSecondary),
        ),
      ],
    );
  }

  String _buildWelcomeWord(String? firstName) {
    if (firstName == null) return 'Bienvenida/o';
    return _looksFeminineName(firstName) ? 'Bienvenida' : 'Bienvenido';
  }

  bool _looksFeminineName(String name) {
    final normalized = name.trim().toLowerCase();
    const masculineExceptions = {
      'blas',
      'luca',
      'noa',
      'andrea',
      'nicola',
      'eliya',
      'josa',
    };
    if (masculineExceptions.contains(normalized)) return false;
    return normalized.endsWith('a');
  }

  Widget _buildProfileAvatar(dynamic member) {
    final theme = context.theme;

    return AnimatedPress(
      onTap: widget.onAvatarTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.88),
          border: Border.all(
            color: theme.border.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowBase.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: CustomUserAvatar(
          name: member?.displayName,
          avatarUrl: member?.avatarUrl,
          radius: 26,
        ),
      ),
    );
  }

  String? _firstName(String? name) {
    if (name == null) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.split(' ').first;
  }

  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    final coins =
        balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;
    final xp = balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0;

    double myExpenseBalance = 0;
    expenseBalancesAsync.whenData((balances) {
      final myBalanceModel =
          balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (myBalanceModel != null) {
        myExpenseBalance = myBalanceModel.balance;
      }
    });

    final partner = membersAsync.whenOrNull(
      data: (members) =>
          members.where((m) => m.userId != currentUserId).firstOrNull,
    );

    return BalanceCard(
      coins: coins,
      xp: xp,
      userBalance: myExpenseBalance,
      partnerName: partner?.displayName,
      onSettle: partner != null && myExpenseBalance.abs() > 10.0
          ? () => _showSettlementDialog(
                householdId: householdId,
                partnerId: partner.userId,
                partnerName: partner.displayName,
                amount: myExpenseBalance.abs(),
                isOwedByMe: myExpenseBalance < 0,
                alias: partner.mercadopagoAlias,
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
              'Lo que necesita la casa hoy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.7,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(taskViewModeProvider.notifier).setCalendar();
                ref.read(bottomNavIndexProvider.notifier).setIndex(1);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
                child: Text(
                  'Ver Semana',
                  style: TextStyle(
                    color: theme.primary.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: -0.1,
                  ),
                ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(theme),
          error: (e, _) =>
              Text('Error: $e', style: TextStyle(color: theme.textPrimary)),
          data: (tasks) {
            final visibleTasks = tasks.toList();
            if (visibleTasks.isEmpty) {
              return _buildEmptyState('Todo listo por hoy', theme);
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleTasks.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) =>
                  _buildTaskCard(visibleTasks[index], theme)
                      .animateStaggered(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, AppThemeColors theme) {
    final categoryColor = AppColors.getCategoryColor(task.category);
    final categoryIcon =
        AppColors.getCategoryMaterialIcon(task.category?.toLowerCase());
    final isCompleting = _completedTaskIds.contains(task.id);
    final canComplete = !isCompleting;

    return AnimatedPress(
      onTap: canComplete ? () => _completeTask(task) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: theme.isDarkMode
              ? Border.all(color: theme.border, width: 1.2)
              : null,
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          children: [
            // Category icon with subtle background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(categoryIcon, size: 22, color: categoryColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: theme.textPrimary,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs, vertical: 5),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppColors.categoryNames[
                                  task.category?.toLowerCase()] ??
                              task.category ??
                              'General',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFE8943A),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${task.xpReward} XP',
                            style: TextStyle(
                              color: theme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleting
                    ? AppColors.accentGold.withValues(alpha: 0.12)
                    : theme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: isCompleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentGold,
                      ),
                    )
                  : Icon(
                      Icons.check_rounded,
                      color: theme.primary,
                      size: 20,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    HapticFeedback.mediumImpact();
    setState(() => _completedTaskIds.add(task.id));

    try {
      final result = await ref.read(tasksProvider.notifier).completeTask(task);
      if ((result == null || !result.success) && mounted) {
        setState(() => _completedTaskIds.remove(task.id));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al completar la tarea. Intenta de nuevo.')));
      } else {
        // Success
        _confettiController.play();
        HapticFeedback.heavyImpact();
        final completion = result!;
        final xp = completion.xpEarned ?? task.xpReward;
        final coins = completion.coinsEarned ?? task.coinReward;
        if (mounted) {
          setState(() => _completedTaskIds.remove(task.id));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⭐ ¡Ganaste $xp XP y $coins coins!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
                child: Text(
                  'Ver todo',
                  style: TextStyle(
                    color: theme.primary.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: -0.1,
                  ),
                ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        activityAsync.when(
          loading: () => _buildActivityShimmer(theme),
          error: (e, _) => Text('Error al cargar actividad: $e',
              style: TextStyle(color: theme.textPrimary)),
          data: (activities) {
            if (activities.isEmpty) {
              return _buildEmptyState('No hay actividad aun', theme);
            }
            return _buildActivityCards(activities, theme);
          },
        ),
      ],
    );
  }

  Widget _buildActivityShimmer(AppThemeColors theme) {
    return Column(
      children: List.generate(
          3,
          (_) => ShimmerLoading(
                child: Container(
                  height: 74,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 12,
                              width: 160,
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
    );
  }

  Widget _buildActivityCards(
      List<Map<String, dynamic>> activities, AppThemeColors theme) {
    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        final id = activity['id'] ?? index.toString();
        final isLast = index == activities.length - 1;
        return _buildActivityCard(
          activity,
          theme,
          key: ValueKey(id),
          isLast: isLast,
        ).animateStaggered(index);
      }),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, AppThemeColors theme,
      {Key? key, required bool isLast}) {
    final type = activity['type'] as String;
    final data = activity['data'] as Map<String, dynamic>;
    final rawTitle =
        (data['task_title'] ?? data['reward_title'] ?? data['title'] ?? '')
            .toString()
            .toLowerCase();
    final isRewardActivity = type == 'reward' ||
        rawTitle.contains('canje') ||
        rawTitle.contains('premio') ||
        rawTitle.contains('reward');
    final time =
        (DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now())
            .toLocal();
    final timeStr = _formatActivityTime(time);

    Color accentColor;
    String actionVerb;
    String itemLabel;
    String? amountStr;
    late IconData categoryIcon;

    if (isRewardActivity) {
      accentColor = AppColors.accentGold;
      actionVerb = 'canjeo';
      itemLabel = _cleanRewardLabel(
        data['reward_title']?.toString() ??
            data['task_title']?.toString() ??
            data['title']?.toString() ??
            'Premio',
      );
      categoryIcon = Icons.card_giftcard_rounded;
    } else if (type == 'task') {
      accentColor = AppColors.accentBlue;
      actionVerb = 'completo';
      itemLabel = data['task_title'] ?? data['title'] ?? 'Tarea';
      final category = (data['category'] as String?)?.toLowerCase();
      categoryIcon = AppColors.getCategoryMaterialIcon(category);
    } else if (type == 'expense') {
      final isIncome = data['type'] == 'income' || data['type'] == 'ingreso';
      final isGift = data['split_type'] == 'gift';
      final rawCategory = (data['category'] as String?)?.toLowerCase();

      categoryIcon = AppColors.getSmartExpenseDisplayIcon(
        rawCategory,
        title: data['title'] as String?,
        description: data['description'] as String?,
        transactionType: data['type'] as String?,
        splitType: data['split_type'] as String?,
      );

      if (isGift) {
        accentColor = Colors.pinkAccent;
        actionVerb = 'dio un regalo';
        itemLabel = 'Regalo';
        categoryIcon = Icons.card_giftcard_rounded;
      } else if (data['type'] == 'settlement') {
        accentColor = AppColors.success;
        actionVerb = 'saldo';
        itemLabel = 'Cuentas claras';
        categoryIcon = Icons.sync_alt_rounded;
      } else if (isIncome) {
        accentColor = AppColors.getSmartExpenseDisplayColor(
          rawCategory,
          title: data['title'] as String?,
          description: data['description'] as String?,
          transactionType: data['type'] as String?,
          splitType: data['split_type'] as String?,
        );
        actionVerb = 'recibio';
        itemLabel = AppColors.categoryNames[rawCategory] ??
            data['category'] ??
            'Ingreso';
      } else {
        accentColor = _resolveActivityExpenseColor(
          rawCategory: rawCategory,
          title: data['title'] as String?,
          description: data['description'] as String?,
          fallback: AppColors.getSmartExpenseDisplayColor(
            rawCategory,
            title: data['title'] as String?,
            description: data['description'] as String?,
            transactionType: data['type'] as String?,
            splitType: data['split_type'] as String?,
          ),
        );
        final expensePhrase = _buildExpenseActivityPhrase(
          rawCategory: rawCategory,
          rawLabel: data['category']?.toString(),
          title: data['title']?.toString(),
          description: data['description']?.toString(),
        );
        actionVerb = expensePhrase.actionVerb;
        itemLabel = expensePhrase.itemLabel;
      }

      final amount = data['amount'];
      if (amount != null) {
        final formatted = NumberFormat.decimalPattern('es_AR').format(
          (amount is num ? amount : double.tryParse(amount.toString()) ?? 0)
              .round(),
        );
        amountStr = '\$$formatted';
      }
    } else {
      accentColor = theme.textSecondary;
      actionVerb = 'registro';
      itemLabel = data['title'] ?? 'Evento';
      categoryIcon = Icons.push_pin_rounded;
    }

    final userName = data['user_name'] as String? ?? 'Usuario';
    final avatarUrl = data['avatar_url'] as String?;
    final description = data['description'] as String?;
    final hasDetail = description != null && description.trim().isNotEmpty;
    final isClickable = type == 'expense' ||
        type == 'task' ||
        type == 'reward' ||
        isRewardActivity ||
        hasDetail;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnimatedPress(
        onTap: isClickable
            ? () async => _handleActivityTap(
                activity, itemLabel, description, accentColor)
            : null,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.22),
                        width: 1,
                      ),
                    ),
                    child: CustomUserAvatar(
                      name: userName,
                      avatarUrl: avatarUrl,
                      radius: 15,
                      showBorder: false,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: userName.split(' ').first,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: theme.textPrimary,
                                    letterSpacing: -0.25,
                                    height: 1.1,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${_humanizeActivityVerb(actionVerb)}',
                                  style: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              color: theme.textPrimary,
                            ),
                          ),
                          _activityLabelText(
                            label: itemLabel,
                            color: accentColor,
                            icon: categoryIcon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 12,
                        runSpacing: 5,
                        children: [
                          _activityMetaText(
                            label: timeStr,
                            color: theme.textMuted,
                            icon: Icons.access_time_rounded,
                          ),
                          if (type == 'task' && !isRewardActivity) ...[
                            if (data['xp_per_user'] != null ||
                                data['xp_reward'] != null ||
                                data['xp'] != null)
                              _activityMetaText(
                                label:
                                    '${_formatNumber(data['xp_per_user'] ?? data['xp_reward'] ?? data['xp'])} XP',
                                color: const Color(0xFFE8943A),
                                icon: Icons.star_rounded,
                              ),
                            if (data['coins_per_user'] != null ||
                                data['coin_reward'] != null)
                              _activityMetaText(
                                label:
                                    '${_formatNumber(data['coins_per_user'] ?? data['coin_reward'])} coins',
                                color: AppColors.sage,
                                icon: Icons.monetization_on_rounded,
                              ),
                          ] else if (amountStr != null)
                            _activityMetaText(
                              label: amountStr,
                              color: accentColor,
                              icon: type == 'reward'
                                  ? Icons.card_giftcard_rounded
                                  : Icons.receipt_long_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 10),
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(right: 8),
                  color: theme.border.withValues(alpha: 0.22),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _activityMetaText({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.92),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  Color _resolveActivityExpenseColor({
    required String? rawCategory,
    required String? title,
    required String? description,
    required Color fallback,
  }) {
    final category = (rawCategory ?? '').toLowerCase();
    final content = '${title ?? ''} ${description ?? ''}'.toLowerCase();

    if (category.contains('comida') ||
        category.contains('food') ||
        category.contains('restaurant') ||
        content.contains('almuerzo') ||
        content.contains('cena') ||
        content.contains('desayuno') ||
        content.contains('pizza') ||
        content.contains('sushi')) {
      return AppColors.sage;
    }

    if (category.contains('supermarket') ||
        category.contains('mercado') ||
        category.contains('compras') ||
        category.contains('shopping') ||
        category.contains('ropa') ||
        content.contains('supermercado') ||
        content.contains('farmacia') ||
        content.contains('verduleria') ||
        content.contains('panaderia') ||
        content.contains('kiosco')) {
      return AppColors.primary;
    }

    return fallback;
  }

  Widget _activityLabelText({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: -0.1,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  String _formatActivityTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Recien';
    }
    if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    }
    return DateFormat('d MMM', 'es').format(time);
  }

  _ExpenseActivityPhrase _buildExpenseActivityPhrase({
    required String? rawCategory,
    required String? rawLabel,
    required String? title,
    required String? description,
  }) {
    final category = (rawCategory ?? rawLabel ?? '').toLowerCase().trim();
    final readableLabel =
        AppColors.categoryNames[rawCategory] ?? rawLabel ?? 'Gasto';
    final content = '${title ?? ''} ${description ?? ''}'.toLowerCase();

    String? detectSpecificPlace(Map<String, List<String>> options) {
      for (final entry in options.entries) {
        if (entry.value.any(content.contains)) {
          return entry.key;
        }
      }
      return null;
    }

    if (category.contains('supermarket') ||
        category.contains('mercado') ||
        category.contains('compras') ||
        category.contains('ropa')) {
      final specificStore = detectSpecificPlace({
        'Supermercado': ['supermercado', 'mercado', 'compras del super'],
        'Farmacia': ['farmacia'],
        'Verduleria': ['verduleria', 'verdulería'],
        'Panaderia': ['panaderia', 'panadería'],
        'Kiosco': ['kiosco'],
        'Libreria': ['libreria', 'librería'],
        'Tienda': ['tienda', 'local'],
      });
      return const _ExpenseActivityPhrase(
        actionVerb: 'compro en',
        itemLabel: 'supermercado',
      ).copyWith(
        itemLabel: specificStore ?? 'supermercado',
      );
    }

    if (category.contains('utilities') ||
        category.contains('servicio') ||
        category.contains('factura') ||
        content.contains('luz') ||
        content.contains('agua') ||
        content.contains('gas') ||
        content.contains('internet')) {
      final specificService = detectSpecificPlace({
        'Luz': ['luz', 'electricidad'],
        'Agua': ['agua'],
        'Gas': ['gas'],
        'Internet': ['internet', 'wifi'],
        'Telefono': ['telefono', 'teléfono', 'celular'],
      });
      return const _ExpenseActivityPhrase(
        actionVerb: 'pago',
        itemLabel: 'Servicios',
      ).copyWith(
        itemLabel: specificService ?? 'Servicios',
      );
    }

    if (category.contains('rent') || category.contains('alquiler')) {
      return const _ExpenseActivityPhrase(
        actionVerb: 'pago',
        itemLabel: 'Alquiler',
      );
    }

    if (category.contains('transport') ||
        category.contains('transporte') ||
        content.contains('subte') ||
        content.contains('colectivo') ||
        content.contains('uber') ||
        content.contains('nafta')) {
      final specificTransport = detectSpecificPlace({
        'Uber': ['uber', 'cabify'],
        'Subte': ['subte', 'metro'],
        'Colectivo': ['colectivo', 'bondi', 'bus'],
        'Nafta': ['nafta', 'combustible', 'gasolina'],
        'Taxi': ['taxi'],
      });
      return const _ExpenseActivityPhrase(
        actionVerb: 'pago',
        itemLabel: 'Transporte',
      ).copyWith(
        itemLabel: specificTransport ?? 'Transporte',
      );
    }

    if (category.contains('restaurant') ||
        category.contains('restaurante') ||
        category.contains('restaurants') ||
        content.contains('sushi') ||
        content.contains('pizza') ||
        content.contains('cafe')) {
      final specificFood = detectSpecificPlace({
        'Sushi': ['sushi'],
        'Pizza': ['pizza', 'pizzeria', 'pizzería'],
        'Cafe': ['cafe', 'café', 'cafeteria', 'cafetería'],
        'Helado': ['helado', 'heladeria', 'heladería'],
        'Hamburguesa': ['hamburguesa', 'burger'],
        'Restaurante': ['restaurante', 'restaurant', 'bistro', 'bistró'],
      });
      return const _ExpenseActivityPhrase(
        actionVerb: 'pago',
        itemLabel: 'sushi',
      ).copyWith(
        itemLabel: specificFood ?? 'comida',
      );
    }

    if (category.contains('health') || category.contains('salud')) {
      return const _ExpenseActivityPhrase(
        actionVerb: 'pago',
        itemLabel: 'Salud',
      );
    }

    return _ExpenseActivityPhrase(
      actionVerb: 'gasto en',
      itemLabel: readableLabel,
    );
  }

  String _cleanRewardLabel(String rawLabel) {
    final cleaned = rawLabel
        .replaceFirst(
          RegExp(r'^\s*canje[oó]\s+premio:?\s*', caseSensitive: false),
          '',
        )
        .replaceFirst(
          RegExp(r'^\s*canje[oó]:?\s*', caseSensitive: false),
          '',
        )
        .trim();

    return cleaned.isEmpty ? 'Premio' : cleaned;
  }

  String _humanizeActivityVerb(String verb) {
    switch (verb.toLowerCase()) {
      case 'compro en':
        return 'compró en';
      case 'completo':
        return 'completó';
      case 'canjeo':
        return 'canjeó';
      case 'recibio':
        return 'recibió';
      case 'pago':
        return 'pagó';
      case 'gasto en':
        return 'gastó en';
      case 'saldo':
        return 'saldó';
      default:
        return verb;
    }
  }

  Future<void> _handleActivityTap(Map<String, dynamic> activity,
      String itemLabel, String? description, Color accentColor) async {
    final type = activity['type'] as String;
    final data = activity['data'] as Map<String, dynamic>;
    final theme = context.theme;

    if (type == 'task') {
      final taskMap = Map<String, dynamic>.from(data);
      taskMap['id'] ??= data['task_id'];
      taskMap['activity_id'] = activity['id'];
      taskMap['completed_at'] ??= activity['created_at'];
      taskMap['status'] = 'pending_verification';
      taskMap['xp_reward'] ??=
          data['xp_per_user'] ?? data['xp_reward'] ?? data['xp'];
      taskMap['coin_reward'] ??=
          data['coins_per_user'] ?? data['coin_reward'] ?? data['coins'];
      taskMap['completed_user'] = {
        'id': activity['creator_id'],
        'full_name': data['user_name'],
        'avatar_url': data['avatar_url'],
      };

      TaskDetailSheet.show(
        context,
        taskMap,
        onChanged: () {
          ref.invalidate(recentActivityProvider);
          ref.invalidate(todayTasksProvider);
          ref.invalidate(userBalanceProvider);
        },
      );
      return;
    }

    if (type == 'expense') {
      final expenseId = _extractExpenseId(data);
      if (expenseId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos identificar este gasto.')),
        );
        return;
      }

      ExpenseModel? expense;
      final cachedExpenses =
          ref.read(expenseControllerProvider).asData?.value ?? const [];
      expense = cachedExpenses.where((e) => e.id == expenseId).firstOrNull;

      if (expense == null) {
        final refreshedExpenses =
            await ref.refresh(expenseControllerProvider.future);
        expense = refreshedExpenses.where((e) => e.id == expenseId).firstOrNull;
      }

      if (expense == null) {
        final repo = ref.read(expenseRepositoryProvider);
        final singleExpenseResult = await repo.getExpenseWithSplits(expenseId);
        expense = singleExpenseResult.fold(
          (_) => null,
          (raw) {
            final map = Map<String, dynamic>.from(raw);
            map['id'] ??= expenseId;
            return ExpenseModel.fromJson(map);
          },
        );
      }

      if (expense != null) {
        if (!mounted) return;
        ExpenseDetailSheet.show(context, expense);
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Este gasto ya no esta disponible o fue eliminado')));
      return;
    }

    if (description == null || description.isEmpty) return;

    final isShoppingList = description.toLowerCase().contains('lista') ||
        description.contains('\n') ||
        description.contains('- ');
    final items = description
        .split(RegExp(r'\n'))
        .map((e) => e.trim().replaceAll(RegExp(r'^[-*]\s*'), ''))
        .where((e) => e.isNotEmpty && !e.toLowerCase().contains('lista'))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: theme.surface, shape: BoxShape.circle),
                    child: Icon(
                        isShoppingList
                            ? Icons.shopping_cart_rounded
                            : Icons.info_outline_rounded,
                        color: accentColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isShoppingList ? 'Lista de Compras' : 'Detalles',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: theme.textPrimary),
                        ),
                        Text(
                          itemLabel,
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: theme.textPrimary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isShoppingList
                    ? Column(
                        children: items
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          size: 20, color: AppColors.sage),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: theme.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      )
                    : Text(description,
                        style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 15,
                            height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _extractExpenseId(Map<String, dynamic> data) {
    final candidates = [
      data['expense_id'],
      data['expenseId'],
      data['id'],
      data['expense'],
    ];

    for (final value in candidates) {
      final parsed = value?.toString().trim();
      if (parsed != null && parsed.isNotEmpty && parsed != 'null') {
        return parsed;
      }
    }
    return null;
  }

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(
      children: List.generate(
          2,
          (_) => ShimmerLoading(
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(24)),
                ),
              )),
    );
  }

  Widget _buildEmptyState(String message, AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Text('🐾', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionMenu(String householdId) {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Que deseas hacer?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.add_shopping_cart_rounded,
                      label: 'Cargar Gasto',
                      color: theme.primary,
                      theme: theme,
                      onTap: () {
                        Navigator.pop(context);
                        ExpenseFormSheet.show(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Completar Tarea',
                      color: AppColors.success,
                      theme: theme,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              CompleteTaskSheet(onTasksCompleted: () {}),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required AppThemeColors theme,
    required VoidCallback onTap,
  }) {
    return AnimatedPress(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
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
    String? alias,
  }) {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: AppColors.accentOrange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Saldar deuda con ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirmas que ya realizaste la transferencia de \$${amount.toStringAsFixed(2)} a $partnerName? Esto equilibrara el balance de la pareja a 0 nuevamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Aun no',
                        style: TextStyle(
                          color: theme.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        final currentUserId = ref.read(currentUserIdProvider);
                        await ref
                            .read(expenseControllerProvider.notifier)
                            .settleDebt(
                              fromUserId: isOwedByMe
                                  ? (currentUserId ?? '')
                                  : partnerId,
                              toUserId: isOwedByMe
                                  ? partnerId
                                  : (currentUserId ?? ''),
                              amount: amount,
                            );

                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Balance equilibrado. Todo listo.'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Si, saldar',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildLoveNotesSection(AppThemeColors theme) {
    final isPremium = ref.watch(premiumProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas de Amor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: theme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (isPremium) _buildNotesList(theme),
        AnimatedPress(
          onTap: () {
            if (!isPremium) {
              PremiumPaywall.show(context);
            } else {
              _showLoveNoteDialog(theme);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [const Color(0xFFFEE2E2), theme.surface]
                    : [
                        theme.isDarkMode
                            ? Colors.grey[900]!
                            : Colors.grey[100]!,
                        theme.surface
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isPremium
                    ? const Color(0xFFFCA5A5).withValues(alpha: 0.5)
                    : theme.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPremium ? const Color(0xFFF87171) : theme.shadow)
                      .withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? const Color(0xFFFECACA)
                        : (theme.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPremium ? Icons.favorite_rounded : Icons.lock_rounded,
                    color:
                        isPremium ? const Color(0xFFEF4444) : Colors.grey[400],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium
                            ? 'Deja un mensaje especial'
                            : 'Función Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isPremium
                              ? const Color(0xFF991B1B)
                              : theme.textPrimary,
                        ),
                      ),
                      Text(
                        isPremium
                            ? 'Sorprende a tu pareja hoy ✨'
                            : 'Suscríbete para enviar notas de amor.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isPremium
                              ? const Color(0xFFB91C1C).withValues(alpha: 0.7)
                              : theme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLoveNoteDialog(AppThemeColors theme) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Nueva Nota de Amor',
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: theme.textPrimary),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: theme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Escribe algo tierno...',
            filled: true,
            fillColor: Colors.red.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: theme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final content = controller.text.trim();
              if (content.isNotEmpty) {
                ref.read(loveNotesProvider.notifier).sendNote(
                      content,
                      ref.read(currentUserIdProvider) ?? 'me',
                      'partner',
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💖 Nota enviada exitosamente'),
                    backgroundColor: Colors.pink,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(AppThemeColors theme) {
    final notes = ref.watch(loveNotesProvider);
    if (notes.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final note = notes[index];
          return GestureDetector(
            onTap: () {
              ref.read(loveNotesProvider.notifier).markAsRead(note.id);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  backgroundColor: theme.surface,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    'De mi pareja 💖',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: theme.textPrimary),
                  ),
                  content: Text(
                    note.content,
                    style: TextStyle(fontSize: 18, color: theme.textPrimary),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cerrar')),
                  ],
                ),
              );
            },
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: note.isRead ? theme.surface : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: note.isRead ? theme.border : const Color(0xFFFCA5A5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowBase
                        .withValues(alpha: theme.isDarkMode ? 0.35 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            note.isRead ? FontWeight.w500 : FontWeight.w800,
                        color: note.isRead
                            ? theme.textPrimary
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                  Text(
                    'Hace momento',
                    style: TextStyle(fontSize: 10, color: theme.textMuted),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    return NumberFormat('#,###', 'es_AR').format(value).replaceAll(',', '.');
  }
}

class _ExpenseActivityPhrase {
  final String actionVerb;
  final String itemLabel;

  const _ExpenseActivityPhrase({
    required this.actionVerb,
    required this.itemLabel,
  });

  _ExpenseActivityPhrase copyWith({
    String? actionVerb,
    String? itemLabel,
  }) {
    return _ExpenseActivityPhrase(
      actionVerb: actionVerb ?? this.actionVerb,
      itemLabel: itemLabel ?? this.itemLabel,
    );
  }
}
