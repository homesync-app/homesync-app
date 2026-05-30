-- Reconstructed from remote migration history (version 20260421144933).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

create or replace function public.get_expense_stats_by_category(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_household_id uuid;
begin
  select household_id into v_household_id
  from household_members
  where user_id = p_user_id
  limit 1;

  if v_household_id is null then
    return '[]'::jsonb;
  end if;

  return coalesce(
    (select jsonb_agg(jsonb_build_object(
      'category', coalesce(e.category, 'general'),
      'total_amount', sum(e.amount),
      'count', count(*)
    ))
    from expenses e
    where e.household_id = v_household_id
      and e.type = 'expense'
      and coalesce(e.is_shared, true) = true
    group by e.category),
    '[]'::jsonb
  );
end;
$$;
