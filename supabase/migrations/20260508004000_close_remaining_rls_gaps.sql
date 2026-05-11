-- Security hardening: close 3 remaining RLS gaps identified in audit.
--
-- Gap 1: household_members INSERT allows role='owner'/'admin' directly.
--         Legitimate join always inserts 'member' (RPCs are SECURITY DEFINER
--         and bypass RLS, so they are unaffected by this restriction).
--
-- Gap 2: shopping_items, planned_expenses, expense_templates UPDATE had no
--         WITH CHECK clause — a user in two households could move rows between
--         them (household_id change not blocked).
--
-- Gap 3: notifications INSERT only validated household_id membership, not that
--         the target user_id belongs to the same household — allows notifying
--         users across household boundaries.

-- ============================================================
-- GAP 1: household_members INSERT — restrict to role='member'
-- ============================================================

drop policy if exists "Users can insert own membership" on public.household_members;

create policy "Users can insert own membership"
on public.household_members
for insert
with check (
  user_id = public.current_app_user_id()
  and role = 'member'
);

-- ============================================================
-- GAP 2: cross-household move protection
-- ============================================================

-- shopping_items: add WITH CHECK matching USING
drop policy if exists "household_members_update_shopping" on public.shopping_items;

create policy "household_members_update_shopping"
on public.shopping_items
for update
using  (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

-- planned_expenses: add WITH CHECK matching USING
drop policy if exists "Users can update planned expenses of their household"
  on public.planned_expenses;

create policy "Users can update planned expenses of their household"
on public.planned_expenses
for update
using  (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

-- expense_templates: add WITH CHECK matching USING
drop policy if exists "Users can update templates of their household"
  on public.expense_templates;

create policy "Users can update templates of their household"
on public.expense_templates
for update
using  (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

-- ============================================================
-- GAP 3: notifications INSERT — validate user_id is in household
-- ============================================================

drop policy if exists "Household members can create notifications"
  on public.notifications;

create policy "Household members can create notifications"
on public.notifications
for insert
with check (
  public.is_current_household_member(household_id)
  and exists (
    select 1
    from public.household_members hm
    where hm.household_id = notifications.household_id
      and hm.user_id     = notifications.user_id
  )
);
