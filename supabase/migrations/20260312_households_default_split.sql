-- Add default_split_ratio to households
-- Value between 0 and 1 (0.5 = 50/50, 0.7 = 70/30, etc.)
ALTER TABLE households ADD COLUMN IF NOT EXISTS default_split_ratio DOUBLE PRECISION DEFAULT 0.5;

-- Add constraint to ensure valid ratio
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'valid_split_ratio'
    ) THEN
        ALTER TABLE households ADD CONSTRAINT valid_split_ratio CHECK (default_split_ratio >= 0 AND default_split_ratio <= 1);
    END IF;
END $$;
