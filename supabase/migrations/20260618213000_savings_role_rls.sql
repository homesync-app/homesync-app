-- Role-aware RLS for savings goals & contributions.
--
-- Product rule:
--  * couple / solo / friends: any household member manages goals (unchanged).
--  * family: only adults (parent/guardian) may create/edit/delete goals;
--    children may not contribute (teens may, adults may).
--
-- Identity + membership resolve through the existing Firebase bridge helpers
-- (current_app_user_id / is_current_household_member). The RESTRICTIVE
-- valid-JWT policies are left untouched and continue to AND with these.

-- Can the current app user MANAGE goals in this household (create/edit/delete)?
create or replace function public.is_household_savings_manager(target_household_id uuid)
returns boolean
language sql stable security definer set search_path to 'public' as $$
  select exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.household_id = target_household_id
      and hm.user_id = public.current_app_user_id()
      and (
        h.household_type is distinct from 'family'
        or coalesce(hm.member_type, 'parent') in ('adult', 'parent', 'guardian')
      )
  );
$$;

-- Can the current app user CONTRIBUTE to goals in this household?
-- Same as manager, but teens are allowed too (children are not).
create or replace function public.is_household_savings_contributor(target_household_id uuid)
returns boolean
language sql stable security definer set search_path to 'public' as $$
  select exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.household_id = target_household_id
      and hm.user_id = public.current_app_user_id()
      and (
        h.household_type is distinct from 'family'
        or coalesce(hm.member_type, 'parent') in ('adult', 'parent', 'guardian', 'teen')
      )
  );
$$;

-- The contribution trigger maintains derived fields (current_amount,
-- completed_at) on savings_goals. It must NOT be gated by the goal UPDATE
-- policy, otherwise a teen's allowed contribution would fail when the trigger
-- tries to bump the goal. Make it SECURITY DEFINER so this internal
-- maintenance bypasses RLS.
create or replace function public.update_goal_current_amount()
returns trigger
language plpgsql security definer set search_path to 'public' as $$
declare
  v_goal_id uuid;
begin
  if (TG_OP = 'INSERT') then
    v_goal_id := NEW.goal_id;
    update public.savings_goals
    set current_amount = current_amount + NEW.amount,
        updated_at = now()
    where id = v_goal_id;
  elsif (TG_OP = 'DELETE') then
    v_goal_id := OLD.goal_id;
    update public.savings_goals
    set current_amount = current_amount - OLD.amount,
        updated_at = now()
    where id = v_goal_id;
  end if;

  update public.savings_goals
  set completed_at = case
        when current_amount >= target_amount and completed_at is null then now()
        when current_amount < target_amount then null
        else completed_at
      end
  where id = v_goal_id;

  return null;
end;
$$;

-- savings_goals: gate create / edit / delete by manager role. SELECT stays
-- open to all members (everyone can view goals).
drop policy if exists "Members can insert household goals" on public.savings_goals;
create policy "Members can insert household goals"
  on public.savings_goals for insert to public
  with check (public.is_household_savings_manager(household_id));

drop policy if exists "Members can update household goals" on public.savings_goals;
create policy "Members can update household goals"
  on public.savings_goals for update to public
  using (public.is_household_savings_manager(household_id))
  with check (public.is_household_savings_manager(household_id));

drop policy if exists "Members can delete household goals" on public.savings_goals;
create policy "Members can delete household goals"
  on public.savings_goals for delete to public
  using (public.is_household_savings_manager(household_id));

-- savings_contributions: the contributor must be themselves, be allowed to
-- contribute (excludes children in family), and belong to the goal's household
-- (also closes a prior gap where membership was not checked on insert).
drop policy if exists "Users can add their own contributions" on public.savings_contributions;
create policy "Users can add their own contributions"
  on public.savings_contributions for insert to public
  with check (
    user_id = public.current_app_user_id()
    and exists (
      select 1
      from public.savings_goals g
      where g.id = savings_contributions.goal_id
        and public.is_household_savings_contributor(g.household_id)
    )
  );
