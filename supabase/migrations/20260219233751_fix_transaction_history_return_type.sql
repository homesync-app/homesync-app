-- Reconstructed from remote migration history (version 20260219233751).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Drop and recreate function with correct return type
DROP FUNCTION IF EXISTS get_transaction_history(UUID, INTEGER, INTEGER, TEXT);

CREATE OR REPLACE FUNCTION get_transaction_history(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0,
  p_type_filter TEXT DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  type TEXT,
  amount INTEGER,
  currency TEXT,
  description TEXT,
  reference_type TEXT,
  reference_id TEXT,
  created_at TIMESTAMPTZ,
  balance_after INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH running_balance AS (
    SELECT 
      le.id,
      le.type,
      le.amount,
      le.currency,
      le.description,
      le.reference_type,
      le.reference_id,
      le.created_at,
      SUM(le.amount) OVER (
        PARTITION BY le.currency 
        ORDER BY le.created_at 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      ) as balance
    FROM ledger_entries le
    WHERE le.user_id = p_user_id
    AND le.currency = 'COIN'
    AND (p_type_filter IS NULL OR le.type = p_type_filter)
  )
  SELECT 
    rb.id,
    rb.type,
    rb.amount,
    rb.currency,
    rb.description,
    rb.reference_type,
    rb.reference_id,
    rb.created_at,
    rb.balance::INTEGER as balance_after
  FROM running_balance rb
  ORDER BY rb.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
;