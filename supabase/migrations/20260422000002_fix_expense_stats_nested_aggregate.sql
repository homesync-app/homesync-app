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
    (select jsonb_agg(row_to_json(sub)::jsonb)
     from (
       select coalesce(e.category, 'general') as category,
              sum(e.amount) as total_amount,
              count(*) as count
       from expenses e
       where e.household_id = v_household_id
         and e.type = 'expense'
         and coalesce(e.is_shared, true) = true
       group by e.category
     ) sub),
    '[]'::jsonb
  );
end;
$$;
