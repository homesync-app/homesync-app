# Preguntas operativas (para Muse)

## Calendario y contenido

- **Calendario:** 18 días, 19 piezas. Llamá a `get_content_kit` sin filtros para
  verlo entero; cada pieza trae `calendar_day`.
  - Día 1: carrusel de lanzamiento, reel "tour familia" (IG + TikTok), historia de pareja.
  - Día 2: reel "familia ciclo completo".
  - Día 3: reel de pareja + historia.
  - Día 4: carrusel de misiones de familia + reel "aprobar".
  - Día 5: frase + reel "canje" + historia de familia.
  - Día 9: carrusel de pareja. Día 10: frase de pareja.
  - Día 12: carrusel de mesada + frase. Día 13: carrusel "cómo dividir gastos".
  - Día 15: carrusel "tareas por edad". Día 17: carrusel "rutina para vivir solo".
  - Día 18: frase.
  - Los días sin pieza son para responder comentarios, repetir lo que mejor anduvo o
    historias espontáneas.
- **Filtros de `get_content_kit`:** `mode` (pareja / familia / solo / general), `type`
  (carousel / reel / post / story), `network` (instagram / tiktok) y `calendar_day`.
  Se combinan.
- **Estado del kit:** completo para estas 18 jornadas. Se van a sumar piezas (sobre
  todo del modo solo); el manifest se actualiza solo, no hay que hacer nada.
- **Cambios de texto o piezas nuevas:** pedírselos a Blas; la otra IA edita el kit y
  lo vuelve a subir.
- **TikTok:** Muse no publica en TikTok. Los reels del kit los sube Blas desde el
  celular, con un sonido en tendencia.

## Métricas

- **Rango:** las tres herramientas reciben `days` de 1 a 365 (por defecto 30),
  contados hacia atrás desde hoy.
- **Definiciones:** alta = usuario nuevo; hogar nuevo = hogar creado; activado =
  registró una tarea, un gasto o una compra en sus primeros 7 días. Salen de la base
  de datos de la app (no de eventos de analytics). Se excluyen los hogares demo/QA.
- **Hoy los números son casi nulos:** la app recién empieza a promocionarse. No sacar
  conclusiones hasta que haya tráfico real.
- **Modos en métricas:** `couple`, `family`, `friends`, `solo`.
- **Campañas (`utm_campaign`):** el modo + el id de la pieza (`familia-ciclo`,
  `pareja-dividir-gastos`, `solo-rutina`...) o `bio`. Compararlas con
  `get_acquisition_funnel` y `group_by: "campaign"`.

## Servidor

- **Token:** no vence. Se rota a mano si hace falta; Blas te pasa el nuevo.
- **Límites:** no hay propios; solo los generales de Supabase, que para este uso
  sobran.
- **Herramientas a futuro:** dejar videos en borradores de TikTok (publicar directo
  pide una auditoría de TikTok). La programación de Instagram la hacés con tu
  conector.

## Marca visual

- **Colores:** naranja `#EE652B` (principal), naranja oscuro `#D85A23`, naranja claro
  `#FFF0EA`, crema `#FFFCF9` (fondo), texto marrón oscuro `#3A2A22`, verde salvia
  `#84A59D` (acento).
- **Tipografía:** Outfit (Black para títulos, Medium para texto).
- **Logo:** la casita naranja con orejas de gato. Foto de perfil:
  `https://tfavamqszdkoeabpyxms.supabase.co/storage/v1/object/public/marketing/kit/profile/foto_perfil.jpg`.
- **Estilo de las piezas:** fondo crema con degradé durazno, títulos grandes en
  marrón con una palabra en naranja, capturas de la app dentro de un teléfono,
  cierre naranja con "Gratis en Google Play".

## Cuentas

- **Instagram:** cuenta nueva de HomeSync (email `homesync.soporte@gmail.com`), en
  creación. Usuario a confirmar por Blas.
- **TikTok:** a confirmar por Blas.
