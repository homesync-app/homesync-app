import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/offline_indicator.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/complete_task_sheet.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:homesync_client/shared/widgets/avatar_picker_sheet.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  final Set<String> _completedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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

    return householdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $e')),
      ),
      data: (householdId) {
        if (householdId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('No pertenecés a un hogar aún.')),
          );
        }
        return Stack(
          children: [
            _buildMainContent(householdId),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primary,
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

  Widget _buildMainContent(String householdId) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => _refreshHome(),
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildFinancialSummary(householdId),
                    const SizedBox(height: 32),
                    _buildTasksSection(),
                    const SizedBox(height: 32),
                    // _buildLoveNotesSection(),
                    const SizedBox(height: 32),
                    _buildActivitySection(),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
          onPressed: () => _showQuickActionMenu(householdId),
          backgroundColor: AppColors.primary,
          elevation: 12,
          label: const Text(
            'Nueva Acción',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: -0.2,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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

  Widget _buildHeader() {
    final profileAsync = ref.watch(userProfileProvider);
    final dateStr = DateFormat('EEEE, d MMM', 'es').format(DateTime.now());
    final capitalizedDate = dateStr.isEmpty ? '' : dateStr[0].toUpperCase() + dateStr.substring(1);

    final displayName = profileAsync.whenOrNull(
          data: (p) => (p?['full_name'] as String?)?.split(' ').first ?? 'Usuario',
        ) ?? 'Usuario';

    final avatarUrl = profileAsync.whenOrNull(data: (p) => p?['avatar_url'] as String?);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $displayName 👋',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ).animateEntrance(),
            const SizedBox(height: 4),
            Text(
              capitalizedDate,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ).animateEntrance(delay: 50),
          ],
        ),
        _buildCircularAvatar(displayName, avatarUrl).animateScaleIn(delay: 150),
      ],
    );
  }

  Widget _buildCircularAvatar(String displayName, String? avatarUrl) {
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final partner = membersAsync.whenOrNull(
      data: (members) =>
          members.where((m) => m.userId != currentUserId).firstOrNull,
    );
    final isPartner = partner != null && avatarUrl == partner.avatarUrl;

    return AnimatedPress(
      onTap: () => AvatarPickerSheet.show(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomUserAvatar(
            name: displayName,
            avatarUrl: avatarUrl,
            radius: 28,
            showBorder: true,
          ),
/*          if (isPartner &&
              ref.watch(incomingLoveNotesProvider).isNotEmpty &&
              ref.watch(premiumProvider))
            Positioned(
              top: -12,
              right: -12,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mail_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2.seconds)
                    .shake(hz: 2, curve: Curves.easeInOut),
              ),
            ),*/
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    final coins = balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;
    final xp = balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0;

    double myExpenseBalance = 0;
    expenseBalancesAsync.whenData((balances) {
      final myBalanceModel = balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (myBalanceModel != null) {
        myExpenseBalance = myBalanceModel.balance;
      }
    });

    final partner = membersAsync.whenOrNull(
      data: (members) => members.where((m) => m.userId != currentUserId).firstOrNull,
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

  Widget _buildTasksSection() {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tareas de hoy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(taskViewModeProvider.notifier).setCalendar();
                ref.read(bottomNavIndexProvider.notifier).setIndex(1);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver Semana',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(),
          error: (e, _) => Text('Error: $e'),
          data: (tasks) {
            final visibleTasks = tasks.where((t) => !t.isCompleted && !_completedTaskIds.contains(t.id)).toList();
            if (visibleTasks.isEmpty) return _buildEmptyState('¡Todo listo por hoy!');
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildTaskCard(visibleTasks[index]).animateStaggered(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final categoryColor = AppColors.getCategoryColor(task.category);
    final categoryEmoji = AppColors.categoryIcons[task.category?.toLowerCase()] ?? '🏠';

    return AnimatedPress(
      onTap: () => _completeTask(task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
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
                child: Text(categoryEmoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppColors.categoryNames[task.category?.toLowerCase()] ?? task.category ?? 'General',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '⭐ ${task.xpReward} XP',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
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
      if (result == null && mounted) {
        setState(() => _completedTaskIds.remove(task.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al completar la tarea. Intenta de nuevo.'))
        );
      } else {
        // Success
        _confettiController.play();
        HapticFeedback.heavyImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⭐ ¡Ganaste ${task.xpReward} XP y ${task.coinReward} coins!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildActivitySection() {
    final activityAsync = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad reciente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        activityAsync.when(
          loading: () => _buildActivityShimmer(),
          error: (e, _) => Text('Error al cargar actividad: $e'),
          data: (activities) {
            if (activities.isEmpty) return _buildEmptyState('No hay actividad aún');
            return _buildActivityCards(activities);
          },
        ),
      ],
    );
  }

  Widget _buildActivityShimmer() {
    return Column(
      children: List.generate(3, (_) => ShimmerLoading(
        child: Container(
          height: 88,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      )),
    );
  }

  Widget _buildActivityCards(List<Map<String, dynamic>> activities) {
    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        final id = activity['id'] ?? index.toString();
        return _buildActivityCard(
          activity, 
          isFirst: index == 0,
          isLast: index == activities.length - 1,
          key: ValueKey(id),
        ).animateStaggered(index);
      }),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, {bool isFirst = false, bool isLast = false, Key? key}) {
    final type = activity['type'] as String;
    final data = activity['data'] as Map<String, dynamic>;
    final time = DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();
    final now = DateTime.now();
    final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
    final timeStr = isToday ? DateFormat('HH:mm').format(time) : DateFormat('d MMM', 'es').format(time);

    Color accentColor;
    String actionVerb;
    String itemLabel;
    String? amountStr;
    String? categoryEmoji;

    if (type == 'task') {
      accentColor = AppColors.sage;
      actionVerb = 'completó';
      itemLabel = data['task_title'] ?? data['title'] ?? 'Tarea';
      final category = (data['category'] as String?)?.toLowerCase();
      categoryEmoji = AppColors.categoryIcons[category] ?? '✅';
    } else if (type == 'expense') {
      final isIncome = data['type'] == 'income' || data['type'] == 'ingreso';
      final isGift = data['split_type'] == 'gift';
      final rawCategory = (data['category'] as String?)?.toLowerCase();
      
      itemLabel = AppColors.categoryNames[rawCategory] ?? data['category'] ?? 'Gasto';
      categoryEmoji = AppColors.categoryIcons[rawCategory] ?? '💰';

      if (isGift) {
        accentColor = Colors.pinkAccent;
        actionVerb = 'dio un regalo';
        itemLabel = 'Regalo';
        categoryEmoji = '🎁';
      } else if (data['type'] == 'settlement') {
        accentColor = AppColors.success;
        actionVerb = 'saldó la deuda';
        itemLabel = 'Cuentas claras';
        categoryEmoji = '🤝';
      } else if (isIncome) {
        accentColor = AppColors.sage;
        actionVerb = 'recibió';
      } else {
        accentColor = AppColors.primary;
        // Natural language logic
        final cat = rawCategory ?? '';
        if (cat.contains('supermarket') || cat.contains('mercado') || cat.contains('ropa')) {
          actionVerb = 'compró en';
        } else if (cat.contains('comida') || cat.contains('ocio') || cat.contains('entertainment')) {
          actionVerb = 'disfrutó de';
        } else if (cat.contains('alquiler') || cat.contains('finanzas') || cat.contains('rent') || cat.contains('factura')) {
          actionVerb = 'pagó';
        } else {
          actionVerb = 'gastó en';
        }
      }

      final amount = data['amount'];
      if (amount != null) {
        final formatted = NumberFormat.decimalPattern('es_AR').format(
          (amount is num ? amount : double.tryParse(amount.toString()) ?? 0).round(),
        );
        amountStr = '\$$formatted';
      }
    } else {
      accentColor = AppColors.textSecondary;
      actionVerb = 'registró';
      itemLabel = data['title'] ?? 'Evento';
      categoryEmoji = '📌';
    }

    final userName = data['user_name'] as String? ?? 'Usuario';
    final avatarUrl = data['avatar_url'] as String?;
    final description = data['description'] as String?;
    final hasDetail = description != null && description.trim().isNotEmpty;
    final isClickable = type == 'expense' || hasDetail;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Container(
            width: 20,
            constraints: const BoxConstraints(minHeight: 60),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                if (!isFirst)
                  Positioned(
                    top: 0,
                    height: 18,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedPress(
                onTap: isClickable ? () => _handleActivityTap(activity, itemLabel, description, accentColor) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomUserAvatar(
                        name: userName,
                        avatarUrl: avatarUrl,
                        radius: 16,
                        showBorder: false,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Row: User + Action + Category Chip
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                const SizedBox(width: 4),
                                if (actionVerb.isNotEmpty)
                                  Text(
                                    actionVerb,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${itemLabel.length > 20 ? "" : (categoryEmoji != null ? "$categoryEmoji " : "")}$itemLabel',
                                      style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Bottom Row: Time, XP, Coins (Left/Center) and Amount (Right)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted.withValues(alpha: 0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  timeStr,
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                if (type == 'task') ...[
                                  const SizedBox(width: 12),
                                  if (data['xp_per_user'] != null || data['xp_reward'] != null) ...[
                                    const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${_formatNumber(data['xp_per_user'] ?? data['xp_reward'])} XP',
                                      style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  if (data['coins_per_user'] != null || data['coin_reward'] != null) ...[
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentGold,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('\$', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatNumber(data['coins_per_user'] ?? data['coin_reward']),
                                      style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                  ],
                                ],
                                const Spacer(),
                                if (amountStr != null)
                                  Text(
                                    amountStr,
                                    style: TextStyle(
                                      color: accentColor, 
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 16, 
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleActivityTap(Map<String, dynamic> activity, String itemLabel, String? description, Color accentColor) {
    final type = activity['type'] as String;
    final data = activity['data'] as Map<String, dynamic>;

    if (type == 'expense') {
      final expenseId = data['expense_id'] ?? data['id'];
      final expenses = ref.read(expenseControllerProvider).valueOrNull;
      if (expenses != null && expenseId != null) {
        final expense = expenses.where((e) => e.id == expenseId).firstOrNull;
        if (expense != null) {
          ExpenseDetailSheet.show(context, expense);
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este gasto ya no está disponible o fue eliminado')),
      );
      return;
    }

    if (description == null || description.isEmpty) return;

    final isShoppingList = description.toLowerCase().contains('lista') || description.contains('\n') || description.contains('- ');
    final items = description
        .split(RegExp(r'\n'))
        .map((e) => e.trim().replaceAll(RegExp(r'^[\-\*•]\s*'), ''))
        .where((e) => e.isNotEmpty && !e.toLowerCase().contains('lista'))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(isShoppingList ? Icons.shopping_cart_rounded : Icons.info_outline_rounded, color: accentColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isShoppingList ? 'Lista de Compras' : 'Detalles', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(itemLabel, style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isShoppingList 
                  ? Column(
                      children: items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.sage),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    )
                  : Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksShimmer() {
    return Column(
      children: List.generate(2, (_) => ShimmerLoading(
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        ),
      )),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Text('🐾', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¡El amor es el mejor plan hoy! ✨',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionMenu(String householdId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '¿Qué deseás hacer?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.add_shopping_cart_rounded,
                      label: 'Cargar Gasto',
                      color: AppColors.primary,
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
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CompleteTaskSheet(onTasksCompleted: () {}),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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
    // Only the debtor (the one who owes) sees the settle button in BalanceCard,
    // so we simplify the message to reflect their confirmation of payment.
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
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
                '¿Saldar deuda con $partnerName?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Confirmas que ya realizaste la transferencia de \$${amount.toStringAsFixed(2)} a $partnerName? Esto equilibrará el balance de la pareja a 0 nuevamente.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
                      child: const Text(
                        'Aún no',
                        style: TextStyle(
                          color: AppColors.textMuted,
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
                               fromUserId: isOwedByMe ? (currentUserId ?? '') : partnerId,
                               toUserId: isOwedByMe ? partnerId : (currentUserId ?? ''),
                               amount: amount,
                             );
  
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text('¡Balance equilibrado! Todo listo. ✨'),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Si, ¡saldar!',
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

  Widget _buildLoveNotesSection() {
    final isPremium = ref.watch(premiumProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas de Amor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (isPremium) _buildNotesList(),
        AnimatedPress(
          onTap: () {
            if (!isPremium) {
              PremiumPaywall.show(context);
            } else {
              _showLoveNoteDialog();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [const Color(0xFFFEE2E2), Colors.white]
                    : [Colors.grey[100]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isPremium
                    ? const Color(0xFFFCA5A5).withValues(alpha: 0.5)
                    : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPremium ? const Color(0xFFF87171) : Colors.black)
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
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPremium ? Icons.favorite_rounded : Icons.lock_rounded,
                    color: isPremium ? const Color(0xFFEF4444) : Colors.grey[400],
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
                              : AppColors.textPrimary,
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
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLoveNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 12),
            Text('Nueva Nota de Amor', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
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
            child: const Text('Cancelar'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  title: const Text('De mi pareja 💖', style: TextStyle(fontWeight: FontWeight.w900)),
                  content: Text(note.content, style: const TextStyle(fontSize: 18)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
                  ],
                ),
              );
            },
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: note.isRead ? Colors.white : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: note.isRead ? AppColors.divider : const Color(0xFFFCA5A5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                        fontWeight: note.isRead ? FontWeight.w500 : FontWeight.w800,
                        color: note.isRead ? AppColors.textPrimary : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                  Text(
                    'Hace momento',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
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
