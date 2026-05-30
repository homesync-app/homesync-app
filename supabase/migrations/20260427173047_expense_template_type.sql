-- Reconstructed from remote migration history (version 20260427173047).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE expense_templates
  ADD COLUMN IF NOT EXISTS type TEXT NOT NULL DEFAULT 'expense'
    CHECK (type IN ('expense', 'income'));
