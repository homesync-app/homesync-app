import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/custom_avatar_generation_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_avatar.dart';

final customAvatarOptionsProvider =
    FutureProvider<List<CustomAvatarOption>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final List<Map<String, dynamic>> rows = await ref
      .read(supabaseClientProvider)
      .from('custom_avatar_generations')
      .select('id, avatar_url, created_at')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(8);

  return rows.map<CustomAvatarOption>((row) {
    return CustomAvatarOption(
      id: row['id'] as String,
      avatarUrl: row['avatar_url'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }).toList();
});

class CustomAvatarOption {
  final String id;
  final String avatarUrl;
  final DateTime createdAt;

  const CustomAvatarOption({
    required this.id,
    required this.avatarUrl,
    required this.createdAt,
  });
}

class AvatarPickerSheet extends ConsumerWidget {
  const AvatarPickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AvatarPickerSheet(),
    );
  }

  Future<void> _updateAvatar(
    BuildContext context,
    WidgetRef ref,
    String avatarValue,
  ) async {
    try {
      final normalizedAvatar =
          UserAvatar.normalizeAvatarValue(avatarValue) ?? avatarValue;
      final isPremiumAvatar = UserAvatar.isPremiumAvatarValue(normalizedAvatar);
      final isPremium = ref.read(premiumProvider).value ?? false;
      if (isPremiumAvatar && !isPremium) {
        PremiumPaywall.show(context);
        return;
      }

      final result = await ref
          .read(authRepositoryProvider)
          .updateProfile(avatarUrl: normalizedAvatar);
      result.match(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      ref.invalidate(userProfileProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(customAvatarOptionsProvider);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar actualizado con exito'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar avatar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final currentAvatar = UserAvatar.normalizeAvatarValue(
      profileAsync.whenOrNull(
        data: (p) => p?['avatar_url'] as String?,
      ),
    );
    final googlePhotoUrl = _resolveGooglePhotoUrl();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 40),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Tu Identidad Visual',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Elegi un avatar de la coleccion o crea el tuyo propio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    if (googlePhotoUrl != null) ...[
                      _GoogleAvatarOption(
                        photoUrl: googlePhotoUrl,
                        isSelected: currentAvatar == googlePhotoUrl,
                        onTap: () =>
                            _updateAvatar(context, ref, googlePhotoUrl),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: UserAvatar.defaultAvatars.map((animal) {
                        final normalizedEmoji = UserAvatar.normalizeAvatarValue(
                              animal['emoji'] as String?,
                            ) ??
                            '';
                        final isSelected = currentAvatar == normalizedEmoji;
                        return _AvatarOption(
                          emoji: normalizedEmoji,
                          color: animal['color'],
                          isSelected: isSelected,
                          onTap: () => _updateAvatar(
                            context,
                            ref,
                            normalizedEmoji,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Consumer(
                      builder: (context, ref, _) {
                        final isPremium =
                            ref.watch(premiumProvider).value ?? false;
                        return Column(
                          children: [
                            _CustomAvatarOptionsSection(
                              currentAvatar: currentAvatar,
                              isPremium: isPremium,
                              onSelect: (avatarUrl) => _updateAvatar(
                                context,
                                ref,
                                avatarUrl,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.accentGold,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Avatares premium',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 14,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: UserAvatar.premiumAvatars.map((avatar) {
                                final value =
                                    UserAvatar.premiumAvatarValue(avatar);
                                final legacyValue =
                                    'premium://${avatar['url'] as String}';
                                final isSelected = currentAvatar == value ||
                                    currentAvatar == legacyValue;
                                return _PremiumAvatarOption(
                                  avatarValue: value,
                                  name: avatar['name'] as String,
                                  color: avatar['color'] as Color,
                                  isLocked: !isPremium,
                                  isSelected: isSelected,
                                  onTap: isPremium
                                      ? () => _updateAvatar(
                                            context,
                                            ref,
                                            value,
                                          )
                                      : () => PremiumPaywall.show(context),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Consumer(
                      builder: (context, ref, _) {
                        final isPremium =
                            ref.watch(premiumProvider).value ?? false;
                        return OutlinedButton.icon(
                          onPressed: isPremium
                              ? () => _showCustomAvatarSourceSheet(context, ref)
                              : () => PremiumPaywall.show(context),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(
                            isPremium
                                ? 'Crear avatar personalizado (1 por mes)'
                                : 'Desbloquear avatar personalizado',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveGooglePhotoUrl() {
    final currentUser = fa.FirebaseAuth.instance.currentUser;
    final directPhotoUrl = currentUser?.photoURL?.trim();
    if (_isValidNetworkAvatar(directPhotoUrl)) {
      return directPhotoUrl;
    }

    for (final profile in currentUser?.providerData ?? const <fa.UserInfo>[]) {
      if (profile.providerId != 'google.com') continue;

      final providerPhotoUrl = profile.photoURL?.trim();
      if (_isValidNetworkAvatar(providerPhotoUrl)) {
        return providerPhotoUrl;
      }
    }

    return null;
  }

  bool _isValidNetworkAvatar(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  void _showCustomAvatarSourceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Avatar personalizado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tenés 1 creación por mes. Se guarda como avatar nuevo y conservamos tus últimos 6 personalizados. Si dejás Premium, quedan guardados pero bloqueados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20),
              _CustomAvatarSourceButton(
                icon: Icons.photo_camera_rounded,
                label: 'Sacar foto',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _generateCustomAvatar(context, ref, ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _CustomAvatarSourceButton(
                icon: Icons.photo_library_rounded,
                label: 'Elegir de galería',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _generateCustomAvatar(context, ref, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateCustomAvatar(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final service = CustomAvatarGenerationService(Supabase.instance.client);

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _CustomAvatarLoadingDialog(),
      );
    }

    try {
      final avatarUrl = await service.generate(source: source);
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (avatarUrl == null || !context.mounted) return;
      ref.invalidate(customAvatarOptionsProvider);
      await _updateAvatar(context, ref, avatarUrl);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ignore: unused_element
  void _showCustomAvatarDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avatar personalizado'),
        content: TextField(
          controller: controller,
          maxLength: 2,
          decoration: const InputDecoration(
            hintText: 'Ej: 🌞',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(context);
                _updateAvatar(context, ref, value);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _CustomAvatarSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CustomAvatarSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomAvatarLoadingDialog extends StatelessWidget {
  const _CustomAvatarLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 18),
            Text(
              'Creando tu avatar...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Puede tardar unos segundos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomAvatarOptionsSection extends ConsumerWidget {
  final String? currentAvatar;
  final bool isPremium;
  final ValueChanged<String> onSelect;

  const _CustomAvatarOptionsSection({
    required this.currentAvatar,
    required this.isPremium,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customAvatars = ref.watch(customAvatarOptionsProvider);

    return customAvatars.when(
      data: (avatars) {
        if (avatars.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tus personalizados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Guardamos los últimos 6 generados por IA.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: avatars.map((avatar) {
                return _PremiumAvatarOption(
                  avatarValue: avatar.avatarUrl,
                  name: 'Personalizado',
                  color: AppColors.primary.withValues(alpha: 0.18),
                  isLocked: !isPremium,
                  isSelected: currentAvatar == avatar.avatarUrl,
                  onTap: isPremium
                      ? () => onSelect(avatar.avatarUrl)
                      : () => PremiumPaywall.show(context),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PremiumAvatarOption extends StatelessWidget {
  final String avatarValue;
  final String name;
  final Color color;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumAvatarOption({
    required this.avatarValue,
    required this.name,
    required this.color,
    required this.isLocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 96,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isLocked ? 0.35 : 0.7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isLocked ? 0.18 : 0.4),
              blurRadius: 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isLocked ? 0.42 : 1,
                  child: CustomUserAvatar(
                    avatarUrl: avatarValue,
                    radius: 26,
                    isAnimated: !isLocked,
                  ),
                ),
                if (isLocked)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLocked
                    ? Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.74)
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 11,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleAvatarOption extends StatelessWidget {
  const _GoogleAvatarOption({
    required this.photoUrl,
    required this.isSelected,
    required this.onTap,
  });

  final String photoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CustomUserAvatar(
              avatarUrl: photoUrl,
              radius: 28,
              showBorder: true,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto de Google',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Usa la imagen de tu cuenta de Google como avatar.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? AppColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
