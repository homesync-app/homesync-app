-- Add type column to expense_templates to support income recurring entries
ALTER TABLE expense_templates
  ADD COLUMN IF NOT EXISTS type TEXT NOT NULL DEFAULT 'expense'
    CHECK (type IN ('expense', 'income'));
