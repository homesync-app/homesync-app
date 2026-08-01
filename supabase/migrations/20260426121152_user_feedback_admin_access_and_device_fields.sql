-- Reconstructed from remote migration history (version 20260426121152).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Fix RLS: allow both admin accounts to read/update feedback
drop policy if exists "admin can read all feedback" on public.user_feedback;
drop policy if exists "admin can update feedback" on public.user_feedback;

create policy "admin can read all feedback"
  on public.user_feedback for select
  using (
    auth.uid()::text in (
      '5ac9da1b-11ba-4427-a994-691577ad596f',
      'e4a31718-a63d-450f-b70f-db899dd109a9'
    )
  );

create policy "admin can update feedback"
  on public.user_feedback for update
  using (
    auth.uid()::text in (
      '5ac9da1b-11ba-4427-a994-691577ad596f',
      'e4a31718-a63d-450f-b70f-db899dd109a9'
    )
  );

-- Add device info columns for AI debugging
alter table public.user_feedback
  add column if not exists device_model text,
  add column if not exists os_version text,
  add column if not exists locale text,
  add column if not exists screen_name text;
;