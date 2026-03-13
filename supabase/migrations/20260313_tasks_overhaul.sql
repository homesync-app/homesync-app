-- Overhaul categories and task templates
BEGIN;

-- 1. Truncate existing templates and categories (careful with foreign keys)
-- We use CASCADE if there are other tables referencing them, but usually they are just templates
TRUNCATE TABLE task_templates CASCADE;
TRUNCATE TABLE categories CASCADE;

-- 2. Insert new Categories
INSERT INTO categories (id, name, icon, color, sort_order) VALUES
('limpieza', 'Limpieza general', '🧹', '#6366F1', 1),
('cocina', 'Cocina', '🍳', '#EF4444', 2),
('dormitorio', 'Dormitorio', '🛏️', '#3B82F6', 3),
('baño', 'Baño', '🚿', '#06B6D4', 4),
('sala', 'Espacios comunes', '🛋️', '#FB923C', 5),
('ropa', 'Ropa', '👕', '#EC4899', 6),
('residuos', 'Basura / reciclaje', '🗑️', '#64748B', 7),
('compras', 'Compras / organización', '🛒', '#10B981', 8),
('mascotas', 'Mascotas', '🐾', '#A16207', 9),
('exterior', 'Exterior / jardín', '🌿', '#22C55E', 10),
('mantenimiento', 'Mantenimiento del hogar', '🔧', '#475569', 11),
('niños', 'Niños / cuidado', '👶', '#F59E0B', 12),
('administracion', 'Administración del hogar', '📋', '#8B5CF6', 13);

-- 3. Insert new Task Templates
-- Difficulty: small (+5 XP, 0 Coins), normal (+15 XP, 1 Coin), big (+35 XP, 2 Coins), heavy (+50 XP, 2 Coins)

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
('dormitorio', 'Ordenar habitación', 'normal', 15, 1, 2),
('dormitorio', 'Cambiar sábanas', 'big', 35, 2, 3),
('dormitorio', 'Ordenar placard', 'big', 35, 2, 4),
('dormitorio', 'Limpieza general del dormitorio', 'normal', 15, 1, 5);

-- Baño
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('baño', 'Limpiar inodoro', 'normal', 15, 1, 1),
('baño', 'Limpiar lavamanos', 'small', 5, 0, 2),
('baño', 'Limpiar espejo', 'small', 5, 0, 3),
('baño', 'Limpiar ducha / bañera', 'big', 35, 2, 4),
('baño', 'Reponer papel higiénico o jabón', 'small', 5, 0, 5),
('baño', 'Limpieza completa del baño', 'big', 35, 2, 6);

-- Espacios comunes
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('sala', 'Ordenar sala / living', 'normal', 15, 1, 1),
('sala', 'Limpiar muebles', 'normal', 15, 1, 2),
('sala', 'Limpiar sillones', 'normal', 15, 1, 3),
('sala', 'Limpiar mesa del comedor', 'small', 5, 0, 4),
('sala', 'Aspirar o limpiar área común', 'normal', 15, 1, 5);

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
('compras', 'Planificar menú semanal', 'normal', 15, 1, 4);

-- Mascotas
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('mascotas', 'Dar de comer a la mascota', 'small', 5, 0, 1),
('mascotas', 'Pasear mascota', 'normal', 15, 1, 2),
('mascotas', 'Limpiar arenero / área', 'normal', 15, 1, 3),
('mascotas', 'Bañar mascota', 'big', 35, 2, 4),
('mascotas', 'Limpieza general de zona de mascota', 'normal', 15, 1, 5);

-- Exterior
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('exterior', 'Regar plantas', 'small', 5, 0, 1),
('exterior', 'Limpiar patio / terraza', 'big', 35, 2, 2),
('exterior', 'Juntar hojas', 'normal', 15, 1, 3),
('exterior', 'Cortar césped', 'heavy', 50, 2, 4),
('exterior', 'Ordenar jardín', 'normal', 15, 1, 5);

-- Mantenimiento
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('mantenimiento', 'Cambiar bombillas', 'small', 5, 0, 1),
('mantenimiento', 'Pequeño arreglo del hogar', 'normal', 15, 1, 2),
('mantenimiento', 'Revisión de filtros', 'normal', 15, 1, 3),
('mantenimiento', 'Desatascar desagües', 'big', 35, 2, 4),
('mantenimiento', 'Arreglo mediano', 'big', 35, 2, 5),
('mantenimiento', 'Arreglo grande', 'heavy', 50, 2, 6);

-- Niños
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('niños', 'Ordenar juguetes', 'small', 5, 0, 1),
('niños', 'Dar de comer', 'normal', 15, 1, 2),
('niños', 'Ayudar con tareas escolares', 'big', 35, 2, 3),
('niños', 'Llevar o buscar del colegio', 'big', 35, 2, 4),
('niños', 'Bañar niños', 'normal', 15, 1, 5);

-- Administracion
INSERT INTO task_templates (category_id, title, difficulty, xp_reward, coin_reward, sort_order) VALUES
('administracion', 'Pagar facturas', 'small', 5, 0, 1),
('administracion', 'Revisar gastos del hogar', 'small', 5, 0, 2),
('administracion', 'Organizar documentos', 'normal', 15, 1, 3),
('administracion', 'Planificar tareas del hogar', 'small', 5, 0, 4);

COMMIT;
