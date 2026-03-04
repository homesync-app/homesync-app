import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import '../widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/savings/presentation/screens/savings_screen.dart';
import 'package:homesync_client/core/services/mercadopago_service.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
class FinanceViewNotifier extends Notifier<bool> {
  @override
  bool build() => true; // true = Compartido, false = Personal

  void setShared() => state = true;
  void setPersonal() => state = false;
  void toggle() => state = !state;
}

final financeViewProvider = NotifierProvider<FinanceViewNotifier, bool>(FinanceViewNotifier.new);

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final isShared = ref.watch(financeViewProvider);
    final expensesAsync = ref.watch(expensesAndBalancesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => _showExpenseSheet(),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Nuevo movimiento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expensesAndBalancesProvider);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              expandedHeight: 0,
              backgroundColor: AppColors.background,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: _buildSegmentedControl(isShared),
                ),
              ),
            ),
            expensesAsync.when(
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              loading: () => SliverFillRemaining(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, __) => ShimmerLoading(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
              data: (data) {
                final expenses = data['expenses'] as List<ExpenseModel>;
                final balances = data['balances'] as List<HouseholdBalanceModel>;
                final householdId = data['householdId'] as String;

                // Filter personal vs shared
                final filteredExpenses = expenses.where((e) {
                  return isShared ? e.isShared : !e.isShared;
                }).toList();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (isShared) ...[
                        _buildSharedDashboard(balances, householdId),
                      ] else ...[
                        _buildPersonalSummary(filteredExpenses),
                      ],
                      const SizedBox(height: 32),
                      _buildMPSuggestions(),
                      const SizedBox(height: 32),
                      Text(
                        isShared ? 'Movimientos Compartidos' : 'Mis Movimientos Personales',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filteredExpenses.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredExpenses.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final ExpenseModel e = entry.value;
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 400 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: AnimatedPress(
                              onTap: () => _showExpenseSheet(e),
                              child: _ExpenseItem(expense: e),
                            ),
                          );
                        }),
                      const SizedBox(height: 120),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(bool isShared) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Nuestras Finanzas',
              isSelected: isShared,
              onTap: () => ref.read(financeViewProvider.notifier).setShared(),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Mis Finanzas',
              isSelected: !isShared,
              onTap: () => ref.read(financeViewProvider.notifier).setPersonal(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSharedDashboard(List<HouseholdBalanceModel> balances, String householdId) {
    if (balances.isEmpty) return const SizedBox.shrink();

    final currentUserId = ref.watch(currentUserIdProvider);
    
    final myBal = balances.firstWhere(
        (b) => b.userId == currentUserId,
        orElse: () => HouseholdBalanceModel(userId: currentUserId ?? '', balance: 0.0));
    final partnerBal = balances.firstWhere(
        (b) => b.userId != currentUserId,
        orElse: () => HouseholdBalanceModel(userId: '', balance: 0.0));
    
    final myBalance = myBal.balance;
    final isNegative = myBalance < -0.01;

    // Calculate split percentage for visual bar
    // We'll map the balance difference to a range [0.3, 0.7] for visual appeal.
    double myPercent = 0.5;
    if (myBalance != 0) {
      double absBal = myBalance.abs();
      double shift = (absBal / (absBal + 2000)).clamp(0, 0.2);
      myPercent = myBalance > 0 ? 0.5 + shift : 0.5 - shift;
    }

    // Avatars: Always prioritize real profile/member data over balance metadata
    final myProfile = ref.watch(userProfileProvider).value;
    final members = ref.watch(householdMembersProvider).value ?? [];
    final partner = members.where((m) => m.userId != currentUserId).firstOrNull;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
            border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // My Avatar (Left)
                  CustomUserAvatar(
                    name: myProfile?['full_name'] ?? 'Tú',
                    avatarUrl: myProfile?['avatar_url'],
                    radius: 28,
                  ),
                  
                  // Central Balance info
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                            'BALANCE DE PAREJA',
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${myBalance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isNegative ? AppColors.accentRed : AppColors.sage,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isNegative ? 'Debes a tu pareja' : (myBalance > 0.01 ? 'Tu pareja te debe' : 'Están al día'),
                            style: TextStyle(
                              color: (isNegative ? AppColors.accentRed : AppColors.sage).withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Partner Avatar (Right)
                  CustomUserAvatar(
                    name: partner?.displayName ?? 'Pareja',
                    avatarUrl: partner?.avatarUrl,
                    radius: 28,
                    showBorder: true,
                    borderColor: AppColors.accentPeach.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Visual Split Bar
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 12,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (myPercent * 100).toInt().clamp(1, 99),
                            child: Container(color: AppColors.accentPeach),
                          ),
                          Expanded(
                            flex: ((1 - myPercent) * 100).toInt().clamp(1, 99),
                            child: Container(color: AppColors.accentPeach.withValues(alpha: 0.2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tú: ${(myPercent * 100).toInt()}%', 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('Tu pareja: ${((1 - myPercent) * 100).toInt()}%', 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Quick Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickAction(
              icon: Icons.sync_alt_rounded,
              label: 'Saldar',
              color: AppColors.accentPeach,
              onTap: isNegative ? () {
                HapticFeedback.selectionClick();
                _confirmSettleDebt(householdId, currentUserId!,
                    partnerBal.userId, myBalance.abs());
              } : null,
            ),
            _buildQuickAction(
              icon: Icons.insights_rounded,
              label: 'Gráficos',
              color: AppColors.accentBlue,
              onTap: () {
                HapticFeedback.selectionClick();
                _showChartsSheet();
              },
            ),
            _buildQuickAction(
              icon: Icons.savings_rounded,
              label: 'Ahorro',
              color: AppColors.accentTeal,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  AppTransitions.slideHorizontal(page: const SavingsScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalSummary(List<ExpenseModel> personalExpenses) {
    final totalIncomes = personalExpenses.where((e) => e.isIncome).fold<double>(0, (sum, e) => sum + e.amount);
    final totalExpenses = personalExpenses.where((e) => e.isExpense).fold<double>(0, (sum, e) => sum + e.amount);
    final balance = totalIncomes - totalExpenses;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BALANCE MENSUAL',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mis Finanzas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (balance >= 0 ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  balance >= 0 ? 'Superávit' : 'Déficit',
                  style: TextStyle(
                    color: balance >= 0 ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ingresos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalIncomes.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.success, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gastos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Restante', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700)),
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: balance >= 0 ? AppColors.success : AppColors.error,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
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
            'Comienza a registrar tus movimientos para ver el balance.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showExpenseSheet([ExpenseModel? expense]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormSheet(
        expense: expense,
      ),
    );
  }

  void _showChartsSheet() {
    final expensesAsync = ref.read(expensesAndBalancesProvider);
    expensesAsync.whenData((data) {
      final allExpenses = data['expenses'] as List<ExpenseModel>;
      final expenses = allExpenses.where((e) => e.isExpense).toList();

      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay gastos para mostrar gráficos'),
            backgroundColor: AppColors.info,
          ),
        );
        return;
      }

      final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      
      final categoryTotals = <String, double>{};
      for (final expense in expenses) {
        final category = expense.category ?? 'other';
        categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
      }

      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.insights_rounded, color: AppColors.accentBlue),
                      SizedBox(width: 12),
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Resumen de movimientos compartidos',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentBlue.withValues(alpha: 0.1),
                          AppColors.accentBlue.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Gastado',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalExpenses.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentBlue,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${expenses.length} ${expenses.length == 1 ? 'gasto' : 'gastos'}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Por Categoría',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sortedCategories.map((entry) {
                    final percentage = (entry.value / totalExpenses * 100);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.getCategoryColor(entry.key).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        AppColors.categoryIcons[entry.key] ?? '📦',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppColors.categoryNames[entry.key] ?? 'Otro',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.getCategoryColor(entry.key),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmSettleDebt(String householdId, String debtorId,
      String creditorId, double amount) async {
    final membersAsync = ref.read(householdMembersProvider);
    String? creditorAlias;
    String creditorName = 'tu pareja';

    if (membersAsync is AsyncData<List<MemberModel>>) {
      final creditor = membersAsync.value.where((m) => m.userId == creditorId).firstOrNull;
      if (creditor != null) {
        creditorAlias = creditor.mercadopagoAlias;
        creditorName = creditor.fullName ?? 'tu pareja';
      }
    }

    final String? method = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldar Deuda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Debes \$${amount.toStringAsFixed(2)} a $creditorName.',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            
            // Option 1: Direct Transfer (0% Commission)
            if (creditorAlias != null && creditorAlias.isNotEmpty)
              _settleOption(
                context,
                icon: Icons.account_balance_rounded,
                title: 'Transferencia Directa',
                subtitle: 'Alias: $creditorAlias (0% comisión)',
                color: Colors.teal,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: creditorAlias!));
                  Navigator.pop(context, 'transfer');
                },
              ),
            
            // Option 2: MP Payment Link (Automatic)
            _settleOption(
              context,
              icon: Icons.bolt_rounded,
              title: 'Pagar con Mercado Pago',
              subtitle: 'Automático y seguro (puede aplicar comisión)',
              color: Colors.blue,
              onTap: () => Navigator.pop(context, 'mp_link'),
            ),
            
            // Option 3: Manual Record
            _settleOption(
              context,
              icon: Icons.edit_note_rounded,
              title: 'Anotar como pagado',
              subtitle: 'Si ya le pagaste por fuera o en efectivo',
              color: AppColors.textMuted,
              onTap: () => Navigator.pop(context, 'manual'),
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );

    if (method == null) return;

    if (method == 'transfer') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Alias copiado. Realiza la transferencia y luego anota el pago.')),
      );
      // We don't settle automatically here, user should probably mark as manual after transfer
      return;
    }

    if (method == 'mp_link') {
      try {
        final mpService = MercadoPagoService();
        final url = await mpService.createPaymentPreference(
          title: 'Saldar deuda en HomeSync',
          amount: amount,
          externalReference: 'settle|$householdId|$debtorId|$creditorId|$amount',
        );
        
        if (url != null) {
          await mpService.launchCheckout(url);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
      return;
    }

    // Manual or post-transfer
    try {
      await ref.read(expenseRepositoryProvider).settleDebt(
            householdId: householdId,
            toUserId: creditorId,
            amount: amount,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Deuda saldada correctamente'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  Widget _buildMPSuggestions() {
    final movementsAsync = ref.watch(mercadopagoMovementsProvider);

    return movementsAsync.when(
      data: (movements) {
        if (movements.isEmpty) return const SizedBox.shrink();

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
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sugerencias de Mercado Pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.invalidate(mercadopagoMovementsProvider),
                  child: const Text('Actualizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: movements.length,
                itemBuilder: (context, index) {
                  final move = movements[index];
                  final amount = (move['amount'] as num).toDouble();
                  final title = move['title'] ?? (move['type'] == 'income' ? 'Ingreso MP' : 'Gasto MP');
                  final bool isIncome = move['type'] == 'income';
                  final Color themeColor = isIncome ? AppColors.success : Colors.blue;
                  
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeColor.withValues(alpha: 0.08),
                          themeColor.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: themeColor.withValues(alpha: 0.15)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Icon(isIncome ? Icons.payments_rounded : Icons.shopping_bag_outlined, 
                              size: 80, color: themeColor.withValues(alpha: 0.05)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isIncome ? '+' : ''}\$${amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: themeColor,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showExpenseSheet(
                                            ExpenseModel(
                                              id: '',
                                              title: title,
                                              amount: amount,
                                              householdId: '',
                                              paidBy: '',
                                              paidAt: DateTime.now(),
                                              createdAt: DateTime.now(),
                                              isShared: false, // Incomes are personal by default
                                              type: isIncome ? 'income' : 'expense',
                                              splitType: isIncome ? 'personal' : 'equal',
                                              category: _suggestCategory(title),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: themeColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(isIncome ? 'Registrar' : 'Compartir',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                                        onPressed: () {
                                          // Local dismiss logic could be added here
                                        },
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
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _suggestCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('sueldo') || t.contains('haberes') || t.contains('transferencia recibida') || t.contains('cobro')) return 'income';
    if (t.contains('super') || t.contains('coto') || t.contains('carrefour') || t.contains('market')) return 'supermarket';
    if (t.contains('restaurante') || t.contains('café') || t.contains('bar') || t.contains('comida')) return 'restaurants';
    if (t.contains('taxi') || t.contains('uber') || t.contains('cabify') || t.contains('nafta') || t.contains('combustible')) return 'transport';
    if (t.contains('netflix') || t.contains('spotify') || t.contains('cine') || t.contains('teatro')) return 'entertainment';
    if (t.contains('luz') || t.contains('agua') || t.contains('gas') || t.contains('internet')) return 'utilities';
    if (t.contains('farmacia') || t.contains('médico') || t.contains('hospital')) return 'health';
    return 'other';
  }

  Widget _settleOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    final amount = expense.amount;
    final title = expense.title;
    final category = expense.category ?? 'other';
    final categoryColor = AppColors.getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                AppColors.categoryIcons[category] ?? '📦',
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${AppColors.categoryNames[category] ?? 'Otro'} · ${_formatDate(expense.paidAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.isIncome ? '+' : ''}\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: expense.isIncome ? AppColors.success : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (expense.isShared)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DIVIDIDO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentTeal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day} ${AppColors.getMonthName(dt.month)}';
    } catch (e) {
      return '';
    }
  }
}
