create or replace function public.qa_admin_get_household_members(
  p_household_id uuid
)
returns table (
  id uuid,
  user_id uuid,
  household_id uuid,
  role text,
  joined_at timestamptz,
  display_role text,
  email text,
  full_name text,
  avatar_url text,
  mercadopago_alias text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.qa_admin_require_access();

  if not exists (
    select 1
    from public.qa_admin_household_defaults(p_household_id)
    where household_name is not null
  ) then
    raise exception 'Escenario QA invalido';
  end if;

  return query
  select
    hm.id,
    hm.user_id,
    hm.household_id,
    hm.role,
    hm.joined_at,
    hm.display_role,
    u.email,
    u.full_name,
    u.avatar_url,
    u.mercadopago_alias
  from public.household_members hm
  join public.users u on u.id = hm.user_id
  where hm.household_id = p_household_id
  order by
    case when hm.role = 'owner' then 0 else 1 end,
    hm.joined_at,
    u.full_name;
end;
$$;

grant execute on function public.qa_admin_get_household_members(uuid) to authenticated;
