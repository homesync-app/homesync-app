// Sube los iconos de out/icons/ al bucket `shopping-icons/products/` y
// actualiza el manifest.json (merge con el existente, subiendo versión).
// Tambien sincroniza aliases desde icons/aliases_seed.json al manifest.
//
// Formato del manifest (SKOS-style, backward compatible con el viejo):
//   { "milk": { "v": "3", "aliases": { "es": ["leche", "leche comun"] } } }
//
// Requiere SUPABASE_SERVICE_ROLE_KEY en .env para escritura en Storage
// (la anon key normalmente no tiene permiso de INSERT en el bucket).
//
// Uso:
//   node icons/upload.js              (sube todos los pngs en out/icons/ y merge aliases)
//   node icons/upload.js milk bread   -> solo esas keys
//   node icons/upload.js --sync-aliases   (solo merge aliases, sin tocar pngs)

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
const ALIASES_SEED_PATH = path.join(__dirname, 'aliases_seed.json');

const stripMeta = (entry) => {
  if (entry && typeof entry === 'object' && !Array.isArray(entry)) {
    const { _comment, ...rest } = entry;
    return rest;
  }
  return entry;
};

function loadAliasesSeed() {
  if (!fs.existsSync(ALIASES_SEED_PATH)) return {};
  const raw = JSON.parse(fs.readFileSync(ALIASES_SEED_PATH, 'utf8'));
  return stripMeta(raw) || {};
}

function readVersion(entry) {
  if (typeof entry === 'string') return parseInt(entry, 10) || 0;
  if (entry && typeof entry === 'object') return parseInt(entry.v, 10) || 0;
  return 0;
}

function readAliases(entry) {
  if (entry && typeof entry === 'object' && entry.aliases) return entry.aliases;
  return {};
}

function bumpEntry(prev, seedAliases) {
  const prevVersion = readVersion(prev);
  const next = {
    v: String(prevVersion + 1),
    aliases: readAliases(prev),
  };
  if (seedAliases && seedAliases.length) {
    const cur = next.aliases.es ?? [];
    next.aliases = {
      ...next.aliases,
      es: Array.from(new Set([...cur, ...seedAliases])),
    };
  }
  return next;
}

async function fetchManifest() {
  try {
    const r = await fetch(MANIFEST_URL);
    if (r.ok) return await r.json();
  } catch (_) {}
  return {};
}

async function main() {
  const argv = process.argv.slice(2);
  const syncAliasesOnly = argv.includes('--sync-aliases');
  const requested = argv.filter((a) => a !== '--sync-aliases');

  const seed = loadAliasesSeed();
  const manifest = await fetchManifest();
  console.log(`Manifest actual: ${Object.keys(manifest).length} iconos`);
  console.log(`Aliases seed:   ${Object.keys(seed).length} keys con aliases`);

  let pngKeys = [];
  if (syncAliasesOnly) {
    pngKeys = [];
  } else if (requested.length) {
    pngKeys = requested;
  } else {
    pngKeys = fs
      .readdirSync(OUT_DIR)
      .filter((f) => f.endsWith('.png'))
      .map((f) => f.replace(/\.png$/, ''));
  }

  let ok = 0;
  for (const key of pngKeys) {
    const filePath = path.join(OUT_DIR, `${key}.png`);
    if (!syncAliasesOnly && !fs.existsSync(filePath)) {
      console.log(`  ${key.padEnd(20)} SKIP (no existe el png)`);
      continue;
    }
    if (!syncAliasesOnly) {
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
    }
    const prev = manifest[key];
    const next = bumpEntry(prev, seed[key]);
    manifest[key] = next;
    console.log(
      `  ${key.padEnd(20)} OK (v${next.v}${
        seed[key] ? ` +${seed[key].length} aliases` : ''
      })`,
    );
    ok++;
  }

  if (syncAliasesOnly) {
    for (const key of Object.keys(seed)) {
      if (manifest[key] && typeof manifest[key] === 'object') {
        const cur = manifest[key].aliases?.es ?? [];
        if (cur.length === 0 || !cur.includes(seed[key][0])) {
          manifest[key] = bumpEntry(manifest[key], seed[key]);
          console.log(`  ${key.padEnd(20)} alias sync (v${manifest[key].v})`);
          ok++;
        }
      } else if (manifest[key]) {
        manifest[key] = bumpEntry(manifest[key], seed[key]);
        console.log(`  ${key.padEnd(20)} alias sync + format bump (v${manifest[key].v})`);
        ok++;
      } else {
        console.log(
          `  ${key.padEnd(20)} SKIP alias (key no existe en manifest todavía)`,
        );
      }
    }
  }

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

  console.log(
    `\nListo. Procesados: ${ok}. Manifest: ${Object.keys(manifest).length} iconos.`,
  );
}

main();
