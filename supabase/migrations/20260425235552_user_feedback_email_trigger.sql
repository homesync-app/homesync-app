-- Reconstructed from remote migration history (version 20260425235552).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- trigger que llama a la edge function notify-feedback en cada nuevo reporte
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
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key', true)
      ),
      body    := to_jsonb(new)
    );
  return new;
end;
$$;

create trigger on_user_feedback_insert
  after insert on public.user_feedback
  for each row
  execute function public.notify_feedback_on_insert();
