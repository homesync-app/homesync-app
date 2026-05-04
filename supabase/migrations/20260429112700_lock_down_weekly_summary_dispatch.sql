-- Modo Padres: la funcion del cron no debe exponerse por RPC publica.

revoke execute on function public.dispatch_weekly_family_summary_notifications()
  from public;
revoke execute on function public.dispatch_weekly_family_summary_notifications()
  from anon;
revoke execute on function public.dispatch_weekly_family_summary_notifications()
  from authenticated;

grant execute on function public.dispatch_weekly_family_summary_notifications()
  to service_role;
