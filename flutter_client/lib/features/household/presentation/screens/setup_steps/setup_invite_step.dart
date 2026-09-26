import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/features/household/presentation/widgets/partner_invite_card.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';

import '../setup_widgets.dart';

/// Último paso para hogares compartidos: sumar a la otra persona.
///
/// Es el paso que más importa para que la app sirva, así que el código ya
/// está generado y compartirlo es un toque. "Lo hago después" no castiga: el
/// Home sigue recordándolo hasta que la pareja se sume.
class SetupInviteStep extends ConsumerWidget {
  final String? inviteCode;
  final bool codeFailed;
  final bool isSharing;
  final bool hasShared;
  final bool isFinishing;
  final VoidCallback onShareWhatsApp;
  final VoidCallback onShareOther;
  final VoidCallback onCopy;
  final VoidCallback onRetryCode;
  final VoidCallback onFinish;

  const SetupInviteStep({
    required this.inviteCode,
    required this.codeFailed,
    required this.isSharing,
    required this.hasShared,
    required this.isFinishing,
    required this.onShareWhatsApp,
    required this.onShareOther,
    required this.onCopy,
    required this.onRetryCode,
    required this.onFinish,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final mode = wizard.selectedMode;

    return Column(
      key: const ValueKey('setup_invite_v1'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: wizard.modeDesign.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: wizard.modeDesign.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  header: true,
                  child: Text(
                    t.setupInviteTitle(mode),
                    style: AppTypography.heroAmount.copyWith(
                      fontSize: 32,
                      letterSpacing: -0.8,
                      height: 1.08,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  t.setupInviteBody(mode),
                  style: AppTypography.body.copyWith(
                    fontSize: 16,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                InviteCodeBox(
                  label: t.setupInviteCodeLabel,
                  code: inviteCode,
                  failed: codeFailed,
                  onCopy: onCopy,
                  onRetry: onRetryCode,
                ),
                const SizedBox(height: AppSpacing.md),
                // Una sola acción fuerte por vez: antes de compartir es esta;
                // después pasa a secundaria y manda "Listo, ya lo mandé".
                AppButton(
                  label: t.partnerInviteShare,
                  icon: Icons.send_rounded,
                  variant: hasShared
                      ? AppButtonVariant.outline
                      : AppButtonVariant.primary,
                  isFullWidth: true,
                  isLoading: isSharing,
                  isDisabled: inviteCode == null,
                  onTap: onShareWhatsApp,
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: TextButton.icon(
                    onPressed:
                        inviteCode == null || isSharing ? null : onShareOther,
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: Text(t.partnerInviteShareOther),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  t.setupInviteHint(mode),
                  style: AppTypography.caption.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(color: theme.border.withValues(alpha: 0.7)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: hasShared
                  ? SetupPrimaryButton(
                      text: t.setupInviteDone,
                      isLoading: isFinishing,
                      accent: wizard.modeDesign.accent,
                      onPressed: onFinish,
                    )
                  : TextButton(
                      onPressed: isFinishing ? null : onFinish,
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppControlSizes.buttonHeight,
                        ),
                        foregroundColor: theme.textSecondary,
                      ),
                      child: Text(
                        t.setupInviteLater,
                        style: AppTypography.bodyStrong,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
