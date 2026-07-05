-- Unificación de logs de OCR + mejoras al pipeline scan-receipt.
--
-- Antes había DOS tablas paralelas por scan:
--   - receipt_scan_logs: insertada por la Edge Function (rate limit)
--   - ocr_scan_logs: insertada por el cliente (telemetría de IA + matcher,
--     leída por el panel admin y las vistas v_ocr_*)
--
-- Ahora ocr_scan_logs es la única tabla:
--   - La Edge Function inserta la fila ANTES de llamar a Gemini (status =
--     'pending' → 'success'/'failed') en TODOS los requests, así el rate
--     limit cuenta intentos (incluidos los fallidos) en ambos paths.
--   - Para clientes nuevos (upload binario) la función además completa los
--     campos ai_* y devuelve el logId; el cliente solo actualiza
--     matcher_result y user_action sobre esa fila.
--   - Los clientes legados (path JSON base64) siguen insertando su propia
--     fila vía RLS como siempre (status IS NULL las identifica). La fila del
--     servidor en ese path queda solo como marcador de rate limit (ai_* null)
--     y v_ocr_daily_stats la excluye para no duplicar estadísticas.
--   - El rate limit cuenta SOLO filas del servidor (status IS NOT NULL):
--     exactamente 1 por intento, sin importar el path ni el resultado.
--
-- receipt_scan_logs se elimina. Su única información era el conteo histórico
-- de scans (sin contenido); cada scan exitoso ya tiene su fila equivalente en
-- ocr_scan_logs desde que esa tabla existe (2026-04-30).

-- ── Telemetría en ocr_scan_logs ─────────────────────────────────────────────

alter table public.ocr_scan_logs
  add column if not exists status text
    check (status in ('pending', 'success', 'failed')),
  add column if not exists finish_reason text,
  add column if not exists gemini_latency_ms integer,
  add column if not exists prompt_tokens integer,
  add column if not exists output_tokens integer,
  add column if not exists model text;

comment on column public.ocr_scan_logs.status is
  'NULL = fila insertada por un cliente legado (logScan). NOT NULL = fila insertada por la Edge Function antes de llamar a Gemini: pending → success/failed.';

-- El rate limit cuenta por usuario en ventana corta; el índice existente
-- (user_id) solo, no cubre el rango temporal. Compuesto dedicado.
create index if not exists ocr_scan_logs_user_recent
  on public.ocr_scan_logs (user_id, created_at);

-- ── RPC de contexto de scan ─────────────────────────────────────────────────

-- Devuelve todo lo que la Edge Function necesita en 1 round-trip (antes eran
-- 3 queries secuenciales en el camino crítico del spinner).
-- left join: si el usuario existe pero no tiene household, devuelve la fila
-- con household_id null (la función distingue 401 de 403 con eso).
-- Solo para uso server-side (service role); se revoca a anon/authenticated.
create or replace function public.get_scan_context(
  p_firebase_uid text,
  p_window_seconds integer default 60
)
returns table (
  user_id uuid,
  household_id uuid,
  tier text,
  recent_scans integer
)
language sql
stable
security definer
set search_path = public
as $$
  select
    u.id as user_id,
    hm.household_id,
    coalesce(h.plan_tier, 'free') as tier,
    (
      -- Solo filas del servidor (status not null): 1 por intento. Las filas
      -- legadas insertadas por el cliente quedan fuera para no contar doble.
      select count(*)::integer
      from public.ocr_scan_logs l
      where l.user_id = u.id
        and l.status is not null
        and l.created_at >= now() - make_interval(secs => p_window_seconds)
    ) as recent_scans
  from public.users u
  left join public.household_members hm on hm.user_id = u.id
  left join public.households h on h.id = hm.household_id
  where u.firebase_uid = p_firebase_uid
  limit 1;
$$;

revoke all on function public.get_scan_context(text, integer) from public;
revoke all on function public.get_scan_context(text, integer) from anon;
revoke all on function public.get_scan_context(text, integer) from authenticated;

-- ── Vistas: excluir filas-marcador del servidor ─────────────────────────────

-- Las filas del servidor sin datos de IA (path legado, scans fallidos o
-- pendientes en vuelo) son marcadores de rate limit, no scans con contenido.
-- Sin este filtro, cada scan de una app legada contaría doble (fila del
-- servidor + fila del cliente). v_ocr_unmatched_items y v_ocr_dropped_items
-- no necesitan cambio: ya filtran por claves de matcher_result que las filas
-- marcador no tienen.
create or replace view v_ocr_daily_stats as
select
  date_trunc('day', created_at)::date     as day,
  count(*)                                as total_scans,
  round(avg(ai_confidence)::numeric, 2)   as avg_confidence,
  round(avg(jsonb_array_length(coalesce(matcher_result->'matched','[]'::jsonb)))::numeric, 1)      as avg_matched,
  round(avg(jsonb_array_length(coalesce(matcher_result->'to_add','[]'::jsonb)))::numeric, 1)        as avg_to_add,
  round(avg(jsonb_array_length(coalesce(matcher_result->'unrecognized','[]'::jsonb)))::numeric, 1) as avg_unmatched,
  round(avg(jsonb_array_length(coalesce(matcher_result->'dropped','[]'::jsonb)))::numeric, 1)       as avg_dropped,
  count(*) filter (where user_action = 'confirmed')   as confirmed,
  count(*) filter (where user_action = 'cancelled')   as cancelled,
  round(count(*) filter (where user_action = 'confirmed') * 100.0 / nullif(count(*), 0), 1) as confirm_rate_pct
from ocr_scan_logs
where not (
  status is not null
  and ai_raw_items = '[]'::jsonb
  and matcher_result = '{}'::jsonb
)
group by 1
order by 1 desc;

-- ── Eliminar la tabla redundante ────────────────────────────────────────────

drop table if exists public.receipt_scan_logs;
