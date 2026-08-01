-- Restore category keys and labels corrupted in the reconstructed catalog.
-- This runs before localization keys are mapped by exact category/title.

insert into public.categories (id, name, icon, color, sort_order) values
  ('limpieza', 'Limpieza general', '🧹', '#6366F1', 1),
  ('cocina', 'Cocina', '🍽️', '#EF4444', 2),
  ('dormitorio', 'Dormitorio', '🛌', '#3B82F6', 3),
  ('baño', 'Baño', '🚿', '#06B6D4', 4),
  ('sala', 'Espacios comunes', '🛋️', '#FB923C', 5),
  ('ropa', 'Ropa', '👕', '#EC4899', 6),
  ('residuos', 'Basura / reciclaje', '🗑️', '#64748B', 7),
  ('compras', 'Compras / organización', '🛒', '#10B981', 8),
  ('mascotas', 'Mascotas', '🐾', '#A16207', 9),
  ('exterior', 'Exterior / jardín', '🌿', '#22C55E', 10),
  ('mantenimiento', 'Mantenimiento del hogar', '🔧', '#475569', 11),
  ('niños', 'Niños / cuidado', '👶', '#F59E0B', 12),
  ('administracion', 'Administración del hogar', '📋', '#8B5CF6', 13)
on conflict (id) do update set
  name = excluded.name, icon = excluded.icon, color = excluded.color,
  sort_order = excluded.sort_order;

update public.task_templates tt set category_id = 'baño'
from public.categories c where c.id = tt.category_id and c.sort_order = 4 and c.id <> 'baño';
update public.task_templates tt set category_id = 'niños'
from public.categories c where c.id = tt.category_id and c.sort_order = 12 and c.id <> 'niños';
delete from public.categories where sort_order = 4 and id <> 'baño';
delete from public.categories where sort_order = 12 and id <> 'niños';

with restored(category_id, sort_order, title) as (values
  ('dormitorio', 2, 'Ordenar habitación'), ('dormitorio', 3, 'Cambiar sábanas'),
  ('baño', 4, 'Limpiar ducha / bañera'), ('baño', 5, 'Reponer papel higiénico o jabón'),
  ('baño', 6, 'Limpieza completa del baño'), ('sala', 5, 'Aspirar o limpiar área común'),
  ('compras', 4, 'Planificar menú semanal'), ('mascotas', 3, 'Limpiar arenero / área'),
  ('mascotas', 4, 'Bañar mascota'), ('exterior', 4, 'Cortar césped'),
  ('exterior', 5, 'Ordenar jardín'), ('mantenimiento', 2, 'Pequeño arreglo del hogar'),
  ('mantenimiento', 3, 'Revisión de filtros'), ('mantenimiento', 4, 'Desatascar desagües'),
  ('niños', 5, 'Bañar niños')
)
update public.task_templates tt set title = restored.title
from restored where tt.category_id = restored.category_id and tt.sort_order = restored.sort_order;
