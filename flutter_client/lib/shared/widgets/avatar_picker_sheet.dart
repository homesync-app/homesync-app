import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homesync_client/core/providers/premium_provider.dart';
import 'user_avatar.dart';

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
    String emoji,
  ) async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null || userId.isEmpty) throw Exception('No autenticado');

      await Supabase.instance.client
          .from('users')
          .update({'avatar_url': emoji}).eq('id', userId);

      ref.invalidate(userProfileProvider);
      ref.invalidate(recentActivityProvider);

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
    final currentAvatar = profileAsync.whenOrNull(
      data: (p) => p?['avatar_url'] as String?,
    );

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
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: UserAvatar.defaultAvatars.map((animal) {
                        final isSelected = currentAvatar == animal['emoji'];
                        return _AvatarOption(
                          emoji: animal['emoji'],
                          color: animal['color'],
                          isSelected: isSelected,
                          onTap: () => _updateAvatar(
                            context,
                            ref,
                            animal['emoji'] as String,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Consumer(
                      builder: (context, ref, _) {
                        final isPremium = ref.watch(premiumProvider);
                        return OutlinedButton.icon(
                          onPressed: isPremium
                              ? () => _showCustomAvatarDialog(context, ref)
                              : () => PremiumPaywall.show(context),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(
                            isPremium
                                ? 'Crear avatar personalizado'
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
