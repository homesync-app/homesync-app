-- Restore the recurrence helper used by task completion RPCs.
-- Some completion flows call this from SECURITY DEFINER functions.

create or replace function public.calculate_next_task_due_at(
  p_current_due_at timestamptz,
  p_recurrence_type text,
  p_recurrence_interval integer default 1
)
returns timestamptz
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_next_due_at timestamptz;
  v_base_date timestamptz;
  v_recurrence_type text := lower(nullif(trim(p_recurrence_type), ''));
  v_recurrence_interval integer := greatest(coalesce(p_recurrence_interval, 1), 1);
begin
  if p_current_due_at is null
      or v_recurrence_type is null
      or v_recurrence_type = 'none' then
    return null;
  end if;

  -- Avoid rescheduling overdue recurring tasks back into the past.
  v_base_date := greatest(p_current_due_at, now());

  if v_recurrence_type = 'daily' then
    v_next_due_at := v_base_date + make_interval(days => v_recurrence_interval);
  elsif v_recurrence_type = 'weekly' then
    v_next_due_at := v_base_date + make_interval(weeks => v_recurrence_interval);
  elsif v_recurrence_type = 'monthly' then
    v_next_due_at := v_base_date + make_interval(months => v_recurrence_interval);
  else
    v_next_due_at := v_base_date + interval '1 day';
  end if;

  return date_trunc('day', v_next_due_at);
end;
$$;

revoke execute on function public.calculate_next_task_due_at(timestamptz, text, integer)
  from public, anon;
grant execute on function public.calculate_next_task_due_at(timestamptz, text, integer)
  to authenticated;

notify pgrst, 'reload schema';
