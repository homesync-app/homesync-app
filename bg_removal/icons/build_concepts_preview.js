// Preview completa de los 60 conceptos, agrupados por sección, sobre fondo directo.
const fs = require('fs');
const path = require('path');
const { concepts } = require('./concepts_catalog');

const OUT = path.join(
  __dirname, '..', '..', 'design', 'shopping_icons_preview', 'preview_concepts_full.html',
);

// nombre es para mostrar
const es = {
  gift:'Regalo',coffee_treat:'Café/mate',massage:'Masajes',movie_night:'Noche cine',
  ice_cream_cone:'Helado',love_note:'Nota romántica',chocolate_treat:'Chocolate',
  wine_glass:'Copa de vino',bath:'Baño relax',sunset:'Atardecer',heart_gift:'Mimo',
  dinner_out:'Cena',pizza:'Pizza',gaming:'Gaming',board_game:'Juego mesa',picnic:'Picnic',
  star_reward:'Estrella',phone_off:'Sin pantallas',day_off:'Día libre',
  candle:'Cita velas',sparkles:'Magia',microphone:'Karaoke',art_palette:'Arte',
  popcorn_bucket:'Pochoclos',camera:'Foto',letter:'Carta',hug:'Abrazo',book:'Libro',
  plane:'Viaje',puzzle:'Rompecabezas',cooking:'Cocinar',cheers:'Brindis',music_note:'Música',
  fire_streak:'Racha',bed_rest:'Descanso',stargazing:'Estrellas',hourglass:'Tiempo',
  picture_frame:'Cuadro',ticket:'Entrada',
  trophy:'Trofeo',medal:'Medalla',crown:'Corona',seedling:'Primeros pasos',rocket:'Imparable',
  heart:'Corazón',infinity:'Infinito',dancer:'Baile',gem:'Gema',target:'Meta',lock:'Bloqueado',
  money_bag:'Ahorro',house_goal:'Casa',car:'Auto',ring:'Anillo',sofa:'Sillón',
  baby_bottle:'Bebé',graduation:'Graduación',dog_pet:'Mascota',laptop:'Notebook',piggy_bank:'Alcancía',
};

// secciones según orden del catálogo (rangos por comentario)
const groups = {
  'Premios (Pareja)': ['gift','coffee_treat','massage','movie_night','ice_cream_cone','love_note','chocolate_treat','wine_glass','bath','sunset','heart_gift','dinner_out','pizza','gaming','board_game','picnic','star_reward','phone_off','day_off'],
  'Duelos / desafíos': ['candle','sparkles','microphone','art_palette','popcorn_bucket','camera','letter','hug','book','plane','puzzle','cooking','cheers','music_note','fire_streak','bed_rest','stargazing','hourglass','picture_frame','ticket'],
  'Logros': ['trophy','medal','crown','seedling','rocket','heart','infinity','dancer','gem','target','lock'],
  'Metas de ahorro': ['money_bag','house_goal','car','ring','sofa','baby_bottle','graduation','dog_pet','laptop','piggy_bank'],
};

const have = new Set(fs.readdirSync(path.join(__dirname,'out','icons_concepts')).filter(f=>f.endsWith('.png')).map(f=>f.replace('.png','')));

function section(title, keys) {
  const cards = keys.filter(k=>have.has(k)).map(k =>
    `<div class="tile"><span class="badge"><img src="concepts/${k}.png" loading="lazy"></span><div class="nm">${es[k]||k}</div></div>`
  ).join('\n');
  return `<section><h2>${title} <span class="cnt">${keys.filter(k=>have.has(k)).length}</span></h2><div class="grid">${cards}</div></section>`;
}

const body = Object.entries(groups).map(([t,k])=>section(t,k)).join('\n');
const total = [...have].length;

const html = `<!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Conceptos completos (${total})</title>
<style>
  :root{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;}
  body{margin:0;background:#FFFCF9;color:#4A4443;}
  header{padding:24px 28px 8px;position:sticky;top:0;background:#FFFCF9;border-bottom:1px solid #F0E4D9;z-index:5;}
  header h1{margin:0 0 4px;font-size:20px;} header p{margin:0;color:#8E8480;font-size:14px;}
  .toggle{margin-top:10px;font-size:13px;color:#8E8480;}
  section{padding:8px 28px 20px;}
  h2{font-size:13px;text-transform:uppercase;letter-spacing:.05em;color:#C0562B;margin:18px 0 12px;}
  h2 .cnt{color:#B2AAA6;font-weight:600;}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(116px,1fr));gap:12px;}
  .tile{background:#fff;border:1px solid #F0E4D9;border-radius:20px;padding:14px 6px 10px;display:flex;flex-direction:column;align-items:center;gap:8px;}
  .badge{width:60px;height:60px;display:flex;align-items:center;justify-content:center;}
  .badge img{width:58px;height:58px;object-fit:contain;}
  .nm{font-size:11.5px;font-weight:600;text-align:center;line-height:1.2;}
  body.dark{background:#1B1716;color:#F8FAFC;} body.dark header{background:#1B1716;border-color:#342E2B;}
  body.dark .tile{background:#2F2927;border-color:#342E2B;}
</style></head><body>
<header><h1>Conceptos — set completo (${total})</h1>
<p>Premios, duelos, logros y metas. Colores naturales, sobre fondo directo (sin rectángulo).</p>
<label class="toggle"><input type="checkbox" id="dk"> Modo oscuro</label></header>
${body}
<script>document.getElementById('dk').addEventListener('change',e=>document.body.classList.toggle('dark',e.target.checked));</script>
</body></html>`;

fs.writeFileSync(OUT, html);
console.log(`Preview: ${OUT} (${total} iconos)`);
