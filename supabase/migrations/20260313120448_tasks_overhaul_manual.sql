-- Reconstructed from remote migration history (version 20260313120448).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Overhaul categories and task templates
BEGIN;

-- 1. Truncate existing templates and categories
TRUNCATE TABLE task_templates CASCADE;
TRUNCATE TABLE categories CASCADE;

-- 2. Insert new Categories
INSERT INTO categories (id, name, icon, color, sort_order) VALUES
('limpieza', 'Limpieza general', 'Â­Æ’Âºâ•£', '#6366F1', 1),
('cocina', 'Cocina', 'Â­Æ’Ã¬â”‚', '#EF4444', 2),
('dormitorio', 'Dormitorio', 'Â­Æ’Ã¸Ã…Â´Â©Ã…', '#3B82F6', 3),
('baâ”œâ–’o', 'Baâ”œâ–’o', 'Â­Æ’Ãœâ”', '#06B6D4', 4),
('sala', 'Espacios comunes', 'Â­Æ’Ã¸Ã¯Â´Â©Ã…', '#FB923C', 5),
('ropa', 'Ropa', 'Â­Æ’Ã¦Ã²', '#EC4899', 6),
('residuos', 'Basura / reciclaje', 'Â­Æ’Ã¹Ã¦Â´Â©Ã…', '#64748B', 7),
('compras', 'Compras / organizaciâ”œâ”‚n', 'Â­Æ’Ã¸Ã†', '#10B981', 8),
('mascotas', 'Mascotas', 'Â­Æ’Ã‰Â¥', '#A16207', 9),
('exterior', 'Exterior / jardâ”œÂ¡n', 'Â­Æ’Ã®â”', '#22C55E', 10),
('mantenimiento', 'Mantenimiento del hogar', 'Â­Æ’Ã¶Âº', '#475569', 11),
('niâ”œâ–’os', 'Niâ”œâ–’os / cuidado', 'Â­Æ’Ã¦Ã‚', '#F59E0B', 12),
('administracion', 'Administraciâ”œâ”‚n del hogar', 'Â­Æ’Ã´Ã¯', '#8B5CF6', 13);

-- 3. Insert new Task Templates
-- Limpieza general
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('limpieza', 'Barrer pisos', 'normal', 15, 1, 1),
('limpieza', 'Aspirar pisos o alfombras', 'normal', 15, 1, 2),
('limpieza', 'Trapear / fregar pisos', 'normal', 15, 1, 3),
('limpieza', 'Limpiar polvo de muebles', 'normal', 15, 1, 4),
('limpieza', 'Limpiar ventanas', 'big', 35, 2, 5),
('limpieza', 'Orden general de la casa', 'normal', 15, 1, 6),
('limpieza', 'Limpieza profunda general', 'heavy', 50, 2, 7);

-- Cocina
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('cocina', 'Lavar los platos', 'normal', 15, 1, 1),
('cocina', 'Guardar / vaciar lavavajillas', 'normal', 15, 1, 2),
('cocina', 'Cocinar comida sencilla', 'normal', 15, 1, 3),
('cocina', 'Cocinar comida completa', 'big', 35, 2, 4),
('cocina', 'Poner la mesa', 'small', 5, 0, 5),
('cocina', 'Levantar la mesa', 'small', 5, 0, 6),
('cocina', 'Limpiar mesada y superficies', 'small', 5, 0, 7),
('cocina', 'Limpiar cocina completa', 'big', 35, 2, 8),
('cocina', 'Limpiar heladera', 'big', 35, 2, 9),
('cocina', 'Limpiar horno', 'big', 35, 2, 10),
('cocina', 'Organizar despensa', 'normal', 15, 1, 11);

-- Dormitorio
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('dormitorio', 'Hacer la cama', 'small', 5, 0, 1),
('dormitorio', 'Ordenar habitaciâ”œâ”‚n', 'normal', 15, 1, 2),
('dormitorio', 'Cambiar sâ”œÃ­banas', 'big', 35, 2, 3),
('dormitorio', 'Ordenar placard', 'big', 35, 2, 4),
('dormitorio', 'Limpieza general del dormitorio', 'normal', 15, 1, 5);

-- Baâ”œâ–’o
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('baâ”œâ–’o', 'Limpiar inodoro', 'normal', 15, 1, 1),
('baâ”œâ–’o', 'Limpiar lavamanos', 'small', 5, 0, 2),
('baâ”œâ–’o', 'Limpiar espejo', 'small', 5, 0, 3),
('baâ”œâ–’o', 'Limpiar ducha / baâ”œâ–’era', 'big', 35, 2, 4),
('baâ”œâ–’o', 'Reponer papel higiâ”œÂ®nico o jabâ”œâ”‚n', 'small', 5, 0, 5),
('baâ”œâ–’o', 'Limpieza completa del baâ”œâ–’o', 'big', 35, 2, 6);

-- Espacios comunes
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('sala', 'Ordenar sala / living', 'normal', 15, 1, 1),
('sala', 'Limpiar muebles', 'normal', 15, 1, 2),
('sala', 'Limpiar sillones', 'normal', 15, 1, 3),
('sala', 'Limpiar mesa del comedor', 'small', 5, 0, 4),
('sala', 'Aspirar o limpiar â”œÃ­rea comâ”œâ•‘n', 'normal', 15, 1, 5);

-- Ropa
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('ropa', 'Lavar ropa', 'normal', 15, 1, 1),
('ropa', 'Tender ropa', 'normal', 15, 1, 2),
('ropa', 'Usar secadora', 'small', 5, 0, 3),
('ropa', 'Doblar y guardar ropa', 'normal', 15, 1, 4),
('ropa', 'Planchar ropa', 'normal', 15, 1, 5),
('ropa', 'Cambiar toallas', 'small', 5, 0, 6),
('ropa', 'Organizar placard', 'big', 35, 2, 7);

-- Basura
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('residuos', 'Sacar la basura', 'small', 5, 0, 1),
('residuos', 'Separar reciclaje', 'small', 5, 0, 2),
('residuos', 'Llevar reciclaje', 'normal', 15, 1, 3);

-- Compras
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('compras', 'Hacer lista de compras', 'small', 5, 0, 1),
('compras', 'Ir al supermercado', 'big', 35, 2, 2),
('compras', 'Guardar compras', 'normal', 15, 1, 3),
('compras', 'Planificar menâ”œâ•‘ semanal', 'normal', 15, 1, 4);

-- Mascotas
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('mascotas', 'Dar de comer a la mascota', 'small', 5, 0, 1),
('mascotas', 'Pasear mascota', 'normal', 15, 1, 2),
('mascotas', 'Limpiar arenero / â”œÃ­rea', 'normal', 15, 1, 3),
('mascotas', 'Baâ”œâ–’ar mascota', 'big', 35, 2, 4),
('mascotas', 'Limpieza general de zona de mascota', 'normal', 15, 1, 5);

-- Exterior
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('exterior', 'Regar plantas', 'small', 5, 0, 1),
('exterior', 'Limpiar patio / terraza', 'big', 35, 2, 2),
('exterior', 'Juntar hojas', 'normal', 15, 1, 3),
('exterior', 'Cortar câ”œÂ®sped', 'heavy', 50, 2, 4),
('exterior', 'Ordenar jardâ”œÂ¡n', 'normal', 15, 1, 5);

-- Mantenimiento
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('mantenimiento', 'Cambiar bombillas', 'small', 5, 0, 1),
('mantenimiento', 'Pequeâ”œâ–’o arreglo del hogar', 'normal', 15, 1, 2),
('mantenimiento', 'Revisiâ”œâ”‚n de filtros', 'normal', 15, 1, 3),
('mantenimiento', 'Desatascar desagâ”œâ•es', 'big', 35, 2, 4),
('mantenimiento', 'Arreglo mediano', 'big', 35, 2, 5),
('mantenimiento', 'Arreglo grande', 'heavy', 50, 2, 6);

-- Niâ”œâ–’os
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('niâ”œâ–’os', 'Ordenar juguetes', 'small', 5, 0, 1),
('niâ”œâ–’os', 'Dar de comer', 'normal', 15, 1, 2),
('niâ”œâ–’os', 'Ayudar con tareas escolares', 'big', 35, 2, 3),
('niâ”œâ–’os', 'Llevar o buscar del colegio', 'big', 35, 2, 4),
('niâ”œâ–’os', 'Baâ”œâ–’ar niâ”œâ–’os', 'normal', 15, 1, 5);

-- Administracion
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('administracion', 'Pagar facturas', 'small', 5, 0, 1),
('administracion', 'Revisar gastos del hogar', 'small', 5, 0, 2),
('administracion', 'Organizar documentos', 'normal', 15, 1, 3),
('administracion', 'Planificar tareas del hogar', 'small', 5, 0, 4);

COMMIT;
