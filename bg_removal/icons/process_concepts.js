// Procesa los PNG crudos de conceptos: recorta fondo + normaliza a 192x192.
// Lee de out/raw_concepts/ -> escribe out/icons_concepts/
// Correr desde bg_removal/ (para que @imgly encuentre sus recursos).
//
// Uso:
//   node icons/process_concepts.js              -> todo lo de raw_concepts
//   node icons/process_concepts.js gift trophy   -> esas claves

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const { removeBackground } = require('@imgly/background-removal-node');

const RAW_DIR = path.join(__dirname, 'out', 'raw_concepts');
const OUT_DIR = path.join(__dirname, 'out', 'icons_concepts');
fs.mkdirSync(OUT_DIR, { recursive: true });

const SIZE = 192;

async function processOne(key) {
  const rawPath = path.join(RAW_DIR, `${key}.png`);
  if (!fs.existsSync(rawPath)) throw new Error('no existe el raw');

  const fileUri = `file://${rawPath.replace(/\\/g, '/')}`;
  const blob = await removeBackground(fileUri);
  const cutout = Buffer.from(await blob.arrayBuffer());

  const trimmed = await sharp(cutout).trim({ threshold: 10 }).toBuffer();

  const canvas = Math.round(SIZE * 0.84);
  const resized = await sharp(trimmed)
    .resize(canvas, canvas, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .toBuffer();

  const pad = Math.round((SIZE - canvas) / 2);
  const outPath = path.join(OUT_DIR, `${key}.png`);
  await sharp({
    create: {
      width: SIZE,
      height: SIZE,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    },
  })
    .composite([{ input: resized, top: pad, left: pad }])
    .png({ compressionLevel: 9 })
    .toFile(outPath);
  return outPath;
}

async function main() {
  const requested = process.argv.slice(2);
  let keys = requested;
  if (!keys.length) {
    keys = fs
      .readdirSync(RAW_DIR)
      .filter((f) => f.endsWith('.png'))
      .map((f) => f.replace(/\.png$/, ''));
  }
  console.log(`Procesando ${keys.length} concepto(s)...\n`);
  let ok = 0;
  let failed = 0;
  for (const key of keys) {
    process.stdout.write(`  ${key.padEnd(18)} `);
    try {
      await processOne(key);
      console.log('OK');
      ok++;
    } catch (e) {
      console.log(`FALLO -> ${e.message}`);
      failed++;
    }
  }
  console.log(`\nListo. OK: ${ok}  Fallos: ${failed}`);
  console.log(`Iconos en: ${OUT_DIR}`);
}

main();
