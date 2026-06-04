// One-off migration: convierte el manifest del formato viejo `{key: versionString}`
// al formato nuevo `{key: {v, aliases}}` (SKOS-style). Idempotente: si una key
// ya está en el formato nuevo, no la toca (excepto merge de aliases).
//
// Uso:
//   node icons/migrate_manifest.js
//
// Lee aliases_seed.json (si existe) y lo mergea. Sube el manifest nuevo al bucket.

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

function migrateEntry(prev, seedAliases) {
  let entry;
  if (typeof prev === 'string') {
    entry = { v: prev, aliases: {} };
  } else if (prev && typeof prev === 'object') {
    entry = {
      v: prev.v ?? '1',
      aliases: prev.aliases ?? {},
    };
  } else {
    entry = { v: '1', aliases: {} };
  }
  if (seedAliases && seedAliases.length) {
    const cur = entry.aliases.es ?? [];
    const merged = Array.from(new Set([...cur, ...seedAliases]));
    entry.aliases = { ...entry.aliases, es: merged };
  }
  return entry;
}

async function main() {
  const r = await fetch(MANIFEST_URL);
  if (!r.ok) {
    console.error(`No pude bajar el manifest (${r.status})`);
    process.exit(1);
  }
  const oldManifest = await r.json();
  const seed = loadAliasesSeed();

  const newManifest = {};
  let migrated = 0;
  let touchedAliases = 0;
  let removed = 0;
  for (const [key, prev] of Object.entries(oldManifest)) {
    const seedAliases = seed[key];
    const next = migrateEntry(prev, seedAliases);
    newManifest[key] = next;
    if (typeof prev === 'string') migrated++;
    if (seedAliases && seedAliases.length) touchedAliases++;
  }

  if (Object.keys(newManifest).length !== Object.keys(oldManifest).length) {
    removed = Object.keys(oldManifest).length - Object.keys(newManifest).length;
  }

  const buf = Buffer.from(JSON.stringify(newManifest, null, 2));
  const { error } = await supabase.storage
    .from(BUCKET)
    .upload('manifest.json', buf, {
      contentType: 'application/json',
      upsert: true,
    });
  if (error) {
    console.error(`Fallo al subir manifest: ${error.message}`);
    process.exit(1);
  }

  const totalAliases = Object.values(newManifest).reduce(
    (acc, e) => acc + (e.aliases?.es?.length ?? 0),
    0,
  );
  console.log(`Migración OK`);
  console.log(`  Keys totales:     ${Object.keys(newManifest).length}`);
  console.log(`  Formato viejo:    ${migrated} keys migradas a {v, aliases}`);
  console.log(`  Keys con aliases: ${touchedAliases}`);
  console.log(`  Aliases totales:  ${totalAliases}`);
  if (removed) console.log(`  Keys removidas:   ${removed}`);
}

main();
