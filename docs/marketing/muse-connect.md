# Conectar Muse a las métricas de HomeSync

Muse (Meta) suma servicios como **custom connectors** que hablan MCP. No hay un
formulario: se le pide en el chat, con la URL del servidor, y Muse pide la
credencial en su propio aviso seguro.

El servidor es la Edge Function `growth-mcp` (Supabase, desplegada). Solo devuelve
**agregados** (conteos por día, modo de hogar y campaña): nunca nombres, emails ni
ids. Acepta el token por `Authorization: Bearer`, por el header `x-api-key` o, si el
cliente no deja poner headers, como `?token=` en la URL.

- URL: `https://tfavamqszdkoeabpyxms.supabase.co/functions/v1/growth-mcp`
- Token: `GROWTH_MCP_TOKEN` en `supabase/.env.claude` (gitignoreado). No pegarlo en el
  chat de Muse ni en ningún archivo versionado: solo en el aviso de credenciales que
  abre Muse.

## Pasos

1. Abrí Muse y pegá este mensaje:

   > Quiero agregar un custom connector MCP llamado **HomeSync Growth**.
   > URL del servidor MCP: https://tfavamqszdkoeabpyxms.supabase.co/functions/v1/growth-mcp
   > Transporte: Streamable HTTP (solo POST, respuestas JSON).
   > Autenticación: API key estática en el header `Authorization: Bearer <token>` (también acepta `x-api-key`). Pedime el token en tu aviso seguro.
   > Tiene tres herramientas de solo lectura: get_growth_overview, get_acquisition_funnel y get_daily_signups. Probá get_growth_overview con days=30 cuando esté conectado.

2. Cuando Muse pida la credencial, pegá el valor de `GROWTH_MCP_TOKEN`.
3. Muse lo prueba y lo guarda. Desde ahí podés preguntarle, por ejemplo:
   - "¿Cuántos hogares nuevos hubo esta semana y en qué modo?"
   - "Compará las campañas de Instagram y TikTok por hogares activados."
   - "¿El reel del martes movió las altas? Mostrame los últimos 14 días."

Si Muse no deja usar headers, la alternativa es dar la URL con el token al final
(`.../growth-mcp?token=<token>`). Funciona, pero el token queda dentro de la URL
guardada en Muse.

## Para que los números signifiquen algo

Cada link que publique Muse lleva su UTM (ver `muse-brief.md`). Sin UTM, la
instalación cae en "(sin atribución)" y no se sabe qué posteo la trajo.

## Si hay que rotar el token

```bash
bash scripts/supabase_prod.sh secrets set GROWTH_MCP_TOKEN=<nuevo>
```

Actualizar el valor en `supabase/.env.claude` y volver a pegarlo en Muse.
