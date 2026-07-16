-- Cocina (#C6503B) y Ropa (#A05795) leían oscuros/apagados en las pills
-- tintadas de Tareas. Se suben en luminosidad y saturación manteniendo el
-- matiz para no chocar con el resto de la paleta Scandi-warm.
-- DEBE coincidir 1:1 con CategoryMapping.getCategoryColor en
-- flutter_client/lib/core/theme/category_mapping.dart.

UPDATE categories SET color = '#E15540' WHERE id = 'cocina';
UPDATE categories SET color = '#BC5BAA' WHERE id = 'ropa';
