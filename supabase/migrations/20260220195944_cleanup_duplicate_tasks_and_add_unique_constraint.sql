-- Reconstructed from remote migration history (version 20260220195944).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 1. Delete duplicate tasks keeping the EARLIEST per (title, category, household_id) Ã”Ã¶Ã‡Ã”Ã¶Ã‡
DELETE FROM tasks
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY LOWER(TRIM(title)), category, household_id
             ORDER BY created_at ASC
           ) AS rn
    FROM tasks
  ) ranked
  WHERE rn > 1
);

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 2. Prevent future duplicates with a unique index (case-insensitive) Ã”Ã¶Ã‡Ã”Ã¶Ã‡
CREATE UNIQUE INDEX IF NOT EXISTS tasks_unique_per_household
  ON tasks (LOWER(TRIM(title)), COALESCE(category, 'general'), household_id)
  WHERE status != 'completed';
;