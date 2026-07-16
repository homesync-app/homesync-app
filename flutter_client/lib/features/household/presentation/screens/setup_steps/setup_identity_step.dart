import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

import '../setup_widgets.dart';

/// Paso 2: nombre + avatar del usuario.
class SetupIdentityStep extends ConsumerWidget {
  final TextEditingController nameController;

  const SetupIdentityStep({required this.nameController, super.key});

  Color _avatarAccentColor(AppThemeColors theme, SetupWizardState wizard) {
    final value = wizard.resolvedAvatarValue;
    if (value.startsWith('http') || value.startsWith('assets/')) {
      return theme.primary.withValues(alpha: 0.16);
    }
    return UserAvatar.getColorForEmoji(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final accentColor = _avatarAccentColor(theme, wizard);

    return Padding(
      key: const ValueKey('identity_v3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ListenableBuilder(
          listenable: nameController,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              SetupStepEyebrow(text: t.setupProfileEyebrow),
              const SizedBox(height: 10),
              SetupHeading(
                title: t.setupProfileTitle,
                subtitle: t.setupProfileSubtitle,
              ),
              const SizedBox(height: 32),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.32),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowBase.withValues(alpha: 0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomUserAvatar(
                          name: nameController.text.trim(),
                          avatarUrl: wizard.resolvedAvatarValue,
                          radius: 52,
                          forceCircular: true,
                        ),
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.22),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                wizard.selectedAvatarUrl != null
                    ? t.setupProfileGoogleAvatarHint
                    : t.setupProfileEmptyAvatarHint,
                style: AppTypography.body.copyWith(
                  height: 1.45,
                  color: theme.textSecondary.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: nameController,
                autofocus: true,
                style: AppTypography.cardTitle.copyWith(fontSize: 19),
                decoration: InputDecoration(
                  hintText: t.authNameHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: theme.surface.withValues(alpha: 0.9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                      color: theme.border.withValues(alpha: 0.9),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                      color: theme.primary,
                      width: 1.6,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(22),
                ),
                onSubmitted: (_) {
                  if (nameController.text.trim().isNotEmpty) {
                    controller.goTo(SetupStep.mode);
                  }
                },
              ),
              const SizedBox(height: 22),
              Text(
                t.setupProfileAvatarLabel,
                style: AppTypography.caption.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 78,
                child: EdgeFade(
                  axis: Axis.horizontal,
                  fadeStart: false,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: UserAvatar.defaultAvatars.length,
                    itemBuilder: (context, index) {
                      final avatar = UserAvatar.defaultAvatars[index];
                      final emoji = avatar['emoji'] as String;
                      final isSelected = wizard.selectedAvatarUrl == null &&
                          wizard.selectedAvatarEmoji == emoji;

                      return GestureDetector(
                        onTap: () {
                          AppHaptics.selection();
                          controller.setAvatarEmoji(emoji);
                        },
                        child: AnimatedContainer(
                          duration: AppMotion.normal,
                          width: 68,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primary.withValues(alpha: 0.12)
                                : theme.surface.withValues(alpha: 0.84),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primary
                                  : theme.border.withValues(alpha: 0.9),
                              width: isSelected ? 1.8 : 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primary
                                          .withValues(alpha: 0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: AppTypography.body.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SetupPrimaryButton(
                text: t.commonContinue,
                onPressed: nameController.text.trim().isEmpty
                    ? null
                    : () {
                        AppHaptics.success();
                        controller.goTo(SetupStep.mode);
                      },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
