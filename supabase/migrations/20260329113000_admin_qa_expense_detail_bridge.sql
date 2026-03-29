create or replace function public.qa_admin_get_expense_with_splits(
  p_expense_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_household_id uuid;
  v_result jsonb;
begin
  perform public.qa_admin_require_access();

  select e.household_id
    into v_household_id
  from public.expenses e
  where e.id = p_expense_id;

  if v_household_id is null then
    raise exception 'Expense not found';
  end if;

  if not exists (
    select 1
    from public.qa_admin_household_defaults(v_household_id)
    where household_name is not null
  ) then
    raise exception 'Expense does not belong to a QA scenario household';
  end if;

  select jsonb_build_object(
    'id', e.id,
    'household_id', e.household_id,
    'created_by_id', e.created_by_id,
    'title', e.title,
    'description', e.description,
    'amount', e.amount,
    'category', e.category,
    'paid_by', e.paid_by,
    'paid_at', e.paid_at,
    'type', e.type,
    'split_type', e.split_type,
    'is_shared', e.is_shared,
    'created_at', e.created_at,
    'updated_at', e.updated_at,
    'expense_splits', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', es.id,
          'expense_id', es.expense_id,
          'user_id', es.user_id,
          'amount', es.amount,
          'created_at', es.created_at,
          'users', jsonb_build_object(
            'email', u.email,
            'full_name', u.full_name,
            'avatar_url', u.avatar_url
          )
        )
      )
      from public.expense_splits es
      left join public.users u on u.id = es.user_id
      where es.expense_id = e.id
    ), '[]'::jsonb)
  )
    into v_result
  from public.expenses e
  where e.id = p_expense_id;

  if v_result is null then
    raise exception 'Expense not found';
  end if;

  return v_result;
end;
$$;

grant execute on function public.qa_admin_get_expense_with_splits(uuid) to authenticated;
