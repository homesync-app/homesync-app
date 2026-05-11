# Triage de errores de produccion con IA

Objetivo: cuando alguien pida "mira que errores hay" o "arregla el error mas importante", la IA debe consultar la bandeja unificada de Supabase, agrupar por impacto y trabajar sobre el issue mas relevante.

## Fuentes

- `public.application_logs`: errores/crashes/logs capturados por Flutter y visibles en `homesync_admin` > Bandeja > Crashes / Logs.
- `public.error_issues`: agrupacion deduplicada de errores, con estado operativo (`open`, `investigating`, `fixed`, `ignored`) y notas para seguimiento.
- Firebase Crashlytics: respaldo para crashes nativos Android/iOS. Usarlo si falta contexto en Supabase.

## Flujo Codex

1. Sincronizar la tabla de issues desde los logs recientes:

```bash
cd homesync_admin
npm run triage:errors -- --days 7 --limit 20 --sync
```

2. Consultar `error_issues` abiertos por impacto:

```sql
select
  id,
  level,
  status,
  title,
  occurrences,
  affected_users,
  first_seen,
  last_seen,
  app_frame,
  screens,
  last_seen_build
from public.error_issues
where status in ('open', 'investigating')
order by
  case level
    when 'critical' then 0
    when 'error' then 1
    when 'warning' then 2
    else 3
  end,
  occurrences desc,
  affected_users desc,
  last_seen desc
limit 10;
```

3. Si `error_issues` esta vacia o desactualizada, consultar errores recientes agrupados, sin exponer PII:

```sql
select
  coalesce(level, 'unknown') as level,
  left(coalesce(message, ''), 120) as message_prefix,
  count(*)::int as occurrences,
  min(created_at) as first_seen,
  max(created_at) as last_seen,
  count(distinct user_id)::int as affected_users
from public.application_logs
where created_at >= now() - interval '7 days'
  and level in ('critical', 'error', 'warning')
group by coalesce(level, 'unknown'), left(coalesce(message, ''), 120)
order by
  case coalesce(level, 'unknown')
    when 'critical' then 0
    when 'error' then 1
    when 'warning' then 2
    else 3
  end,
  occurrences desc,
  last_seen desc
limit 10;
```

4. Elegir el grupo con mas impacto: prioridad `critical`, luego cantidad de ocurrencias, luego usuarios afectados, luego recencia.
5. Pedir 1-3 muestras del grupo elegido. Sanitizar contexto removiendo `email`, tokens, secretos y datos sensibles:

```sql
select
  id,
  created_at,
  level,
  message,
  left(coalesce(stack_trace, ''), 4000) as stack_trace_head,
  context - 'email' as context_sanitized,
  device_info
from public.application_logs
where created_at >= now() - interval '7 days'
  and level = '<level>'
  and message like '<message_prefix>%'
order by created_at desc
limit 3;
```

6. Marcar el issue como `investigating` antes de tocar codigo si va a requerir trabajo.
7. Buscar frames de la app (`package:homesync_client/...`) o breadcrumbs (`current_screen`, `breadcrumbs`) para ubicar el modulo.
8. Inspeccionar el codigo con `rg` y lecturas por offset. No leer god files completos.
9. Implementar el fix mas chico que corte la causa.
10. Verificar con `flutter test` o, si el cambio es focalizado y los tests globales estan rotos, con `flutter analyze`/test especifico. Anotar cualquier limitacion.
11. Marcar el issue como `fixed` solo cuando el cambio exista en codigo. Usar `fixed_in_build = 'pending_patch'` si todavia no se publico Shorebird/Play Store.
12. Resumir: error elegido, evidencia, archivos cambiados, verificacion y estado actualizado en Supabase.

## Comando local opcional

Desde `homesync_admin`:

```bash
npm run triage:errors -- --days 7 --limit 10
```

Para sincronizar la tabla de issues:

```bash
npm run triage:errors -- --days 7 --limit 20 --sync
```

El script lee `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` desde `.env.local`. Si RLS no permite leer logs sin sesion, configurar variables locales no commiteadas:

```bash
HOMESYNC_ADMIN_EMAIL=...
HOMESYNC_ADMIN_PASSWORD=...
```

Para tareas server-only tambien se puede usar `SUPABASE_SERVICE_ROLE_KEY`, pero nunca debe commitearse ni imprimirse.
