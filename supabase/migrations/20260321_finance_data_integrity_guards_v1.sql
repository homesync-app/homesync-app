-- Data integrity guards for finance tables

-- 1) Defensive checks on expense_splits amounts
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'expense_splits_amount_positive_chk'
      AND conrelid = 'public.expense_splits'::regclass
  ) THEN
    ALTER TABLE public.expense_splits
      ADD CONSTRAINT expense_splits_amount_positive_chk
      CHECK (amount > 0);
  END IF;
END $$;

-- 2) Validate expense actors belong to the same household
CREATE OR REPLACE FUNCTION public.validate_expense_membership_integrity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.household_id IS NULL THEN
    RAISE EXCEPTION 'expenses.household_id is required';
  END IF;

  IF NEW.created_by_id IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = NEW.household_id
      AND hm.user_id = NEW.created_by_id
  ) THEN
    RAISE EXCEPTION 'created_by_id must be a member of the expense household';
  END IF;

  IF NEW.paid_by IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = NEW.household_id
      AND hm.user_id = NEW.paid_by
  ) THEN
    RAISE EXCEPTION 'paid_by must be a member of the expense household';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_expense_membership_integrity ON public.expenses;
CREATE TRIGGER trg_validate_expense_membership_integrity
BEFORE INSERT OR UPDATE OF household_id, created_by_id, paid_by
ON public.expenses
FOR EACH ROW
EXECUTE FUNCTION public.validate_expense_membership_integrity();

-- 3) Validate split user belongs to expense household
CREATE OR REPLACE FUNCTION public.validate_expense_split_membership_integrity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_household_id UUID;
BEGIN
  SELECT e.household_id
  INTO v_household_id
  FROM public.expenses e
  WHERE e.id = NEW.expense_id;

  IF v_household_id IS NULL THEN
    RAISE EXCEPTION 'expense_id does not exist for split';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id
      AND hm.user_id = NEW.user_id
  ) THEN
    RAISE EXCEPTION 'split user_id must belong to expense household';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_expense_split_membership_integrity ON public.expense_splits;
CREATE TRIGGER trg_validate_expense_split_membership_integrity
BEFORE INSERT OR UPDATE OF expense_id, user_id
ON public.expense_splits
FOR EACH ROW
EXECUTE FUNCTION public.validate_expense_split_membership_integrity();

-- 4) Supporting index for split validations
CREATE INDEX IF NOT EXISTS idx_household_members_household_user
  ON public.household_members (household_id, user_id);
