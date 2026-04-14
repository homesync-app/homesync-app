# Finance Canonical Rules (2026-04-01)

This document is the canonical functional definition for HomeSync finances as of 2026-04-01.

It exists because the current finance docs mix:

- old design intent
- partially updated implementation notes
- runtime contracts that evolved after the original V2 spec

If older docs disagree with this file, this file should win.

## Core model

HomeSync must keep three layers clearly separated:

1. `expense_templates`
Rule only. Defines recurrence, default amount, split type, and habitual payer.
It never changes real balances by itself.

2. `planned_expenses`
Forecast layer. Represents an upcoming or overdue expected household expense.
It is visible in the feed and summary, but it does not affect the real shared balance.

3. `expenses`
Confirmed reality. Only confirmed expenses affect the shared balance and real financial history.

## Canonical behavior for recurring expenses

### When a new recurring expense starts counting

HomeSync should use "first valid occurrence" logic.

- If the recurring rule is created before or on its due day for the current month, the first planned expense may belong to the current month.
- If the rule is created after that month's due day, the first planned expense should be the next cycle.
- The app should not silently backfill the current month as overdue just because the recurring rule was created late.
- If we ever want "include current month too", that must be an explicit user choice.

Reason:
Implicit backfill creates fake overdue debt and makes trust in the forecast worse.

### Planned expenses must not alter the real balance

This is a strict rule.

- `planned_expenses` are forecast only
- `expenses` are accounting reality
- shared balance must be computed only from confirmed expenses and their splits

## Canonical meaning of summary numbers

HomeSync must separate shared responsibility from expected cashflow.

### Balance actual

Real monthly position for the current user.
Uses confirmed income and confirmed expenses only.
Does not include recurring pending items.

### Pendientes del hogar

Total amount of all pending planned expenses for the current month.
This is the household-level view.

### Tu parte pendiente

The amount that belongs to the current user according to the split rule.

Examples:

- `equal`: user share is `amount / household_size`
- `personal`: user share is `amount` only if the expense belongs to that user
- `gift`: should not create shared obligation

### Flujo de caja pendiente

The amount the current user is likely to pay out-of-pocket if they are the habitual payer (`payer_default`).

This is useful, but it is not the same as shared responsibility.

### Balance estimado

By default in HomeSync, `Balance estimado` should mean:

`balance actual - tu parte pendiente`

If the product wants to show cashflow instead, it must use a different label such as:

- `Vas a desembolsar`
- `Pagador habitual`
- `Salida esperada`

It should not use `Balance estimado` for a cashflow number unless the wording makes that explicit.

## How recurring shared expenses should be displayed

For a shared recurring item like rent:

- show total amount on the card
- show split type on the card
- show habitual payer on the card
- do not confuse total amount with the user's responsibility

Example:

- Rent total: `$400.000`
- Split: `50/50`
- Habitual payer: `Blas`
- Blas responsibility: `$200.000`
- Blas expected cash outflow: `$400.000`

Both numbers are valid.
They answer different questions.
They should not be collapsed into a single ambiguous metric.

## Planned visibility rules

The product may choose a short visibility window in the main feed to avoid clutter.

That is fine, but it must not change forecast math.

- feed visibility window controls what is shown in the timeline
- forecast math must consider all relevant pending planned expenses for the month

If a planned item exists for the current month but is not shown in the short feed window, it should still be counted in the monthly forecast.

## Payment confirmation rules

Paying a planned expense should:

1. create a real `expense`
2. preserve the effective amount actually paid
3. preserve the actual paid date
4. mark the planned item as `paid`
5. remove it from pending forecast

Skipping a planned expense should:

- mark it as skipped or otherwise exclude it from pending forecast
- not affect the real balance

## What HomeSync should optimize for

HomeSync is not just a debt app like Splitwise and not just a budget app like YNAB or Monarch.

It should solve both:

- real shared balance between the couple
- planning of upcoming household obligations
- clarity between total cost, user share, and expected payer cashflow

## Current code behavior vs canonical behavior

This section reflects the current implementation observed in the codebase on 2026-04-01.

### 1. Current code computes pending as payer cashflow, not user share

Observed in:

- [expense_provider.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/features/expenses/presentation/providers/expense_provider.dart)

Current logic:

- real expenses add to `spent` only when `item.payerId == userId`
- planned expenses add to `pending` only when `item.payerId == userId`
- the full planned amount is counted

Implication:

- for a shared `equal` recurring expense, the current user may see the full amount as pending if they are the habitual payer
- this is a cashflow forecast
- it is not a responsibility forecast

That means the current UI label `Balance estimado` is misleading unless we intentionally define it as cashflow.

### 2. Current code derives forecast from the short feed window

Observed in:

- [expenses_screen.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/features/expenses/presentation/screens/expenses_screen.dart)

The feed currently hides planned items unless they are:

- overdue
- due today
- within the next 2 days

The projection logic reads from the combined feed provider.

Implication:

- monthly forecast can miss valid pending items later in the same month
- forecast becomes a "near-term reminder" instead of a true monthly projection

This should be changed.

### 3. Runtime contract drift exists around recurring generation

Observed in code:

- frontend calls `process_recurring_expenses`
- older docs and migrations prominently describe `ensure_planned_expenses`
- Flutter model carries `next_execution_date`

Observed docs and migrations do not clearly reconcile these three pieces.

Implication:

- finance documentation is partially outdated
- the exact generation rule for recurring items is not documented as a stable contract

### 4. Current recurring UI only exposes a simplified split model

Observed in:

- [recurring_expense_form_sheet.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/features/expenses/presentation/widgets/recurring_expense_form_sheet.dart)

Current UI supports:

- `equal`
- `personal`

This is acceptable for the current product scope, but docs should not imply that recurring forecast already supports the full split spectrum in the UX.

## Product decision recommended for HomeSync

The cleanest product definition is:

1. Keep `Balance actual` as real, confirmed, current-month data.
2. Add or redefine `Tu parte pendiente` as the main shared forecast metric.
3. Keep `Flujo de caja pendiente` as a separate operational metric if useful.
4. Make `Balance estimado` mean `Balance actual - Tu parte pendiente`.
5. Keep planned cards showing total amount plus split plus habitual payer.
6. Do not backfill newly created recurring rules implicitly.
7. Calculate forecast from all pending items in the month, not only the ones visible in the short feed.

## Suggested next engineering step

Before changing UI copy or SQL, we should align product semantics around these two questions:

1. Should `Balance estimado` mean responsibility forecast or cashflow forecast?
2. Should a newly created recurring item ever backfill the current cycle automatically?

My recommendation:

- `Balance estimado` = responsibility forecast
- backfill = explicit only, never implicit
