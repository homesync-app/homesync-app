import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:intl/intl.dart';
import '../widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/features/savings/presentation/screens/savings_screen.dart';


class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

// --- Helper for Argentine Currency Formatting ---
String _formatCurrency(double amount) {
  return NumberFormat.decimalPattern('es_AR').format(amount.round());
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(personalFinanceSummaryProvider);
    final expensesAsync = ref.watch(expenseControllerProvider);
    final filters = ref.watch(expenseFiltersNotifierProvider);
    final movementsAsync = ref.watch(mercadopagoMovementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'finance_add_expense_v2',
        onPressed: () => _showExpenseSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Movimiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(personalFinanceSummaryProvider);
          ref.invalidate(expenseControllerProvider);
          ref.invalidate(mercadopagoMovementsProvider);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Financial Summary Header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: summaryAsync.when(
                  loading: () => _buildSummaryShimmer(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (summary) => _buildSummaryCard(summary),
                ),
              ),
            ),

            // ── MP Suggestions Section ─────────────────────────────────────
            movementsAsync.when(
              data: (movements) => movements.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: _buildMPSuggestions(movements),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink()),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Savings Goals Section (METAS) ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildSavingsSection(),
              ),
            ),

            // ── Filter Chips ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(
                child: _buildFilterChips(filters),
              ),
            ),

            // ── Transaction List ───────────────────────────────────────────
            expensesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final e = expenses[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 6),
                          child: AnimatedPress(
                            onTap: () => _showExpenseSheet(e),
                            child: _TransactionItem(expense: e),
                          ),
                        );
                      },
                      childCount: expenses.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final balance = (summary['balance'] ?? 0).toDouble();
    final income = (summary['income'] ?? 0).toDouble();
    final expense = (summary['expense'] ?? 0).toDouble();
    final variation = (summary['variation'] ?? 0).toDouble();

    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BALANCE ACTUAL',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isPositive ? '+' : '-'} \$ ${_formatCurrency(balance.abs())}',
                    style: TextStyle(
                      color:
                          isPositive ? AppColors.sage : AppColors.accentOrange,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              _buildVariationBadge(variation),
            ],
          ),
          const SizedBox(height: 28),
          Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 28),
          Row(
            children: [
              _buildMiniMetric('Ingresos', income, AppColors.success),
              Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider.withValues(alpha: 0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildMiniMetric('Gastos', expense, AppColors.textPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_formatCurrency(value)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationBadge(double variation) {
    final isIncrease = variation > 0;
    final color = isIncrease ? AppColors.accentOrange : AppColors.sage;
    final icon =
        isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '${variation.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMPSuggestions(List<Map<String, dynamic>> movements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sugerencias MP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movements.length,
            itemBuilder: (context, index) {
              final move = movements[index];
              final amount = (move['amount'] as num).toDouble();
              final title = move['title'] ?? 'Gasto MP';
              final isIncome = move['type'] == 'income';

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.success.withValues(alpha: 0.05)
                      : Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('\$${_formatCurrency(amount)}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isIncome ? AppColors.success : Colors.blue)),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showExpenseSheet(ExpenseModel(
                          id: '',
                          title: title,
                          amount: amount,
                          householdId: '',
                          paidBy: '',
                          paidAt: DateTime.now(),
                          createdAt: DateTime.now(),
                          type: isIncome ? 'income' : 'expense',
                          isShared: false,
                        )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Registrar',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ExpenseFilters current) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            isSelected: current.sharing == 'all' && current.type == 'all',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(expenseFiltersNotifierProvider.notifier).updateFilters(sharing: 'all', type: 'all');
            },
          ),
          _FilterChip(
            label: 'Personal',
            isSelected: current.sharing == 'mine',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(expenseFiltersNotifierProvider.notifier).updateFilters(sharing: 'mine');
            },
          ),
          _FilterChip(
            label: 'Compartido',
            isSelected: current.sharing == 'shared',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(expenseFiltersNotifierProvider.notifier).updateFilters(sharing: 'shared');
            },
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: AppColors.divider),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Ingresos',
            isSelected: current.type == 'income',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(expenseFiltersNotifierProvider.notifier).updateFilters(type: 'income');
            },
            activeColor: AppColors.success,
          ),
          _FilterChip(
            label: 'Gastos',
            isSelected: current.type == 'expense',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(expenseFiltersNotifierProvider.notifier).updateFilters(type: 'expense');
            },
            activeColor: AppColors.accentOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return ShimmerLoading(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 80, height: 10, color: Colors.white),
                    const SizedBox(height: 10),
                    Container(width: 140, height: 30, color: Colors.white),
                  ],
                ),
                Container(width: 60, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white)),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: Container(height: 40, color: Colors.white)),
                const SizedBox(width: 20),
                Expanded(child: Container(height: 40, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text(
            'Sin movimientos',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'No encontramos registros con estos filtros.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showExpenseSheet([ExpenseModel? expense]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormSheet(expense: expense),
    );
  }

  Widget _buildSavingsSection() {
    final savingsGoalsAsync = ref.watch(savingsGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'METAS DE AHORRO',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        savingsGoalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return _buildEmptySavingsCard();
            }
            return _buildSavingsCard(goals.first); // Show first goal as teaser
          },
          loading: () => ShimmerLoading(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptySavingsCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, AppTransitions.slideHorizontal(page: const SavingsScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.savings_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Empezamos a ahorrar?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Crea una meta y junten dinero juntos.',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(SavingsGoalModel goal) {
    final progress = goal.currentAmount / goal.targetAmount;
    return GestureDetector(
      onTap: () => Navigator.push(
          context, AppTransitions.slideHorizontal(page: const SavingsScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Text(goal.icon.isEmpty ? '💰' : goal.icon,
                  style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% • \$${_formatCurrency(goal.currentAmount)} de \$${_formatCurrency(goal.targetAmount)}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends ConsumerWidget {
  final ExpenseModel expense;

  const _TransactionItem({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('d MMM', 'es');
    final isIncome = expense.type == 'income';
    final isSettlement = expense.type == 'settlement';
    final currentUserId = ref.read(currentUserIdProvider);

    final bool isPositive =
        isIncome || (isSettlement && expense.paidBy != currentUserId);
    final color = isSettlement
        ? const Color(0xFF94A3B8)
        : (isPositive ? AppColors.success : AppColors.textPrimary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSettlement
                  ? const Color(0xFFF1F5F9)
                  : AppColors.getCategoryColor(expense.category)
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                isSettlement
                    ? '🤝'
                    : (AppColors.categoryIcons[expense.category] ?? '📦'),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSettlement ? 'Liquidación de pareja' : expense.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isSettlement
                        ? const Color(0xFF64748B)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dateFormat.format(expense.paidAt)} • ${isSettlement ? "Ajuste" : (expense.isShared ? "Compartido" : "Personal")}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? "+" : "-"}\$${_formatCurrency(expense.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: color,
                ),
              ),
              if (isSettlement)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AJUSTE',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 8,
                        fontWeight: FontWeight.w900),
                  ),
                )
              else if (expense.isShared)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PAR',
                    style: TextStyle(
                        color: AppColors.sage,
                        fontSize: 8,
                        fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
