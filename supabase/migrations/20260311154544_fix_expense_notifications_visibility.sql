-- Reconstructed from remote migration history (version 20260311154544).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Update expense notification trigger to respect is_shared
CREATE OR REPLACE FUNCTION handle_expense_notifications()
RETURNS TRIGGER AS $$
DECLARE
  creator_name TEXT;
  member_id UUID;
BEGIN
  -- ONLY notify if it is shared
  IF NEW.is_shared = false THEN
    RETURN NEW;
  END IF;

  -- Notify everyone else in the household
  SELECT full_name INTO creator_name FROM public.users WHERE id = NEW.created_by_id;

  FOR member_id IN 
    SELECT user_id FROM public.household_members WHERE household_id = NEW.household_id AND user_id != NEW.created_by_id
  LOOP
    INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id)
    VALUES (
      NEW.household_id,
      member_id,
      NEW.created_by_id,
      'Nuevo Gasto',
      COALESCE(creator_name, 'Alguien') || ' agregâ”œâ”‚ un gasto de ' || COALESCE(NEW.currency, 'ARS') || ' ' || NEW.amount || ' por ' || NEW.title,
      'expense_added',
      'expense',
      NEW.id
    );
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
;