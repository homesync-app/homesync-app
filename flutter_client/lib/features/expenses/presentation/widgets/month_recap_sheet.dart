import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/expenses/presentation/providers/month_recap_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_data.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

String _capitalizedMonth(DateTime month, String localeTag) {
  final raw = DateFormat.MMMM(localeTag).format(month);
  return raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);
}

/// Banner "Tu {mes} está listo": primeros 10 días del mes, si el mes anterior
/// tuvo movimientos y no fue descartado. Premium abre el recap; free, el
/// paywall (el banner en sí es el teaser del feature).
class MonthRecapBanner extends ConsumerWidget {
  const MonthRecapBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (DateTime.now().day > 10) return const SizedBox.shrink();

    final dismissed = ref.watch(monthRecapDismissedProvider).value ?? true;
    if (dismissed) return const SizedBox.shrink();

    final recap = ref.watch(monthRecapProvider).value;
    if (recap == null) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final localeTag = Localizations.localeOf(context).toString();
    final monthName = _capitalizedMonth(recap.month, localeTag);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppInsets.screenHorizontal,
        AppSpacing.md,
        AppInsets.screenHorizontal,
        0,
      ),
      child: AnimatedPress(
        onTap: () {
          final isPremium = ref.read(premiumProvider).value ?? false;
          if (!isPremium) {
            PremiumPaywall.show(context);
            return;
          }
          AppHaptics.selection();
          MonthRecapSheet.show(context);
        },
        scale: 0.98,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primary.withValues(alpha: 0.10),
                AppColors.accentPurple.withValues(alpha: 0.08),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: theme.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 19,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.recapBannerTitle(monthName),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.recapBannerSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await persistMonthRecapDismissal();
                  ref.invalidate(monthRecapDismissedProvider);
                },
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recap narrativo del mes anterior: gasto total con delta, ingresos, top
/// categorías, quién puso (si hay más de un aportante) y ahorro a metas.
class MonthRecapSheet extends ConsumerWidget {
  const MonthRecapSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MonthRecapSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(currencyProvider);
    final localeTag = Localizations.localeOf(context).toString();
    final recap = ref.watch(monthRecapProvider).value;
    final householdType = ref.watch(householdCapabilitiesProvider).type.name;

    if (recap == null) return const SizedBox.shrink();

    final monthName = _capitalizedMonth(recap.month, localeTag);
    final prevMonthName = _capitalizedMonth(
      DateTime(recap.month.year, recap.month.month - 1),
      localeTag,
    );

    String? deltaText;
    Color deltaColor = theme.textSecondary;
    if (recap.prevSpent > 0 && recap.totalSpent > 0) {
      final pct = (((recap.totalSpent - recap.prevSpent) / recap.prevSpent) *
              100)
          .round();
      if (pct <= -1) {
        deltaText = t.trendDeltaDown(pct.abs(), prevMonthName);
        deltaColor = AppColors.success;
      } else if (pct >= 1) {
        deltaText = t.trendDeltaUp(pct, prevMonthName);
        deltaColor = AppColors.warning;
      }
    }

    final maxCategorySpent = recap.byCategory
        .map((c) => c.spent)
        .fold<double>(0, (max, v) => v > max ? v : max);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                    color: theme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t.recapSheetTitle(monthName),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.recapMovementsCount(recap.expenseCount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Gasto total del mes + delta.
              Text(
                recap.sharedEconomy
                    ? t.recapTotalLabelShared
                    : t.recapTotalLabelPersonal,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: theme.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedAmount(
                value: recap.totalSpent,
                locale: localeTag,
                format: (value) => currency.format(value.round()),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -1.2,
                  fontFeatures: kTabularFigures,
                ),
              ),
              if (deltaText != null) ...[
                const SizedBox(height: 6),
                Text(
                  deltaText,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: deltaColor,
                  ),
                ),
              ],
              if (recap.income > 0) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 18,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.recapIncomeRow(currency.format(recap.income.round())),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],

              // Top categorías.
              if (recap.byCategory.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  t.recapCategoriesTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: theme.textMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                for (final category in recap.byCategory) ...[
                  _CategoryBar(
                    category: category,
                    maxSpent: maxCategorySpent,
                    amountLabel: currency.format(category.spent.round()),
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              // Quién puso (solo con más de un aportante en compartidos).
              if (recap.byPayer.length > 1) ...[
                const SizedBox(height: 20),
                Text(
                  t.recapPayersTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: theme.textMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                for (final payer in recap.byPayer) ...[
                  Row(
                    children: [
                      CustomUserAvatar(
                        avatarUrl: payer.avatarUrl,
                        name: payer.name,
                        radius: 16,
                        forceCircular: true,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          payer.name.split(' ').first,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        currency.format(payer.paid.round()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                          fontFeatures: kTabularFigures,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              // Ahorro sumado a metas.
              if (recap.savingsAdded > 0) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.recapSavingsRow(
                            householdType,
                            currency.format(recap.savingsAdded.round()),
                          ),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.textPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                  ),
                  child: Text(
                    t.commonClose,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final MonthRecapCategory category;
  final double maxSpent;
  final String amountLabel;

  const _CategoryBar({
    required this.category,
    required this.maxSpent,
    required this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final color = CategoryMapping.getCategoryColor(category.category);
    final ratio =
        maxSpent <= 0 ? 0.0 : (category.spent / maxSpent).clamp(0.05, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                localizedExpenseCategoryName(t, category.category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ),
            Text(
              amountLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                fontFeatures: kTabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 7,
                width: double.infinity,
                color: color.withValues(alpha: 0.12),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(height: 7, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
