-- Correct the activity CTE union in get_home_bootstrap for databases that
-- already applied 20260519213000 before this local migration was fixed.

do $$
declare
  src text;
begin
  select pg_get_functiondef(
    'public.get_home_bootstrap(integer,integer,integer)'::regprocedure
  )
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
