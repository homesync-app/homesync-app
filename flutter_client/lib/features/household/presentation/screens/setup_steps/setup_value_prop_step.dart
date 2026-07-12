import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import '../setup_widgets.dart';

/// Paso 0: propuesta de valor (features + CTA de inicio).
class SetupValuePropStep extends ConsumerWidget {
  const SetupValuePropStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final features = [
      (
        icon: Icons.checklist_rounded,
        title: t.setupFeatureTasksTitle,
        desc: t.setupFeatureTasksDesc,
        color: AppColors.primary,
      ),
      (
        icon: Icons.account_balance_wallet_rounded,
        title: t.setupFeatureExpensesTitle,
        desc: t.setupFeatureExpensesDesc,
        color: AppColors.sage,
      ),
      (
        icon: Icons.workspace_premium_rounded,
        title: t.setupFeatureGamificationTitle,
        desc: t.setupFeatureGamificationDesc,
        color: AppColors.accentGold,
      ),
      (
        icon: Icons.shopping_cart_checkout_rounded,
        title: t.setupFeatureShoppingTitle,
        desc: t.setupFeatureShoppingDesc,
        color: AppColors.accentBlue,
      ),
    ];

    return Padding(
      key: const ValueKey('value_prop_v3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Único gradiente de la pantalla: hero suave detrás del titular.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withValues(alpha: 0.10),
                    theme.primary.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadii.xxl),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SetupStepEyebrow(text: t.setupValuePropEyebrow),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Home',
                          style: TextStyle(color: theme.textPrimary),
                        ),
                        TextSpan(
                          text: 'Sync',
                          style: TextStyle(color: theme.primary),
                        ),
                      ],
                    ),
                    // Tracking a -1.2 (~-0.03em): más apretado se tocan las letras.
                    style: AppTypography.heroAmount.copyWith(
                      fontSize: 40,
                      letterSpacing: -1.2,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.setupValuePropTagline,
                    style: AppTypography.body.copyWith(
                      fontSize: 18,
                      height: 1.45,
                      color: theme.textSecondary.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 320 + (index * 70)),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                ),
                child: SetupFeatureCard(
                  icon: feature.icon,
                  title: feature.title,
                  desc: feature.desc,
                  color: feature.color,
                ),
              );
            }),
            const SizedBox(height: 24),
            SetupPrimaryButton(
              text: t.setupValuePropStartButton,
              onPressed: () {
                AppHaptics.success();
                ref
                    .read(setupWizardControllerProvider.notifier)
                    .goTo(SetupStep.welcome);
              },
            ),
            const SizedBox(height: 14),
            SetupKicker(text: t.setupValuePropTimeHint),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
