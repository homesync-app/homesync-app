-- Reconstructed from remote migration history (version 20260221160541).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- AUTO-CAPTURE ACTIVITIES IN THE FEED
-- This ensures that even if added via API or direct SQL, things show up in history.

-- 1. Expense Trigger
CREATE OR REPLACE FUNCTION public.trg_capture_expense_activity()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.household_activities (
    household_id, user_id, event_type, title, metadata
  ) VALUES (
    NEW.household_id, NEW.created_by_id, 'expense_added', NEW.title,
    jsonb_build_object(
      'expense_id', NEW.id,
      'amount', NEW.amount,
      'currency', NEW.currency,
      'category', NEW.category
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_after_expense_insert ON public.expenses;
CREATE TRIGGER trg_after_expense_insert
  AFTER INSERT ON public.expenses
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_capture_expense_activity();

-- 2. Reward Redemption Trigger (Optional but good for history)
CREATE OR REPLACE FUNCTION public.trg_capture_reward_activity()
RETURNS TRIGGER AS $$
DECLARE
  v_reward_title TEXT;
BEGIN
  SELECT title INTO v_reward_title FROM public.rewards WHERE id = NEW.reward_id;
  
  INSERT INTO public.household_activities (
    household_id, user_id, event_type, title, metadata
  ) VALUES (
    NEW.household_id, NEW.user_id, 'reward_redeemed', v_reward_title,
    jsonb_build_object(
      'redemption_id', NEW.id,
      'cost', NEW.cost
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_after_reward_redemption ON public.reward_redemptions;
CREATE TRIGGER trg_after_reward_redemption
  AFTER INSERT ON public.reward_redemptions
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_capture_reward_activity();
;