-- Finance invariants + performance hardening

-- 1) Normalize nullable legacy fields
UPDATE public.expenses
SET split_type = 'equal'
WHERE split_type IS NULL OR btrim(split_type) = '';

UPDATE public.expenses
SET is_shared = CASE
  WHEN lower(split_type) IN ('personal', 'gift') THEN false
  ELSE true
END
WHERE is_shared IS NULL;

UPDATE public.expenses
SET type = 'expense'::transaction_type
WHERE type IS NULL;

-- 2) Stronger column guarantees
ALTER TABLE public.expenses
  ALTER COLUMN split_type SET DEFAULT 'equal',
  ALTER COLUMN split_type SET NOT NULL,
  ALTER COLUMN is_shared SET DEFAULT true,
  ALTER COLUMN is_shared SET NOT NULL,
  ALTER COLUMN type SET DEFAULT 'expense',
  ALTER COLUMN type SET NOT NULL;

-- 3) Add defensive checks (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'expenses_split_type_allowed_chk'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_split_type_allowed_chk
      CHECK (lower(split_type) IN ('equal', 'fixed', 'gift', 'personal'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'expenses_amount_positive_chk'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_amount_positive_chk
      CHECK (amount > 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'expenses_title_not_blank_chk'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_title_not_blank_chk
      CHECK (btrim(title) <> '');
  END IF;
END $$;

-- 4) Query-scale indexes
CREATE INDEX IF NOT EXISTS idx_expenses_household_visibility_paidat
  ON public.expenses (household_id, is_shared, paid_at DESC);

CREATE INDEX IF NOT EXISTS idx_expenses_household_paidby_paidat
  ON public.expenses (household_id, paid_by, paid_at DESC);

CREATE INDEX IF NOT EXISTS idx_expenses_household_creator_paidat
  ON public.expenses (household_id, created_by_id, paid_at DESC);

-- 5) Keep privacy consistent when split type changes outside RPCs
CREATE OR REPLACE FUNCTION public.enforce_expense_privacy_consistency()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF lower(coalesce(NEW.split_type, 'equal')) IN ('personal', 'gift') THEN
    NEW.is_shared := false;
  ELSIF NEW.is_shared IS NULL THEN
    NEW.is_shared := true;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_expense_privacy_consistency ON public.expenses;
CREATE TRIGGER trg_enforce_expense_privacy_consistency
BEFORE INSERT OR UPDATE OF split_type, is_shared
ON public.expenses
FOR EACH ROW
EXECUTE FUNCTION public.enforce_expense_privacy_consistency();
