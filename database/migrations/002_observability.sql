-- ============================================
-- OBSERVABILITY MIGRATION
-- System events, audit logs, integrity checks, alerts
-- ============================================

-- ============================================
-- SYSTEM EVENTS TABLE (Logging estructurado)
-- ============================================

CREATE TABLE IF NOT EXISTS public.system_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  request_id TEXT,
  user_id UUID,
  event_type TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  household_id UUID,
  operation TEXT,
  result TEXT,  -- 'success', 'failure', 'error'
  duration_ms INTEGER,
  metadata JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  source TEXT  -- 'rpc', 'api', 'admin_script', etc.
);

-- Índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_system_events_request_id ON public.system_events(request_id);
CREATE INDEX IF NOT EXISTS idx_system_events_user_id ON public.system_events(user_id);
CREATE INDEX IF NOT EXISTS idx_system_events_entity ON public.system_events(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_system_events_household ON public.system_events(household_id);
CREATE INDEX IF NOT EXISTS idx_system_events_created_at ON public.system_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_system_events_event_type ON public.system_events(event_type);
CREATE INDEX IF NOT EXISTS idx_system_events_result ON public.system_events(result);
CREATE INDEX IF NOT EXISTS idx_system_events_metadata ON public.system_events USING gin(metadata);

-- ============================================
-- AUDIT LOGS TABLE (Auditoría inmutable)
-- ============================================

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  request_id TEXT,
  user_id UUID NOT NULL,
  household_id UUID,
  action TEXT NOT NULL,  -- 'complete_task', 'verify_task', 'create_expense', etc.
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  old_value JSONB,
  new_value JSONB,
  reason TEXT,
  ip_address INET,
  user_agent TEXT,
  source TEXT  -- 'api', 'rpc', 'admin', etc.
);

-- Índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_household ON public.audit_logs(household_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_request_id ON public.audit_logs(request_id);

-- ============================================
-- INTEGRITY CHECKS TABLE (Para guardar resultados de reconciliación)
-- ============================================

CREATE TABLE IF NOT EXISTS public.integrity_checks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  check_type TEXT NOT NULL,  -- 'task_without_ledger', 'orphaned_ledger', 'negative_balance'
  check_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  severity TEXT NOT NULL,  -- 'low', 'medium', 'high', 'critical'
  entity_type TEXT,
  entity_id UUID,
  household_id UUID,
  issue_description TEXT,
  metadata JSONB DEFAULT '{}',
  resolved BOOLEAN DEFAULT FALSE,
  resolved_at TIMESTAMPTZ,
  resolved_by TEXT,
  resolution_notes TEXT
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_integrity_checks_type ON public.integrity_checks(check_type);
CREATE INDEX IF NOT EXISTS idx_integrity_checks_severity ON public.integrity_checks(severity);
CREATE INDEX IF NOT EXISTS idx_integrity_checks_resolved ON public.integrity_checks(resolved);
CREATE INDEX IF NOT EXISTS idx_integrity_checks_date ON public.integrity_checks(check_date DESC);

-- ============================================
-- ALERTS TABLE (Para almacenar alertas)
-- ============================================

CREATE TABLE IF NOT EXISTS public.alerts (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  severity TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  source TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  job_id TEXT,
  resolved BOOLEAN DEFAULT FALSE,
  resolved_at TIMESTAMPTZ,
  resolved_by TEXT,
  resolution_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON public.alerts(severity);
CREATE INDEX IF NOT EXISTS idx_alerts_resolved ON public.alerts(resolved);
CREATE INDEX IF NOT EXISTS idx_alerts_type ON public.alerts(type);
CREATE INDEX IF NOT EXISTS idx_alerts_job_id ON public.alerts(job_id);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON public.alerts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_metadata ON public.alerts USING gin(metadata);

-- ============================================
-- AGGREGAR COLUMNAS DE AUDITORÍA A LEDGER_ENTRIES
-- ============================================

ALTER TABLE public.ledger_entries
ADD COLUMN IF NOT EXISTS created_by TEXT,
ADD COLUMN IF NOT EXISTS source TEXT;

CREATE INDEX IF NOT EXISTS idx_ledger_entries_source ON public.ledger_entries(source);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_created_by ON public.ledger_entries(created_by);

-- ============================================
-- GRANTS
-- ============================================

-- Grant permissions on observability tables
GRANT SELECT, INSERT ON public.system_events TO authenticated;
GRANT SELECT, INSERT ON public.audit_logs TO authenticated;
GRANT SELECT, INSERT ON public.integrity_checks TO authenticated;
GRANT SELECT, INSERT ON public.alerts TO authenticated;

-- Grant permissions on ledger_entries columns
GRANT UPDATE (created_by, source) ON public.ledger_entries TO authenticated;

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE public.system_events IS 'Structured logging for observability and debugging';
COMMENT ON TABLE public.audit_logs IS 'Immutable audit trail of all operations';
COMMENT ON TABLE public.integrity_checks IS 'Results of automated integrity checks';
COMMENT ON TABLE public.alerts IS 'System alerts for issues detected by checks';
