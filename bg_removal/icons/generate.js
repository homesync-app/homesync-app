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

// Referencias de estilo: las 4 maestras ya aprobadas. Gemini 3 acepta hasta 14
// imágenes de referencia para mantener estilo consistente en todo el set.
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

// Preámbulo de estilo del ICON_BRIEF.md. Es lo que da consistencia entre iconos.
// CLAVE: cada producto conserva su COLOR REAL, suavizado a pastel. La paleta
// cálida de la app es solo el "acabado"/ambiente, NO se repinta el objeto.
// Nota: la API NO genera transparencia -> pedimos fondo BLANCO PLANO y lo
// recortamos después con process.js.
function buildPrompt(noun) {
  return [
    `Flat modern illustration of a single ${noun}, centered, front 3/4 view.`,
    'Soft rounded shapes, no black outlines, gentle soft inner shading.',
    // --- iluminación / brillo (consistente en todo el set) ---
    'Even, flat lighting with ONE small, soft, matte highlight on the top-left.',
    'Avoid glossy plastic-looking shine, no strong specular reflections.',
    // --- color del producto ---
    'IMPORTANT: keep the realistic, true-to-life colors of the object itself',
    '(milk is white/cream, an apple is red, bread is golden brown, leafy greens',
    'are green, etc.). Render colors as SOFT pastel tones: gentle and slightly',
    'desaturated so the set feels cohesive, but still warm, lively and appetizing,',
    'NOT washed-out, grey or dull. Keep enough color so each product is instantly',
    'recognizable. DO NOT recolor the object orange or terracotta. Never change a',
    'food to an unnatural color.',
    // --- ambiente / app ---
    'Cozy, friendly, homey mood matching a warm cream interface.',
    'Warm terracotta/peach (#EE652B, #E88D67) may appear ONLY as a tiny, subtle',
    'accent on neutral parts (a cap, a small label, a lid), never as the main',
    'body color of natural produce, and never as a large shape.',
    // --- CONTRASTE (clave: el icono se muestra sobre una tarjeta CREMA #FFF0EA) ---
    'CRITICAL: the icon will be placed on a warm cream/peach background, so it',
    'MUST stand out clearly against light cream. Give the object good contrast and',
    'a well-defined silhouette using a subtle slightly-darker tonal edge of its',
    'OWN color (a soft self-outline, NOT a black outline) so the shape never',
    'dissolves into the cream.',
    'For pale, white, cream or translucent products (milk, yogurt, bleach, oil,',
    'shampoo, water, vinegar, salt, sugar, cream cheese): never render them as',
    'near-white. Add a clearly SATURATED colored cap, lid or label and a soft',
    'medium-grey/blue defining edge, and tint the body slightly away from pure',
    'white, so they read clearly on a cream background.',
    'For tubs, cups or transparent containers (ice cream, cream cheese, hummus):',
    'do NOT leave the body clear or white; give the container a solid soft color',
    'or show the colored contents filling it, plus a saturated lid.',
    'Aim for a contrast level similar to a red apple or golden bread, never',
    'washed-out or pale.',
    // --- legibilidad ---
    'Very minimal detail: no small text, no busy labels, no tiny logos; any label',
    'must be a simple plain shape, because the icon will be shown as small as 24px',
    'and must stay clearly readable.',
    // --- SIN TEXTO (absoluto) ---
    'ABSOLUTELY NO text, NO letters, NO words, NO numbers anywhere in the image,',
    'not even on labels or packaging. Labels are blank colored shapes only.',
    // --- comida apetecible ---
    'Any food must look fresh and appetizing, with warm, natural, cooked-looking',
    'tones; never raw, fleshy, grey or unappetizing.',
    'Exactly one object, centered, occupying about',
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

async function generateOne(key, noun, styleRefs) {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

  // No pasar como referencia el mismo producto que estamos generando.
  const refs = styleRefs.filter((_, i) => REF_KEYS[i] !== key);
  const parts = [];
  if (refs.length) {
    parts.push({
      text:
        'Here are reference icons that define the EXACT visual style ' +
        '(shape language, soft pastel palette, lighting, contrast, framing) ' +
        'you must match for consistency:',
    });
    parts.push(...refs);
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
  const args = process.argv.slice(2);
  const skipExisting = args.includes('--skip-existing');
  const requested = args.filter((a) => !a.startsWith('--'));
  const entries = requested.length
    ? catalog.filter(([k]) => requested.includes(k))
    : catalog;

  if (requested.length && entries.length !== requested.length) {
    const found = entries.map(([k]) => k);
    const missing = requested.filter((k) => !found.includes(k));
    console.warn(`Keys no encontradas en el catálogo: ${missing.join(', ')}`);
  }

  console.log(`Modelo: ${MODEL}`);
  const styleRefs = loadStyleRefs();
  console.log(`Referencias de estilo: ${styleRefs.length}`);
  console.log(`Generando ${entries.length} icono(s)...\n`);

  let ok = 0;
  let failed = 0;
  for (const [key, noun] of entries) {
    process.stdout.write(`  ${key.padEnd(20)} `);
    if (skipExisting && fs.existsSync(path.join(RAW_DIR, `${key}.png`))) {
      console.log('SKIP (ya existe)');
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
    // pacing suave para no pegarle a rate limits
    await delay(1200);
  }

  console.log(`\nListo. OK: ${ok}  Fallos: ${failed}`);
  console.log(`Raw en: ${RAW_DIR}`);
}

main();
