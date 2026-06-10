-- Include weekly duel bonuses and any future COIN ledger movement in the user
-- balance RPC. The UI balance should be the ledger balance by currency, not a
-- whitelist of reward entry types.

create or replace function public.get_user_balance(
  p_user_id uuid,
  p_household_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid;
  v_xp integer := 0;
  v_coins integer := 0;
begin
  v_uid := public.current_app_user_id();

  if v_uid is null
     or v_uid <> p_user_id
     or not exists (
       select 1
       from public.household_members hm
       where hm.household_id = p_household_id
         and hm.user_id = v_uid
     ) then
    return jsonb_build_object(
      'xp', 0,
      'coins', 0
    );
  end if;

  select
    coalesce(sum(le.amount) filter (where upper(le.currency) = 'XP'), 0)::integer,
    coalesce(sum(le.amount) filter (where upper(le.currency) = 'COIN'), 0)::integer
  into v_xp, v_coins
  from public.ledger_entries le
  where le.household_id = p_household_id
    and le.user_id = p_user_id;

  return jsonb_build_object(
    'xp', coalesce(v_xp, 0),
    'coins', coalesce(v_coins, 0)
  );
end;
$function$;

revoke execute on function public.get_user_balance(uuid, uuid)
  from anon, public;
grant execute on function public.get_user_balance(uuid, uuid)
  to authenticated;

comment on function public.get_user_balance(uuid, uuid) is
  'Returns the current user XP and COIN ledger balance for one household, including weekly winner bonuses.';
