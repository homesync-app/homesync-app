import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/custom_avatar_generation_service.dart';
import 'package:homesync_client/core/services/premium_avatar_motion_cache.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

/// Fecha en la que se libera el cupo mensual de creación IA (1° del mes
/// siguiente, en UTC como lo cuenta el server), o null si aún no se usó.
final customAvatarQuotaResetProvider = FutureProvider<DateTime?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final nowUtc = DateTime.now().toUtc();
  final monthStart = DateTime.utc(nowUtc.year, nowUtc.month);
  final row = await ref
      .read(supabaseClientProvider)
      .from('custom_avatar_monthly_usage')
      .select('generation_month')
      .eq('user_id', userId)
      .eq('generation_month', monthStart.toIso8601String().substring(0, 10))
      .maybeSingle();

  if (row == null) return null;
  return DateTime.utc(nowUtc.year, nowUtc.month + 1);
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
    AppSheet.show(
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
        await PremiumPaywall.show(context);
        // Si compro premium desde el paywall, retomar la seleccion pendiente
        // en vez de descartarla (antes el avatar elegido se perdia).
        final nowPremium = ref.read(premiumProvider).value ?? false;
        if (!nowPremium || !context.mounted) return;
      }

      final result = await ref
          .read(authRepositoryProvider)
          .updateProfile(avatarUrl: normalizedAvatar);
      result.match(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      // Si el avatar tiene variante animada, arrancar la descarga ya para
      // que el home lo muestre en movimiento apenas se cierre el picker.
      final animatedId = UserAvatar.animatedPremiumAvatarIdFor(
        normalizedAvatar,
      );
      if (animatedId != null) {
        PremiumAvatarMotionCache.prefetch(animatedId);
      }

      ref.invalidate(userProfileProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(customAvatarOptionsProvider);

      if (context.mounted) {
        Navigator.pop(context);
        AppSnackBar.show(
          context,
          message: AppLocalizations.of(context).avatarPickerUpdated,
          type: AppSnackBarType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.of(context).avatarPickerUpdateError('$e'),
          type: AppSnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final currentAvatar = UserAvatar.normalizeAvatarValue(
      profileAsync.whenOrNull(
        data: (p) => p?['avatar_url'] as String?,
      ),
    );
    final googlePhotoUrl = _resolveGooglePhotoUrl();
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + safeBottom,
      ),
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
          Text(
            t.avatarPickerTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.avatarPickerSubtitle,
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
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  if (googlePhotoUrl != null) ...[
                    _GoogleAvatarOption(
                      photoUrl: googlePhotoUrl,
                      isSelected: currentAvatar == googlePhotoUrl,
                      onTap: () => _updateAvatar(context, ref, googlePhotoUrl),
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
                  _AiAvatarCreationCard(
                    onCreate: () => _showCustomAvatarSourceSheet(context, ref),
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
                            onDelete: (avatar) => _deleteCustomAvatar(
                              context,
                              ref,
                              avatar,
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
                                t.avatarPickerPremiumSection,
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
                ],
              ),
            ),
          ),
        ],
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
    AppSheet.show(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
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
              Text(
                AppLocalizations.of(context).avatarPickerCustomSheetTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).avatarPickerCustomSheetBody,
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
                label: AppLocalizations.of(context).avatarPickerTakePhoto,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _generateCustomAvatar(context, ref, ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _CustomAvatarSourceButton(
                icon: Icons.photo_library_rounded,
                label:
                    AppLocalizations.of(context).avatarPickerChooseFromGallery,
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
      ref.invalidate(customAvatarQuotaResetProvider);
      if (avatarUrl == null || !context.mounted) return;
      ref.invalidate(customAvatarOptionsProvider);
      await _updateAvatar(context, ref, avatarUrl);
    } catch (e) {
      ref.invalidate(customAvatarQuotaResetProvider);
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

  Future<void> _deleteCustomAvatar(
    BuildContext context,
    WidgetRef ref,
    CustomAvatarOption avatar,
  ) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.avatarPickerDeleteCustomTitle),
        content: Text(t.avatarPickerDeleteCustomBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final service = CustomAvatarGenerationService(Supabase.instance.client);
      await service.deleteAvatar(avatarId: avatar.id);

      ref.invalidate(userProfileProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(customAvatarOptionsProvider);

      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: t.avatarPickerCustomDeleted,
          type: AppSnackBarType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: t.avatarPickerCustomDeleteError('$e'),
          type: AppSnackBarType.error,
        );
      }
    }
  }

}

class _AiAvatarCreationCard extends ConsumerWidget {
  final VoidCallback onCreate;

  const _AiAvatarCreationCard({required this.onCreate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPremium = ref.watch(premiumProvider).value ?? false;
    final quotaReset =
        isPremium ? ref.watch(customAvatarQuotaResetProvider).value : null;
    final quotaUsed = quotaReset != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accentGold.withValues(alpha: 0.16),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.avatarPickerAiCardTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.avatarPickerAiCardBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: quotaUsed
                  ? null
                  : isPremium
                      ? onCreate
                      : () => PremiumPaywall.show(context),
              icon: Icon(
                isPremium
                    ? Icons.auto_awesome_rounded
                    : Icons.lock_rounded,
                size: 18,
              ),
              label: Text(
                isPremium
                    ? t.avatarPickerAiCreateButton
                    : t.avatarPickerUnlockCustom,
              ),
            ),
          ),
          if (quotaUsed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.avatarPickerAiUsedThisMonth(
                      DateFormat.MMMMd(
                        Localizations.localeOf(context).toString(),
                      ).format(quotaReset),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
    final t = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 18),
            Text(
              t.avatarPickerCreatingTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.avatarPickerCreatingSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
  final ValueChanged<CustomAvatarOption> onDelete;

  const _CustomAvatarOptionsSection({
    required this.currentAvatar,
    required this.isPremium,
    required this.onSelect,
    required this.onDelete,
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
                  AppLocalizations.of(context).avatarPickerYourCustomSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).avatarPickerCustomKeepHint,
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
                  name: AppLocalizations.of(context).avatarPickerCustomName,
                  color: AppColors.primary.withValues(alpha: 0.18),
                  isLocked: !isPremium,
                  isSelected: currentAvatar == avatar.avatarUrl,
                  onTap: isPremium
                      ? () => onSelect(avatar.avatarUrl)
                      : () => PremiumPaywall.show(context),
                  onDelete: isPremium ? () => onDelete(avatar) : null,
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
  final VoidCallback? onDelete;

  const _PremiumAvatarOption({
    required this.avatarValue,
    required this.name,
    required this.color,
    required this.isLocked,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
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
                        // Solo la imagen: la variante animada se descarga recien
                        // al seleccionar el avatar (no viene en el APK).
                        child: CustomUserAvatar(
                          avatarUrl: avatarValue,
                          radius: 26,
                          isAnimated: !isLocked,
                          allowMotion: false,
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
          ),
          if (onDelete != null)
            Positioned(
              top: -8,
              right: -6,
              child: Material(
                color: AppColors.error,
                shape: const CircleBorder(),
                elevation: 4,
                child: IconButton(
                  tooltip:
                      AppLocalizations.of(context).avatarPickerDeleteCustom,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 30,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
        ],
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
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
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
                    AppLocalizations.of(context).avatarPickerGooglePhotoTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)
                        .avatarPickerGooglePhotoSubtitle,
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
