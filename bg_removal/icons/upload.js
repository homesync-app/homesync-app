// Sube los iconos de out/icons/ al bucket `shopping-icons/products/` y
// actualiza el manifest.json (merge con el existente, subiendo versión).
//
// Requiere SUPABASE_SERVICE_ROLE_KEY en .env para escritura en Storage
// (la anon key normalmente no tiene permiso de INSERT en el bucket).
//
// Uso:
//   node icons/upload.js              (correr desde bg_removal/)
//   node icons/upload.js milk bread   -> solo esas keys

const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://tfavamqszdkoeabpyxms.supabase.co';
const KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
const BUCKET = 'shopping-icons';

if (!KEY) {
  console.error(
    'Falta SUPABASE_SERVICE_ROLE_KEY (o SUPABASE_ANON_KEY) en icons/.env',
  );
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, KEY);
const OUT_DIR = path.join(__dirname, 'out', 'icons');
const MANIFEST_URL = `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/manifest.json`;

async function fetchManifest() {
  try {
    const r = await fetch(MANIFEST_URL);
    if (r.ok) return await r.json();
  } catch (_) {}
  return {};
}

async function main() {
  const requested = process.argv.slice(2);
  let keys = requested;
  if (!keys.length) {
    keys = fs
      .readdirSync(OUT_DIR)
      .filter((f) => f.endsWith('.png'))
      .map((f) => f.replace(/\.png$/, ''));
  }

  const manifest = await fetchManifest();
  console.log(`Manifest actual: ${Object.keys(manifest).length} iconos`);
  console.log(`Subiendo ${keys.length}...\n`);

  let ok = 0;
  for (const key of keys) {
    const filePath = path.join(OUT_DIR, `${key}.png`);
    if (!fs.existsSync(filePath)) {
      console.log(`  ${key.padEnd(20)} SKIP (no existe el png)`);
      continue;
    }
    const buf = fs.readFileSync(filePath);
    const { error } = await supabase.storage
      .from(BUCKET)
      .upload(`products/${key}.png`, buf, {
        contentType: 'image/png',
        upsert: true,
      });
    if (error) {
      console.log(`  ${key.padEnd(20)} FALLO -> ${error.message}`);
      continue;
    }
    // subir versión para cache-busting
    const prev = parseInt(manifest[key] ?? '0', 10) || 0;
    manifest[key] = String(prev + 1);
    console.log(`  ${key.padEnd(20)} OK (v${manifest[key]})`);
    ok++;
  }

  // subir manifest actualizado
  const manifestBuf = Buffer.from(JSON.stringify(manifest, null, 2));
  const { error: mErr } = await supabase.storage
    .from(BUCKET)
    .upload('manifest.json', manifestBuf, {
      contentType: 'application/json',
      upsert: true,
    });
  if (mErr) {
    console.log(`\nFALLO al subir manifest -> ${mErr.message}`);
    process.exit(1);
  }

  console.log(`\nListo. Subidos: ${ok}. Manifest: ${Object.keys(manifest).length} iconos.`);
}

main();
