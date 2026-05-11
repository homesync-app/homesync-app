import 'package:flutter/widgets.dart';

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
  ShoppingCatalogEntry('matambre', 'Matambre', 'Matambre'),
  ShoppingCatalogEntry('peceto', 'Peceto', 'Eye round'),
  ShoppingCatalogEntry('ribs', 'Costillas', 'Ribs'),
  ShoppingCatalogEntry('milanesas', 'Milanesas', 'Milanesas'),
  ShoppingCatalogEntry('sausages', 'Salchichas', 'Sausages'),
  ShoppingCatalogEntry('chorizo', 'Chorizo', 'Chorizo'),
  ShoppingCatalogEntry('burgers', 'Hamburguesas', 'Burgers'),
  ShoppingCatalogEntry('bacon', 'Panceta', 'Bacon'),
  ShoppingCatalogEntry('milk', 'Leche', 'Milk'),
  ShoppingCatalogEntry('plantMilk', 'Leche vegetal', 'Plant milk'),
  ShoppingCatalogEntry('condensedMilk', 'Leche condensada', 'Condensed milk'),
  ShoppingCatalogEntry('chocolateMilk', 'Leche chocolatada', 'Chocolate milk'),
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
      'multipurposeCleaner', 'Multiuso', 'Multi-purpose cleaner',),
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
      'frozenVegetables', 'Verdura congelada', 'Frozen vegetables',),
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
      'bakingChocolate', 'Chocolate cobertura', 'Baking chocolate',),
  ShoppingCatalogEntry('gelatin', 'Gelatina', 'Gelatin'),
];

String? shoppingCatalogKeyForName(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  for (final entry in shoppingCatalogEntries) {
    if (entry.es.toLowerCase() == normalized ||
        entry.en.toLowerCase() == normalized) {
      return entry.key;
    }
  }

  return null;
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

String localizedShoppingItemName(BuildContext context, ShoppingItemModel item) {
  return localizedShoppingCatalogName(
    context,
    name: item.name,
    nameKey: item.nameKey,
  );
}
