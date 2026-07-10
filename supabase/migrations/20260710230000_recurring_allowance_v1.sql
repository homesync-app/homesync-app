-- Mesada recurrente (Teen finances fase 3 — docs/TEEN_FINANCES_SPEC.md).
--
-- Un adulto deja programada la mesada mensual (monto + día). Un cron diario
-- ejecuta las que vencieron: mismas DOS filas personales atómicas que
-- transfer_to_member (egreso del adulto + ingreso del teen, fuera del pozo
-- compartido), idempotentes vía request_id único por schedule+mes — correr
-- el cron dos veces no duplica. El teen recibe una notificación.
--
-- Guards en ejecución (no solo al crear): hogar premium (Parent Mode),
-- emisor sigue siendo adulto y receptor sigue siendo teen del hogar; si algo
-- dejó de cumplirse, el schedule se salta sin romper (y sin desactivarse:
-- si el premium vuelve, la mesada sigue).

CREATE TABLE IF NOT EXISTS public.allowance_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id uuid NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  from_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  to_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount numeric NOT NULL CHECK (amount > 0),
  day_of_month integer NOT NULL DEFAULT 1 CHECK (day_of_month BETWEEN 1 AND 28),
  note text,
  is_active boolean NOT NULL DEFAULT true,
  last_run_month date,
  created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Una mesada activa por par adulto→teen.
CREATE UNIQUE INDEX IF NOT EXISTS uq_allowance_schedules_active_pair
  ON public.allowance_schedules (from_user_id, to_user_id)
  WHERE is_active;

ALTER TABLE public.allowance_schedules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "restrict_to_valid_jwt_allowance_schedules" ON public.allowance_schedules;
CREATE POLICY "restrict_to_valid_jwt_allowance_schedules"
  ON public.allowance_schedules
  AS RESTRICTIVE
  FOR ALL
  USING ((SELECT public.is_supabase_or_firebase_project_jwt()) IS TRUE);

-- Ver: emisor o receptor (el teen ve su propia mesada programada).
DROP POLICY IF EXISTS "Sender or recipient can view allowance schedules" ON public.allowance_schedules;
CREATE POLICY "Sender or recipient can view allowance schedules"
  ON public.allowance_schedules
  FOR SELECT
  USING (
    public.is_current_household_member(household_id)
    AND (
      from_user_id = public.current_app_user_id()
      OR to_user_id = public.current_app_user_id()
    )
  );

-- Crear/editar/borrar: solo el adulto emisor.
DROP POLICY IF EXISTS "Adults manage own allowance schedules" ON public.allowance_schedules;
CREATE POLICY "Adults manage own allowance schedules"
  ON public.allowance_schedules
  FOR INSERT
  WITH CHECK (
    from_user_id = public.current_app_user_id()
    AND EXISTS (
      SELECT 1 FROM public.household_members hm
      WHERE hm.household_id = allowance_schedules.household_id
        AND hm.user_id = public.current_app_user_id()
        AND coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
    )
  );

DROP POLICY IF EXISTS "Adults update own allowance schedules" ON public.allowance_schedules;
CREATE POLICY "Adults update own allowance schedules"
  ON public.allowance_schedules
  FOR UPDATE
  USING (from_user_id = public.current_app_user_id())
  WITH CHECK (from_user_id = public.current_app_user_id());

DROP POLICY IF EXISTS "Adults delete own allowance schedules" ON public.allowance_schedules;
CREATE POLICY "Adults delete own allowance schedules"
  ON public.allowance_schedules
  FOR DELETE
  USING (from_user_id = public.current_app_user_id());

-- Ejecutor diario.
create or replace function public.process_allowance_schedules_v1()
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_schedule record;
  v_from_name text;
  v_to_name text;
  v_currency text;
  v_req text;
  v_out_id uuid;
  v_processed integer := 0;
  v_skipped integer := 0;
begin
  for v_schedule in
    select s.*
    from public.allowance_schedules s
    where s.is_active
      and s.day_of_month <= extract(day from current_date)::int
      and (
        s.last_run_month is null
        or s.last_run_month < date_trunc('month', current_date)::date
      )
    order by s.created_at
  loop
    -- Guards de ejecución: premium + roles vigentes.
    if not public.is_household_premium(v_schedule.household_id)
       or not exists (
         select 1 from public.household_members hm
         where hm.household_id = v_schedule.household_id
           and hm.user_id = v_schedule.from_user_id
           and coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
       )
       or not exists (
         select 1 from public.household_members hm
         where hm.household_id = v_schedule.household_id
           and hm.user_id = v_schedule.to_user_id
           and coalesce(hm.member_type, '') = 'teen'
       )
    then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    -- Idempotencia dura: request_id único por schedule+mes.
    v_req := 'allowance-sched-' || v_schedule.id || '-'
      || to_char(current_date, 'YYYY-MM');
    if exists (
      select 1 from public.expenses where request_id = v_req || '-out'
    ) then
      update public.allowance_schedules
      set last_run_month = date_trunc('month', current_date)::date,
          updated_at = timezone('utc'::text, now())
      where id = v_schedule.id;
      v_skipped := v_skipped + 1;
      continue;
    end if;

    select u.full_name into v_from_name
    from public.users u where u.id = v_schedule.from_user_id;
    select u.full_name into v_to_name
    from public.users u where u.id = v_schedule.to_user_id;

    select currency into v_currency
    from public.expenses
    where household_id = v_schedule.household_id
    order by created_at desc
    limit 1;
    v_currency := coalesce(v_currency, 'ARS');

    -- Egreso del adulto (personal).
    insert into public.expenses (
      household_id, created_by_id, title, description, category, amount,
      currency, paid_by, paid_at, type, split_type, is_shared, request_id
    ) values (
      v_schedule.household_id, v_schedule.from_user_id,
      'Mesada para ' || coalesce(v_to_name, 'familiar'),
      v_schedule.note, 'allowance', v_schedule.amount, v_currency,
      v_schedule.from_user_id, now(), 'expense', 'personal', false,
      v_req || '-out'
    ) returning id into v_out_id;
    insert into public.expense_splits (expense_id, user_id, amount)
    values (v_out_id, v_schedule.from_user_id, v_schedule.amount);

    -- Ingreso del teen (personal).
    insert into public.expenses (
      household_id, created_by_id, title, description, category, amount,
      currency, paid_by, paid_at, type, split_type, is_shared, request_id
    ) values (
      v_schedule.household_id, v_schedule.from_user_id,
      'Mesada de ' || coalesce(v_from_name, 'familiar'),
      v_schedule.note, 'allowance', v_schedule.amount, v_currency,
      v_schedule.to_user_id, now(), 'income', 'personal', false,
      v_req || '-in'
    ) returning id into v_out_id;
    insert into public.expense_splits (expense_id, user_id, amount)
    values (v_out_id, v_schedule.to_user_id, v_schedule.amount);

    -- Aviso al teen (copy sin tildes, params para localizar después).
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id, params
    ) values (
      v_schedule.household_id,
      v_schedule.to_user_id,
      'Te llego la mesada',
      coalesce(v_from_name, 'Un adulto') || ' te paso $'
        || to_char(round(v_schedule.amount), 'FM999999990'),
      'allowance_received',
      'allowance_schedule',
      v_schedule.id,
      jsonb_build_object(
        'amount', round(v_schedule.amount),
        'from_name', v_from_name
      )
    );

    update public.allowance_schedules
    set last_run_month = date_trunc('month', current_date)::date,
        updated_at = timezone('utc'::text, now())
    where id = v_schedule.id;

    v_processed := v_processed + 1;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed', v_processed,
    'skipped', v_skipped,
    'run_date', current_date
  );
end;
$function$;

revoke execute on function public.process_allowance_schedules_v1()
  from public, anon, authenticated;
grant execute on function public.process_allowance_schedules_v1()
  to service_role;

-- Diario 12:10 UTC (9:10 AR), después de los recordatorios de pagos.
select cron.schedule(
  'allowance-schedules-daily',
  '10 12 * * *',
  'select public.process_allowance_schedules_v1();'
);
