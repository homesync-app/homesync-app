class ShoppingIconAsset {
  const ShoppingIconAsset({
    required this.assetPath,
    required this.fallbackEmoji,
  });

  final String assetPath;
  final String fallbackEmoji;
}

class ShoppingVisuals {
  static const String _basePath = 'assets/images/shopping_icons';

  static const Map<String, ShoppingIconAsset> categories = {
    'general': ShoppingIconAsset(
      assetPath: '$_basePath/categories/general.png',
      fallbackEmoji: '🛒',
    ),
    'fruits': ShoppingIconAsset(
      assetPath: '$_basePath/categories/fruits.png',
      fallbackEmoji: '🥦',
    ),
    'meat': ShoppingIconAsset(
      assetPath: '$_basePath/categories/meat.png',
      fallbackEmoji: '🥩',
    ),
    'dairy': ShoppingIconAsset(
      assetPath: '$_basePath/categories/dairy.png',
      fallbackEmoji: '🥛',
    ),
    'bakery': ShoppingIconAsset(
      assetPath: '$_basePath/categories/bakery.png',
      fallbackEmoji: '🍞',
    ),
    'pantry': ShoppingIconAsset(
      assetPath: '$_basePath/categories/pantry.png',
      fallbackEmoji: '🥫',
    ),
    'frozen': ShoppingIconAsset(
      assetPath: '$_basePath/categories/frozen.png',
      fallbackEmoji: '🧊',
    ),
    'cleaning': ShoppingIconAsset(
      assetPath: '$_basePath/categories/cleaning.png',
      fallbackEmoji: '🧴',
    ),
    'drinks': ShoppingIconAsset(
      assetPath: '$_basePath/categories/drinks.png',
      fallbackEmoji: '🥤',
    ),
    'snacks': ShoppingIconAsset(
      assetPath: '$_basePath/categories/snacks.png',
      fallbackEmoji: '🍫',
    ),
    'pharmacy': ShoppingIconAsset(
      assetPath: '$_basePath/categories/pharmacy.png',
      fallbackEmoji: '💊',
    ),
    'pets': ShoppingIconAsset(
      assetPath: '$_basePath/categories/pets.png',
      fallbackEmoji: '🐾',
    ),
  };

  static const Map<String, ShoppingIconAsset> products = {
    'tomato': ShoppingIconAsset(
      assetPath: '$_basePath/products/tomato.png',
      fallbackEmoji: '🍅',
    ),
    'onion': ShoppingIconAsset(
      assetPath: '$_basePath/products/onion.png',
      fallbackEmoji: '🧅',
    ),
    'potato': ShoppingIconAsset(
      assetPath: '$_basePath/products/potato.png',
      fallbackEmoji: '🥔',
    ),
    'carrot': ShoppingIconAsset(
      assetPath: '$_basePath/products/carrot.png',
      fallbackEmoji: '🥕',
    ),
    'apple': ShoppingIconAsset(
      assetPath: '$_basePath/products/apple.png',
      fallbackEmoji: '🍎',
    ),
    'banana': ShoppingIconAsset(
      assetPath: '$_basePath/products/banana.png',
      fallbackEmoji: '🍌',
    ),
    'groundBeef': ShoppingIconAsset(
      assetPath: '$_basePath/products/groundBeef.png',
      fallbackEmoji: '🥩',
    ),
    'chicken': ShoppingIconAsset(
      assetPath: '$_basePath/products/chicken.png',
      fallbackEmoji: '🍗',
    ),
    'fish': ShoppingIconAsset(
      assetPath: '$_basePath/products/fish.png',
      fallbackEmoji: '🐟',
    ),
    'pork': ShoppingIconAsset(
      assetPath: '$_basePath/products/pork.png',
      fallbackEmoji: '🐖',
    ),
    'bondiola': ShoppingIconAsset(
      assetPath: '$_basePath/products/bondiola.png',
      fallbackEmoji: '🍖',
    ),
    'flankSteak': ShoppingIconAsset(
      assetPath: '$_basePath/products/flankSteak.png',
      fallbackEmoji: '🥩',
    ),
    'matambre': ShoppingIconAsset(
      assetPath: '$_basePath/products/matambre.png',
      fallbackEmoji: '🥓',
    ),
    'peceto': ShoppingIconAsset(
      assetPath: '$_basePath/products/peceto.png',
      fallbackEmoji: '🍖',
    ),
    'ribs': ShoppingIconAsset(
      assetPath: '$_basePath/products/ribs.png',
      fallbackEmoji: '🍖',
    ),
    'milanesas': ShoppingIconAsset(
      assetPath: '$_basePath/products/milanesas.png',
      fallbackEmoji: '🍽️',
    ),
    'sausages': ShoppingIconAsset(
      assetPath: '$_basePath/products/sausages.png',
      fallbackEmoji: '🌭',
    ),
    'chorizo': ShoppingIconAsset(
      assetPath: '$_basePath/products/chorizo.png',
      fallbackEmoji: '🌶️',
    ),
    'milk': ShoppingIconAsset(
      assetPath: '$_basePath/products/milk.png',
      fallbackEmoji: '🥛',
    ),
    'cheese': ShoppingIconAsset(
      assetPath: '$_basePath/products/cheese.png',
      fallbackEmoji: '🧀',
    ),
    'eggs': ShoppingIconAsset(
      assetPath: '$_basePath/products/eggs.png',
      fallbackEmoji: '🥚',
    ),
    'bread': ShoppingIconAsset(
      assetPath: '$_basePath/products/bread.png',
      fallbackEmoji: '🍞',
    ),
    'rice': ShoppingIconAsset(
      assetPath: '$_basePath/products/rice.png',
      fallbackEmoji: '🍚',
    ),
    'pasta': ShoppingIconAsset(
      assetPath: '$_basePath/products/pasta.png',
      fallbackEmoji: '🍝',
    ),
    'detergent': ShoppingIconAsset(
      assetPath: '$_basePath/products/detergent.png',
      fallbackEmoji: '🧴',
    ),
    'toiletPaper': ShoppingIconAsset(
      assetPath: '$_basePath/products/toiletPaper.png',
      fallbackEmoji: '🧻',
    ),
    'water': ShoppingIconAsset(
      assetPath: '$_basePath/products/water.png',
      fallbackEmoji: '💧',
    ),
    'soda': ShoppingIconAsset(
      assetPath: '$_basePath/products/soda.png',
      fallbackEmoji: '🥤',
    ),
    'coffee': ShoppingIconAsset(
      assetPath: '$_basePath/products/coffee.png',
      fallbackEmoji: '☕',
    ),
    'yerbaMate': ShoppingIconAsset(
      assetPath: '$_basePath/products/yerbaMate.png',
      fallbackEmoji: '🌿',
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
