-- Reconstructed from remote migration history (version 20260425235603).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- reemplaza la funciâ”œâ”‚n sin depender de service_role_key (la edge function no requiere JWT)
create or replace function public.notify_feedback_on_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform
    net.http_post(
      url     := 'https://tfavamqszdkoeabpyxms.supabase.co/functions/v1/notify-feedback',
      headers := jsonb_build_object('Content-Type', 'application/json'),
      body    := to_jsonb(new)
    );
  return new;
end;
$$;
