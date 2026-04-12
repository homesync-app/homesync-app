create or replace function public.finance_process_recurring_expenses_internal(
  p_household_id uuid
)
returns void
language plpgsql
set search_path = public
as $$
declare
  v_horizon date := (
    date_trunc('month', current_date)::date + interval '2 month - 1 day'
  )::date;
  template_row record;
  v_next_due date;
begin
  for template_row in
    select *
    from public.expense_templates
    where household_id = p_household_id
      and is_active = true
      and coalesce(frequency, 'monthly') = 'monthly'
    order by created_at asc
  loop
    v_next_due := coalesce(
      template_row.next_execution_date::date,
      public.finance_first_valid_monthly_due_date(current_date, template_row.day_of_month)
    );

    while v_next_due <= v_horizon loop
      insert into public.planned_expenses (
        household_id,
        template_id,
        title,
        amount,
        category,
        split_type,
        payer_default,
        due_date,
        status
      ) values (
        template_row.household_id,
        template_row.id,
        template_row.title,
        template_row.default_amount,
        template_row.category,
        template_row.split_type,
        template_row.payer_default,
        v_next_due,
        'pending'
      )
      on conflict (template_id, due_date) do nothing;

      v_next_due := public.finance_next_monthly_due_date(
        v_next_due,
        template_row.day_of_month
      );
    end loop;

    update public.expense_templates
    set
      next_execution_date = v_next_due::timestamptz,
      updated_at = timezone('utc'::text, now())
    where id = template_row.id
      and next_execution_date is distinct from v_next_due::timestamptz;
  end loop;
end;
$$;

create or replace function public.process_recurring_expenses(
  p_household_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_current_household_member(p_household_id) then
    raise exception 'User is not a member of this household';
  end if;

  perform public.finance_process_recurring_expenses_internal(p_household_id);
end;
$$;

create or replace function public.qa_admin_process_recurring_expenses(
  p_household_id uuid
)
returns void
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

  perform public.finance_process_recurring_expenses_internal(p_household_id);
end;
$$;

grant execute on function public.process_recurring_expenses(uuid) to authenticated;
grant execute on function public.qa_admin_process_recurring_expenses(uuid) to authenticated;
