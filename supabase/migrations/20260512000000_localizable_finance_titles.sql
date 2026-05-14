alter table public.expense_templates
  add column if not exists title_key text;

alter table public.planned_expenses
  add column if not exists title_key text;

alter table public.expenses
  add column if not exists title_key text;

comment on column public.expense_templates.title_key is
  'ARB key for localizing known recurring finance template titles. Null means display title as user-authored text.';
comment on column public.planned_expenses.title_key is
  'ARB key copied from the recurring template, or inferred for known planned expense titles.';
comment on column public.expenses.title_key is
  'ARB key inferred for known finance movement titles. Null means display title as user-authored text.';

create or replace function public.finance_title_key_for(
  p_title text,
  p_category text default null,
  p_transaction_type text default null
)
returns text
language sql
immutable
set search_path = public
as $$
  with normalized as (
    select
      regexp_replace(
        translate(
          lower(trim(coalesce(p_title, ''))),
          'áàäéèëíïóöúüñ',
          'aaaeeeiioouun'
        ),
        '\s+',
        ' ',
        'g'
      ) as title,
      regexp_replace(
        translate(
          lower(trim(coalesce(p_category, ''))),
          'áàäéèëíïóöúüñ',
          'aaaeeeiioouun'
        ),
        '\s+',
        ' ',
        'g'
      ) as category,
      lower(trim(coalesce(p_transaction_type, ''))) as transaction_type
  )
  select case
    when transaction_type = 'settlement'
      or title in ('liquidacion de balance', 'liquidacion de saldo', 'liquidacion de deuda')
      then 'financeTitleBalanceSettlement'
    when title = 'liquidacion de pareja'
      then 'financeTitlePartnerSettlement'
    when category in ('supermarket', 'groceries')
      and (
        title like '%supermerc%'
        or title like '%supermarket%'
        or title like '%compras del%'
        or title like '%compra del%'
        or title like '%compra de supermercado%'
      )
      then 'financeTitleSupermarket'
    when category = 'mercadolibre'
      or title in ('mercadolibre', 'mercado libre')
      or title like '%compras online%'
      then 'financeTitleOnlineShopping'
    when title in ('sueldo', 'salario', 'salary')
      then 'financeTitleSalary'
    when title in ('alquiler', 'alquler', 'rent')
      then 'financeTitleRent'
    when title in ('expensas', 'building fees')
      then 'financeTitleBuildingFees'
    when title = 'gas'
      then 'financeTitleGas'
    when title in ('luz', 'electricidad', 'electricity')
      then 'financeTitleElectricity'
    when title in ('agua', 'water')
      then 'financeTitleWater'
    when title = 'internet'
      then 'financeTitleInternet'
    when title = 'netflix'
      then 'financeTitleNetflix'
    when title in ('pelis', 'peliculas', 'movies')
      then 'financeTitleMovies'
    when title in ('seguro', 'srguro', 'insurance')
      then 'financeTitleInsurance'
    when title in ('celu', 'celular', 'celu blas', 'phone')
      then 'financeTitlePhone'
    else null
  end
  from normalized;
$$;

create or replace function public.set_finance_title_key()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.title_key is null then
    if tg_table_name = 'expenses' then
      new.title_key := public.finance_title_key_for(
        new.title,
        new.category,
        new.type::text
      );
    elsif tg_table_name = 'expense_templates' then
      new.title_key := public.finance_title_key_for(
        new.title,
        new.category,
        coalesce(new.type, 'expense')
      );
    else
      new.title_key := public.finance_title_key_for(
        new.title,
        new.category,
        'expense'
      );
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists set_expense_templates_title_key on public.expense_templates;
create trigger set_expense_templates_title_key
before insert or update of title, category, type, title_key on public.expense_templates
for each row execute function public.set_finance_title_key();

drop trigger if exists set_planned_expenses_title_key on public.planned_expenses;
create trigger set_planned_expenses_title_key
before insert or update of title, category, title_key on public.planned_expenses
for each row execute function public.set_finance_title_key();

drop trigger if exists set_expenses_title_key on public.expenses;
create trigger set_expenses_title_key
before insert or update of title, category, type, title_key on public.expenses
for each row execute function public.set_finance_title_key();

update public.expense_templates
set title_key = public.finance_title_key_for(title, category, coalesce(type, 'expense'))
where title_key is null
  and public.finance_title_key_for(title, category, coalesce(type, 'expense')) is not null;

update public.planned_expenses pe
set title_key = coalesce(
  et.title_key,
  public.finance_title_key_for(pe.title, pe.category, 'expense')
)
from public.expense_templates et
where pe.template_id = et.id
  and pe.title_key is null
  and coalesce(et.title_key, public.finance_title_key_for(pe.title, pe.category, 'expense')) is not null;

update public.planned_expenses
set title_key = public.finance_title_key_for(title, category, 'expense')
where title_key is null
  and public.finance_title_key_for(title, category, 'expense') is not null;

update public.expenses
set title_key = public.finance_title_key_for(title, category, type::text)
where title_key is null
  and public.finance_title_key_for(title, category, type::text) is not null;

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
        title_key,
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
        template_row.title_key,
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

drop function if exists public.get_combined_feed(uuid, integer, integer);
create or replace function public.get_combined_feed(
  p_household_id uuid,
  p_limit integer default 20,
  p_offset integer default 0
)
returns table (
  record_type text,
  transaction_type text,
  id uuid,
  title text,
  title_key text,
  amount numeric,
  category text,
  split_type text,
  payer_id uuid,
  payer_email text,
  payer_full_name text,
  payer_avatar_url text,
  date timestamptz,
  status text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
begin
  if v_uid is null then
    return;
  end if;

  if not public.is_current_household_member(p_household_id) then
    return;
  end if;

  return query
  select
    'expense'::text as record_type,
    e.type::text as transaction_type,
    e.id,
    e.title,
    e.title_key,
    e.amount,
    e.category,
    e.split_type,
    e.paid_by as payer_id,
    u.email as payer_email,
    u.full_name as payer_full_name,
    u.avatar_url as payer_avatar_url,
    e.paid_at as date,
    'paid'::text as status
  from public.expenses e
  left join public.users u on u.id = e.paid_by
  where e.household_id = p_household_id
    and e.type in ('expense', 'income', 'settlement')
    and (
      coalesce(
        e.is_shared,
        case
          when lower(coalesce(e.split_type, 'equal')) in ('personal', 'gift') then false
          else true
        end
      ) = true
      or e.paid_by = v_uid
      or e.created_by_id = v_uid
    )

  union all

  select
    'planned'::text as record_type,
    'expense'::text as transaction_type,
    pe.id,
    pe.title,
    pe.title_key,
    pe.amount,
    pe.category,
    pe.split_type,
    pe.payer_default as payer_id,
    u.email as payer_email,
    u.full_name as payer_full_name,
    u.avatar_url as payer_avatar_url,
    pe.due_date::timestamptz as date,
    pe.status
  from public.planned_expenses pe
  left join public.users u on u.id = pe.payer_default
  where pe.household_id = p_household_id
    and pe.status = 'pending'
    and (
      lower(coalesce(pe.split_type, 'equal')) not in ('personal', 'gift')
      or pe.payer_default = v_uid
    )

  order by date desc, id desc
  limit p_limit
  offset p_offset;
end;
$$;

grant execute on function public.get_combined_feed(uuid, integer, integer) to authenticated;

create or replace function public.pay_planned_expense(
  p_planned_id uuid,
  p_amount numeric,
  p_paid_at timestamptz,
  p_paid_by uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
  v_expense_id uuid;
  v_household_id uuid;
  v_title text;
  v_title_key text;
  v_category text;
  v_split_type text;
  v_is_shared boolean;
begin
  if v_uid is null then
    return jsonb_build_object('success', false, 'message', 'Not authenticated');
  end if;

  if p_paid_by is distinct from v_uid then
    return jsonb_build_object('success', false, 'message', 'You can only pay with your own user');
  end if;

  select household_id, title, title_key, category, split_type
  into v_household_id, v_title, v_title_key, v_category, v_split_type
  from public.planned_expenses
  where id = p_planned_id;

  if not found then
    return jsonb_build_object('success', false, 'message', 'Planned expense not found');
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_household_id
      and hm.user_id = v_uid
  ) then
    return jsonb_build_object('success', false, 'message', 'User is not a member of this household');
  end if;

  v_is_shared := case
    when lower(coalesce(v_split_type, 'equal')) in ('personal', 'gift') then false
    else true
  end;

  insert into public.expenses (
    household_id,
    created_by_id,
    title,
    title_key,
    amount,
    category,
    paid_by,
    paid_at,
    type,
    split_type,
    is_shared,
    planned_expense_id
  ) values (
    v_household_id,
    v_uid,
    v_title,
    v_title_key,
    p_amount,
    v_category,
    p_paid_by,
    p_paid_at,
    'expense',
    coalesce(v_split_type, 'equal'),
    v_is_shared,
    p_planned_id
  ) returning id into v_expense_id;

  update public.planned_expenses
  set status = 'paid'
  where id = p_planned_id;

  if lower(coalesce(v_split_type, 'equal')) = 'equal' then
    insert into public.expense_splits (expense_id, user_id, amount)
    select
      v_expense_id,
      hm.user_id,
      p_amount / nullif((select count(*)::numeric from public.household_members where household_id = v_household_id), 0)
    from public.household_members hm
    where hm.household_id = v_household_id;
  else
    insert into public.expense_splits (expense_id, user_id, amount)
    values (v_expense_id, p_paid_by, p_amount);
  end if;

  return jsonb_build_object(
    'success', true,
    'expense_id', v_expense_id,
    'message', 'Planned expense paid successfully'
  );
end;
$$;
