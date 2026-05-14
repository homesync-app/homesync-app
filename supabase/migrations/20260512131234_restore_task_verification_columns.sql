alter table public.tasks
  add column if not exists verified_by uuid references public.users(id) on delete set null,
  add column if not exists verified_at timestamptz;

comment on column public.tasks.verified_by is
  'User that verified or approved the task completion. Kept for compatibility with task approval RPCs and clients.';
comment on column public.tasks.verified_at is
  'Timestamp when the task completion was verified or approved.';

notify pgrst, 'reload schema';
