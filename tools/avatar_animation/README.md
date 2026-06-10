# Avatar Animation Pipeline

Convierte los avatares premium estáticos (`flutter_client/assets/images/premium_3d_avatars/*.png`)
en **WebP animados con transparencia** usando Veo (Gemini API) + FFmpeg, con un
movimiento idle ("saludo") más movimientos de evento (victory / versus / celebrate).

## Requisitos

- Node 22+ y FFmpeg en PATH (verificados)
- `GEMINI_API_KEY` en el entorno (cuenta con facturación habilitada para Veo;
  las keys nuevas empiezan con `AQ.`)

## Receta: sumar un personaje nuevo (gatito = referencia terminada)

```powershell
# 0. (una vez por personaje) Agregar sus prompts de evento en avatars.config.mjs
#    -> EVENT_MOTIONS[<id>] = { victory, versus, celebrate } (copiar del gatito y adaptar)

# 1. Generar los 4 clips (~USD 0.60 c/u con veo-3.1-fast)
node tools/avatar_animation/generate.mjs --avatar <id> --takes 1
node tools/avatar_animation/generate.mjs --avatar <id> --motion victory --takes 1
node tools/avatar_animation/generate.mjs --avatar <id> --motion versus --takes 1
node tools/avatar_animation/generate.mjs --avatar <id> --motion celebrate --takes 1

# 2. Post-producción: chroma key -> loop -> WebP transparente + preview
node tools/avatar_animation/postprocess.mjs --avatar <id>
start tools/avatar_animation/work/out/preview.html

# 3. Copiar los elegidos a dist/ (nombre sin _takeN) y subirlos a Supabase
#    Storage (NO van en el APK; la app los descarga bajo demanda):
#    supabase storage cp "tools\avatar_animation\dist\<archivo>.webp" `
#      "ss:///avatars/premium_animated/<archivo>.webp" --experimental --linked
#    Archivos: <id>.webp (idle), <id>_victory.webp, <id>_versus.webp, <id>_celebrate.webp

# 4. Registrar en Flutter: agregar la entrada del personaje en
#    kAnimatedPremiumAvatarFiles (lib/core/services/premium_avatar_motion_cache.dart).
#    Nada más: header, faceoff, ganador semanal y saldar deuda ya lo levantan solos.
```

Si un take oneshot no termina en pose neutral (le pasó al celebrate del gato),
no regenerar: agregarle `trimSeconds` en EVENT_MOTIONS y cambiarlo a `pingpong`
(recorta a la parte buena y la ida-vuelta garantiza volver al inicio).

## Detalles técnicos

- **Chroma magenta** (`#FF00FF`) para todos: el arte usa paleta cálida/pastel con
  muchos verdes (pañuelos, yerba, plantas), así que el verde clásico está descartado.
- Los PNG se componen sobre lienzo magenta 1280x720 antes de enviarse a Veo
  (el modelo solo acepta 16:9 / 9:16).
- Prompts por avatar en `avatars.config.mjs`: idle en `AVATARS[].motion`,
  eventos en `EVENT_MOTIONS` (oneshot debe pedir "end in the same pose as the
  very first frame"; los pingpong deben ser movimientos simétricos/sutiles).
- API Veo: la imagen va como `image: {mimeType, bytesBase64Encoded}` y
  `durationSeconds` es numérico (con string/inlineData devuelve 400).
- Clips de 4 s; el post baja a 12 fps, 480x480. idle/versus = ping-pong sin
  costura; oneshot = solo ida.
- La cadena fuerza `out_color_matrix=bt601` + `format=rgba` para evitar
  corrimientos de color 601/709 (verde → marrón).
- Si queda halo magenta en bordes: subir `--similarity` (default 0.20).
  Si se come partes del personaje: bajarla.
- Los videos generados expiran a los 2 días en el server de Google; el script
  los descarga inmediatamente a `work/raw/`.
- Peso: ~0.8-1.7 MB por clip a calidad 70. Pendiente: bajar `--quality`/`--size`
  cuando se cierren los takes; a futuro solo idles en el APK y eventos por CDN.

## Lado Flutter (ya construido)

- **Entrega remota**: los WebP viven en Supabase Storage (bucket publico
  `avatars`, carpeta `premium_animated/`). `PremiumAvatarMotionCache`
  (lib/core/services/premium_avatar_motion_cache.dart) los descarga bajo
  demanda (escritura atomica via .tmp) y los cachea en el dir de soporte de
  la app; `premiumAvatarMotionPathsProvider` expone las rutas locales.
  En el picker los tiles son siempre estaticos (`allowMotion: false`);
  al seleccionar se dispara el prefetch.
- `PremiumAnimatedAvatar` (lib/shared/widgets/premium_animated_avatar.dart):
  player frame a frame con ui.Codec — reproduce una pasada y "respira" 10 s
  (nada de loop infinito). Acepta assets del bundle o archivos locales.
  Se pausa en background/ruta tapada (TickerMode + lifecycle) y respeta
  reduce-motion (muestra el PNG). **No usar Image.asset con cacheWidth para
  WebP animado: congela el primer frame.**
- `enum AvatarMotion { idle, victory, versus, celebrate }` + registro central
  `kAnimatedPremiumAvatarFiles` (premium_avatar_motion_cache.dart).
- `CustomUserAvatar(ambientMotion: ...)` para estados sostenidos (faceoff usa
  versus; pantalla de ganador usa victory).
- `PremiumAvatarMotionController` + `homeMascotMotionProvider` (Riverpod) para
  disparar eventos desde cualquier widget: saldar deuda dispara
  `play(AvatarMotion.celebrate)` sobre la mascota del header.
- Animan solo los personajes con entrada en el registro; el resto cae al PNG
  estático automáticamente (fallback integrado en el player).
