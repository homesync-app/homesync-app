-- Reconstructed from remote migration history (version 20260219232401).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Add recurrence fields to tasks
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS recurrence_type TEXT CHECK (recurrence_type IN ('daily', 'weekly', 'monthly'));
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS recurrence_interval INTEGER DEFAULT 1;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS recurrence_end_at TIMESTAMPTZ;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS recurrence_parent_id UUID REFERENCES tasks(id);

-- Create index for recurring tasks
CREATE INDEX IF NOT EXISTS idx_tasks_recurrence ON tasks(recurrence_type) WHERE recurrence_type IS NOT NULL;

-- Function to calculate next due date
CREATE OR REPLACE FUNCTION calculate_next_due_date(
  p_current_due TIMESTAMPTZ,
  p_recurrence_type TEXT,
  p_interval INTEGER DEFAULT 1
)
RETURNS TIMESTAMPTZ AS $$
BEGIN
  RETURN CASE p_recurrence_type
    WHEN 'daily' THEN p_current_due + (p_interval || ' days')::INTERVAL
    WHEN 'weekly' THEN p_current_due + (p_interval * 7 || ' days')::INTERVAL
    WHEN 'monthly' THEN p_current_due + (p_interval || ' months')::INTERVAL
    ELSE NULL
  END;
END;
$$ LANGUAGE plpgsql;

-- Function to create next recurring task
CREATE OR REPLACE FUNCTION create_next_recurring_task(
  p_task_id UUID,
  p_verified_by UUID
)
RETURNS UUID AS $$
DECLARE
  v_task RECORD;
  v_next_due TIMESTAMPTZ;
  v_new_task_id UUID;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;
  
  IF v_task.recurrence_type IS NULL THEN
    RETURN NULL;
  END IF;
  
  IF v_task.recurrence_end_at IS NOT NULL AND NOW() >= v_task.recurrence_end_at THEN
    RETURN NULL;
  END IF;
  
  v_next_due := calculate_next_due_date(
    COALESCE(v_task.due_at, NOW()),
    v_task.recurrence_type,
    COALESCE(v_task.recurrence_interval, 1)
  );
  
  INSERT INTO tasks (
    household_id,
    assigned_to,
    created_by_id,
    title,
    description,
    category,
    type,
    difficulty,
    xp_reward,
    coin_reward,
    priority,
    status,
    due_at,
    recurrence_type,
    recurrence_interval,
    recurrence_end_at,
    recurrence_parent_id
  ) VALUES (
    v_task.household_id,
    v_task.assigned_to,
    v_task.created_by_id,
    v_task.title,
    v_task.description,
    v_task.category,
    v_task.type,
    v_task.difficulty,
    v_task.xp_reward,
    v_task.coin_reward,
    v_task.priority,
    'active',
    v_next_due,
    v_task.recurrence_type,
    v_task.recurrence_interval,
    v_task.recurrence_end_at,
    v_task.id
  ) RETURNING id INTO v_new_task_id;
  
  RETURN v_new_task_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
;