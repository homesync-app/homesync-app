-- Modo Padres: update seguro del flag per-member sin UPDATE directo desde UI.

create or replace function public.update_member_task_approval(
  p_household_member_id uuid,
  p_requires_task_approval boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller uuid := public.current_app_user_id();
  v_target record;
begin
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select
    hm.id,
    hm.household_id,
    h.household_type
  into v_target
  from public.household_members hm
  join public.households h on h.id = hm.household_id
  where hm.id = p_household_member_id;

  if v_target.id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Member not found',
      'status', 'not_found'
    );
  end if;

  if v_target.household_type <> 'family' then
    return jsonb_build_object(
      'success', false,
      'message', 'Only family households can use parent mode',
      'status', 'invalid_household_type'
    );
  end if;

  if not public.is_household_premium(v_target.household_id) then
    return jsonb_build_object(
      'success', false,
      'message', 'Parent mode requires household premium',
      'status', 'premium_required'
    );
  end if;

  if not exists (
    select 1
    from public.household_members caller
    where caller.household_id = v_target.household_id
      and caller.user_id = v_caller
      and caller.role in ('owner', 'admin')
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only admins can update task approval settings',
      'status', 'forbidden'
    );
  end if;

  update public.household_members
  set requires_task_approval = p_requires_task_approval
  where id = p_household_member_id;

  return jsonb_build_object(
    'success', true,
    'member_id', p_household_member_id,
    'requires_task_approval', p_requires_task_approval
  );
end;
$$;

revoke execute on function public.update_member_task_approval(uuid, boolean)
  from public;
revoke execute on function public.update_member_task_approval(uuid, boolean)
  from anon;

grant execute on function public.update_member_task_approval(uuid, boolean)
  to authenticated, service_role;

comment on function public.update_member_task_approval(uuid, boolean) is
  'Modo Padres: owner/admin de family premium actualiza household_members.requires_task_approval via RPC.';
