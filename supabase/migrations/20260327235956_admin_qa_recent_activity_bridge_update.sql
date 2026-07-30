-- Reconstructed from remote migration history (version 20260327235956).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

create or replace function public.qa_admin_get_recent_activity(
  p_household_id uuid,
  p_since timestamptz default null
)
returns table (
  id uuid,
  event_type text,
  title text,
  description text,
  metadata jsonb,
  created_at timestamptz,
  user_id uuid,
  "user" jsonb
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
    ha.id,
    ha.event_type,
    ha.title,
    ha.description,
    ha.metadata,
    ha.created_at,
    ha.user_id,
    jsonb_build_object(
      'id', u.id,
      'full_name', u.full_name,
      'avatar_url', u.avatar_url
    ) as "user"
  from public.household_activities ha
  left join public.users u on u.id = ha.user_id
  where ha.household_id = p_household_id
    and (p_since is null or ha.created_at >= p_since)
  order by ha.created_at desc
  limit 30;
end;
$$;

grant execute on function public.qa_admin_get_recent_activity(uuid, timestamptz) to authenticated;
