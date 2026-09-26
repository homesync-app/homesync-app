import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

/// Piezas compartidas por los pasos del onboarding.

class SetupSupportBullet extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const SetupSupportBullet({
    required this.icon,
    required this.color,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: AppControlSizes.iconMd),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: theme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SetupPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Acento del modo elegido; null usa el primary global.
  final Color? accent;

  const SetupPrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tone = accent ?? theme.primary;
    // Texto legible sobre el tinte al 20%: el primary global ya tiene su
    // variante oscura; los acentos de modo se oscurecen en runtime.
    final foreground = accent == null
        ? AppColors.primaryDark
        : Color.lerp(tone, Colors.black, 0.35)!;
    final isEnabled = onPressed != null && !isLoading;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: tone.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? tone.withValues(alpha: 0.2)
              : theme.surface.withValues(alpha: 0.5),
          foregroundColor: isEnabled ? foreground : theme.textMuted,
          disabledBackgroundColor: theme.surface.withValues(alpha: 0.5),
          disabledForegroundColor: theme.textMuted,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: isEnabled
                  ? tone.withValues(alpha: 0.38)
                  : theme.border.withValues(alpha: 0.85),
              width: 1.4,
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: tone,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: AppTypography.cardTitle.copyWith(fontSize: 18),
              ),
      ),
    );
  }
}

class SetupFamilyPanel extends StatelessWidget {
  final Widget child;

  const SetupFamilyPanel({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.cardBorder.withValues(alpha: 0.85)),
        boxShadow: theme.cardShadow,
      ),
      child: child,
    );
  }
}

class SetupFamilyChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Acento del modo elegido; null usa el primary global.
  final Color? accent;

  const SetupFamilyChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tone = accent ?? theme.primary;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? tone.withValues(alpha: 0.14) : theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? tone.withValues(alpha: 0.3) : theme.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? tone : theme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
