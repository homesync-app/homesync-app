# 💸 Spec: Finanzas personales de adolescentes + Mesada (transferencia adulto→teen)

> **Estado:** dirección de producto aprobada (2026-06-04). No implementado aún.
> **Contexto:** surge del fix de splits (`pay_planned_expense` adults-only). El alquiler/servicios NO deben dividirse entre hijos. Pero un adolescente SÍ debería poder llevar SUS finanzas personales, sin entrar al pozo compartido del hogar.

---

## 1. El modelo — 3 capas de plata, separadas

| Capa | Quién | Qué | Afecta balance del hogar |
|---|---|---|---|
| **Pozo compartido** | Solo adultos (`parent`/`guardian`/`adult`) | Alquiler, servicios, super → split entre adultos | ✅ Sí |
| **Finanzas personales del teen** | El `teen`, aislado | Su propia plata: gastos e ingresos propios | ❌ No — ledger separado |
| **Niños (`child`)** | — | Sin plata real; solo monedas/XP gamificadas (ya existe) | ❌ No |

**Principio clave:** el teen tiene un **mini-ledger propio**, totalmente aislado del split compartido. Objetivo: educación financiera, que maneje SU plata.

✅ **Ya hecho:** la migración `20260604234445_family_planned_expense_adult_splits.sql` excluye a `teen`/`child` del split de `pay_planned_expense` para family/couple. Esta spec construye **sobre** eso.

---

## 2. Feature central: Mesada (transferencia adulto → teen)

Un adulto le pasa plata a un teen. Atómico:
- **Lado adulto:** egreso (categoría "Mesada / Transferencia") → su balance ↓
- **Lado teen:** ingreso a su ledger personal → su balance ↑
- **Una vez** o **recurrente** (semanal/mensual) → reusar el motor de gastos recurrentes que ya existe
- **Solo adultos la inician.** Gateada por **Modo Padres (premium)** → monetización consistente con `taskApprovalEnabledProvider`

### Por qué importa
Valor pedagógico alto y encaja perfecto con el modo familia: el teen ve entrar la plata, la gasta, la trackea.

---

## 3. Data model

- `member_type = 'teen'` ya existe ✓
- **Scope personal:** expenses/incomes del teen marcados como personales (`user_id = teen`, `is_shared = false`, sin `expense_splits` hacia otros). No entran al combined feed compartido del hogar.
- **RPC nuevo — transferencia atómica:**
  ```
  transfer_to_member(
    p_household_id uuid,
    p_from_user   uuid,   -- adulto (debe ser adult/parent/guardian)
    p_to_user     uuid,   -- teen del mismo hogar
    p_amount      numeric,
    p_note        text default null,
    p_recurring   text default null  -- null | 'weekly' | 'monthly'
  ) returns jsonb
  ```
  - Inserta **dos** filas atómicas: egreso del adulto + ingreso del teen, con un `type = 'transfer'` (o `'allowance'`) nuevo.
  - Valida: `p_from_user` es adulto del hogar; `p_to_user` es teen del mismo hogar; premium activo (`is_household_premium`).
  - `SECURITY DEFINER`, `REVOKE anon`, `GRANT authenticated` (mismo patrón que el resto).
- **RLS:** el teen lee su propio ledger; puede crear sus expenses personales; **no** puede tocar el pozo compartido ni iniciar transferencias.

---

## 4. Ideas conectadas (backlog)

1. **Mesada ligada a tareas:** el teen completa tareas → gana la mesada. Conecta el sistema de tareas/recompensas existente con plata real ("gané $X por mis quehaceres").
2. **Aprobación de gastos del teen:** extender el patrón de aprobación parental (Modo Padres) al gasto — el teen pide gastar > umbral y el adulto aprueba. Mismo mecanismo que `task_approvals`, otro dominio.
3. **Metas de ahorro para teens:** extender `savings_goals` (ya existe) al teen.

---

## 5. UI / dónde van las pantallas

- **Home del teen:** balance personal + botón "registrar gasto/ingreso" + historial de mesadas recibidas.
- **Vista del adulto (Modo Padres):** acción "Dar mesada" por teen (una vez / recurrente), historial de transferencias.

---

## 6. Rollout sugerido (por fases)

| Fase | Qué | Depende de |
|---|---|---|
| **1** | Ledger personal del teen (registra sus propios gastos/ingresos, aislado) | scope personal + RLS teen |
| **2** | Transferencia adulto→teen **una vez** | RPC `transfer_to_member` |
| **3** | **Mesada recurrente** (semanal/mensual) | motor recurrente existente |
| **4** | Mesada-por-tareas · aprobación de gasto · metas de ahorro teen | fases 1-3 |

Todo gateado por **Modo Padres (premium)**.

---

## Decisiones de producto confirmadas (2026-06-04)
- ✅ Family/couple: shared splits **solo entre adultos** (el alquiler no se divide con hijos).
- ✅ Teens: finanzas **personales aisladas**, fuera del pozo compartido.
- ✅ Transferencia adulto→teen como mecanismo de mesada (premium, Modo Padres).
- Pendiente de confirmar: que el payment sheet oculte el selector de pagador en modo `shared` (cambio del IDE AI, a validar).
