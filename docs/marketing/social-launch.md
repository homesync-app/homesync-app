# Lanzamiento en Instagram y TikTok

Kit generado con `python tmp/marketing/build_social.py` → `tmp/marketing/social/`
(gitignoreado). Las fuentes son las capturas de los hogares demo; para
regenerar con datos frescos, resembrar (`docs/marketing/content-plan.md`) y
volver a capturar.

| Carpeta | Qué hay | Formato |
| --- | --- | --- |
| `profile/` | Foto de perfil y 6 portadas de destacadas | 1080×1080 / 1080×1920 |
| `carousels/01_lanzamiento` | Presentación general (5 placas) | 1080×1350 |
| `carousels/02_familia_misiones` | Misiones, aprobación, premios y ranking (6) | 1080×1350 |
| `carousels/03_pareja_semana` | La semana de la pareja, propuestas, plata (5) | 1080×1350 |
| `carousels/04_mesada` | Mesada y Modo Padres (4) | 1080×1350 |
| `posts/` | 4 frases sueltas | 1080×1350 |
| `stories/` | 3 historias | 1080×1920 |
| `reels/` | 5 videos verticales sin audio (9–22 s) | 1080×1920, 30 fps |

Los reels van **sin audio** a propósito: en TikTok e Instagram se elige un sonido
en tendencia al publicar, y eso pesa más en el alcance que cualquier música fija.

## Cuentas

Las cuentas las crea el owner (no un agente). Mismo nombre en las dos redes:

- Usuario: `@homesync.app` (alternativas: `@homesyncapp`, `@homesync.ar`)
- Nombre visible: `HomeSync · tareas y gastos del hogar`
- Categoría (IG): App / Aplicación de software. Cuenta de **empresa** o
  **creador** para ver estadísticas.
- Foto: `profile/foto_perfil.jpg`

**Bio de Instagram** (máx. 150):

```
Que la casa sea pareja 🏠
Tareas, plata y compras repartidas entre todos.
Pareja · Familia · Convivencia
Gratis en Android 👇
```

**Bio de TikTok** (máx. 80):

```
Que la casa sea pareja 🏠 Tareas y gastos del hogar. Gratis en Android 👇
```

**Link de la bio** (cada red con su UTM, así `growth-mcp` sabe de dónde vino cada
hogar):

- Instagram: `https://play.google.com/store/apps/details?id=com.blas.homesync&referrer=utm_source%3Dinstagram%26utm_medium%3Dorganic%26utm_campaign%3Dbio`
- TikTok: `https://play.google.com/store/apps/details?id=com.blas.homesync&referrer=utm_source%3Dtiktok%26utm_medium%3Dorganic%26utm_campaign%3Dbio`

**Destacadas de IG**: Pareja, Familia, Plata, Tareas, Compras, Novedades (portadas en
`profile/destacadas/`). Cada historia que se publique se guarda en la que corresponda.

## Primeras dos semanas

Ritmo sostenible: IG 4 posteos por semana + historias; TikTok 1 video por día
hábil (TikTok premia la frecuencia). Los reels se suben a las dos redes.

| Día | Instagram | TikTok |
| --- | --- | --- |
| 1 | Carrusel `01_lanzamiento` (fijado) + historia `01_tareas` | Reel `05_tour_familia` |
| 2 | Reel `01_familia_ciclo_completo` | Reel `01_familia_ciclo_completo` |
| 3 | Historia `03_plata` | Reel `04_pareja_semana` |
| 4 | Carrusel `02_familia_misiones` (fijado) | Reel `02_familia_aprobar` |
| 5 | Post `01_frase` + historia `02_benja` | Reel `03_familia_canje` |
| 8 | Reel `04_pareja_semana` | Repost con otro sonido del de mejor rendimiento |
| 9 | Carrusel `03_pareja_semana` (fijado) | Reel `05_tour_familia` con texto distinto |
| 10 | Post `03_frase` | — |
| 11 | Reel `03_familia_canje` | Reel nuevo (grabar) |
| 12 | Carrusel `04_mesada` + post `02_frase` | Reel nuevo (grabar) |

Horarios que suelen andar en Argentina: 12–13 h y 20–22 h. Después de la primera
semana, mirar en `growth-mcp` (`get_acquisition_funnel` agrupado por source)
qué red trae hogares que se activan y volcar ahí el esfuerzo.

## Textos para cada pieza

Voseo, sin culpar a nadie, emojis clásicos. Los hashtags van al final (en TikTok,
3 a 5).

**Carrusel 01 · lanzamiento**
> ¿Quién sacó la basura? ¿Quién puso la plata del súper? ¿A quién le toca lavar? 🙃
> Hicimos HomeSync para que la casa sea pareja: las tareas, los gastos y la lista de compras, repartidos y a la vista de todos.
> Gratis y sin publicidad. Link en la bio 👆
> #organizacióndelhogar #tareasdelhogar #parejas #finanzasenpareja #homesync

**Carrusel 02 · familia**
> En casa de los Romero, Benja (9) pone la mesa sin que se lo pidan. ¿El secreto? Misiones con monedas que canjea por premios que eligen en familia 🪙
> Mamá o papá aprueban, él junta y elige: postre, la peli del viernes o 15 minutos más de pantalla.
> #crianza #tareasparaniños #familia #maternidad #paternidad

**Carrusel 03 · pareja**
> "Yo cocino siempre" vs. "pero yo lavo" 🍝
> HomeSync les muestra cómo se repartió la semana, sin ranking y sin reproches, y les propone cómo emparejarla.
> #parejas #convivencia #vidaenpareja #tareasdelhogar

**Carrusel 04 · mesada**
> La mesada, sin acordarte cada 1° del mes 💸
> Se programa una vez y le llega sola a tu adolescente, que además aprende a registrar en qué la gasta.
> #mesada #educaciónfinanciera #adolescentes #crianza

**Reel 01 · ciclo completo** (gancho en pantalla: "Benja (9) puso la mesa")
> Tarea hecha ✅ aprobada ✅ canjeada ✅ Así funciona en casa.
> #tareasparaniños #crianzarespetuosa #familia #homesync

**Reel 02 · aprobar**
> Ese momento 🥹 #crianza #maternidad #paternidad #tareasdelhogar

**Reel 03 · canje**
> No es plata, son monedas. Y las cuida como si fueran oro 😂 #crianza #tareasparaniños #familia

**Reel 04 · pareja**
> Para las parejas que discuten por quién hizo más 👀 #parejas #convivencia #humordepareja

**Reel 05 · tour**
> Así se ve un día en casa de los Romero 🏠 #organizacióndelhogar #familia #apps

**Frases**
- 01: "La casa no se limpia sola." → *Etiquetá a quien tiene que leer esto 👀*
- 02: "Yo sacaba la basura todas las semanas." → *¿Te pasó? 🗑️*
- 03: plata en pareja → *¿Cómo manejan la plata en casa: todo junto o cada uno lo suyo? Leemos 👇*
- 04: "¿a quién le toca?" → *Guardalo para mostrárselo a tu familia.*

## Reglas

- Los personajes son siempre los demo (Sofi y Mati, Familia Romero). Nunca chicos
  reales.
- No prometer iPhone, Mercado Pago ni precios (ver `muse-brief.md`).
- No inventar reseñas, cifras de usuarios ni premios.
- Responder comentarios en las primeras 2 horas: es lo que más empuja el alcance al
  principio.

## Próximos videos para grabar

Lo que más rinde en TikTok son personas reales con un gancho de humor; la app
aparece al final como solución. Ideas para grabar con el celular:

1. "POV: tu pareja dice que siempre lava él" → mostrar La semana de ustedes.
2. "Cómo logré que mi hijo de 9 ordene sin gritar" → misiones + tienda.
3. "Le saco foto al ticket y se carga solo" (escáner OCR, solo pantalla).
4. "Lo que gastamos en un mes siendo 4" → resumen del mes (con datos demo).
5. Dueto o stitch con videos de "carga mental" respondiendo con la app.
