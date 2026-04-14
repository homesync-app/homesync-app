ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS tasks_enabled BOOLEAN NOT NULL DEFAULT true;
