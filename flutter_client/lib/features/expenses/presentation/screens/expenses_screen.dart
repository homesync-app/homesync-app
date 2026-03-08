import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:intl/intl.dart';
import '../widgets/expense_form_sheet.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> with SingleTickerProviderStateMixin {
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
          _buildAppBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildExpensesTab(),
                _buildSavingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Finanzas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            tabs: const [
              Tab(text: 'RESUMEN'),
              Tab(text: 'GASTOS'),
              Tab(text: 'AHORRO'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        if (_tabController.index == 0) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: () => _tabController.index == 1 ? _showExpenseSheet() : _showGoalSheet(),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            _tabController.index == 1 ? 'Nuevo Gasto' : 'Nueva Meta',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ).animateEntrance();
      },
    );
  }

  // --- Summary Tab ---

  Widget _buildSummaryTab() {
    final summaryAsync = ref.watch(personalFinanceSummaryProvider);
    
    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) {
        final balance = (data['balance'] ?? 0.0).toDouble();
        final isNegative = balance < -0.01;
        final isPositive = balance > 0.01;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(personalFinanceSummaryProvider);
            ref.invalidate(expenseBalancesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildBalanceSection(balance, isPositive, isNegative),
              const SizedBox(height: 32),
              _buildMembersSection(),
              const SizedBox(height: 32),
              _buildSummaryCards(data),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection(double balance, bool isPositive, bool isNegative) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegative 
            ? [Colors.orange[700]!, Colors.orange[400]!] 
            : [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isNegative ? Colors.orange : AppColors.success).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Balance Personal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '${isPositive ? '+' : (isNegative ? '-' : '')}\$${_formatCurrency(balance.abs())}',
            style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            isNegative ? 'Debés dinero a tu pareja' : (isPositive ? 'Te deben dinero' : 'Están al día'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animateEntrance();
  }

  Widget _buildMembersSection() {
    final balancesAsync = ref.watch(expenseBalancesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado de la pareja',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        balancesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (balances) {
            return Row(
              children: balances.map((b) => Expanded(
                child: _buildMemberBalanceItem(b),
              )).toList(),
            );
          },
        ),
      ],
    ).animateEntrance(delay: 100);
  }

  Widget _buildMemberBalanceItem(HouseholdBalanceModel data) {
    final balance = data.balance;
    return Column(
      children: [
        CustomUserAvatar(
          name: data.displayName,
          avatarUrl: data.avatarUrl,
          radius: 24,
        ),
        const SizedBox(height: 8),
        Text(
          data.displayName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        Text(
          '${balance >= 0 ? '+' : ''}\$${_formatCurrency(balance)}',
          style: TextStyle(
            color: balance >= 0 ? AppColors.success : Colors.orange[700],
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildStatTile(
          'Total mis pagos', 
          '\$${_formatCurrency((data['total_paid'] ?? 0.0).toDouble())}', 
          Icons.payments_rounded, 
          Colors.blue,
        ).animateStaggered(1),
        const SizedBox(height: 12),
        _buildStatTile(
          'Lo que yo consumí', 
          '\$${_formatCurrency((data['total_consumed'] ?? 0.0).toDouble())}', 
          Icons.shopping_basket_rounded, 
          Colors.purple,
        ).animateStaggered(2),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  // --- Expenses Tab ---

  Widget _buildExpensesTab() {
    final expensesAsync = ref.watch(expenseControllerProvider);
    
    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (expenses) {
        if (expenses.isEmpty) return _buildEmptyState('No hay gastos cargados');
        
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(expenseControllerProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildExpenseCard(expenses[index]).animateStaggered(index),
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final isShared = expense.isShared;
    final color = AppColors.getCategoryColor(expense.category);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(AppColors.getCategoryMaterialIcon(expense.category), color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Row(
                    children: [
                      Text(
                        expense.paidBy == ref.read(currentUserIdProvider) ? 'Pagaste vos' : 'Pagó tu pareja',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isShared ? AppColors.sage : Colors.blueGrey).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isShared ? 'COMPARTIDO' : 'PERSONAL',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isShared ? AppColors.sage : Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '\$${_formatCurrency(expense.amount)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
            ),
          ],
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
        if (goals.isEmpty) return _buildEmptyState('No hay metas de ahorro');
        
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savingsGoalsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) => _buildGoalCard(goals[index]).animateStaggered(index),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(dynamic goal) {
    // Basic goal card during restoration
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(goal.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(AppColors.fromHex(goal.color)),
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_formatCurrency(goal.currentAmount)} / \$${_formatCurrency(goal.targetAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              AnimatedPress(
                onTap: () => _showContributionDialog(goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                  child: const Text('Aportar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  String _formatCurrency(double amount) {
    return NumberFormat('#,##0.00', 'es').format(amount);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.query_stats_rounded, size: 64, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showExpenseSheet() {
    ExpenseFormSheet.show(context);
  }

  void _showGoalSheet() {
    // Trigger sheet to create new goal (to be implemented)
  }

  void _showContributionDialog(dynamic goal) {
     showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Aportar a ${goal.title}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto a ahorrar (\$)', prefixText: '\$'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  Navigator.pop(context);
                  await ref.read(savingsGoalsProvider.notifier).contribute(goal.id, amount);
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
