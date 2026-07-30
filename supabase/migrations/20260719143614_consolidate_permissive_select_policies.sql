-- Consolida las politicas SELECT permissive duplicadas restantes (advisor
-- multiple_permissive_policies). Mismo criterio que 20260719120500: OR literal
-- de las quals existentes, scope TO authenticated. En Postgres las USING
-- permissive ya se evaluan como OR, asi que la visibilidad es identica por
-- construccion. Verificado con snapshots SQL antes/despues para un usuario real
-- y un admin (13 tablas, counts byte-identicos). El overlap de UPDATE en
-- household_members queda para sesion supervisada (no se toca).
-- Aplicada a prod via MCP el 2026-07-19.
-- NOTA de seguridad pendiente (no tocada aca): application_logs es legible por
-- CUALQUIER usuario autenticado (qual=true, 101k filas). Decidir si debe ser
-- solo-admin; cambiarlo altera comportamiento y requiere revisar que la app no
-- lea sus propios logs.

-- 4 tablas donde la politica de miembros es qual=true: la politica admin es
-- estrictamente redundante; alcanza con borrarla.
drop policy "admins can read application_logs" on public.application_logs;
drop policy "admins can read categories" on public.categories;
drop policy "admins can read reward_templates" on public.reward_templates;
drop policy "admins can read task_templates" on public.task_templates;

-- error_issues
drop policy "admins can read error issues" on public.error_issues;
drop policy "admins can read error_issues" on public.error_issues;
create policy "error_issues_select" on public.error_issues
  for select to authenticated
  using ((select is_error_issue_admin()) or is_current_app_admin());

-- household_activities
drop policy "admins can read household_activities" on public.household_activities;
drop policy "users_view_household_activities" on public.household_activities;
create policy "household_activities_select" on public.household_activities
  for select to authenticated
  using (
    is_current_app_admin()
    or (
      is_current_household_member(household_id)
      and (
        is_shared = true
        or user_id = current_app_user_id()
        or (metadata ->> 'split_type') = 'gift'
        or (metadata ->> 'split_type') = 'regalo'
      )
    )
  );

-- household_members (solo SELECT; el overlap de UPDATE queda documentado)
drop policy "Members can view same household members" on public.household_members;
drop policy "admins can read household members" on public.household_members;
create policy "household_members_select" on public.household_members
  for select to authenticated
  using (
    is_current_app_admin()
    or household_id in (select get_my_household_ids())
  );

-- households
drop policy "Users can view their households" on public.households;
drop policy "admins can read households" on public.households;
create policy "households_select" on public.households
  for select to authenticated
  using (is_current_app_admin() or is_current_household_member(id));

-- ocr_scan_logs
drop policy "admins can read ocr_scan_logs" on public.ocr_scan_logs;
drop policy "users select own logs" on public.ocr_scan_logs;
create policy "ocr_scan_logs_select" on public.ocr_scan_logs
  for select to authenticated
  using (is_current_app_admin() or user_id = current_app_user_id());

-- shopping_items
drop policy "admins can read shopping_items" on public.shopping_items;
drop policy "household_members_select_shopping" on public.shopping_items;
create policy "shopping_items_select" on public.shopping_items
  for select to authenticated
  using (is_current_app_admin() or is_current_household_member(household_id));

-- tasks
drop policy "Users can view household tasks" on public.tasks;
drop policy "admins can read tasks" on public.tasks;
create policy "tasks_select" on public.tasks
  for select to authenticated
  using (is_current_app_admin() or is_current_household_member(household_id));

-- user_feedback_responses
drop policy "admins can read feedback responses" on public.user_feedback_responses;
drop policy "users can read own feedback responses" on public.user_feedback_responses;
create policy "user_feedback_responses_select" on public.user_feedback_responses
  for select to authenticated
  using (
    is_current_app_admin()
    or exists (
      select 1
      from user_feedback f
      where f.id = user_feedback_responses.feedback_id
        and f.user_id = (current_app_user_id())::text
    )
  );

-- users
drop policy "Users can view household member profiles" on public.users;
drop policy "admins can read users" on public.users;
create policy "users_select" on public.users
  for select to authenticated
  using (
    is_current_app_admin()
    or current_app_user_id() = id
    or id in (
      select hm2.user_id
      from household_members hm1
      join household_members hm2 on hm1.household_id = hm2.household_id
      where hm1.user_id = current_app_user_id()
    )
  );
