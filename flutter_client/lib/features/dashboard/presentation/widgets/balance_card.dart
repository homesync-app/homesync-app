import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class BalanceCard extends ConsumerStatefulWidget {
  final int coins;
  final int xp;
  final double? userBalance;
  final bool isDark;
  final VoidCallback? onSettle;
  final String? partnerName;
  final bool settlementJustCompleted;
  final String? balancedLabel;
  final String? neutralLabel;
  final bool compact;
  final bool showGamification;

  /// When true, the household uses an integrated (shared) economy: there is no
  /// debt/balance between members, so the card shows a neutral "shared
  /// finances" state instead of a balance amount or a settle action.
  final bool integratedEconomy;

  /// Total shared household spending for the current month. Only shown when
  /// [integratedEconomy] is true, in place of the balance amount.
  final double? monthlySpent;

  const BalanceCard({
    super.key,
    required this.coins,
    required this.xp,
    this.userBalance,
    this.isDark = false,
    this.onSettle,
    this.partnerName,
    this.settlementJustCompleted = false,
    this.balancedLabel,
    this.neutralLabel,
    this.compact = false,
    this.showGamification = true,
    this.integratedEconomy = false,
    this.monthlySpent,
  });

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  late int _coinsAnimationStart;
  late int _xpAnimationStart;

  @override
  void initState() {
    super.initState();
    _coinsAnimationStart = widget.coins;
    _xpAnimationStart = widget.xp;
  }

  @override
  void didUpdateWidget(covariant BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins) {
      _coinsAnimationStart = oldWidget.coins;
    }
    if (oldWidget.xp != widget.xp) {
      _xpAnimationStart = oldWidget.xp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.userBalance ?? 0.0;
    final isPositive = balance > 0.01;
    final isNegative = balance < -0.01;
    final isBalanced = !isPositive && !isNegative;
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final integrated = widget.integratedEconomy;

    final statusColor = integrated
        ? AppColors.sage
        : (isNegative ? AppColors.accentOrange : AppColors.sage);
    final surfaceColor = widget.settlementJustCompleted
        ? Color.alphaBlend(
            AppColors.sage.withValues(alpha: 0.035),
            theme.surface,
          )
        : theme.surface;
    final elevatedSurfaceColor = widget.settlementJustCompleted
        ? Color.alphaBlend(
            AppColors.sage.withValues(alpha: 0.05),
            theme.elevatedSurface,
          )
        : theme.elevatedSurface;
    final borderColor = widget.settlementJustCompleted
        ? AppColors.sage.withValues(alpha: 0.22)
        : theme.border.withValues(alpha: 0.68);
    final balanceMessage = widget.settlementJustCompleted
        ? t.balanceCardSettled
        : widget.partnerName == null
            ? (widget.neutralLabel ?? t.balanceCardMyBudget)
            : (isBalanced
                ? (widget.balancedLabel ?? t.balanceCardBalanced)
                : (isNegative
                    ? t.balanceCardNeedsSettlement
                    : t.balanceCardInYourFavor));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surfaceColor,
            elevatedSurfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.compact ? 24 : 28),
        border: Border.all(
          color: borderColor,
          width: 1.05,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.settlementJustCompleted
                ? AppColors.sage.withValues(alpha: 0.075)
                : theme.shadowBase.withValues(alpha: 0.036),
            blurRadius: widget.settlementJustCompleted ? 22 : 16,
            offset: Offset(0, widget.settlementJustCompleted ? 9 : 7),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          widget.compact ? 16 : 18,
          20,
          widget.compact ? 14 : 16,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Integrated economy: the green eyebrow is the label
                        // ("Gastos del hogar"); the amount stands alone below so
                        // it doesn't crowd the home badge on the right.
                        integrated
                            ? t.balanceCardIntegratedSubtitle
                            : (widget.settlementJustCompleted || !isBalanced
                                ? balanceMessage
                                : (widget.balancedLabel ??
                                    t.balanceCardBalanced)),
                        style: TextStyle(
                          color: isBalanced
                              ? statusColor.withValues(alpha: 0.88)
                              : statusColor,
                          fontSize: widget.compact ? 11.5 : 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: widget.compact ? 4 : 6),
                      if (integrated)
                        if (widget.monthlySpent != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                currency.inputPrefix(),
                                style: AppTypography.cardTitle.copyWith(
                                  color: theme.textPrimary,
                                ),
                              ),
                              AnimatedAmount(
                                value: widget.monthlySpent!,
                                locale: currency.locale,
                                style: TextStyle(
                                  color:
                                      theme.textPrimary.withValues(alpha: 0.94),
                                  fontSize: widget.compact ? 29 : 31,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          )
                        else
                          // No spend value yet: show a neutral amount instead
                          // of repeating the "Gastos del hogar" eyebrow.
                          Text(
                            currency.inputPrefix(),
                            style: TextStyle(
                              color: theme.textPrimary.withValues(alpha: 0.94),
                              fontSize: widget.compact ? 29 : 31,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isBalanced
                                  ? currency.inputPrefix()
                                  : (isNegative
                                      ? '- ${currency.inputPrefix()}'
                                      : '+ ${currency.inputPrefix()}'),
                              style: TextStyle(
                                color: isBalanced
                                    ? theme.textPrimary
                                    : statusColor,
                                fontSize: isBalanced ? 16 : 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            AnimatedAmount(
                              value: balance.abs(),
                              locale: currency.locale,
                              style: TextStyle(
                                color: isBalanced
                                    ? theme.textPrimary.withValues(alpha: 0.94)
                                    : statusColor,
                                fontSize: widget.compact
                                    ? (isBalanced ? 29 : 32)
                                    : (isBalanced ? 31 : 35),
                                fontWeight: isBalanced
                                    ? FontWeight.w800
                                    : FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (integrated)
                  _IntegratedEconomyBadge(compact: widget.compact)
                else if (isNegative && widget.onSettle != null)
                  AnimatedPress(
                    onTap: widget.onSettle!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.14),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.045),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            color: statusColor,
                            size: 15,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            t.balanceCardSettleButton,
                            style: AppTypography.caption.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animatePulse()
                else if (isBalanced)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.88,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _BalanceSuccessBadge(
                      key: ValueKey(widget.settlementJustCompleted),
                      emphasized: widget.settlementJustCompleted,
                    ),
                  ),
              ],
            ),
            if (widget.showGamification) ...[
              SizedBox(height: widget.compact ? 10 : 13),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: widget.compact ? 10 : 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.border.withValues(alpha: 0.32),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInlineMetric(
                        context,
                        icon: Icons.star_rounded,
                        label: 'XP',
                        value: widget.xp,
                        beginValue: _xpAnimationStart,
                        color: AppColors.xpGold,
                        subdued: isBalanced && widget.xp == 0,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: theme.border
                          .withValues(alpha: isBalanced ? 0.14 : 0.22),
                    ),
                    Expanded(
                      child: _buildInlineMetric(
                        context,
                        icon: Icons.monetization_on_rounded,
                        label: 'coins',
                        value: widget.coins,
                        beginValue: _coinsAnimationStart,
                        color: AppColors.coinGreen,
                        subdued: isBalanced && widget.coins == 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      // Entrance animation is owned by the caller (home_couple_view wraps the
      // card in animateEntrance); animating here too produced a doubled,
      // heavier fade+slide.
    );
  }

  Widget _buildInlineMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required int beginValue,
    required Color color,
    bool subdued = false,
  }) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final delta = value - beginValue;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: beginValue.toDouble(),
        end: value.toDouble(),
      ),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      onEnd: () {
        if (!mounted) return;
        if (label == 'XP' && _xpAnimationStart != value) {
          setState(() => _xpAnimationStart = value);
        }
        if (label != 'XP' && _coinsAnimationStart != value) {
          setState(() => _coinsAnimationStart = value);
        }
      },
      builder: (context, animatedValue, child) {
        // Emphasis swells 0→1→0 while the value is counting so the metric
        // visibly "lights up" during the change and settles back when done.
        final progress = delta == 0
            ? 1.0
            : ((animatedValue - beginValue) / delta).clamp(0.0, 1.0);
        final emphasis = delta == 0 ? 0.0 : math.sin(progress * math.pi);
        final baseNumberColor = subdued
            ? theme.textPrimary.withValues(alpha: 0.86)
            : theme.textPrimary;
        final numberColor =
            Color.lerp(baseNumberColor, color, emphasis * 0.85)!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 1 + 0.14 * emphasis,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: (subdued ? 0.045 : 0.07) + 0.11 * emphasis,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: subdued ? color.withValues(alpha: 0.82) : color,
                  size: 14.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: NumberFormat.decimalPattern('es_AR').format(
                        animatedValue.round(),
                      ),
                      style: TextStyle(
                        color: numberColor,
                        fontSize: 14.5,
                        fontWeight: subdued ? FontWeight.w700 : FontWeight.w800,
                        letterSpacing: 0,
                        fontFeatures: kTabularFigures,
                      ),
                    ),
                    TextSpan(
                      text: label == 'XP'
                          ? ' ${t.balanceCardXpLabel}'
                          : ' ${t.balanceCardCoinsLabel}',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: subdued
                            ? theme.textSecondary.withValues(alpha: 0.82)
                            : theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BalanceSuccessBadge extends StatelessWidget {
  final bool emphasized;

  const _BalanceSuccessBadge({
    super.key,
    required this.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: emphasized ? 54 : 44,
      height: emphasized ? 54 : 44,
      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: emphasized ? 0.16 : 0.1),
        shape: BoxShape.circle,
        boxShadow: emphasized
            ? [
                BoxShadow(
                  color: AppColors.sage.withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AppColors.sage,
        size: 24,
      ),
    );
  }
}

class _IntegratedEconomyBadge extends StatelessWidget {
  final bool compact;

  const _IntegratedEconomyBadge({required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 48.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.home_rounded,
        color: AppColors.sage,
        size: 22,
      ),
    );
  }
}
