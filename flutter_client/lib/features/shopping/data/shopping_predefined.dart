import 'package:flutter/material.dart';
import 'package:homesync_client/features/shopping/utils/shopping_localization.dart';

class ShoppingPredefined {
  // Legacy support for background services and providers that don't have context.
  // Defaults to Spanish (original catalog).
  static const Map<String, List<Map<String, String>>> itemsPerCategory = {
    'fruits': [
      {'name': 'Tomate', 'emoji': '🍅'},
      {'name': 'Cebolla', 'emoji': '🧅'},
      {'name': 'Cebolla de verdeo', 'emoji': '🌱'},
      {'name': 'Papa', 'emoji': '🥔'},
      {'name': 'Manzana', 'emoji': '🍎'},
      {'name': 'Banana', 'emoji': '🍌'},
      {'name': 'Pera', 'emoji': '🍐'},
      {'name': 'Durazno', 'emoji': '🍑'},
      {'name': 'Limón', 'emoji': '🍋'},
      {'name': 'Naranja', 'emoji': '🍊'},
      {'name': 'Mandarina', 'emoji': '🍊'},
      {'name': 'Pomelo', 'emoji': '🍊'},
      {'name': 'Kiwi', 'emoji': '🥝'},
      {'name': 'Anana', 'emoji': '🍍'},
      {'name': 'Frutilla', 'emoji': '🍓'},
      {'name': 'Uvas', 'emoji': '🍇'},
      {'name': 'Sandía', 'emoji': '🍉'},
      {'name': 'Zanahoria', 'emoji': '🥕'},
      {'name': 'Ajo', 'emoji': '🧄'},
      {'name': 'Jengibre', 'emoji': '🫚'},
      {'name': 'Lechuga', 'emoji': '🥬'},
      {'name': 'Rúcula', 'emoji': '🥬'},
      {'name': 'Espinaca', 'emoji': '🥬'},
      {'name': 'Acelga', 'emoji': '🥬'},
      {'name': 'Apio', 'emoji': '🌿'},
      {'name': 'Palta', 'emoji': '🥑'},
      {'name': 'Morrón', 'emoji': '🫑'},
      {'name': 'Pimiento', 'emoji': '🫑'},
      {'name': 'Zapallo', 'emoji': '🎃'},
      {'name': 'Batata', 'emoji': '🍠'},
      {'name': 'Boniato', 'emoji': '🍠'},
      {'name': 'Brocoli', 'emoji': '🥦'},
      {'name': 'Berenjena', 'emoji': '🍆'},
      {'name': 'Champiñones', 'emoji': '🍄'},
      {'name': 'Choclo', 'emoji': '🌽'},
      {'name': 'Pepino', 'emoji': '🥒'},
      {'name': 'Remolacha', 'emoji': '🫜'},
    ],
    'meat': [
      {'name': 'Carne picada', 'emoji': '🥩'},
      {'name': 'Pollo', 'emoji': '🍗'},
      {'name': 'Pescado', 'emoji': '🐟'},
      {'name': 'Cerdo', 'emoji': '🐖'},
      {'name': 'Bondiola', 'emoji': '🥩'},
      {'name': 'Vacío', 'emoji': '🥩'},
      {'name': 'Matambre', 'emoji': '🥩'},
      {'name': 'Peceto', 'emoji': '🥩'},
      {'name': 'Costillas', 'emoji': '🍖'},
      {'name': 'Milanesas', 'emoji': '🥩'},
      {'name': 'Salchichas', 'emoji': '🌭'},
      {'name': 'Chorizo', 'emoji': '🥓'},
      {'name': 'Hamburguesas', 'emoji': '🍔'},
      {'name': 'Panceta', 'emoji': '🥓'},
    ],
    'dairy': [
      {'name': 'Leche', 'emoji': '🥛'},
      {'name': 'Leche vegetal', 'emoji': '🥛'},
      {'name': 'Leche condensada', 'emoji': '🥫'},
      {'name': 'Leche chocolatada', 'emoji': '🍫'},
      {'name': 'Queso fresco', 'emoji': '🧀'},
      {'name': 'Queso rallado', 'emoji': '🧀'},
      {'name': 'Queso crema', 'emoji': '🥣'},
      {'name': 'Queso provolone', 'emoji': '🧀'},
      {'name': 'Mozzarella', 'emoji': '🧀'},
      {'name': 'Manteca', 'emoji': '🧈'},
      {'name': 'Crema', 'emoji': '🥛'},
      {'name': 'Yogur', 'emoji': '🥣'},
      {'name': 'Yogur bebible', 'emoji': '🧃'},
      {'name': 'Huevos', 'emoji': '🥚'},
      {'name': 'Dulce de leche', 'emoji': '🍯'},
      {'name': 'Tofu', 'emoji': '🧊'},
      {'name': 'Hummus', 'emoji': '🥣'},
    ],
    'bakery': [
      {'name': 'Pan', 'emoji': '🥖'},
      {'name': 'Pan lactal', 'emoji': '🍞'},
      {'name': 'Pan rallado', 'emoji': '🍞'},
      {'name': 'Tostadas', 'emoji': '🍞'},
      {'name': 'Medialunas', 'emoji': '🥐'},
      {'name': 'Criollos', 'emoji': '🥨'},
      {'name': 'Bizcochos', 'emoji': '🥨'},
      {'name': 'Vainillas', 'emoji': '🍪'},
      {'name': 'Galletas', 'emoji': '🍪'},
      {'name': 'Tarta', 'emoji': '🥧'},
    ],
    'cleaning': [
      {'name': 'Detergente', 'emoji': '🧴'},
      {'name': 'Lavandina', 'emoji': '🧪'},
      {'name': 'Limpiavidrios', 'emoji': '✨'},
      {'name': 'Limpiador pisos', 'emoji': '✨'},
      {'name': 'Multiuso', 'emoji': '🧴'},
      {'name': 'Desengrasante', 'emoji': '🧴'},
      {'name': 'Desinfectante', 'emoji': '🧴'},
      {'name': 'Insecticida', 'emoji': '🦟'},
      {'name': 'Papel higiénico', 'emoji': '🧻'},
      {'name': 'Rollo cocina', 'emoji': '🧻'},
      {'name': 'Esponja', 'emoji': '🧽'},
      {'name': 'Trapo rejilla', 'emoji': '🧽'},
      {'name': 'Escoba', 'emoji': '🧹'},
      {'name': 'Jabón ropa', 'emoji': '🧼'},
      {'name': 'Suavizante', 'emoji': '🌸'},
      {'name': 'Bolsas', 'emoji': '🥡'},
    ],
    'drinks': [
      {'name': 'Agua', 'emoji': '💧'},
      {'name': 'Agua saborizada', 'emoji': '💧'},
      {'name': 'Soda', 'emoji': '🫧'},
      {'name': 'Tónica', 'emoji': '🫧'},
      {'name': 'Gaseosa', 'emoji': '🥤'},
      {'name': 'Coca Cola', 'emoji': '🥤'},
      {'name': 'Jugo', 'emoji': '🧃'},
      {'name': 'Isotonico', 'emoji': '💪'},
      {'name': 'Energizante', 'emoji': '⚡'},
      {'name': 'Cerveza', 'emoji': '🍺'},
      {'name': 'Vino', 'emoji': '🍷'},
      {'name': 'Vermouth', 'emoji': '🍷'},
      {'name': 'Champagne', 'emoji': '🍾'},
      {'name': 'Sidra', 'emoji': '🍾'},
      {'name': 'Whisky', 'emoji': '🥃'},
      {'name': 'Fernet', 'emoji': '🥃'},
      {'name': 'Aperitivo', 'emoji': '🥃'},
      {'name': 'Terma', 'emoji': '🌿'},
    ],
    'snacks': [
      {'name': 'Papas fritas', 'emoji': '🍟'},
      {'name': 'Chizitos', 'emoji': '🧀'},
      {'name': 'Palitos', 'emoji': '🥨'},
      {'name': 'Pochoclos', 'emoji': '🍿'},
      {'name': 'Chocolate', 'emoji': '🍫'},
      {'name': 'Turrón', 'emoji': '🍫'},
      {'name': 'Alfajor', 'emoji': '🍩'},
      {'name': 'Budín', 'emoji': '🍰'},
      {'name': 'Helado', 'emoji': '🍦'},
      {'name': 'Galletitas dulces', 'emoji': '🍪'},
      {'name': 'Caramelos', 'emoji': '🍬'},
      {'name': 'Gomitas', 'emoji': '🧸'},
      {'name': 'Golosinas', 'emoji': '🍭'},
      {'name': 'Maní', 'emoji': '🥜'},
      {'name': 'Almendras', 'emoji': '🥜'},
      {'name': 'Nueces', 'emoji': '🥜'},
    ],
    'pharmacy': [
      {'name': 'Ibuprofeno', 'emoji': '💊'},
      {'name': 'Paracetamol', 'emoji': '💊'},
      {'name': 'Aspirina', 'emoji': '💊'},
      {'name': 'Curitas', 'emoji': '🩹'},
      {'name': 'Alcohol', 'emoji': '🍾'},
      {'name': 'Algodón', 'emoji': '☁️'},
      {'name': 'Hisopos', 'emoji': '👂'},
      {'name': 'Pañuelos', 'emoji': '🤧'},
      {'name': 'Dentífrico', 'emoji': '🪥'},
      {'name': 'Shampoo', 'emoji': '🧴'},
      {'name': 'Acondicionador', 'emoji': '🧴'},
      {'name': 'Crema corporal', 'emoji': '🧴'},
      {'name': 'Protector solar', 'emoji': '☀️'},
      {'name': 'Desodorante', 'emoji': '💨'},
      {'name': 'Antitranspirante', 'emoji': '🧴'},
      {'name': 'Máquina afeitar', 'emoji': '🪒'},
      {'name': 'Jabón tocador', 'emoji': '🧼'},
      {'name': 'Protectores', 'emoji': '🩸'},
      {'name': 'Toallitas', 'emoji': '🩸'},
      {'name': 'Preservativos', 'emoji': '🍆'},
    ],
    'pets': [
      {'name': 'Alimento perro', 'emoji': '🐕'},
      {'name': 'Alimento gato', 'emoji': '🐈'},
      {'name': 'Piedras gato', 'emoji': '🪨'},
      {'name': 'Arena gato', 'emoji': '🪨'},
      {'name': 'Golosinas mascota', 'emoji': '🦴'},
      {'name': 'Bolsitas', 'emoji': '💩'},
    ],
    'frozen': [
      {'name': 'Papas congeladas', 'emoji': '🍟'},
      {'name': 'Verdura congelada', 'emoji': '🥦'},
      {'name': 'Pescado congelado', 'emoji': '🐟'},
      {'name': 'Nuggets', 'emoji': '🍗'},
      {'name': 'Hielo', 'emoji': '🧊'},
    ],
    'pantry': [
      {'name': 'Aceite', 'emoji': '🛢️'},
      {'name': 'Vinagre', 'emoji': '🍶'},
      {'name': 'Sal', 'emoji': '🧂'},
      {'name': 'Pimienta', 'emoji': '🧂'},
      {'name': 'Condimentos', 'emoji': '🧂'},
      {'name': 'Azúcar', 'emoji': '🍬'},
      {'name': 'Edulcorante', 'emoji': '🍬'},
      {'name': 'Fideos', 'emoji': '🍝'},
      {'name': 'Arroz', 'emoji': '🍚'},
      {'name': 'Harina', 'emoji': '🥖'},
      {'name': 'Polenta', 'emoji': '🌽'},
      {'name': 'Avena', 'emoji': '🌾'},
      {'name': 'Lentejas', 'emoji': '🍛'},
      {'name': 'Garbanzo', 'emoji': '🫘'},
      {'name': 'Porotos', 'emoji': '🫘'},
      {'name': 'Arvejas', 'emoji': '🫛'},
      {'name': 'Café', 'emoji': '☕'},
      {'name': 'Cacao', 'emoji': '☕'},
      {'name': 'Yerba', 'emoji': '🌿'},
      {'name': 'Té', 'emoji': '🍵'},
      {'name': 'Atún', 'emoji': '🐟'},
      {'name': 'Salsa de tomate', 'emoji': '🥫'},
      {'name': 'Salsa soja', 'emoji': '🫙'},
      {'name': 'Ketchup', 'emoji': '🥫'},
      {'name': 'Mayonesa', 'emoji': '🍯'},
      {'name': 'Mostaza', 'emoji': '🌭'},
      {'name': 'Mermelada', 'emoji': '🍯'},
      {'name': 'Chocolate cobertura', 'emoji': '🍫'},
      {'name': 'Gelatina', 'emoji': '🍮'},
    ],
  };

  static List<Map<String, String>> itemsForCategory(
    String categoryId,
    BuildContext context,
  ) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    if (!isEn) return itemsPerCategory[categoryId] ?? [];

    final localized = _localizedItemsForCategory(categoryId, context);
    if (localized.isNotEmpty) return localized;

    switch (categoryId) {
      case 'fruits':
        return [
          {'name': 'Tomato', 'emoji': '🍅'},
          {'name': 'Onion', 'emoji': '🧅'},
          {'name': 'Green Onion', 'emoji': '🌱'},
          {'name': 'Potato', 'emoji': '🥔'},
          {'name': 'Apple', 'emoji': '🍎'},
          {'name': 'Banana', 'emoji': '🍌'},
          {'name': 'Pear', 'emoji': '🍐'},
          {'name': 'Peach', 'emoji': '🍑'},
          {'name': 'Lemon', 'emoji': '🍋'},
          {'name': 'Orange', 'emoji': '🍊'},
          {'name': 'Tangerine', 'emoji': '🍊'},
          {'name': 'Grapefruit', 'emoji': '🍊'},
          {'name': 'Kiwi', 'emoji': '🥝'},
          {'name': 'Pineapple', 'emoji': '🍍'},
          {'name': 'Strawberry', 'emoji': '🍓'},
          {'name': 'Grapes', 'emoji': '🍇'},
          {'name': 'Watermelon', 'emoji': '🍉'},
          {'name': 'Carrot', 'emoji': '🥕'},
          {'name': 'Garlic', 'emoji': '🧄'},
          {'name': 'Ginger', 'emoji': '🫚'},
          {'name': 'Lettuce', 'emoji': '🥬'},
          {'name': 'Arugula', 'emoji': '🥬'},
          {'name': 'Spinach', 'emoji': '🥬'},
          {'name': 'Chard', 'emoji': '🥬'},
          {'name': 'Celery', 'emoji': '🌿'},
          {'name': 'Avocado', 'emoji': '🥑'},
          {'name': 'Bell Pepper', 'emoji': '🫑'},
          {'name': 'Pumpkin', 'emoji': '🎃'},
          {'name': 'Sweet Potato', 'emoji': '🍠'},
          {'name': 'Broccoli', 'emoji': '🥦'},
          {'name': 'Eggplant', 'emoji': '🍆'},
          {'name': 'Mushrooms', 'emoji': '🍄'},
          {'name': 'Corn', 'emoji': '🌽'},
          {'name': 'Cucumber', 'emoji': '🥒'},
          {'name': 'Beet', 'emoji': '🫜'},
        ];

      case 'meat':
        return [
          {'name': 'Ground beef', 'emoji': '🥩'},
          {'name': 'Chicken', 'emoji': '🍗'},
          {'name': 'Fish', 'emoji': '🐟'},
          {'name': 'Pork', 'emoji': '🐖'},
          {'name': 'Steak', 'emoji': '🥩'},
          {'name': 'Ribs', 'emoji': '🍖'},
          {'name': 'Sausages', 'emoji': '🌭'},
          {'name': 'Chorizo', 'emoji': '🥓'},
          {'name': 'Burgers', 'emoji': '🍔'},
          {'name': 'Bacon', 'emoji': '🥓'},
        ];

      case 'dairy':
        return [
          {'name': 'Milk', 'emoji': '🥛'},
          {'name': 'Plant milk', 'emoji': '🥛'},
          {'name': 'Cheese', 'emoji': '🧀'},
          {'name': 'Grated cheese', 'emoji': '🧀'},
          {'name': 'Cream cheese', 'emoji': '🥣'},
          {'name': 'Mozzarella', 'emoji': '🧀'},
          {'name': 'Butter', 'emoji': '🧈'},
          {'name': 'Cream', 'emoji': '🥛'},
          {'name': 'Yogurt', 'emoji': '🥣'},
          {'name': 'Eggs', 'emoji': '🥚'},
          {'name': 'Tofu', 'emoji': '🧊'},
          {'name': 'Hummus', 'emoji': '🥣'},
        ];

      case 'cleaning':
        return [
          {'name': 'Detergent', 'emoji': '🧴'},
          {'name': 'Bleach', 'emoji': '🧪'},
          {'name': 'Glass cleaner', 'emoji': '✨'},
          {'name': 'Floor cleaner', 'emoji': '✨'},
          {'name': 'Multi-purpose', 'emoji': '🧴'},
          {'name': 'Toilet paper', 'emoji': '🧻'},
          {'name': 'Kitchen roll', 'emoji': '🧻'},
          {'name': 'Sponge', 'emoji': '🧽'},
          {'name': 'Laundry soap', 'emoji': '🧼'},
          {'name': 'Softener', 'emoji': '🌸'},
          {'name': 'Trash bags', 'emoji': '🥡'},
        ];

      case 'drinks':
        return [
          {'name': 'Water', 'emoji': '💧'},
          {'name': 'Soda', 'emoji': '🥤'},
          {'name': 'Juice', 'emoji': '🧃'},
          {'name': 'Beer', 'emoji': '🍺'},
          {'name': 'Wine', 'emoji': '🍷'},
          {'name': 'Coffee', 'emoji': '☕'},
          {'name': 'Tea', 'emoji': '🍵'},
        ];

      default:
        return itemsPerCategory[categoryId] ?? [];
    }
  }

  static Map<String, List<Map<String, String>>> allItems(BuildContext context) {
    const categories = [
      'fruits',
      'meat',
      'dairy',
      'bakery',
      'cleaning',
      'drinks',
      'snacks',
      'pharmacy',
      'pets',
      'frozen',
      'pantry',
    ];
    final result = <String, List<Map<String, String>>>{};
    for (final cat in categories) {
      result[cat] = itemsForCategory(cat, context);
    }
    return result;
  }

  static List<Map<String, String>> _localizedItemsForCategory(
    String categoryId,
    BuildContext context,
  ) {
    final source = itemsPerCategory[categoryId] ?? const [];
    return source.map((item) {
      final name = item['name'] ?? '';
      return {
        'name': localizedShoppingCatalogName(context, name: name),
        'emoji': item['emoji'] ?? '',
      };
    }).toList();
  }
}
