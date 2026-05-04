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
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:intl/intl.dart';

import '../providers/estimated_income_provider.dart';
import '../widgets/estimated_income_sheet.dart';
import '../widgets/expense_detail_sheet.dart';
import '../widgets/expense_form_sheet.dart';
import '../widgets/planned_expense_payment_sheet.dart';
import '../widgets/recurring_expense_form_sheet.dart';
import 'recurrentes_tab.dart';
import 'savings_tab.dart';

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
                RecurrentesTab(
                  formatCurrency: _formatCurrency,
                  onTemplateForm: _showTemplateForm,
                ),
                const SavingsTab(),
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
          onPressed = () => SavingsTab.showGoalSheet(context, ref);
        }

        return AppFloatingActionButton(
          label: label,
          icon: Icons.add_rounded,
          onPressed: onPressed,
          heroTag: 'expenses_fab',
          margin: const EdgeInsets.only(bottom: 20),
          animateIn: true,
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
    final estimatedIncomeAsync = ref.watch(estimatedIncomeNotifierProvider);

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
          parent: AlwaysScrollableScrollPhysics(),
        ),
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
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (summary) {
                  final realIncome =
                      (summary['income'] as num?)?.toDouble() ?? 0.0;
                  final expense =
                      (summary['expense'] as num?)?.toDouble() ?? 0.0;
                  final settlementsReceived =
                      (summary['settlements_received'] as num?)?.toDouble() ??
                          0.0;
                  final settlementsPaid =
                      (summary['settlements_paid'] as num?)?.toDouble() ?? 0.0;
                  // balance real del RPC (incluye settlements correctamente)
                  final rpcBalance =
                      (summary['balance'] as num?)?.toDouble() ?? 0.0;

                  final estimated = estimatedIncomeAsync.valueOrNull;
                  final isIncomeEstimated =
                      realIncome == 0 && estimated?.isSet == true;

                  // income para mostrar en el tile: ingresos reales o estimado
                  final displayIncome = realIncome > 0
                      ? realIncome
                      : (estimated?.isSet == true ? estimated!.amount : 0.0);

                  // balance para mostrar: si hay ingreso estimado lo usamos,
                  // si no usamos el balance real del RPC (que ya tiene settlements)
                  final balance = isIncomeEstimated
                      ? estimated!.amount +
                          settlementsReceived -
                          expense -
                          settlementsPaid
                      : rpcBalance;

                  return projectionAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildUnifiedSummaryCard(
                      balance,
                      displayIncome,
                      expense,
                      0,
                      isIncomeEstimated: isIncomeEstimated,
                    ),
                    data: (proj) => _buildUnifiedSummaryCard(
                      balance,
                      displayIncome,
                      expense,
                      proj.pending,
                      isIncomeEstimated: isIncomeEstimated,
                    ),
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
              hasScrollBody: false,
              child: Center(child: Text('Error: $e')),
            ),
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
                              child: Icon(
                                Icons.history_rounded,
                                size: 12,
                                color: theme.textSecondary,
                              ),
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
                                  horizontal: 24,
                                  vertical: 6,
                                ),
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
    if (normalized.isEmpty) return CategoryMapping.displayName(category);

    final lower = normalized.toLowerCase();
    final categoryId = category?.toLowerCase();

    if (lower == categoryId ||
        CategoryMapping.categoryNames.containsKey(lower)) {
      return CategoryMapping.displayName(normalized);
    }

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
        .where(
          (item) =>
              item.isPlanned &&
              item.status == 'pending' &&
              item.date.month == now.month &&
              item.date.year == now.year,
        )
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

  Widget _buildProjectionStat(
    String label,
    num amount,
    Color color, {
    bool isBold = false,
    VoidCallback? onTap,
  }) {
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

  // --- Recurrentes Tab (delegated to RecurrentesTab widget) ---

  Widget _buildUnifiedSummaryCard(
    num balance,
    num income,
    num expense,
    num projectedPending, {
    bool isIncomeEstimated = false,
  }) {
    final projectedBalance = balance - projectedPending;
    final theme = context.theme;
    final hasIncome = income > 0;

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
                  hasIncome ? 'TU BALANCE ACTUAL' : 'GASTOS DEL MES',
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
                    '\$ ${_formatCurrency(hasIncome ? balance : expense)}',
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
                    if (hasIncome) ...[
                      Expanded(
                        child: _buildPremiumStatTile(
                          isIncomeEstimated ? 'Ingreso estimado' : 'Ingresos',
                          income,
                          AppColors.success,
                          isIncomeEstimated
                              ? Icons.edit_rounded
                              : Icons.trending_up_rounded,
                          onTap: isIncomeEstimated
                              ? () => EstimatedIncomeSheet.show(context)
                              : () => _showIncomeBreakdownSheet(income),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
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
                    hasIncome ? 'Cierre estimado' : 'Pendiente de pagar',
                    hasIncome ? projectedBalance : projectedPending,
                    theme.textPrimary,
                    isBold: true,
                    onTap: () => hasIncome
                        ? _showProjectionBreakdownSheet(
                            balance,
                            projectedPending,
                            projectedBalance,
                          )
                        : _showPendingBreakdownSheet(projectedPending),
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
    num balance,
    num pendingTotal,
    num estimated,
  ) {
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
                    'Tu balance actual',
                    balance,
                    AppColors.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  _buildBreakdownRow(
                    'Tu parte pendiente',
                    -pendingTotal,
                    AppColors.primary,
                  ),
                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  _buildBreakdownRow(
                    'Tu cierre estimado',
                    estimated,
                    AppColors.accentTeal,
                    isFinal: true,
                  ),

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
                          child: const Icon(
                            Icons.pending_actions_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
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
                    ...pendingItems.map(
                      (item) => Padding(
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
                              child: Text(
                                item.categoryIcon,
                                style: const TextStyle(fontSize: 16),
                              ),
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
                      ),
                    ),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Entendido',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildBreakdownRow(
    String label,
    num amount,
    Color color, {
    bool isFinal = false,
  }) {
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
    String label,
    num amount,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
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
        .where(
          (item) =>
              item.isRealExpense &&
              item.date.month == now.month &&
              item.date.year == now.year &&
              ((item.transactionType == 'income' && item.payerId == userId) ||
                  (item.transactionType == 'settlement' &&
                      item.payerId != userId)),
        )
        .map(_expenseFromFeedItem)
        .toList();

    _showGenericBreakdownSheet(
      'Detalle de Ingresos',
      'Tus ingresos registrados este mes.',
      total,
      items,
      AppColors.success,
    );
  }

  void _showExpensesBreakdownSheet(num total) {
    final feed = _effectiveFeedForBreakdowns();
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final items = feed
        .where(
          (item) =>
              item.isRealExpense &&
              item.date.month == now.month &&
              item.date.year == now.year &&
              ((item.transactionType == 'expense' && item.payerId == userId) ||
                  (item.transactionType == 'settlement' &&
                      item.payerId == userId)),
        )
        .map(_expenseFromFeedItem)
        .toList();

    _showGenericBreakdownSheet(
      'Detalle de Gastos',
      'Tus gastos pagados este mes.',
      total,
      items,
      AppColors.primary,
    );
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
              .map(
                (item) => _buildMovementDetailRow(
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
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showGenericBreakdownSheet(
    String title,
    String subtitle,
    num total,
    List<ExpenseModel> items,
    Color accentColor,
  ) {
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
                    child: Text(
                      'No hay movimientos registrados',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ]
              : items
                  .map(
                    (e) => _buildMovementDetailRow(
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
                    ),
                  )
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
                      child: Icon(
                        Icons.list_alt_rounded,
                        size: 12,
                        color: accentColor,
                      ),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('d MMM', 'es').format(date),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$ ${_formatCurrency(amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
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
                          letterSpacing: -0.3,
                        ),
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
                    fontWeight: FontWeight.w600,
                  ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pagar',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
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
                child: const Text(
                  'Omitir',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
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
              letterSpacing: 0.5,
            ),
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
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 28,
        ),
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
                child: const Text('Cancelar'),
              ),
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
          const SnackBar(content: Text('Movimiento eliminado')),
        );
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
                          Icon(
                            Icons.notes_rounded,
                            size: 14,
                            color: theme.textMuted.withValues(alpha: 0.65),
                          ),
                          if (expense.description!
                                  .toLowerCase()
                                  .contains('art?culos') ||
                              expense.description!
                                  .toLowerCase()
                                  .contains('hogar'))
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.shopping_bag_rounded,
                                size: 14,
                                color:
                                    AppColors.accentTeal.withValues(alpha: 0.7),
                              ),
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
                const Text(
                  'Liquidación de saldo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.accentBlue,
                  ),
                ),
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
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String label, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
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

  void _showTemplateForm(
    BuildContext context, {
    ExpenseTemplateModel? template,
    String initialType = 'expense',
  }) {
    RecurringExpenseFormSheet.show(
      context,
      template: template,
      initialType: initialType,
    );
  }
}
