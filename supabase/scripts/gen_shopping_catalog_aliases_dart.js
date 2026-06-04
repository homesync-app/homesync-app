#!/usr/bin/env node
// Genera un archivo Dart con un Map<String, List<String>> de aliases por key,
// a partir de bg_removal/icons/aliases_seed.json. Pensado para ejecutarse
// manualmente:
//
//   node supabase/scripts/seed_shopping_catalog_keys.js > ...     # SQL
//   node supabase/scripts/gen_shopping_catalog_aliases_dart.js > flutter_client/lib/features/shopping/data/shopping_catalog_aliases.dart
//
// El archivo Dart se commitea para que la app pueda hacer matching
// sincronico (offline-first) sin esperar a descargar el manifest de storage.

const fs = require('fs');
const path = require('path');

const outArg = process.argv[2];
const seedPath = path.join(
  __dirname,
  '..',
  '..',
  'bg_removal',
  'icons',
  'aliases_seed.json',
);

const raw = JSON.parse(fs.readFileSync(seedPath, 'utf8'));

const escape = (s) => s.replace(/'/g, "\\'");

const lines = [
  "// GENERATED FILE. DO NOT EDIT.",
  "// Source: bg_removal/icons/aliases_seed.json",
  "// Regenerate with: node supabase/scripts/gen_shopping_catalog_aliases_dart.js > flutter_client/lib/features/shopping/data/shopping_catalog_aliases.dart",
  "//",
  "// Solo contiene los aliases crudos. La funcion de matching (normalize +",
  "// first-word + singularize + substring) vive en shopping_localization.dart",
  "// y se mantiene sincronizada con la logica server-side en",
  "// supabase/migrations/20260604130000_shopping_catalog_keys_table_and_function.sql.",
  "",
  "const Map<String, List<String>> kShoppingCatalogAliases = {",
];

const keys = Object.keys(raw)
  .filter((k) => !k.startsWith('_'))
  .sort();
for (const key of keys) {
  const aliases = raw[key];
  if (!Array.isArray(aliases) || aliases.length === 0) continue;
  const arr = aliases.map((a) => `'${escape(a)}'`).join(', ');
  lines.push(`  '${escape(key)}': [${arr}],`);
}
lines.push("};");

const out = lines.join('\n') + '\n';

if (outArg) {
  fs.writeFileSync(outArg, out, { encoding: 'utf8' });
  process.stderr.write(`wrote ${out.length} bytes to ${outArg}\n`);
} else {
  process.stdout.write(out);
}
