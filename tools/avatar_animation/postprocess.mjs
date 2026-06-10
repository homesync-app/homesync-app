// Post-produccion: MP4 crudo de Veo -> WebP animado transparente listo para Flutter.
//
// Pipeline por take:
//   1. Recorte cuadrado centrado (720x720 del 1280x720)
//   2. chromakey (verde o magenta segun avatar) + despill -> alfa real
//   3. Loop perfecto ping-pong (ida y vuelta, sin salto)
//   4. WebP animado 480x480 @ 12fps, loop infinito
//
// Uso:
//   node postprocess.mjs                 -> procesa todos los takes en work/raw
//   node postprocess.mjs --avatar premium_orange_cat
//   node postprocess.mjs --quality 70 --size 480 --fps 12
//
// Salida: work/out/{id}_take{n}.webp + work/out/preview.html para comparar takes.

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { AVATARS, EVENT_MOTIONS, KEY_COLORS } from './avatars.config.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const RAW_DIR = join(__dirname, 'work', 'raw');
const OUT_DIR = join(__dirname, 'work', 'out');

const args = process.argv.slice(2);
const getArg = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const ONLY_AVATAR = getArg('avatar', null);
const QUALITY = getArg('quality', '70');
const SIZE = getArg('size', '480');
const FPS = getArg('fps', '12');
// Tolerancias del chroma: subir similarity si queda halo del fondo,
// bajarla si se come partes del personaje.
const SIMILARITY = getArg('similarity', '0.20');
const BLEND = getArg('blend', '0.06');

function processTake(file) {
  const match = file.match(/^(.+?)(?:_(victory|versus|celebrate))?_take(\d+)\.mp4$/);
  if (!match) return null;
  const [, avatarId, motion = 'idle', take] = match;
  if (ONLY_AVATAR && avatarId !== ONLY_AVATAR) return null;

  const avatar = AVATARS.find((a) => a.id === avatarId);
  if (!avatar) {
    console.warn(`Sin config para ${avatarId}, salteado`);
    return null;
  }
  const eventCfg =
    motion === 'idle' ? null : EVENT_MOTIONS[avatarId]?.[motion];
  const oneshot = eventCfg?.loop === 'oneshot';
  const trimSeconds = eventCfg?.trimSeconds;
  const key = KEY_COLORS[avatar.keyColor];
  const input = join(RAW_DIR, file);
  const suffix = motion === 'idle' ? '' : `_${motion}`;
  const output = join(OUT_DIR, `${avatarId}${suffix}_take${take}.webp`);

  // Ping-pong: [v] -> forward + reverse concatenados = loop sin costura.
  // Los oneshot (eventos) van solo de ida: el prompt pide terminar en la
  // pose inicial, asi el player puede volver al idle sin salto.
  // despill de ffmpeg solo soporta green/blue; con magenta el borde blanco
  // tipo sticker de los avatares evita el spill, asi que se omite.
  const filter = [
    // Normaliza la matriz de color de entrada para evitar corrimientos 601/709.
    `scale=in_color_matrix=auto:out_color_matrix=bt601,setparams=colorspace=bt470bg`,
    ...(trimSeconds ? [`trim=duration=${trimSeconds}`, `setpts=PTS-STARTPTS`] : []),
    `crop=ih:ih`,
    `chromakey=${key.ffmpeg}:${SIMILARITY}:${BLEND}`,
    ...(avatar.keyColor === 'green' ? ['despill=type=green'] : []),
    `fps=${FPS}`,
    `format=rgba`,
    `scale=${SIZE}:${SIZE}:flags=lanczos`,
    ...(oneshot
      ? []
      : ['split[fwd][tmp];[tmp]reverse[rev];[fwd][rev]concat=n=2:v=1:a=0']),
  ].join(',');

  execFileSync('ffmpeg', [
    '-y', '-hide_banner', '-loglevel', 'error',
    '-i', input,
    '-filter_complex', filter,
    '-c:v', 'libwebp_anim',
    '-lossless', '0',
    '-q:v', QUALITY,
    '-loop', '0',
    '-an',
    output,
  ]);

  const kb = Math.round(statSync(output).size / 1024);
  console.log(`${avatarId} ${motion} take${take}: ${kb} KB -> ${output}`);
  return {
    avatarId: `${avatarId}${suffix}`,
    take,
    file: `${avatarId}${suffix}_take${take}.webp`,
    kb,
  };
}

function writePreview(results) {
  const byAvatar = {};
  for (const r of results) (byAvatar[r.avatarId] ??= []).push(r);

  const rows = Object.entries(byAvatar)
    .map(
      ([id, takes]) => `
    <section>
      <h2>${id}</h2>
      <div class="takes">
        ${takes
          .map(
            (t) => `
        <figure>
          <img src="${t.file}" width="240" height="240" alt="${t.file}">
          <figcaption>take ${t.take} &middot; ${t.kb} KB</figcaption>
        </figure>`,
          )
          .join('')}
      </div>
    </section>`,
    )
    .join('\n');

  const html = `<!doctype html>
<meta charset="utf-8">
<title>Avatar takes preview</title>
<style>
  body { font-family: system-ui; background: repeating-conic-gradient(#f0f0f0 0% 25%, #fff 0% 50%) 50% / 24px 24px; padding: 24px; }
  section { background: rgba(255,255,255,.85); border-radius: 16px; padding: 16px 24px; margin-bottom: 24px; }
  .takes { display: flex; gap: 24px; flex-wrap: wrap; }
  figure { margin: 0; text-align: center; }
</style>
${rows}`;
  writeFileSync(join(OUT_DIR, 'preview.html'), html);
  console.log(`\nPreview: ${join(OUT_DIR, 'preview.html')}`);
}

mkdirSync(OUT_DIR, { recursive: true });
if (!existsSync(RAW_DIR)) {
  console.error('No hay takes crudos en work/raw. Corre primero generate.mjs');
  process.exit(1);
}

const results = readdirSync(RAW_DIR)
  .filter((f) => f.endsWith('.mp4'))
  .map(processTake)
  .filter(Boolean);

if (results.length === 0) {
  console.error('Nada para procesar.');
  process.exit(1);
}
writePreview(results);
