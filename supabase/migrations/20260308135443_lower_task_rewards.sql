-- Reconstructed from remote migration history (version 20260308135443).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Lower coin rewards in templates
UPDATE public.task_templates 
SET coin_reward = CASE 
  WHEN difficulty IN ('hard', 'Difâ”œÂ¡cil') THEN 2
  ELSE 1 
END;

-- Lower coin rewards in current active tasks
UPDATE public.tasks
SET coin_reward = CASE 
  WHEN difficulty IN ('hard', 'Difâ”œÂ¡cil') THEN 2
  ELSE 1 
END
WHERE status IN ('active', 'assigned', 'objected');
;