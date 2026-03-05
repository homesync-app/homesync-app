import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';

import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/widgets/offline_indicator.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/complete_task_sheet.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/shared/widgets/avatar_picker_sheet.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  RealtimeChannel? _tasksChannel;
  RealtimeChannel? _expensesChannel;
  RealtimeChannel? _splitsChannel;
  RealtimeChannel? _membersChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupRealtime());
  }

  @override
  void dispose() {
    _tasksChannel?.unsubscribe();
    _expensesChannel?.unsubscribe();
    _splitsChannel?.unsubscribe();
    _membersChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _setupRealtime() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null || !mounted) return;

    final client = Supabase.instance.client;

    _tasksChannel = client
        .channel('home_tasks:$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (_) => _refreshAll(),
        )
        .subscribe();

    _expensesChannel = client
        .channel('home_expenses:$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'expenses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (_) => _refreshFinancials(),
        )
        .subscribe();

    _splitsChannel = client
        .channel('home_splits:$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'expense_splits',
          callback: (_) => _refreshFinancials(),
        )
        .subscribe();

    _membersChannel = client
        .channel('home_members:$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'household_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (_) {
            ref.invalidate(householdMembersProvider);
            _refreshFinancials();
          },
        )
        .subscribe();
  }

  void _refreshAll() {
    if (!mounted) return;
    ref.invalidate(tasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(userBalanceProvider);
  }

  void _refreshFinancials() {
    if (!mounted) return;
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(recentActivityProvider);
  }

  void _refreshHome() {
    ref.invalidate(tasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(expenseBalancesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final householdAsync = ref.watch(householdIdProvider);

    return householdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $e')),
      ),
      data: (householdId) {
        if (householdId == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text('No pertenecés a un hogar aún.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          );
        }
        return _buildMainContent(householdId);
      },
    );
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildFinancialSummary(householdId),
                    const SizedBox(height: 32),
                    _buildTasksSection(),
                    const SizedBox(height: 32),
                    _buildActivitySection(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showQuickActionMenu(householdId),
        backgroundColor: AppColors.primary,
        elevation: 12,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    final profileAsync = ref.watch(userProfileProvider);
    final dateFormat = DateFormat('EEEE, d MMM', 'es');
    final dateStr = dateFormat.format(DateTime.now());
    final capitalized =
        dateStr.substring(0, 1).toUpperCase() + dateStr.substring(1);

    final displayName = profileAsync.whenOrNull(
          data: (p) => (p?['full_name'] as String?)?.split(' ').first ?? 'User',
        ) ??
        'User';

    final avatarUrl =
        profileAsync.whenOrNull(data: (p) => p?['avatar_url'] as String?);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side: Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(-20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '¡Hola, $displayName! 👋',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                capitalized,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Right Side: Avatar
        _buildCircularAvatar(displayName, avatarUrl),
      ],
    );
  }

  Widget _buildCircularAvatar(String displayName, String? avatarUrl) {
    final bool isPremium = avatarUrl?.startsWith('premium://') == true;
    return AnimatedPress(
      onTap: () => AvatarPickerSheet.show(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isPremium)
            CustomUserAvatar(
              name: displayName,
              avatarUrl: avatarUrl,
              radius: 36,
              isAnimated: false,
              isPriority: false,
            )
          else
            CustomUserAvatar(
              name: displayName,
              avatarUrl: avatarUrl,
              radius: 28,
              showBorder: true,
              isAnimated: false,
            ),
          if (!isPremium)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final expensesAsync = ref.watch(expenseBalancesProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    final coins =
        balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;
    final xp = balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0;

    double myBalance = 0;
    expensesAsync.whenOrNull(
      data: (balances) {
        try {
          final myBal = balances.firstWhere(
              (b) => b['user_id'] == currentUserId,
              orElse: () => null);
          if (myBal != null) {
            myBalance = (myBal['balance'] ?? 0).toDouble();
          }
        } catch (_) {}
      },
    );

    // Find partner info for settlement
    final partner = membersAsync.whenOrNull(
      data: (members) =>
          members.where((m) => m.userId != currentUserId).firstOrNull,
    );

    return BalanceCard(
      coins: coins,
      xp: xp,
      userBalance: myBalance,
      partnerName: partner?.displayName,
      onSettle: partner != null && myBalance.abs() > 1.0
          ? () => _showSettlementDialog(
                householdId: householdId,
                partnerId: partner.userId,
                partnerName: partner.displayName ?? 'tu pareja',
                amount: myBalance.abs(),
                isOwedByMe: myBalance < 0,
                alias: partner.mercadopagoAlias,
              )
          : null,
      isDark: false,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Equilibrar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Registrar equilibración por \$${NumberFormat.decimalPattern('es_AR').format(amount.round())}?',
              style: const TextStyle(fontSize: 16),
            ),
            if (isOwedByMe && alias != null) ...[
              const SizedBox(height: 20),
              const Text(
                '¿Querés transferir ahora por Mercado Pago?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          if (isOwedByMe && alias != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _handleSettle(alias, amount);
                // Optionally show another dialog later to confirm registration
              },
              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
              label: const Text('Transferir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _registerSettlementInDB(
                  householdId, partnerId, amount, isOwedByMe);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerSettlementInDB(
    String householdId,
    String partnerId,
    double amount,
    bool isOwedByMe,
  ) async {
    try {
      // If I owe, I am the one settling to partner
      // If partner owes, I am recording that partner settled to me
      final toUserId =
          isOwedByMe ? partnerId : ref.read(currentUserIdProvider)!;
      // Wait, the RPC settle_debt(p_user_id, p_household_id, p_to_user_id, p_amount)
      // p_user_id is the one PAYING.
      final payerId = isOwedByMe ? ref.read(currentUserIdProvider)! : partnerId;
      final receiverId =
          isOwedByMe ? partnerId : ref.read(currentUserIdProvider)!;

      final repo = ref.read(expenseRepositoryProvider);
      // We need to ensure we have a version of settleDebt that takes the payerId or use the RPC
      // The repository currently uses the authenticated user as the payer.
      // If I am recording that partner paid me, I might need a different call or the repo needs to allow specifying payer.

      // For now, let's use the repo settleDebt which uses current user as payer (Settling my own debt)
      if (isOwedByMe) {
        await repo.settleDebt(
          householdId: householdId,
          toUserId: partnerId,
          amount: amount,
        );
      } else {
        // Recording partner's payment to me.
        // We can simulate this by saving a special expense paid by partner where I am the beneficiary 100%
        await repo.saveExpense(
          householdId: householdId,
          title: 'Liquidación recibida',
          amount: amount,
          category: 'other',
          paidBy: partnerId,
          paidAt: DateTime.now(),
          splitType: SplitType
              .gift, // In our logic, gift usually means payer pays for others
          type: 'expense',
          description: 'Saldado por pareja',
          splits: [
            {'user_id': ref.read(currentUserIdProvider)!, 'amount': amount}
          ],
        );
      }

      // Refresh data
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(filteredExpensesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda saldada correctamente 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al saldar: $e')),
        );
      }
    }
  }

  Future<void> _handleSettle(String alias, double amount) async {
    final url = 'https://link.mercadopago.com.ar/transfer/alias/$alias';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir Mercado Pago')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir link: $e')),
        );
      }
    }
  }

  Widget _buildTasksSection() {
    final todayTasksAsync = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tareas de hoy',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(1);
                ref.read(taskViewModeProvider.notifier).setCalendar();
              },
              child: const Text(
                'Ver semana',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        todayTasksAsync.when(
          loading: () => Column(
            children: List.generate(
                2,
                (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerLoading(
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    )),
          ),
          error: (e, _) =>
              Text('Error: $e', style: const TextStyle(color: AppColors.error)),
          data: (tasks) {
            if (tasks.isEmpty) return _buildEmptyTasksState();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTaskCard(tasks[index]),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyTasksState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sage.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Día libre!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No hay tareas pendientes. Disfruten el tiempo juntos.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final category = task.category ?? 'general';
    final title = task.title;
    final xp = task.xpReward;
    final isCompleted = task.isVerified;

    // Resolve dynamic category data
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        try {
          return list.firstWhere((c) => c.id == task.category);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    final categoryColor = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : AppColors.getCategoryColor(category);
    final categoryIcon =
        categoryData?.icon ?? AppColors.categoryIcons[category] ?? '📋';

    return AnimatedPress(
      onTap: () {
        if (!isCompleted) {
          _handleCompleteFromCard(task);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isCompleted
                ? AppColors.accentGreen.withValues(alpha: 0.1)
                : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(categoryIcon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryChip(category),
                      const SizedBox(width: 8),
                      _buildRewardChip('+$xp XP', const Color(0xFFFDA4AF)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.accentGreen : Colors.white,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.accentGreen
                      : const Color(0xFFE2E8F0),
                  width: 2.5,
                ),
              ),
              child: isCompleted
                  ? const Center(
                      child: Icon(Icons.check_rounded,
                          color: Colors.white, size: 20),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final cat = category.toLowerCase();
    final color = AppColors.getCategoryColor(cat);
    final name = AppColors.categoryNames[cat] ?? category;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRewardChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _handleCompleteFromCard(TaskModel task) async {
    final xpReward = task.xpReward;
    final coinReward = task.coinReward;

    try {
      final completeTaskLogic = ref.read(completeTaskUseCaseProvider);
      final eitherResult = await completeTaskLogic(task);

      if (!mounted) return;

      eitherResult.fold(
        (failure) =>
            _showSnack('Error: ${failure.message}', AppColors.accentRed),
        (data) {
          final xp = data['xp_earned'] ?? xpReward;
          final coins = data['coins_earned'] ?? coinReward;
          HapticFeedback.heavyImpact();
          _showSnack(
              '¡Ganaste $xp XP y $coins coins! 🎉', AppColors.accentTeal);
          _refreshAll();
        },
      );
    } catch (e) {
      _showSnack('Error: $e', AppColors.accentRed);
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
              'Historial de Actividad',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(4);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver historial',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        activityAsync.when(
          loading: () => Column(
            children: List.generate(
                3,
                (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerLoading(
                        child: Container(
                          height: 70,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    )),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Text('😔', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('No pudimos cargar el historial',
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          data: (activities) {
            if (activities.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded,
                          size: 48, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      const Text(
                        'Todavía no hay actividad.\n¡Empezá haciendo alguna tarea!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildActivityTimeline(activities);
          },
        ),
      ],
    );
  }

  Widget _buildActivityTimeline(List<Map<String, dynamic>> activities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayActs = activities
        .where((a) =>
            (a['time'] as DateTime).isAfter(today) ||
            (a['time'] as DateTime).isAtSameMomentAs(today))
        .toList();
    final yesterdayActs = activities.where((a) {
      final t = a['time'] as DateTime;
      return t.isAfter(yesterday) && t.isBefore(today);
    }).toList();
    final earlierActs = activities
        .where((a) => (a['time'] as DateTime).isBefore(yesterday))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayActs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12, top: 4),
            child: Text(
              'HOY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...todayActs
              .asMap()
              .entries
              .map((entry) => TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (entry.key * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildActivityItem(entry.value),
                  )),
        ],
        if (yesterdayActs.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12, top: 4),
            child: Text(
              'AYER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...yesterdayActs
              .asMap()
              .entries
              .map((entry) => TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (entry.key * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildActivityItem(entry.value),
                  )),
        ],
        if (earlierActs.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12, top: 4),
            child: Text(
              'ANTERIOR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...earlierActs
              .asMap()
              .entries
              .map((entry) => TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (entry.key * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildActivityItem(entry.value),
                  )),
        ],
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final data = activity['data'] as Map<String, dynamic>;
    final time = activity['time'] as DateTime;
    final timeStr = DateFormat('HH:mm').format(time);

    final userData = data['user'] as Map<String, dynamic>?;
    final String userName =
        (userData?['full_name'] as String? ?? 'Alguien').split(' ').first;
    final String? avatarUrl = userData?['avatar_url'] as String?;
    final String category = data['category'] as String? ?? 'general';

    final Color activityColor =
        type == 'TaskModel' ? AppColors.primary : AppColors.sage;
    final String title = data['title'] as String? ??
        data['description'] as String? ??
        (type == 'TaskModel' ? 'Tarea' : 'Gasto');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline strip
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activityColor,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: activityColor.withValues(alpha: 0.3),
                          blurRadius: 4),
                    ]),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedPress(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (type == 'TaskModel') {
                    TaskDetailSheet.show(context, data, onChanged: _refreshAll);
                  } else {
                    // For expenses, we could open a detail view if available
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CustomUserAvatar(
                              name: userName, avatarUrl: avatarUrl, radius: 18),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                AppColors.getCategoryMaterialIcon(category),
                                size: 10,
                                color: AppColors.getCategoryColor(category),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF1E293B)),
                                children: [
                                  TextSpan(
                                      text: userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  TextSpan(
                                    text: type == 'TaskModel'
                                        ? ' completó '
                                        : ' compró ',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B)),
                                  ),
                                  TextSpan(
                                      text: title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                    width: 3,
                                    height: 3,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFCBD5E1),
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                if (type == 'TaskModel') ...[
                                  const Icon(Icons.stars_rounded,
                                      size: 12, color: AppColors.accentGold),
                                  const SizedBox(width: 4),
                                  Text('${data['xp_reward'] ?? 0} XP',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.w700)),
                                ] else ...[
                                  Text('\$${data['amount'] ?? 0}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.sage,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: Color(0xFFCBD5E1)),
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

  void _showQuickActionMenu(String householdId) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Qué querés hacer?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionItem(
                  icon: Icons.task_alt_rounded,
                  label: 'Completar Tarea',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        builder: (_, controller) => CompleteTaskSheet(
                          onTasksCompleted: _refreshAll,
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Cargar un Gasto',
                  color: AppColors.accentPeach,
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ExpenseFormSheet(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin:
            const EdgeInsets.fromLTRB(20, 0, 20, 100), // Above FAB/Bottom bar
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
