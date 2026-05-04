import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';
import 'package:intl/intl.dart';

class FamilyFinanceSection extends ConsumerWidget {
  final HouseholdCapabilities caps;
  final MemberModel? currentMember;

  const FamilyFinanceSection({
    super.key,
    required this.caps,
    required this.currentMember,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final feedAsync = ref.watch(combinedFeedControllerProvider);
    final pendingAsync = ref.watch(monthlyPendingPlannedExpensesProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);

    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final isChild = currentMember?.isChild ?? false;
    final isTeen = currentMember?.isTeen ?? false;
    final adultMembers = members.where((m) => m.isAdult).toList();
    final shouldShowSection =
        currentMember != null && !isChild && !isTeen && adultMembers.length > 1;
    const sectionTitle = 'Finanzas familiares';

    final isLoading =
        membersAsync.isLoading || feedAsync.isLoading || pendingAsync.isLoading;
    final hasError = membersAsync.hasError || feedAsync.hasError;

    Widget child;
    if (!isLoading && !shouldShowSection) {
      child = const SizedBox.shrink(key: ValueKey('finance-hidden'));
    } else if (hasError) {
      child = Column(
        key: const ValueKey('finance-error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceHeader(theme, sectionTitle, ref, currentMember),
          const SizedBox(height: 12),
          _buildFinanceEmptyState(
            theme,
            'No pudimos cargar las finanzas del hogar por ahora.',
          ),
          const SizedBox(height: 28),
        ],
      );
    } else if (isLoading) {
      child = Column(
        key: const ValueKey('finance-loading'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeaderLoading(),
          const SizedBox(height: 12),
          _buildFinanceLoadingState(theme),
          const SizedBox(height: 28),
        ],
      );
    } else {
      final feed = feedAsync.valueOrNull ?? const <FeedItemModel>[];
      final pending = pendingAsync.valueOrNull ?? const <FeedItemModel>[];

      child = Column(
        key: ValueKey('finance-ready-${adultMembers.length}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceHeader(theme, sectionTitle, ref, currentMember),
          const SizedBox(height: 12),
          _buildFinanceReadyState(
            theme,
            feed: feed,
            pending: pending,
          ),
          const SizedBox(height: 28),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget _buildFinanceHeader(
    AppThemeColors theme,
    String title,
    WidgetRef ref,
    MemberModel? currentMember,
  ) {
    final caps = ref.watch(householdCapabilitiesProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {
            final index = indexForMainTab(
              caps,
              MainTab.expenses,
              currentMember: currentMember,
            );
            if (index >= 0) {
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            }
          },
          child: const Text('Ver todos'),
        ),
      ],
    );
  }

  static Widget _buildFinanceReadyState(
    AppThemeColors theme, {
    required List<FeedItemModel> feed,
    required List<FeedItemModel> pending,
  }) {
    final now = DateTime.now();
    final monthItems = feed.where((item) {
      return item.isRealExpense &&
          item.date.month == now.month &&
          item.date.year == now.year &&
          !item.isSettlement;
    }).toList();
    final spent = monthItems
        .where((item) => item.transactionType == 'expense')
        .fold<double>(0, (total, item) => total + item.amount);
    final income = monthItems
        .where((item) => item.transactionType == 'income')
        .fold<double>(0, (total, item) => total + item.amount);
    final pendingTotal =
        pending.fold<double>(0, (total, item) => total + item.amount);
    final sortedItems = [...monthItems]
      ..sort((a, b) => b.date.compareTo(a.date));

    return _SharedFamilyFinanceCard(
      spent: spent,
      income: income,
      pending: pendingTotal,
      movementCount: monthItems.length,
      lastMovement: sortedItems.firstOrNull,
    );
  }

  static Widget _buildFinanceLoadingState(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.surface.withValues(alpha: 0.98),
            theme.elevatedSurface.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.62),
        ),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerLoading(height: 14, width: 120, borderRadius: 10),
              Spacer(),
              ShimmerLoading(height: 44, width: 44, borderRadius: 22),
            ],
          ),
          SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: ShimmerLoading(height: 42, width: 170, borderRadius: 14),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 56, borderRadius: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerLoading(height: 56, borderRadius: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildFinanceEmptyState(AppThemeColors theme, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin resumen financiero todavía',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedFamilyFinanceCard extends StatelessWidget {
  final double spent;
  final double income;
  final double pending;
  final int movementCount;
  final FeedItemModel? lastMovement;

  const _SharedFamilyFinanceCard({
    required this.spent,
    required this.income,
    required this.pending,
    required this.movementCount,
    required this.lastMovement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final formatter = NumberFormat.decimalPattern('es_AR');
    final totalMonth = spent + pending;
    final hasActivity = movementCount > 0 || pending > 0 || income > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.surface,
            theme.elevatedSurface.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.62),
          width: 1.05,
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.accentTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasActivity
                          ? 'Gasto compartido del mes'
                          : 'Mes sin gastos',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$ ${formatter.format(totalMonth.round())}',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _FinanceMetric(
                  icon: Icons.receipt_long_rounded,
                  label: 'Pagado',
                  value: '\$ ${formatter.format(spent.round())}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinanceMetric(
                  icon: Icons.event_available_rounded,
                  label: 'Pendiente',
                  value: '\$ ${formatter.format(pending.round())}',
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FinanceMetric(
                  icon: Icons.trending_up_rounded,
                  label: 'Ingresos',
                  value: '\$ ${formatter.format(income.round())}',
                  color: AppColors.sage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinanceMetric(
                  icon: Icons.swap_vert_rounded,
                  label: 'Movimientos',
                  value: '$movementCount',
                  color: AppColors.accentPurple,
                ),
              ),
            ],
          ),
          if (lastMovement != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surfaceContainer.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.border.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  Text(
                    lastMovement!.categoryIcon,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lastMovement!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '\$ ${formatter.format(lastMovement!.amount.round())}',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinanceMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _FinanceMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderLoading extends StatelessWidget {
  const _SectionHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerLoading(height: 18, width: 136, borderRadius: 10),
        ShimmerLoading(height: 34, width: 72, borderRadius: 999),
      ],
    );
  }
}
