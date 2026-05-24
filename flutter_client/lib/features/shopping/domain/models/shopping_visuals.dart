class ShoppingIconAsset {
  const ShoppingIconAsset({
    required this.assetPath,
    required this.fallbackEmoji,
  });

  final String assetPath;
  final String fallbackEmoji;
}

/// Custom PNG overrides for products whose default emoji collides with other
/// products (e.g. naranja/mandarina/pomelo all map to 🍊). Base icons are the
/// system emoji; an entry here is only added when a dedicated icon exists, and
/// it must live under assets/images/shopping_icons/products/ (re-add that dir to
/// pubspec when the first override ships).
class ShoppingVisuals {
  static const Map<String, ShoppingIconAsset> categories = {};

  static const Map<String, ShoppingIconAsset> products = {};

  static ShoppingIconAsset? product(String? key) {
    if (key == null || key.isEmpty) return null;
    return products[key];
  }

  static ShoppingIconAsset? category(String? id) {
    if (id == null || id.isEmpty) return null;
    return categories[id];
  }
}
