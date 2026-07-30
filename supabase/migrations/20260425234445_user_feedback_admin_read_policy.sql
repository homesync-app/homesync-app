-- Reconstructed from remote migration history (version 20260425234445).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- reemplaza la polâ”œÂ¡tica de lectura para que el admin QA pueda leer todo el feedback
drop policy if exists "service role can read all feedback" on public.user_feedback;

create policy "admin can read all feedback"
  on public.user_feedback
  for select
  using (
    auth.uid()::text = '5ac9da1b-11ba-4427-a994-691577ad596f'
  );
