create or replace function public.get_my_household_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select household_id
  from public.household_members
  where user_id = public.current_app_user_id();
$$;

comment on function public.get_my_household_ids() is
  'Returns household ids for the current authenticated app user, compatible with Supabase Auth and Firebase-backed identity.';

create or replace function public.is_current_household_member(target_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = target_household_id
      and hm.user_id = public.current_app_user_id()
  );
$$;

comment on function public.is_current_household_member(uuid) is
  'Checks whether the current authenticated app user belongs to the given household.';

create or replace function public.is_current_household_owner(target_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = target_household_id
      and hm.user_id = public.current_app_user_id()
      and hm.role = 'owner'
  );
$$;

comment on function public.is_current_household_owner(uuid) is
  'Checks whether the current authenticated app user is an owner of the given household.';

drop policy if exists "Users can insert own profile" on public.users;
create policy "Users can insert own profile"
on public.users
for insert
with check (public.current_app_user_id() = id);

drop policy if exists "Users can update own profile" on public.users;
create policy "Users can update own profile"
on public.users
for update
using (public.current_app_user_id() = id);

drop policy if exists "Users can view household member profiles" on public.users;
create policy "Users can view household member profiles"
on public.users
for select
using (
  public.current_app_user_id() = id
  or id in (
    select hm2.user_id
    from public.household_members hm1
    join public.household_members hm2
      on hm1.household_id = hm2.household_id
    where hm1.user_id = public.current_app_user_id()
  )
);

drop policy if exists "Users can insert own membership" on public.household_members;
create policy "Users can insert own membership"
on public.household_members
for insert
with check (user_id = public.current_app_user_id());

drop policy if exists "Users can update own membership" on public.household_members;
create policy "Users can update own membership"
on public.household_members
for update
using (user_id = public.current_app_user_id());

drop policy if exists "Users can delete own membership" on public.household_members;
create policy "Users can delete own membership"
on public.household_members
for delete
using (user_id = public.current_app_user_id());

drop policy if exists "Users can create households" on public.households;
create policy "Users can create households"
on public.households
for insert
with check (public.current_app_user_id() is not null);

drop policy if exists "Users can view their households" on public.households;
create policy "Users can view their households"
on public.households
for select
using (public.is_current_household_member(id));

drop policy if exists "Owners can update households" on public.households;
create policy "Owners can update households"
on public.households
for update
using (public.is_current_household_owner(id));

drop policy if exists "Owners can delete households" on public.households;
create policy "Owners can delete households"
on public.households
for delete
using (public.is_current_household_owner(id));

drop policy if exists "Users can view household tasks" on public.tasks;
create policy "Users can view household tasks"
on public.tasks
for select
using (public.is_current_household_member(household_id));

drop policy if exists "Users can create tasks" on public.tasks;
create policy "Users can create tasks"
on public.tasks
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can update tasks" on public.tasks;
create policy "Users can update tasks"
on public.tasks
for update
using (public.is_current_household_member(household_id));

drop policy if exists "Owners can delete tasks" on public.tasks;
create policy "Owners can delete tasks"
on public.tasks
for delete
using (public.is_current_household_owner(household_id));

drop policy if exists "Users can create expenses" on public.expenses;
create policy "Users can create expenses"
on public.expenses
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can update own expenses" on public.expenses;
create policy "Users can update own expenses"
on public.expenses
for update
using (created_by_id = public.current_app_user_id());

drop policy if exists "Owners and creators can delete expenses" on public.expenses;
create policy "Owners and creators can delete expenses"
on public.expenses
for delete
using (
  public.is_current_household_owner(household_id)
  or created_by_id = public.current_app_user_id()
);

drop policy if exists "Users can view visible household expenses" on public.expenses;
create policy "Users can view visible household expenses"
on public.expenses
for select
using (
  public.is_current_household_member(household_id)
  and (
    coalesce(
      is_shared,
      case
        when lower(coalesce(split_type, 'equal')) = any (array['personal', 'gift']) then false
        else true
      end
    ) = true
    or paid_by = public.current_app_user_id()
    or created_by_id = public.current_app_user_id()
  )
);

drop policy if exists "Household members can create notifications" on public.notifications;
create policy "Household members can create notifications"
on public.notifications
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can view their own notifications" on public.notifications;
create policy "Users can view their own notifications"
on public.notifications
for select
using (user_id = public.current_app_user_id());

drop policy if exists "Users can update their own notifications" on public.notifications;
create policy "Users can update their own notifications"
on public.notifications
for update
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());

drop policy if exists "Users can delete their own notifications" on public.notifications;
create policy "Users can delete their own notifications"
on public.notifications
for delete
using (user_id = public.current_app_user_id());

drop policy if exists "household_members_select_shopping" on public.shopping_items;
create policy "household_members_select_shopping"
on public.shopping_items
for select
using (public.is_current_household_member(household_id));

drop policy if exists "household_members_insert_shopping" on public.shopping_items;
create policy "household_members_insert_shopping"
on public.shopping_items
for insert
with check (
  public.is_current_household_member(household_id)
  and added_by = public.current_app_user_id()
);

drop policy if exists "household_members_update_shopping" on public.shopping_items;
create policy "household_members_update_shopping"
on public.shopping_items
for update
using (public.is_current_household_member(household_id));

drop policy if exists "household_members_delete_shopping" on public.shopping_items;
create policy "household_members_delete_shopping"
on public.shopping_items
for delete
using (public.is_current_household_member(household_id));

drop policy if exists "Users can view own ledger" on public.ledger_entries;
create policy "Users can view own ledger"
on public.ledger_entries
for select
using (user_id = public.current_app_user_id());

drop policy if exists "Household members can view all ledger" on public.ledger_entries;
create policy "Household members can view all ledger"
on public.ledger_entries
for select
using (public.is_current_household_member(household_id));

drop policy if exists "users_view_household_activities" on public.household_activities;
create policy "users_view_household_activities"
on public.household_activities
for select
using (
  public.is_current_household_member(household_id)
  and (
    is_shared = true
    or user_id = public.current_app_user_id()
    or (metadata ->> 'split_type') = 'gift'
    or (metadata ->> 'split_type') = 'regalo'
  )
);

drop policy if exists "Users can create splits" on public.expense_splits;
create policy "Users can create splits"
on public.expense_splits
for insert
with check (
  expense_id in (
    select e.id
    from public.expenses e
    where public.is_current_household_member(e.household_id)
  )
);

drop policy if exists "Users can view visible expense splits" on public.expense_splits;
create policy "Users can view visible expense splits"
on public.expense_splits
for select
using (
  exists (
    select 1
    from public.expenses e
    where e.id = expense_splits.expense_id
      and public.is_current_household_member(e.household_id)
      and (
        coalesce(
          e.is_shared,
          case
            when lower(coalesce(e.split_type, 'equal')) = any (array['personal', 'gift']) then false
            else true
          end
        ) = true
        or e.paid_by = public.current_app_user_id()
        or e.created_by_id = public.current_app_user_id()
      )
  )
);

drop policy if exists "Users can view planned expenses of their household" on public.planned_expenses;
create policy "Users can view planned expenses of their household"
on public.planned_expenses
for select
using (
  public.is_current_household_member(household_id)
  and (
    split_type <> 'personal'
    or payer_default = public.current_app_user_id()
  )
);

drop policy if exists "Users can insert planned expenses to their household" on public.planned_expenses;
create policy "Users can insert planned expenses to their household"
on public.planned_expenses
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can update planned expenses of their household" on public.planned_expenses;
create policy "Users can update planned expenses of their household"
on public.planned_expenses
for update
using (public.is_current_household_member(household_id));

drop policy if exists "Users can view templates of their household" on public.expense_templates;
create policy "Users can view templates of their household"
on public.expense_templates
for select
using (
  public.is_current_household_member(household_id)
  and (
    split_type <> 'personal'
    or payer_default = public.current_app_user_id()
  )
);

drop policy if exists "Users can insert templates to their household" on public.expense_templates;
create policy "Users can insert templates to their household"
on public.expense_templates
for insert
with check (public.is_current_household_member(household_id));

drop policy if exists "Users can update templates of their household" on public.expense_templates;
create policy "Users can update templates of their household"
on public.expense_templates
for update
using (public.is_current_household_member(household_id));

drop policy if exists "Users can create redemptions" on public.reward_redemptions;
create policy "Users can create redemptions"
on public.reward_redemptions
for insert
with check (user_id = public.current_app_user_id());

drop policy if exists "Users can view own redemptions" on public.reward_redemptions;
create policy "Users can view own redemptions"
on public.reward_redemptions
for select
using (
  user_id = public.current_app_user_id()
  or public.is_current_household_member(household_id)
);

drop policy if exists "Users can view household rewards" on public.rewards;
create policy "Users can view household rewards"
on public.rewards
for select
using (public.is_current_household_member(household_id));

drop policy if exists "Owners can insert rewards" on public.rewards;
create policy "Owners can insert rewards"
on public.rewards
for insert
with check (public.is_current_household_owner(household_id));

drop policy if exists "Owners can update rewards" on public.rewards;
create policy "Owners can update rewards"
on public.rewards
for update
using (public.is_current_household_owner(household_id))
with check (public.is_current_household_owner(household_id));

drop policy if exists "Owners can delete rewards" on public.rewards;
create policy "Owners can delete rewards"
on public.rewards
for delete
using (public.is_current_household_owner(household_id));
