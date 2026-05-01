import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/theme_palettes.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class SettingsLoadingCard extends StatelessWidget {
  final double height;

  const SettingsLoadingCard({
    super.key,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: theme.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const SettingsSectionLabel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: theme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsAppearanceCard extends StatelessWidget {
  final Color effectiveColor;
  final bool isPremium;
  final ValueChanged<ThemePalette> onPaletteTap;
  final VoidCallback onLockedTap;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsAppearanceCard({
    super.key,
    required this.effectiveColor,
    required this.isPremium,
    required this.onPaletteTap,
    required this.onLockedTap,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: theme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apariencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      'Elige el tema visual de la app',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsThemeModeSelector(
            currentMode: currentThemeMode,
            onModeChanged: onThemeModeChanged,
          ),
          const SizedBox(height: 16),
          SettingsThemePalettePicker(
            effectiveColor: effectiveColor,
            isPremium: isPremium,
            onPaletteTap: onPaletteTap,
            onLockedTap: onLockedTap,
          ),
        ],
      ),
    );
  }
}

class SettingsThemePalettePicker extends StatelessWidget {
  final Color effectiveColor;
  final bool isPremium;
  final ValueChanged<ThemePalette> onPaletteTap;
  final VoidCallback onLockedTap;

  const SettingsThemePalettePicker({
    super.key,
    required this.effectiveColor,
    required this.isPremium,
    required this.onPaletteTap,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    const palettes = ThemePalette.all;
    const freePaletteNames = {'Naranja (Original)'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Color del Tema',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 10,
                      color: AppColors.accentGold,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: palettes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final palette = palettes[index];
              final isSelected =
                  effectiveColor.toARGB32() == palette.primary.toARGB32();
              final isFreePalette = freePaletteNames.contains(palette.name);
              final isLocked = !isPremium && !isFreePalette;

              return GestureDetector(
                onTap: () => isLocked ? onLockedTap() : onPaletteTap(palette),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: theme.surface, width: 3)
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: palette.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : (isLocked)
                          ? Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 18,
                            )
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const SettingsThemeModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final options = [
      (ThemeMode.light, Icons.light_mode_rounded, 'Claro'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Oscuro'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Sistema'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modo del Tema',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((opt) {
            final (mode, icon, label) = opt;
            final isSelected = currentMode == mode;
            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: mode != ThemeMode.system ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onModeChanged(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primary.withValues(alpha: 0.12)
                          : theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.primary
                            : theme.border.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color:
                              isSelected ? theme.primary : theme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? theme.primary
                                : theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

Future<String?> showSettingsRenameProfileDialog(
  BuildContext context, {
  required String currentName,
}) {
  final theme = context.theme;
  final controller = TextEditingController(text: currentName);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Cambiar nombre',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Nombre',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

class SettingsPremiumCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onTapPlans;
  final List<String> premiumFeatures;

  const SettingsPremiumCard({
    super.key,
    required this.isPremium,
    required this.onTapPlans,
    required this.premiumFeatures,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [
                  const Color(0xFFFDE68A),
                  const Color(0xFFF59E0B).withValues(alpha: 0.1),
                ]
              : [
                  theme.primary.withValues(alpha: 0.05),
                  theme.surface,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isPremium
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : theme.border.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? const Color(0xFFF59E0B) : theme.shadow)
                .withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPremium
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                      : theme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPremium
                      ? Icons.auto_awesome_rounded
                      : Icons.star_outline_rounded,
                  color: isPremium ? const Color(0xFFB45309) : theme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOMESYNC PREMIUM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isPremium
                            ? const Color(0xFF92400E)
                            : theme.textPrimary,
                      ),
                    ),
                    Text(
                      'Modo simulador para testing',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPremium
                            ? const Color(0xFFB45309).withValues(alpha: 0.8)
                            : theme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onTapPlans,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPremium ? const Color(0xFFF59E0B) : theme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(isPremium ? 'Gestionar' : 'Ver Planes'),
              ),
            ],
          ),
          if (isPremium) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Funciones habilitadas:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 8),
            ...premiumFeatures.map(
              (feature) => SettingsPremiumFeatureItem(text: feature),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsPremiumFeatureItem extends StatelessWidget {
  final String text;

  const SettingsPremiumFeatureItem({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onNameTap;

  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onAvatarTap,
    required this.onNameTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Hero(
                  tag: 'user-profile-avatar',
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (avatarUrl?.startsWith('premium://') == true)
                        CustomUserAvatar(
                          name: name,
                          avatarUrl: avatarUrl,
                          radius: 36,
                          isAnimated: true,
                          isPriority: true,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomUserAvatar(
                            name: name,
                            avatarUrl: avatarUrl,
                            radius: 36,
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: theme.surface, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SettingsProfileActionButton(
                  icon: Icons.pets_rounded,
                  label: 'Avatar',
                  onTap: onAvatarTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SettingsProfileActionButton(
                  icon: Icons.badge_rounded,
                  label: 'Nombre',
                  onTap: onNameTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SettingsProfileActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SettingsMinorPremiumCard
// ---------------------------------------------------------------------------

/// Tarjeta que se muestra a miembros menores de edad (child/teen) en lugar
/// de la tarjeta de compra de premium.
///
/// Informa que existen funciones premium pero **no** muestra ni redirige al
/// paywall — esa decision es exclusiva de los adultos del hogar.
///
/// [isChild] determina el copy:
///  - true  → "pedi a tus papas" (niño)
///  - false → "los adultos pueden activar" (adolescente)
class SettingsMinorPremiumCard extends StatelessWidget {
  final bool isChild;

  const SettingsMinorPremiumCard({
    super.key,
    required this.isChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final body = isChild
        ? 'Pedi a tus papas que activen el plan para desbloquear avatares exclusivos, colores y mas 🌟'
        : 'Los adultos del hogar pueden activar el plan premium para desbloquear funciones adicionales.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Funciones Premium',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.textSecondary,
                    height: 1.4,
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
