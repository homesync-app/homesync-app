import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

import '../setup_widgets.dart';

/// Paso 4: crear hogar nuevo o unirse con código.
class SetupTeamOptionsStep extends ConsumerWidget {
  final TextEditingController codeController;
  final bool isJoining;
  final VoidCallback onCreateTeam;
  final VoidCallback onJoinTeam;

  const SetupTeamOptionsStep({
    required this.codeController,
    required this.isJoining,
    required this.onCreateTeam,
    required this.onJoinTeam,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final accent = wizard.modeDesign.accent;

    return SingleChildScrollView(
      key: const ValueKey('team_options_v3'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          SetupStepEyebrow(text: t.setupConnectEyebrow, accent: accent),
          const SizedBox(height: 10),
          Text(
            t.setupConnectTitle,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
              height: 0.95,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.setupConnectSubtitle,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.28,
              color: theme.textSecondary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SetupOptionTile(
            icon: Icons.add_home_work_rounded,
            title: t.setupConnectCreateTitle,
            desc: t.setupConnectCreateDesc,
            isSelected: wizard.createNew,
            tone: accent,
            onTap: () => controller.setCreateNew(true),
          ),
          const SizedBox(height: 10),
          SetupOptionTile(
            icon: Icons.qr_code_scanner_rounded,
            title: t.setupConnectJoinTitle,
            desc: t.setupConnectJoinDesc,
            isSelected: !wizard.createNew,
            tone: wizard.modeDesign.secondaryAccent,
            onTap: () => controller.setCreateNew(false),
          ),
          if (!wizard.createNew) ...[
            const SizedBox(height: 14),
            Text(
              t.setupConnectCodeInputLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            SetupJoinCodeInput(
              codeController: codeController,
              joinError: wizard.joinError,
              onChanged: () => controller.setJoinError(null),
              showLabel: false,
              compact: true,
              accent: accent,
            ),
          ],
          const SizedBox(height: 20),
          if (isJoining)
            const AppLoadingState()
          else
            SetupPrimaryButton(
              text: wizard.createNew
                  ? t.setupConnectCreateButton
                  : t.setupConnectJoinButton,
              onPressed: wizard.createNew ? onCreateTeam : onJoinTeam,
              accent: accent,
            ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => controller.goTo(SetupStep.mode),
              child: Text(t.setupConnectBackButton),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Input del código de invitación (6 caracteres).
class SetupJoinCodeInput extends StatelessWidget {
  final TextEditingController codeController;
  final String? joinError;
  final VoidCallback onChanged;
  final bool showLabel;
  final bool compact;

  /// Acento del modo elegido; null usa el primary global.
  final Color? accent;

  const SetupJoinCodeInput({
    required this.codeController,
    required this.joinError,
    required this.onChanged,
    this.showLabel = true,
    this.compact = false,
    this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tone = accent ?? theme.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return FractionalTranslation(
          translation: Offset(0, 0.1 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Text(
              AppLocalizations.of(context).setupJoinCodeTitle,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SizedBox(height: compact ? 8 : 12),
          ],
          TextField(
            controller: codeController,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 26 : 32,
              letterSpacing: compact ? 8 : 12,
              fontWeight: FontWeight.w900,
              color: tone,
            ),
            maxLength: 6,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABCDEF',
              hintStyle: TextStyle(
                letterSpacing: compact ? 5 : 8,
                color: theme.textMuted.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: theme.surface.withValues(alpha: 0.92),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(compact ? 18 : 20),
                borderSide:
                    BorderSide(color: theme.border.withValues(alpha: 0.9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(compact ? 18 : 20),
                borderSide: BorderSide(color: tone, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: compact ? 18 : 24,
              ),
              errorText: joinError,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }
}
