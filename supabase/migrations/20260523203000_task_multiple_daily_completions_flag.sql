-- Explicitly mark tasks that can be completed multiple times in the same day.

alter table public.tasks
  add column if not exists allow_multiple_daily_completions boolean not null default false;

comment on column public.tasks.allow_multiple_daily_completions is
  'When true, a daily recurring task can create multiple task_completed activities on the same local day.';

update public.tasks
set allow_multiple_daily_completions = true
where recurrence_type = 'daily'
  and (
    category = 'cocina'
    or lower(title) like '%lavar plato%'
    or lower(title) like '%plato%'
    or lower(title) like '%cocinar%'
    or lower(title) like '%cocina%'
    or lower(title) like '%barrer%'
  );

notify pgrst, 'reload schema';
