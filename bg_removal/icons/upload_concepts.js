// Sube los conceptos de out/icons_concepts/ al bucket shopping-icons bajo
// la carpeta concepts/, y mantiene un manifest separado: concepts_manifest.json
// Correr desde bg_removal/. Requiere SUPABASE_SERVICE_ROLE_KEY en icons/.env

const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://tfavamqszdkoeabpyxms.supabase.co';
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const BUCKET = 'shopping-icons';

if (!KEY) {
  console.error('Falta SUPABASE_SERVICE_ROLE_KEY en icons/.env');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, KEY);
const OUT_DIR = path.join(__dirname, 'out', 'icons_concepts');
const MANIFEST_URL =
  `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/concepts_manifest.json`;

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
  console.log(`Manifest concepts actual: ${Object.keys(manifest).length}`);
  console.log(`Subiendo ${keys.length} conceptos...\n`);

  let ok = 0;
  for (const key of keys) {
    const filePath = path.join(OUT_DIR, `${key}.png`);
    if (!fs.existsSync(filePath)) {
      console.log(`  ${key.padEnd(18)} SKIP (no existe)`);
      continue;
    }
    const buf = fs.readFileSync(filePath);
    const { error } = await supabase.storage
      .from(BUCKET)
      .upload(`concepts/${key}.png`, buf, {
        contentType: 'image/png',
        upsert: true,
      });
    if (error) {
      console.log(`  ${key.padEnd(18)} FALLO -> ${error.message}`);
      continue;
    }
    const prev = parseInt(manifest[key] ?? '0', 10) || 0;
    manifest[key] = String(prev + 1);
    console.log(`  ${key.padEnd(18)} OK (v${manifest[key]})`);
    ok++;
  }

  const manifestBuf = Buffer.from(JSON.stringify(manifest, null, 2));
  const { error: mErr } = await supabase.storage
    .from(BUCKET)
    .upload('concepts_manifest.json', manifestBuf, {
      contentType: 'application/json',
      upsert: true,
    });
  if (mErr) {
    console.log(`\nFALLO manifest -> ${mErr.message}`);
    process.exit(1);
  }
  console.log(`\nListo. Subidos: ${ok}. Manifest concepts: ${Object.keys(manifest).length}.`);
}

main();
