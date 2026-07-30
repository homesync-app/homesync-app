-- The reconstructed duplicate migration contains mojibake for the generic
-- shopping emoji. Restore the intended RPC body without changing its contract.

create or replace function public.upsert_catalog_request(
  p_name text,
  p_emoji text
) returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  insert into public.shopping_catalog_requests (
    name,
    emoji,
    total_count,
    first_seen_at,
    last_seen_at
  ) values (
    p_name,
    p_emoji,
    1,
    now(),
    now()
  )
  on conflict (name) do update
    set total_count = public.shopping_catalog_requests.total_count + 1,
        last_seen_at = now(),
        emoji = case
          when excluded.emoji <> '🛒' then excluded.emoji
          else public.shopping_catalog_requests.emoji
        end;
end;
$function$;
