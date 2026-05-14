create or replace function public.delete_expense_v1(
  p_expense_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
  v_household_id uuid;
  v_created_by_id uuid;
  v_rows_deleted integer := 0;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  select e.household_id, e.created_by_id
  into v_household_id, v_created_by_id
  from public.expenses e
  where e.id = p_expense_id;

  if v_household_id is null then
    raise exception 'Expense not found';
  end if;

  if not (
    v_created_by_id = v_uid
    or public.is_current_household_owner(v_household_id)
  ) then
    raise exception 'Expense not found or not owned by user';
  end if;

  delete from public.household_activities ha
  where ha.household_id = v_household_id
    and ha.event_type = 'expense_added'
    and (
      ha.metadata ->> 'expense_id' = p_expense_id::text
      or ha.metadata ->> 'id' = p_expense_id::text
    );

  delete from public.notifications n
  where n.household_id = v_household_id
    and n.related_entity_type = 'expense'
    and n.related_entity_id = p_expense_id;

  delete from public.expenses e
  where e.id = p_expense_id
    and e.household_id = v_household_id;

  get diagnostics v_rows_deleted = row_count;
  if v_rows_deleted = 0 then
    raise exception 'Expense not deleted';
  end if;
end;
$$;

grant execute on function public.delete_expense_v1(uuid) to authenticated;
