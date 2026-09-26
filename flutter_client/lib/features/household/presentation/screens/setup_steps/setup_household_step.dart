import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/household_design.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

import '../setup_widgets.dart';

// Nombres y descripciones viven en el ARB (`setupModeName` /
// `setupModeDescription`, ICU select sobre el id). Acento e ícono salen de
// HouseholdModeDesign para que cada modo use su personalidad visual real.
const _modeIds = ['couple', 'family', 'friends', 'solo'];

/// Los ids de rol se guardan en español en el backend (`p_display_role`).
const _familyRoleIds = ['Padre', 'Madre', 'Tutor/a', 'Adolescente'];

/// Segundo paso: con quién vivís, tu nombre y tu avatar. Al continuar se crea
/// el hogar, así que es el último paso antes de tener algo propio.
class SetupHouseholdStep extends ConsumerWidget {
  final TextEditingController nameController;

  /// Foto de la cuenta de Google, para poder volver a elegirla después de
  /// probar un emoji.
  final String? accountPhotoUrl;
  final bool isCreating;
  final VoidCallback onContinue;

  const SetupHouseholdStep({
    required this.nameController,
    required this.accountPhotoUrl,
    required this.isCreating,
    required this.onContinue,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final accent = wizard.modeDesign.accent;

    return Column(
      key: const ValueKey('setup_household_v1'),
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
                Semantics(
                  header: true,
                  child: Text(
                    t.setupHouseholdTitle,
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
                  t.setupHouseholdSubtitle,
                  style: AppTypography.body.copyWith(
                    fontSize: 16,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FieldLabel(text: t.setupHouseholdModeLabel),
                const SizedBox(height: AppSpacing.sm),
                for (final modeId in _modeIds) ...[
                  _ModeOption(
                    id: modeId,
                    isSelected: wizard.selectedMode == modeId,
                    onTap: () {
                      AppHaptics.selection();
                      controller.selectMode(modeId);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                const SizedBox(height: AppSpacing.md),
                _FieldLabel(text: t.setupHouseholdNameLabel),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: nameController,
                  enabled: !isCreating,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 18,
                    color: theme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: t.authNameHint,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel(text: t.setupProfileAvatarLabel),
                const SizedBox(height: AppSpacing.sm),
                _AvatarPicker(
                  wizard: wizard,
                  accountPhotoUrl: accountPhotoUrl,
                  name: nameController,
                  onPickEmoji: controller.setAvatarEmoji,
                  onPickPhoto: controller.setAvatarUrl,
                ),
                if (wizard.householdType == HouseholdType.family) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _FieldLabel(text: t.setupFamilyRoleLabel),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final roleId in _familyRoleIds)
                        SetupFamilyChoiceChip(
                          label: _familyRoleLabel(t, roleId),
                          selected: wizard.familyRole == roleId,
                          accent: accent,
                          onTap: () => controller.setFamilyRole(roleId),
                        ),
                    ],
                  ),
                ],
                if (wizard.householdType == HouseholdType.couple) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: AppControlSizes.iconSm + 2,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          t.setupHouseholdFinanceNote,
                          style: AppTypography.caption.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        _BottomBar(
          child: ListenableBuilder(
            listenable: nameController,
            builder: (context, _) => SetupPrimaryButton(
              text: t.commonContinue,
              isLoading: isCreating,
              accent: accent,
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () {
                      AppHaptics.success();
                      onContinue();
                    },
            ),
          ),
        ),
      ],
    );
  }

  String _familyRoleLabel(AppLocalizations t, String roleId) {
    return switch (roleId) {
      'Padre' => t.setupFamilyRoleFather,
      'Madre' => t.setupFamilyRoleMother,
      'Adolescente' => t.setupFamilyRoleTeen,
      _ => t.setupFamilyRoleGuardian,
    };
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodyStrong.copyWith(
        color: context.theme.textPrimary,
      ),
    );
  }
}

/// Opción de modo compacta: ícono del modo, nombre, una línea de contexto y
/// el check. Las cuatro entran sin scroll en un teléfono común.
class _ModeOption extends StatelessWidget {
  final String id;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.id,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final HouseholdModeDesign design = HouseholdType.fromString(id).design;
    final accent = design.accent;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? accent.withValues(alpha: theme.isDarkMode ? 0.16 : 0.08)
            : theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.55)
                    : theme.border,
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isSelected ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    isSelected ? design.icon : design.outlineIcon,
                    color: accent,
                    size: AppControlSizes.iconLg,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.setupModeName(id),
                        style: AppTypography.cardTitle.copyWith(
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.setupModeDescription(id),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedContainer(
                  duration: AppMotion.normal,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accent : theme.border,
                      width: 1.4,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final SetupWizardState wizard;
  final String? accountPhotoUrl;
  final TextEditingController name;
  final ValueChanged<String> onPickEmoji;
  final ValueChanged<String> onPickPhoto;

  const _AvatarPicker({
    required this.wizard,
    required this.accountPhotoUrl,
    required this.name,
    required this.onPickEmoji,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final photo = accountPhotoUrl;
    final itemCount =
        UserAvatar.defaultAvatars.length + (photo != null ? 1 : 0);

    return SizedBox(
      height: 60,
      child: EdgeFade(
        axis: Axis.horizontal,
        fadeStart: false,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
          itemBuilder: (context, index) {
            if (photo != null && index == 0) {
              final selected = wizard.selectedAvatarUrl == photo;
              return _AvatarChoice(
                selected: selected,
                onTap: () {
                  AppHaptics.selection();
                  onPickPhoto(photo);
                },
                child: ListenableBuilder(
                  listenable: name,
                  builder: (context, _) => CustomUserAvatar(
                    name: name.text.trim(),
                    avatarUrl: photo,
                    radius: 22,
                    forceCircular: true,
                  ),
                ),
              );
            }
            final avatar =
                UserAvatar.defaultAvatars[index - (photo != null ? 1 : 0)];
            final emoji = avatar['emoji'] as String;
            final selected = wizard.selectedAvatarUrl == null &&
                wizard.selectedAvatarEmoji == emoji;
            return _AvatarChoice(
              selected: selected,
              onTap: () {
                AppHaptics.selection();
                onPickEmoji(emoji);
              },
              child: Text(
                emoji,
                style: AppTypography.body.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: theme.textPrimary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _AvatarChoice({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          width: 60,
          decoration: BoxDecoration(
            color: selected
                ? theme.primary.withValues(alpha: 0.12)
                : theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected ? theme.primary : theme.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Widget child;

  const _BottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
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
          child: child,
        ),
      ),
    );
  }
}
