import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:intl/intl.dart';

import '../widgets/expense_detail_sheet.dart';
import '../widgets/expense_form_sheet.dart';
import '../widgets/planned_expense_payment_sheet.dart';
import '../widgets/recurring_expense_form_sheet.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: _buildTabBar(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMovimientosTab(),
                _buildRecurrentesTab(),
                _buildSavingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildTabBar() {
    return AppSegmentedTabs(
      controller: _tabController,
      labels: const ['Movimientos', 'Recurrentes', 'Metas'],
      padding: const EdgeInsets.all(6),
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final theme = context.theme;
        String label = 'Movimiento';
        VoidCallback onPressed = () => _showExpenseSheet();

        if (_tabController.index == 1) {
          final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
          label = 'Nueva Suscripción';
          onPressed = isPremium
              ? () => _showTemplateForm(context)
              : () => PremiumPaywall.show(context);
        } else if (_tabController.index == 2) {
          label = 'Nueva Meta';
          onPressed = () => _showGoalSheet();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowBase.withValues(alpha: 0.032),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.022),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              heroTag: 'expenses_fab',
              onPressed: onPressed,
              backgroundColor: theme.elevatedSurface.withValues(alpha: 0.94),
              foregroundColor: AppColors.primary,
              elevation: 0,
              highlightElevation: 0,
              splashColor: theme.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.075),
                  width: 1,
                ),
              ),
              extendedPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              icon: const Icon(
                Icons.add_rounded,
                size: 19,
                color: AppColors.primary,
              ),
              label: Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  letterSpacing: -0.15,
                ),
              ),
            ),
          ).animateEntrance(),
        );
      },
    );
  }

  // --- Summary Tab ---

  Widget _buildMovimientosTab() {
    final theme = context.theme;
    final summaryAsync = ref.watch(personalFinanceSummaryProvider);
    final feedAsync = ref.watch(combinedFeedControllerProvider);
    final projectionAsync = ref.watch(monthlyProjectionProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(expenseBalancesProvider);
        ref.invalidate(combinedFeedControllerProvider);
        ref.invalidate(monthlyPendingPlannedExpensesProvider);
        ref.invalidate(monthlyProjectionProvider);
        ref.invalidate(expenseControllerProvider);
      },
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),),
        slivers: [
          // 1. SUMMARY WIDGET WITH PROJECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: summaryAsync.when(
                loading: () => const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                            color: AppColors.primary,),),),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (summary) {
                  final income = (summary['income'] as num?)?.toDouble() ?? 0.0;
                  final expense =
                      (summary['expense'] as num?)?.toDouble() ?? 0.0;
                  final balance = income - expense;

                  return projectionAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) =>
                        _buildUnifiedSummaryCard(balance, income, expense, 0),
                    data: (proj) => _buildUnifiedSummaryCard(
                        balance, income, expense, proj.pending,),
                  );
                },
              ),
            ),
          ),

          // 2. FEED & FUTURE EXPENSES
          feedAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
                hasScrollBody: false, child: Center(child: Text('Error: $e')),),
            data: (feedItems) {
              final filteredItems =
                  feedItems.where(_shouldShowFeedItem).toList();
              final sortedItems = List<FeedItemModel>.from(filteredItems)
                ..sort((a, b) => b.date.compareTo(a.date));

              return SliverMainAxisGroup(
                slivers: [
                  if (sortedItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    theme.textSecondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.history_rounded,
                                  size: 12, color: theme.textSecondary,),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'ACTIVIDAD RECIENTE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color:
                                    theme.textSecondary.withValues(alpha: 0.7),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (sortedItems.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = sortedItems[index];
                          final isFirstOfDate = index == 0 ||
                              _formatFeedDate(item.date) !=
                                  _formatFeedDate(sortedItems[index - 1].date);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isFirstOfDate)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 24, 24, 12),
                                  child: Text(
                                    _formatFeedDate(item.date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: theme.textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 6,),
                                child: _buildFeedItemCard(item)
                                    .animateStaggered(index),
                              ),
                            ],
                          );
                        },
                        childCount: sortedItems.length,
                      ),
                    ),
                  if (sortedItems.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: _buildEmptyState('No hay movimientos recientes'),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatFeedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'HOY';
    } else if (checkDate == yesterday) {
      return 'AYER';
    } else {
      return DateFormat('d MMMM y', 'es').format(date).toUpperCase();
    }
  }

  String _compactMovementTitle(String title, {String? category}) {
    final normalized = title.trim();
    final lower = normalized.toLowerCase();
    final categoryId = category?.toLowerCase();

    if (categoryId == 'supermarket' &&
        (lower.contains('supermerc') || lower.contains('compras del'))) {
      return 'Supermercado';
    }

    if (lower == 'compras del supermercado' ||
        lower == 'compras de supermercado' ||
        lower == 'compra del supermercado') {
      return 'Supermercado';
    }

    if (categoryId == 'mercadolibre' &&
        (lower.contains('mercado libre') || lower.contains('compras online'))) {
      return 'Compras online';
    }

    return normalized;
  }

  List<FeedItemModel> _effectiveFeedForBreakdowns() {
    final feed = ref.read(combinedFeedControllerProvider).valueOrNull ??
        const <FeedItemModel>[];
    if (feed.isNotEmpty) return feed;

    final expenses = ref.read(expenseControllerProvider).valueOrNull ??
        const <ExpenseModel>[];
    return expenses
        .map(
          (e) => FeedItemModel(
            recordType: 'expense',
            transactionType: e.type,
            id: e.id,
            title: e.title,
            amount: e.amount,
            category: e.category,
            splitType: e.splitType,
            payerId: e.paidBy,
            payerEmail: e.payerEmail,
            payerFullName: e.payerFullName,
            payerAvatarUrl: e.payerAvatarUrl,
            date: e.paidAt,
            status: 'paid',
          ),
        )
        .toList();
  }

  List<FeedItemModel> _effectiveMonthlyPendingForBreakdowns() {
    final monthlyPending =
        ref.read(monthlyPendingPlannedExpensesProvider).valueOrNull;
    if (monthlyPending != null) return monthlyPending;

    final now = DateTime.now();
    return _effectiveFeedForBreakdowns()
        .where((item) =>
            item.isPlanned &&
            item.status == 'pending' &&
            item.date.month == now.month &&
            item.date.year == now.year,)
        .toList();
  }

  ExpenseModel _expenseFromFeedItem(FeedItemModel item) {
    final expenses = ref.read(expenseControllerProvider).valueOrNull;
    final matches = expenses?.where((e) => e.id == item.id).toList() ??
        const <ExpenseModel>[];
    if (matches.isNotEmpty) return matches.first;

    return ExpenseModel(
      id: item.id,
      title: item.title,
      amount: item.amount,
      category: item.category,
      householdId: '',
      paidBy: item.payerId,
      paidAt: item.date,
      createdAt: item.date,
      payerFullName: item.payerFullName,
      payerEmail: item.payerEmail,
      splitType: item.splitType,
      isShared: item.splitType != SplitType.personal.name,
      type: item.transactionType,
    );
  }

  int _householdMemberCount() {
    final members = ref.read(householdMembersProvider).valueOrNull;
    if (members != null && members.isNotEmpty) return members.length;
    return 2;
  }

  double _plannedShareAmount(FeedItemModel item, String? userId) {
    if (userId == null) return 0.0;

    final splitType = (item.splitType ?? 'equal').toLowerCase();
    if (splitType == SplitType.personal.name || splitType == 'gift') {
      return item.payerId == userId ? item.amount : 0.0;
    }

    return item.amount / _householdMemberCount();
  }

  String _templateSplitLabel(String splitType) {
    switch (splitType.toLowerCase()) {
      case 'equal':
        return 'Compartido';
      case 'fixed':
        return 'Monto fijo';
      case 'gift':
        return 'Regalo';
      case 'personal':
        return 'Personal';
      default:
        return 'Compartido';
    }
  }

  Widget _buildProjectionStat(String label, num amount, Color color,
      {bool isBold = false, VoidCallback? onTap,}) {
    final theme = context.theme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$ ${_formatCurrency(amount)}',
            style: TextStyle(
              color: isBold ? theme.textPrimary : color,
              fontSize: isBold ? 20 : 17,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              letterSpacing: isBold ? -0.7 : -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // --- Recurrentes Tab ---

  Widget _buildRecurrentesTab() {
    final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
    if (!isPremium) return _buildPremiumLockedRecurrentes();

    final templatesAsync = ref.watch(expenseTemplateControllerProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (templates) {
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(expenseTemplateControllerProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (templates.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.update_rounded,
                                  size: 64, color: AppColors.primary,)
                              .animatePulse(),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sin gastos recurrentes',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Crea plantillas para tus suscripciones o alquileres y nosotros nos encargamos del resto.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final template = templates[index];
                        final color =
                            CategoryMapping.getSmartExpenseDisplayColor(
                          template.category,
                          title: template.title,
                          description: null,
                        );
                        final icon = CategoryMapping.getSmartExpenseDisplayIcon(
                          template.category,
                          title: template.title,
                          description: null,
                        );
                        final theme = context.theme;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () =>
                                _showTemplateForm(context, template: template),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColors.divider
                                        .withValues(alpha: 0.3),),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 24,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          template.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: AppColors.textPrimary,),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Día ${template.dayOfMonth} de cada mes',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$ ${_formatCurrency(template.defaultAmount)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: AppColors.textPrimary,),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4,),
                                        decoration: BoxDecoration(
                                          color: AppColors.sage
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _templateSplitLabel(
                                              template.splitType,),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.sage,),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animateStaggered(index);
                      },
                      childCount: templates.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnifiedSummaryCard(
      num balance, num income, num expense, num projectedPending,) {
    final projectedBalance = balance - projectedPending;
    final theme = context.theme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.border.withValues(alpha: 0.82)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TU BALANCE ACTUAL',
                  style: TextStyle(
                    color: theme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$ ${_formatCurrency(balance)}',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildPremiumStatTile(
                        'Ingresos',
                        income,
                        AppColors.success,
                        Icons.trending_up_rounded,
                        onTap: () => _showIncomeBreakdownSheet(income),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPremiumStatTile(
                        'Gastos',
                        expense,
                        AppColors.primary,
                        Icons.trending_down_rounded,
                        onTap: () => _showExpensesBreakdownSheet(expense),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withValues(alpha: 0.38),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
              border: Border(
                top: BorderSide(
                  color: theme.border.withValues(alpha: 0.55),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildProjectionStat(
                    'Tu parte pendiente',
                    projectedPending,
                    theme.textSecondary,
                    onTap: () => _showPendingBreakdownSheet(projectedPending),
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  color: theme.border.withValues(alpha: 0.62),
                ),
                Expanded(
                  child: _buildProjectionStat(
                    'Cierre estimado',
                    projectedBalance,
                    theme.textPrimary,
                    isBold: true,
                    onTap: () => _showProjectionBreakdownSheet(
                        balance, projectedPending, projectedBalance,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animateEntrance(delay: 100);
  }

  void _showProjectionBreakdownSheet(
      num balance, num pendingTotal, num estimated,) {
    final pendingFeed = _effectiveMonthlyPendingForBreakdowns();
    final userId = ref.read(currentUserIdProvider);
    final theme = context.theme;

    final pendingItems = pendingFeed
        .where((item) => _plannedShareAmount(item, userId) > 0)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Cálculo de proyección',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Así llegamos a tu cierre estimado para fin de mes.',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Equation Section
                  _buildBreakdownRow(
                      'Tu balance actual', balance, AppColors.textPrimary,),
                  const SizedBox(height: 16),
                  _buildBreakdownRow(
                      'Tu parte pendiente', -pendingTotal, AppColors.primary,),
                  const Divider(
                      height: 40, thickness: 1, color: AppColors.divider,),
                  _buildBreakdownRow(
                      'Tu cierre estimado', estimated, AppColors.accentTeal,
                      isFinal: true,),

                  if (pendingItems.isNotEmpty) ...[
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.pending_actions_rounded,
                              size: 12, color: AppColors.primary,),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'DETALLE DE PENDIENTES',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...pendingItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(item.categoryIcon,
                                    style: const TextStyle(fontSize: 16),),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '\$ ${_formatCurrency(_plannedShareAmount(item, userId))}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),),
                        elevation: 0,
                      ),
                      child: const Text('Entendido',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16,),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, num amount, Color color,
      {bool isFinal = false,}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isFinal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isFinal ? 18 : 16,
            fontWeight: isFinal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        Text(
          '${amount > 0 ? "+" : ""}\$ ${_formatCurrency(amount.abs())}',
          style: TextStyle(
            color: amount < 0
                ? AppColors.primary
                : (isFinal ? AppColors.accentTeal : color),
            fontSize: isFinal ? 22 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatTile(
      String label, num amount, Color color, IconData icon,
      {VoidCallback? onTap,}) {
    final theme = context.theme;

    return AnimatedPress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\$ ${_formatCurrency(amount)}',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomeBreakdownSheet(num total) {
    final feed = _effectiveFeedForBreakdowns();
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final items = feed
        .where((item) =>
            item.isRealExpense &&
            item.date.month == now.month &&
            item.date.year == now.year &&
            ((item.transactionType == 'income' && item.payerId == userId) ||
                (item.transactionType == 'settlement' &&
                    item.payerId != userId)),)
        .map(_expenseFromFeedItem)
        .toList();

    _showGenericBreakdownSheet('Detalle de Ingresos',
        'Tus ingresos registrados este mes.', total, items, AppColors.success,);
  }

  void _showExpensesBreakdownSheet(num total) {
    final feed = _effectiveFeedForBreakdowns();
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final items = feed
        .where((item) =>
            item.isRealExpense &&
            item.date.month == now.month &&
            item.date.year == now.year &&
            ((item.transactionType == 'expense' && item.payerId == userId) ||
                (item.transactionType == 'settlement' &&
                    item.payerId == userId)),)
        .map(_expenseFromFeedItem)
        .toList();

    _showGenericBreakdownSheet('Detalle de Gastos',
        'Tus gastos pagados este mes.', total, items, AppColors.primary,);
  }

  void _showPendingBreakdownSheet(num total) {
    final pendingFeed = _effectiveMonthlyPendingForBreakdowns();
    final userId = ref.read(currentUserIdProvider);

    final items = pendingFeed
        .where((item) => _plannedShareAmount(item, userId) > 0)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBreakdownBaseContainer(
        title: 'Tu Parte Pendiente',
        subtitle:
            'Lo que te corresponde de los gastos planificados de este mes.',
        total: total,
        totalLabel: 'Tu total pendiente',
        accentColor: AppColors.textSecondary,
        content: Column(
          children: items
              .map((item) => _buildMovementDetailRow(
                    title: item.title,
                    amount: _plannedShareAmount(item, userId),
                    date: item.date,
                    icon: CategoryMapping.getSmartExpenseDisplayIcon(
                      item.category,
                      title: item.title,
                      description: null,
                      transactionType: item.transactionType,
                      splitType: item.splitType,
                    ),
                    color: AppColors.primary,
                  ),)
              .toList(),
        ),
      ),
    );
  }

  void _showGenericBreakdownSheet(String title, String subtitle, num total,
      List<ExpenseModel> items, Color accentColor,) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBreakdownBaseContainer(
        title: title,
        subtitle: subtitle,
        total: total,
        totalLabel: 'Total del mes',
        accentColor: accentColor,
        content: Column(
          children: items.isEmpty
              ? [
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('No hay movimientos registrados',
                          style: TextStyle(color: AppColors.textMuted),),),
                ]
              : items
                  .map((e) => _buildMovementDetailRow(
                        title: e.title,
                        amount: e.amount,
                        date: e.paidAt,
                        icon: CategoryMapping.getSmartExpenseDisplayIcon(
                          e.category,
                          title: e.title,
                          description: e.description,
                          transactionType: e.type,
                          splitType: e.splitType,
                        ),
                        color: accentColor,
                      ),)
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildBreakdownBaseContainer({
    required String title,
    required String subtitle,
    required num total,
    required String totalLabel,
    required Color accentColor,
    required Widget content,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$ ${_formatCurrency(total)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.list_alt_rounded,
                          size: 12, color: accentColor,),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'MOVIMIENTOS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                content,
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),),
                      elevation: 0,
                    ),
                    child: const Text('Entendido',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16,),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementDetailRow({
    required String title,
    required num amount,
    required DateTime date,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,),),
                Text(DateFormat('d MMM', 'es').format(date),
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,),),
              ],
            ),
          ),
          Text('\$ ${_formatCurrency(amount)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary,),),
        ],
      ),
    );
  }

  Widget _buildFeedItemCard(FeedItemModel item) {
    if (item.isRealExpense) {
      final expenses = ref.read(expenseControllerProvider).valueOrNull;
      final expense = expenses?.where((e) => e.id == item.id).firstOrNull ??
          ExpenseModel(
            id: item.id,
            title: item.title,
            amount: item.amount,
            category: item.category,
            householdId: '',
            paidBy: item.payerId,
            paidAt: item.date,
            createdAt: item.date,
            payerFullName: item.payerFullName,
            payerEmail: item.payerEmail,
            splitType: item.splitType,
            isShared: item.splitType != SplitType.personal.name,
            type: item.title.toLowerCase().contains('liquidación')
                ? 'settlement'
                : 'expense',
          );
      return _buildRealExpenseCard(expense);
    } else {
      return _buildPlannedExpenseCard(item);
    }
  }

  Widget _buildRealExpenseCard(ExpenseModel expense) {
    return _buildExpenseCard(expense);
  }

  Widget _buildPlannedExpenseCard(FeedItemModel item) {
    final theme = context.theme;
    final categoryColor = CategoryMapping.getSmartExpenseDisplayColor(
      item.category,
      title: item.title,
      description: null,
      transactionType: item.transactionType,
      splitType: item.splitType,
    );
    final categoryIcon = CategoryMapping.getSmartExpenseDisplayIcon(
      item.category,
      title: item.title,
      description: null,
      transactionType: item.transactionType,
      splitType: item.splitType,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              categoryIcon,
              size: 22,
              color: categoryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _compactMovementTitle(
                          item.title,
                          category: item.category,
                        ),
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: theme.textPrimary.withValues(
                              alpha: theme.isDarkMode ? 0.92 : 0.6,
                            ),
                            letterSpacing: -0.3,),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPlannedStatusBadge(item),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Previsto: ${DateFormat('d MMM', 'es').format(item.date)}',
                  style: TextStyle(
                      color: theme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$ ${_formatCurrency(item.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: theme.textPrimary.withValues(
                    alpha: theme.isDarkMode ? 0.88 : 0.5,
                  ),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final result =
                      await PlannedExpensePaymentSheet.show(context, item);
                  if (!mounted || result == null || result['success'] != true) {
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),),
                ),
                child: const Text('Pagar',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 12),),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => ref
                    .read(combinedFeedControllerProvider.notifier)
                    .discardPlannedExpense(item.id),
                style: TextButton.styleFrom(
                  foregroundColor: theme.textMuted,
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Omitir',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w700),),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedStatusBadge(FeedItemModel item) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(item.date.year, item.date.month, item.date.day);
    final diff = dueDate.difference(today).inDays;

    String label = 'PRÓXIMO';
    Color badgeColor = AppColors.textMuted;
    IconData icon = Icons.access_time_rounded;

    if (diff < 0) {
      label = 'PENDIENTE';
      badgeColor = AppColors.accentRed;
      icon = Icons.priority_high_rounded;
    } else if (diff == 0) {
      label = 'VENCE HOY';
      badgeColor = AppColors.accentOrange;
      icon = Icons.today_rounded;
    } else if (diff <= 2) {
      label = 'VENCE PRONTO';
      badgeColor = AppColors.accentGold;
      icon = Icons.notification_important_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor.withValues(alpha: 0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: badgeColor,
                letterSpacing: 0.5,),
          ),
        ],
      ),
    );
  }

  bool _shouldShowFeedItem(FeedItemModel item) {
    if (!item.isPlanned) return true;
    if (item.status != 'pending') return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(item.date.year, item.date.month, item.date.day);

    // Show if it's today, in the past (overdue), or within the next 2 days
    if (dueDate.isBefore(today) || dueDate.isAtSameMomentAs(today)) return true;

    final difference = dueDate.difference(today).inDays;
    return difference <= 2;
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    if (expense.isSettlement) return _buildSettlementCard(expense);

    final isIncome = expense.isIncome;
    final isShared = expense.isShared || expense.splitType == 'gift';
    final theme = context.theme;
    final color = CategoryMapping.getSmartExpenseDisplayColor(
      expense.category,
      title: expense.title,
      description: expense.description,
      transactionType: expense.type,
      splitType: expense.splitType,
    );
    final categoryIcon = CategoryMapping.getSmartExpenseDisplayIcon(
      expense.category,
      title: expense.title,
      description: expense.description,
      transactionType: expense.type,
      splitType: expense.splitType,
    );

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_sweep_rounded,
            color: Colors.white, size: 28,),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Eliminar gasto?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Movimiento eliminado')),);
      },
      child: AnimatedPress(
        onTap: () => _showExpenseDetailSheet(expense),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.border.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowBase.withValues(
                  alpha: theme.isDarkMode ? 0.18 : 0.018,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  categoryIcon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _compactMovementTitle(
                        expense.title,
                        category: expense.category,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: theme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('d MMM', 'es').format(expense.paidAt),
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (expense.description != null &&
                            expense.description!.isNotEmpty) ...[
                          Icon(Icons.notes_rounded,
                              size: 14,
                              color: theme.textMuted.withValues(alpha: 0.65),),
                          if (expense.description!
                                  .toLowerCase()
                                  .contains('art?culos') ||
                              expense.description!
                                  .toLowerCase()
                                  .contains('hogar'))
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.shopping_bag_rounded,
                                  size: 14,
                                  color: AppColors.accentTeal
                                      .withValues(alpha: 0.7),),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${isIncome ? '+' : ''}\$ ${_formatCurrency(expense.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.5,
                      color: isIncome ? AppColors.success : theme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildTypeBadge(
                    expense.splitType == 'gift'
                        ? 'Regalo'
                        : (isShared ? 'Compartido' : 'Personal'),
                    expense.splitType == 'gift'
                        ? Colors.pinkAccent
                        : (isShared ? AppColors.sage : AppColors.textMuted),
                    isSmall: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementCard(ExpenseModel expense) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(
          alpha: theme.isDarkMode ? 0.12 : 0.04,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentBlue.withValues(
            alpha: theme.isDarkMode ? 0.24 : 0.1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_alt_rounded,
              size: 22,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Liquidación de saldo',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.accentBlue,),),
                Text(
                  '${expense.payerDisplayName} equilibró el balance',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$ ${_formatCurrency(expense.amount)}',
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.accentBlue,
                letterSpacing: -0.5,),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String label, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8, vertical: isSmall ? 2 : 4,),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: isSmall ? 8 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // --- Savings Tab ---

  Widget _buildSavingsTab() {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return goalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (goals) {
        if (goals.isEmpty) {
          return _buildEmptyState(
            'No hay metas activas aún',
            icon: '🎯',
            subtitle:
                'Empezá a guardar para algo que de verdad les entusiasme.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savingsGoalsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) =>
                _buildGoalCard(goals[index]).animateStaggered(index),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(SavingsGoalModel goal) {
    final theme = context.theme;
    return AnimatedPress(
      onTap: () => _showContributionDialog(goal),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), blurRadius: 15,),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fromHex(goal.color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(goal.icon, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18,),),
                      const SizedBox(height: 4),
                      Text(
                        'Meta: \$ ${_formatCurrency(goal.targetAmount)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: AppColors.textPrimary,),
                    ),
                    const Text('objetivo',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,),),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(AppColors.fromHex(goal.color)),
              borderRadius: BorderRadius.circular(10),
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ahorrado: \$ ${_formatCurrency(goal.currentAmount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 14,),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.primary, size: 16,),
                      SizedBox(width: 6),
                      Text('Aportar',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  String _formatCurrency(num amount) {
    return NumberFormat('#,###', 'es_AR').format(amount).replaceAll(',', '.');
  }

  Widget _buildEmptyState(
    String message, {
    String icon = '📉',
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child:
                Text(icon, style: const TextStyle(fontSize: 48)).animatePulse(),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle ??
                  'Empez? hoy mismo a organizar tus finanzas del hogar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animateEntrance();
  }

  void _showExpenseSheet({ExpenseModel? expense}) {
    ExpenseFormSheet.show(context, expense: expense, defaultOnlyMe: false);
  }

  void _showExpenseDetailSheet(ExpenseModel expense) async {
    ExpenseDetailSheet.show(context, expense);
  }

  void _showTemplateForm(BuildContext context,
      {ExpenseTemplateModel? template,}) {
    RecurringExpenseFormSheet.show(context, template: template);
  }

  void _showGoalSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedEmoji = '🎯';
    Color selectedColor = AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 46,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            8,
                            24,
                            24 + bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.flag_rounded,
                                      color: AppColors.primary,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nueva Meta',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Definí qué quieren lograr y cuánto necesitan juntar para hacerlo realidad.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.4,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'DETALLE',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Qué quieren alcanzar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: titleController,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: '¿Cuál es tu objetivo?',
                                  prefixIcon: const Icon(
                                    Icons.flag_rounded,
                                    color: AppColors.primary,
                                  ),
                                  filled: true,
                                  fillColor: context.theme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Monto objetivo',
                                  hintText: '¿Cuánto quieren juntar?',
                                  prefixText: '\$ ',
                                  prefixStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: context.theme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'PERSONALIZACIÓN',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Dale personalidad',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  _buildGoalOption(
                                    label: 'Emoji',
                                    value: selectedEmoji,
                                    onTap: () {
                                      final emojis = [
                                        '🎯',
                                        '🏡',
                                        '✈️',
                                        '🚗',
                                        '💍',
                                        '🛋️',
                                        '🍼',
                                        '🎓',
                                        '🐶',
                                        '💻',
                                      ];
                                      _showSimplePicker(
                                        context,
                                        'Elegí un ícono',
                                        emojis,
                                        (e) => setModalState(
                                            () => selectedEmoji = e,),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  _buildGoalOption(
                                    label: 'Color',
                                    value: '',
                                    customValue: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: selectedColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    onTap: () {
                                      final colors = [
                                        AppColors.primary,
                                        AppColors.accentTeal,
                                        AppColors.accentGold,
                                        AppColors.accentPurple,
                                        AppColors.accentRed,
                                        AppColors.success,
                                      ];
                                      _showColorPicker(
                                        context,
                                        colors,
                                        (c) => setModalState(
                                            () => selectedColor = c,),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          18,
                          24,
                          20 + MediaQuery.of(context).padding.bottom,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final title = titleController.text.trim();
                                    final amount = double.tryParse(
                                          amountController.text
                                              .replaceAll(',', '.'),
                                        ) ??
                                        0;

                                    if (title.isNotEmpty && amount > 0) {
                                      ref
                                          .read(savingsGoalsProvider.notifier)
                                          .addGoal(
                                            title,
                                            amount,
                                            '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
                                            selectedEmoji,
                                          );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Crear Meta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalOption(
      {required String label,
      required String value,
      Widget? customValue,
      required VoidCallback onTap,}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,),),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (customValue != null)
                    customValue
                  else
                    Text(value, style: const TextStyle(fontSize: 18)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: AppColors.textMuted,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimplePicker(BuildContext context, String title,
      List<String> options, Function(String) onSelect,) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16,),
              itemCount: options.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  onSelect(options[index]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),),
                  alignment: Alignment.center,
                  child: Text(options[index],
                      style: const TextStyle(fontSize: 24),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
      BuildContext context, List<Color> colors, Function(Color) onSelect,) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Elegí un color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors
                  .map((c) => GestureDetector(
                        onTap: () {
                          onSelect(c);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),),
                        ),
                      ),)
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showContributionDialog(SavingsGoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.theme;
        final amountController = TextEditingController();
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          AppColors.fromHex(goal.color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Text(goal.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ingresar dinero a',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,),),
                        Text(goal.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.textPrimary,),),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextField(
                controller: amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.3),),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      await ref
                          .read(savingsGoalsProvider.notifier)
                          .contribute(goal.id, amount, goalTitle: goal.title);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirmar Aporte',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumLockedRecurrentes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                size: 80,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Pagos Recurrentes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Gestiona tus suscripciones, alquileres y servicios de forma automática con HomeSync Premium.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => PremiumPaywall.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SABER MÁS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
