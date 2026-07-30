-- Secure the database-to-Edge-Function notification channel.
-- Provision these values outside source control:
--   Edge secret: SEND_NOTIFICATION_WEBHOOK_SECRET
--   Vault name:  send_notification_webhook_secret (same random value)
--   Vault name:  send_notification_webhook_url (full HTTPS function URL)
-- Example provisioning (never commit real values):
-- select vault.create_secret('<secret>', 'send_notification_webhook_secret');
-- select vault.create_secret(
--   'https://<project-ref>.supabase.co/functions/v1/send-notification',
--   'send_notification_webhook_url'
-- );

create extension if not exists supabase_vault with schema vault;
create extension if not exists pg_net;

create or replace function public.handle_push_notification_on_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_webhook_secret text;
  v_webhook_url text;
begin
  select ds.decrypted_secret
    into v_webhook_secret
  from vault.decrypted_secrets ds
  where ds.name = 'send_notification_webhook_secret'
  limit 1;

  select ds.decrypted_secret
    into v_webhook_url
  from vault.decrypted_secrets ds
  where ds.name = 'send_notification_webhook_url'
  limit 1;

  if v_webhook_secret is null or length(v_webhook_secret) < 32 then
    raise warning
      'Push notification skipped: send_notification_webhook_secret is missing or too short';
    return new;
  end if;

  if v_webhook_url is null or v_webhook_url not like 'https://%' then
    raise warning
      'Push notification skipped: send_notification_webhook_url is missing or not HTTPS';
    return new;
  end if;

  perform net.http_post(
    url := v_webhook_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', v_webhook_secret
    ),
    body := jsonb_build_object('record', to_jsonb(new)),
    timeout_milliseconds := 5000
  );

  return new;
exception
  when others then
    -- Push delivery is best-effort and must never roll back the notification.
    raise warning 'Could not enqueue push notification: %', sqlerrm;
    return new;
end;
$function$;

revoke execute on function public.handle_push_notification_on_insert()
  from public, anon, authenticated;
grant execute on function public.handle_push_notification_on_insert()
  to service_role;
