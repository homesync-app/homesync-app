import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_scroll_physics.dart';
import 'package:homesync_client/core/utils/date_extensions.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_swipe_to_delete.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';
import 'package:homesync_client/shared/widgets/expressive/expressive.dart';
import 'package:intl/intl.dart';

import '../providers/estimated_income_provider.dart';
import '../widgets/budget_section.dart';
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
              physics: const AppSnappyPagePhysics(),
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
    final t = AppLocalizations.of(context);
    return AppSegmentedTabs(
      controller: _tabController,
      labels: [
        t.expensesTabMovements,
        t.expensesTabRecurring,
        t.expensesTabGoals,
      ],
      padding: const EdgeInsets.all(6),
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final t = AppLocalizations.of(context);
        String label = t.expensesFabMovement;
        VoidCallback onPressed = () => _showExpenseSheet();

        if (_tabController.index == 1) {
          final isPremium = ref.watch(premiumProvider).value ?? false;
          if (!isPremium) return const SizedBox.shrink();
          label = t.expensesFabNewSubscription;
          onPressed = () => _showTemplateForm(context);
        } else if (_tabController.index == 2) {
          return const SizedBox.shrink();
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
      // Fade también arriba: el contenido se disuelve al pasar bajo las tabs
      // en vez de cortarse seco (tip flutterpro "fade behind").
      child: EdgeFade(
        extent: 0.035,
        child: CustomScrollView(
          // PrimaryScrollController del tab Finanzas (re-tap sube al tope).
          primary: true,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // 1. SUMMARY WIDGET WITH PROJECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppInsets.screenHorizontal,
                  10,
                  AppInsets.screenHorizontal,
                  0,
                ),
                child: summaryAsync.when(
                  loading: () => _buildSummaryLoadingCard(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (summary) {
                    // v2 RPC (posición neta, month-scoped): income/expense son
                    // del mes y expense ya es MI parte de los compartidos.
                    // Settlements quedan fuera (saldan deuda ya devengada).
                    final realIncome =
                        (summary['income'] as num?)?.toDouble() ?? 0.0;
                    final expense =
                        (summary['expense'] as num?)?.toDouble() ?? 0.0;
                    final rpcBalance =
                        (summary['balance'] as num?)?.toDouble() ?? 0.0;

                    // Ingreso estimado: configuración local (SharedPreferences),
                    // usada solo cuando no hay ingresos reales este mes. La
                    // v1 leía un flag `is_income_estimated` que la RPC nunca
                    // devolvió, así que esta rama estaba muerta.
                    final estimated = estimatedIncomeAsync.value;
                    final isIncomeEstimated =
                        realIncome <= 0 && (estimated?.isSet ?? false);
                    final displayIncome =
                        isIncomeEstimated ? estimated!.amount : realIncome;

                    // rpcBalance = ledger + realIncome - expense; si el ingreso
                    // es estimado, intercambiamos el real por el estimado.
                    final balance = rpcBalance - realIncome + displayIncome;

                    return projectionAsync.when(
                      loading: () => _buildSummaryLoadingCard(),
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
                        paidThisMonth: proj.spent,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. PRESUPUESTOS POR CATEGORÍA (premium; teaser para free)
            const SliverToBoxAdapter(child: BudgetSection()),

            // 3. FEED & FUTURE EXPENSES
            feedAsync.when(
              loading: () => _buildFeedLoadingSliver(),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Error: $e')),
              ),
              data: (feedItems) {
                final filteredItems =
                    feedItems.where(_shouldShowFeedItem).toList();
                final sortedItems = List<FeedItemModel>.from(filteredItems)
                  ..sort((a, b) => b.date.compareTo(a.date));

                final expenses = ref.watch(expenseControllerProvider).value ??
                    const <ExpenseModel>[];
                final expenseMap = {for (final e in expenses) e.id: e};

                return SliverMainAxisGroup(
                  slivers: [
                    if (sortedItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppInsets.screenHorizontal,
                            AppSpacing.lg,
                            AppInsets.screenHorizontal,
                            AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.textSecondary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.xs),
                                ),
                                child: Icon(
                                  Icons.history_rounded,
                                  size: 12,
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)
                                    .expensesActivityRecentEyebrow,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: theme.textSecondary
                                      .withValues(alpha: 0.7),
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
                                    _formatFeedDate(
                                      sortedItems[index - 1].date,
                                    );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFirstOfDate)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppInsets.screenHorizontal,
                                      AppSpacing.lg,
                                      AppInsets.screenHorizontal,
                                      AppSpacing.sm,
                                    ),
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
                                    horizontal: AppInsets.screenHorizontal,
                                    vertical: 6,
                                  ),
                                  child: _buildFeedItemCard(item, expenseMap)
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
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl,
                          ),
                          child: _buildEmptyState(
                            AppLocalizations.of(context).expensesActivityEmpty,
                            actionLabel:
                                AppLocalizations.of(context).expensesEmptyCta,
                            onAction: () => _showExpenseSheet(),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFeedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);
    final t = AppLocalizations.of(context);

    if (checkDate == today) {
      return t.expensesDateToday;
    } else if (checkDate == yesterday) {
      return t.expensesDateYesterday;
    } else if (checkDate == tomorrow) {
      return t.expensesDateTomorrow;
    } else {
      final localeTag = Localizations.localeOf(context).toString();
      return DateFormat('d MMMM y', localeTag).format(date).toUpperCase();
    }
  }

  String _compactMovementTitle(
    String title, {
    String? titleKey,
    String? category,
    String? transactionType,
  }) {
    return localizedFinanceTitle(
      AppLocalizations.of(context),
      title: title,
      titleKey: titleKey,
      category: category,
      transactionType: transactionType,
    );
  }

  List<FeedItemModel> _effectiveFeedForBreakdowns() {
    final feed = ref.read(combinedFeedControllerProvider).value ??
        const <FeedItemModel>[];
    if (feed.isNotEmpty) return feed;

    final expenses =
        ref.read(expenseControllerProvider).value ?? const <ExpenseModel>[];
    return expenses
        .map(
          (e) => FeedItemModel(
            recordType: 'expense',
            transactionType: e.type,
            id: e.id,
            title: e.title,
            titleKey: e.titleKey,
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
        ref.read(monthlyPendingPlannedExpensesProvider).value;
    if (monthlyPending != null) return monthlyPending;

    final now = DateTime.now();
    return _effectiveFeedForBreakdowns()
        .where(
          (item) =>
              item.isPlanned &&
              item.status == 'pending' &&
              item.date.isSameMonth(now),
        )
        .toList();
  }

  ExpenseModel _expenseFromFeedItem(
    FeedItemModel item, {
    double? amountOverride,
  }) {
    if (amountOverride == null) {
      final expenses = ref.read(expenseControllerProvider).value;
      final matches = expenses?.where((e) => e.id == item.id).toList() ??
          const <ExpenseModel>[];
      if (matches.isNotEmpty) return matches.first;
    }

    return ExpenseModel(
      id: item.id,
      title: item.title,
      titleKey: item.titleKey,
      amount: amountOverride ?? item.amount,
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

  List<String> _splitMemberIds() {
    final members = ref.read(householdMembersProvider).value;
    if (members == null || members.isEmpty) return const [];
    // Rent/bills split between adults only — kids and teens don't share
    // household expenses (mirrors pay_planned_expense's split-member filter).
    // Friends/roommates households have no "kids", everyone splits.
    final householdType =
        ref.read(currentHouseholdProvider).value?.householdType.toLowerCase();
    final isFriendsOrRoommates =
        householdType == 'friends' || householdType == 'roommates';
    final splitMembers =
        isFriendsOrRoommates ? members : members.where((m) => m.isAdult);
    return splitMembers.map((m) => m.userId).toList(growable: false);
  }

  /// Parte del usuario en un movimiento (feed o planificado): personal/gift
  /// cuentan completos solo para su payer; el resto respeta el ratio anclado
  /// del hogar cuando reparten exactamente dos (mismo criterio que
  /// ExpenseSplitBuilder) y partes iguales si no. Quien no reparte (p. ej.
  /// un teen en familia) no tiene parte.
  double _memberShareAmount(FeedItemModel item, String? userId) {
    if (userId == null) return 0.0;

    final splitType = (item.splitType ?? 'equal').toLowerCase();
    if (splitType == SplitType.personal.name || splitType == 'gift') {
      return item.payerId == userId ? item.amount : 0.0;
    }

    final memberIds = _splitMemberIds();
    // Miembros aún no cargados: mitades, la aproximación menos engañosa.
    if (memberIds.isEmpty) return item.amount / 2;
    if (!memberIds.contains(userId)) return 0.0;

    final household = ref.read(currentHouseholdProvider).value;
    final ratio = household?.defaultSplitRatio ?? 0.5;
    final anchorId = household?.splitRatioAnchorId;
    if (memberIds.length == 2 &&
        ratio != 0.5 &&
        anchorId != null &&
        memberIds.contains(anchorId)) {
      return item.amount * (userId == anchorId ? ratio : 1.0 - ratio);
    }

    return item.amount / memberIds.length;
  }

  /// Intercala el divisor vertical del pie entre celdas y las expande.
  List<Widget> _withFooterDividers(AppThemeColors theme, List<Widget> cells) {
    final children = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            height: 28,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: theme.border.withValues(alpha: 0.62),
          ),
        );
      }
      children.add(Expanded(child: cells[i]));
    }
    return children;
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
      borderRadius: BorderRadius.circular(AppRadii.md),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              value: amount.toDouble(),
              locale: ref.watch(currencyProvider).locale,
              prefix: ref.watch(currencyProvider).inputPrefix(),
              style: TextStyle(
                color: isBold ? theme.textPrimary : color,
                fontSize: isBold ? 20 : 17,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: isBold ? -0.7 : -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Recurrentes Tab (delegated to RecurrentesTab widget) ---

  Widget _buildSummaryLoadingCard() {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: theme.border.withValues(alpha: 0.62)),
        boxShadow: theme.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading(height: 14, width: 120, borderRadius: 10),
              Spacer(),
              ShimmerLoading(height: 36, width: 36, borderRadius: 18),
            ],
          ),
          SizedBox(height: 18),
          ShimmerLoading(height: 42, width: 180, borderRadius: 14),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: ShimmerLoading(height: 58, borderRadius: 18)),
              SizedBox(width: 12),
              Expanded(child: ShimmerLoading(height: 58, borderRadius: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedLoadingSliver() {
    final theme = context.theme;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      sliver: SliverList.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.border.withValues(alpha: 0.52)),
            boxShadow: theme.cardShadow,
          ),
          child: const Row(
            children: [
              ShimmerLoading(height: 42, width: 42, borderRadius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(height: 14, width: 160, borderRadius: 10),
                    SizedBox(height: 8),
                    ShimmerLoading(height: 12, width: 104, borderRadius: 10),
                  ],
                ),
              ),
              SizedBox(width: 12),
              ShimmerLoading(height: 18, width: 72, borderRadius: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedSummaryCard(
    num balance,
    num income,
    num expense,
    num projectedPending, {
    bool isIncomeEstimated = false,
    num? paidThisMonth,
  }) {
    final projectedBalance = balance - projectedPending;
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final hasIncome = income > 0;
    final hasPending = projectedPending > 0;
    // In the "previsto del mes" view (no personal income recorded) "Pagado"
    // must mirror "Pendiente": the household total paid this month, not just
    // what the current user paid. `paidThisMonth` carries that value.
    final paid = paidThisMonth ?? expense;
    final mainLabel = hasIncome
        ? t.expensesSummaryMainBalance
        : hasPending
            ? t.expensesSummaryMainProjected
            : t.expensesSummaryMainExpenses;
    final mainAmount = hasIncome
        ? balance
        : hasPending
            ? paid + projectedPending
            : paid;

    // Month context on every mode: right after a month rollover the card can
    // legitimately show $0 while last month's movements are still visible
    // below — without the month name that reads as a bug, not as "July just
    // started".
    final localeTag = Localizations.localeOf(context).toString();
    final rawMonth = DateFormat.MMMM(localeTag).format(DateTime.now());
    final monthName = rawMonth.isEmpty
        ? rawMonth
        : rawMonth[0].toUpperCase() + rawMonth.substring(1);
    final isSimpleExpenseMode = !hasIncome && !hasPending;
    final showZeroState = isSimpleExpenseMode && mainAmount == 0;
    final dailyAvg = isSimpleExpenseMode && mainAmount > 0
        ? (mainAmount / math.max(DateTime.now().day, 1)).round()
        : null;
    final currency = ref.watch(currencyProvider);

    // La otra mitad de la posición neta: la deuda viva entre miembros por los
    // compartidos ya pagados (mismo dato que el widget de división del
    // Inicio). Sin esto, el balance neto parece no cerrar con la caja.
    final isSharedEconomy =
        ref.watch(currentHouseholdProvider).value?.financeMode == 'shared';
    final currentUserId = ref.watch(currentUserIdProvider);
    final myDebtBalance = ref
        .watch(expenseBalancesProvider)
        .value
        ?.where((b) => b.userId == currentUserId)
        .firstOrNull
        ?.balance;
    final showDebtChip =
        !isSharedEconomy && myDebtBalance != null && myDebtBalance.abs() > 10;

    // Surface base instead of the hero gradient: at this size the full-bleed
    // cream gradient washed the whole screen into one tone. The white card
    // lets the colored stat tiles, the month pill and the amount carry the
    // contrast.
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: theme.border.withValues(alpha: 0.62)),
        boxShadow: theme.cardShadow,
      ),
      child: Stack(
        children: [
          // Siluetas expresivas asomando desde las esquinas (patrón player
          // card de bunpod): mismas posiciones que los viejos orbes, pero con
          // formas M3E que le dan intención al recorte.
          Positioned(
            right: -42,
            top: -42,
            child: Container(
              width: 128,
              height: 128,
              decoration: ShapeDecoration(
                color: theme.primary.withValues(alpha: 0.07),
                shape: MaterialShapeBorder(shape: AppShapes.sunny),
              ),
            ),
          ),
          Positioned(
            right: 26,
            bottom: -56,
            child: Container(
              width: 96,
              height: 96,
              decoration: ShapeDecoration(
                color: theme.primary.withValues(alpha: 0.045),
                shape: MaterialShapeBorder(shape: AppShapes.clover),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mainLabel,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: theme.primary.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Text(
                            monthName.toUpperCase(),
                            style: TextStyle(
                              color: theme.primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (showZeroState)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Text(
                          AppLocalizations.of(context).homeSoloSpentEmpty,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      )
                    else
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedAmount(
                          value: mainAmount.abs().toDouble(),
                          locale: currency.locale,
                          prefix: mainAmount < 0
                              ? '- ${currency.inputPrefix()}'
                              : currency.inputPrefix(),
                          style: TextStyle(
                            color: mainAmount < 0
                                ? AppColors.error
                                : theme.textPrimary,
                            fontSize: 38,
                            fontWeight: AppTypography.hero,
                            letterSpacing: AppTypography.heroLetterSpacing,
                          ),
                        ),
                      ),
                    if (dailyAvg != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).expensesDailyAvg(
                          '${currency.inputPrefix()}${NumberFormat.decimalPattern(currency.locale).format(dailyAvg)}',
                        ),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (hasIncome || hasPending) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPremiumStatTile(
                              hasIncome
                                  ? (isIncomeEstimated
                                      ? t.expensesStatTileEstimatedIncome
                                      : t.expensesStatTileIncomes)
                                  : t.expensesStatTilePaid,
                              hasIncome ? income : paid,
                              hasIncome ? AppColors.success : AppColors.primary,
                              hasIncome
                                  ? (isIncomeEstimated
                                      ? Icons.edit_rounded
                                      : Icons.trending_up_rounded)
                                  : Icons.receipt_long_rounded,
                              onTap: hasIncome
                                  ? (isIncomeEstimated
                                      ? () => EstimatedIncomeSheet.show(context)
                                      : () => _showIncomeBreakdownSheet(income))
                                  : () => _showExpensesBreakdownSheet(
                                        paid,
                                        cashFlow: true,
                                      ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPremiumStatTile(
                              hasIncome
                                  ? t.expensesStatTileExpenses
                                  : t.expensesStatTilePending,
                              hasIncome ? expense : projectedPending,
                              hasIncome
                                  ? AppColors.primary
                                  : AppColors.accentTeal,
                              hasIncome
                                  ? Icons.trending_down_rounded
                                  : Icons.event_available_rounded,
                              onTap: hasIncome
                                  ? () => _showExpensesBreakdownSheet(
                                        expense,
                                        cashFlow: false,
                                      )
                                  : () => _showPendingBreakdownSheet(
                                        projectedPending,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (hasIncome || showDebtChip)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surfaceVariant.withValues(alpha: 0.38),
                    border: Border(
                      top: BorderSide(
                        color: theme.border.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  child: Row(
                    children: _withFooterDividers(theme, [
                      // Deuda viva entre miembros: dato del mes, no accion —
                      // saldar solo lo inicia quien debe (flujo del Home).
                      if (showDebtChip)
                        _buildProjectionStat(
                          myDebtBalance > 0
                              ? t.expensesProjectionOwedToYou
                              : t.expensesProjectionYouOwe,
                          myDebtBalance.abs(),
                          myDebtBalance > 0 ? AppColors.sage : theme.primary,
                        ),
                      if (hasIncome)
                        _buildProjectionStat(
                          t.expensesProjectionPendingShare,
                          projectedPending,
                          theme.textSecondary,
                          onTap: () =>
                              _showPendingBreakdownSheet(projectedPending),
                        ),
                      if (hasIncome)
                        _buildProjectionStat(
                          t.expensesProjectionEstimated,
                          projectedBalance,
                          theme.textPrimary,
                          isBold: true,
                          onTap: () => _showProjectionBreakdownSheet(
                            balance,
                            projectedPending,
                            projectedBalance,
                          ),
                        ),
                    ]),
                  ),
                ),
            ],
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
    final isSharedEconomy =
        ref.read(currentHouseholdProvider).value?.financeMode == 'shared';

    final pendingItems = pendingFeed
        .where(
          (item) =>
              item.transactionType == 'expense' &&
              (isSharedEconomy || _memberShareAmount(item, userId) > 0),
        )
        .toList();
    final t = AppLocalizations.of(context);

    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
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
                    t.expensesProjectionTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.expensesProjectionSubtitle,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Equation Section
                  _buildBreakdownRow(
                    t.expensesProjectionRowBalance,
                    balance,
                    AppColors.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  _buildBreakdownRow(
                    t.expensesProjectionPendingShare,
                    -pendingTotal,
                    AppColors.primary,
                  ),
                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  _buildBreakdownRow(
                    t.expensesProjectionRowEstimated,
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
                            borderRadius: BorderRadius.circular(AppRadii.xs),
                          ),
                          child: const Icon(
                            Icons.pending_actions_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          t.expensesPendingDetailsEyebrow,
                          style: const TextStyle(
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
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
                              _formatCurrency(
                                isSharedEconomy
                                    ? item.amount
                                    : _memberShareAmount(item, userId),
                              ),
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
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context).expensesGotIt,
                        style: const TextStyle(
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
          _formatCurrency(amount, signed: true),
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
                      _formatCurrency(amount),
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
    final isSharedEconomy =
        ref.read(currentHouseholdProvider).value?.financeMode == 'shared';

    // Solo type='income': el total viene del resumen v2, que no cuenta
    // liquidaciones — listarlas acá rompía la suma del desglose. En economía
    // dividida el total es MI parte (personales míos + share de compartidos),
    // así que las filas se ajustan con el mismo criterio.
    final items = feed
        .where(
          (item) =>
              item.isRealExpense &&
              item.date.isSameMonth(now) &&
              item.transactionType == 'income' &&
              (isSharedEconomy || _memberShareAmount(item, userId) > 0),
        )
        .map(
          (item) => _expenseFromFeedItem(
            item,
            amountOverride:
                isSharedEconomy ? null : _memberShareAmount(item, userId),
          ),
        )
        .toList();

    final t = AppLocalizations.of(context);
    _showGenericBreakdownSheet(
      t.expensesIncomeBreakdownTitle,
      t.expensesIncomeBreakdownSubtitle,
      total,
      items,
      AppColors.success,
    );
  }

  void _showExpensesBreakdownSheet(num total, {required bool cashFlow}) {
    final feed = _effectiveFeedForBreakdowns();
    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();
    final isSharedEconomy =
        ref.read(currentHouseholdProvider).value?.financeMode == 'shared';

    // Solo type='expense': las liquidaciones saldan deuda ya devengada y los
    // totales (resumen v2 y proyección) las excluyen. Dos modos:
    //  - cashFlow ("Pagado"): plata que salió de la billetera — en economía
    //    dividida solo lo que YO pagué, a monto completo;
    //  - share ("Gastos"): MI parte del mes — compartidos (los pague quien
    //    los pague) a valor share + mis personales completos.
    // En economía integrada ambos coinciden: todo el hogar a monto completo.
    final monthExpenses = feed.where(
      (item) =>
          item.isRealExpense &&
          item.date.isSameMonth(now) &&
          item.transactionType == 'expense',
    );

    final List<ExpenseModel> items;
    if (isSharedEconomy) {
      items = monthExpenses.map(_expenseFromFeedItem).toList();
    } else if (cashFlow) {
      items = monthExpenses
          .where((item) => item.payerId == userId)
          .map(_expenseFromFeedItem)
          .toList();
    } else {
      items = monthExpenses
          .where((item) => _memberShareAmount(item, userId) > 0)
          .map(
            (item) => _expenseFromFeedItem(
              item,
              amountOverride: _memberShareAmount(item, userId),
            ),
          )
          .toList();
    }

    final t = AppLocalizations.of(context);
    _showGenericBreakdownSheet(
      t.expensesExpensesBreakdownTitle,
      t.expensesExpensesBreakdownSubtitle,
      total,
      items,
      AppColors.primary,
    );
  }

  void _showPendingBreakdownSheet(num total) {
    final pendingFeed = _effectiveMonthlyPendingForBreakdowns();
    final userId = ref.read(currentUserIdProvider);
    // Igual que la proyección: en economía integrada el pendiente cuenta a
    // monto completo para todo el hogar; en dividida, solo mi share. Los
    // planificados de ingreso no son gasto pendiente.
    final isSharedEconomy =
        ref.read(currentHouseholdProvider).value?.financeMode == 'shared';

    final items = pendingFeed
        .where(
          (item) =>
              item.transactionType == 'expense' &&
              (isSharedEconomy || _memberShareAmount(item, userId) > 0),
        )
        .toList();

    final t = AppLocalizations.of(context);
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBreakdownBaseContainer(
        title: t.expensesPendingBreakdownTitle,
        subtitle: t.expensesPendingBreakdownSubtitle,
        total: total,
        totalLabel: t.expensesPendingBreakdownTotalLabel,
        accentColor: AppColors.textSecondary,
        content: Column(
          children: items
              .map(
                (item) => _buildMovementDetailRow(
                  title: _compactMovementTitle(
                    item.title,
                    titleKey: item.titleKey,
                    category: item.category,
                    transactionType: item.transactionType,
                  ),
                  amount: isSharedEconomy
                      ? item.amount
                      : _memberShareAmount(item, userId),
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
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBreakdownBaseContainer(
        title: title,
        subtitle: subtitle,
        total: total,
        totalLabel: AppLocalizations.of(context).expensesBreakdownTotalLabel,
        accentColor: accentColor,
        content: Column(
          children: items.isEmpty
              ? [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Text(
                      AppLocalizations.of(context).expensesBreakdownEmpty,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ]
              : items
                  .map(
                    (e) => _buildMovementDetailRow(
                      title: _compactMovementTitle(
                        e.title,
                        titleKey: e.titleKey,
                        category: e.category,
                        transactionType: e.type,
                      ),
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadii.xl),
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
                        _formatCurrency(total),
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
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Icon(
                        Icons.list_alt_rounded,
                        size: 12,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)
                          .expensesBreakdownMovementsEyebrow,
                      style: const TextStyle(
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
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).expensesGotIt,
                      style: const TextStyle(
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadii.sm),
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
                  DateFormat(
                    'd MMM',
                    Localizations.localeOf(context).toString(),
                  ).format(date),
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
            _formatCurrency(amount),
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

  Widget _buildFeedItemCard(
    FeedItemModel item,
    Map<String, ExpenseModel> expenseMap,
  ) {
    if (item.isRealExpense) {
      final expense = expenseMap[item.id] ??
          ExpenseModel(
            id: item.id,
            title: item.title,
            titleKey: item.titleKey,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              categoryIcon,
              size: 23,
              color: categoryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _compactMovementTitle(
                    item.title,
                    titleKey: item.titleKey,
                    category: item.category,
                    transactionType: item.transactionType,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: theme.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.08,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildPlannedStatusBadge(item),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _formatCurrency(item.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: theme.textPrimary.withValues(
                      alpha: theme.isDarkMode ? 0.92 : 0.72,
                    ),
                    letterSpacing: -0.55,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => ref
                        .read(combinedFeedControllerProvider.notifier)
                        .discardPlannedExpense(item.id),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.textMuted,
                      minimumSize: const Size(48, 30),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context).expensesPlannedSkip,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () async {
                      final result =
                          await PlannedExpensePaymentSheet.show(context, item);
                      if (!mounted ||
                          result == null ||
                          result['success'] != true) {
                        return;
                      }
                      AppSnackBar.show(
                        context,
                        message: AppLocalizations.of(context)
                            .expensesPlannedPaymentSnack(
                          item.transactionType,
                          result['title'].toString(),
                        ),
                        type: AppSnackBarType.success,
                        duration: const Duration(milliseconds: 2200),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      minimumSize: const Size(66, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .expensesPlannedPay(item.transactionType),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
    final t = AppLocalizations.of(context);

    String label = t.expensesPlannedBadgeUpcoming;
    Color badgeColor = AppColors.textMuted;
    IconData icon = Icons.access_time_rounded;

    if (diff < 0) {
      label = t.expensesPlannedBadgePending;
      badgeColor = AppColors.accentRed;
      icon = Icons.priority_high_rounded;
    } else if (diff == 0) {
      label = t.expensesPlannedBadgeDueToday;
      badgeColor = AppColors.accentOrange;
      icon = Icons.today_rounded;
    } else if (diff == 1) {
      label = t.expensesPlannedBadgeTomorrow;
      badgeColor = AppColors.accentGold;
      icon = Icons.notification_important_rounded;
    } else if (diff <= 2) {
      label = t.expensesPlannedBadgeSoon;
      badgeColor = AppColors.accentGold;
      icon = Icons.notification_important_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: badgeColor.withValues(alpha: 0.78)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
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

    return AppSwipeToDelete(
      dismissibleKey: Key(expense.id),
      borderRadius: 22,
      confirm: () async {
        final t = AppLocalizations.of(context);
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.expensesDeleteDialogTitle),
            content: Text(t.expensesDeleteDialogBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(t.editTaskDeleteConfirm),
              ),
            ],
          ),
        );
      },
      onDeleted: () {
        ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
        AppSnackBar.show(
          context,
          message: AppLocalizations.of(context).expensesDeletedSnack,
          type: AppSnackBarType.success,
          duration: const Duration(milliseconds: 1500),
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
                        titleKey: expense.titleKey,
                        category: expense.category,
                        transactionType: expense.type,
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
                          DateFormat(
                            'd MMM',
                            Localizations.localeOf(context).toString(),
                          ).format(expense.paidAt),
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
                    _formatCurrency(expense.amount, signed: isIncome),
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
                        ? AppLocalizations.of(context).expensesTypeBadgeGift
                        : (isShared
                            ? AppLocalizations.of(context)
                                .expensesTypeBadgeShared
                            : AppLocalizations.of(context)
                                .expensesTypeBadgePersonal),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(
          alpha: theme.isDarkMode ? 0.12 : 0.04,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: AppColors.accentBlue.withValues(
            alpha: theme.isDarkMode ? 0.24 : 0.1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
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
                Text(
                  AppLocalizations.of(context).expensesSettlementCardTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.accentBlue,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)
                      .expensesSettlementCardBody(expense.payerDisplayName),
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
            _formatCurrency(expense.amount),
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

  String _formatCurrency(num amount, {bool signed = false}) {
    return ref.read(currencyProvider).format(amount, signed: signed);
  }

  Widget _buildEmptyState(
    String message, {
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = context.theme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.82),
            ).animatePulse(),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                height: 1.18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Text(
              subtitle ??
                  AppLocalizations.of(context).expensesEmptyDefaultSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
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
