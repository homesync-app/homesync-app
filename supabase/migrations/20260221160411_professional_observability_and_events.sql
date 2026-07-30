-- Reconstructed from remote migration history (version 20260221160411).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- ============================================
-- 1. PROFESSIONAL ACTIVITY FEED (EVENT SOURCING)
-- ============================================

CREATE TABLE IF NOT EXISTS public.household_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL, -- 'task_completed', 'expense_added', 'reward_redeemed', 'member_joined'
  title TEXT NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}', -- Store snapshot of data (e.g., amount, xp, category)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activities_household_time ON public.household_activities(household_id, created_at DESC);
GRANT SELECT, INSERT ON public.household_activities TO authenticated;

-- ============================================
-- 2. CLIENT-SIDE ERROR LOGGING
-- ============================================

CREATE TABLE IF NOT EXISTS public.application_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id),
  level TEXT NOT NULL, -- 'error', 'warning', 'info'
  message TEXT NOT NULL,
  stack_trace TEXT,
  context JSONB DEFAULT '{}',
  device_info JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_logs_level ON public.application_logs(level);
CREATE INDEX IF NOT EXISTS idx_app_logs_time ON public.application_logs(created_at DESC);
GRANT INSERT, SELECT ON public.application_logs TO authenticated;

-- ============================================
-- 3. DIAGNOSTICS RPC (The "Repair" Helper)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_system_diagnostics(p_limit INTEGER DEFAULT 10)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_error_count INTEGER;
  v_recent_errors JSONB;
  v_integrity_issues JSONB;
BEGIN
  -- Count recent failures in system_events
  SELECT COUNT(*) INTO v_error_count 
  FROM public.system_events 
  WHERE result = 'failure' AND created_at > NOW() - INTERVAL '24 hours';

  -- Get last X errors from app_logs
  SELECT jsonb_agg(t) INTO v_recent_errors FROM (
    SELECT level, message, created_at 
    FROM public.application_logs 
    ORDER BY created_at DESC LIMIT p_limit
  ) t;

  -- Get unresolved integrity issues
  SELECT jsonb_agg(t) INTO v_integrity_issues FROM (
    SELECT check_type, severity, issue_description 
    FROM public.integrity_checks 
    WHERE resolved = FALSE LIMIT p_limit
  ) t;

  RETURN jsonb_build_object(
    'status', CASE WHEN v_error_count > 5 THEN 'unstable' ELSE 'healthy' END,
    'recent_system_failures_24h', v_error_count,
    'recent_app_logs', COALESCE(v_recent_errors, '[]'::jsonb),
    'integrity_issues', COALESCE(v_integrity_issues, '[]'::jsonb)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_system_diagnostics(INTEGER) TO authenticated;

-- ============================================
-- 4. RECONCILIATION TOOL (Self-Repair)
-- ============================================

CREATE OR REPLACE FUNCTION public.reconcile_points_and_history(p_household_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_fixed_tasks INTEGER := 0;
  v_fixed_activities INTEGER := 0;
BEGIN
  -- 1. Create missing activity entries for completed tasks
  INSERT INTO public.household_activities (household_id, user_id, event_type, title, metadata, created_at)
  SELECT 
    t.household_id, 
    COALESCE(t.completed_by, t.assigned_to), 
    'task_completed', 
    t.title,
    jsonb_build_object('xp', t.xp_reward, 'coins', t.coin_reward, 'category', t.category, 'task_id', t.id),
    COALESCE(t.completed_at, t.updated_at)
  FROM public.tasks t
  LEFT JOIN public.household_activities a ON (a.metadata->>'task_id')::uuid = t.id
  WHERE t.status IN ('pending_verification', 'verified', 'objected')
  AND t.household_id = p_household_id
  AND a.id IS NULL;
  
  GET DIAGNOSTICS v_fixed_activities = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'activities_reconstructed', v_fixed_activities,
    'message', 'Data reconciliation completed'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.reconcile_points_and_history(UUID) TO authenticated;
;