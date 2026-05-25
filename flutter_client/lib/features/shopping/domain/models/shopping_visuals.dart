class ShoppingIconAsset {
  const ShoppingIconAsset({
    required this.assetPath,
    required this.fallbackEmoji,
  });

  final String assetPath;
  final String fallbackEmoji;
}

/// Camino 2: los emojis del sistema son la base de todos los productos. Acá solo
/// van los *overrides* con PNG propio para casos puntuales: colisiones de emoji
/// (ej. naranja/mandarina/pomelo → todos 🍊) o productos sin emoji decente (ej.
/// milanesa). Para sumar uno: dejá el PNG en
/// assets/images/shopping_icons/products/{clave}.png (ese dir debe estar en
/// pubspec assets) y agregá la entrada acá. Las call sites ya pasan
/// allowProductAsset: true, así que el ícono aparece solo; lo que no esté en
/// este mapa sigue mostrando su emoji.
class ShoppingVisuals {
  static const String _basePath = 'assets/images/shopping_icons';

  static const Map<String, ShoppingIconAsset> categories = {};

  static const Map<String, ShoppingIconAsset> products = {
    'milanesas': ShoppingIconAsset(
      assetPath: '$_basePath/products/milanesas.png',
      fallbackEmoji: '🍽️',
    ),
  };

  static ShoppingIconAsset? product(String? key) {
    if (key == null || key.isEmpty) return null;
    return products[key];
  }

  static ShoppingIconAsset? category(String? id) {
    if (id == null || id.isEmpty) return null;
    return categories[id];
  }
}
