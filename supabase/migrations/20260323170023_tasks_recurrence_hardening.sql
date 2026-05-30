-- Reconstructed from remote migration history (version 20260323170023).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Add columns for advanced recurrence
ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS recurrence_weekdays integer[] DEFAULT ARRAY[]::integer[],
ADD COLUMN IF NOT EXISTS recurrence_month_days integer[] DEFAULT ARRAY[]::integer[];

-- 2. Update the check constraint to include 'custom'
ALTER TABLE public.tasks 
DROP CONSTRAINT IF EXISTS tasks_recurrence_type_check;

ALTER TABLE public.tasks 
ADD CONSTRAINT tasks_recurrence_type_check 
CHECK (recurrence_type = ANY (ARRAY['daily', 'weekly', 'monthly', 'custom']));

-- 3. Comments for documentation
COMMENT ON COLUMN public.tasks.recurrence_weekdays IS 'Integers 1-7 representing Monday-Sunday for custom weekly recurrence';
COMMENT ON COLUMN public.tasks.recurrence_month_days IS 'Integers 1-31 representing days of the month for custom monthly recurrence';
;