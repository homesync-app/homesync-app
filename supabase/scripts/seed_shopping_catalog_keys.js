#!/usr/bin/env node
// Genera una migracion SQL con INSERTs de los 188 keys/aliases a partir de
// `bg_removal/icons/aliases_seed.json`. Pensado para ejecutarse manualmente:
//
//   node supabase/scripts/seed_shopping_catalog_keys.js > supabase/migrations/<ts>_shopping_catalog_keys_seed.sql
//
// El output se concatena a la migracion estructural (tabla + funcion) o se
// usa solo si solo cambian los aliases. Idempotente: usa ON CONFLICT (key) DO UPDATE.

const fs = require('fs');
const path = require('path');

const seedPath = path.join(
  __dirname,
  '..',
  '..',
  'bg_removal',
  'icons',
  'aliases_seed.json',
);

const raw = JSON.parse(fs.readFileSync(seedPath, 'utf8'));

const entries = [];
for (const [key, aliases] of Object.entries(raw)) {
  if (key.startsWith('_')) continue;
  if (!Array.isArray(aliases) || aliases.length === 0) continue;
  entries.push([key, aliases]);
}
entries.sort((a, b) => a[0].localeCompare(b[0]));

const escape = (s) => s.replace(/'/g, "''");

console.log('-- Seed generated from bg_removal/icons/aliases_seed.json');
console.log('-- ' + entries.length + ' keys');
console.log('');
console.log('TRUNCATE public.shopping_catalog_keys;');
console.log('');
for (const [key, aliases] of entries) {
  const arr = aliases.map((a) => `'${escape(a)}'`).join(', ');
  console.log(
    `INSERT INTO public.shopping_catalog_keys (key, es_names) VALUES ('${escape(key)}', ARRAY[${arr}]);`,
  );
}
