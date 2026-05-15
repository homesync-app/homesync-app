# HomeSync - Politica de optimistic updates

Este archivo es contrato operativo para agentes IA. Si una accion no aparece aca, no se inventa optimistic update nuevo.

| action | optimistic_behavior | rollback | invalidations | offline_behavior |
|---|---|---|---|---|
| `delete_expense_v1` | Remover el item local del feed inmediatamente; balances y resumen esperan backend. | Restaurar feed previo si falla el RPC. | `expenseBalancesProvider`, `personalFinanceSummaryProvider`, `combinedFeedControllerProvider`, `recentActivityProvider`. | Encolar solo si el repositorio ya soporta queue; mostrar estado pendiente, no recalcular balances localmente. |
| `save_expense_v4` | No asumir exito financiero. Mostrar loading, esperar backend y refrescar. | No aplica salvo reset del formulario. | `expenseControllerProvider`, `expenseBalancesProvider`, `personalFinanceSummaryProvider`, `combinedFeedControllerProvider`, `recentActivityProvider`. | Queue RPC existente permitida; el feed financiero queda como fuente backend hasta confirmacion. |
| `complete_task_v1` | Marcar/remover tarea localmente para respuesta rapida; recent activity puede agregar activity optimista visual. | Restaurar lista previa si falla; limpiar activity optimista. | `tasksProvider`, `todayTasksProvider`, `recentActivityProvider`, `userBalanceProvider`, `statsControllerProvider`. | Encolar `complete_task_v1` con request id; UI debe mostrar estado no confirmado si aplica. |
| `approve_task_v1` | No acreditar rewards localmente. Esperar backend y refrescar. | No aplica. | `recentActivityProvider`, `combinedFeedControllerProvider`, `userBalanceProvider`, pendientes de aprobacion, tasks. | Encolar solo si hay UX explicita de decision pendiente; si no, bloquear accion offline. |
| `undo_task_completion_v1` | No borrar rewards localmente sin respuesta. Mostrar loading y refrescar al exito. | No aplica; si falla, mantener estado visible. | `tasksProvider`, `todayTasksProvider`, `recentActivityProvider`, `combinedFeedControllerProvider`, `expenseBalancesProvider`, `personalFinanceSummaryProvider`, `statsControllerProvider`. | Encolar `undo_task_completion_v1`; no ocultar definitivamente la activity hasta confirmacion. |
| `reject_task_v1` | No cambiar rewards. Puede remover la card de pendientes despues de exito. | Si falla, mantener pendiente. | pendientes de aprobacion, tasks, recent activity/notificaciones si se muestran. | Preferir bloquear offline salvo que se agregue queue explicita para decisiones de aprobacion. |
| `shopping toggle item` | Optimistic permitido: marcar comprado/no comprado en lista. | Restaurar item previo si falla. | `shoppingProvider`; feed solo si el backend genera activity. | Queue existente permitida con estado pendiente. |

## Reglas

- Finanzas reales son backend-first: gastos, settlements y balances no se recalculan a mano en UI como fuente de verdad.
- Tareas y shopping son reversibles: optimistic update permitido si el rollback esta escrito en el mismo controller.
- El feed combinado es cache de servidor. Se permite remocion local inmediata para UX, pero siempre se invalida despues.
- Si una accion toca XP/coins, no actualizar balances localmente salvo que haya un contrato de idempotencia escrito.
