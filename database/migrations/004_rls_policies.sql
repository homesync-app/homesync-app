-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================
-- Security: Users can only access their own data
-- Applied: 2026-02-18
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.idempotency_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_splits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.integrity_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS TABLE
-- ============================================

-- Users can only see and update their own record
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- HOUSEHOLDS TABLE
-- ============================================

-- Users can see households they are members of
CREATE POLICY "Users can view their households"
  ON public.households FOR SELECT
  USING (
    id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid()
    )
  );

-- Users can create households (they become owner via household_members)
CREATE POLICY "Users can create households"
  ON public.households FOR INSERT
  WITH CHECK (true);

-- Only owners can update/delete households
CREATE POLICY "Owners can update households"
  ON public.households FOR UPDATE
  USING (
    id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

CREATE POLICY "Owners can delete households"
  ON public.households FOR DELETE
  USING (
    id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- ============================================
-- HOUSEHOLD_MEMBERS TABLE
-- ============================================

-- Users can see members of their households
CREATE POLICY "Users can view household members"
  ON public.household_members FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can join a household (insert themselves)
CREATE POLICY "Users can join household"
  ON public.household_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Owners/admins can add other members
CREATE POLICY "Owners can add members"
  ON public.household_members FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- Users can update their own membership or owners can update any
CREATE POLICY "Users can update membership"
  ON public.household_members FOR UPDATE
  USING (
    user_id = auth.uid()
    OR household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- Only owners can remove members
CREATE POLICY "Owners can remove members"
  ON public.household_members FOR DELETE
  USING (
    household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- ============================================
-- TASKS TABLE
-- ============================================

-- Users can see tasks from their households
CREATE POLICY "Users can view household tasks"
  ON public.tasks FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can create tasks in their household
CREATE POLICY "Users can create tasks"
  ON public.tasks FOR INSERT
  WITH CHECK (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can update tasks in their household
CREATE POLICY "Users can update tasks"
  ON public.tasks FOR UPDATE
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Only owners can delete tasks
CREATE POLICY "Owners can delete tasks"
  ON public.tasks FOR DELETE
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid() AND role = 'owner'
  ));

-- ============================================
-- LEDGER_ENTRIES TABLE
-- ============================================

-- Users can see their own ledger entries
CREATE POLICY "Users can view own ledger"
  ON public.ledger_entries FOR SELECT
  USING (user_id = auth.uid());

-- No INSERT/UPDATE/DELETE via RLS - only via RPC functions
-- This ensures immutability

-- ============================================
-- IDEMPOTENCY_KEYS TABLE
-- ============================================

-- Users can only see their own idempotency keys
CREATE POLICY "Users can view own keys"
  ON public.idempotency_keys FOR SELECT
  USING (user_id = auth.uid());

-- Users can create idempotency keys
CREATE POLICY "Users can create keys"
  ON public.idempotency_keys FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- No UPDATE or DELETE - keys are immutable

-- ============================================
-- EXPENSES TABLE
-- ============================================

-- Users can see expenses from their households
CREATE POLICY "Users can view household expenses"
  ON public.expenses FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can create expenses
CREATE POLICY "Users can create expenses"
  ON public.expenses FOR INSERT
  WITH CHECK (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can update expenses they created
CREATE POLICY "Users can update own expenses"
  ON public.expenses FOR UPDATE
  USING (created_by_id = auth.uid());

-- Only owners can delete expenses
CREATE POLICY "Owners can delete expenses"
  ON public.expenses FOR DELETE
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid() AND role = 'owner'
  ));

-- ============================================
-- EXPENSE_SPLITS TABLE
-- ============================================

-- Users can see splits for expenses in their household
CREATE POLICY "Users can view expense splits"
  ON public.expense_splits FOR SELECT
  USING (expense_id IN (
    SELECT id FROM public.expenses 
    WHERE household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid()
    )
  ));

-- Users can create splits
CREATE POLICY "Users can create splits"
  ON public.expense_splits FOR INSERT
  WITH CHECK (expense_id IN (
    SELECT id FROM public.expenses 
    WHERE household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid()
    )
  ));

-- ============================================
-- SYSTEM_EVENTS TABLE
-- ============================================

-- Users can see events from their household
CREATE POLICY "Users can view household events"
  ON public.system_events FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can create events (via RPC)
CREATE POLICY "Users can create events"
  ON public.system_events FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    OR household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid()
    )
  );

-- ============================================
-- AUDIT_LOGS TABLE
-- ============================================

-- Users can see audit logs from their household
CREATE POLICY "Users can view household audits"
  ON public.audit_logs FOR SELECT
  USING (household_id IN (
    SELECT household_id FROM public.household_members 
    WHERE user_id = auth.uid()
  ));

-- Users can create audit logs (via RPC)
CREATE POLICY "Users can create audits"
  ON public.audit_logs FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    OR household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid()
    )
  );

-- ============================================
-- INTEGRITY_CHECKS TABLE
-- ============================================

-- Only service role can access (no user access)
-- This table is for admin monitoring only
CREATE POLICY "No user access to integrity checks"
  ON public.integrity_checks FOR ALL
  USING (false);

-- ============================================
-- ALERTS TABLE
-- ============================================

-- Only service role can access (no user access)
-- This table is for admin monitoring only
CREATE POLICY "No user access to alerts"
  ON public.alerts FOR ALL
  USING (false);
