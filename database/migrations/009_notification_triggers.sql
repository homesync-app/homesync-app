-- ============================================
-- HOMESYNC NOTIFICATION TRIGGERS
-- ============================================

-- Function to handle task notifications
CREATE OR REPLACE FUNCTION handle_task_notifications()
RETURNS TRIGGER AS $$
DECLARE
  creator_name TEXT;
  assignee_name TEXT;
  household_member_id UUID;
BEGIN
  -- We'll try to get names if possible
  SELECT full_name INTO creator_name FROM public.users WHERE id = NEW.created_by_id;
  
  -- If assigning a task to someone
  IF (TG_OP = 'INSERT' AND NEW.assigned_to IS NOT NULL AND NEW.assigned_to != NEW.created_by_id) OR
     (TG_OP = 'UPDATE' AND NEW.assigned_to IS NOT NULL AND OLD.assigned_to IS DISTINCT FROM NEW.assigned_to AND NEW.assigned_to != NEW.created_by_id) THEN
     
    INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id)
    VALUES (
      NEW.household_id,
      NEW.assigned_to,
      NEW.created_by_id,
      'Nueva Tarea Asignada',
      COALESCE(creator_name, 'Alguien') || ' te asignó la tarea: ' || NEW.title,
      'task_assigned',
      'task',
      NEW.id
    );
  END IF;

  -- If completing a task
  IF (TG_OP = 'UPDATE' AND NEW.status IN ('pending_verification', 'verified') AND OLD.status NOT IN ('pending_verification', 'verified')) THEN
    -- Try to get the name of the user who completed the task
    -- Usually this is auth.uid(). As a fallback, use the assigned user.
    IF auth.uid() IS NOT NULL THEN
      SELECT full_name INTO assignee_name FROM public.users WHERE id = auth.uid();
    ELSIF NEW.assigned_to IS NOT NULL THEN
      SELECT full_name INTO assignee_name FROM public.users WHERE id = NEW.assigned_to;
    ELSE
      assignee_name := 'Alguien';
    END IF;

    -- Also check that auth.uid() is not the creator themselves completing it
    IF auth.uid() IS NULL OR NEW.created_by_id != auth.uid() THEN  
      INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id)
      VALUES (
        NEW.household_id,
        NEW.created_by_id,
        auth.uid(),
        'Tarea Completada',
        COALESCE(assignee_name, 'Alguien') || ' completó: ' || NEW.title,
        'task_completed',
        'task',
        NEW.id
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for tasks
DROP TRIGGER IF EXISTS on_task_action ON public.tasks;
CREATE TRIGGER on_task_action
  AFTER INSERT OR UPDATE ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION handle_task_notifications();


-- Function to handle expense notifications
CREATE OR REPLACE FUNCTION handle_expense_notifications()
RETURNS TRIGGER AS $$
DECLARE
  creator_name TEXT;
  member_id UUID;
BEGIN
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
      COALESCE(creator_name, 'Alguien') || ' agregó un gasto de ' || NEW.currency || ' ' || NEW.amount || ' por ' || NEW.title,
      'expense_added',
      'expense',
      NEW.id
    );
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for expenses
DROP TRIGGER IF EXISTS on_expense_action ON public.expenses;
CREATE TRIGGER on_expense_action
  AFTER INSERT ON public.expenses
  FOR EACH ROW
  EXECUTE FUNCTION handle_expense_notifications();
