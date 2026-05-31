// Descarga una muestra de los iconos que YA están en el bucket para
// compararlos con el estilo nuevo. Salida: out/existing/{key}.png
const fs = require('fs');
const path = require('path');

const BASE =
  'https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/shopping-icons';
const OUT = path.join(__dirname, 'out', 'existing');
fs.mkdirSync(OUT, { recursive: true });

// muestra variada: lácteos, fiambres, snacks, condimentos, bebidas, frutas...
const sample = [
  'milanesas', 'dulceDeLeche', 'fernet', 'yogurt', 'mozzarella',
  'mayonnaise', 'cocaCola', 'alfajor', 'mushrooms', 'butter',
  'tuna', 'oil', 'chorizo', 'gummies', 'sugar',
];

async function main() {
  const manifestResp = await fetch(`${BASE}/manifest.json`);
  const manifest = await manifestResp.json();
  let ok = 0;
  for (const key of sample) {
    const v = manifest[key];
    if (!v) {
      console.log(`  ${key.padEnd(16)} (no está en manifest)`);
      continue;
    }
    const url = `${BASE}/products/${key}.png?v=${v}`;
    const r = await fetch(url);
    if (!r.ok) {
      console.log(`  ${key.padEnd(16)} FALLO ${r.status}`);
      continue;
    }
    const buf = Buffer.from(await r.arrayBuffer());
    fs.writeFileSync(path.join(OUT, `${key}.png`), buf);
    console.log(`  ${key.padEnd(16)} OK (${Math.round(buf.length / 1024)}KB)`);
    ok++;
  }
  console.log(`\nDescargados: ${ok} en ${OUT}`);
}

main();
