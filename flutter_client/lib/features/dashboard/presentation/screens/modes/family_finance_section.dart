import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';

import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_balance_card.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

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
    final balancesAsync = ref.watch(expenseBalancesProvider);
    final walletAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';

    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final isChild = currentMember?.isChild ?? false;
    final isTeen = currentMember?.isTeen ?? false;
    final adultMembers = members.where((m) => m.isAdult).toList();
    final shouldShowSection =
        currentMember != null && !isChild && !isTeen && adultMembers.length > 1;
    final sectionTitle =
        adultMembers.length == 2 ? 'Balance del hogar' : 'Finanzas familiares';

    final isLoading = membersAsync.isLoading ||
        balancesAsync.isLoading ||
        walletAsync.isLoading;
    final hasError = membersAsync.hasError || balancesAsync.hasError;

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
      final walletCoins = walletAsync.valueOrNull?['coins'] as int? ?? 0;
      final walletXp = walletAsync.valueOrNull?['xp'] as int? ?? 0;
      final balances = balancesAsync.valueOrNull ?? const [];

      child = Column(
        key: ValueKey('finance-ready-${adultMembers.length}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceHeader(theme, sectionTitle, ref, currentMember),
          const SizedBox(height: 12),
          _buildFinanceReadyState(
            theme,
            caps,
            adultMembers: adultMembers,
            currentUserId: currentUserId,
            balances: balances,
            walletCoins: walletCoins,
            walletXp: walletXp,
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
    AppThemeColors theme,
    HouseholdCapabilities caps, {
    required List<MemberModel> adultMembers,
    required String currentUserId,
    required List<HouseholdBalanceModel> balances,
    required int walletCoins,
    required int walletXp,
  }) {
    if (balances.isEmpty) {
      if (adultMembers.length == 2) {
        final partner = adultMembers
            .where((member) => member.userId != currentUserId)
            .firstOrNull;
        return BalanceCard(
          coins: walletCoins,
          xp: walletXp,
          userBalance: 0,
          partnerName: partner?.displayName,
        );
      }

      return _buildFinanceEmptyState(
        theme,
        'Todavia no hay balances del hogar para mostrar.',
      );
    }

    final adultIds = adultMembers.map((member) => member.userId).toSet();
    final adultBalances =
        balances.where((balance) => adultIds.contains(balance.userId)).toList();

    if (adultBalances.isEmpty) {
      if (adultMembers.length == 2) {
        final partner = adultMembers
            .where((member) => member.userId != currentUserId)
            .firstOrNull;
        return BalanceCard(
          coins: walletCoins,
          xp: walletXp,
          userBalance: 0,
          partnerName: partner?.displayName,
        );
      }

      return _buildFinanceEmptyState(
        theme,
        'Todavia no hay balances del hogar para mostrar.',
      );
    }

    if (adultMembers.length == 2) {
      final partner = adultMembers
          .where((member) => member.userId != currentUserId)
          .firstOrNull;
      final myBalance = adultBalances
          .where((balance) => balance.userId == currentUserId)
          .firstOrNull
          ?.balance;

      return BalanceCard(
        coins: walletCoins,
        xp: walletXp,
        userBalance: myBalance,
        partnerName: partner?.displayName,
      );
    }

    return FamilyBalanceCard(
      balances: adultBalances,
      title: caps.balanceMessage,
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
