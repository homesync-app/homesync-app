-- Reconstructed from remote migration history (version 20260430110245).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


CREATE TABLE IF NOT EXISTS ocr_scan_logs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  household_id    uuid REFERENCES households ON DELETE SET NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  ai_merchant     text,
  ai_confidence   numeric,
  ai_raw_items    jsonb NOT NULL DEFAULT '[]'::jsonb,
  matcher_result  jsonb NOT NULL DEFAULT '{}'::jsonb,
  user_action     text,
  tier            text
);

CREATE INDEX IF NOT EXISTS ocr_scan_logs_created_at_idx ON ocr_scan_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS ocr_scan_logs_user_id_idx   ON ocr_scan_logs(user_id);

ALTER TABLE ocr_scan_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users insert own logs" ON ocr_scan_logs;
CREATE POLICY "users insert own logs"
  ON ocr_scan_logs FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "users update own logs" ON ocr_scan_logs;
CREATE POLICY "users update own logs"
  ON ocr_scan_logs FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "admins read all logs" ON ocr_scan_logs;
CREATE POLICY "admins read all logs"
  ON ocr_scan_logs FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND is_admin = true));

CREATE OR REPLACE VIEW v_ocr_unmatched_items AS
SELECT
  jsonb_array_elements_text(matcher_result->'unrecognized') AS raw_text,
  COUNT(*)                       AS occurrences,
  COUNT(DISTINCT user_id)        AS distinct_users,
  MAX(created_at)                AS last_seen
FROM ocr_scan_logs
WHERE created_at > now() - interval '60 days'
  AND matcher_result ? 'unrecognized'
GROUP BY raw_text
ORDER BY occurrences DESC;

CREATE OR REPLACE VIEW v_ocr_dropped_items AS
SELECT
  jsonb_array_elements_text(matcher_result->'dropped') AS raw_text,
  COUNT(*)                AS occurrences,
  COUNT(DISTINCT user_id) AS distinct_users,
  MAX(created_at)         AS last_seen
FROM ocr_scan_logs
WHERE created_at > now() - interval '60 days'
  AND matcher_result ? 'dropped'
GROUP BY raw_text
ORDER BY occurrences DESC;

CREATE OR REPLACE VIEW v_manual_items_no_icon AS
SELECT
  lower(trim(name))             AS normalized_name,
  COUNT(*)                      AS times_added,
  COUNT(DISTINCT household_id)  AS households_using,
  MAX(created_at)               AS last_added,
  array_agg(DISTINCT name)      AS variations
FROM shopping_items
WHERE (emoji IS NULL OR emoji = '' OR emoji = 'Â­Æ’Ã¸Ã†')
  AND created_at > now() - interval '60 days'
GROUP BY lower(trim(name))
HAVING COUNT(*) >= 1
ORDER BY times_added DESC, households_using DESC;

CREATE OR REPLACE VIEW v_ocr_daily_stats AS
SELECT
  date_trunc('day', created_at)::date     AS day,
  COUNT(*)                                AS total_scans,
  ROUND(AVG(ai_confidence)::numeric, 2)   AS avg_confidence,
  ROUND(AVG(jsonb_array_length(COALESCE(matcher_result->'matched','[]'::jsonb)))::numeric, 1)      AS avg_matched,
  ROUND(AVG(jsonb_array_length(COALESCE(matcher_result->'to_add','[]'::jsonb)))::numeric, 1)        AS avg_to_add,
  ROUND(AVG(jsonb_array_length(COALESCE(matcher_result->'unrecognized','[]'::jsonb)))::numeric, 1) AS avg_unmatched,
  ROUND(AVG(jsonb_array_length(COALESCE(matcher_result->'dropped','[]'::jsonb)))::numeric, 1)       AS avg_dropped,
  COUNT(*) FILTER (WHERE user_action = 'confirmed')   AS confirmed,
  COUNT(*) FILTER (WHERE user_action = 'cancelled')   AS cancelled,
  ROUND(COUNT(*) FILTER (WHERE user_action = 'confirmed') * 100.0 / NULLIF(COUNT(*), 0), 1) AS confirm_rate_pct
FROM ocr_scan_logs
GROUP BY 1
ORDER BY 1 DESC;

GRANT SELECT ON v_ocr_unmatched_items, v_ocr_dropped_items, v_manual_items_no_icon, v_ocr_daily_stats TO authenticated;
;