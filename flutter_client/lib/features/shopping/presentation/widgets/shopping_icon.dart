import 'package:flutter/material.dart';

import '../../domain/models/shopping_visuals.dart';

class ShoppingIcon extends StatelessWidget {
  const ShoppingIcon({
    super.key,
    this.productKey,
    this.categoryId,
    this.fallbackEmoji,
    this.allowProductAsset = false,
    this.allowCategoryFallback = false,
    this.size = 40,
    this.opacity = 1,
  });

  final String? productKey;
  final String? categoryId;
  final String? fallbackEmoji;
  final bool allowProductAsset;
  final bool allowCategoryFallback;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final visual = (allowProductAsset
            ? ShoppingVisuals.product(productKey)
            : null) ??
        (allowCategoryFallback ? ShoppingVisuals.category(categoryId) : null);
    final emoji = fallbackEmoji ?? visual?.fallbackEmoji ?? '🛒';

    Widget child;
    if (visual != null) {
      child = Image.asset(
        visual.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _EmojiFallback(
          emoji: emoji,
          size: size,
        ),
      );
    } else {
      child = _EmojiFallback(emoji: emoji, size: size);
    }

    if (opacity >= 1) return child;
    return Opacity(opacity: opacity, child: child);
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
