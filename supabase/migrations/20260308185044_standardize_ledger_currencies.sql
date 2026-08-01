-- Reconstructed from remote migration history (version 20260308185044).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

UPDATE ledger_entries 
SET currency = 'XP' 
WHERE lower(currency) = 'xp' AND currency != 'XP';

UPDATE ledger_entries 
SET currency = 'COIN' 
WHERE lower(currency) IN ('coin', 'coins') AND currency != 'COIN';
