# 🏗 Plan de Implementación: Finanzas V2

> **Estado:** Plan aprobado — No implementado aún  
> **Fecha:** 2026-03-10  
> **Objetivo:** Evolucionar el sistema de finanzas de un divisor de gastos a un planificador financiero de pareja completo.

---

## 🔍 Análisis del Estado Actual

### Lo que ya existe y funciona bien ✅

| Componente                                | Estado                         | Notas                                              |
| ----------------------------------------- | ------------------------------ | -------------------------------------------------- |
| `expenses` table                          | ✅ Activa (8 registros reales) | Tiene `split_type`, `is_shared`, `type` enum       |
| `expense_splits` table                    | ✅ Activa (13 registros)       | División correcta por usuario                      |
| `savings_goals` + `savings_contributions` | ✅ En DB, 0 registros          | Schema listo, UI integrada                         |
| `save_expense_v4` RPC                     | ✅ Estable                     | Auto-split, gift, personal correctos               |
| `get_expense_balance` RPC                 | ✅ Simétrico                   | Ajustado en V13: balance = pagado − owed           |
| `get_filtered_expenses` RPC               | ✅ Nuevo                       | Feed filtrable por tipo y sharing                  |
| `get_personal_finance_summary` RPC        | ✅ Activo                      | Ingreso/gasto del mes + balance                    |
| `ExpenseModel` en Flutter                 | ✅ Completo                    | Soporta `isShared`, `splitType`, `type`            |
| `HouseholdBalanceModel` en Flutter        | ✅ Completo                    | `isCreditor`, `isDebtor`, `isSettled`              |
| `SupabaseExpenseRepository`               | ✅ Limpio                      | Clean architecture con fpdart Either               |
| `settlements` como expense type           | ✅ Funciona                    | `type = 'settlement'` en la misma tabla `expenses` |

### Lo que NO existe todavía ❌

| Componente                             | Descripción                                     |
| -------------------------------------- | ----------------------------------------------- |
| `expense_templates`                    | Plantillas de gastos recurrentes                |
| `planned_expenses`                     | Próximos gastos (instancias de templates)       |
| `monthly_closures`                     | Cierre y foto histórica de cada mes             |
| Feed combinado en UI                   | Real + próximos juntos con diseño diferenciado  |
| Generación dinámica de próximos gastos | Lógica "on-open" para crear planned expenses    |
| Formulario de confirmación al pagar    | Abrir form pre-cargado desde un planned expense |
| Proyección mensual                     | Widget "Este mes te toca pagar $X"              |

---

## 🧠 Modelo Conceptual Definitivo

### Los 3 niveles de realidad financiera

```
┌─────────────────────────────────────────────────────────────────┐
│  NIVEL 1: TEMPLATES (Reglas)                                    │
│  "Alquiler, $400k, día 5, mensual, 50/50"                       │
│  → NO afectan balance. Solo son plantillas.                     │
├─────────────────────────────────────────────────────────────────┤
│  NIVEL 2: PLANNED EXPENSES (Planificación)                      │
│  "5 mayo · Alquiler · $400k · pendiente"                        │
│  → NO afectan balance. Son intenciones.                         │
├─────────────────────────────────────────────────────────────────┤
│  NIVEL 3: EXPENSES (Realidad)                                   │
│  "5 mayo · Alquiler · $400k · pagado por Blas · 50/50"         │
│  → SÍ afectan balance. Dinero que ya ocurrió.                   │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo completo de un gasto recurrente

```
[Template: Alquiler mensual]
        ↓ (apertura de app o refresh)
[Planned Expense: 5 mayo · pendiente]
        ↓ (usuario toca ✓ Pagar)
[Formulario pre-cargado abre]
        ↓ (usuario confirma, puede ajustar monto)
[Expense real creado]
        ↓ (automático)
[Balance de pareja actualizado]
```

---

## 🧱 Modelo de Datos Final

### Tabla: `expense_templates` (NUEVA)

```sql
CREATE TABLE public.expense_templates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id    UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    created_by      UUID NOT NULL REFERENCES users(id),
    title           TEXT NOT NULL,
    default_amount  NUMERIC,            -- NULL = usuario lo confirma cada vez
    category        TEXT,
    frequency       TEXT NOT NULL,      -- 'monthly' | 'weekly' | 'yearly'
    day_of_month    INTEGER,            -- 1-31 (para frecuencia mensual)
    day_of_week     INTEGER,            -- 0=lun, 6=dom (para frecuencia semanal)
    split_type      TEXT DEFAULT 'equal', -- 'equal' | 'percentage' | 'fixed' | 'personal'
    payer_default   UUID REFERENCES users(id), -- quién paga por defecto
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);
```

> [!NOTE]
> `default_amount` puede ser NULL. Esto es intencional: si el monto varía (ej: supermercado estimado), el usuario lo ingresa al confirmar el pago.

### Tabla: `planned_expenses` (NUEVA)

```sql
CREATE TABLE public.planned_expenses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id    UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    template_id     UUID REFERENCES expense_templates(id) ON DELETE SET NULL,
    title           TEXT NOT NULL,
    amount          NUMERIC,            -- puede ser NULL si el template no tiene monto fijo
    due_date        DATE NOT NULL,
    payer_default   UUID REFERENCES users(id),
    split_type      TEXT DEFAULT 'equal',
    category        TEXT,
    status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'skipped')),
    expense_id      UUID REFERENCES expenses(id) ON DELETE SET NULL, -- se llena cuando se paga
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);
```

### Tabla: `monthly_closures` (NUEVA — Fase 5)

```sql
CREATE TABLE public.monthly_closures (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id        UUID NOT NULL REFERENCES households(id),
    month               INTEGER NOT NULL, -- 1-12
    year                INTEGER NOT NULL,
    total_spent         NUMERIC,
    balance_snapshot    JSONB,  -- snapshot del balance al momento del cierre
    carryover_amount    NUMERIC DEFAULT 0, -- deuda arrastrada al mes siguiente
    closed_by           UUID REFERENCES users(id),
    created_at          TIMESTAMPTZ DEFAULT now(),
    UNIQUE (household_id, month, year)
);
```

### Tablas existentes que se mantienen sin cambios

- `expenses` — gastos reales (sin tocar, ya funciona bien)
- `expense_splits` — divisiones (sin tocar)
- `savings_goals` + `savings_contributions` — ahorros (sin tocar)

---

## ⚡ Funciones SQL a Crear

### Función 1: Generación dinámica de próximos gastos

```sql
-- Se llama cada vez que el usuario abre la app.
-- Calcula si debería existir un planned_expense para cada template activo
-- y lo crea solo si no existe ya.
CREATE OR REPLACE FUNCTION public.ensure_planned_expenses(p_household_id UUID)
RETURNS VOID AS $$
DECLARE
    t RECORD;
    expected_date DATE;
    exists_count INT;
BEGIN
    FOR t IN
        SELECT * FROM expense_templates
        WHERE household_id = p_household_id AND is_active = true
    LOOP
        -- Calcular la próxima fecha esperada
        IF t.frequency = 'monthly' THEN
            expected_date := DATE_TRUNC('month', CURRENT_DATE) + (t.day_of_month - 1);
        ELSIF t.frequency = 'weekly' THEN
            -- Próximo día de semana correspondiente
            expected_date := CURRENT_DATE + ((t.day_of_week - EXTRACT(DOW FROM CURRENT_DATE)::INT + 7) % 7);
        ELSIF t.frequency = 'yearly' THEN
            expected_date := DATE_TRUNC('year', CURRENT_DATE) + (t.day_of_month - 1);
        END IF;

        -- Solo crear si no existe ya (evitar duplicados)
        SELECT COUNT(*) INTO exists_count
        FROM planned_expenses
        WHERE template_id = t.id
        AND due_date = expected_date
        AND status = 'pending';

        IF exists_count = 0 THEN
            INSERT INTO planned_expenses (
                household_id, template_id, title, amount,
                due_date, payer_default, split_type, category
            ) VALUES (
                p_household_id, t.id, t.title, t.default_amount,
                expected_date, t.payer_default, t.split_type, t.category
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Función 2: Confirmar pago de próximo gasto → Expense real

```sql
-- Se llama cuando el usuario toca ✓ Pagar y confirma el formulario.
-- Crea el expense real y marca el planned_expense como pagado.
CREATE OR REPLACE FUNCTION public.pay_planned_expense(
    p_planned_id    UUID,
    p_paid_by       UUID,
    p_amount        NUMERIC,    -- puede diferir del template
    p_paid_at       TIMESTAMPTZ DEFAULT NOW(),
    p_splits        JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_planned   planned_expenses%ROWTYPE;
    v_expense_id UUID;
BEGIN
    SELECT * INTO v_planned FROM planned_expenses WHERE id = p_planned_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Planned expense not found'; END IF;

    -- Crear el expense real usando la función existente
    SELECT public.save_expense_v4(
        p_id            := NULL,
        p_household_id  := v_planned.household_id,
        p_title         := v_planned.title,
        p_amount        := p_amount,
        p_category      := v_planned.category,
        p_paid_by       := p_paid_by,
        p_paid_at       := p_paid_at,
        p_split_type    := v_planned.split_type,
        p_is_shared     := v_planned.split_type NOT IN ('personal', 'gift'),
        p_type          := 'expense',
        p_splits        := p_splits
    ) INTO v_expense_id;

    -- Marcar el planned expense como pagado y vincular al expense real
    UPDATE planned_expenses
    SET status = 'paid', expense_id = v_expense_id, updated_at = NOW()
    WHERE id = p_planned_id;

    RETURN v_expense_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Función 3: Feed combinado (real + próximos)

```sql
CREATE OR REPLACE FUNCTION public.get_combined_feed(
    p_household_id  UUID,
    p_limit         INTEGER DEFAULT 50
)
RETURNS JSONB AS $$
DECLARE v_result JSONB;
BEGIN
    SELECT jsonb_agg(feed_row ORDER BY feed_date DESC) INTO v_result
    FROM (
        -- Gastos reales
        SELECT
            e.id, e.title, e.amount, e.type::TEXT as type,
            e.split_type, e.is_shared, e.paid_at as feed_date,
            'expense' as feed_type,
            NULL as status,
            jsonb_build_object('email', u.email, 'full_name', u.full_name) as payer,
            ( SELECT jsonb_agg(s) FROM expense_splits s WHERE s.expense_id = e.id ) as splits
        FROM expenses e
        JOIN users u ON u.id = e.paid_by
        WHERE e.household_id = p_household_id

        UNION ALL

        -- Próximos gastos pendientes (hasta 30 días en el futuro)
        SELECT
            pe.id, pe.title, pe.amount, 'planned' as type,
            pe.split_type, true as is_shared, pe.due_date::TIMESTAMPTZ as feed_date,
            'planned' as feed_type,
            pe.status,
            jsonb_build_object('id', pe.payer_default) as payer,
            NULL as splits
        FROM planned_expenses pe
        WHERE pe.household_id = p_household_id
        AND pe.status = 'pending'
        AND pe.due_date <= CURRENT_DATE + INTERVAL '30 days'

        ORDER BY feed_date DESC
        LIMIT p_limit
    ) feed_row;

    RETURN COALESCE(v_result, '[]'::JSONB);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Función 4: Proyección mensual

```sql
CREATE OR REPLACE FUNCTION public.get_monthly_projection(
    p_household_id  UUID,
    p_user_id       UUID
)
RETURNS JSONB AS $$
DECLARE
    v_planned_total     NUMERIC;
    v_user_portion      NUMERIC;
    v_actual_spent      NUMERIC;
BEGIN
    -- Total planificado este mes
    SELECT COALESCE(SUM(amount), 0) INTO v_planned_total
    FROM planned_expenses
    WHERE household_id = p_household_id
    AND DATE_TRUNC('month', due_date) = DATE_TRUNC('month', CURRENT_DATE)
    AND status = 'pending';

    -- Porción del usuario (simplificado: 50/50)
    v_user_portion := v_planned_total / 2;

    -- Gasto real del mes actual
    SELECT COALESCE(SUM(amount), 0) INTO v_actual_spent
    FROM expenses
    WHERE household_id = p_household_id
    AND type = 'expense'
    AND DATE_TRUNC('month', paid_at) = DATE_TRUNC('month', NOW());

    RETURN jsonb_build_object(
        'planned_total', v_planned_total,
        'user_portion', v_user_portion,
        'actual_spent', v_actual_spent,
        'remaining_planned', v_planned_total - COALESCE((
            SELECT SUM(amount) FROM planned_expenses
            WHERE household_id = p_household_id
            AND DATE_TRUNC('month', due_date) = DATE_TRUNC('month', CURRENT_DATE)
            AND status = 'paid'
        ), 0)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📱 Diseño de UI — Pantalla de Finanzas Rediseñada

### Feed combinado (diseño visual)

```
┌──────────────────────────────────────────────────────────────────┐
│  FINANZAS                                        ⚙ Configurar   │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  BALANCE  Blas +$15.000                                  │   │
│  │  Rocío te debe $15.000    [Equilibrar →]                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  📅 ESTE MES TE TOCA PAGAR                               │   │
│  │  $195.000 estimado (50% de $390.000 planificados)        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  — PRÓXIMOS GASTOS ─────────────────── fondo gris claro ──     │
│                                                                  │
│  ┌──────────── 📌 PRÓXIMO ──────────────────────────────┐  │   │
│  │  5 mayo · Alquiler                                   │  │   │
│  │  $400.000 · paga Blas · 50/50          [✓ Pagar]    │  │   │
│  └──────────────────────────────────────────────────────┘  │   │
│                                                                  │
│  ┌──────────── 📌 PRÓXIMO ──────────────────────────────┐  │   │
│  │  3 mayo · Internet                                   │  │   │
│  │  $20.000 · paga Rocío · 50/50          [✓ Pagar]    │  │   │
│  └──────────────────────────────────────────────────────┘  │   │
│                                                                  │
│  — MOVIMIENTOS ─────────────────────── fondo blanco ──────     │
│                                                                  │
│  │  🛒 Supermercado      $25.000    Blas   hoy           │       │
│  │  ⛽ Nafta             $12.000    Rocío  ayer           │       │
│  │  🏠 Supermercado     $50.000    Blas   28 abr         │       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Formulario de confirmación al pagar

```
┌──────────────────────────────────────────────────────────────────┐
│  ✓ Confirmar pago                                    [×]        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Alquiler                          [editar título]              │
│                                                                  │
│  Monto                                                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  $ 400.000                                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│  Podés ajustar si el monto cambió                               │
│                                                                  │
│  Pagó                                                           │
│  [ Blas ▼ ]                                                     │
│                                                                  │
│  División                                                       │
│  [ 50/50  ▼ ]                                                   │
│                                                                  │
│  Fecha                                                          │
│  [ 5 de mayo ▼ ]                                               │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              GUARDAR GASTO                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🗂 Arquitectura Flutter — Nuevos Archivos

### Feature: `planned_expenses`

```
lib/features/expenses/
├── domain/
│   ├── models/
│   │   ├── expense_model.dart          (existente ✅)
│   │   ├── planned_expense_model.dart  (NUEVO)
│   │   └── expense_template_model.dart (NUEVO)
│   ├── repositories/
│   │   ├── expense_repository.dart     (existente ✅)
│   │   └── planned_expense_repository.dart (NUEVO)
│   └── usecases/
│       ├── get_templates_usecase.dart  (NUEVO)
│       ├── create_template_usecase.dart (NUEVO)
│       ├── get_planned_expenses_usecase.dart (NUEVO)
│       └── pay_planned_expense_usecase.dart  (NUEVO)
├── data/
│   └── repositories/
│       ├── supabase_expense_repository.dart    (existente ✅)
│       └── supabase_planned_expense_repository.dart (NUEVO)
└── presentation/
    ├── providers/
    │   ├── expense_provider.dart       (existente ✅)
    │   └── planned_expense_provider.dart (NUEVO)
    ├── screens/
    │   ├── expenses_screen.dart        (MODIFICAR — feed combinado)
    │   └── templates_screen.dart       (NUEVO — gestionar recurrentes)
    └── widgets/
        ├── expense_form_sheet.dart     (existente ✅)
        ├── planned_expense_card.dart   (NUEVO — card con ✓ pagar)
        ├── pay_confirmation_sheet.dart (NUEVO — formulario confirmación)
        └── monthly_projection_card.dart (NUEVO — widget proyección)
```

---

## 🚀 Roadmap de Implementación

### Fase 1 — Fundación (lo que ya existe ✅)

- Gastos reales con splits
- Balance simétrico de pareja
- Liquidaciones (settlements)
- Sistema de ahorros

### Fase 2 — Feed Combinado (SIGUIENTE PASO)

**Esfuerzo estimado: 3-4 horas**

1. Crear función SQL `get_combined_feed`
2. Crear `PlannedExpenseModel` en Flutter (modelo sin DB por ahora)
3. Rediseñar `ExpensesScreen` con feed separado en secciones:
   - "Próximos gastos" (gris, vacío si no hay ninguno)
   - "Movimientos" (blanco, con toda la historia)
4. Añadir widget de "Este mes te toca pagar $X" (proyección simple basada en gastos existentes)

### Fase 3 — Templates y Recurrentes

**Esfuerzo estimado: 5-6 horas**

1. Migración SQL: tabla `expense_templates`
2. Función SQL `ensure_planned_expenses` (generación dinámica)
3. `TemplateModel` y `TemplateRepository` en Flutter
4. `TemplatesScreen` para gestionar recurrentes
5. Llamar `ensure_planned_expenses` al cargar el home

### Fase 4 — Planned Expenses + Confirmación

**Esfuerzo estimado: 4-5 horas**

1. Migración SQL: tabla `planned_expenses`
2. Función SQL `pay_planned_expense`
3. `PlannedExpenseModel` y `PlannedExpenseRepository` en Flutter
4. Widget `PlannedExpenseCard` con botón ✓ Pagar
5. Sheet `PayConfirmationSheet` con formulario pre-cargado
6. Animación: Pendiente → Pagado en el feed

### Fase 5 — Proyección Mensual

**Esfuerzo estimado: 2-3 horas**

1. Función SQL `get_monthly_projection`
2. Widget `MonthlyProjectionCard` arriba del home/finanzas
3. Integrar con templates para mostrar "Este mes planeado: $X"

### Fase 6 — Cierre de Mes (futuro)

**Esfuerzo estimado: 4-5 horas**

1. Migración SQL: tabla `monthly_closures`
2. Pantalla de resumen y cierre de mes
3. Lógica de arrastre de deuda al mes siguiente

---

## 🧮 Lógica de Balance — Reglas Inquebrantables

> [!IMPORTANT]
> Estas reglas NO deben cambiar bajo ningún concepto para mantener consistencia contable.

| Tipo de movimiento              | ¿Afecta balance? | Razón                       |
| ------------------------------- | ---------------- | --------------------------- |
| `expense` + `is_shared = true`  | ✅ SÍ            | Es un gasto real compartido |
| `expense` + `is_shared = false` | ❌ NO            | Personal o regalo           |
| `income`                        | ❌ NO            | Los ingresos son personales |
| `settlement`                    | ✅ SÍ            | Salda una deuda existente   |
| `planned_expense` (cualquiera)  | ❌ NO            | Aún no ocurrió              |
| `expense_template`              | ❌ NO            | Es solo una regla/plantilla |

**Fórmula invariante:**

```
balance_usuario = SUM(expenses.amount WHERE paid_by = user AND is_shared = true)
               - SUM(expense_splits.amount WHERE user_id = user AND expense.is_shared = true)
```

---

## 💡 Decisiones de Diseño Importantes

### 1. ¿Por qué generación dinámica y no automática?

Los templates NO generan planned_expenses automáticamente. En cambio, `ensure_planned_expenses` se llama cuando el usuario abre la app. Esto garantiza:

- Base de datos limpia (sin registros futuros innecesarios)
- Cambios de monto en el template se reflejan inmediatamente
- No se generan gastos si la pareja no usa la app

### 2. ¿Por qué formulario de confirmación al pagar?

Cuando un usuario toca ✓ Pagar, se abre un sheet pre-cargado en lugar de convertir el gasto automáticamente. Esto permite:

- Ajustar el monto si cambió (el alquiler sube)
- Cambiar quién pagó en el último momento
- Mantener datos precisos en el historial

### 3. ¿Por qué no guardar el balance en la DB?

El balance SIEMPRE se calcula en tiempo real desde `expenses` y `expense_splits`. Nunca se almacena en una columna. Esto evita inconsistencias contables y simplifica la lógica de actualización.

### 4. ¿Por qué los settlements están en la tabla `expenses`?

Para simplificar arquitectura. Un settlement es simplemente un `type = 'settlement'` en la tabla `expenses`. Funciona con la misma lógica de balance y no requiere tabla separada.

---

## 📊 Índices SQL Necesarios

```sql
-- Para el feed combinado (performance crítica)
CREATE INDEX IF NOT EXISTS idx_expenses_household_paid_at
    ON expenses(household_id, paid_at DESC);

CREATE INDEX IF NOT EXISTS idx_planned_expenses_household_status
    ON planned_expenses(household_id, status, due_date);

CREATE INDEX IF NOT EXISTS idx_expense_templates_household_active
    ON expense_templates(household_id, is_active);

-- Para cálculo de balance (ya existe implícitamente por FK)
CREATE INDEX IF NOT EXISTS idx_expense_splits_expense_id
    ON expense_splits(expense_id);

CREATE INDEX IF NOT EXISTS idx_expense_splits_user_id
    ON expense_splits(user_id);
```

---

## 🏆 Resultado Final de la App

Cuando todo esté implementado, la app quedará posicionada entre:

| App                | ¿Qué hace?                                      |
| ------------------ | ----------------------------------------------- |
| **Splitwise**      | Divide gastos (solo reactivo)                   |
| **YNAB / Monarch** | Planifica presupuestos (general)                |
| **HomeSync V2**    | Divide + planifica, **optimizado para parejas** |

Las features claves que nos diferencian:

- Feed de tiempo real donde ves lo que pasó Y lo que viene
- Los gastos recurrentes del hogar (alquiler, servicios) se gestionan juntos
- El balance de pareja es automático y siempre sincronizado
- La proyección mensual convierte la app en un planificador real

---

_Plan creado: 2026-03-10 | Próximo paso: Implementar Fase 2 (Feed Combinado)_
