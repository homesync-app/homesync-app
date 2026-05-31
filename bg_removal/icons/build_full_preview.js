// Genera una preview HTML de TODOS los iconos procesados, con nombre español.
const fs = require('fs');
const path = require('path');
const { catalog } = require('./catalog');

const ICONS_DIR = path.join(__dirname, 'out', 'icons');
const OUT = path.join(
  __dirname, '..', '..', 'design', 'shopping_icons_preview', 'preview_full.html',
);

// nombres es sacados del catálogo de la app (key -> es) mínimos para la preview
const esNames = {
  tomato:'Tomate',onion:'Cebolla',greenOnion:'Verdeo',potato:'Papa',apple:'Manzana',
  banana:'Banana',pear:'Pera',peach:'Durazno',lemon:'Limón',orange:'Naranja',
  tangerine:'Mandarina',grapefruit:'Pomelo',kiwi:'Kiwi',pineapple:'Ananá',
  strawberry:'Frutilla',grapes:'Uvas',watermelon:'Sandía',carrot:'Zanahoria',
  garlic:'Ajo',ginger:'Jengibre',lettuce:'Lechuga',arugula:'Rúcula',spinach:'Espinaca',
  chard:'Acelga',celery:'Apio',avocado:'Palta',bellPepper:'Morrón',pepper:'Pimiento',
  pumpkin:'Zapallo',sweetPotato:'Batata',boniato:'Boniato',broccoli:'Brócoli',
  eggplant:'Berenjena',mushrooms:'Champiñones',corn:'Choclo',cucumber:'Pepino',beet:'Remolacha',
  groundBeef:'Carne picada',chicken:'Pollo',fish:'Pescado',pork:'Cerdo',bondiola:'Bondiola',
  flankSteak:'Vacío',matambre:'Matambre',peceto:'Peceto',ribs:'Costillas',milanesas:'Milanesas',
  sausages:'Salchichas',chorizo:'Chorizo',burgers:'Hamburguesas',bacon:'Panceta',
  milk:'Leche',plantMilk:'Leche vegetal',condensedMilk:'Leche cond.',chocolateMilk:'Choco milk',
  freshCheese:'Queso fresco',gratedCheese:'Queso rallado',creamCheese:'Queso crema',
  provolone:'Provolone',mozzarella:'Mozzarella',butter:'Manteca',cream:'Crema',yogurt:'Yogur',
  drinkableYogurt:'Yogur bebible',eggs:'Huevos',dulceDeLeche:'Dulce de leche',tofu:'Tofu',
  hummus:'Hummus',bread:'Pan',sandwichBread:'Pan lactal',breadcrumbs:'Pan rallado',toast:'Tostadas',
  croissants:'Medialunas',criollos:'Criollos',biscuits:'Bizcochos',ladyfingers:'Vainillas',
  cookies:'Galletas',tart:'Tarta',detergent:'Detergente',bleach:'Lavandina',glassCleaner:'Limpiavidrios',
  floorCleaner:'Limpiapisos',multipurposeCleaner:'Multiuso',degreaser:'Desengrasante',
  disinfectant:'Desinfectante',insecticide:'Insecticida',toiletPaper:'Papel hig.',kitchenRoll:'Rollo cocina',
  sponge:'Esponja',dishcloth:'Rejilla',broom:'Escoba',laundrySoap:'Jabón ropa',softener:'Suavizante',
  bags:'Bolsas',water:'Agua',flavoredWater:'Agua sab.',sparklingWater:'Soda',tonicWater:'Tónica',
  soda:'Gaseosa',cocaCola:'Coca',juice:'Jugo',sportsDrink:'Isotónico',energyDrink:'Energizante',
  beer:'Cerveza',wine:'Vino',vermouth:'Vermouth',champagne:'Champagne',cider:'Sidra',whisky:'Whisky',
  fernet:'Fernet',aperitif:'Aperitivo',terma:'Terma',chips:'Papas fritas',cheesePuffs:'Chizitos',
  pretzelSticks:'Palitos',popcorn:'Pochoclos',chocolate:'Chocolate',turron:'Turrón',alfajor:'Alfajor',
  poundCake:'Budín',iceCream:'Helado',sweetCookies:'Galletitas',candy:'Caramelos',gummies:'Gomitas',
  sweets:'Golosinas',peanuts:'Maní',almonds:'Almendras',walnuts:'Nueces',ibuprofen:'Ibuprofeno',
  paracetamol:'Paracetamol',aspirin:'Aspirina',bandAids:'Curitas',alcohol:'Alcohol',cotton:'Algodón',
  cottonSwabs:'Hisopos',tissues:'Pañuelos',toothpaste:'Dentífrico',shampoo:'Shampoo',conditioner:'Acond.',
  bodyCream:'Crema corp.',sunscreen:'Protector',deodorant:'Desodorante',antiperspirant:'Antitransp.',
  razor:'Afeitadora',barSoap:'Jabón',liners:'Protectores',pads:'Toallitas',condoms:'Preservativos',
  dogFood:'Alim. perro',catFood:'Alim. gato',catStones:'Piedras gato',catLitter:'Arena gato',
  petTreats:'Snacks mascota',petBags:'Bolsitas',frozenFries:'Papas cong.',frozenVegetables:'Verdura cong.',
  frozenFish:'Pescado cong.',nuggets:'Nuggets',ice:'Hielo',oil:'Aceite',vinegar:'Vinagre',salt:'Sal',
  pepperSpice:'Pimienta',seasonings:'Condimentos',sugar:'Azúcar',sweetener:'Edulcorante',pasta:'Fideos',
  rice:'Arroz',flour:'Harina',polenta:'Polenta',oats:'Avena',lentils:'Lentejas',chickpeas:'Garbanzos',
  beans:'Porotos',peas:'Arvejas',coffee:'Café',cocoa:'Cacao',yerbaMate:'Yerba',tea:'Té',tuna:'Atún',
  tomatoSauce:'Salsa tomate',soySauce:'Salsa soja',ketchup:'Ketchup',mayonnaise:'Mayonesa',mustard:'Mostaza',
  jam:'Mermelada',bakingChocolate:'Choco cob.',gelatin:'Gelatina',
};

const cards = catalog
  .filter(([k]) => fs.existsSync(path.join(ICONS_DIR, `${k}.png`)))
  .map(([k]) => `<div class="tile"><img src="png/${k}.png" loading="lazy"><div class="nm">${esNames[k]||k}</div></div>`)
  .join('\n');

const total = catalog.filter(([k]) => fs.existsSync(path.join(ICONS_DIR, `${k}.png`))).length;

const html = `<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>HomeSync · Set completo de iconos (${total})</title>
<style>
  :root{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;}
  body{margin:0;background:#FFFCF9;color:#4A4443;}
  header{padding:24px 28px 8px;position:sticky;top:0;background:#FFFCF9;border-bottom:1px solid #F0E4D9;z-index:5;}
  header h1{margin:0 0 4px;font-size:20px;}
  header p{margin:0;color:#8E8480;font-size:14px;}
  .toggle{margin-top:10px;font-size:13px;color:#8E8480;}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(110px,1fr));gap:12px;padding:20px 28px 60px;}
  .tile{background:#FFF0EA;border-radius:20px;padding:14px 6px 10px;display:flex;flex-direction:column;align-items:center;gap:8px;}
  .tile img{width:60px;height:60px;object-fit:contain;}
  .tile .nm{font-size:11.5px;font-weight:600;text-align:center;line-height:1.2;}
  body.dark{background:#1B1716;color:#F8FAFC;}
  body.dark header{background:#1B1716;border-color:#342E2B;}
  body.dark .tile{background:#2F2927;}
</style></head><body>
<header>
  <h1>Set completo — ${total} iconos</h1>
  <p>Todos generados con el prompt final + 4 referencias. Fondo crema real de la app. Marcá los que haya que regenerar.</p>
  <label class="toggle"><input type="checkbox" id="dk"> Modo oscuro</label>
</header>
<div class="grid">
${cards}
</div>
<script>
  document.getElementById('dk').addEventListener('change',e=>{
    document.body.classList.toggle('dark', e.target.checked);
  });
</script>
</body></html>`;

fs.writeFileSync(OUT, html);
console.log(`Preview generada: ${OUT} (${total} iconos)`);
