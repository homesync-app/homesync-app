-- Reconstructed from remote migration history (version 20260524224831).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Parent Mode task approvals are premium-only.
-- Keep the server as the source of truth so old clients cannot submit
-- completions into the approval queue after premium is disabled.

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

  if v_mode = 'all' then
    return true;
  end if;

  select requires_task_approval, member_type
    into v_requires, v_member_type
  from public.household_members
  where household_id = p_household_id
    and user_id = p_user_id;

  if v_mode = 'children_only' then
    return coalesce(v_member_type in ('child', 'teen'), false);
  end if;

  if v_mode = 'per_member' then
    return coalesce(v_requires, false);
  end if;

  return false;
end;
$$;

grant execute on function public.should_require_task_approval(uuid, uuid)
  to authenticated, service_role;

comment on function public.should_require_task_approval(uuid, uuid) is
  'Premium-gated Parent Mode helper. Returns true only for family task approval modes when the household has active premium.';
