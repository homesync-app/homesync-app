-- Reconstructed from remote migration history (version 20260302215755).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Create enum for transaction type
DO $$ BEGIN
    CREATE TYPE transaction_type AS ENUM ('expense', 'income');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add type column to expenses table
ALTER TABLE public.expenses 
ADD COLUMN IF NOT EXISTS type transaction_type DEFAULT 'expense';

-- 3. Update existing records (all current records are expenses)
UPDATE public.expenses SET type = 'expense' WHERE type IS NULL;

-- 4. Add index for performance on filtering by type
CREATE INDEX IF NOT EXISTS idx_expenses_type ON public.expenses(type);

-- 5. Add a comment for clarification
COMMENT ON COLUMN public.expenses.type IS 'Distinguishes between a money outflow (expense) and inflow (income)';
;