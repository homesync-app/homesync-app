# Modo Convivencia (friends) — Plan de rediseño

> Estado: EN PROGRESO · Rama: `codex/convivencia-mode`
> Objetivo: convertir "convivencia" de un clon recortado de "familia" en un modo
> propio centrado en **equidad entre pares adultos**: tareas + finanzas, sin
> gamificación infantil, sin roles padre/madre, sin tienda de premios.

## Principio de diseño

**Familia premia. Convivencia equilibra.** Roomies son adultos iguales; nadie
aprueba a nadie. La pregunta central es "¿estamos parejos? ¿quién le debe a
quién?". Todo lo que reduzca fricción y aumente transparencia suma; todo lo que
sea infantil (estrellas, coins) o competitivo (corona al mejor) resta.

## Funcionalidades objetivo (aprobadas por el usuario)

1. **Equilibrio de aporte** — reemplaza al ranking competitivo. Tareas hechas +
   gastos compartidos pagados del mes, en framing neutro de balance, sin ganador.
2. **Cuentas del piso (gastos recurrentes)** — alquiler, luz, internet, expensas.
   Cargar "Alquiler $X, dividido entre N" y que se genere solo cada mes.
3. **Settle up / saldar cuentas** — protagonista, no extra. "Estás en cero con
   Juan", "le debés $3.000 a Ana".
4. **Rotación justa de tareas (sin aprobación)** — turnos parejos, nadie aprueba.
5. **Cero gamificación infantil** — fuera coins/XP/tienda. Incentivo permitido:
   cumplimiento ("12 de 15 tareas del piso hechas esta semana").

## Lo que se saca de convivencia (heredado de familia)

- [ ] Botón "Tienda"/premios (`FamilyRewardsScreen`) en el tab Convivencia.
- [ ] Ranking competitivo padres-vs-hijos (`FamilyRankingSection`) en friends.
- [ ] Roles padre/madre y `member_type='parent'` para friends.
- [x] Modo padres — YA gateado a `family` (`parentModeAvailableProvider`, etc.). OK.

## Bug confirmado aparte

- [ ] Overflow de 17px en el step "Convivencia creada" del setup
  (`_buildInviteCodeStepV2` en `setup_screen.dart`).

## Infra existente reutilizable (NO reinventar)

- Gastos recurrentes: `expense_template` + `processRecurringExpenses` + RPC.
- Rotación de tareas: `rotation_pool` / `rotation_strategy` / `advance_task_rotation`.
- Settle up: `DebtSettlementSection` + `settleDebt` (ya usado en HomeFriendsView).
- Balances: `expenseBalancesProvider` + `FamilyBalanceCard`.

## Fases (cada una verificable e independiente)

### Fase 0 — Quirúrgico / bajo riesgo (UI gating)
- [x] Fix overflow setup (17px) — `_buildInviteCodeStepV2` ahora scrollea.
- [x] Tab Convivencia: ocultar tienda (`usesRewardsStore`) + ranking competitivo
      (`usesCompetitiveRanking`) para `friends`.
- Verificación: `flutter analyze` OK.

### Fase 1 — Roles neutros
- [x] Header del hub: rol neutro "Integrante" en friends (`usesFamilyRoles`),
      nunca "Padre/Madre". Key ARB `householdSocialHubRoleMember` (es/en).
- [x] Setup/onboarding: friends ya usa display_role 'Adulto' (verificado).
- Nota: `member_type='parent'` se mantiene para friends a nivel permisos
      (es adulto, ve finanzas). Solo se neutraliza el LABEL visible.
- Verificación: tests de provider + crear hogar friends nuevo.

### Fase 2 — Equilibrio de aporte (feature nueva)
- [x] `contributionBalanceProvider`: combina tareas hechas (weeklyRanking) +
      gastos pagados del mes (combinedFeed por payer). Sin queries nuevas.
- [x] Widget `ContributionBalanceCard`: framing neutro (sin ranking/corona),
      orden por nombre, 2 barras de proporción (tareas/plata) por integrante.
- [x] Reemplaza `FamilyRankingSection` en el tab convivencia (`usesContributionBalance`).
- [x] Keys ARB es/en (título, subtítulo, vacío, plural tareas, footnote).
- Verificación: `flutter analyze` OK. Falta check visual en device.

### Fase 3 — Cuentas del piso (gastos recurrentes destacados)
- [x] Widget `HouseholdBillsCard`: lista gastos fijos compartidos del hogar
      (reusa `expenseTemplateControllerProvider`, filtra income/personal) +
      botón "Agregar cuenta del piso" que abre `RecurringExpenseFormSheet.show`.
- [x] Integrado en hub de convivencia bajo el equilibrio de aporte.
- [x] Gate premium: gasto recurrente es feature premium. Sin premium muestra
      candado + CTA al `PremiumPaywall` (mismo patrón que `RecurrentesTab`).
- [x] Keys ARB es/en (título, subtítulo, vacío, botón, /mes, día, premium).
- Verificación: `flutter analyze` OK.

### Fase 4 — Pulido (PENDIENTE)
- [ ] Settle up como sección protagonista del tab convivencia.
- [ ] Repaso de copy/i18n específico (sin jerga familiar).

## Reglas de trabajo

- No commitear sin pedido explícito del usuario.
- `flutter analyze` + tests relevantes después de cada fase.
- Migraciones SQL: smoke test de RPCs críticos antes de tocar grants (ver AGENTS.md).
- Strings UI nuevos SIEMPRE vía ARB (`app_es.arb` fuente, `app_en.arb` a mano).
