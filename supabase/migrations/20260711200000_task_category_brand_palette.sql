-- Paleta de marca para las categorías de tareas.
-- La seed original (20260313120448) usaba colores Tailwind fríos con choques
-- de matiz (cocina #EF4444 vs ropa #EC4899 indistinguibles como tinte al 10%).
-- Estos 13 tonos están separados en matiz y calibrados al look Scandi-warm.
-- DEBE coincidir 1:1 con CategoryMapping.getCategoryColor en
-- flutter_client/lib/core/theme/category_mapping.dart.
--
-- Re-asserta también name/icon: el archivo reconstruido de la seed quedó con
-- mojibake, así que un entorno fresco heredaría textos corruptos sin esto.

UPDATE categories SET color = '#5A94E1', name = 'Limpieza general',         icon = '🧹' WHERE id = 'limpieza';
UPDATE categories SET color = '#C6503B', name = 'Cocina',                   icon = '🍽️' WHERE id = 'cocina';
UPDATE categories SET color = '#9575CD', name = 'Dormitorio',               icon = '🛌' WHERE id = 'dormitorio';
UPDATE categories SET color = '#3F9FA8', name = 'Baño',                     icon = '🚿' WHERE id = 'baño';
UPDATE categories SET color = '#C08A33', name = 'Espacios comunes',         icon = '🛋️' WHERE id = 'sala';
UPDATE categories SET color = '#A05795', name = 'Ropa',                     icon = '👕' WHERE id = 'ropa';
UPDATE categories SET color = '#8A8078', name = 'Basura / reciclaje',       icon = '🗑️' WHERE id = 'residuos';
UPDATE categories SET color = '#4E9E6B', name = 'Compras / organización',   icon = '🛒' WHERE id = 'compras';
UPDATE categories SET color = '#A97045', name = 'Mascotas',                 icon = '🐾' WHERE id = 'mascotas';
UPDATE categories SET color = '#7FA045', name = 'Exterior / jardín',        icon = '🌿' WHERE id = 'exterior';
UPDATE categories SET color = '#64748B', name = 'Mantenimiento del hogar',  icon = '🔧' WHERE id = 'mantenimiento';
UPDATE categories SET color = '#D96A8B', name = 'Niños / cuidado',          icon = '👶' WHERE id = 'niños';
UPDATE categories SET color = '#6D62C4', name = 'Administración del hogar', icon = '📋' WHERE id = 'administracion';
