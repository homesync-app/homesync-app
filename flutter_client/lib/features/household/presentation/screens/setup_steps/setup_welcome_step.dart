import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import '../setup_widgets.dart';

/// Paso 1: bienvenida con ilustración.
class SetupWelcomeStep extends ConsumerWidget {
  const SetupWelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final t = AppLocalizations.of(context);
        final theme = context.theme;
        return SingleChildScrollView(
          key: const ValueKey('welcome_v5'),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SetupOnboardingIllustration(
                  imagePath: 'assets/images/onboarding_welcome_cat.png',
                ),
                const SizedBox(height: 18),
                Text(
                  t.setupWelcomeTitle,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.8,
                    height: 0.94,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.setupWelcomeBody,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.36,
                    color: theme.textSecondary.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SetupSupportBullet(
                  icon: Icons.timer_outlined,
                  color: theme.primary,
                  text: t.setupWelcomeBulletQuick,
                ),
                const SizedBox(height: 12),
                SetupSupportBullet(
                  icon: Icons.groups_2_rounded,
                  color: const Color(0xFF6FA097),
                  text: t.setupWelcomeBulletJoin,
                ),
                const SizedBox(height: 30),
                SetupPrimaryButton(
                  text: t.setupWelcomeStartButton,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    ref
                        .read(setupWizardControllerProvider.notifier)
                        .goTo(SetupStep.identity);
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
