-- Consolida politicas permissive duplicadas (advisor multiple_permissive_policies)
-- en las dos tablas con overlap cross-role. Semantica identica por construccion:
-- la nueva politica es el OR literal de las quals anteriores, scopeada a
-- authenticated (anon nunca tuvo acceso real: current_app_user_id() le es
-- EXECUTE-denied; service_role bypassea RLS).
-- Smoke SQL antes/despues (2026-07-19): usuario real ve 295 ledger_entries y
-- 24 task_approvals en ambos estados; anon ve 0/0; INSERT directo como
-- authenticated sigue negado (42501).
-- Aplicada a prod via MCP el 2026-07-19.

-- ledger_entries: 3 politicas SELECT -> 1
drop policy "Household members can view all ledger" on public.ledger_entries;
drop policy "Users can view own ledger" on public.ledger_entries;
drop policy "admins can read ledger_entries" on public.ledger_entries;
create policy "ledger_entries_select" on public.ledger_entries
  for select to authenticated
  using (
    is_current_household_member(household_id)
    or user_id = current_app_user_id()
    or is_current_app_admin()
  );

-- task_approvals: la politica ALL con qual/check false era un no-op (una politica
-- permissive con false no otorga nada; los writes directos siguen negados por
-- default-deny al no existir ninguna politica permissive de INSERT/UPDATE/DELETE).
drop policy "task_approvals_no_direct_write" on public.task_approvals;
drop policy "task_approvals_household_read" on public.task_approvals;
create policy "task_approvals_household_read" on public.task_approvals
  for select to authenticated
  using (is_current_household_member(household_id));
