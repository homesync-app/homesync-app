import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/household_design.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/features/household/presentation/widgets/couple_finance_config_body.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import '../setup_widgets.dart';

/// Paso 6: configuración del hogar según el modo — nombre/rol para familia,
/// finanzas (split o economía compartida) para pareja/familia, 50/50 fijo
/// para amigos.
class SetupHouseholdConfigStep extends ConsumerWidget {
  final TextEditingController familyHouseholdNameController;
  final VoidCallback onSaveFamily;
  final VoidCallback onSaveFinanceSettings;
  final VoidCallback onSaveFriendsSplit;
  final VoidCallback onSkip;

  const SetupHouseholdConfigStep({
    required this.familyHouseholdNameController,
    required this.onSaveFamily,
    required this.onSaveFinanceSettings,
    required this.onSaveFriendsSplit,
    required this.onSkip,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(setupWizardControllerProvider);
    if (wizard.selectedMode == 'family') {
      return _FamilySetupBody(
        familyHouseholdNameController: familyHouseholdNameController,
        onSave: onSaveFamily,
        onSkip: onSkip,
      );
    }
    if (wizard.selectedMode == 'friends') {
      return _FriendsEqualSplitBody(onSave: onSaveFriendsSplit, onSkip: onSkip);
    }
    return _CoupleFamilySplitBody(onSave: onSaveFinanceSettings, onSkip: onSkip);
  }
}

class _FamilySetupBody extends ConsumerWidget {
  final TextEditingController familyHouseholdNameController;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  const _FamilySetupBody({
    required this.familyHouseholdNameController,
    required this.onSave,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final accent = wizard.modeDesign.accent;

    return Padding(
      key: const ValueKey('family_setup_v2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SetupStepEyebrow(text: t.setupFamilyBaseEyebrow, accent: accent),
          const SizedBox(height: 10),
          SetupHeading(
            title: t.setupFamilyBaseTitle,
            subtitle: t.setupFamilyBaseSubtitle,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SetupFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.setupFamilyHouseholdNameLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: familyHouseholdNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: t.setupFamilyHouseholdNameHint,
                            filled: true,
                            fillColor: theme.surface.withValues(alpha: 0.92),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: theme.border.withValues(alpha: 0.9),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: theme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SetupFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.setupFamilyRoleLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            // Internal id stays in Spanish for backend compat
                            // (sent as 'p_display_role'); only the UI label is
                            // localized via the lookup below.
                            ('Padre', t.setupFamilyRoleFather),
                            ('Madre', t.setupFamilyRoleMother),
                            ('Tutor/a', t.setupFamilyRoleGuardian),
                            ('Adolescente', t.setupFamilyRoleTeen),
                          ].map((entry) {
                            final id = entry.$1;
                            final label = entry.$2;
                            return SetupFamilyChoiceChip(
                              label: label,
                              selected: wizard.familyRole == id,
                              onTap: () => controller.setFamilyRole(id),
                              accent: accent,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SetupPrimaryButton(
            text: t.setupSaveAndContinue,
            onPressed: onSave,
            accent: accent,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(t.setupConfigureLater),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FriendsEqualSplitBody extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onSkip;

  const _FriendsEqualSplitBody({required this.onSave, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final design = HouseholdType.friends.design;
    final accent = design.accent;
    return Padding(
      key: const ValueKey('split_friends_v2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SetupStepEyebrow(text: t.setupExpensesEyebrow, accent: accent),
          const SizedBox(height: 10),
          SetupHeading(
            title: t.setupExpensesTitle,
            subtitle: t.setupFriendsExpensesSubtitle,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: theme.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(
                        color: theme.cardBorder.withValues(alpha: 0.85),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          child: Icon(
                            Icons.balance_rounded,
                            color: accent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t.setupFriendsExpensesCardTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.setupFriendsExpensesCardBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: theme.textSecondary
                                .withValues(alpha: 0.84),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SetupStrategyTip(
                    title: t.setupFriendsExpensesTipTitle,
                    desc: t.setupFriendsExpensesTipDesc,
                    active: true,
                    accent: accent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SetupPrimaryButton(
            text: t.setupSaveAndContinue,
            onPressed: onSave,
            accent: accent,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(t.setupConfigureLater),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CoupleFamilySplitBody extends ConsumerWidget {
  final VoidCallback onSave;
  final VoidCallback onSkip;

  const _CoupleFamilySplitBody({required this.onSave, required this.onSkip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final modeKey = wizard.selectedMode ?? 'couple';
    final accent = wizard.modeDesign.accent;

    return Padding(
      key: const ValueKey('split_v2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SetupStepEyebrow(text: t.setupExpensesEyebrow, accent: accent),
          const SizedBox(height: 10),
          SetupHeading(
            title: t.setupExpensesTitle,
            subtitle: t.setupCoupleFamilyExpensesSubtitle(modeKey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: CoupleFinanceConfigBody(
                modeKey: modeKey,
                accent: accent,
                financeMode: wizard.financeMode,
                splitRatio: wizard.splitRatio,
                supportsFinanceModeChoice: true,
                onFinanceModeChanged: controller.setFinanceMode,
                onSplitRatioChanged: controller.setSplitRatio,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SetupPrimaryButton(
            text: t.setupSaveAndContinue,
            onPressed: onSave,
            accent: accent,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(t.setupConfigureLater),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
