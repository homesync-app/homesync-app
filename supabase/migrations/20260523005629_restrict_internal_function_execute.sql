-- Reconstructed from remote migration history (version 20260523005629).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Internal trigger/cron functions are SECURITY DEFINER implementation details.
-- They should be callable by Postgres triggers/jobs, not exposed as authenticated
-- RPC endpoints through PostgREST.

revoke execute on function public.dispatch_weekly_family_summary_notifications()
  from public, anon, authenticated;
grant execute on function public.dispatch_weekly_family_summary_notifications()
  to service_role;

revoke execute on function public.enforce_expense_privacy_consistency()
  from public, anon, authenticated;
grant execute on function public.enforce_expense_privacy_consistency()
  to service_role;

revoke execute on function public.handle_expense_notifications()
  from public, anon, authenticated;
grant execute on function public.handle_expense_notifications()
  to service_role;

revoke execute on function public.handle_new_user()
  from public, anon, authenticated;
grant execute on function public.handle_new_user()
  to service_role;

revoke execute on function public.handle_push_notification_on_insert()
  from public, anon, authenticated;
grant execute on function public.handle_push_notification_on_insert()
  to service_role;

revoke execute on function public.handle_task_notifications()
  from public, anon, authenticated;
grant execute on function public.handle_task_notifications()
  to service_role;

revoke execute on function public.handle_template_update_sync()
  from public, anon, authenticated;
grant execute on function public.handle_template_update_sync()
  to service_role;

revoke execute on function public.notify_feedback_on_insert()
  from public, anon, authenticated;
grant execute on function public.notify_feedback_on_insert()
  to service_role;

revoke execute on function public.trg_capture_expense_activity()
  from public, anon, authenticated;
grant execute on function public.trg_capture_expense_activity()
  to service_role;

revoke execute on function public.trg_on_expense_delete_cleanup()
  from public, anon, authenticated;
grant execute on function public.trg_on_expense_delete_cleanup()
  to service_role;

revoke execute on function public.validate_expense_membership_integrity()
  from public, anon, authenticated;
grant execute on function public.validate_expense_membership_integrity()
  to service_role;

revoke execute on function public.validate_expense_split_membership_integrity()
  from public, anon, authenticated;
grant execute on function public.validate_expense_split_membership_integrity()
  to service_role;
