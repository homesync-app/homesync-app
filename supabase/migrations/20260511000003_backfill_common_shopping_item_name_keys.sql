-- Backfill the common products visible in existing shopping lists.
-- The client also resolves old catalog names locally, so custom/free-text items
-- remain untouched and still display exactly as the user wrote them.

with catalog(name_key, es_name, en_name) as (
  values
    ('flankSteak', 'Vacío', 'Flank steak'),
    ('pumpkin', 'Zapallo', 'Pumpkin'),
    ('avocado', 'Palta', 'Avocado'),
    ('banana', 'Banana', 'Banana'),
    ('pasta', 'Fideos', 'Pasta'),
    ('detergent', 'Detergente', 'Detergent'),
    ('chicken', 'Pollo', 'Chicken'),
    ('spinach', 'Espinaca', 'Spinach'),
    ('eggs', 'Huevos', 'Eggs'),
    ('fish', 'Pescado', 'Fish'),
    ('tomato', 'Tomate', 'Tomato')
)
update public.shopping_items si
set name_key = catalog.name_key
from catalog
where si.name_key is null
  and lower(trim(si.name)) in (lower(catalog.es_name), lower(catalog.en_name));
