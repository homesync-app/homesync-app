-- OCR: modelo principal + respaldo, chequeo aritmético del monto, techo
-- diario por usuario y comercios recordados por CUIT.
--
-- 1. ocr_scan_logs: telemetría del escalado (attempts, escalation_reason),
--    resultado del chequeo aritmético (amount_check) y de los avisos nuevos
--    (duplicate_expense_id, merchant_from_history).
-- 2. get_scan_context: además del conteo de la ventana corta devuelve el de
--    las últimas 24 h (techo de costo: 8/min permitía ~11.500 scans/día).
--    Cambia el tipo de retorno → DROP + CREATE con los mismos revokes.
-- 3. merchant_preferences: cómo llama cada hogar a un comercio (por CUIT).
--    La Edge Function la lee con service role; el cliente la escribe SOLO
--    vía remember_merchant_preference (security definer): RLS directo no
--    funciona con JWT de Firebase.

-- ── 1. Telemetría ───────────────────────────────────────────────────────────

alter table public.ocr_scan_logs
  add column if not exists attempts integer,
  add column if not exists escalation_reason text
    check (escalation_reason in ('primary_unavailable', 'amount_mismatch', 'amount_missing', 'invalid_output')),
  add column if not exists amount_check text
    check (amount_check in ('ok', 'mismatch', 'missing', 'unknown')),
  add column if not exists duplicate_expense_id uuid,
  add column if not exists merchant_from_history boolean;

comment on column public.ocr_scan_logs.model is
  'Modelo cuyo resultado se usó (principal o respaldo).';
comment on column public.ocr_scan_logs.attempts is
  'Requests a Gemini en este scan (principal, respaldo, reintentos).';
comment on column public.ocr_scan_logs.escalation_reason is
  'Por qué se llamó al modelo de respaldo; NULL = solo el principal.';
comment on column public.ocr_scan_logs.amount_check is
  'Chequeo aritmético: suma de líneas − descuentos + recargos contra el total.';
comment on column public.ocr_scan_logs.duplicate_expense_id is
  'Gasto existente del hogar con mismo monto y fecha (aviso de posible duplicado).';
comment on column public.ocr_scan_logs.merchant_from_history is
  'true si nombre/categoría salieron de merchant_preferences (CUIT conocido).';

-- ── 2. Contexto de scan con conteo diario ───────────────────────────────────

drop function if exists public.get_scan_context(text, integer);

create function public.get_scan_context(
  p_firebase_uid text,
  p_window_seconds integer default 60
)
returns table (
  user_id uuid,
  household_id uuid,
  tier text,
  recent_scans integer,
  daily_scans integer
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
    ) as recent_scans,
    (
      select count(*)::integer
      from public.ocr_scan_logs l
      where l.user_id = u.id
        and l.status is not null
        and l.created_at >= now() - interval '24 hours'
    ) as daily_scans
  from public.users u
  left join public.household_members hm on hm.user_id = u.id
  left join public.households h on h.id = hm.household_id
  where u.firebase_uid = p_firebase_uid
  limit 1;
$$;

revoke all on function public.get_scan_context(text, integer) from public;
revoke all on function public.get_scan_context(text, integer) from anon;
revoke all on function public.get_scan_context(text, integer) from authenticated;

-- ── 3. Comercios recordados por CUIT ────────────────────────────────────────

create table if not exists public.merchant_preferences (
  household_id uuid not null references public.households(id) on delete cascade,
  tax_id text not null check (tax_id ~ '^\d{11}$'),
  title text not null check (char_length(btrim(title)) between 1 and 100),
  category text check (category is null or char_length(category) <= 40),
  updated_by uuid references public.users(id) on delete set null,
  updated_at timestamptz not null default now(),
  primary key (household_id, tax_id)
);

comment on table public.merchant_preferences is
  'Nombre y categoría que el hogar usa para un comercio (CUIT). Se escribe al confirmar un gasto escaneado; scan-receipt lo aplica en el próximo ticket del mismo CUIT.';

-- Sin policies: nadie la lee ni escribe directo desde el cliente.
alter table public.merchant_preferences enable row level security;
revoke all on table public.merchant_preferences from anon, authenticated;

create or replace function public.remember_merchant_preference(
  p_tax_id text,
  p_title text,
  p_category text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := public.current_app_user_id();
  v_household_id uuid;
  v_title text := left(btrim(coalesce(p_title, '')), 100);
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  -- Entrada inválida: se ignora en silencio (es una preferencia, no un dato
  -- crítico; el cliente lo llama best-effort).
  if p_tax_id is null or p_tax_id !~ '^\d{11}$' or v_title = '' then
    return;
  end if;

  select hm.household_id into v_household_id
  from public.household_members hm
  where hm.user_id = v_user_id
  limit 1;
  if v_household_id is null then
    return;
  end if;

  insert into public.merchant_preferences as mp
    (household_id, tax_id, title, category, updated_by, updated_at)
  values
    (v_household_id, p_tax_id, v_title, nullif(left(btrim(p_category), 40), ''), v_user_id, now())
  on conflict (household_id, tax_id) do update
    set title = excluded.title,
        category = excluded.category,
        updated_by = excluded.updated_by,
        updated_at = now();
end;
$$;

revoke all on function public.remember_merchant_preference(text, text, text) from public;
revoke all on function public.remember_merchant_preference(text, text, text) from anon;
grant execute on function public.remember_merchant_preference(text, text, text) to authenticated;
