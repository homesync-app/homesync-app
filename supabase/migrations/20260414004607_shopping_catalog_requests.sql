-- Reconstructed from remote migration history (version 20260414004607).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Tabla para trackear productos que los usuarios agregan y no estâ”œÃ­n en el catâ”œÃ­logo predefinido.
-- Se usa en el admin panel para identificar quâ”œÂ® iconos/nombres agregar en futuras versiones.

create table if not exists shopping_catalog_requests (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  emoji       text        not null default 'Â­Æ’Ã¸Ã†',
  total_count integer     not null default 1,
  first_seen_at timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),
  constraint shopping_catalog_requests_name_key unique (name)
);

-- Solo los admins leen, el insert/upsert viene autenticado desde el cliente
alter table shopping_catalog_requests enable row level security;

-- Cualquier usuario autenticado puede insertar/incrementar (upsert anâ”œâ”‚nimo por nombre)
create policy "authenticated can upsert catalog requests"
  on shopping_catalog_requests
  for all
  to authenticated
  using (true)
  with check (true);

-- Funciâ”œâ”‚n para upsert: si ya existe incrementa el contador
create or replace function upsert_catalog_request(p_name text, p_emoji text)
returns void
language plpgsql
security definer
as $$
begin
  insert into shopping_catalog_requests (name, emoji, total_count, first_seen_at, last_seen_at)
  values (p_name, p_emoji, 1, now(), now())
  on conflict (name) do update
    set total_count  = shopping_catalog_requests.total_count + 1,
        last_seen_at = now(),
        -- Actualizar emoji si el nuevo no es el genâ”œÂ®rico
        emoji        = case
                         when excluded.emoji != 'Â­Æ’Ã¸Ã†' then excluded.emoji
                         else shopping_catalog_requests.emoji
                       end;
end;
$$;
