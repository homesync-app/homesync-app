-- Reconstructed from remote migration history (version 20260526163514).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Vista de uso real de items en shopping_items (ultimos 90 dias) agrupados por
-- nombre normalizado. Devuelve TODO (no filtra por emoji), para que el admin
-- web pueda cruzarla con el manifest de iconos custom del Storage y detectar
-- productos sin icono / con emoji generico, ordenados por uso real.

create or replace view public.v_shopping_items_usage as
select
  lower(trim(name)) as normalized_name,
  (array_agg(name_key order by created_at desc)
     filter (where name_key is not null and name_key <> ''))[1] as primary_name_key,
  (array_agg(emoji order by created_at desc)
     filter (where emoji is not null and emoji <> ''))[1] as primary_emoji,
  count(*)::int as times_added,
  count(distinct household_id)::int as households_using,
  max(created_at) as last_added,
  array_agg(distinct name) as variations
from public.shopping_items
where created_at > now() - interval '90 days'
group by lower(trim(name));

grant select on public.v_shopping_items_usage to authenticated;
grant select on public.v_shopping_items_usage to anon;

comment on view public.v_shopping_items_usage is
  'Productos en shopping_items (ultimos 90 dias) agrupados por nombre normalizado. '
  'El admin web cruza esto con shopping-icons/manifest.json en Storage para '
  'detectar productos sin icono custom y priorizar futuras camadas.';
