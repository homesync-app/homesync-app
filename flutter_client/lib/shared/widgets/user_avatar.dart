import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

import 'video_avatar_player.dart';

class UserAvatar {
  static const Map<String, String> _legacyAvatarAliases = {
    'Ã°Å¸±': '\u{1F431}',
    'Ã°Å¸¶': '\u{1F436}',
    'Ã°Å¸¦Å ': '\u{1F98A}',
    'Ã°Å¸¼': '\u{1F43C}',
    'Ã°Å¸°': '\u{1F430}',
    'Ã°Å¸»': '\u{1F43B}',
    'Ã°Å¸¨': '\u{1F428}',
    'Ã°Å¸¯': '\u{1F42F}',
    'Ã°Å¸¦â€¹': '\u{1F98B}',
    'Ã°Å¸â„¢': '\u{1F419}',
    'Ã°Å¸¦©': '\u{1F9A9}',
    'Ã°Å¸§': '\u{1F427}',
    'Ã°Å¸¦â€ž': '\u{1F984}',
    'Ã°Å¸â€°': '\u{1F409}',
    'Ã°Å¸¦â€™': '\u{1F992}',
    'Ã°Å¸¦¥': '\u{1F9A5}',
  };

  static const List<Map<String, dynamic>> defaultAvatars = [
    {'emoji': '\u{1F431}', 'color': Color(0xFFFFD180), 'name': 'Gato'},
    {'emoji': '\u{1F436}', 'color': Color(0xFFFFEDE4), 'name': 'Perro'},
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
      'id': 'premium_mate_boy',
      'url': 'assets/images/premium_3d_avatars/premium_mate_boy.png',
      'name': 'Matecito',
      'color': Color(0xFFFFE7BA),
    },
    {
      'id': 'premium_keys_girl',
      'url': 'assets/images/premium_3d_avatars/premium_keys_girl.png',
      'name': 'Llaves de Casa',
      'color': Color(0xFFFFD3E0),
    },
    {
      'id': 'premium_market_dog',
      'url': 'assets/images/premium_3d_avatars/premium_market_dog.png',
      'name': 'Perrito Super',
      'color': Color(0xFFD8ECFA),
    },
    {
      'id': 'premium_orange_cat',
      'url': 'assets/images/premium_3d_avatars/premium_orange_cat.png',
      'name': 'Gatito Naranja',
      'color': Color(0xFFFFD180),
    },
    {
      'id': 'premium_paper_plane_kid',
      'url': 'assets/images/premium_3d_avatars/premium_paper_plane_kid.png',
      'name': 'Mini Aventurero',
      'color': Color(0xFFFFE0C2),
    },
    {
      'id': 'premium_star_girl',
      'url': 'assets/images/premium_3d_avatars/premium_star_girl.png',
      'name': 'Mini Estrella',
      'color': Color(0xFFFFD8C7),
    },
    {
      'id': 'premium_key_bird',
      'url': 'assets/images/premium_3d_avatars/premium_key_bird.png',
      'name': 'Pajarito Llaves',
      'color': Color(0xFFFFE7A8),
    },
    {
      'id': 'premium_tool_adult_man',
      'url': 'assets/images/premium_3d_avatars/premium_tool_adult_man.png',
      'name': 'Manos a Casa',
      'color': Color(0xFFDCE8CF),
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

  static Map<String, dynamic>? premiumAvatarById(String id) {
    for (final avatar in premiumAvatars) {
      if (avatar['id'] == id) return avatar;
    }
    return null;
  }

  static String resolvePremiumAvatarUrl(String value) {
    final cleanValue = value.startsWith('premium://')
        ? value.replaceFirst('premium://', '')
        : value;
    final byId = premiumAvatarById(cleanValue);
    if (byId != null) return byId['url'] as String;
    return cleanValue;
  }

  static String premiumAvatarValue(Map<String, dynamic> avatar) {
    return 'premium://${avatar['id']}';
  }

  static bool isPremiumAvatarValue(String? value) {
    final normalized = normalizeAvatarValue(value);
    if (normalized == null || normalized.trim().isEmpty) return false;
    return normalized.startsWith('premium://') ||
        normalized.startsWith('assets/images/custom_avatars/') ||
        normalized.contains('/storage/v1/object/public/custom-avatars/');
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
    final bool isPremium = UserAvatar.isPremiumAvatarValue(avatarUrl);
    final admin = ref.watch(adminProvider);

    Widget avatarContent;
    if (isPremium && !forceCircular) {
      avatarContent = _PremiumCharacterAvatar(
        url: avatarUrl!,
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
              content: Text(
                '\u00BFDeseas ver la app como ${name ?? 'este usuario'}?',
              ),
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
        normalizedAvatarUrl?.startsWith('premium://') == true
            ? UserAvatar.resolvePremiumAvatarUrl(normalizedAvatarUrl!)
            : (normalizedAvatarUrl ?? '');
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
                ),
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
    final String cleanUrl = UserAvatar.resolvePremiumAvatarUrl(url);

    final bool isVideo = cleanUrl.toLowerCase().endsWith('.mp4');
    final bool shouldPlayVideo =
        isVideo && (isAnimated || isPriority || radius >= 32);

    final double size = isVideo ? radius * 2.8 : radius * 3.38;
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
      content = _PremiumAvatarMotion(
        size: size,
        isPriority: isPriority,
        child: content,
      );
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

class _PremiumAvatarMotion extends StatefulWidget {
  final Widget child;
  final double size;
  final bool isPriority;

  const _PremiumAvatarMotion({
    required this.child,
    required this.size,
    required this.isPriority,
  });

  @override
  State<_PremiumAvatarMotion> createState() => _PremiumAvatarMotionState();
}

class _PremiumAvatarMotionState extends State<_PremiumAvatarMotion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(begin: 0.0, end: -2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.995, end: 1.012).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.06, end: 0.16).animate(
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
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size * 0.92,
              height: widget.size * 0.92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(
                      alpha: _glowAnimation.value,
                    ),
                    blurRadius: widget.isPriority ? 16 : 10,
                    spreadRadius: widget.isPriority ? 2 : 0,
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, _offsetAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
