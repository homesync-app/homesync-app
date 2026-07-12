// Genera motions de los avatares premium con Kling (API oficial de KlingAI).
// Mismo pipeline que generate.mjs (Veo): imagen del avatar sobre lienzo
// magenta 1280x720 -> video -> work/raw/*.mp4 (postprocess.mjs no cambia).
//
// Uso:
//   node generate_kling.mjs --avatar premium_orange_cat --motion tada --takes 2
//   node generate_kling.mjs --model kling-v2-6 ...   (si v3 no esta habilitado)
//
// Requiere: KLING_API_KEY en el entorno o en tools/avatar_animation/.env
// Los takes ya descargados se saltean (re-ejecutable sin costo duplicado).

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import {
  AVATARS,
  EVENT_MOTIONS,
  KEY_COLORS,
  NEGATIVE_PROMPT,
  buildPrompt,
} from './avatars.config.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = join(__dirname, '..', '..');
const SRC_DIR = join(REPO_ROOT, 'flutter_client', 'assets', 'images', 'premium_3d_avatars');
const WORK_DIR = join(__dirname, 'work');
const INPUT_DIR = join(WORK_DIR, 'inputs');
const RAW_DIR = join(WORK_DIR, 'raw');

// Endpoint global (fuera de China). El dominio de China es api-beijing.
const API_BASE = 'https://api-singapore.klingai.com';
const POLL_INTERVAL_MS = 10_000;
const POLL_TIMEOUT_MS = 15 * 60_000;

const args = process.argv.slice(2);
const getArg = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const MODEL = getArg('model', 'kling-v3');
// 'pro' rinde mejor calidad/menos contraste que 'std' (cuesta mas unidades).
const MODE = getArg('mode', 'pro');
const TAKES = Number(getArg('takes', '2'));
const ONLY_AVATAR = getArg('avatar', null);
const MOTION = getArg('motion', 'idle');
const DRY_RUN = args.includes('--dry-run');

function loadApiKey() {
  if (process.env.KLING_API_KEY) return process.env.KLING_API_KEY;
  const envFile = join(__dirname, '.env');
  if (existsSync(envFile)) {
    const match = readFileSync(envFile, 'utf8').match(/^KLING_API_KEY=(.+)$/m);
    if (match) return match[1].trim();
  }
  return null;
}
const API_KEY = loadApiKey();
if (!API_KEY && !DRY_RUN) {
  console.error('ERROR: falta KLING_API_KEY (entorno o tools/avatar_animation/.env).');
  process.exit(1);
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Compone el avatar centrado sobre un lienzo 1280x720 del color de chroma.
// A diferencia de Veo (85% de alto), aca ocupa ~78%: deja aire arriba para
// saltos/gestos (con 85% las orejas se cortaban contra el borde del cuadro)
// sin regalar nitidez (a 72% el upscale de normalizacion 1.43x se notaba
// borroso vs Veo; a 78% queda ~1.25x). postprocess normaliza contra el sticker.
function prepareInput(avatar) {
  const src = [`${avatar.id}.webp`, `${avatar.id}.png`]
    .map((name) => join(SRC_DIR, name))
    .find((p) => existsSync(p));
  if (!src) throw new Error(`No existe el asset: ${join(SRC_DIR, avatar.id)}.{webp,png}`);
  const out = join(INPUT_DIR, `${avatar.id}_input_kling.png`);
  if (existsSync(out)) return out;

  const key = KEY_COLORS[avatar.keyColor];
  execFileSync('ffmpeg', [
    '-y', '-hide_banner', '-loglevel', 'error',
    '-f', 'lavfi', '-i', `color=c=${key.ffmpeg}:s=1280x720`,
    '-i', src,
    '-filter_complex',
    '[1]scale=-1:560[fg];[0][fg]overlay=(W-w)/2:(H-h)/2:format=auto',
    '-frames:v', '1',
    out,
  ]);
  return out;
}

// Clausula de estilo NEUTRA: pedir "bajo contraste/pastel" lavaba los colores
// (quedaba palido vs el arte original); pedir nada los contrastaba de mas.
// La referencia es SIEMPRE el input tal cual.
const SOFT_STYLE_CLAUSE =
  'Preserve exactly the warm watercolor storybook style, colors, saturation, ' +
  'contrast and soft lighting of the input image throughout the entire video, ' +
  'as if every frame were painted by the same artist as the input image.';

async function api(path, { method = 'GET', body } = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${API_KEY}`,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    throw new Error(`${method} ${path} ${res.status}: ${text.slice(0, 400)}`);
  }
  if (!res.ok || json.code !== 0) {
    throw new Error(
      `${method} ${path} ${res.status} code=${json.code}: ${json.message ?? text.slice(0, 400)}`,
    );
  }
  return json.data;
}

async function startGeneration(avatar, inputPng) {
  const isIdle = MOTION === 'idle';
  const event = isIdle ? null : EVENT_MOTIONS[avatar.id]?.[MOTION];
  const prompt = `${buildPrompt(avatar, {
    motionText: event?.prompt,
    oneshot: isIdle ? true : event?.loop === 'oneshot',
  })} ${SOFT_STYLE_CLAUSE}`;
  const data = await api('/v1/videos/image2video', {
    method: 'POST',
    body: {
      model_name: MODEL,
      mode: MODE,
      duration: '5',
      image: readFileSync(inputPng).toString('base64'),
      prompt,
      negative_prompt: NEGATIVE_PROMPT,
      cfg_scale: 0.5,
    },
  });
  return data.task_id;
}

async function pollTask(taskId) {
  const deadline = Date.now() + POLL_TIMEOUT_MS;
  while (Date.now() < deadline) {
    await sleep(POLL_INTERVAL_MS);
    const data = await api(`/v1/videos/image2video/${taskId}`);
    if (data.task_status === 'succeed') {
      const url = data.task_result?.videos?.[0]?.url;
      if (!url) throw new Error(`succeed sin video url: ${JSON.stringify(data)}`);
      return url;
    }
    if (data.task_status === 'failed') {
      throw new Error(`task failed: ${data.task_status_msg ?? 'sin detalle'}`);
    }
    process.stdout.write('.');
  }
  throw new Error('timeout esperando la tarea');
}

async function downloadVideo(url, outPath) {
  const res = await fetch(url);
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
      console.error(`Sin prompt '${MOTION}' para: ${missing.map((a) => a.id).join(', ')}`);
      process.exit(1);
    }
  }
  const suffix = MOTION === 'idle' ? '' : `_${MOTION}`;

  const failures = [];
  for (const avatar of avatars) {
    const inputPng = prepareInput(avatar);
    console.log(`\n[${avatar.id}] input listo (${avatar.keyColor}, ${MOTION}, ${MODEL}/${MODE})`);
    if (DRY_RUN) continue;

    for (let take = 1; take <= TAKES; take++) {
      const outPath = join(RAW_DIR, `${avatar.id}${suffix}_take${take}.mp4`);
      if (existsSync(outPath)) {
        console.log(`  take ${take}: ya existe, salteado`);
        continue;
      }
      try {
        console.log(`  take ${take}: generando...`);
        const taskId = await startGeneration(avatar, inputPng);
        const url = await pollTask(taskId);
        await downloadVideo(url, outPath);
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
