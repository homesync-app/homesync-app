import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

import 'video_avatar_player.dart';

class UserAvatar {
  static const Map<String, String> _legacyAvatarAliases = {
    'Ã°Å¸ÂÂ±': '\u{1F431}',
    'Ã°Å¸ÂÂ¶': '\u{1F436}',
    'Ã°Å¸Â¦Å ': '\u{1F98A}',
    'Ã°Å¸ÂÂ¼': '\u{1F43C}',
    'Ã°Å¸ÂÂ°': '\u{1F430}',
    'Ã°Å¸ÂÂ»': '\u{1F43B}',
    'Ã°Å¸ÂÂ¨': '\u{1F428}',
    'Ã°Å¸ÂÂ¯': '\u{1F42F}',
    'Ã°Å¸Â¦â€¹': '\u{1F98B}',
    'Ã°Å¸Ââ„¢': '\u{1F419}',
    'Ã°Å¸Â¦Â©': '\u{1F9A9}',
    'Ã°Å¸ÂÂ§': '\u{1F427}',
    'Ã°Å¸Â¦â€ž': '\u{1F984}',
    'Ã°Å¸Ââ€°': '\u{1F409}',
    'Ã°Å¸Â¦â€™': '\u{1F992}',
    'Ã°Å¸Â¦Â¥': '\u{1F9A5}',
  };

  static const List<Map<String, dynamic>> defaultAvatars = [
    {'emoji': '\u{1F431}', 'color': Color(0xFFFFD180), 'name': 'Gato'},
    {'emoji': '\u{1F436}', 'color': Color(0xFF80D8FF), 'name': 'Perro'},
    {'emoji': '\u{1F98A}', 'color': Color(0xFFFFAB40), 'name': 'Zorro'},
    {'emoji': '\u{1F43C}', 'color': Color(0xFFB9F6CA), 'name': 'Panda'},
    {'emoji': '\u{1F430}', 'color': Color(0xFFFF80AB), 'name': 'Conejo'},
    {'emoji': '\u{1F43B}', 'color': Color(0xFFFFD54F), 'name': 'Oso'},
    {'emoji': '\u{1F428}', 'color': Color(0xFFCFD8DC), 'name': 'Koala'},
    {'emoji': '\u{1F42F}', 'color': Color(0xFFFFCC80), 'name': 'Tigre'},
    {'emoji': '\u{1F98B}', 'color': Color(0xFFE1BEE7), 'name': 'Mariposa'},
    {'emoji': '\u{1F419}', 'color': Color(0xFFFFCDD2), 'name': 'Pulpo'},
    {'emoji': '\u{1F9A9}', 'color': Color(0xFFF8BBD0), 'name': 'Flamenco'},
    {'emoji': '\u{1F427}', 'color': Color(0xFFE0E0E0), 'name': 'Ping\u00FCino'},
    {'emoji': '\u{1F984}', 'color': Color(0xFFF3E5F5), 'name': 'Unicornio'},
    {'emoji': '\u{1F409}', 'color': Color(0xFFC8E6C9), 'name': 'Drag\u00F3n'},
    {'emoji': '\u{1F992}', 'color': Color(0xFFFFF9C4), 'name': 'Jirafa'},
    {'emoji': '\u{1F9A5}', 'color': Color(0xFFD7CCC8), 'name': 'Pereza'},
  ];

  static const List<Map<String, dynamic>> premiumAvatars = [
    {
      'id': 'premium_boy',
      'url':
          'https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/avatars/boy.png',
      'name': 'Chico 3D',
      'color': Color(0xFFE3F2FD)
    },
    {
      'id': 'premium_girl',
      'url':
          'https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/avatars/girl.png',
      'name': 'Chica 3D',
      'color': Color(0xFFFCE4EC)
    },
    {
      'id': 'premium_cat',
      'url': 'assets/images/gato_premium_v2.mp4',
      'name': 'Gato Animado',
      'color': Color(0xFFFFF3E0)
    },
    {
      'id': 'premium_dog',
      'url':
          'https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/avatars/dog.png',
      'name': 'Perro 3D',
      'color': Color(0xFFE8EAF6)
    },
    {
      'id': 'premium_robot',
      'url':
          'https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/avatars/robot.png',
      'name': 'Robot 3D',
      'color': Color(0xFFE0F2F1)
    },
    {
      'id': 'premium_bird',
      'url':
          'https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/avatars/bird.png',
      'name': 'P\u00E1jaro 3D',
      'color': Color(0xFFF3E5F5)
    },
  ];

  static Color getColorForEmoji(String emoji) {
    final normalizedEmoji = normalizeAvatarValue(emoji) ?? emoji;
    final avatar = defaultAvatars.firstWhere(
      (a) => normalizeAvatarValue(a['emoji'] as String) == normalizedEmoji,
      orElse: () => {'color': AppColors.primary.withValues(alpha: 0.15)},
    );
    return avatar['color'] as Color;
  }

  static String? normalizeAvatarValue(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return trimmed;
    return _legacyAvatarAliases[trimmed] ?? trimmed;
  }
}

class CustomUserAvatar extends ConsumerWidget {
  final String? name;
  final String? userId;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool isAnimated;
  final bool isPriority;
  final bool forceCircular;

  const CustomUserAvatar({
    super.key,
    this.name,
    this.userId,
    this.avatarUrl,
    this.radius = 20,
    this.onTap,
    this.showBorder = false,
    this.isAnimated = false,
    this.isPriority = false,
    this.forceCircular = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPremium = avatarUrl?.startsWith('premium://') ?? false;
    final admin = ref.watch(adminProvider);

    Widget avatarContent;
    if (isPremium && !forceCircular) {
      avatarContent = _PremiumCharacterAvatar(
        url: avatarUrl!.replaceFirst('premium://', ''),
        radius: radius,
        isAnimated: isAnimated,
        isPriority: isPriority,
        onTap: onTap,
      );
    } else if (isAnimated || isPriority) {
      avatarContent = _AnimatedAvatar(
        name: name,
        avatarUrl: avatarUrl,
        radius: radius,
        onTap: onTap,
        showBorder: showBorder,
        isPriority: isPriority,
      );
    } else {
      avatarContent = _StaticAvatar(
        name: name,
        avatarUrl: avatarUrl,
        radius: radius,
        onTap: onTap,
        showBorder: showBorder,
      );
    }

    if (AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        userId != null &&
        userId != AdminTestingConfig.adminTestingUserId) {
      return GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Admin: Impersonaci\u00F3n'),
              content:
                  Text('\u00BFDeseas ver la app como ${name ?? 'este usuario'}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(adminProvider.notifier).impersonate(userId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viendo como: ${name ?? userId}')),
                    );
                  },
                  child: const Text('Impersonar'),
                ),
              ],
            ),
          );
        },
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}

class _StaticAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;

  const _StaticAvatar({
    this.name,
    this.avatarUrl,
    this.radius = 20,
    this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AvatarContent(
      name: name,
      avatarUrl: avatarUrl,
      radius: radius,
      onTap: onTap,
      showBorder: showBorder,
    );
  }
}

class _AnimatedAvatar extends StatefulWidget {
  final String? name;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool isPriority;

  const _AnimatedAvatar({
    this.name,
    this.avatarUrl,
    this.radius = 20,
    this.onTap,
    this.showBorder = false,
    this.isPriority = false,
  });

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isPriority)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: widget.radius * 2 * (1 + _pulseAnimation.value * 0.5),
                height: widget.radius * 2 * (1 + _pulseAnimation.value * 0.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentGold
                        .withValues(alpha: 1 - _pulseAnimation.value),
                    width: 2,
                  ),
                ),
              );
            },
          ),
        ScaleTransition(
          scale: _scaleAnimation,
          child: _AvatarContent(
            name: widget.name,
            avatarUrl: widget.avatarUrl,
            radius: widget.radius,
            onTap: widget.onTap,
            showBorder: widget.showBorder,
            borderColor:
                widget.isPriority ? AppColors.accentGold : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AvatarContent extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;

  const _AvatarContent({
    this.name,
    this.avatarUrl,
    this.radius = 20,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = UserAvatar.normalizeAvatarValue(avatarUrl);
    final bool hasAvatar =
        normalizedAvatarUrl != null && normalizedAvatarUrl.trim().isNotEmpty;
    final int avatarCacheSize =
        (radius * 2 * MediaQuery.devicePixelRatioOf(context)).round();

    final String cleanUrl =
        (normalizedAvatarUrl ?? '').replaceFirst('premium://', '');
    final bool isAsset = hasAvatar && cleanUrl.startsWith('assets/');

    final bool isEmoji =
        hasAvatar && !isAsset && normalizedAvatarUrl.runes.length <= 2;
    final bool isNetwork = hasAvatar && cleanUrl.startsWith('http');

    final color = isEmoji
        ? UserAvatar.getColorForEmoji(normalizedAvatarUrl)
        : ((isNetwork || isAsset) ? Colors.transparent : AppColors.primary);

    final safeName = name?.trim() ?? '';
    final initial =
        safeName.isNotEmpty ? safeName.substring(0, 1).toUpperCase() : '?';

    final avatarWidget = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: isEmoji
            ? color
            : ((isNetwork || isAsset)
                ? Colors.grey.shade100
                : AppColors.primary),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: borderColor ?? Colors.white, width: 2)
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: ClipOval(
        child: isAsset
            ? Image.asset(
                cleanUrl,
                fit: BoxFit.cover,
                cacheWidth: avatarCacheSize,
                cacheHeight: avatarCacheSize,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: radius * 0.9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : isNetwork
                ? Image.network(
                    cleanUrl,
                    fit: BoxFit.cover,
                    cacheWidth: avatarCacheSize,
                    cacheHeight: avatarCacheSize,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: radius * 0.9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: isEmoji
                        ? Text(
                            normalizedAvatarUrl,
                            style: TextStyle(
                              fontSize: radius * 1.0,
                              height: 1.1,
                            ),
                          )
                        : Text(
                            initial,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: radius * 0.9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

class _PremiumCharacterAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final bool isAnimated;
  final bool isPriority;
  final VoidCallback? onTap;

  const _PremiumCharacterAvatar({
    required this.url,
    required this.radius,
    required this.isAnimated,
    required this.isPriority,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String cleanUrl =
        url.startsWith('premium://') ? url.replaceFirst('premium://', '') : url;

    final bool isVideo = cleanUrl.toLowerCase().endsWith('.mp4');
    final bool shouldPlayVideo =
        isVideo && (isAnimated || isPriority || radius >= 32);

    final double size = isVideo ? radius * 2.8 : radius * 2.8;
    final int premiumCacheSize =
        (size * MediaQuery.devicePixelRatioOf(context)).round();

    final bool isAsset = cleanUrl.startsWith('assets/');

    Widget contentWidget;

    if (isVideo && shouldPlayVideo) {
      contentWidget = VideoAvatarPlayer(
        url: cleanUrl,
        size: size,
        isAsset: isAsset,
      );
    } else if (isVideo) {
      contentWidget = _buildStaticVideoFallback(cleanUrl, size);
    } else if (isAsset) {
      contentWidget = Image.asset(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        cacheWidth: premiumCacheSize,
        cacheHeight: premiumCacheSize,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                _getFallbackIcon(cleanUrl),
                size: radius,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      );
    } else {
      contentWidget = Image.network(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        cacheWidth: premiumCacheSize,
        cacheHeight: premiumCacheSize,
        filterQuality: FilterQuality.low,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: radius * 0.6,
                height: radius * 0.6,
                child: CircularProgressIndicator(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                _getFallbackIcon(cleanUrl),
                size: radius,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      );
    }

    Widget content = contentWidget;

    if (isAnimated || isPriority) {
      content = _FloatingAnimation(child: content);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }

  Widget _buildStaticVideoFallback(String cleanUrl, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Center(
          child: Icon(
            _getFallbackIcon(cleanUrl),
            size: radius,
            color: AppColors.primary.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }

  IconData _getFallbackIcon(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('cat')) return Icons.pets;
    if (lowerUrl.contains('dog')) return Icons.cruelty_free;
    if (lowerUrl.contains('robot')) return Icons.smart_toy;
    if (lowerUrl.contains('bird')) return Icons.flutter_dash;
    if (lowerUrl.contains('boy')) return Icons.face;
    if (lowerUrl.contains('girl')) return Icons.face_3;
    return Icons.star;
  }
}

class _FloatingAnimation extends StatefulWidget {
  final Widget child;

  const _FloatingAnimation({required this.child});

  @override
  State<_FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<_FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
