-- Reconstructed from remote migration history (version 20260508215618).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Gap 1: household_members INSERT Ã”Ã‡Ã¶ restrict to role='member' only
drop policy if exists "Users can insert own membership" on public.household_members;

create policy "Users can insert own membership"
on public.household_members
for insert
with check (
  user_id = public.current_app_user_id()
  and role = 'member'
);

-- Gap 2: cross-household move Ã”Ã‡Ã¶ add WITH CHECK to shopping_items, planned_expenses, expense_templates
drop policy if exists "household_members_update_shopping" on public.shopping_items;

create policy "household_members_update_shopping"
on public.shopping_items
for update
using  (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can update planned expenses of their household" on public.planned_expenses;

create policy "Users can update planned expenses of their household"
on public.planned_expenses
for update
using  (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can update templates of their household" on public.expense_templates;

create policy "Users can update templates of their household"
on public.expense_templates
for update
using  (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

-- Gap 3: notifications INSERT Ã”Ã‡Ã¶ validate user_id is member of the same household
drop policy if exists "Household members can create notifications" on public.notifications;

create policy "Household members can create notifications"
on public.notifications
for insert
with check (
  public.is_current_household_member(household_id)
  and exists (
    select 1
    from public.household_members hm
    where hm.household_id = notifications.household_id
      and hm.user_id      = notifications.user_id
  )
);
;