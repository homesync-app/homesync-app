-- Reconstructed from remote migration history (version 20260311154741).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Add is_shared column to household_activities
ALTER TABLE public.household_activities 
ADD COLUMN IF NOT EXISTS is_shared BOOLEAN DEFAULT true;

-- 2. Update existing records (assume all existing ones are shared for safety, 
-- or try to infer from metadata if it was added recently, but usually it's cleaner to just set default)
UPDATE public.household_activities SET is_shared = true WHERE is_shared IS NULL;

-- 3. Update trg_capture_expense_activity to populate is_shared
CREATE OR REPLACE FUNCTION trg_capture_expense_activity()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.household_activities (
    household_id, 
    user_id, 
    event_type, 
    title, 
    is_shared,
    metadata
  ) VALUES (
    NEW.household_id, 
    NEW.created_by_id, 
    'expense_added', 
    NEW.title,
    NEW.is_shared, -- Capture from the expense record
    jsonb_build_object(
      'expense_id', NEW.id,
      'amount', NEW.amount,
      'currency', NEW.currency,
      'category', NEW.category,
      'type', NEW.type,
      'is_shared', NEW.is_shared -- Also add to metadata for legacy/easier frontend access
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Update RLS policy for household_activities
-- Drop the old policy and create a new one that respects is_shared
DROP POLICY IF EXISTS "users_view_household_activities" ON public.household_activities;

CREATE POLICY "users_view_household_activities" ON public.household_activities
FOR SELECT TO authenticated
USING (
  (household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid()))
  AND 
  (is_shared = true OR user_id = auth.uid())
);
;