-- Localizable shopping item catalog metadata.
-- Keeps custom shopping item names intact while allowing predefined products
-- to switch between Spanish and English after they were created.

alter table public.shopping_items
  add column if not exists name_key text;

create index if not exists idx_shopping_items_name_key
  on public.shopping_items(name_key)
  where name_key is not null;

comment on column public.shopping_items.name_key is
  'Stable client catalog key used to localize predefined shopping item names. Null for custom items.';
