import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/budget_section.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/spend_trend_card.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';

/// Análisis del mes: tendencia de 6 meses + presupuestos por categoría.
///
/// Viven acá (y no en el scroll de Movimientos) para que el home de Finanzas
/// sea balance → movimientos, sin ruido intermedio. Se abre desde el ícono
/// junto a la píldora del mes en el summary card.
class FinanceInsightsSheet extends StatelessWidget {
  const FinanceInsightsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FinanceInsightsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          // Sin padding horizontal propio: TrendCard y BudgetSection ya
          // traen el suyo (AppInsets.screenHorizontal), así quedan alineados
          // con el resto de la app.
          padding: const EdgeInsets.only(top: 12, bottom: 32),
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.financeInsightsTitle,
                      style: AppTypography.sectionTitle.copyWith(
                        fontSize: 22,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.financeInsightsSubtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SpendTrendCard(),
              const BudgetSection(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
