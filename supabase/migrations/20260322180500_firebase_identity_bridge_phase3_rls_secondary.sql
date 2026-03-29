drop policy if exists "Authenticated users can insert own logs" on public.application_logs;
create policy "Authenticated users can insert own logs"
on public.application_logs
for insert
with check (
  public.current_app_user_id() is not null
  and (user_id is null or user_id = public.current_app_user_id())
);

drop policy if exists "Users can delete own logs" on public.application_logs;
create policy "Users can delete own logs"
on public.application_logs
for delete
using (user_id = public.current_app_user_id());

drop policy if exists "Users can create audits" on public.audit_logs;
create policy "Users can create audits"
on public.audit_logs
for insert
with check (
  user_id = public.current_app_user_id()
  or public.is_current_household_member(household_id)
);

drop policy if exists "Users can view household audits" on public.audit_logs;
create policy "Users can view household audits"
on public.audit_logs
for select
using (public.is_current_household_member(household_id));

drop policy if exists "Users can insert template history to their household" on public.expense_template_history;
create policy "Users can insert template history to their household"
on public.expense_template_history
for insert
with check (
  exists (
    select 1
    from public.expense_templates t
    where t.id = expense_template_history.template_id
      and public.is_current_household_member(t.household_id)
  )
);

drop policy if exists "Users can view template history of their household" on public.expense_template_history;
create policy "Users can view template history of their household"
on public.expense_template_history
for select
using (
  exists (
    select 1
    from public.expense_templates t
    where t.id = expense_template_history.template_id
      and public.is_current_household_member(t.household_id)
  )
);

drop policy if exists "Owners can create invitations" on public.household_invitations;
create policy "Owners can create invitations"
on public.household_invitations
for insert
with check (public.is_current_household_owner(household_id));

drop policy if exists "Users can view invitations" on public.household_invitations;
create policy "Users can view invitations"
on public.household_invitations
for select
using (
  created_by = public.current_app_user_id()
  or used_by = public.current_app_user_id()
  or public.is_current_household_member(household_id)
);

drop policy if exists "Users can create keys" on public.idempotency_keys;
create policy "Users can create keys"
on public.idempotency_keys
for insert
with check (user_id = public.current_app_user_id());

drop policy if exists "Users can view own keys" on public.idempotency_keys;
create policy "Users can view own keys"
on public.idempotency_keys
for select
using (user_id = public.current_app_user_id());

drop policy if exists "Users can manage their own connections" on public.mercadopago_connections;
create policy "Users can manage their own connections"
on public.mercadopago_connections
for all
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());

drop policy if exists "Users can add their own contributions" on public.savings_contributions;
create policy "Users can add their own contributions"
on public.savings_contributions
for insert
with check (user_id = public.current_app_user_id());

drop policy if exists "Members can view household contributions" on public.savings_contributions;
create policy "Members can view household contributions"
on public.savings_contributions
for select
using (
  exists (
    select 1
    from public.savings_goals g
    where g.id = savings_contributions.goal_id
      and public.is_current_household_member(g.household_id)
  )
);

drop policy if exists "Members can view household goals" on public.savings_goals;
create policy "Members can view household goals"
on public.savings_goals
for select
using (public.is_current_household_member(household_id));

drop policy if exists "Members can insert household goals" on public.savings_goals;
create policy "Members can insert household goals"
on public.savings_goals
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Members can update household goals" on public.savings_goals;
create policy "Members can update household goals"
on public.savings_goals
for update
using (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

drop policy if exists "Members can delete household goals" on public.savings_goals;
create policy "Members can delete household goals"
on public.savings_goals
for delete
using (public.is_current_household_member(household_id));

drop policy if exists "Users can create events" on public.system_events;
create policy "Users can create events"
on public.system_events
for insert
with check (
  user_id = public.current_app_user_id()
  or public.is_current_household_member(household_id)
);

drop policy if exists "Users can view household events" on public.system_events;
create policy "Users can view household events"
on public.system_events
for select
using (public.is_current_household_member(household_id));

drop policy if exists "Members can insert duel history" on public.weekly_duel_history;
create policy "Members can insert duel history"
on public.weekly_duel_history
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Members can view duel history" on public.weekly_duel_history;
create policy "Members can view duel history"
on public.weekly_duel_history
for select
using (public.is_current_household_member(household_id));

drop policy if exists "Members can insert weekly winners" on public.weekly_winners;
create policy "Members can insert weekly winners"
on public.weekly_winners
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Members can view their household winners" on public.weekly_winners;
create policy "Members can view their household winners"
on public.weekly_winners
for select
using (public.is_current_household_member(household_id));
