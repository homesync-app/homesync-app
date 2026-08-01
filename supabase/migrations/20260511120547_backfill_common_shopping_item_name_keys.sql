-- Reconstructed from remote migration history (version 20260511120547).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

with catalog(name_key, es_name, en_name) as (
  values
    ('flankSteak', 'Vacâ”œÂ¡o', 'Flank steak'),
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
