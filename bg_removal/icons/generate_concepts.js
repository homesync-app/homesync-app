// Genera iconos de CONCEPTOS (premios, logros, duelos, metas) con Gemini.
// Mismo estilo y referencias que los productos, pero prompt adaptado a
// símbolos/escenas (no "producto sobre fondo blanco").
//
// Uso (correr desde bg_removal/):
//   node icons/generate_concepts.js                 -> todo el catálogo
//   node icons/generate_concepts.js --pilot         -> solo los pilot:true
//   node icons/generate_concepts.js gift trophy      -> esas claves
//   node icons/generate_concepts.js --skip-existing  -> reanudar
//
// Salida: out/raw_concepts/{clave}.png

const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const { concepts } = require('./concepts_catalog');

const API_KEY = process.env.GEMINI_API_KEY;
const MODEL = (process.env.GEMINI_IMAGE_MODEL || 'gemini-3.1-flash-image').trim();

if (!API_KEY) {
  console.error('Falta GEMINI_API_KEY en bg_removal/icons/.env');
  process.exit(1);
}

const RAW_DIR = path.join(__dirname, 'out', 'raw_concepts');
fs.mkdirSync(RAW_DIR, { recursive: true });

// Mismas 4 referencias maestras de estilo (productos) -> amarran el lenguaje.
const REF_KEYS = ['bread', 'milk', 'carrot', 'apple'];
const ICONS_DIR = path.join(__dirname, 'out', 'icons');

function loadStyleRefs() {
  const refs = [];
  for (const k of REF_KEYS) {
    const p = path.join(ICONS_DIR, `${k}.png`);
    if (fs.existsSync(p)) {
      refs.push({
        inlineData: {
          mimeType: 'image/png',
          data: fs.readFileSync(p).toString('base64'),
        },
      });
    }
  }
  return refs;
}

// Prompt para conceptos: símbolo/objeto único, mismo lenguaje visual que los
// productos (flat, pastel cálido, contraste sobre crema, sin texto).
function buildPrompt(noun) {
  return [
    `Flat modern illustration of a single ${noun}, centered, front view,`,
    'as a friendly app icon / sticker.',
    'Soft rounded shapes, no black outlines, gentle soft inner shading, one small',
    'soft matte highlight on the top-left, no glossy plastic shine.',
    // paleta
    'Use the object\'s OWN natural colors in a soft pastel version (gold/yellow',
    'for a trophy or medal, red for a heart, green for plants, blue for water,',
    'brown for wood, etc.), the same way fresh produce keeps its real colors.',
    'Keep colors soft and lively, gently desaturated but NOT washed-out, grey or',
    'neon. Terracotta/peach (#EE652B, #E88D67) may appear ONLY as a small subtle',
    'accent or warm ambiance, NEVER as the dominant color and NEVER repainting an',
    'object that has its own natural color. Do not make everything orange.',
    // contraste
    'CRITICAL: the icon sits on a warm cream/peach background (#FFF0EA), so it',
    'MUST have good contrast and a clearly defined silhouette using a subtle',
    'slightly-darker tonal edge of its own color (a soft self-outline, never a',
    'black outline). Pale or white elements must be tinted and given a colored',
    'accent so they never dissolve into the cream.',
    // legibilidad / sin texto
    'Very minimal detail so it reads clearly as small as 24px.',
    'ABSOLUTELY NO text, NO letters, NO words, NO numbers anywhere in the image.',
    // encuadre
    'Exactly one subject, centered, occupying about 72% of a square canvas with',
    'even padding. Plain solid pure white background (#FFFFFF), no gradient, no',
    'ground shadow, no card, no frame, no text.',
  ].join(' ');
}

function delay(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function extractFinalImage(json) {
  const parts = json?.candidates?.[0]?.content?.parts;
  if (!Array.isArray(parts)) return null;
  let last = null;
  for (const part of parts) {
    const inline = part.inlineData || part.inline_data;
    if (inline?.data && !part.thought) last = inline.data;
  }
  return last;
}

async function generateOne(key, noun, styleRefs) {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;
  const parts = [];
  if (styleRefs.length) {
    parts.push({
      text:
        'Here are reference icons that define the EXACT visual style ' +
        '(shape language, soft pastel palette, lighting, contrast, framing) ' +
        'you must match for consistency:',
    });
    parts.push(...styleRefs);
  }
  parts.push({ text: buildPrompt(noun) });

  const body = {
    contents: [{ parts }],
    generationConfig: {
      responseModalities: ['IMAGE'],
      imageConfig: { aspectRatio: '1:1' },
    },
  };

  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-goog-api-key': API_KEY },
    body: JSON.stringify(body),
  });
  if (!resp.ok) {
    const detail = await resp.text();
    throw new Error(`HTTP ${resp.status}: ${detail.slice(0, 300)}`);
  }
  const json = await resp.json();
  const b64 = extractFinalImage(json);
  if (!b64) throw new Error('respuesta sin imagen');
  const outPath = path.join(RAW_DIR, `${key}.png`);
  fs.writeFileSync(outPath, Buffer.from(b64, 'base64'));
  return outPath;
}

async function main() {
  const args = process.argv.slice(2);
  const skipExisting = args.includes('--skip-existing');
  const pilotOnly = args.includes('--pilot');
  const requested = args.filter((a) => !a.startsWith('--'));

  let entries = concepts;
  if (requested.length) {
    entries = concepts.filter(([k]) => requested.includes(k));
  } else if (pilotOnly) {
    entries = concepts.filter((c) => c[3] === true);
  }

  console.log(`Modelo: ${MODEL}`);
  const styleRefs = loadStyleRefs();
  console.log(`Referencias de estilo: ${styleRefs.length}`);
  console.log(`Generando ${entries.length} concepto(s)...\n`);

  let ok = 0;
  let failed = 0;
  for (const [key, , noun] of entries) {
    process.stdout.write(`  ${key.padEnd(18)} `);
    if (skipExisting && fs.existsSync(path.join(RAW_DIR, `${key}.png`))) {
      console.log('SKIP');
      ok++;
      continue;
    }
    try {
      await generateOne(key, noun, styleRefs);
      console.log('OK');
      ok++;
    } catch (e) {
      console.log(`FALLO -> ${e.message}`);
      failed++;
    }
    await delay(1200);
  }
  console.log(`\nListo. OK: ${ok}  Fallos: ${failed}`);
  console.log(`Raw en: ${RAW_DIR}`);
}

main();
