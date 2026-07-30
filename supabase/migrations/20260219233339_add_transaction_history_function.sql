-- Reconstructed from remote migration history (version 20260219233339).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Function to get transaction history
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
  reference_id UUID,
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
    ORDER BY le.created_at DESC
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

-- Function to get transaction types
CREATE OR REPLACE FUNCTION get_transaction_types()
RETURNS TABLE(type TEXT, label TEXT, icon TEXT) AS $$
BEGIN
  RETURN QUERY VALUES
    ('task_completion', 'Tarea completada', 'Ã”Â£Ã '),
    ('coin_transfer', 'Coins enviados', 'Â­Æ’Ã´Ã±'),
    ('coin_received', 'Coins recibidos', 'Â­Æ’Ã´Ã‘'),
    ('reward_redemption', 'Canje de premio', 'Â­Æ’Ã„Ã¼'),
    ('xp_earned', 'XP ganado', 'Ã”Â¡Ã‰');
END;
$$ LANGUAGE plpgsql;
;