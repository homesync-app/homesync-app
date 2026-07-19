import 'package:flutter/widgets.dart';

import '../data/shopping_catalog_aliases.dart';
import '../domain/models/shopping_model.dart';

class ShoppingCatalogEntry {
  const ShoppingCatalogEntry(this.key, this.es, this.en);

  final String key;
  final String es;
  final String en;
}

const List<ShoppingCatalogEntry> shoppingCatalogEntries = [
  ShoppingCatalogEntry('tomato', 'Tomate', 'Tomato'),
  ShoppingCatalogEntry('onion', 'Cebolla', 'Onion'),
  ShoppingCatalogEntry('greenOnion', 'Cebolla de verdeo', 'Green onion'),
  ShoppingCatalogEntry('potato', 'Papa', 'Potato'),
  ShoppingCatalogEntry('apple', 'Manzana', 'Apple'),
  ShoppingCatalogEntry('banana', 'Banana', 'Banana'),
  ShoppingCatalogEntry('pear', 'Pera', 'Pear'),
  ShoppingCatalogEntry('peach', 'Durazno', 'Peach'),
  ShoppingCatalogEntry('lemon', 'Limón', 'Lemon'),
  ShoppingCatalogEntry('orange', 'Naranja', 'Orange'),
  ShoppingCatalogEntry('tangerine', 'Mandarina', 'Tangerine'),
  ShoppingCatalogEntry('grapefruit', 'Pomelo', 'Grapefruit'),
  ShoppingCatalogEntry('kiwi', 'Kiwi', 'Kiwi'),
  ShoppingCatalogEntry('pineapple', 'Anana', 'Pineapple'),
  ShoppingCatalogEntry('strawberry', 'Frutilla', 'Strawberry'),
  ShoppingCatalogEntry('grapes', 'Uvas', 'Grapes'),
  ShoppingCatalogEntry('watermelon', 'Sandía', 'Watermelon'),
  ShoppingCatalogEntry('carrot', 'Zanahoria', 'Carrot'),
  ShoppingCatalogEntry('garlic', 'Ajo', 'Garlic'),
  ShoppingCatalogEntry('ginger', 'Jengibre', 'Ginger'),
  ShoppingCatalogEntry('lettuce', 'Lechuga', 'Lettuce'),
  ShoppingCatalogEntry('arugula', 'Rúcula', 'Arugula'),
  ShoppingCatalogEntry('spinach', 'Espinaca', 'Spinach'),
  ShoppingCatalogEntry('chard', 'Acelga', 'Chard'),
  ShoppingCatalogEntry('celery', 'Apio', 'Celery'),
  ShoppingCatalogEntry('avocado', 'Palta', 'Avocado'),
  ShoppingCatalogEntry('bellPepper', 'Morrón', 'Bell pepper'),
  ShoppingCatalogEntry('pepper', 'Pimiento', 'Pepper'),
  ShoppingCatalogEntry('pumpkin', 'Zapallo', 'Pumpkin'),
  ShoppingCatalogEntry('sweetPotato', 'Batata', 'Sweet potato'),
  ShoppingCatalogEntry('boniato', 'Boniato', 'Sweet potato'),
  ShoppingCatalogEntry('broccoli', 'Brocoli', 'Broccoli'),
  ShoppingCatalogEntry('eggplant', 'Berenjena', 'Eggplant'),
  ShoppingCatalogEntry('mushrooms', 'Champiñones', 'Mushrooms'),
  ShoppingCatalogEntry('corn', 'Choclo', 'Corn'),
  ShoppingCatalogEntry('cucumber', 'Pepino', 'Cucumber'),
  ShoppingCatalogEntry('beet', 'Remolacha', 'Beet'),
  ShoppingCatalogEntry('groundBeef', 'Carne picada', 'Ground beef'),
  ShoppingCatalogEntry('chicken', 'Pollo', 'Chicken'),
  ShoppingCatalogEntry('fish', 'Pescado', 'Fish'),
  ShoppingCatalogEntry('pork', 'Cerdo', 'Pork'),
  ShoppingCatalogEntry('bondiola', 'Bondiola', 'Pork shoulder'),
  ShoppingCatalogEntry('flankSteak', 'Vacío', 'Flank steak'),
  ShoppingCatalogEntry('matambre', 'Matambre', 'Rolled flank'),
  ShoppingCatalogEntry('peceto', 'Peceto', 'Round roast'),
  ShoppingCatalogEntry('roastBeef', 'Roast beef', 'Roast beef'),
  ShoppingCatalogEntry('ribs', 'Costillas', 'Ribs'),
  ShoppingCatalogEntry('milanesas', 'Milanesas', 'Breaded cutlets'),
  ShoppingCatalogEntry('sausages', 'Salchichas', 'Sausages'),
  ShoppingCatalogEntry('chorizo', 'Chorizo', 'Chorizo sausage'),
  ShoppingCatalogEntry('burgers', 'Hamburguesas', 'Burgers'),
  ShoppingCatalogEntry('bacon', 'Panceta', 'Bacon'),
  ShoppingCatalogEntry('milk', 'Leche', 'Milk'),
  ShoppingCatalogEntry('plantMilk', 'Leche vegetal', 'Plant milk'),
  ShoppingCatalogEntry('condensedMilk', 'Leche condensada', 'Condensed milk'),
  ShoppingCatalogEntry('chocolateMilk', 'Leche chocolatada', 'Chocolate milk'),
  ShoppingCatalogEntry('cheese', 'Queso', 'Cheese'),
  ShoppingCatalogEntry('freshCheese', 'Queso fresco', 'Fresh cheese'),
  ShoppingCatalogEntry('gratedCheese', 'Queso rallado', 'Grated cheese'),
  ShoppingCatalogEntry('creamCheese', 'Queso crema', 'Cream cheese'),
  ShoppingCatalogEntry('provolone', 'Queso provolone', 'Provolone'),
  ShoppingCatalogEntry('mozzarella', 'Mozzarella', 'Mozzarella'),
  ShoppingCatalogEntry('butter', 'Manteca', 'Butter'),
  ShoppingCatalogEntry('cream', 'Crema', 'Cream'),
  ShoppingCatalogEntry('yogurt', 'Yogur', 'Yogurt'),
  ShoppingCatalogEntry('drinkableYogurt', 'Yogur bebible', 'Drinkable yogurt'),
  ShoppingCatalogEntry('eggs', 'Huevos', 'Eggs'),
  ShoppingCatalogEntry('dulceDeLeche', 'Dulce de leche', 'Dulce de leche'),
  ShoppingCatalogEntry('tofu', 'Tofu', 'Tofu'),
  ShoppingCatalogEntry('hummus', 'Hummus', 'Hummus'),
  ShoppingCatalogEntry('bread', 'Pan', 'Bread'),
  ShoppingCatalogEntry('sandwichBread', 'Pan lactal', 'Sandwich bread'),
  ShoppingCatalogEntry('breadcrumbs', 'Pan rallado', 'Breadcrumbs'),
  ShoppingCatalogEntry('toast', 'Tostadas', 'Toast'),
  ShoppingCatalogEntry('croissants', 'Medialunas', 'Croissants'),
  ShoppingCatalogEntry('criollos', 'Criollos', 'Criollos'),
  ShoppingCatalogEntry('biscuits', 'Bizcochos', 'Biscuits'),
  ShoppingCatalogEntry('ladyfingers', 'Vainillas', 'Ladyfingers'),
  ShoppingCatalogEntry('cookies', 'Galletas', 'Cookies'),
  ShoppingCatalogEntry('tart', 'Tarta', 'Tart'),
  ShoppingCatalogEntry('detergent', 'Detergente', 'Detergent'),
  ShoppingCatalogEntry('bleach', 'Lavandina', 'Bleach'),
  ShoppingCatalogEntry('glassCleaner', 'Limpiavidrios', 'Glass cleaner'),
  ShoppingCatalogEntry('floorCleaner', 'Limpiador pisos', 'Floor cleaner'),
  ShoppingCatalogEntry(
    'multipurposeCleaner',
    'Multiuso',
    'Multi-purpose cleaner',
  ),
  ShoppingCatalogEntry('degreaser', 'Desengrasante', 'Degreaser'),
  ShoppingCatalogEntry('disinfectant', 'Desinfectante', 'Disinfectant'),
  ShoppingCatalogEntry('insecticide', 'Insecticida', 'Insecticide'),
  ShoppingCatalogEntry('toiletPaper', 'Papel higiénico', 'Toilet paper'),
  ShoppingCatalogEntry('kitchenRoll', 'Rollo cocina', 'Kitchen roll'),
  ShoppingCatalogEntry('sponge', 'Esponja', 'Sponge'),
  ShoppingCatalogEntry('dishcloth', 'Trapo rejilla', 'Dishcloth'),
  ShoppingCatalogEntry('broom', 'Escoba', 'Broom'),
  ShoppingCatalogEntry('laundrySoap', 'Jabón ropa', 'Laundry soap'),
  ShoppingCatalogEntry('softener', 'Suavizante', 'Softener'),
  ShoppingCatalogEntry('bags', 'Bolsas', 'Bags'),
  ShoppingCatalogEntry('water', 'Agua', 'Water'),
  ShoppingCatalogEntry('flavoredWater', 'Agua saborizada', 'Flavored water'),
  ShoppingCatalogEntry('sparklingWater', 'Soda', 'Sparkling water'),
  ShoppingCatalogEntry('tonicWater', 'Tónica', 'Tonic water'),
  ShoppingCatalogEntry('soda', 'Gaseosa', 'Soda'),
  ShoppingCatalogEntry('cocaCola', 'Coca Cola', 'Coca-Cola'),
  ShoppingCatalogEntry('juice', 'Jugo', 'Juice'),
  ShoppingCatalogEntry('sportsDrink', 'Isotonico', 'Sports drink'),
  ShoppingCatalogEntry('energyDrink', 'Energizante', 'Energy drink'),
  ShoppingCatalogEntry('beer', 'Cerveza', 'Beer'),
  ShoppingCatalogEntry('wine', 'Vino', 'Wine'),
  ShoppingCatalogEntry('vermouth', 'Vermouth', 'Vermouth'),
  ShoppingCatalogEntry('champagne', 'Champagne', 'Champagne'),
  ShoppingCatalogEntry('cider', 'Sidra', 'Cider'),
  ShoppingCatalogEntry('whisky', 'Whisky', 'Whisky'),
  ShoppingCatalogEntry('fernet', 'Fernet', 'Fernet'),
  ShoppingCatalogEntry('aperitif', 'Aperitivo', 'Aperitif'),
  ShoppingCatalogEntry('terma', 'Terma', 'Terma'),
  ShoppingCatalogEntry('chips', 'Papas fritas', 'Chips'),
  ShoppingCatalogEntry('cheesePuffs', 'Chizitos', 'Cheese puffs'),
  ShoppingCatalogEntry('pretzelSticks', 'Palitos', 'Pretzel sticks'),
  ShoppingCatalogEntry('popcorn', 'Pochoclos', 'Popcorn'),
  ShoppingCatalogEntry('chocolate', 'Chocolate', 'Chocolate'),
  ShoppingCatalogEntry('turron', 'Turrón', 'Turrón'),
  ShoppingCatalogEntry('alfajor', 'Alfajor', 'Alfajor'),
  ShoppingCatalogEntry('poundCake', 'Budín', 'Pound cake'),
  ShoppingCatalogEntry('iceCream', 'Helado', 'Ice cream'),
  ShoppingCatalogEntry('sweetCookies', 'Galletitas dulces', 'Sweet cookies'),
  ShoppingCatalogEntry('candy', 'Caramelos', 'Candy'),
  ShoppingCatalogEntry('gummies', 'Gomitas', 'Gummies'),
  ShoppingCatalogEntry('sweets', 'Golosinas', 'Sweets'),
  ShoppingCatalogEntry('peanuts', 'Maní', 'Peanuts'),
  ShoppingCatalogEntry('almonds', 'Almendras', 'Almonds'),
  ShoppingCatalogEntry('walnuts', 'Nueces', 'Walnuts'),
  ShoppingCatalogEntry('ibuprofen', 'Ibuprofeno', 'Ibuprofen'),
  ShoppingCatalogEntry('paracetamol', 'Paracetamol', 'Acetaminophen'),
  ShoppingCatalogEntry('aspirin', 'Aspirina', 'Aspirin'),
  ShoppingCatalogEntry('bandAids', 'Curitas', 'Bandages'),
  ShoppingCatalogEntry('alcohol', 'Alcohol', 'Alcohol'),
  ShoppingCatalogEntry('cotton', 'Algodón', 'Cotton'),
  ShoppingCatalogEntry('cottonSwabs', 'Hisopos', 'Cotton swabs'),
  ShoppingCatalogEntry('tissues', 'Pañuelos', 'Tissues'),
  ShoppingCatalogEntry('toothpaste', 'Dentífrico', 'Toothpaste'),
  ShoppingCatalogEntry('shampoo', 'Shampoo', 'Shampoo'),
  ShoppingCatalogEntry('conditioner', 'Acondicionador', 'Conditioner'),
  ShoppingCatalogEntry('bodyCream', 'Crema corporal', 'Body cream'),
  ShoppingCatalogEntry('sunscreen', 'Protector solar', 'Sunscreen'),
  ShoppingCatalogEntry('deodorant', 'Desodorante', 'Deodorant'),
  ShoppingCatalogEntry('antiperspirant', 'Antitranspirante', 'Antiperspirant'),
  ShoppingCatalogEntry('razor', 'Máquina afeitar', 'Razor'),
  ShoppingCatalogEntry('barSoap', 'Jabón tocador', 'Bar soap'),
  ShoppingCatalogEntry('liners', 'Protectores', 'Liners'),
  ShoppingCatalogEntry('pads', 'Toallitas', 'Pads'),
  ShoppingCatalogEntry('condoms', 'Preservativos', 'Condoms'),
  ShoppingCatalogEntry('dogFood', 'Alimento perro', 'Dog food'),
  ShoppingCatalogEntry('catFood', 'Alimento gato', 'Cat food'),
  ShoppingCatalogEntry('catStones', 'Piedras gato', 'Cat litter stones'),
  ShoppingCatalogEntry('catLitter', 'Arena gato', 'Cat litter'),
  ShoppingCatalogEntry('petTreats', 'Golosinas mascota', 'Pet treats'),
  ShoppingCatalogEntry('petBags', 'Bolsitas', 'Pet bags'),
  ShoppingCatalogEntry('frozenFries', 'Papas congeladas', 'Frozen fries'),
  ShoppingCatalogEntry(
    'frozenVegetables',
    'Verdura congelada',
    'Frozen vegetables',
  ),
  ShoppingCatalogEntry('frozenFish', 'Pescado congelado', 'Frozen fish'),
  ShoppingCatalogEntry('nuggets', 'Nuggets', 'Nuggets'),
  ShoppingCatalogEntry('ice', 'Hielo', 'Ice'),
  ShoppingCatalogEntry('oil', 'Aceite', 'Oil'),
  ShoppingCatalogEntry('vinegar', 'Vinagre', 'Vinegar'),
  ShoppingCatalogEntry('salt', 'Sal', 'Salt'),
  ShoppingCatalogEntry('pepperSpice', 'Pimienta', 'Pepper'),
  ShoppingCatalogEntry('seasonings', 'Condimentos', 'Seasonings'),
  ShoppingCatalogEntry('sugar', 'Azúcar', 'Sugar'),
  ShoppingCatalogEntry('sweetener', 'Edulcorante', 'Sweetener'),
  ShoppingCatalogEntry('pasta', 'Fideos', 'Pasta'),
  ShoppingCatalogEntry('rice', 'Arroz', 'Rice'),
  ShoppingCatalogEntry('flour', 'Harina', 'Flour'),
  ShoppingCatalogEntry('polenta', 'Polenta', 'Polenta'),
  ShoppingCatalogEntry('oats', 'Avena', 'Oats'),
  ShoppingCatalogEntry('cornFlakes', 'Copos de maíz', 'Corn flakes'),
  ShoppingCatalogEntry('bakingMix', 'Premezcla', 'Baking mix'),
  ShoppingCatalogEntry('cinnamon', 'Canela', 'Cinnamon'),
  ShoppingCatalogEntry('plunger', 'Sopapa', 'Plunger'),
  ShoppingCatalogEntry('lentils', 'Lentejas', 'Lentils'),
  ShoppingCatalogEntry('chickpeas', 'Garbanzo', 'Chickpeas'),
  ShoppingCatalogEntry('beans', 'Porotos', 'Beans'),
  ShoppingCatalogEntry('peas', 'Arvejas', 'Peas'),
  ShoppingCatalogEntry('coffee', 'Café', 'Coffee'),
  ShoppingCatalogEntry('cocoa', 'Cacao', 'Cocoa'),
  ShoppingCatalogEntry('yerbaMate', 'Yerba', 'Yerba mate'),
  ShoppingCatalogEntry('tea', 'Té', 'Tea'),
  ShoppingCatalogEntry('tuna', 'Atún', 'Tuna'),
  ShoppingCatalogEntry('tomatoSauce', 'Salsa de tomate', 'Tomato sauce'),
  ShoppingCatalogEntry('soySauce', 'Salsa soja', 'Soy sauce'),
  ShoppingCatalogEntry('ketchup', 'Ketchup', 'Ketchup'),
  ShoppingCatalogEntry('mayonnaise', 'Mayonesa', 'Mayonnaise'),
  ShoppingCatalogEntry('mustard', 'Mostaza', 'Mustard'),
  ShoppingCatalogEntry('jam', 'Mermelada', 'Jam'),
  ShoppingCatalogEntry(
    'bakingChocolate',
    'Chocolate cobertura',
    'Baking chocolate',
  ),
  ShoppingCatalogEntry('gelatin', 'Gelatina', 'Gelatin'),
];

String? shoppingCatalogKeyForName(String name) {
  final normalized = _normalizeShoppingName(name);
  if (normalized.isEmpty) return null;

  final index = _buildCatalogIndex();
  final firstWord = normalized.split(' ').first;
  final firstWordSingular = _singularize(firstWord);

  // 1. exact match
  final exact = index.exact[normalized];
  if (exact != null) return exact;

  // 2. first-word match
  final firstHit = index.firstWord[firstWord];
  if (firstHit != null) return firstHit;

  // 3. first-word singular match (plurals)
  if (firstWordSingular != firstWord) {
    final singHit = index.firstWord[firstWordSingular];
    if (singHit != null) return singHit;
  }

  // 4. substring match: longest alias contained in the name (length >= 4)
  String? bestKey;
  int bestLen = 3;
  for (final entry in index.substring) {
    if (entry.length > bestLen && normalized.contains(entry.alias)) {
      bestKey = entry.key;
      bestLen = entry.length;
    }
  }
  return bestKey;
}

class _CatalogIndex {
  _CatalogIndex({
    required this.exact,
    required this.firstWord,
    required this.substring,
  });

  final Map<String, String> exact;
  final Map<String, String> firstWord;
  final List<_SubstringEntry> substring;
}

class _SubstringEntry {
  _SubstringEntry(this.key, this.alias, this.length);

  final String key;
  final String alias;
  final int length;
}

_CatalogIndex? _cachedIndex;

_CatalogIndex _buildCatalogIndex() {
  if (_cachedIndex != null) return _cachedIndex!;

  final exact = <String, String>{};
  final firstWord = <String, String>{};
  final substring = <_SubstringEntry>[];

  for (final entry in shoppingCatalogEntries) {
    final aliases = <String>{
      entry.es,
      entry.en,
      ...?kShoppingCatalogAliases[entry.key],
    };
    for (final alias in aliases) {
      final norm = _normalizeShoppingName(alias);
      if (norm.isEmpty) continue;
      exact.putIfAbsent(norm, () => entry.key);
      final fw = norm.split(' ').first;
      firstWord.putIfAbsent(fw, () => entry.key);
      if (norm.length >= 4) {
        substring.add(_SubstringEntry(entry.key, norm, norm.length));
      }
    }
  }
  substring.sort((a, b) => b.length.compareTo(a.length));

  _cachedIndex = _CatalogIndex(
    exact: exact,
    firstWord: firstWord,
    substring: substring,
  );
  return _cachedIndex!;
}

String _normalizeShoppingName(String name) {
  if (name.isEmpty) return '';
  final stripped = _foldDiacritics(name).trim().toLowerCase();
  final collapsed = stripped.replaceAll(RegExp(r'\s+'), ' ');
  return collapsed;
}

String _foldDiacritics(String input) {
  // Asciifolding ES + EU basico: suficiente para los alias del catalogo.
  // Mantener equivalencia con public.normalize_shopping_name() de SQL.
  const map = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ä': 'a',
    'ë': 'e',
    'ï': 'i',
    'ö': 'o',
    'â': 'a',
    'ê': 'e',
    'î': 'i',
    'ô': 'o',
    'û': 'u',
    'à': 'a',
    'è': 'e',
    'ì': 'i',
    'ò': 'o',
    'ù': 'u',
    'ã': 'a',
    'ẽ': 'e',
    'ĩ': 'i',
    'õ': 'o',
    'ũ': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'ç': 'c',
    '¿': '',
    '¡': '',
  };
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    buffer.write(map[ch] ?? ch);
  }
  return buffer.toString();
}

String _singularize(String word) {
  final len = word.length;
  if (len <= 3) return word;
  if (len > 4 && word.endsWith('es') && !word.contains('ss')) {
    return word.substring(0, len - 2);
  }
  if (word.endsWith('s') && !word.endsWith('ss') && !word.endsWith('as')) {
    // Evita falsos positivos tipo "queso" (no plural) -> "queso" ya es singular.
    // 'as' solo aparece en plurales en ES; words que terminan en 'as' tipicamente
    // son plurales ("manzanas", "naranjas"). Para nuestra lista esto siempre
    // conviene singularizar.
    return word.substring(0, len - 1);
  }
  return word;
}

String localizedShoppingCatalogName(
  BuildContext context, {
  required String name,
  String? nameKey,
}) {
  final isEnglish = Localizations.localeOf(context).languageCode == 'en';
  final key = nameKey ?? shoppingCatalogKeyForName(name);
  if (key == null) return name;

  for (final entry in shoppingCatalogEntries) {
    if (entry.key == key) return isEnglish ? entry.en : entry.es;
  }

  return name;
}

String localizedShoppingCategoryName(
  BuildContext context,
  String categoryId, {
  String? fallback,
}) {
  final isEnglish = Localizations.localeOf(context).languageCode == 'en';
  if (!isEnglish) return fallback ?? _spanishShoppingCategoryName(categoryId);

  switch (categoryId) {
    case 'general':
      return 'Frequent';
    case 'fruits':
      return 'Fruit & vegetables';
    case 'meat':
      return 'Meat';
    case 'dairy':
      return 'Dairy';
    case 'bakery':
      return 'Bakery';
    case 'pantry':
      return 'Pantry';
    case 'frozen':
      return 'Frozen';
    case 'cleaning':
      return 'Cleaning';
    case 'drinks':
      return 'Drinks';
    case 'snacks':
      return 'Snacks';
    case 'pharmacy':
      return 'Pharmacy';
    case 'pets':
      return 'Pets';
    default:
      return fallback ?? categoryId;
  }
}

String _spanishShoppingCategoryName(String categoryId) {
  switch (categoryId) {
    case 'general':
      return 'Frecuentes';
    case 'fruits':
      return 'Frutas y verduras';
    case 'meat':
      return 'Carnes';
    case 'dairy':
      return 'Lácteos';
    case 'bakery':
      return 'Panadería';
    case 'pantry':
      return 'Despensa';
    case 'frozen':
      return 'Congelados';
    case 'cleaning':
      return 'Limpieza';
    case 'drinks':
      return 'Bebidas';
    case 'snacks':
      return 'Snacks';
    case 'pharmacy':
      return 'Farmacia';
    case 'pets':
      return 'Mascotas';
    default:
      return categoryId;
  }
}

String localizedShoppingItemName(BuildContext context, ShoppingItemModel item) {
  return localizedShoppingCatalogName(
    context,
    name: item.name,
    nameKey: item.nameKey,
  );
}
