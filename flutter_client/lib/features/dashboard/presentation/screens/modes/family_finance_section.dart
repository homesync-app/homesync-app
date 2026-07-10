import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/app_ui_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/date_extensions.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/spent_bento_tile.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/pending_approvals_screen.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

/// Family-adult finance summary as a bento grid: the shared monthly spend
/// (hero tile, taps through to Finances) plus the Parent Mode approvals inbox
/// tile when the feature is available. No section header — the tiles are
/// self-labelled, which removed the duplicated "Finanzas familiares /
/// Gasto compartido del mes" double title.
class FamilyFinanceSection extends ConsumerWidget {
  final HouseholdCapabilities caps;
  final MemberModel? currentMember;

  const FamilyFinanceSection({
    super.key,
    required this.caps,
    required this.currentMember,
  });

  static const double _bentoHeight = 158;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final feedAsync = ref.watch(combinedFeedControllerProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final t = AppLocalizations.of(context);

    final members = membersAsync.value ?? const <MemberModel>[];
    final isChild = currentMember?.isChild ?? false;
    final isTeen = currentMember?.isTeen ?? false;
    final adultMembers = members.where((m) => m.isAdult).toList();
    final shouldShowSection =
        currentMember != null && !isChild && !isTeen && adultMembers.length > 1;

    final isLoading = membersAsync.isLoading || feedAsync.isLoading;
    final hasError = membersAsync.hasError || feedAsync.hasError;

    Widget child;
    if (!isLoading && !shouldShowSection) {
      child = const SizedBox.shrink(key: ValueKey('finance-hidden'));
    } else if (hasError) {
      child = Column(
        key: const ValueKey('finance-error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceEmptyState(
            theme,
            t.homeFamilyFinanceLoadError,
          ),
          const SizedBox(height: 28),
        ],
      );
    } else if (isLoading) {
      child = Column(
        key: const ValueKey('finance-loading'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceLoadingState(),
          const SizedBox(height: 28),
        ],
      );
    } else {
      final feed = feedAsync.value ?? const <FeedItemModel>[];
      final now = DateTime.now();
      // "Gasto compartido del mes": los personales/gift del viewer quedan
      // fuera — el tile debe mostrar la misma cifra a todos los adultos.
      final spent = feed
          .where(
            (item) =>
                item.isRealExpense &&
                item.date.isSameMonth(now) &&
                !item.isSettlement &&
                item.transactionType == 'expense' &&
                !const {'personal', 'gift'}
                    .contains((item.splitType ?? 'equal').toLowerCase()),
          )
          .fold<double>(0, (total, item) => total + item.amount);

      child = Column(
        key: ValueKey('finance-ready-${adultMembers.length}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FamilyBentoGrid(
            spent: spent,
            caps: caps,
            currentMember: currentMember,
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

  static Widget _buildFinanceLoadingState() {
    return const SizedBox(
      height: _bentoHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 13,
            child: ShimmerLoading(borderRadius: AppRadii.xxl),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 9,
            child: ShimmerLoading(borderRadius: AppRadii.xxl),
          ),
        ],
      ),
    );
  }

  static Widget _buildFinanceEmptyState(AppThemeColors theme, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.xl),
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

class _FamilyBentoGrid extends ConsumerWidget {
  final double spent;
  final HouseholdCapabilities caps;
  final MemberModel? currentMember;

  const _FamilyBentoGrid({
    required this.spent,
    required this.caps,
    required this.currentMember,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final parentModeAvailable = ref.watch(parentModeAvailableProvider);

    final spentTile = SpentBentoTile(
      label: t.homeFamilyFinanceMonthSpent,
      amount: spent,
      onTap: () {
        final index = indexForMainTab(
          caps,
          MainTab.expenses,
          currentMember: currentMember,
        );
        if (index >= 0) {
          ref.read(bottomNavIndexProvider.notifier).setIndex(index);
        }
      },
    );

    return SizedBox(
      height: FamilyFinanceSection._bentoHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 13, child: spentTile),
          // The approvals tile only exists where Parent Mode does — otherwise
          // the spend tile takes the full width.
          if (parentModeAvailable) ...[
            const SizedBox(width: 12),
            const Expanded(flex: 9, child: _ApprovalsTile()),
          ],
        ],
      ),
    );
  }
}

/// Parent Mode inbox tile: pending-approval count with attention tint, or a
/// calm sage "all clear". Always tappable — the inbox is reachable even when
/// empty.
class _ApprovalsTile extends ConsumerWidget {
  const _ApprovalsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final approvalsAsync = ref.watch(pendingTaskApprovalsProvider);
    final count = approvalsAsync.value?.length;
    final isLoading = count == null;
    final hasPending = (count ?? 0) > 0;
    final accent = hasPending ? theme.primary : AppColors.sage;

    return Semantics(
      button: true,
      child: AnimatedPress(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PendingApprovalsScreen(),
            ),
          );
        },
        scale: 0.97,
        haptic: AppPressHaptic.selection,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: hasPending
                ? accent.withValues(alpha: theme.isDarkMode ? 0.14 : 0.08)
                : theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            border: Border.all(
              color: hasPending
                  ? accent.withValues(alpha: 0.16)
                  : theme.border.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const ShimmerLoading(height: 44, width: 44, borderRadius: 12)
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Center(
                    child: hasPending
                        ? Text(
                            '$count',
                            style: TextStyle(
                              color: accent,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          )
                        : Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: accent,
                          ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                t.homeFamilyApprovalsTileLabel.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isLoading
                    ? '—'
                    : hasPending
                        ? t.homeFamilyApprovalsPendingLabel(count)
                        : t.homeFamilyApprovalsAllClear,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary,
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
}
