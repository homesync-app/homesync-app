import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import '../setup_widgets.dart';

/// Paso 5: mostrar el código de invitación del hogar recién creado.
class SetupInviteCodeStep extends ConsumerWidget {
  final String? inviteCode;
  final bool isGeneratingCode;
  final VoidCallback onCopyCode;
  final VoidCallback onShareCode;

  const SetupInviteCodeStep({
    required this.inviteCode,
    required this.isGeneratingCode,
    required this.onCopyCode,
    required this.onShareCode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final modeKey = wizard.selectedMode ?? 'couple';
    final design = wizard.modeDesign;
    final accent = design.accent;

    return Column(
      key: const ValueKey('invite_code_v2'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SetupStepEyebrow(text: t.setupInvitationEyebrow, accent: accent),
              const SizedBox(height: 10),
              SetupHeading(
                title: t.setupInvitationTitle(modeKey),
                subtitle: t.setupInvitationSubtitle(modeKey),
              ),
              const SizedBox(height: 28),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: Container(
                      decoration: BoxDecoration(
                        // Único gradiente de la pantalla: el hero del modo.
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: design.heroGradient,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.modal),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowBase.withValues(alpha: 0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.modal),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    t.setupInvitationCodeEyebrow,
                                    style: AppTypography.eyebrow.copyWith(
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                  if (isGeneratingCode)
                                    CircularProgressIndicator(color: accent)
                                  else
                                    FittedBox(
                                      child: Text(
                                        inviteCode ?? '------',
                                        style: AppTypography.heroAmount.copyWith(
                                          fontSize: 56,
                                          letterSpacing: 8,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.border.withValues(alpha: 0.85),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: design.secondaryAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: design.secondaryAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.setupInvitationFooter,
                        style: AppTypography.caption.copyWith(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              theme.textSecondary.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SetupSecondaryButton(
                      text: t.setupInvitationCopyButton,
                      icon: Icons.copy_rounded,
                      onTap: onCopyCode,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SetupSecondaryButton(
                      text: t.setupInvitationShareButton,
                      icon: Icons.share_rounded,
                      onTap: onShareCode,
                      accent: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SetupPrimaryButton(
            text: t.commonContinue,
            onPressed: controller.continueFromInviteCode,
            accent: accent,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => controller.goTo(SetupStep.teamOptions),
          child: Text(t.commonBack),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
