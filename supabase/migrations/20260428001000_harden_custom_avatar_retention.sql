create index if not exists idx_custom_avatar_generations_household_id
  on public.custom_avatar_generations (household_id);

create or replace function public.enforce_free_avatar_when_not_premium()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  if coalesce(new.is_premium, false) = false
    and new.avatar_url is not null
    and (
      new.avatar_url like 'premium://%'
      or new.avatar_url like 'assets/images/custom_avatars/%'
      or new.avatar_url like '%/storage/v1/object/public/custom-avatars/%'
    )
  then
    new.avatar_url := chr(128049);
  end if;

  return new;
end;
$$;
