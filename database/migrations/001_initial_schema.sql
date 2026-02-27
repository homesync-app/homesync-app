-- ============================================
-- HOMESYNC INITIAL SCHEMA - SUPABASE OPTION B
-- ============================================
-- This migration creates all necessary tables for HomeSync
-- Using Supabase Auth + PostgreSQL + RPC Functions
-- ============================================

-- Enable UUID extension (usually enabled in Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE (Supabase Auth manages this)
-- ============================================
-- We'll use Supabase's built-in auth.users
-- But we'll extend it with public.users for additional data

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for users
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- ============================================
-- HOUSEHOLDS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.households (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- HOUSEHOLD MEMBERS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.household_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',  -- 'owner', 'admin', 'member'
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(household_id, user_id)
);

-- Indexes for household_members
CREATE INDEX IF NOT EXISTS idx_household_members_household ON public.household_members(household_id);
CREATE INDEX IF NOT EXISTS idx_household_members_user ON public.household_members(user_id);

-- ============================================
-- TASKS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  assigned_to UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_by_id UUID NOT NULL REFERENCES public.users(id),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  type TEXT DEFAULT 'one_time',  -- 'one_time', 'recurring'
  difficulty TEXT DEFAULT 'medium',  -- 'easy', 'medium', 'hard'
  xp_reward INTEGER DEFAULT 0,
  coin_reward INTEGER DEFAULT 0,
  priority TEXT DEFAULT 'medium',  -- 'low', 'medium', 'high'
  status TEXT NOT NULL DEFAULT 'active',  -- 'assigned', 'active', 'in_progress', 'pending_verification', 'verified', 'rejected'
  due_at TIMESTAMPTZ,
  last_completed_at TIMESTAMPTZ,
  last_verified_by UUID REFERENCES public.users(id),
  next_due_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for tasks
CREATE INDEX IF NOT EXISTS idx_tasks_household ON public.tasks(household_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON public.tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON public.tasks(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_created_by ON public.tasks(created_by_id);

-- ============================================
-- LEDGER ENTRIES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id),
  type TEXT NOT NULL,  -- 'xp_earned', 'coins_earned', 'expense_payment', 'expense_split', etc.
  amount INTEGER NOT NULL,  -- Positive for gains, negative for losses
  currency TEXT NOT NULL,  -- 'XP', 'COIN', 'EUR', etc.
  reference_id TEXT,  -- Task ID, Expense ID, etc.
  reference_type TEXT,  -- 'task_completion', 'expense', etc.
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by TEXT,
  source TEXT DEFAULT 'api'  -- 'api', 'rpc', 'admin'
);

-- Unique constraint for ledger entries (prevents duplicates)
CREATE UNIQUE INDEX IF NOT EXISTS idx_ledger_entries_unique 
ON public.ledger_entries(reference_id, type, user_id);

-- Indexes for ledger_entries
CREATE INDEX IF NOT EXISTS idx_ledger_entries_household ON public.ledger_entries(household_id);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_user ON public.ledger_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_created_at ON public.ledger_entries(created_at DESC);

-- ============================================
-- IDEMPOTENCY KEYS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.idempotency_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  idempotency_key UUID NOT NULL UNIQUE,
  operation TEXT NOT NULL,  -- 'complete_task', 'verify_task', etc.
  request_body JSONB,
  response_body JSONB,
  status_code INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours')
);

-- Indexes for idempotency_keys
CREATE UNIQUE INDEX IF NOT EXISTS idx_idempotency_keys_user_key 
ON public.idempotency_keys(user_id, idempotency_key);
CREATE INDEX IF NOT EXISTS idx_idempotency_keys_expires ON public.idempotency_keys(expires_at);

-- ============================================
-- EXPENSES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  created_by_id UUID NOT NULL REFERENCES public.users(id),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  amount DECIMAL NOT NULL,
  currency TEXT DEFAULT 'EUR',
  paid_by UUID NOT NULL REFERENCES public.users(id),
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for expenses
CREATE INDEX IF NOT EXISTS idx_expenses_household ON public.expenses(household_id);
CREATE INDEX IF NOT EXISTS idx_expenses_paid_by ON public.expenses(paid_by);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON public.expenses(created_at DESC);

-- ============================================
-- EXPENSE SPLITS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.expense_splits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id),
  amount DECIMAL NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Unique constraint for expense splits
CREATE UNIQUE INDEX IF NOT EXISTS idx_expense_splits_unique 
ON public.expense_splits(expense_id, user_id);

-- Indexes for expense_splits
CREATE INDEX IF NOT EXISTS idx_expense_splits_expense ON public.expense_splits(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_splits_user ON public.expense_splits(user_id);

-- ============================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMPS
-- ============================================

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_households_updated_at
  BEFORE UPDATE ON public.households
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at
  BEFORE UPDATE ON public.expenses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SUPABASE AUTH TRIGGER (auto-create user in public.users)
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- GRANTS (Row Level Security will be added separately)
-- ============================================

-- Grant basic access to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT INSERT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT UPDATE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE public.users IS 'Extended user data linked to Supabase Auth';
COMMENT ON TABLE public.households IS 'Households/families for grouping users';
COMMENT ON TABLE public.household_members IS 'Membership of users in households';
COMMENT ON TABLE public.tasks IS 'Tasks/household chores';
COMMENT ON TABLE public.ledger_entries IS 'Immutable ledger for XP, Coins, and financial transactions';
COMMENT ON TABLE public.idempotency_keys IS 'Idempotency keys to prevent duplicate operations';
COMMENT ON TABLE public.expenses IS 'Household expenses';
COMMENT ON TABLE public.expense_splits IS 'Split of expenses between household members';
