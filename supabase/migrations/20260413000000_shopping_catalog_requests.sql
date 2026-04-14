-- Tabla para trackear productos que los usuarios agregan y no están en el catálogo predefinido.
-- Se usa en el admin panel para identificar qué iconos/nombres agregar en futuras versiones.

create table if not exists shopping_catalog_requests (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  emoji       text        not null default '🛒',
  total_count integer     not null default 1,
  first_seen_at timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),
  constraint shopping_catalog_requests_name_key unique (name)
);

-- Solo los admins leen, el insert/upsert viene autenticado desde el cliente
alter table shopping_catalog_requests enable row level security;

-- Cualquier usuario autenticado puede insertar/incrementar (upsert anónimo por nombre)
create policy "authenticated can upsert catalog requests"
  on shopping_catalog_requests
  for all
  to authenticated
  using (true)
  with check (true);

-- Función para upsert: si ya existe incrementa el contador
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
        -- Actualizar emoji si el nuevo no es el genérico
        emoji        = case
                         when excluded.emoji != '🛒' then excluded.emoji
                         else shopping_catalog_requests.emoji
                       end;
end;
$$;
