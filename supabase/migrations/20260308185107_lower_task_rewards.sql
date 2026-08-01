-- Reconstructed from remote migration history (version 20260308185107).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

UPDATE task_templates SET coin_reward = 1 WHERE coin_reward > 1;
