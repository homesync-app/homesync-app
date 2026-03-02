-- ========================================================
-- ENABLE PUSH NOTIFICATIONS TRIGGER
-- This trigger automatically sends a push notification 
-- whenever a new record is inserted into the 'notifications' table.
-- ========================================================

-- Enable pg_net extension for async HTTP calls
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Create the trigger function
CREATE OR REPLACE FUNCTION public.handle_push_notification_on_insert()
RETURNS TRIGGER AS $$
DECLARE
  service_role_key TEXT;
  project_url TEXT;
BEGIN
  -- We try to get the service role key from the environment/settings if possible.
  -- In Supabase, this is often set in the 'vault' or as a custom setting.
  -- If not found, the call will fail, but the insert will succeed (async).
  
  -- NOTE: For security, it's recommended to configure the 'Authorization' header
  -- in the Supabase Dashboard -> Database -> Webhooks UI to avoid hardcoding keys.
  -- However, for this implementation, we set up the structure.
  
  -- The Edge Function URL (change [PROJECT_REF] if needed, current is tfavamqszdkoeabpyxms)
  -- In production, the function will be called with the row data in the 'record' field.
  
  PERFORM
    net.http_post(
      url := 'https://tfavamqszdkoeabpyxms.supabase.co/functions/v1/send-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || COALESCE(current_setting('app.settings.service_role_key', true), 'SERVICE_ROLE_KEY_PLACEHOLDER')
      ),
      body := jsonb_build_object(
        'record', row_to_json(NEW)
      )
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach the trigger to the notifications table
DROP TRIGGER IF EXISTS on_notification_created_push ON public.notifications;
CREATE TRIGGER on_notification_created_push
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_push_notification_on_insert();

COMMENT ON FUNCTION public.handle_push_notification_on_insert() IS 'Automatically sends a push notification via Edge Function when a new notification is created in the DB.';
