import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/design/app_pill.dart';

class SetupStepEyebrow extends StatelessWidget {
  final String text;

  /// Acento del modo elegido; null usa el primary global.
  final Color? accent;

  const SetupStepEyebrow({required this.text, this.accent, super.key});

  @override
  Widget build(BuildContext context) {
    return AppPill(label: text, color: accent);
  }
}

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
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: theme.textSecondary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Encabezado editorial de step: título hero + subtítulo de apoyo, con la
/// firma de la app (regla horizontal + kicker) opcional vía [kicker].
class SetupHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? kicker;

  const SetupHeading({
    required this.title,
    required this.subtitle,
    this.kicker,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            height: 1.02,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 19,
            color: theme.textSecondary.withValues(alpha: 0.84),
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (kicker != null) ...[
          const SizedBox(height: 10),
          SetupKicker(text: kicker!),
        ],
      ],
    );
  }
}

/// Regla horizontal + texto corto, la firma editorial del home solo.
class SetupKicker extends StatelessWidget {
  final String text;

  const SetupKicker({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Container(
          width: 24,
          height: 1.5,
          color: theme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }
}

class SetupSecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  /// Acento del modo elegido; null usa el primary global.
  final Color? accent;

  const SetupSecondaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tone = accent ?? theme.primary;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: AppControlSizes.iconMd),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.surface.withValues(alpha: 0.9),
        foregroundColor: tone,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: tone.withValues(alpha: 0.28),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class SetupFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const SetupFeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppInsets.itemGap),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.85)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: AppControlSizes.iconLg),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: theme.textSecondary.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SetupStrategyTip extends StatelessWidget {
  final String title;
  final String desc;
  final bool active;

  /// Acento del modo elegido; null usa el primary global.
  final Color? accent;

  const SetupStrategyTip({
    required this.title,
    required this.desc,
    required this.active,
    this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tone = accent ?? theme.primary;
    return AnimatedContainer(
      duration: AppMotion.slow,
      margin: const EdgeInsets.only(bottom: AppInsets.itemGap),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active
            ? tone.withValues(alpha: 0.08)
            : theme.surface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: active
              ? tone.withValues(alpha: 0.28)
              : theme.cardBorder.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: active ? tone : theme.textMuted,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: active ? tone : theme.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? tone.withValues(alpha: 0.14)
              : theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected
                ? tone.withValues(alpha: 0.3)
                : theme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? tone : theme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class SetupOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isSelected;
  final Color tone;
  final VoidCallback onTap;

  const SetupOptionTile({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isSelected,
    required this.tone,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? tone.withValues(alpha: 0.5)
                : theme.border.withValues(alpha: 0.8),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? tone.withValues(alpha: 0.08)
                  : theme.shadowBase.withValues(alpha: 0.045),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, color: tone, size: AppControlSizes.iconLg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textSecondary.withValues(alpha: 0.84),
                      fontSize: 13.5,
                      height: 1.24,
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
                color: isSelected ? tone : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? tone
                      : theme.border.withValues(alpha: 0.9),
                  width: 1.3,
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
    );
  }
}

class SetupOnboardingIllustration extends StatelessWidget {
  final String imagePath;

  const SetupOnboardingIllustration({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final illustrationWidth =
              (constraints.maxWidth * 0.92).clamp(260.0, 420.0);

          return SizedBox(
            width: illustrationWidth,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
