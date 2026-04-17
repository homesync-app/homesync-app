class ShoppingCategories {
  static const List<Map<String, dynamic>> all = [
    {'id': 'general', 'name': 'Frecuentes', 'emoji': '🛒', 'color': 0xFF6366F1},
    {
      'id': 'fruits',
      'name': 'Frutas y verd.',
      'emoji': '🥦',
      'color': 0xFF22C55E,
    },
    {'id': 'meat', 'name': 'Carnes', 'emoji': '🥩', 'color': 0xFFEF4444},
    {'id': 'dairy', 'name': 'Lácteos', 'emoji': '🥛', 'color': 0xFF3B82F6},
    {'id': 'bakery', 'name': 'Panadería', 'emoji': '🍞', 'color': 0xFFF59E0B},
    {'id': 'pantry', 'name': 'Despensa', 'emoji': '🥫', 'color': 0xFFD97706},
    {'id': 'frozen', 'name': 'Congelados', 'emoji': '🧊', 'color': 0xFF0284C7},
    {'id': 'cleaning', 'name': 'Limpieza', 'emoji': '🧴', 'color': 0xFF8B5CF6},
    {'id': 'drinks', 'name': 'Bebidas', 'emoji': '🫙', 'color': 0xFF06B6D4},
    {'id': 'snacks', 'name': 'Snacks', 'emoji': '🍫', 'color': 0xFFEC4899},
    {'id': 'pharmacy', 'name': 'Farmacia', 'emoji': '💊', 'color': 0xFF10B981},
    {'id': 'pets', 'name': 'Mascotas', 'emoji': '🐕', 'color': 0xFFA16207},
  ];

  static String emojiFor(String id) =>
      all.firstWhere((c) => c['id'] == id, orElse: () => all.first)['emoji']
          as String;

  static String nameFor(String id) =>
      all.firstWhere((c) => c['id'] == id, orElse: () => all.first)['name']
          as String;

  static int colorFor(String id) =>
      all.firstWhere((c) => c['id'] == id, orElse: () => all.first)['color']
          as int;
}
