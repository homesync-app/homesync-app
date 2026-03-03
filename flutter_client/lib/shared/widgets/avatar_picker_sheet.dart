import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
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
      BuildContext context, WidgetRef ref, String emoji) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No autenticado');

      await Supabase.instance.client
          .from('users')
          .update({'avatar_url': emoji}).eq('id', user.id);

      ref.invalidate(userProfileProvider);
      ref.invalidate(recentActivityProvider);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar actualizado con éxito 🎉'),
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
            'Elegí un avatar de la colección o creá el tuyo propio',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
                        onTap: () => _updateAvatar(context, ref, animal['emoji']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Text(
                        'Personajes 3D',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    clipBehavior: Clip.none,
                    child: Row(
                      children: UserAvatar.premiumAvatars.map((char) {
                        final premiumUrl = 'premium://${char['url']}';
                        final isSelected = currentAvatar == premiumUrl;

                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () => _updateAvatar(context, ref, premiumUrl),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? char['color'].withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(28),
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 3,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.25),
                                              blurRadius: 20,
                                              offset: const Offset(0, 6),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: CustomUserAvatar(
                                    avatarUrl: premiumUrl,
                                    radius: 40,
                                    isAnimated: true,
                                    isPriority: isSelected,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  char['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _CustomEmojiSection(
                    onSelected: (emoji) => _updateAvatar(context, ref, emoji),
                  ),
                ],
              ),
            ),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 34),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomEmojiSection extends StatefulWidget {
  final Function(String) onSelected;

  const _CustomEmojiSection({required this.onSelected});

  @override
  State<_CustomEmojiSection> createState() => _CustomEmojiSectionState();
}

class _CustomEmojiSectionState extends State<_CustomEmojiSection> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text(
            '¿Querés algo diferente?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 24),
                  decoration: InputDecoration(
                    hintText: '💡 Pegá un emoji',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      widget.onSelected(val);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Cualquier emoji que elijas se adaptará a tu perfil',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
