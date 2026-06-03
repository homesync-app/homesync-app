-- Hardening de pre-lanzamiento 1.2.0 — revoca acceso anon a funciones y vista
-- administrativas que, por el pg_default_acl default de Postgres, son
-- ejecutables/legibles por PUBLIC (incluye anon) aunque las migraciones
-- originales solo hayan hecho GRANT TO authenticated.
--
-- El linter 0028 de Supabase dispara precisamente por esto: el `GRANT
-- EXECUTE TO authenticated` es aditivo, no quita el grant a PUBLIC.
--
-- Verificacion contra DB viva (2026-06-03):
--   - pay_planned_expense, award_weekly_winner_for_week,
--     get_weekly_ranking_for_week, is_week_processed_for_week
--     anon_can_execute = true (mitigado por guard interno v_uid IS NULL)
--   - v_shopping_items_usage
--     anon_can_select = true, security_invoker = null
--
-- Esta migracion es idempotente: REVOKE es no-op si el grant no existe,
-- y ALTER VIEW SET es idempotente si el valor ya coincide.

-- ============================================================================
-- P0: vista con fuga potencial (anon bypasea RLS de shopping_items)
-- ============================================================================

REVOKE SELECT ON public.v_shopping_items_usage FROM anon;
ALTER VIEW public.v_shopping_items_usage SET (security_invoker = true);

-- ============================================================================
-- P2: defense in depth para RPCs SECURITY DEFINER
-- Los guards internos (v_uid IS NULL + household_members check) ya impiden
-- dano, pero no queremos depender de que el cuerpo este bien escrito manana.
-- ============================================================================

REVOKE EXECUTE ON FUNCTION public.pay_planned_expense(uuid, numeric, timestamptz, text)
  FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.award_weekly_winner_for_week(uuid, date)
  FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_weekly_ranking_for_week(uuid, date)
  FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_week_processed_for_week(uuid, date)
  FROM anon, PUBLIC;
