import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shopping_icons_remote.dart';
import '../../domain/models/shopping_visuals.dart';

class ShoppingIcon extends ConsumerWidget {
  const ShoppingIcon({
    super.key,
    this.productKey,
    this.categoryId,
    this.fallbackEmoji,
    this.allowProductAsset = false,
    this.allowCategoryFallback = false,
    this.size = 40,
    this.opacity = 1,
    this.color,
  });

  final String? productKey;
  final String? categoryId;
  final String? fallbackEmoji;
  final bool allowProductAsset;
  final bool allowCategoryFallback;
  final double size;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifest = ref.watch(shoppingIconManifestProvider);
    final fallback = _buildFallback(context);

    Widget child;
    final key = productKey;
    if (key != null && key.isNotEmpty && manifest.containsKey(key)) {
      // Usamos `Image` (no `CachedNetworkImage`) con `CachedNetworkImageProvider`
      // a propósito: si el ícono ya está en el ImageCache (memoria) — porque lo
      // precargamos en el arranque/onboarding — se dibuja SINCRÓNICAMENTE en el
      // primer frame (`wasSynchronouslyLoaded`), sin placeholder ni swap. Si por
      // alguna razón aún no está, el frameBuilder muestra el emoji (la base) sólo
      // mientras carga, en vez del flash de un ícono viejo.
      child = Image(
        image: CachedNetworkImageProvider(shoppingIconUrl(key, manifest[key]!)),
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return fallback;
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      child = fallback;
    }

    if (opacity >= 1) return child;
    return Opacity(opacity: opacity, child: child);
  }

  /// Fallback cuando no hay ícono remoto (o falla / offline en 1ª carga):
  /// asset bundled (si está permitido) -> ícono de categoría -> emoji.
  Widget _buildFallback(BuildContext context) {
    // The bundled per-product PNGs (ShoppingVisuals.product) were the OLD
    // flat-plate style, since replaced by the emoji-look remote icons in
    // Storage. We intentionally no longer show them: on a fresh install the
    // remote icons aren't cached yet, and using a stale bundled PNG as the
    // placeholder caused the visible "old icon -> new icon" swap. The emoji is
    // the base (and the remote icons imitate it), so the transient/offline
    // visual is the emoji and the swap to the real icon is barely noticeable.
    final categoryIcon =
        allowCategoryFallback ? _categoryIcon(categoryId) : null;
    final visual = (categoryIcon == null && allowCategoryFallback)
        ? ShoppingVisuals.category(categoryId)
        : null;
    final emoji = fallbackEmoji ?? visual?.fallbackEmoji ?? '\u{1F6D2}';

    if (categoryIcon != null) {
      return SizedBox.square(
        dimension: size,
        child: Center(
          child: Icon(
            categoryIcon,
            size: size * 0.68,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    if (visual != null) {
      return Image.asset(
        visual.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _EmojiFallback(emoji: emoji, size: size),
      );
    }
    return _EmojiFallback(emoji: emoji, size: size);
  }

  IconData? _categoryIcon(String? id) {
    switch (id) {
      case 'general':
        return Icons.shopping_cart_rounded;
      case 'fruits':
        return Icons.eco_rounded;
      case 'meat':
        return Icons.restaurant_rounded;
      case 'dairy':
        return Icons.local_drink_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      case 'pantry':
        return Icons.inventory_2_rounded;
      case 'frozen':
        return Icons.ac_unit_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'drinks':
        return Icons.local_bar_rounded;
      case 'snacks':
        return Icons.fastfood_rounded;
      case 'pharmacy':
        return Icons.medical_services_rounded;
      case 'pets':
        return Icons.pets_rounded;
    }
    return null;
  }
}

class _EmojiFallback extends StatelessWidget {
  const _EmojiFallback({
    required this.emoji,
    required this.size,
  });

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.68),
        ),
      ),
    );
  }
}
