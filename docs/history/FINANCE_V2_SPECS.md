# 🏗️ Especificaciones Técnicas: Finanzas V2 (HomeSync)

> **Estado:** Diseño Final Aprobado (Optimizado para Producción)
> **Versión:** 2.3 (Arquitectura Profesional de 3 Niveles con Índices y Timestamps)
> **Objetivo:** Transformar la app de un simple divisor de gastos a un planificador financiero integral para parejas.

---

## 💎 Propuesta de Valor y Principios de Diseño

HomeSync V2 se basa en el principio de separación estricta entre **Planificación (Editable)** y **Realidad (Confirmada)**.

1.  **Templates (Reglas):** Definiciones recurrentes. Si se elimina uno, solo se marca `is_active = false` (Soft Delete) para no romper el historial.
2.  **Planned Expenses (Snapshots):** Generados automáticamente vía CRON. Son inmutables ante cambios posteriores en el template original.
3.  **Expenses (Realidad):** El gasto real tras confirmarse. Permite pagos adelantados (con un `paid_at` distinto al `due_date`) e impacta instantáneamente el balance.

---

## 🧱 Estructura de Base de Datos (Supabase)

### Tabla: `expense_templates`

Reglas de recurrencia.

- `id` (UUID, PK)
- `household_id` (FK households)
- `title` (TEXT)
- `default_amount` (NUMERIC, **Not Null**)
- `category` (TEXT)
- `frequency` (TEXT) -> _Mensual (V1)._
- `day_of_month` (INTEGER)
- `split_type` (TEXT)
- `payer_default` (FK users)
- `is_active` (BOOLEAN DEFAULT true) -> _Soft delete._
- `created_at` (TIMESTAMP DEFAULT now())
- `updated_at` (TIMESTAMP DEFAULT now())

### Tabla: `planned_expenses`

Fotos exactas de la planificación del mes. No se eliminan (`DELETE`), solo cambian de estado.

- `id` (UUID, PK)
- `household_id` (FK households)
- `template_id` (FK expense_templates)
- `title`, `amount`, `category`, `split_type`, `payer_default` -> _Snapshots copiados al generar._
- `due_date` (DATE)
- `status` (TEXT: 'pending', 'paid', 'skipped')
- `expense_id` (FK expenses) -> _Enlace a la realidad tras el pago._
- `created_at` (TIMESTAMP DEFAULT now())

**Constraints & Índices:**

- `UNIQUE (template_id, due_date)` (Garantiza idempotencia del CRON).
- `INDEX idx_planned_expenses_feed (household_id, due_date DESC)` (Performance del feed).

### Tabla: `expenses` (Existente, a extender)

La realidad contable.

- Campos actuales + `paid_at` (TIMESTAMP), `created_at` (TIMESTAMP DEFAULT now()), `planned_expense_id` (FK opcional vinculada al snapshot).
- **Fórmula de balance (estricta):** `balance = sum(paid_by_user) - sum(user_share)`. Calculado _exclusivamente_ leyendo esta tabla.
- **Índice de performance:** `INDEX idx_expenses_feed (household_id, paid_at DESC)`.

---

## ⚡ Backend y Lógica CRON

### 1. Generación Automática (`pg_cron`)

Proceso diario a las 02:00 usando `INSERT ... ON CONFLICT DO NOTHING`.
Usa recálculo seguro de fechas: `LEAST(template.day_of_month, extract(day from last_day_of_month))`.

### 2. Ediciones y Modificaciones al Template

- Editar el template **solo afecta a generaciones futuras**.
- Para cambiar un monto anómalo de este mes (ej. aumento imprevisto), el usuario edita el `planned_expense.amount` directamente _antes_ de confirmar el pago o durante el propio formulario de confirmación.

---

## 📱 Componentes de Flutter y UX

### 1. Feed Combinado (El timeline financiero)

El feed agrupará cronológicamente con visualización diferenciada:

- **Gris/Dashed:** Pendientes (Planned).
- **Blanco/Full:** Realizados (Real).

### 2. Formularios de Confirmación y "Skipping"

- Al abrir un planned expense, se precarga todo (`amount`, `payer_default`, `category`).
- El campo `paid_at` permite elegir fechas pasadas o adelantadas.
- Acción `[✕ Omitir]` disponible para pasarlo a `status = 'skipped'` sin alterar contabilidad.

### 3. Proyección Inteligente

El cálculo lee el snapshot del `planned_expense` (`status = pending`):

- `equal` -> proyecta `amount / 2`.
- `personal` (pagado por mi) -> proyecta `amount`.
- `personal` (pagado por el otro) -> proyecta `0`.

---

## 🗓️ Plan de Implementación

### Fase 1: Feed Combinado (Visual) ✅ COMPLETADO

- [x] Migración SQL (Tablas `expense_templates`, `planned_expenses`).
- [x] Función RPC `get_combined_feed`.
- [x] Modelos de datos en Flutter (`FeedItemModel`).
- [x] Repositorio y Caso de Uso para el Feed.
- [x] UI: Cards para gastos reales vs planeados.
- [x] UI: Widget de Proyección Mensual en el Resumen.

### Fase 2: Gestión de Plantillas (Recurrentes)

- [x] Backend: Tabla `expense_templates`.
- [x] UI: Formulario de creación/edición de plantillas.
- [x] Vista de listado de suscripciones/recurrentes.

### Fase 3: Automatización (CRON Job)

- [x] Configuración de `pg_cron` en Supabase.
- [x] Función `ensure_planned_expenses` (Lógica de generación).

### Fase 4: Confirmación de Pago

- [x] Función `pay_planned_expense`.
- [x] UI: Modal de confirmación (Confirm Sheet).

### Fase 5: Proyecciones Avanzadas ✅ COMPLETADO

- [x] Refinar cálculo de proyección según `split_type`.
- [x] Visualización de "Cashflow" mensual esperado.
- [x] Sugerencias proactivas de ahorro según excedente proyectado.
