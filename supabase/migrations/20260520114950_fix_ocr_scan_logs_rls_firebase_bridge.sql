-- Reconstructed from remote migration history (version 20260520114950).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

drop policy if exists "users insert own logs" on public.ocr_scan_logs;
create policy "users insert own logs"
  on public.ocr_scan_logs
  for insert
  to authenticated
  with check (user_id = public.current_app_user_id());

drop policy if exists "users update own logs" on public.ocr_scan_logs;
create policy "users update own logs"
  on public.ocr_scan_logs
  for update
  to authenticated
  using (user_id = public.current_app_user_id())
  with check (user_id = public.current_app_user_id());

drop policy if exists "users select own logs" on public.ocr_scan_logs;
create policy "users select own logs"
  on public.ocr_scan_logs
  for select
  to authenticated
  using (user_id = public.current_app_user_id());

drop policy if exists "admins read all logs" on public.ocr_scan_logs;
