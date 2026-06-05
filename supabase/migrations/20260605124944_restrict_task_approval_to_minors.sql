-- Parent Mode task approvals apply only to children and teens.
--
-- The old `all` mode made adults require approval too, which does not match
-- the product model. Existing households are normalized to `children_only`.

update public.households
set task_approval_mode = 'children_only'
where task_approval_mode = 'all';

alter table public.households
  drop constraint if exists households_task_approval_mode_check;

alter table public.households
  add constraint households_task_approval_mode_check
  check (task_approval_mode in ('off', 'children_only', 'per_member'));

create or replace function public.should_require_task_approval(
  p_household_id uuid,
  p_user_id uuid
)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_mode text;
  v_requires boolean;
  v_member_type text;
begin
  if not public.is_household_premium(p_household_id) then
    return false;
  end if;

  select task_approval_mode into v_mode
  from public.households
  where id = p_household_id;

  if v_mode is null or v_mode = 'off' then
    return false;
  end if;

  select requires_task_approval, member_type
    into v_requires, v_member_type
  from public.household_members
  where household_id = p_household_id
    and user_id = p_user_id;

  if v_mode in ('children_only', 'all') then
    return coalesce(v_member_type in ('child', 'teen'), false);
  end if;

  if v_mode = 'per_member' then
    return coalesce(v_member_type in ('child', 'teen'), false)
      and coalesce(v_requires, false);
  end if;

  return false;
end;
$$;

grant execute on function public.should_require_task_approval(uuid, uuid)
  to authenticated, service_role;

comment on column public.households.task_approval_mode is
  'off | children_only | per_member. Parent Mode approvals only apply to children and teens.';

comment on function public.should_require_task_approval(uuid, uuid) is
  'Premium-gated Parent Mode helper. Returns true only for children/teens that require task approval.';
