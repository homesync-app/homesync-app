-- Hardening pre-lanzamiento (advisors 2026-07-16).
-- 1) RPCs SECURITY DEFINER ejecutables por anon: la app siempre llama como
--    authenticated (JWT de Firebase third-party), asi que anon no pierde nada.
--    Se revoca tambien PUBLIC (origen del grant implicito) y se re-otorga
--    explicitamente a authenticated + service_role.
-- 2) Constraint UNIQUE duplicada en household_members (mismas columnas que
--    household_members_household_id_user_id_key; sin FKs entrantes).
-- 3) v_ocr_daily_stats era SECURITY DEFINER (unico ERROR del advisor): pasa a
--    security_invoker. Los admins del portal ya tienen policy propia sobre
--    ocr_scan_logs ("admins can read ocr_scan_logs"), asi que no pierden acceso.
-- 4) Bucket avatars: la app lee SOLO por URL publica (bucket publico) y ningun
--    cliente sube directo (custom-avatars va por edge function con service
--    role). Las policies amplias solo habilitaban listar el bucket entero a
--    cualquier autenticado (advisor public_bucket_allows_listing).

do $$
declare
  fn text;
begin
  foreach fn in array array[
    'public.deactivate_goal_linked_templates()',
    'public.get_category_spend_v1(uuid, timestamptz, timestamptz)',
    'public.get_month_recap_v1(uuid, timestamptz, timestamptz)',
    'public.get_monthly_spend_trend_v1(uuid, integer)',
    'public.get_personal_finance_summary(uuid, uuid, timestamptz, timestamptz)',
    'public.get_pool_summary_v1(uuid)',
    'public.is_household_savings_contributor(uuid)',
    'public.is_household_savings_manager(uuid)',
    'public.save_expense_v4(uuid, uuid, text, numeric, text, uuid, timestamptz, text, text, boolean, text, jsonb, text, uuid)',
    'public.seed_family_default_rewards_v1(uuid)',
    'public.settle_debt_v1(text, uuid, uuid, uuid, numeric, uuid)'
  ]
  loop
    execute format('revoke execute on function %s from public, anon', fn);
    execute format(
      'grant execute on function %s to authenticated, service_role',
      fn
    );
  end loop;
end $$;

alter table public.household_members
  drop constraint if exists unique_household_user;

alter view public.v_ocr_daily_stats set (security_invoker = on);
revoke select on public.v_ocr_daily_stats from anon;

drop policy if exists "Avatars readable by authenticated" on storage.objects;
drop policy if exists "Avatars uploadable by authenticated" on storage.objects;

notify pgrst, 'reload schema';
