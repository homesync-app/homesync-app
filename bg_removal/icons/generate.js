// Genera iconos de productos con la API de Gemini (nanobanana).
// Uso:
//   node generate.js milk bread carrot apple      -> genera esas keys
//   node generate.js                              -> genera TODO el catálogo
//
// Salida: out/raw/{key}.png  (PNG con fondo, todavía sin recortar)
// La key de Gemini sale de .env (GEMINI_API_KEY). NO se hardcodea.

const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const { catalog } = require('./catalog');

const API_KEY = process.env.GEMINI_API_KEY;
const MODEL = (process.env.GEMINI_IMAGE_MODEL || 'gemini-3-pro-image').trim();

if (!API_KEY) {
  console.error('Falta GEMINI_API_KEY en bg_removal/icons/.env');
  process.exit(1);
}

const RAW_DIR = path.join(__dirname, 'out', 'raw');
fs.mkdirSync(RAW_DIR, { recursive: true });

// Preámbulo de estilo del ICON_BRIEF.md. Es lo que da consistencia entre iconos.
// CLAVE: cada producto conserva su COLOR REAL, suavizado a pastel. La paleta
// cálida de la app es solo el "acabado"/ambiente, NO se repinta el objeto.
// Nota: la API NO genera transparencia -> pedimos fondo BLANCO PLANO y lo
// recortamos después con process.js.
function buildPrompt(noun) {
  return [
    `Flat modern illustration of a single ${noun}, centered, front 3/4 view.`,
    'Soft rounded shapes, no black outlines, gentle soft inner shading, even flat',
    'lighting with a subtle highlight on the top-left.',
    // --- color del producto ---
    'IMPORTANT: keep the realistic, true-to-life colors of the object itself',
    '(milk is white, an apple is red, bread is golden brown, leafy greens are',
    'green, etc.). Render those natural colors as soft, slightly muted pastel',
    'tones so they feel cohesive and gentle, but DO NOT recolor the object',
    'orange or terracotta. Never change a food to an unnatural color.',
    // --- ambiente / app ---
    'Overall mood is cozy, friendly and homey, matching a warm cream interface.',
    'Use warm terracotta/peach (#EE652B, #E88D67) only as subtle accents on',
    'neutral parts like caps, labels, lids or wrappers, never as the main body',
    'color of natural produce.',
    'Minimal detail, must read clearly at small sizes. The object occupies about',
    '75% of a square canvas with even padding. Plain solid pure white background',
    '(#FFFFFF), no gradient, no shadow on the ground, no card, no frame, no text.',
  ].join(' ');
}

function delay(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

// Extrae la imagen FINAL de la respuesta. Gemini 3 (thinking) puede devolver
// varias imágenes intermedias marcadas con thought:true -> hay que ignorarlas
// y quedarse con la última imagen no-thought.
function extractFinalImage(json) {
  const parts = json?.candidates?.[0]?.content?.parts;
  if (!Array.isArray(parts)) return null;
  let last = null;
  for (const part of parts) {
    const inline = part.inlineData || part.inline_data;
    if (inline?.data && !part.thought) {
      last = inline.data;
    }
  }
  return last;
}

async function generateOne(key, noun) {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;
  const body = {
    contents: [{ parts: [{ text: buildPrompt(noun) }] }],
    generationConfig: {
      responseModalities: ['IMAGE'],
      imageConfig: { aspectRatio: '1:1' },
    },
  };

  const resp = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': API_KEY,
    },
    body: JSON.stringify(body),
  });

  if (!resp.ok) {
    const detail = await resp.text();
    throw new Error(`HTTP ${resp.status}: ${detail.slice(0, 300)}`);
  }

  const json = await resp.json();
  const b64 = extractFinalImage(json);
  if (!b64) {
    throw new Error('respuesta sin imagen (¿bloqueo de safety o modelo equivocado?)');
  }
  const outPath = path.join(RAW_DIR, `${key}.png`);
  fs.writeFileSync(outPath, Buffer.from(b64, 'base64'));
  return outPath;
}

async function main() {
  const requested = process.argv.slice(2);
  const entries = requested.length
    ? catalog.filter(([k]) => requested.includes(k))
    : catalog;

  if (requested.length && entries.length !== requested.length) {
    const found = entries.map(([k]) => k);
    const missing = requested.filter((k) => !found.includes(k));
    console.warn(`Keys no encontradas en el catálogo: ${missing.join(', ')}`);
  }

  console.log(`Modelo: ${MODEL}`);
  console.log(`Generando ${entries.length} icono(s)...\n`);

  let ok = 0;
  let failed = 0;
  for (const [key, noun] of entries) {
    process.stdout.write(`  ${key.padEnd(20)} `);
    try {
      await generateOne(key, noun);
      console.log('OK');
      ok++;
    } catch (e) {
      console.log(`FALLO -> ${e.message}`);
      failed++;
    }
    // pacing suave para no pegarle a rate limits
    await delay(1200);
  }

  console.log(`\nListo. OK: ${ok}  Fallos: ${failed}`);
  console.log(`Raw en: ${RAW_DIR}`);
}

main();
