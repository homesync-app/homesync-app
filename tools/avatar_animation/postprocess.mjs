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

import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { AVATARS, EVENT_MOTIONS, KEY_COLORS } from './avatars.config.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const RAW_DIR = join(__dirname, 'work', 'raw');
const OUT_DIR = join(__dirname, 'work', 'out');
const STATIC_DIR = join(
  __dirname, '..', '..', 'flutter_client', 'assets', 'images', 'premium_3d_avatars',
);

// Corrige el bug de "el avatar se agranda/achica al asentar": cada take de
// Veo puede encuadrar al personaje con una escala levemente distinta dentro
// del cuadro (aunque el fondo sea plano y la camara este "fija"), y eso se
// nota al hacer crossfade con el PNG/WebP estatico del sticker en Flutter.
// Medimos la fraccion vertical que ocupa el personaje (bbox de canal alfa)
// en el primer frame del take y en el sticker estatico, y reescalamos el
// take para que coincida antes del resize final a SIZE x SIZE.
function detectAlphaBBoxHeightFraction(inputPath, preFilter, canvasHeight) {
  const result = spawnSync('ffmpeg', [
    '-hide_banner', '-loglevel', 'info',
    '-i', inputPath,
    '-vf', `${preFilter},alphaextract,cropdetect=limit=24:round=2:reset=1:skip=0`,
    '-frames:v', '1',
    '-f', 'null', '-',
  ], { encoding: 'utf8' });
  const stderr = result.stderr ?? '';
  const matches = [...stderr.matchAll(/crop=(\d+):(\d+):(\d+):(\d+)/g)];
  if (matches.length === 0) return null;
  const [, , h] = matches[matches.length - 1];
  return Number(h) / canvasHeight;
}

function staticBBoxHeightFraction(avatarId) {
  const staticPath = join(STATIC_DIR, `${avatarId}.webp`);
  if (!existsSync(staticPath)) return null;
  const dims = execFileSync('ffprobe', [
    '-v', 'error', '-select_streams', 'v:0',
    '-show_entries', 'stream=height', '-of', 'csv=p=0', staticPath,
  ]).toString().trim();
  const canvasHeight = Number(dims);
  if (!canvasHeight) return null;
  return detectAlphaBBoxHeightFraction(staticPath, 'format=rgba', canvasHeight);
}

const args = process.argv.slice(2);
const getArg = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const ONLY_AVATAR = getArg('avatar', null);
const ONLY_MOTION = getArg('motion', null);
const QUALITY = getArg('quality', '70');
const SIZE = getArg('size', '480');
const FPS = getArg('fps', '12');
// Tolerancias del chroma: subir similarity si queda halo del fondo,
// bajarla si se come partes del personaje.
const SIMILARITY = getArg('similarity', '0.20');
const BLEND = getArg('blend', '0.06');
// Override del color de chroma (ej. --key 0x54E637 si el fondo derivo del
// color pedido; samplear con ffmpeg crop=40:40:10:10,scale=1:1 -> od).
const KEY_OVERRIDE = getArg('key', null);

function processTake(file) {
  const match = file.match(
    /^(.+?)(?:_(victory|versus|celebrate|tada))?_take(\d+)\.mp4$/,
  );
  if (!match) return null;
  const [, avatarId, motion = 'idle', take] = match;
  if (ONLY_AVATAR && avatarId !== ONLY_AVATAR) return null;
  if (ONLY_MOTION && motion !== ONLY_MOTION) return null;

  const avatar = AVATARS.find((a) => a.id === avatarId);
  if (!avatar) {
    console.warn(`Sin config para ${avatarId}, salteado`);
    return null;
  }
  const eventCfg =
    motion === 'idle' ? null : EVENT_MOTIONS[avatarId]?.[motion];
  // Modo de loop:
  //  - idle ("llegada") = reverse: Veo genera reposo->agarra-objeto; al
  //    invertirlo, el personaje LLEGA con el objeto y lo DEJA, terminando en
  //    la pose del sticker (primer frame original = la imagen estatica).
  //  - evento oneshot = forward tal cual; pingpong = ida y vuelta.
  const mode = motion === 'idle'
    ? 'reverse'
    : (eventCfg?.loop === 'oneshot' ? 'oneshot' : 'pingpong');
  const trimSeconds = motion === 'idle' ? undefined : eventCfg?.trimSeconds;
  const key = KEY_COLORS[avatar.keyColor];
  const input = join(RAW_DIR, file);
  const suffix = motion === 'idle' ? '' : `_${motion}`;
  const output = join(OUT_DIR, `${avatarId}${suffix}_take${take}.webp`);

  // Cadena hasta el alfa limpio, sin trim/fps/scale final -- se usa solo
  // para medir el bbox del personaje en el frame 0 (independiente del take).
  const alphaChain = [
    `scale=in_color_matrix=auto:out_color_matrix=bt601,setparams=colorspace=bt470bg`,
    `crop=ih:ih`,
    `chromakey=${KEY_OVERRIDE ?? key.ffmpeg}:${SIMILARITY}:${BLEND}`,
    ...(avatar.keyColor === 'green' && avatar.despill !== false ? ['despill=type=green'] : []),
    `format=rgba`,
  ].join(',');
  const croppedSize = Number(
    execFileSync('ffprobe', [
      '-v', 'error', '-select_streams', 'v:0',
      '-show_entries', 'stream=height', '-of', 'csv=p=0', input,
    ]).toString().trim(),
  );
  const takeFrac = detectAlphaBBoxHeightFraction(input, alphaChain, croppedSize);
  const staticFrac = staticBBoxHeightFraction(avatarId);
  let scaleFactor = 1;
  if (takeFrac && staticFrac) {
    // Tope 1.5: los inputs de Kling entran al 72% de alto (aire para saltos)
    // y necesitan ~1.43x para calzar con el sticker.
    scaleFactor = Math.min(1.5, Math.max(0.7, staticFrac / takeFrac));
  }
  if (Math.abs(scaleFactor - 1) > 0.01) {
    console.log(
      `${avatarId} ${motion} take${take}: corrigiendo escala x${scaleFactor.toFixed(3)} (bbox ${(takeFrac * 100).toFixed(1)}% vs sticker ${(staticFrac * 100).toFixed(1)}%)`,
    );
  }
  // Reescala el personaje dentro del cuadro cropeado para que su altura
  // relativa coincida con la del sticker estatico, antes del resize final
  // -- corrige el salto de tamano al asentar (crossfade al PNG/WebP fijo).
  const normalize = Math.abs(scaleFactor - 1) > 0.01
    ? `scale=trunc(iw*${scaleFactor}/2)*2:trunc(ih*${scaleFactor}/2)*2,` +
      `pad=w='max(iw\\,${croppedSize})':h='max(ih\\,${croppedSize})':x='(ow-iw)/2':y='(oh-ih)/2':color=0x00000000@0,` +
      `crop=${croppedSize}:${croppedSize}:(iw-${croppedSize})/2:(ih-${croppedSize})/2,`
    : '';

  // Cadena base hasta el alfa limpio y escalado.
  // despill de ffmpeg solo soporta green/blue; con magenta el borde blanco
  // tipo sticker de los avatares evita el spill, asi que se omite.
  const pre = [
    // Normaliza la matriz de color de entrada para evitar corrimientos 601/709.
    `scale=in_color_matrix=auto:out_color_matrix=bt601,setparams=colorspace=bt470bg`,
    ...(trimSeconds ? [`trim=duration=${trimSeconds}`, `setpts=PTS-STARTPTS`] : []),
    `crop=ih:ih`,
    `chromakey=${KEY_OVERRIDE ?? key.ffmpeg}:${SIMILARITY}:${BLEND}`,
    // Segunda pasada por MATIZ (hue 300 = magenta): limpia lavados rosa
    // acuarela que Kling a veces pinta en el fondo (el chromakey exacto no
    // los alcanza) y de paso las motas magenta sueltas. similarity 0.30 es
    // el limite: 0.35 ya desatura el arte (bandana/corazon). Verificado que
    // nariz/cachetes rosados (hue ~350) sobreviven.
    ...(avatar.keyColor === 'magenta'
      ? [`hsvkey=hue=300:sat=0.35:val=0.7:similarity=0.30:blend=0.1`]
      : []),
    ...(avatar.keyColor === 'green' && avatar.despill !== false ? ['despill=type=green'] : []),
    `fps=${FPS}`,
    `format=rgba`,
    // Clampa alfas debiles a 0: los restos casi-invisibles del keying varian
    // frame a frame y inflan el WebP ~40% sin aporte visual.
    `geq=a='if(lt(alpha(X,Y),48),0,alpha(X,Y))':r='r(X,Y)':g='g(X,Y)':b='b(X,Y)'`,
    normalize.replace(/,$/, ''),
    `scale=${SIZE}:${SIZE}:flags=lanczos`,
  ].filter(Boolean).join(',');

  // tail segun modo:
  //  - oneshot: nada (forward tal cual)
  //  - reverse: invierte el clip completo (llegada)
  //  - pingpong: ida + vuelta sin costura
  const tail = mode === 'oneshot'
    ? null
    : mode === 'reverse'
        ? 'reverse'
        : 'split[fwd][tmp];[tmp]reverse[rev];[fwd][rev]concat=n=2:v=1:a=0';

  // Erosion opcional del alfa para comer un borde sticker blanco (ver config).
  const erode = avatar.erodeBorder || 0;
  let filter;
  if (erode > 0) {
    const chain = Array(erode).fill('erosion').join(',');
    filter =
      `${pre}[pp];[pp]split[b][acp];[acp]alphaextract,${chain}[ae];` +
      `[b][ae]alphamerge` +
      (tail ? `,${tail}` : '');
  } else {
    filter = pre + (tail ? `,${tail}` : '');
  }

  // NOTA: no fundir el final del clip hacia el sticker (xfade) ni forzar que
  // termine en la pose exacta del arte: xfade con alfa funde a traves de
  // negro (efecto oscuro feo) y el owner NO quiere ese "asentado" — el video
  // termina en la pose que termine y ahi queda (2026-07-06).

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
