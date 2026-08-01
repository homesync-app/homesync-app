-- Reconstructed from remote migration history (version 20260520001802).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

do $$
declare
  src text;
begin
  select pg_get_functiondef('public.get_home_bootstrap(integer,integer,integer)'::regprocedure)
    into src;

  src := replace(
    src,
    'select * from raw_activity
    union all
    select * from pending_approvals',
    'select id, type, created_at, creator_id, data from raw_activity
    union all
    select id, type, created_at, creator_id, data from pending_approvals'
  );

  execute src;
end $$;
