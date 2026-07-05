// Procesa los PNG crudos de out/raw/ -> recorta fondo + normaliza a 192x192.
// Salida: out/icons/{key}.png  (PNG transparente, listo para subir)
//
// Uso:
//   node process.js                  -> procesa todo lo que haya en out/raw/
//   node process.js milk bread       -> solo esas keys

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const { removeBackground } = require('@imgly/background-removal-node');

const RAW_DIR = path.join(__dirname, 'out', 'raw');
const OUT_DIR = path.join(__dirname, 'out', 'icons');
fs.mkdirSync(OUT_DIR, { recursive: true });

const SIZE = 192; // px final (cubre 64dp @ xxhdpi)

async function processOne(key) {
  const rawPath = path.join(RAW_DIR, `${key}.png`);
  if (!fs.existsSync(rawPath)) {
    throw new Error('no existe el raw');
  }

  // 1) recorte de fondo (blanco -> alpha)
  const fileUri = `file://${rawPath.replace(/\\/g, '/')}`;
  const blob = await removeBackground(fileUri);
  const cutout = Buffer.from(await blob.arrayBuffer());

  // 2) recortar al bounding box del objeto (trim de alpha sobrante) y
  //    encajar en un cuadrado 192x192 con padding parejo.
  const trimmed = await sharp(cutout)
    .trim({ threshold: 10 })
    .toBuffer();

  const canvas = Math.round(SIZE * 0.84); // ~16% padding total
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

  console.log(`Procesando ${keys.length} icono(s)...\n`);
  let ok = 0;
  let failed = 0;
  for (const key of keys) {
    process.stdout.write(`  ${key.padEnd(20)} `);
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
