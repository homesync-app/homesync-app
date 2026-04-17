# Lógica de Finanzas - HomeSync 💸

Este documento detalla el funcionamiento interno del sistema de finanzas, incluyendo las mejoras recientes en la precisión de balances y la integración con la base de datos.

## 1. Tipos de Transacciones

El sistema soporta tres tipos principales de movimientos:

- **Gasto (Expense):** Salida de dinero para compras o servicios.
- **Ingreso (Income):** Entrada de dinero (sueldos, regalos, etc.).
- **Ajuste/Liquidación (Settlement):** Movimiento especial para saldar deudas entre los miembros de la pareja.

## 2. Modos de Reparto (Split Logic)

Cuando se registra un gasto, existen cuatro formas de dividirlo:

| Modo                   | Comportamiento                                              | Impacto en Balance                                                |
| :--------------------- | :---------------------------------------------------------- | :---------------------------------------------------------------- |
| **50/50 (Igual)**      | El gasto se divide equitativamente entre los dos miembros.  | Genera deuda para quien no pagó (50%).                            |
| **Puntual (Fijo)**     | Se define un monto exacto para cada persona.                | Genera deuda basada en el monto asignado.                         |
| **Solo Yo (Personal)** | El gasto es asumido 100% por quien lo registra.             | **Balance Neutro:** No afecta la deuda de pareja.                 |
| **Regalo**             | Es un gasto compartido pero quien paga lo asume totalmente. | **Balance Neutro:** Aparece en el historial pero no genera deuda. |

## 3. Cálculo del Balance de Pareja

El balance se calcula mediante la función `public.get_expense_balance(household_id)`.

La lógica es **simétrica**:

- **Total Pagado:** Suma de todos los gastos donde el usuario es el `paid_by` Y `is_shared` es true.
- **Total Debido:** Suma de todos los "splits" asignados al usuario en la tabla `expense_splits` para gastos compartidos.
- **Balance = (Total Pagado) - (Total Debido)**

> [!IMPORTANT]
> Si el usuario A tiene un balance de `+10,000`, significa que el usuario B tiene un balance de `-10,000`. El sistema garantiza que la suma de balances siempre sea cero. Los gastos marcados como "Solo Yo" o "Regalo" (is_shared = false) no entran en este cálculo.

## 4. Sistema de Ahorros (NUEVO 🎯)

El sistema de ahorros permite crear metas compartidas:

- **Metas de Ahorro:** Objetivos con nombre, monto y progreso visual.
- **Aportes:** Cada miembro puede aportar a una meta usando Mercado Pago.
- **Visualización:** El progreso se muestra en una sección dedicada en la pantalla de Gastos y en una pestaña propia.

## 5. Mejoras de Robustez (V12+)

Se implementó la función `save_expense_v4` con salvaguardas automáticas:

- **Autofix de Splits:** Si la aplicación falla al enviar el detalle de división en un gasto 50/50, la base de datos detecta el error y autogenera los registros necesarios basándose en los miembros del hogar.
- **Sincronización Personal:** Los gastos personales e ingresos se computan en el resumen mensual pero no afectan la deuda compartida.
- **Enum de Transacciones:** Manejo nativo de `expense`, `income` y `settlement`.

---

_Ultima actualización: 2026-03-07_
