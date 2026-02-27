# ROW LEVEL SECURITY (RLS) - Documentacion

## Que es RLS?

**Row Level Security** es una caracteristica de PostgreSQL que restringe que filas puede ver/modificar un usuario. Cada query es automaticamente filtrada segun las politicas definidas.

## Estado

**Fecha:** 2026-02-18
**Status:** IMPLEMENTADO

---

## Tablas Protegidas

| Tabla | RLS | Politicas |
|-------|-----|-----------|
| users | ON | 3 |
| households | ON | 4 |
| household_members | ON | 5 |
| tasks | ON | 4 |
| ledger_entries | ON | 1 |
| idempotency_keys | ON | 2 |
| expenses | ON | 4 |
| expense_splits | ON | 2 |
| system_events | ON | 2 |
| audit_logs | ON | 2 |
| integrity_checks | ON | 1 (bloqueado) |
| alerts | ON | 1 (bloqueado) |

---

## Politicas por Tabla

### users
```
SELECT: Solo ver su propio perfil (auth.uid() = id)
UPDATE: Solo actualizar su propio perfil
INSERT: Solo insertar su propio perfil
DELETE: No permitido
```

### households
```
SELECT: Ver households donde es miembro
INSERT: Crear nuevos households
UPDATE: Solo owners pueden modificar
DELETE: Solo owners pueden eliminar
```

### household_members
```
SELECT: Ver miembros de sus households
INSERT: Unirse a household (user_id = auth.uid())
        Owners/admins pueden agregar otros
UPDATE: Modificar su propia membresia
        Owners pueden modificar cualquier membresia
DELETE: Solo owners pueden remover miembros
```

### tasks
```
SELECT: Ver tareas de su household
INSERT: Crear tareas en su household
UPDATE: Modificar tareas de su household
DELETE: Solo owners pueden eliminar tareas
```

### ledger_entries
```
SELECT: Ver solo sus propias entradas
INSERT: No permitido (solo via RPC)
UPDATE: No permitido (inmutable)
DELETE: No permitido (inmutable)
```

### idempotency_keys
```
SELECT: Ver solo sus propias keys
INSERT: Crear sus propias keys
UPDATE: No permitido
DELETE: No permitido
```

### expenses
```
SELECT: Ver gastos de su household
INSERT: Crear gastos en su household
UPDATE: Modificar gastos que creo
DELETE: Solo owners pueden eliminar
```

### system_events / audit_logs
```
SELECT: Ver eventos/audits de su household
INSERT: Crear eventos (via RPC)
UPDATE: No permitido
DELETE: No permitido
```

### integrity_checks / alerts
```
ALL: Bloqueado para usuarios
     Solo service_role puede acceder
```

---

## Como Funciona

### Ejemplo 1: Ver tareas
```sql
-- Query del usuario:
SELECT * FROM tasks;

-- PostgreSQL ejecuta automaticamente:
SELECT * FROM tasks 
WHERE household_id IN (
  SELECT household_id FROM household_members 
  WHERE user_id = auth.uid()
);
```

### Ejemplo 2: Ver balance
```sql
-- Query del usuario:
SELECT * FROM ledger_entries WHERE user_id = '...';

-- PostgreSQL filtra:
SELECT * FROM ledger_entries 
WHERE user_id = auth.uid();  -- Solo sus propias entradas
```

### Ejemplo 3: Ataque prevenido
```sql
-- Intento malicioso:
DELETE FROM tasks WHERE id = 'otra-persona-task-id';

-- Resultado: 0 rows affected
-- RLS bloquea porque el usuario no es owner del household
```

---

## Roles de Usuario

| Rol | Permisos |
|-----|----------|
| owner | Todo: crear, ver, modificar, eliminar |
| admin | Crear, ver, modificar (no eliminar) |
| member | Crear, ver, modificar tareas propias |

---

## Funciones RPC y RLS

Las funciones RPC con `SECURITY DEFINER` **bypassean RLS** porque se ejecutan con permisos del owner de la funcion. Esto es **intencional** para:

1. `create_task` - Necesita crear household automaticamente
2. `complete_task_transaction` - Necesita crear ledger_entries
3. `verify_task_transaction` - Necesita actualizar tareas

**Importante:** Las funciones RPC validan permisos internamente antes de ejecutar operaciones.

---

## Testing de Seguridad

### Test 1: Usuario no puede ver tareas de otro
```sql
-- Como user1
SET LOCAL jwt.claims.sub = 'user1-uuid';
SELECT * FROM tasks; -- Solo ve sus tareas

-- Como user2
SET LOCAL jwt.claims.sub = 'user2-uuid';
SELECT * FROM tasks; -- Solo ve sus tareas
```

### Test 2: Usuario no puede modificar ledger
```sql
-- Intento de modificacion
UPDATE ledger_entries SET amount = 999999;
-- Resultado: ERROR - RLS policy violation
```

### Test 3: Usuario no puede ver alerts
```sql
SELECT * FROM alerts;
-- Resultado: 0 rows (politica bloquea todo acceso)
```

---

## Archivos Relacionados

| Archivo | Descripcion |
|---------|-------------|
| `database/migrations/004_rls_policies.sql` | SQL de politicas |
| `TEST_RESULTS.md` | Resultados de tests |
| `DIA_7_COMPLETADO.md` | Documentacion del dia |

---

## Notas de Seguridad

### Lo que RLS protege:
- Acceso directo a tablas via Supabase SDK
- Queries desde el cliente Flutter
- SQL injection (PostgreSQL maneja automaticamente)

### Lo que RLS NO protege:
- Funciones RPC con SECURITY DEFINER (tienen sus propias validaciones)
- Service role key (tiene acceso total)
- Admin dashboard (si existe)

---

## Mejoras Futuras

1. **Audit logging de RLS violations**
   - Registrar intentos de acceso denegado
   - Alertas de actividad sospechosa

2. **Roles mas granulares**
   - Rol "viewer" (solo ver, no modificar)
   - Permisos por categoria de tarea

3. **Data masking**
   - Ocultar campos sensibles (email, phone)
   - Solo visibles para owners/admins
