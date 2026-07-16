import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/household_design.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import '../setup_widgets.dart';

// Names and descriptions live in app_es.arb / app_en.arb under
// `setupModeName` / `setupModeDescription` (ICU select on the id below).
// Acento e icono salen de HouseholdModeDesign para que cada modo use su
// personalidad visual real (sin gradientes por card: regla del design system).
const _modeIds = ['couple', 'family', 'friends', 'solo'];

/// Paso 3: elección del modo de hogar (couple/family/friends/solo).
class SetupModeStep extends ConsumerWidget {
  /// Confirmar el modo elegido. El screen decide el salto (prefill del nombre
  /// de familia + `confirmMode` del controller).
  final VoidCallback onContinue;

  const SetupModeStep({required this.onContinue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);

    return Padding(
      key: const ValueKey('mode_v3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SetupStepEyebrow(text: t.setupModePickerEyebrow),
          const SizedBox(height: 8),
          SetupHeading(
            title: t.setupModePickerTitle,
            subtitle: t.setupModePickerSubtitle,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          ..._modeIds.asMap().entries.map((entry) {
                            final index = entry.key;
                            final modeId = entry.value;
                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 280 + (index * 60)),
                              tween: Tween(begin: 0, end: 1),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(18 * (1 - value), 0),
                                  child: child,
                                ),
                              ),
                              child: _ModeCard(
                                id: modeId,
                                isSelected: wizard.selectedMode == modeId,
                                onTap: () {
                                  AppHaptics.selection();
                                  controller.selectMode(modeId);
                                },
                              ),
                            );
                          }),
                          const Spacer(flex: 2),
                          const SizedBox(height: 8),
                          SetupPrimaryButton(
                            text: t.commonContinue,
                            onPressed:
                                wizard.selectedMode != null ? onContinue : null,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 0,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 34),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .signOut();
                                },
                                child: Text(
                                  t.setupSignOutLink,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textSecondary
                                        .withValues(alpha: 0.64),
                                  ),
                                ),
                              ),
                              Text(
                                '·',
                                style: AppTypography.cardTitle.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.textSecondary
                                      .withValues(alpha: 0.38),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 34),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    controller.goTo(SetupStep.valueProp),
                                child: Text(
                                  t.setupSeeFeaturesLink,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textSecondary
                                        .withValues(alpha: 0.52),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String id;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.id,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final design = HouseholdType.fromString(id).design;
    final accent = design.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.52)
                : theme.border.withValues(alpha: 0.82),
            width: isSelected ? 1.7 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accent.withValues(alpha: 0.07)
                  : theme.shadowBase.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _ModeIcon(design: design, selected: isSelected),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.setupModeName(id),
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 18,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.setupModeDescription(id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.28,
                      color: theme.textSecondary.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: AppMotion.normal,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? accent
                      : theme.border.withValues(alpha: 0.9),
                  width: 1.3,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeIcon extends StatelessWidget {
  final HouseholdModeDesign design;
  final bool selected;

  const _ModeIcon({required this.design, required this.selected});

  @override
  Widget build(BuildContext context) {
    final accent = design.accent;

    return AnimatedContainer(
      duration: AppMotion.normal,
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: selected ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        selected ? design.icon : design.outlineIcon,
        color: accent,
        size: 30,
      ),
    );
  }
}
