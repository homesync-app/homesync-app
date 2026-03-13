-- Add created_by_id to tasks and setup for approval logic
BEGIN;

-- 1. Add created_by_id column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tasks' AND column_name = 'created_by_id') THEN
        ALTER TABLE public.tasks ADD COLUMN created_by_id UUID REFERENCES public.users(id);
    END IF;
END $$;

-- 2. Ensure status can accept 'pending_approval' (if there was a constraint)
-- We don't know the constraint name, so we just try to update if it was restrictive.
-- Usually it's better to just leave it as TEXT without constraints if we want flexibility.

-- 3. Update existing tasks with a guessed creator if possible (e.g. household owner or first member)
-- But for now we leave them as null.

COMMIT;
