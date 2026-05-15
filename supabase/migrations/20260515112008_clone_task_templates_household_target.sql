drop function if exists public.clone_task_templates(uuid, uuid[]);

update public.household_members hm
set
  onboarding_completed = true,
  member_type = coalesce(nullif(hm.member_type, ''), 'parent'),
  display_role = coalesce(nullif(hm.display_role, ''), 'Adulto')
from public.households h
where h.id = hm.household_id
  and h.household_type <> 'family'
  and hm.onboarding_completed = false;

create or replace function public.clone_task_templates(
  p_user_id uuid,
  p_template_ids uuid[] default null::uuid[],
  p_household_id uuid default null::uuid
)
returns integer
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_caller_id uuid;
  v_household_id uuid;
  v_cloned_count integer := 0;
  v_template record;
begin
  v_caller_id := public.current_app_user_id();
  if v_caller_id is null or v_caller_id <> p_user_id then
    raise exception 'Not authorized';
  end if;

  if p_household_id is not null then
    select hm.household_id into v_household_id
    from public.household_members hm
    where hm.user_id = p_user_id
      and hm.household_id = p_household_id
    limit 1;

    if v_household_id is null then
      raise exception 'User is not a member of the requested household';
    end if;
  else
    select hm.household_id into v_household_id
    from public.household_members hm
    where hm.user_id = p_user_id
    order by hm.joined_at desc nulls last
    limit 1;
  end if;

  if v_household_id is null then
    insert into public.households (name)
    values ('Mi Hogar')
    returning id into v_household_id;

    insert into public.household_members (household_id, user_id, role)
    values (v_household_id, p_user_id, 'owner');
  end if;

  for v_template in
    select *
    from public.task_templates
    where p_template_ids is null or id = any(p_template_ids)
    order by category_id, sort_order
  loop
    insert into public.tasks (
      id, household_id, created_by_id, title, category, difficulty,
      xp_reward, coin_reward, status, source_template_id, title_key
    ) values (
      gen_random_uuid(), v_household_id, p_user_id, v_template.title,
      v_template.category_id, v_template.difficulty, v_template.xp_reward,
      v_template.coin_reward, 'active', v_template.id, v_template.translation_key
    );
    v_cloned_count := v_cloned_count + 1;
  end loop;

  return v_cloned_count;
end;
$$;

revoke execute on function public.clone_task_templates(uuid, uuid[], uuid)
from public, anon;
grant execute on function public.clone_task_templates(uuid, uuid[], uuid)
to authenticated;
