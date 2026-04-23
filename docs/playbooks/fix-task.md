# Playbook: Fix Bug en Tasks

## Archivos clave

- `flutter_client/lib/features/tasks/` — feature completa
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_family_view.dart` (~1051 LOC — NO leer entero)
- `flutter_client/lib/features/dashboard/presentation/screens/modes/family_tasks_section.dart` (~725 LOC — Tasks section)
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_couple_view.dart`

## Estructura de home_family_view

Secciones extraídas a archivos separados:
- **Weekly summary + ranking**: `family_weekly_summary_section.dart` (~532 LOC)
- **Finance**: `family_finance_section.dart` (~354 LOC)
- **Tasks**: `family_tasks_section.dart` (~725 LOC) — incluye flujo de aprobación

Lo que queda en `home_family_view.dart`: header, banners, welcome, shopping, activity, personal finance/child wallet.

## Estructura de family_tasks_section

ConsumerStatefulWidget con:
- Task list display (loading, empty, data states)
- 5 Future methods para approval flow: confirm, submit for approval, approve, reject, complete
- Constructor params: `caps`, `currentMember`, `isChild`

## Reglas

- Para bugs de tasks en family mode: ir directo a `family_tasks_section.dart`
- Para bugs en dashboard general: grep en `home_family_view.dart` por nombre de método
- Probar con `cd flutter_client && flutter test` después del fix
