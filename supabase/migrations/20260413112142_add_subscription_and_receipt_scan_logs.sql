-- Reconstructed from remote migration history (version 20260413112142).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Tier de suscripciâ”œâ”‚n en households
ALTER TABLE households
  ADD COLUMN subscription_tier text NOT NULL DEFAULT 'free'
  CHECK (subscription_tier IN ('free', 'premium'));

-- Log de scans para contar uso mensual por household
CREATE TABLE receipt_scan_logs (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id uuid       NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  user_id      uuid       NOT NULL,
  scanned_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX receipt_scan_logs_household_month
  ON receipt_scan_logs (household_id, scanned_at);

ALTER TABLE receipt_scan_logs ENABLE ROW LEVEL SECURITY;

-- Los miembros del household pueden ver sus propios logs
CREATE POLICY "members can view scan logs"
  ON receipt_scan_logs FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM household_members WHERE user_id = auth.uid()
    )
  );
;