import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/expenses/presentation/providers/subscription_suggestion_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/recurring_expense_form_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

/// Banner "¿esto es un gasto fijo?" sobre el feed de Movimientos: aparece
/// cuando el detector encuentra un gasto que se repite mes a mes sin
/// plantilla recurrente. Crear abre el form de recurrentes prefilleado
/// (paywall para free — recurrentes es premium); "Ahora no" lo descarta
/// para siempre.
class SubscriptionSuggestionBanner extends ConsumerWidget {
  const SubscriptionSuggestionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestion = ref.watch(subscriptionSuggestionProvider).value;
    if (suggestion == null) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(currencyProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppInsets.screenHorizontal,
        AppSpacing.lg,
        AppInsets.screenHorizontal,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.primary.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    Icons.autorenew_rounded,
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
                        t.subsSuggestionTitle(suggestion.title),
                        style: AppTypography.bodyStrong.copyWith(
                          height: 1.25,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t.subsSuggestionBody(
                          currency.format(suggestion.avgAmount.round()),
                        ),
                        style: AppTypography.caption.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    await persistSubscriptionSuggestionDismissal(
                      suggestion.normalizedKey,
                    );
                    ref.invalidate(subscriptionSuggestionProvider);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    t.subsSuggestionDismiss,
                    style: AppTypography.caption.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () {
                    final isPremium =
                        ref.read(premiumProvider).value ?? false;
                    if (!isPremium) {
                      PremiumPaywall.show(context);
                      return;
                    }
                    AppHaptics.selection();
                    RecurringExpenseFormSheet.show(
                      context,
                      initialTitle: suggestion.title,
                      initialAmount: suggestion.avgAmount.roundToDouble(),
                      initialCategory: suggestion.category,
                      initialDayOfMonth: suggestion.suggestedDayOfMonth,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primary,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  child: Text(
                    t.subsSuggestionCreate,
                    style: AppTypography.caption.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
