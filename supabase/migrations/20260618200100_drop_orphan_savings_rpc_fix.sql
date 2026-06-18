-- Corrective drop for the orphaned add_savings_contribution RPC.
--
-- The previous migration dropped the (uuid, uuid, numeric, text) signature, but
-- the function deployed in prod had drifted to (uuid, uuid, uuid, numeric, text)
-- (an extra p_household_id arg) outside tracked migrations, so the drop was a
-- no-op. Drop every overload by name to be signature-agnostic and survive both
-- the prod state and a fresh rebuild.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as sig
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'add_savings_contribution'
  loop
    execute 'drop function ' || r.sig::text;
  end loop;
end $$;
