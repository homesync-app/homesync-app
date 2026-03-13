import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import '../widgets/expense_form_sheet.dart';
import '../widgets/expense_detail_sheet.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTabBar(),
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
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        tabs: const [
          Tab(text: 'Movimientos'),
          Tab(text: 'Recurrentes'),
          Tab(text: 'Metas'),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        String label = 'Nuevo Movimiento';
        VoidCallback onPressed = () => _showExpenseSheet();

        if (_tabController.index == 1) {
          label = 'Nueva Suscripción';
          onPressed = () => _showTemplateForm(context);
        } else if (_tabController.index == 2) {
          label = 'Nueva Meta';
          onPressed = () => _showGoalSheet();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
            heroTag: 'expenses_fab',
            onPressed: onPressed,
            backgroundColor: AppColors.primary,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            label: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16),
            ),
          ).animateEntrance(),
        );
      },
    );
  }

  // --- Summary Tab ---

  Widget _buildMovimientosTab() {
    final summaryAsync = ref.watch(personalFinanceSummaryProvider);
    final feedAsync = ref.watch(combinedFeedControllerProvider);
    final projectionAsync = ref.watch(monthlyProjectionProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(expenseBalancesProvider);
        ref.invalidate(combinedFeedControllerProvider);
        ref.invalidate(monthlyProjectionProvider);
        ref.invalidate(expenseControllerProvider);
      },
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // 1. SUMMARY WIDGET WITH PROJECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: summaryAsync.when(
                loading: () => const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                            color: AppColors.primary))),
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
                        balance, income, expense, proj.pending),
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
                hasScrollBody: false, child: Center(child: Text('Error: $e'))),
            data: (feedItems) {
              final sortedItems = List<FeedItemModel>.from(feedItems)
                ..sort((a, b) => b.date.compareTo(a.date));

              return SliverMainAxisGroup(
                slivers: [
                  if (sortedItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.history_rounded, size: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'MOVIMIENTOS',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 6),
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

  Widget _buildProjectionStat(String label, num amount, Color color,
      {bool isBold = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '\$ ${_formatCurrency(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --- Recurrentes Tab ---

  Widget _buildRecurrentesTab() {
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
                parent: AlwaysScrollableScrollPhysics()),
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
                              size: 64, color: AppColors.primary).animatePulse(),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sin gastos recurrentes',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5),
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
                                fontWeight: FontWeight.w500),
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
                            AppColors.getCategoryColor(template.category);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () =>
                                _showTemplateForm(context, template: template),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColors.divider
                                        .withValues(alpha: 0.3)),
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
                                    child: Text(
                                      AppColors.categoryIcons[template.category
                                              .toLowerCase()] ??
                                          '📦',
                                      style: const TextStyle(fontSize: 24),
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
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Día ${template.dayOfMonth} de cada mes',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
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
                                            color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.sage
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          template.splitType == 'equal'
                                              ? '50/50'
                                              : 'Personal',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.sage),
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
      num balance, num income, num expense, num projectedPending) {
    final projectedBalance = balance - projectedPending;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          // Premium Header & Balance Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BALANCE ACTUAL',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$ ${_formatCurrency(balance)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Income & Expenses Row
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

          // Projection Footer (Clean Integration)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildProjectionStat('Gastos pendientes', projectedPending, AppColors.textSecondary,
                    onTap: () => _showPendingBreakdownSheet(projectedPending),
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _buildProjectionStat('Balance estimado', projectedBalance, AppColors.textPrimary, 
                    isBold: true,
                    onTap: () => _showProjectionBreakdownSheet(balance, projectedPending, projectedBalance),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animateEntrance(delay: 100);
  }

  void _showProjectionBreakdownSheet(num balance, num pendingTotal, num estimated) {
    final feedAsync = ref.read(combinedFeedControllerProvider).valueOrNull ?? [];
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();
    
    final pendingItems = feedAsync.where((item) => 
      item.isPlanned && 
      item.status == 'pending' && 
      item.payerId == userId &&
      item.date.month == now.month && 
      item.date.year == now.year
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                  const Text(
                    'Cálculo de Proyección',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Así llegamos a tu balance estimado para fin de mes.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Equation Section
                  _buildBreakdownRow('Balance actual', balance, AppColors.textPrimary),
                  const SizedBox(height: 16),
                  _buildBreakdownRow('Gastos pendientes', -pendingTotal, AppColors.primary),
                  const Divider(height: 40, thickness: 1, color: AppColors.divider),
                  _buildBreakdownRow('Balance estimado', estimated, AppColors.accentTeal, isFinal: true),
                  
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
                          child: const Icon(Icons.pending_actions_rounded, size: 12, color: AppColors.primary),
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
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(item.categoryIcon, style: const TextStyle(fontSize: 16)),
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
                            '\$ ${_formatCurrency(item.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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

  Widget _buildBreakdownRow(String label, num amount, Color color, {bool isFinal = false}) {
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
            color: amount < 0 ? AppColors.primary : (isFinal ? AppColors.accentTeal : color),
            fontSize: isFinal ? 22 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatTile(String label, num amount, Color color, IconData icon, {VoidCallback? onTap}) {
    return AnimatedPress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '\$ ${_formatCurrency(amount)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomeBreakdownSheet(num total) {
    final expenses = ref.read(expenseControllerProvider).valueOrNull ?? [];
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final items = expenses.where((e) {
      if (e.paidAt.month != now.month || e.paidAt.year != now.year) return false;
      if (e.isIncome && e.paidBy == userId) return true;
      if (e.isSettlement && e.paidBy != userId) return true; // Partner paid me
      return false;
    }).toList();

    _showGenericBreakdownSheet('Detalle de Ingresos', 'Tus ingresos registrados este mes.', total, items, AppColors.success);
  }

  void _showExpensesBreakdownSheet(num total) {
    final expenses = ref.read(expenseControllerProvider).valueOrNull ?? [];
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final items = expenses.where((e) {
      if (e.paidAt.month != now.month || e.paidAt.year != now.year) return false;
      if (e.type == 'expense' && e.paidBy == userId) return true;
      if (e.isSettlement && e.paidBy == userId) return true; // I paid partner
      return false;
    }).toList();

    _showGenericBreakdownSheet('Detalle de Gastos', 'Tus gastos pagados este mes.', total, items, AppColors.primary);
  }

  void _showPendingBreakdownSheet(num total) {
    final feedAsync = ref.read(combinedFeedControllerProvider).valueOrNull ?? [];
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final items = feedAsync.where((item) =>
      item.isPlanned &&
      item.status == 'pending' &&
      item.payerId == userId &&
      item.date.month == now.month &&
      item.date.year == now.year
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBreakdownBaseContainer(
        title: 'Gastos Pendientes',
        subtitle: 'Lo que tenés programado pagar antes de fin de mes.',
        total: total,
        totalLabel: 'Total pendiente',
        accentColor: AppColors.textSecondary,
        content: Column(
          children: items.map((item) => _buildMovementDetailRow(
            title: item.title,
            amount: item.amount,
            date: item.date,
            icon: item.categoryIcon,
            color: AppColors.primary,
          )).toList(),
        ),
      ),
    );
  }

  void _showGenericBreakdownSheet(String title, String subtitle, num total, List<ExpenseModel> items, Color accentColor) {
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
            ? [const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Text('No hay movimientos registrados', style: TextStyle(color: AppColors.textMuted)))]
            : items.map((e) => _buildMovementDetailRow(
                title: e.title,
                amount: e.amount,
                date: e.paidAt,
                icon: e.categoryIcon.isNotEmpty ? e.categoryIcon : (e.isIncome ? '📈' : '📦'),
                color: accentColor,
              )).toList(),
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
                    border: Border.all(color: accentColor.withValues(alpha: 0.1)),
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
                      child: Icon(Icons.list_alt_rounded, size: 12, color: accentColor),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
    required String icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                Text(DateFormat('d MMM', 'es').format(date), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text('\$ ${_formatCurrency(amount)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
        ],
      ),
    );
  }



  Widget _buildMiniStats(
      String label, num amount, IconData icon, Color color,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (crossAxisAlignment == CrossAxisAlignment.start)
              Icon(icon, size: 12, color: color),
            if (crossAxisAlignment == CrossAxisAlignment.start)
              const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (crossAxisAlignment == CrossAxisAlignment.end)
              const SizedBox(width: 4),
            if (crossAxisAlignment == CrossAxisAlignment.end)
              Icon(icon, size: 12, color: color),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '\$ ${_formatCurrency(amount)}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedItemCard(FeedItemModel item) {
    if (item.isRealExpense) {
      final expenses = ref.read(expenseControllerProvider).valueOrNull;
      final expense = expenses?.where((e) => e.id == item.id).firstOrNull ?? ExpenseModel(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.categoryIcon,
              style: const TextStyle(fontSize: 24),
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
                        item.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary.withValues(alpha: 0.6),
                            letterSpacing: -0.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 9, color: AppColors.textMuted.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          const Text(
                            'PRÓXIMO',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Previsto: ${DateFormat('d MMM', 'es').format(item.date)}',
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
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
                  fontSize: 16,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => PlannedExpensePaymentSheet.show(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Pagar',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    if (expense.isSettlement) return _buildSettlementCard(expense);

    final isIncome = expense.isIncome;
    final isShared = expense.isShared;
    final color = isIncome
        ? AppColors.success
        : AppColors.getCategoryColor(expense.category);

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
            color: Colors.white, size: 28),
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
                  child: const Text('Cancelar')),
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
            const SnackBar(content: Text('Movimiento eliminado')));
      },
      child: AnimatedPress(
        onTap: () => _showExpenseDetailSheet(expense),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
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
                child: Text(
                  expense.categoryIcon.isNotEmpty
                      ? expense.categoryIcon
                      : (isIncome ? '📈' : '📦'),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat('d MMM', 'es').format(expense.paidAt),
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        if (expense.description != null &&
                            expense.description!.isNotEmpty) ...[
                          Icon(Icons.notes_rounded,
                              size: 14,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.5)),
                          if (expense.description!
                                  .toLowerCase()
                                  .contains('artículos') ||
                              expense.description!
                                  .toLowerCase()
                                  .contains('lista'))
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.shopping_bag_rounded,
                                  size: 14,
                                  color: AppColors.accentTeal
                                      .withValues(alpha: 0.7)),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : ''}\$ ${_formatCurrency(expense.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color:
                          isIncome ? AppColors.success : AppColors.textPrimary,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Text('🤝', style: TextStyle(fontSize: 24)),
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
                        color: AppColors.accentBlue)),
                Text(
                  '${expense.payerDisplayName} equilibró el balance',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
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
                letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String label, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8, vertical: isSmall ? 2 : 4),
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
        if (goals.isEmpty) return _buildEmptyState('No hay metas activas aún', icon: '🎯');

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
    return AnimatedPress(
      onTap: () => _showContributionDialog(goal),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), blurRadius: 15)
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
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        'Meta: \$ ${_formatCurrency(goal.targetAmount)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
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
                          color: AppColors.textPrimary),
                    ),
                    const Text('objetivo',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
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
                      fontSize: 14),
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
                          color: AppColors.primary, size: 16),
                      SizedBox(width: 6),
                      Text('Aportar',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800)),
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

  Widget _buildEmptyState(String message, {String icon = '📉'}) {
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
            child: Text(icon, style: const TextStyle(fontSize: 48)).animatePulse(),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Empezá hoy mismo a organizar tus finanzas en pareja.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ).animateEntrance();
  }

  void _showExpenseSheet({ExpenseModel? expense}) {
    ExpenseFormSheet.show(context, expense: expense, defaultOnlyMe: true);
  }

  void _showExpenseDetailSheet(ExpenseModel expense) async {
    // If expense splits are missing (common for feed items), fetch the full expense
    if (expense.splits == null || expense.splits!.isEmpty) {
      ref.read(expenseRepositoryProvider).getExpenseWithSplits(expense.id).then((result) {
        result.fold(
          (failure) => ExpenseDetailSheet.show(context, expense), // Show partial as fallback
          (fullData) => ExpenseDetailSheet.show(context, ExpenseModel.fromJson(fullData)),
        );
      });
    } else {
      ExpenseDetailSheet.show(context, expense);
    }
  }

  void _showTemplateForm(BuildContext context,
      {ExpenseTemplateModel? template}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecurringExpenseFormSheet(template: template),
    );
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
        builder: (context, setModalState) => Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nueva Meta',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -1.0)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: titleController,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              hintText: '¿Cuál es tu objetivo?',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none,
                              icon: Icon(Icons.flag_rounded,
                                  color: AppColors.primary),
                            ),
                          ),
                          const Divider(height: 32),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              hintText: 'Monto objetivo',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none,
                              icon: Icon(Icons.attach_money_rounded,
                                  color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Personalizá tu meta',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildGoalOption(
                          label: 'Emoji',
                          value: selectedEmoji,
                          onTap: () {
                            final emojis = [
                              '🎯',
                              '🏠',
                              '🚗',
                              '💍',
                              '✈️',
                              '🏝️',
                              '🎮',
                              '💻',
                              '👶',
                              '🐶'
                            ];
                            _showSimplePicker(context, 'Elegí un ícono', emojis,
                                (e) => setModalState(() => selectedEmoji = e));
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildGoalOption(
                          label: 'Color',
                          value: '',
                          customValue: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: selectedColor, shape: BoxShape.circle),
                          ),
                          onTap: () {
                            final colors = [
                              AppColors.primary,
                              AppColors.accentTeal,
                              AppColors.accentGold,
                              AppColors.accentPurple,
                              AppColors.accentRed,
                              AppColors.success
                            ];
                            _showColorPicker(context, colors,
                                (c) => setModalState(() => selectedColor = c));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(
                                  amountController.text.replaceAll(',', '.')) ??
                              0;

                          if (title.isNotEmpty && amount > 0) {
                            ref.read(savingsGoalsProvider.notifier).addGoal(
                                title,
                                amount,
                                '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
                                selectedEmoji);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Crear Meta',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(
      {required String label,
      required String value,
      Widget? customValue,
      required VoidCallback onTap}) {
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
                      color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (customValue != null)
                    customValue
                  else
                    Text(value, style: const TextStyle(fontSize: 18)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: AppColors.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimplePicker(BuildContext context, String title,
      List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16),
              itemCount: options.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  onSelect(options[index]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(options[index],
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
      BuildContext context, List<Color> colors, Function(Color) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Elegí un color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
                                  Border.all(color: Colors.white, width: 2)),
                        ),
                      ))
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
        final amountController = TextEditingController();
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                                fontWeight: FontWeight.w600)),
                        Text(goal.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.textPrimary)),
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
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.3)),
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
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirmar Aporte',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
