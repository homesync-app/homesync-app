-- Reconstructed from remote migration history (version 20260425235502).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

alter table public.user_feedback
  add column if not exists resolved boolean not null default false;

-- el admin puede actualizar el estado resolved
create policy "admin can update feedback"
  on public.user_feedback
  for update
  using ( auth.uid()::text = '5ac9da1b-11ba-4427-a994-691577ad596f' )
  with check ( auth.uid()::text = '5ac9da1b-11ba-4427-a994-691577ad596f' );

create index if not exists user_feedback_resolved_idx on public.user_feedback (resolved);
