// Genera idle loops de los avatares premium con Veo (Gemini API).
//
// Uso:
//   node generate.mjs                       -> todos los avatares, 2 takes c/u
//   node generate.mjs --avatar premium_orange_cat
//   node generate.mjs --takes 3 --model veo-3.1-fast-generate-preview
//   node generate.mjs --dry-run             -> solo prepara las imagenes de entrada
//
// Requiere: GEMINI_API_KEY en el entorno, ffmpeg en PATH.
// Los takes ya descargados se saltean (re-ejecutable sin costo duplicado).

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  AVATARS,
  EVENT_MOTIONS,
  KEY_COLORS,
  NEGATIVE_PROMPT,
  buildPrompt,
} from './avatars.config.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '..', '..');
const SRC_DIR = join(REPO_ROOT, 'flutter_client', 'assets', 'images', 'premium_3d_avatars');
const WORK_DIR = join(__dirname, 'work');
const INPUT_DIR = join(WORK_DIR, 'inputs');
const RAW_DIR = join(WORK_DIR, 'raw');

const API_BASE = 'https://generativelanguage.googleapis.com/v1beta';
const DEFAULT_MODEL = 'veo-3.1-fast-generate-preview';
const DURATION_SECONDS = 4;
const POLL_INTERVAL_MS = 10_000;
const POLL_TIMEOUT_MS = 10 * 60_000;

const args = process.argv.slice(2);
const getArg = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const MODEL = getArg('model', DEFAULT_MODEL);
const TAKES = Number(getArg('takes', '2'));
const ONLY_AVATAR = getArg('avatar', null);
// 'idle' (default) o un movimiento de evento de EVENT_MOTIONS (ej. victory).
const MOTION = getArg('motion', 'idle');
const DRY_RUN = args.includes('--dry-run');

const API_KEY = process.env.GEMINI_API_KEY;
if (!API_KEY && !DRY_RUN) {
  console.error('ERROR: falta GEMINI_API_KEY en el entorno.');
  process.exit(1);
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Compone el PNG (con alfa) sobre un lienzo 1280x720 del color de chroma,
// con el personaje centrado ocupando ~85% de la altura.
function prepareInput(avatar) {
  const src = join(SRC_DIR, `${avatar.id}.png`);
  if (!existsSync(src)) throw new Error(`No existe el asset: ${src}`);
  const out = join(INPUT_DIR, `${avatar.id}_input.png`);
  if (existsSync(out)) return out;

  const key = KEY_COLORS[avatar.keyColor];
  execFileSync('ffmpeg', [
    '-y', '-hide_banner', '-loglevel', 'error',
    '-f', 'lavfi', '-i', `color=c=${key.ffmpeg}:s=1280x720`,
    '-i', src,
    '-filter_complex',
    '[1]scale=-1:612[fg];[0][fg]overlay=(W-w)/2:(H-h)/2:format=auto',
    '-frames:v', '1',
    out,
  ]);
  return out;
}

async function startGeneration(avatar, inputPng) {
  const event = MOTION === 'idle' ? null : EVENT_MOTIONS[avatar.id]?.[MOTION];
  const body = {
    instances: [
      {
        prompt: buildPrompt(avatar, {
          motionText: event?.prompt,
          oneshot: event?.loop === 'oneshot',
        }),
        image: {
          mimeType: 'image/png',
          bytesBase64Encoded: readFileSync(inputPng).toString('base64'),
        },
      },
    ],
    parameters: {
      aspectRatio: '16:9',
      resolution: '720p',
      durationSeconds: DURATION_SECONDS,
      negativePrompt: NEGATIVE_PROMPT,
    },
  };

  const res = await fetch(`${API_BASE}/models/${MODEL}:predictLongRunning`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-goog-api-key': API_KEY },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    throw new Error(`predictLongRunning ${res.status}: ${await res.text()}`);
  }
  const { name } = await res.json();
  return name;
}

async function pollOperation(operationName) {
  const deadline = Date.now() + POLL_TIMEOUT_MS;
  while (Date.now() < deadline) {
    await sleep(POLL_INTERVAL_MS);
    const res = await fetch(`${API_BASE}/${operationName}`, {
      headers: { 'x-goog-api-key': API_KEY },
    });
    if (!res.ok) throw new Error(`poll ${res.status}: ${await res.text()}`);
    const op = await res.json();
    if (op.error) throw new Error(`operation error: ${JSON.stringify(op.error)}`);
    if (op.done) {
      const uri =
        op.response?.generateVideoResponse?.generatedSamples?.[0]?.video?.uri;
      if (!uri) throw new Error(`done sin video uri: ${JSON.stringify(op.response)}`);
      return uri;
    }
    process.stdout.write('.');
  }
  throw new Error('timeout esperando la operacion');
}

async function downloadVideo(uri, outPath) {
  const res = await fetch(uri, { headers: { 'x-goog-api-key': API_KEY }, redirect: 'follow' });
  if (!res.ok) throw new Error(`download ${res.status}`);
  writeFileSync(outPath, Buffer.from(await res.arrayBuffer()));
}

async function main() {
  mkdirSync(INPUT_DIR, { recursive: true });
  mkdirSync(RAW_DIR, { recursive: true });

  const avatars = AVATARS.filter((a) => !ONLY_AVATAR || a.id === ONLY_AVATAR);
  if (avatars.length === 0) {
    console.error(`Avatar desconocido: ${ONLY_AVATAR}`);
    process.exit(1);
  }
  if (MOTION !== 'idle') {
    const missing = avatars.filter((a) => !EVENT_MOTIONS[a.id]?.[MOTION]);
    if (missing.length) {
      console.error(
        `Sin prompt '${MOTION}' para: ${missing.map((a) => a.id).join(', ')}`,
      );
      process.exit(1);
    }
  }
  const suffix = MOTION === 'idle' ? '' : `_${MOTION}`;

  const failures = [];
  for (const avatar of avatars) {
    const inputPng = prepareInput(avatar);
    console.log(`\n[${avatar.id}] input listo (${avatar.keyColor}, ${MOTION})`);
    if (DRY_RUN) continue;

    for (let take = 1; take <= TAKES; take++) {
      const outPath = join(RAW_DIR, `${avatar.id}${suffix}_take${take}.mp4`);
      if (existsSync(outPath)) {
        console.log(`  take ${take}: ya existe, salteado`);
        continue;
      }
      try {
        console.log(`  take ${take}: generando con ${MODEL}...`);
        const op = await startGeneration(avatar, inputPng);
        const uri = await pollOperation(op);
        await downloadVideo(uri, outPath);
        console.log(`\n  take ${take}: OK -> ${outPath}`);
      } catch (err) {
        console.error(`\n  take ${take}: FALLO -> ${err.message}`);
        failures.push(`${avatar.id} take${take}`);
      }
    }
  }

  if (failures.length) {
    console.error(`\nFallaron: ${failures.join(', ')} (re-ejecutar para reintentar)`);
    process.exit(2);
  }
  console.log('\nGeneracion completa.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
