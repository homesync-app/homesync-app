# Conectar Muse a HomeSync

Muse (Meta) suma servicios como **custom connectors** que hablan MCP. No hay un
formulario: se le pide en el chat, con la URL del servidor, y Muse pide la
credencial en su propio aviso seguro.

El servidor es la Edge Function `growth-mcp` (Supabase, desplegada). Le da a Muse:

- **El contenido para publicar** (`get_content_kit`): cada carrusel, reel, post e
  historia con sus URLs públicas, el texto, los hashtags, la red, el día del
  calendario y el link de Play con UTM. Muse lo publica en Instagram con su conector
  nativo.
- **Las métricas** (`get_growth_overview`, `get_acquisition_funnel`,
  `get_daily_signups`): solo agregados (conteos por día, modo y campaña), nunca
  nombres, emails ni ids.

Acepta el token por `Authorization: Bearer`, por el header `x-api-key` o, si el
cliente no deja poner headers, como `?token=` en la URL.

- URL: `https://tfavamqszdkoeabpyxms.supabase.co/functions/v1/growth-mcp`
- Token: `GROWTH_MCP_TOKEN` en `supabase/.env.claude` (gitignoreado). No pegarlo en el
  chat de Muse ni en ningún archivo versionado: solo en el aviso de credenciales que
  abre Muse.

## Pasos

1. Abrí Muse y pegá este mensaje:

   > Quiero agregar un custom connector MCP llamado **HomeSync**.
   > URL del servidor MCP: https://tfavamqszdkoeabpyxms.supabase.co/functions/v1/growth-mcp
   > Transporte: Streamable HTTP (solo POST, respuestas JSON).
   > Autenticación: API key estática en el header `Authorization: Bearer <token>` (también acepta `x-api-key`). Pedime el token en tu aviso seguro.
   > Tiene cuatro herramientas de solo lectura: get_content_kit (contenido listo para publicar), get_growth_overview, get_acquisition_funnel y get_daily_signups. Cuando esté conectado, probá get_content_kit con calendar_day=1.

2. Cuando Muse pida la credencial, pegá el valor de `GROWTH_MCP_TOKEN`.
3. Muse lo prueba y lo guarda. Desde ahí podés pedirle, por ejemplo:
   - "Traé lo del día 1 del kit y mostrámelo antes de publicarlo en Instagram."
   - "Programá en Instagram los carruseles del kit según su día de calendario, arrancando el lunes. Mostrame cada uno antes."
   - "¿Cuántos hogares nuevos hubo esta semana y en qué modo?"
   - "Compará las campañas por hogares activados."

Si Muse no deja usar headers, la alternativa es dar la URL con el token al final
(`.../growth-mcp?token=<token>`). Funciona, pero el token queda dentro de la URL
guardada en Muse.

## El contenido

- Se genera con `python tmp/marketing/build_social.py` y se sube con
  `python tmp/marketing/publish_kit.py` al bucket público `marketing`
  (migración `20261002190000_marketing_bucket.sql`: sin policies, así que no se
  puede listar ni escribir desde afuera; solo leer cada archivo por su URL).
- `content_kit.json` es la fuente de verdad de los textos. Para cambiar un texto o
  sumar una pieza: editar `PIECES` en `publish_kit.py` y volver a correrlo.
- **TikTok:** Muse no tiene conector de TikTok. Los reels del kit sirven igual: se
  suben a mano desde el celular, eligiendo un sonido en tendencia. La API oficial de
  TikTok publica en privado hasta pasar una auditoría; si más adelante vale la pena,
  se puede sumar una herramienta que deje los videos en borradores.

## Para que los números signifiquen algo

Cada pieza del kit trae su link con UTM (`links` por red). Sin UTM, la instalación
cae en "(sin atribución)" y no se sabe qué posteo la trajo.

## Si hay que rotar el token

```bash
bash scripts/supabase_prod.sh secrets set GROWTH_MCP_TOKEN=<nuevo>
```

Actualizar el valor en `supabase/.env.claude` y volver a pegarlo en Muse.
